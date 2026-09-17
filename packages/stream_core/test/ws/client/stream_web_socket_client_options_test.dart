import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

import '../../helpers/fake_server.dart';
import '../../helpers/ws_client_tester.dart';

void main() {
  group('the options behind the attempt', () {
    test('takes them from the deprecated builder when that is what the caller gave', () async {
      // The builder cannot be handed the refusal, so a caller left on it never replaces a token the
      // server turned down — which is what the deprecation says.
      final tester = buildTester(
        optionsBuilder: () => const WebSocketOptions(url: 'wss://example.com'),
      );
      addTearDown(tester.dispose);

      await tester.client.connect();
      await tester.pumpEventQueue();

      expect(tester.connectionState, isA<Connected>());
    });

    // Completed by a test body to release a builder it deliberately left hanging.
    late Completer<WebSocketOptions> optionsAfter;
    setUp(() => optionsAfter = Completer<WebSocketOptions>());

    wsClientTest(
      'waits for options the caller builds asynchronously',
      optionsProvider: (_) async {
        // An app loading a credential the connection URL carries.
        await Future<void>.delayed(const Duration(milliseconds: 1));
        return const WebSocketOptions(url: 'wss://example.com');
      },
      body: (tester) {
        // `wsClientTest` asserts the connection was established before this runs, which it could
        // not be if the attempt went ahead without waiting.
        expect(tester.attempts, 1);
      },
    );

    wsClientTest(
      'reports a builder that throws as an authentication failure',
      optionsProvider: (_) => throw const StreamAuthenticationException(message: 'no token'),
      connect: (_) {},
      body: (tester) async {
        await tester.client.connect();
        await tester.pumpEventQueue();

        expect(
          tester.connectionState,
          isA<Disconnected>().having(
            (it) => it.source,
            'source',
            isA<AuthenticationFailed>().having(
              (it) => it.error,
              'error',
              isA<StreamAuthenticationException>().having((it) => it.message, 'message', 'no token'),
            ),
          ),
        );

        // Credentials that could not be produced will not fare better on a retry.
        expect(tester.connectionState.isAutomaticReconnectionEnabled, isFalse);
      },
    );

    wsClientTest(
      'retries a builder that failed on the network rather than on the credentials',
      optionsProvider: (_) => throw const StreamNetworkException(message: 'the token request failed'),
      connect: (_) {},
      body: (tester) async {
        await tester.client.connect();
        await tester.pumpEventQueue();

        // The moment was at fault, not the credentials, so the attempt is worth making again.
        // Eligibility only: a first attempt is still not recovered, because nothing was ever
        // established for `ConnectionRecoveryHandler` to recover.
        expect(tester.connectionState.isAutomaticReconnectionEnabled, isTrue);
      },
    );

    test('tells an attempt what the server refused the one before it with', () {
      fakeAsync((async) {
        final tester = buildTester(recover: true);

        tester.client.connect().ignore();
        async.flushMicrotasks();

        // Nothing was refused before the first attempt, so it is told nothing.
        expect(tester.refusals, [null]);

        // The server refuses an expired token and hangs up, which is reconnected.
        tester.server.send(expiredTokenFrame());
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 1));

        // The options for the attempt that follows carry the refusal, which is the only place an
        // SDK authenticating in its request can act on one.
        expect(
          tester.refusals.last,
          isA<StreamApiException>().having((it) => it.isTokenExpired, 'isTokenExpired', isTrue),
        );
      });
    });

    test('tells an attempt nothing once a connection has been established', () {
      fakeAsync((async) {
        final tester = buildTester(recover: true);

        tester.client.connect().ignore();
        async.flushMicrotasks();

        tester.server.send(expiredTokenFrame());
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 1));
        expect(tester.refusals.last, isNotNull);

        // Established, so the refusal before it no longer describes anything. A drop after this
        // starts an attempt that is told nothing.
        expect(tester.connectionState, isA<Connected>());
        tester.server.socket.endStream();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 1));

        expect(tester.refusals.last, isNull);
      });
    });

    test('abandons an attempt whose options never arrive', () {
      fakeAsync((async) {
        // A builder awaiting a credential that never loads. Nothing else watches 'connecting',
        // so only the connect timeout can end this.
        final tester = buildTester(
          optionsProvider: (_) => Completer<WebSocketOptions>().future,
        );

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

    wsClientTest(
      'opens nothing for an attempt the caller abandoned while the options were being built',
      optionsProvider: (_) => optionsAfter.future,
      connect: (_) {},
      body: (tester) async {
        tester.client.connect().ignore();
        await tester.pumpEventQueue();

        await tester.client.disconnect();
        expect(tester.connectionState, isA<Disconnected>().having((it) => it.source, 'source', isA<UserInitiated>()));

        // The builder answers for an attempt nobody is making any more. Acted on, it opens a socket
        // the client reports nothing about and nothing is left holding to close.
        optionsAfter.complete(const WebSocketOptions(url: 'wss://example.com'));
        await tester.pumpEventQueue();

        expect(tester.server.sockets, isEmpty);
        expect(tester.connectionState, isA<Disconnected>().having((it) => it.source, 'source', isA<UserInitiated>()));
      },
    );

    test('bounds the options it is waiting for separately from the connection they describe', () {
      fakeAsync((async) {
        // A builder that never returns, for options that would have named a longer timeout than
        // the default. That timeout is not knowable until the builder returns, so it cannot be
        // what bounds the wait — and a connection nobody is still trying to make must not outlive
        // the default either.
        final tester = buildTester(
          connectTimeout: const Duration(minutes: 5),
          optionsProvider: (_) => Completer<WebSocketOptions>().future,
        );

        tester.client.connect().ignore();
        async.flushMicrotasks();

        async.elapse(WebSocketOptions.defaultConnectTimeout - const Duration(seconds: 1));
        expect(tester.connectionState, isA<Connecting>());

        async.elapse(const Duration(seconds: 1));
        expect(
          tester.connectionState,
          isA<Disconnected>().having((it) => it.source, 'source', isA<ConnectTimeout>()),
        );
      });
    });

    test('spends the whole timeout the options name on the connection they describe', () {
      fakeAsync((async) {
        // A builder that takes its time, then options naming a short timeout. Reusing one budget
        // for both would leave the connection less than the timeout it asked for.
        final tester = buildTester(
          optionsProvider: (_) => Future.delayed(
            const Duration(seconds: 20),
            () => const WebSocketOptions(url: 'wss://example.com', connectTimeout: Duration(seconds: 20)),
          ),
          handshakeHangs: true,
        );

        tester.client.connect().ignore();
        async.elapse(const Duration(seconds: 20));
        async.flushMicrotasks();
        expect(tester.connectionState, isA<Connecting>());

        // 19 of the connection's own 20 seconds have gone by; it is still being given them.
        async.elapse(const Duration(seconds: 19));
        expect(tester.connectionState, isA<Connecting>());

        async.elapse(const Duration(seconds: 1));
        expect(
          tester.connectionState,
          isA<Disconnected>().having((it) => it.source, 'source', isA<ConnectTimeout>()),
        );
      });
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
}
