import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

import '../../helpers/fake_server.dart';
import '../../helpers/user_token.dart';
import '../../helpers/ws_client_tester.dart';

/// A connect that is expected not to establish anything, so nothing is asserted about the outcome.
Future<void> _justConnect(WsClientTester tester) async {
  await tester.client.connect();
  await tester.pumpEventQueue();
}

void main() {
  group('connect', () {
    wsClientTest(
      'reports a handshake that failed as closed',
      handshakeFails: true,
      connect: _justConnect,
      body: (tester) {
        // Nothing else reports it: a socket that never opened has no closure of its own to deliver,
        // so the client would otherwise be left connecting for good.
        expect(tester.connectionState, isA<Disconnected>());
      },
    );

    wsClientTest(
      'reports a handshake that failed with the reason it failed',
      handshakeFails: true,
      connect: _justConnect,
      body: (tester) {
        // Closed without saying why, the attempt reads as the deliberate close the engine defaults
        // to, and a closure with that code is never reconnected.
        expect(
          tester.connectionState,
          isA<Disconnected>().having(
            (it) => it.source,
            'source',
            isA<ServerInitiated>().having((it) => it.error?.error, 'error', isNotNull),
          ),
        );
        expect(tester.connectionState.isAutomaticReconnectionEnabled, isTrue);
      },
    );

    wsClientTest(
      'lets a caller connect again straight after a failed handshake',
      handshakeFails: true,
      connect: (_) {},
      body: (tester) async {
        // Nothing is pumped between the two calls, so `connect` has to finish abandoning the first
        // attempt before it returns; otherwise the second is refused for racing a close still
        // under way, and the caller is left with a connection nobody is trying to make.
        await tester.client.connect();
        await tester.client.connect();

        expect(tester.attempts, 2);
      },
    );

    wsClientTest(
      'reports the closure when the socket of a failed handshake refuses to close',
      handshakeFails: true,
      closeError: Exception('close failed'),
      connect: _justConnect,
      body: (tester) async {
        // The engine announces nothing when a close fails, and the connect timeout cannot rescue a
        // state that is already `Disconnecting`, so this would stay there for good.
        expect(tester.connectionState, isA<Disconnected>());

        await tester.client.connect();
        await tester.pumpEventQueue();
        expect(tester.attempts, 2);
      },
    );

    wsClientTest(
      'ignores a handshake that finishes after the connection was closed',
      handshakeHangs: true,
      connect: (_) {},
      body: (tester) async {
        tester.client.connect().ignore();
        await tester.pumpEventQueue();

        await tester.client.disconnect();
        await tester.pumpEventQueue();
        expect(tester.connectionState, isA<Disconnected>().having((it) => it.source, 'source', isA<UserInitiated>()));

        // Acted on, it would authenticate a socket the client has let go of, and failing to send
        // would relabel the closure as `AuthenticationFailed`. That costs a caller their own reason
        // here; on the connect-timeout path it turns a reconnectable `ConnectTimeout` into a state
        // that never reconnects.
        tester.server.sockets.last.completeReady();
        await tester.pumpEventQueue();

        expect(tester.connectionState, isA<Disconnected>().having((it) => it.source, 'source', isA<UserInitiated>()));
      },
    );

    wsClientTest(
      'closes a socket whose handshake failed',
      handshakeFails: true,
      connect: _justConnect,
      body: (tester) {
        // The socket is opened before the handshake it fails, so reporting closed without closing
        // left one open that nothing could reach — not even `dispose`.
        expect(tester.server.socket.sink.closedWith, isNotNull);
      },
    );

    wsClientTest(
      'leaves no socket behind for a later attempt to close',
      handshakeFails: true,
      connect: _justConnect,
      body: (tester) async {
        await tester.client.connect();
        await tester.pumpEventQueue();

        // Each attempt closes its own socket. A socket left behind is closed by the next attempt
        // instead, which reports a closure while that attempt is still connecting.
        expect(tester.server.sockets, hasLength(2));
        expect(tester.server.sockets.every((it) => it.sink.closedWith != null), isTrue);
      },
    );

    wsClientTest(
      'builds the options for every connection attempt, not once per client',
      body: (tester) async {
        expect(tester.attempts, 1);

        await tester.client.disconnect();
        await tester.client.connect();
        await tester.pumpEventQueue();

        expect(tester.attempts, 2);
      },
    );

    wsClientTest(
      'reports the connection established only once the server answers',
      connect: (tester) async {
        // A server that accepts the credentials but has not replied yet.
        tester.server.onFrame = (_) => [];

        await tester.client.connect();
        await tester.pumpEventQueue();
      },
      body: (tester) async {
        // `connect` completes when the socket opens, well before the connection is usable, which is
        // why an app watches the state rather than awaiting the call.
        expect(tester.connectionState, isA<Authenticating>());

        await tester.emit({'type': 'connection.ok', 'connection_id': 'connection-id'});

        expect(tester.connectionState, isA<Connected>());
        expect(
          tester.states.map((it) => it.runtimeType),
          containsAllInOrder([Initialized, Connecting, Authenticating, Connected]),
        );
      },
    );

    wsClientTest(
      'carries the connection id the server issued',
      connect: (tester) async {
        tester.server.onFrame = (_) => [];
        await tester.client.connect();
        await tester.pumpEventQueue();
      },
      body: (tester) async {
        await tester.emit({'type': 'connection.ok', 'connection_id': 'a-real-connection'});

        // The id is what later pings are stamped with, so it has to survive the wire.
        expect(
          tester.connectionState,
          isA<Connected>().having(
            (it) => it.healthCheck.connectionId,
            'healthCheck.connectionId',
            'a-real-connection',
          ),
        );
      },
    );
  });

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
      ({WebSocketAuthenticator authenticator, List<StreamApiError?> seen}) watching() {
        final seen = <StreamApiError?>[];
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
        expect(seen, [null, isA<StreamApiError>().having((it) => it.code, 'code', 40)]);
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
        expect(seen, [null, isA<StreamApiError>().having((it) => it.code, 'code', 43)]);
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

        expect(seen, [null, isA<StreamApiError>(), null]);
      });

      test('is absent after a closure the server did not cause', () async {
        final seen = <StreamApiError?>[];
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

        expect(seen, [null, isA<StreamApiError>(), null]);
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
              isA<AuthenticationFailed>().having((it) => it.error, 'error', isStateError),
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
                (it) => it.error?.apiError?.code,
                'apiError.code',
                43,
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

      test('records the failure when nothing replaced it, so it is not reconnected', () {
        fakeAsync((async) {
          // A token load that outlives the attempt the timeout abandoned and then fails. Nothing has
          // replaced that attempt, so this failure is the last word on it.
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

          // Nothing can repair credentials the authenticator has given up on, so an attempt left
          // eligible for a reconnection would be refused the same way.
          final state = tester.connectionState;
          expect(state, isA<Disconnected>().having((it) => it.source, 'source', isA<AuthenticationFailed>()));
          expect(state.isAutomaticReconnectionEnabled, isFalse);
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

  group('disconnect', () {
    wsClientTest(
      'leaves the connection closed, not closing, once it returns',
      body: (tester) async {
        await tester.client.disconnect();

        // A caller that reconnects straight away would otherwise race the close.
        expect(tester.connectionState, isA<Disconnected>());
      },
    );

    wsClientTest(
      'reports the connection closed even when the socket close fails',
      closeError: Exception('close failed'),
      body: (tester) async {
        await tester.client.disconnect();

        // The engine reports the failure rather than the closure, so the client is what moves this
        // out of 'disconnecting'.
        expect(
          tester.connectionState,
          isA<Disconnected>().having((it) => it.source, 'source', isA<UserInitiated>()),
        );
      },
    );

    wsClientTest(
      'leaves a client whose socket refused to close able to connect',
      closeError: Exception('close failed'),
      body: (tester) async {
        await tester.client.disconnect();

        await tester.client.connect();
        await tester.pumpEventQueue();

        // A socket that refuses to close is not one the client can use, and holding on to it would
        // refuse every later connect.
        expect(tester.connectionState, isA<Connected>());
        expect(tester.attempts, 2);
      },
    );

    wsClientTest(
      'does not open a socket while the previous one is still closing',
      holdClose: true,
      body: (tester) async {
        tester.client.disconnect().ignore();
        expect(tester.connectionState, isA<Disconnecting>());

        await tester.client.connect();

        // The old socket's close event would otherwise bring the new connection down and disarm the
        // timeout meant to be watching it.
        expect(tester.attempts, 1);
        expect(tester.connectionState, isA<Disconnecting>());
        tester.server.socket.sink.completeClose();
      },
    );

    wsClientTest(
      'does not refuse a connect made straight after it',
      connect: (_) {},
      body: (tester) async {
        // Not awaited, as a caller reasonably might not: there is no connection to close, so nothing
        // should stand in the way of the connect that follows.
        tester.client.disconnect().ignore();
        tester.client.connect().ignore();
        await tester.pumpEventQueue();

        expect(tester.connectionState, isA<Connected>());
        expect(tester.attempts, 1);
      },
    );

    wsClientTest(
      'leaves a client that never connected able to connect',
      connect: (_) {},
      body: (tester) async {
        // Nothing was opened, so there is nothing to close and no closure to report. Reporting one
        // would leave a connect made straight after it racing a close that never happened.
        await tester.client.disconnect();
        expect(tester.connectionState, isA<Initialized>());

        await tester.client.connect();
        await tester.pumpEventQueue();

        expect(tester.connectionState, isA<Connected>());
        expect(tester.attempts, 1);
      },
    );

    wsClientTest(
      'takes over a closure already under way',
      holdClose: true,
      body: (tester) async {
        // A closure the client decided on, still in flight.
        tester.client.disconnect(source: const UnHealthyConnection()).ignore();
        expect(tester.connectionState, isA<Disconnecting>());

        final disconnected = tester.client.disconnect();
        tester.server.socket.sink.completeClose();
        await disconnected;

        // Recorded as the caller's, so nothing is reconnected after they asked to stop.
        expect(
          tester.connectionState,
          isA<Disconnected>().having((it) => it.source, 'source', isA<UserInitiated>()),
        );
      },
    );

    wsClientTest(
      'takes over a closure the server already made',
      body: (tester) async {
        // The server hung up, which the client would reconnect after.
        tester.server.hangUp();
        await tester.pumpEventQueue();
        expect(tester.connectionState, isA<Disconnected>());

        await tester.client.disconnect();

        expect(
          tester.connectionState,
          isA<Disconnected>().having((it) => it.source, 'source', isA<UserInitiated>()),
        );
      },
    );

    wsClientTest(
      'keeps the reason the caller gave when a server error arrives mid-close',
      holdClose: true,
      body: (tester) async {
        tester.client.disconnect().ignore();

        // A rate limit clears on its own, so the client would reconnect after a closure recorded for
        // one.
        await tester.emit(connectionErrorFrame(code: 9, statusCode: 429));
        tester.server.socket.sink.completeClose();
        await tester.pumpEventQueue();

        expect(
          tester.connectionState,
          isA<Disconnected>().having((it) => it.source, 'source', isA<UserInitiated>()),
        );
      },
    );

    test('stands the health monitor down, so it cannot relabel the closure', () {
      fakeAsync((async) {
        final tester = buildTester();

        tester.client.connect().ignore();
        async.flushMicrotasks();
        expect(tester.connectionState, isA<Connected>());

        // A live connection is being watched, so there is something to stand down.
        expect(async.pendingTimers, isNotEmpty);

        tester.client.disconnect().ignore();
        async.flushMicrotasks();

        // Nothing is left to fire. A monitor still watching would report the connection unhealthy,
        // which is reconnected where the caller's closure is not.
        expect(async.pendingTimers, isEmpty);

        async.elapse(const Duration(minutes: 1));
        expect(
          tester.connectionState,
          isA<Disconnected>().having((it) => it.source, 'source', isA<UserInitiated>()),
        );
      });
    });

    group('dispose', () {
      wsClientTest(
        'closes the connection and both emitters',
        body: (tester) async {
          await tester.client.dispose();

          expect(tester.client.isDisposed, isTrue);
          expect(tester.client.events.isClosed, isTrue);
          expect(tester.client.connectionState.isClosed, isTrue);
        },
      );

      wsClientTest(
        'does nothing when called again',
        body: (tester) async {
          await tester.client.dispose();

          await expectLater(tester.client.dispose(), completes);
        },
      );

      wsClientTest(
        'refuses to connect again',
        body: (tester) async {
          await tester.client.dispose();

          // Throws rather than asserts, so a release build refuses too: the recovery handler is the
          // one caller that does not await this, and it ignores the future. The untouched builder
          // count pins that no socket was opened.
          await expectLater(tester.client.connect(), throwsA(isA<StateError>()));
          expect(tester.attempts, 1);
        },
      );
    });
  });

  group('the events it receives', () {
    group('an event the client has no handling of', () {
      wsClientTest(
        'reaches whoever is listening',
        body: (tester) async {
          final received = <WsEvent>[];
          final subscription = tester.client.events.listen(received.add);
          addTearDown(subscription.cancel);

          await tester.emit({'type': 'activity.added'});

          // Everything the client does not act on itself is an app's to act on, and an event it does
          // not recognise must not be taken as a reason to end the connection.
          expect(received, [isA<PlainEvent>().having((it) => it.type, 'type', 'activity.added')]);
          expect(tester.connectionState, isA<Connected>());
        },
      );
    });

    group('a health check', () {
      wsClientTest(
        'is emitted as well as acted on',
        body: (tester) async {
          final received = <WsEvent>[];
          final subscription = tester.client.events.listen(received.add);
          addTearDown(subscription.cancel);

          await tester.emit({'type': 'health.check', 'connection_id': 'connection-id'});

          // Handled and then passed on, so an app can react to a connection coming back.
          expect(received, hasLength(1));
          expect(tester.connectionState, isA<Connected>());
        },
      );
    });

    group('when the socket itself gives out', () {
      wsClientTest(
        'reports the closure as the server ending it',
        connect: (tester) async {
          await tester.client.connect();
          await tester.pumpEventQueue();
        },
        body: (tester) async {
          // Not a `connection.error` over a working socket: the socket is what failed.
          tester.server.fail(StateError('socket died'));
          await tester.pumpEventQueue();

          expect(
            tester.connectionState,
            isA<Disconnected>().having(
              (it) => it.source,
              'source',
              isA<ServerInitiated>().having((it) => it.error?.error, 'error.error', isStateError),
            ),
          );
        },
      );

      wsClientTest(
        'is reconnected, since nothing says the credentials were the problem',
        recover: true,
        body: (tester) async {
          tester.server.fail(StateError('socket died'));
          await tester.pumpEventQueue();

          // A socket that gave out says nothing about the token, so this is a drop to recover from,
          // and the token it presents again is the one it already had.
          expect(tester.attempts, 2);
          expect(tester.connectionState, isA<Connected>());
          expect(tester.tokenLoads, 1);
        },
      );
    });

    group('an error event the server sent', () {
      wsClientTest(
        'closes the connection rather than being emitted',
        body: (tester) async {
          final received = <WsEvent>[];
          final subscription = tester.client.events.listen(received.add);
          addTearDown(subscription.cancel);

          await tester.emit(expiredTokenFrame());

          // The client acts on it; an app learns about it from the connection state.
          expect(received, isEmpty);
          expect(
            tester.connectionState,
            isA<Disconnected>().having((it) => it.source, 'source', isA<ServerInitiated>()),
          );
        },
      );
    });
  });

  group('the connect timeout', () {
    test('abandons an attempt that never becomes connected', () {
      fakeAsync((async) {
        // A server that takes the credentials and never answers.
        final tester = buildTester();
        tester.server.onFrame = (_) => [];

        tester.client.connect().ignore();
        async.flushMicrotasks();

        // The socket opened, so the client is authenticating with nothing else watching it.
        expect(tester.connectionState, isA<Authenticating>());

        // Still waiting a tick before the timeout is due.
        async.elapse(WebSocketOptions.defaultConnectTimeout - const Duration(seconds: 1));
        expect(tester.connectionState, isA<Authenticating>());

        async.elapse(const Duration(seconds: 1));
        final state = tester.connectionState;
        expect(state, isA<Disconnected>().having((it) => it.source, 'source', isA<ConnectTimeout>()));

        // An attempt abandoned here is retried: a first health check that never arrives is the same
        // failure as one that stops arriving.
        expect(state.isAutomaticReconnectionEnabled, isTrue);
      });
    });

    test('abandons an attempt whose socket never opens', () {
      fakeAsync((async) {
        // A handshake that hangs, so the attempt never leaves 'connecting'.
        final tester = buildTester(handshakeHangs: true);

        tester.client.connect().ignore();
        async.flushMicrotasks();
        expect(tester.connectionState, isA<Connecting>());

        async.elapse(WebSocketOptions.defaultConnectTimeout);

        expect(
          tester.connectionState,
          isA<Disconnected>().having((it) => it.source, 'source', isA<ConnectTimeout>()),
        );
      });
    });

    test('abandons an attempt whose authenticator never returns', () {
      fakeAsync((async) {
        // An authenticator awaiting something that never resolves. Nothing else watches
        // 'authenticating', so only this fires.
        final tester = buildTester(
          authenticator: (_, _) => Completer<void>().future,
        );

        tester.client.connect().ignore();
        async.flushMicrotasks();
        expect(tester.connectionState, isA<Authenticating>());

        async.elapse(WebSocketOptions.defaultConnectTimeout);

        expect(
          tester.connectionState,
          isA<Disconnected>().having((it) => it.source, 'source', isA<ConnectTimeout>()),
        );
      });
    });

    test('times out a later attempt too', () {
      fakeAsync((async) {
        final tester = buildTester();
        tester.server.onFrame = (_) => [];

        tester.client.connect().ignore();
        async.flushMicrotasks();
        async.elapse(WebSocketOptions.defaultConnectTimeout);
        expect(tester.connectionState, isA<Disconnected>());

        tester.client.connect().ignore();
        async.flushMicrotasks();
        async.elapse(WebSocketOptions.defaultConnectTimeout);

        expect(
          tester.connectionState,
          isA<Disconnected>().having((it) => it.source, 'source', isA<ConnectTimeout>()),
        );
      });
    });

    test('honours a timeout given in the options', () {
      fakeAsync((async) {
        final tester = buildTester(connectTimeout: const Duration(seconds: 2));
        tester.server.onFrame = (_) => [];

        tester.client.connect().ignore();
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 2));

        expect(
          tester.connectionState,
          isA<Disconnected>().having((it) => it.source, 'source', isA<ConnectTimeout>()),
        );
      });
    });

    test('does not time out once the connection is established', () {
      fakeAsync((async) {
        // The default server answers every ping, which is what keeps a live connection alive.
        final tester = buildTester();

        tester.client.connect().ignore();
        async.flushMicrotasks();
        expect(tester.connectionState, isA<Connected>());

        // Past the timeout, and past several ping cycles with it.
        async.elapse(WebSocketOptions.defaultConnectTimeout + const Duration(seconds: 60));

        expect(tester.connectionState, isA<Connected>());
      });
    });

    test('does not replace the source of a closure that came first', () {
      fakeAsync((async) {
        final tester = buildTester();
        tester.server.onFrame = (_) => [];

        tester.client.connect().ignore();
        async.flushMicrotasks();

        // The server refuses and hangs up while the attempt is still being timed.
        tester.server.send(expiredTokenFrame());
        async.flushMicrotasks();

        async.elapse(WebSocketOptions.defaultConnectTimeout * 2);

        // The source of the closure already under way wins: `ConnectTimeout` would say the server
        // never answered, when it answered with a refusal an authenticator can act on.
        final state = tester.connectionState;
        expect(state, isA<Disconnected>().having((it) => it.source, 'source', isA<ServerInitiated>()));
        expect(state.isAutomaticReconnectionEnabled, isTrue);
      });
    });

    test('does not replace the source of a disconnect that came first', () {
      fakeAsync((async) {
        final tester = buildTester();
        tester.server.onFrame = (_) => [];

        tester.client.connect().ignore();
        async.flushMicrotasks();
        tester.client.disconnect().ignore();
        async.flushMicrotasks();

        async.elapse(WebSocketOptions.defaultConnectTimeout * 2);

        // The timeout would otherwise report this deliberate disconnect as a timed-out attempt,
        // which is retried where this is not.
        expect(
          tester.connectionState,
          isA<Disconnected>().having((it) => it.source, 'source', isA<UserInitiated>()),
        );
      });
    });

    test('releases the timeout of an attempt in flight when disposed', () {
      fakeAsync((async) {
        final tester = buildTester(handshakeHangs: true);

        tester.client.connect().ignore();
        async.flushMicrotasks();
        tester.client.dispose().ignore();
        async.flushMicrotasks();

        // A timeout left armed keeps a disposed client alive for as long as it has left to run.
        expect(async.pendingTimers, isEmpty);
      });
    });

    group('when a health check arrives while disconnecting', () {
      wsClientTest(
        'does not report the connection as established again',
        holdClose: true,
        body: (tester) async {
          tester.client.disconnect().ignore();
          expect(tester.connectionState, isA<Disconnecting>());

          // Arrives before the socket finished closing.
          await tester.emit({'type': 'connection.ok', 'connection_id': 'late'});

          expect(tester.connectionState, isA<Disconnecting>());
          tester.server.socket.sink.completeClose();
        },
      );

      wsClientTest(
        'ignores one that arrives before the credentials have gone out',
        handshakeHangs: true,
        connect: (tester) async {
          tester.client.connect().ignore();
          await tester.pumpEventQueue();
        },
        body: (tester) {
          // The engine subscribes before the handshake completes, so a frame can reach the client
          // while it is still connecting. Acted on, it would report a connection established that
          // has never presented credentials.
          expect(tester.connectionState, isA<Connecting>());

          tester.client.onMessage(const HealthCheck(connectionId: 'early'));

          expect(tester.connectionState, isA<Connecting>());
        },
      );

      wsClientTest(
        'ignores one the engine delivers after the state has moved on',
        holdClose: true,
        body: (tester) {
          tester.client.disconnect().ignore();
          expect(tester.connectionState, isA<Disconnecting>());

          // Delivered straight to the listener, as the engine does for a frame already in its queue
          // when the state flipped. Closing cancels the subscription, so a frame sent through the
          // socket is dropped before it gets here and cannot reach this guard.
          tester.client.onMessage(const HealthCheck(connectionId: 'late'));

          expect(tester.connectionState, isA<Disconnecting>());
          tester.server.socket.sink.completeClose();
        },
      );

      wsClientTest(
        'leaves the disconnection source intact once the socket closes',
        holdClose: true,
        body: (tester) async {
          tester.client.disconnect().ignore();
          await tester.emit({'type': 'connection.ok', 'connection_id': 'late'});

          tester.server.socket.sink.completeClose();
          await tester.pumpEventQueue();

          // A late health check must not move the state back to connected: the closure would then be
          // reported as server-initiated, which is eligible for a reconnect.
          final state = tester.connectionState;
          expect(state, isA<Disconnected>().having((it) => it.source, 'source', isA<UserInitiated>()));
          expect(state.isAutomaticReconnectionEnabled, isFalse);
        },
      );
    });
  });

  // The client, its authentication handler, its health monitor and its recovery handler all take
  // part, so these cover the loop rather than any one of them: the server refuses, the refusal
  // reaches the next attempt, that attempt presents something else, and the connection comes back
  // without the app being told anything.
  group('the token behind the connection', () {
    // The handshake a consuming SDK performs, which acts on `previousError`: an expired token is
    // dropped so the provider can issue another, and a provider with nothing else to give declines
    // rather than presenting the same token again.
    WebSocketAuthenticator authenticatorFor(TokenManager tokens) {
      return (send, previousError) async {
        if (previousError?.isTokenExpiredError ?? false) {
          tokens.expireToken();
          if (tokens.usesStaticProvider) {
            throw ClientException(message: 'The token was refused and the provider has no other to give');
          }
        }

        final token = await tokens.getToken();
        send(WsAuthMessageRequest(token: token.rawValue)).getOrThrow();
      };
    }

    test('is still answered for by the attempt after it, when the user has not changed', () {
      fakeAsync((async) {
        final asked = <StreamApiError?>[];
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
        expect(asked, [null, isA<StreamApiError>().having((it) => it.code, 'code', 40)]);
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
