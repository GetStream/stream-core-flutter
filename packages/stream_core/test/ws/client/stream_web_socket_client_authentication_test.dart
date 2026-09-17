import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

import '../../helpers/fake_server.dart';
import '../../helpers/user_token.dart';
import '../../helpers/ws_client_tester.dart';

void main() {
  group('authenticate', () {
    wsClientTest(
      'presents credentials once the socket is open, while authenticating',
      authenticator: (send, _) async {
        send(const WsAuthMessageRequest(token: 'token')).getOrThrow();
      },
      connect: (tester) async {
        WebSocketConnectionState? whenPresented;
        tester.server.onFrame = (_) {
          whenPresented = tester.connectionState;
          return [];
        };

        await tester.client.connect();
        await tester.pumpEventQueue();

        // The socket is open but the connection is not usable until the server answers.
        expect(whenPresented, isA<Authenticating>());
      },
      body: (tester) {
        expect(tester.connectionState, isA<Authenticating>());
      },
    );

    wsClientTest(
      'authenticates once per connection attempt',
      body: (tester) async {
        expect(tester.server.received, hasLength(1));

        await tester.client.disconnect();
        await tester.client.connect();
        await tester.pumpEventQueue();

        // Each attempt presents credentials of its own; the server has now seen two handshakes.
        expect(tester.server.received, hasLength(2));
        expect(tester.connectionState, isA<Connected>());
      },
    );

    wsClientTest(
      'puts the credentials it was given on the wire',
      tokenLoader: (userId) async => generateTestUserToken(userId),
      body: (tester) {
        // Really serialised and really read by the server, rather than handed over in memory.
        final handshake = tester.server.received.single;
        expect(handshake['token'], isA<String>());
        expect(tester.tokenLoads, 1);
      },
    );

    wsClientTest(
      'stays authenticating when there is nothing to authenticate with',
      authenticates: false,
      connect: (tester) async {
        await tester.client.connect();
        await tester.pumpEventQueue();
      },
      body: (tester) async {
        // Nothing was sent, so the server has nothing to answer and the connection waits.
        expect(tester.server.received, isEmpty);
        expect(tester.connectionState, isA<Authenticating>());

        await tester.emit({'type': 'connection.ok', 'connection_id': 'connection-id'});
        expect(tester.connectionState, isA<Connected>());
      },
    );

    group('the refusal handed to the next attempt', () {
      /// Records what each attempt was told about the previous one.
      ({WebSocketAuthenticator authenticator, List<StreamApiException?> seen}) watching() {
        final seen = <StreamApiException?>[];
        return (
          authenticator: (send, previousError) async {
            seen.add(previousError);
            send(WsAuthMessageRequest(token: generateTestUserToken('luke_skywalker').rawValue)).getOrThrow();
          },
          seen: seen,
        );
      }

      test('is what the server closed the previous attempt with', () async {
        final (:authenticator, :seen) = watching();
        final tester = buildTester(authenticator: authenticator);

        await tester.client.connect();
        await tester.pumpEventQueue();

        await tester.emit(expiredTokenFrame());
        await tester.client.connect();
        await tester.pumpEventQueue();

        // The second attempt is told why the first ended, so it can present something else.
        expect(seen, [null, isA<StreamApiException>().having((it) => it.code, 'code', 40)]);
      });

      test('is handed on even when the closure is not one to reconnect from', () async {
        final (:authenticator, :seen) = watching();
        final tester = buildTester(authenticator: authenticator);

        await tester.client.connect();
        await tester.pumpEventQueue();

        // A refusal no other token repairs, so nothing reconnects on the client's own initiative.
        await tester.emit(invalidSignatureFrame());
        expect(tester.connectionState.isAutomaticReconnectionEnabled, isFalse);

        await tester.client.connect();
        await tester.pumpEventQueue();

        // A caller who connects again is presenting credentials of their own, and needs to be told
        // what the last ones were refused for however the closure was classified.
        expect(seen, [null, isA<StreamApiException>().having((it) => it.code, 'code', 43)]);
      });

      test('is spent even for a connection that authenticates through its options', () async {
        // Nothing is sent over a socket whose credential rides in its URL, so the options builder is
        // the only reader. Establishing clears the refusal on its own, so the attempt between has to
        // be one that opens and then drops.
        final tester = buildTester(authenticates: false);

        await tester.client.connect();
        await tester.emit(healthCheckFrame());
        await tester.emit(expiredTokenFrame());

        // The second attempt is told what the server refused, and spends it by opening at all.
        await tester.client.connect();
        await tester.pumpEventQueue();
        tester.server.hangUp();
        await tester.pumpEventQueue();

        // The third is told nothing: the drop above says nothing about the credentials.
        await tester.client.connect();
        await tester.pumpEventQueue();

        expect(tester.refusals, [null, isA<StreamApiException>().having((it) => it.code, 'code', 40), null]);
      });

      test('is absent once a connection has been established', () async {
        final (:authenticator, :seen) = watching();
        final tester = buildTester(authenticator: authenticator);

        await tester.client.connect();
        await tester.pumpEventQueue();
        await tester.emit(expiredTokenFrame());

        // The replacement is accepted, so the refusal is spent.
        await tester.client.connect();
        await tester.pumpEventQueue();
        expect(tester.connectionState, isA<Connected>());

        await tester.client.disconnect();
        await tester.client.connect();
        await tester.pumpEventQueue();

        expect(seen, [null, isA<StreamApiException>(), null]);
      });

      test('is absent after a closure the server did not cause', () async {
        final seen = <StreamApiException?>[];
        final tester = buildTester(
          // Declines, the way an authenticator with nothing left to offer does, which closes the
          // connection as `AuthenticationFailed`.
          authenticator: (send, previousError) async {
            seen.add(previousError);
            if (previousError != null) throw StateError('nothing to offer');
            send(WsAuthMessageRequest(token: generateTestUserToken('luke_skywalker').rawValue)).getOrThrow();
          },
        );

        await tester.client.connect();
        await tester.pumpEventQueue();
        await tester.emit(expiredTokenFrame());

        await tester.client.connect();
        await tester.pumpEventQueue();
        expect(
          tester.connectionState,
          isA<Disconnected>().having((it) => it.source, 'source', isA<AuthenticationFailed>()),
        );

        // A refusal left armed through that would decline this attempt too, without the credentials
        // it carries ever being sent.
        await tester.client.connect();
        await tester.pumpEventQueue();

        expect(seen, [null, isA<StreamApiException>(), null]);
      });
    });

    group('when authentication fails', () {
      wsClientTest(
        'closes the connection instead of waiting for a reply',
        authenticator: (_, _) async => throw StateError('no token'),
        connect: (tester) async {
          await tester.client.connect();
          await tester.pumpEventQueue();
        },
        body: (tester) {
          expect(
            tester.connectionState,
            isA<Disconnected>().having(
              (it) => it.source,
              'source',
              isA<AuthenticationFailed>().having(
                (it) => it.error,
                'error',
                // Whatever the authenticator threw arrives as an authentication
                // failure, with the original error preserved as its cause.
                isA<StreamAuthenticationException>().having((it) => it.cause, 'cause', isStateError),
              ),
            ),
          );
        },
      );

      wsClientTest(
        'does not retry, since the same credentials would fail again',
        authenticator: (_, _) async => throw StateError('no token'),
        recover: true,
        connect: (tester) async {
          await tester.client.connect();
          await tester.pumpEventQueue();
        },
        body: (tester) {
          expect(tester.connectionState.isAutomaticReconnectionEnabled, isFalse);

          // Nothing was sent, so there is nothing for a retry to build on.
          expect(tester.server.received, isEmpty);
          expect(tester.attempts, 1);
        },
      );

      wsClientTest(
        'retries when the token provider named the moment rather than the credentials',
        authenticator: (_, _) async => throw const StreamNetworkException(
          message: 'The token endpoint was unreachable',
        ),
        recover: true,
        connect: (tester) async {
          await tester.client.connect();
          await tester.pumpEventQueue();
        },
        body: (tester) {
          // A failure the provider classified itself keeps its kind all the way here, which is what
          // makes the reconnect carve-out reachable at all.
          expect(
            tester.connectionState,
            isA<Disconnected>().having(
              (it) => it.source,
              'source',
              isA<AuthenticationFailed>().having((it) => it.error, 'error', isA<StreamNetworkException>()),
            ),
          );

          expect(tester.connectionState.isAutomaticReconnectionEnabled, isTrue);
        },
      );

      wsClientTest(
        'reports a refusal the server sent, carrying what it said',
        connect: (tester) async {
          // The credentials reach the server and it refuses them, rather than the client failing to
          // present any.
          tester.server.onFrame = (_) => [invalidSignatureFrame()];

          await tester.client.connect();
          await tester.pumpEventQueue();
        },
        body: (tester) {
          // The credentials went out and were answered, so this is the server's refusal rather than
          // a failure to present them.
          expect(tester.server.received, hasLength(1));
          expect(
            tester.connectionState,
            isA<Disconnected>().having(
              (it) => it.source,
              'source',
              isA<ServerInitiated>().having(
                (it) => it.error,
                'error',
                isA<StreamApiException>().having((it) => it.code, 'code', 43),
              ),
            ),
          );

          // No other token repairs a signature the server rejected.
          expect(tester.connectionState.isAutomaticReconnectionEnabled, isFalse);
        },
      );
    });

    group('when an attempt is abandoned while authenticating', () {
      test('does not send its credentials over the connection that replaced it', () {
        fakeAsync((async) {
          final loaded = Completer<void>();
          var calls = 0;
          final tester = buildTester(
            // Only the first attempt waits, so the token it is eventually handed belongs to a
            // connection that has since been abandoned.
            authenticator: (send, _) async {
              if (++calls > 1) return;
              await loaded.future;
              send(const WsAuthMessageRequest(token: 'stale')).getOrThrow();
            },
          );

          tester.client.connect().ignore();
          async.flushMicrotasks();
          final abandoned = tester.server.socket;

          async.elapse(WebSocketOptions.defaultConnectTimeout);
          expect(tester.connectionState, isA<Disconnected>());

          tester.client.connect().ignore();
          async.flushMicrotasks();
          final replacement = tester.server.socket;
          expect(replacement, isNot(abandoned));

          loaded.complete();
          async.flushMicrotasks();

          // The sender writes to whichever socket the engine holds, so credentials loaded for the
          // abandoned attempt land on the one that replaced it and never asked for them.
          expect(tester.server.received, isEmpty);
        });
      });

      test('leaves the reason a closed attempt was abandoned for alone', () {
        fakeAsync((async) {
          // A token load that outlives the attempt the timeout abandoned and then fails. The attempt
          // it belonged to is gone, so its failure describes a connection that no longer exists.
          final loaded = Completer<void>();
          final tester = buildTester(
            authenticator: (_, _) async {
              await loaded.future;
              throw StateError('token load failed');
            },
          );

          tester.client.connect().ignore();
          async.flushMicrotasks();

          async.elapse(WebSocketOptions.defaultConnectTimeout);
          expect(tester.connectionState, isA<Disconnected>());

          loaded.complete();
          async.flushMicrotasks();

          // Recorded, it would replace a reason worth reconnecting for with one that never is, and
          // an established connection would stop recovering for the life of the client.
          final state = tester.connectionState;
          expect(state, isA<Disconnected>().having((it) => it.source, 'source', isA<ConnectTimeout>()));
          expect(state.isAutomaticReconnectionEnabled, isTrue);
        });
      });

      test('does not close the connection that replaced it when its credentials fail', () {
        fakeAsync((async) {
          final loaded = Completer<void>();
          var calls = 0;
          final tester = buildTester(
            authenticator: (send, _) async {
              if (++calls > 1) return;
              await loaded.future;
              throw StateError('token load failed');
            },
          );

          tester.client.connect().ignore();
          async.flushMicrotasks();

          async.elapse(WebSocketOptions.defaultConnectTimeout);

          tester.client.connect().ignore();
          async.flushMicrotasks();
          tester.server.send({'type': 'connection.ok', 'connection_id': 'connection-id'});
          async.flushMicrotasks();
          expect(tester.connectionState, isA<Connected>());

          loaded.complete();
          async.flushMicrotasks();

          // The failure belongs to an attempt abandoned before this connection was opened. Reported
          // against this one it closes a working connection as `AuthenticationFailed`, which is
          // never retried.
          expect(tester.connectionState, isA<Connected>());
        });
      });
    });
  });

  group('the token behind the connection', () {
    // The handshake a consuming SDK performs, which acts on `previousError`: an expired token is
    // dropped so the provider can issue another, and a provider with nothing else to give declines
    // rather than presenting the same token again.
    WebSocketAuthenticator authenticatorFor(TokenManager tokens) {
      return (send, previousError) async {
        if (previousError?.isTokenExpired ?? false) {
          tokens.expireToken();
          if (tokens.usesStaticProvider) {
            throw const StreamAuthenticationException(
              message: 'The token was refused and the provider has no other to give',
            );
          }
        }

        final token = await tokens.getToken();
        send(WsAuthMessageRequest(token: token.rawValue)).getOrThrow();
      };
    }

    test('is still answered for by the attempt after it, when the user has not changed', () {
      fakeAsync((async) {
        final asked = <StreamApiException?>[];
        final tokens = TokenManager(
          userId: 'user-1',
          tokenProvider: TokenProvider.dynamic((id) async => generateTestUserToken(id)),
        );
        final tester = buildTester(
          tokens: tokens,
          authenticator: (send, previousError) async {
            asked.add(previousError);
            send(WsAuthMessageRequest(token: (await tokens.getToken()).rawValue)).getOrThrow();
          },
        );
        tester.server.onFrame = (_) => [
          {'type': 'connection.ok', 'connection_id': 'connection-id'},
        ];

        tester.client.connect().ignore();
        async.flushMicrotasks();

        tester.server.send(expiredTokenFrame());
        async.flushMicrotasks();

        tester.client.connect().ignore();
        async.flushMicrotasks();

        // Nothing replaced the credentials, so the refusal still describes what this attempt holds
        // and forgetting it would leave the same token offered again.
        expect(asked, [null, isA<StreamApiException>().having((it) => it.code, 'code', 40)]);
      });
    });

    test('is not answered for with a refusal recorded against the user before it', () {
      fakeAsync((async) {
        final tokens = TokenManager(
          userId: 'user-1',
          tokenProvider: TokenProvider.dynamic((id) async => generateTestUserToken(id)),
        );
        final tester = buildTester(tokens: tokens, authenticator: authenticatorFor(tokens));
        // Whose token it is, is the server's business elsewhere; this is about what the client does.
        tester.server.onFrame = (_) => [
          {'type': 'connection.ok', 'connection_id': 'connection-id'},
        ];

        tester.client.connect().ignore();
        async.flushMicrotasks();
        expect(tester.connectionState, isA<Connected>());

        // The server refuses the token. Nothing retries it, so the refusal is still armed.
        tester.server.send(expiredTokenFrame());
        async.flushMicrotasks();
        expect(tester.connectionState, isA<Disconnected>());

        // The app takes connecting back, then signs a different user in: a new identity, on a
        // provider with one token to give, as a guest exchange produces.
        tester.client.disconnect().ignore();
        async.flushMicrotasks();
        tokens.setTokenProvider('guest-1', tokenProvider: TokenProvider.static(generateTestUserToken('guest-1')));

        tester.client.connect().ignore();
        async.flushMicrotasks();

        // The refusal was about the user before this one. Handed on, it makes an authenticator drop
        // credentials that were never refused and decline a connection that would have been served.
        expect(tester.connectionState, isA<Connected>());
        expect(tokens.peekToken(), isNotNull);
      });
    });

    test('comes back with a fresh token after the server refuses an expired one', () {
      fakeAsync((async) {
        final tester = buildTester(recover: true);

        tester.client.connect().ignore();
        async.flushMicrotasks();
        expect(tester.connectionState, isA<Connected>());
        expect(tester.tokenLoads, 1);

        // The server refuses the token of a connection that was working.
        tester.server.send(expiredTokenFrame());
        async.flushMicrotasks();
        async.elapse(Duration.zero);

        // Reconnecting is the recovery handler's, and the token it presents was loaded after the
        // refusal. The app is told nothing and does nothing.
        expect(tester.connectionState, isA<Connected>());
        expect(tester.tokenLoads, 2);
        expect(tester.states.whereType<Connecting>(), hasLength(2));
      });
    });

    test('presents the replacement, not the token that was refused', () {
      fakeAsync((async) {
        var issued = 0;
        final tester = buildTester(
          recover: true,
          // A backend handing out a distinguishable token each time. The user has to stay the same —
          // a manager configured for one user refuses to cache another's token — so these differ by
          // the nonce they carry.
          tokenLoader: (userId) async => generateTestUserToken(userId, nonce: '${++issued}'),
        );
        // The server accepts any token, so what matters is which one arrives second.
        tester.server.onFrame = (_) => [
          {'type': 'connection.ok', 'connection_id': 'connection-id'},
        ];

        tester.client.connect().ignore();
        async.flushMicrotasks();

        tester.server.send(expiredTokenFrame());
        async.flushMicrotasks();
        async.elapse(Duration.zero);

        final presented = tester.server.received.map((it) => it['token']).toList();
        expect(presented, hasLength(2));

        // Offering the refused token again would be refused again, for the life of the client.
        expect(presented[1], isNot(presented[0]));
      });
    });

    test('keeps the token when the server closed for a reason that was not about it', () {
      fakeAsync((async) {
        final tester = buildTester(recover: true);

        tester.client.connect().ignore();
        async.flushMicrotasks();
        expect(tester.tokenLoads, 1);

        // A server error that says nothing about the token, and is retried like any other. Dropping
        // the token here would send the reconnect to the provider for one that was never refused.
        tester.server.send(connectionErrorFrame(code: 5, statusCode: 500));
        async.flushMicrotasks();
        async.elapse(Duration.zero);

        expect(tester.connectionState, isA<Connected>());
        expect(tester.tokenLoads, 1);
      });
    });

    test('keeps the token across a disconnect the caller asked for', () {
      fakeAsync((async) {
        final tester = buildTester(recover: true);

        tester.client.connect().ignore();
        async.flushMicrotasks();
        expect(tester.tokenLoads, 1);

        // A deliberate disconnect says nothing about the token. Dropping it here would send every
        // reconnect to the provider for a token that was never refused.
        tester.client.disconnect().ignore();
        async.flushMicrotasks();
        tester.client.connect().ignore();
        async.flushMicrotasks();

        expect(tester.connectionState, isA<Connected>());
        expect(tester.tokenLoads, 1);
      });
    });

    test('keeps the token across a connection that stopped answering', () {
      fakeAsync((async) {
        final tester = buildTester(recover: true);

        tester.client.connect().ignore();
        async.flushMicrotasks();
        expect(tester.tokenLoads, 1);

        // A connection that goes quiet says nothing about the token either.
        tester.server.onFrame = (frame) => switch (frame['type']) {
          'health.check' => const [],
          _ => [
            {'type': 'connection.ok', 'connection_id': 'connection-id'},
          ],
        };
        async.elapse(const Duration(seconds: 29));
        async.flushMicrotasks();

        expect(tester.states.whereType<Connecting>(), hasLength(2));
        expect(tester.tokenLoads, 1);
      });
    });

    test('stays closed when no other token would be accepted', () {
      fakeAsync((async) {
        final tester = buildTester(recover: true);

        tester.client.connect().ignore();
        async.flushMicrotasks();

        // A signature signed with the wrong secret: another token from the same provider carries the
        // same problem, so retrying would offer refused credentials for the life of the client.
        tester.server.send(invalidSignatureFrame());
        async.flushMicrotasks();
        async.elapse(const Duration(minutes: 1));

        expect(tester.connectionState, isA<Disconnected>());
        expect(tester.tokenLoads, 1);
        expect(tester.attempts, 1);
      });
    });
  });
}
