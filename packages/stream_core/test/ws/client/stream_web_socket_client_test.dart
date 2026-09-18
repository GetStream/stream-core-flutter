import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

import '../../helpers/fake_server.dart';
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
        // Reported with its cause, so the closure stays reconnectable. Closed without one it would
        // read as the deliberate close the engine defaults to, which never is.
        expect(
          tester.connectionState,
          isA<Disconnected>().having(
            (it) => it.source,
            'source',
            isA<ServerInitiated>().having((it) => it.error, 'error', isA<StreamNetworkException>()),
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

  group('send', () {
    wsClientTest(
      'throws when nothing has connected yet, which is an order to fix rather than a failure',
      connect: (_) {}, // never connected
      body: (tester) {
        // Reported where the caller wrote it: no retry, and no reconnection,
        // makes a send that came before the connection work.
        expect(
          () => tester.client.send(const HealthCheckPingEvent(connectionId: 'connection-id')),
          throwsStateError,
        );
      },
    );

    wsClientTest(
      'fails as a network problem when a connection that was established has dropped',
      body: (tester) async {
        await tester.client.disconnect();

        // A drop can race any send, so a correct caller can hit this: it
        // reads as the moment's failure, classified like every other one.
        final result = tester.client.send(const HealthCheckPingEvent(connectionId: 'connection-id'));

        expect(
          result.exceptionOrNull(),
          isA<StreamNetworkException>().having((it) => it.cause, 'cause', isA<StateError>()),
        );
      },
    );
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
      'opens a socket without waiting for the previous one to finish closing',
      holdClose: true,
      body: (tester) async {
        final closing = tester.server.socket;

        await tester.client.disconnect();
        expect(tester.connectionState, isA<Disconnected>());

        await tester.client.connect();
        await tester.pumpEventQueue();
        expect(tester.attempts, 2);
        expect(tester.connectionState, isA<Connected>());

        // The socket that was replaced, finishing on its own schedule. Its closure belongs to a
        // connection already reported as closed, so it must not bring down the one that replaced it.
        closing.sink.completeClose();
        await tester.pumpEventQueue();

        expect(tester.connectionState, isA<Connected>());
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
}
