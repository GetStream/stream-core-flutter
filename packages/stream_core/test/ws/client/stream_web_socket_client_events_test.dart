import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

import '../../helpers/fake_server.dart';
import '../../helpers/ws_client_tester.dart';

void main() {
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
        'reports the closure as the system, not the server, ending it',
        connect: (tester) async {
          await tester.client.connect();
          await tester.pumpEventQueue();
        },
        body: (tester) async {
          // Not a `connection.error` over a working socket: the socket is what failed, which is
          // this side of the connection — the server was never reached to end anything.
          tester.server.fail(StateError('socket died'));
          await tester.pumpEventQueue();

          expect(
            tester.connectionState,
            isA<Disconnected>().having(
              (it) => it.source,
              'source',
              isA<SystemInitiated>().having(
                (it) => it.error,
                'error',
                isA<StreamNetworkException>().having((it) => it.cause, 'cause', isStateError),
              ),
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

  group('the health check interval', () {
    test('pings on the interval the client was given', () {
      fakeAsync((async) {
        var pings = 0;
        final tester = buildTester(
          pingInterval: const Duration(seconds: 5),
          pongTimeout: const Duration(seconds: 1),
        );

        tester.server.onFrame = (frame) {
          if (frame['type'] == 'health.check') pings++;
          return [
            {'type': 'health.check', 'connection_id': 'connection-id'},
          ];
        };

        tester.client.connect().ignore();
        async.flushMicrotasks();
        expect(tester.connectionState, isA<Connected>());

        async.elapse(const Duration(seconds: 12));

        // Two intervals elapsed, and the connection is still answered for.
        expect(pings, 2);
        expect(tester.connectionState, isA<Connected>());
      });
    });

    test('gives up on a connection that misses the pong timeout it was given', () {
      fakeAsync((async) {
        final tester = buildTester(
          pingInterval: const Duration(seconds: 5),
          pongTimeout: const Duration(seconds: 1),
        );

        tester.client.connect().ignore();
        async.flushMicrotasks();

        // A server that stops answering pings once the connection is up.
        tester.server.onFrame = (_) => const [];

        // One ping goes out at 5s, and its pong is due a second later.
        async.elapse(const Duration(seconds: 7));

        expect(
          tester.connectionState,
          isA<Disconnected>().having((it) => it.source, 'source', isA<UnHealthyConnection>()),
        );
      });
    });
  });
}
