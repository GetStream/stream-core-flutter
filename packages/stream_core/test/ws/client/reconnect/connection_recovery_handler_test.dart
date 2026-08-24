import 'package:fake_async/fake_async.dart';
import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

import '../../../helpers/ws_client_tester.dart';

/// Long enough for a health check to go unanswered, which is the drop this handler recovers from.
///
/// The monitor pings every 25 seconds and gives the peer 3 to answer.
const _untilUnhealthy = Duration(seconds: 29);

void main() {
  test('does not retry a first attempt that never connected', () {
    fakeAsync((async) {
      final tester = buildTester(recover: true);
      // A server that takes the credentials and never answers, so the attempt is abandoned.
      tester.server.onFrame = (_) => [];

      tester.client.connect().ignore();
      async.flushMicrotasks();

      async.elapse(WebSocketOptions.defaultConnectTimeout);
      async.flushMicrotasks();
      expect(tester.connectionState, isA<Disconnected>());

      // Retrying here would work behind a caller already told it failed.
      async.elapse(const Duration(minutes: 1));
      expect(tester.attempts, 1);
    });
  });

  test('retries a connection that dropped after being established', () {
    fakeAsync((async) {
      final tester = buildTester(recover: true);

      tester.client.connect().ignore();
      async.flushMicrotasks();
      expect(tester.connectionState, isA<Connected>());

      // The server stops answering health checks, which is a drop rather than a failed attempt, so
      // recovering it is this handler's job. The first retry carries no delay.
      tester.server.onFrame = (_) => [];
      async.elapse(_untilUnhealthy);
      async.flushMicrotasks();

      expect(tester.attempts, 2);
      expect(tester.states.whereType<Connecting>(), hasLength(2));
    });
  });

  test('hands connecting back after the caller disconnected', () {
    fakeAsync((async) {
      final tester = buildTester(recover: true);

      tester.client.connect().ignore();
      async.flushMicrotasks();
      tester.client.disconnect().ignore();
      async.flushMicrotasks();

      // A fresh attempt, awaited by whoever made it, that never connects.
      tester.server.onFrame = (_) => [];
      tester.client.connect().ignore();
      async.flushMicrotasks();
      async.elapse(WebSocketOptions.defaultConnectTimeout);
      async.flushMicrotasks();

      // Having connected in a previous session does not make this failure the handler's to retry.
      async.elapse(const Duration(minutes: 1));
      expect(tester.attempts, 2);
    });
  });

  test('stops a retry the caller called off while it was pending', () {
    fakeAsync((async) {
      final tester = buildTester(recover: true);

      tester.client.connect().ignore();
      async.flushMicrotasks();

      // A closure worth retrying, so one is scheduled.
      tester.server.hangUp();
      async.flushMicrotasks();

      // The caller says stop while that retry is still pending. Asking to disconnect a connection
      // that is already down is asking for whatever is pending on its behalf to stop too.
      tester.client.disconnect().ignore();
      async.flushMicrotasks();

      async.elapse(const Duration(minutes: 1));

      expect(tester.attempts, 1);
    });
  });

  test('cancels a retry it had already scheduled when the caller disconnects', () {
    fakeAsync((async) {
      final tester = buildTester(recover: true);

      tester.client.connect().ignore();
      async.flushMicrotasks();
      expect(tester.connectionState, isA<Connected>());

      // The server hangs up, which schedules a retry.
      tester.server.hangUp();
      async.flushMicrotasks();
      expect(async.pendingTimers, isNotEmpty);

      tester.client.disconnect().ignore();
      async.flushMicrotasks();

      // Nothing is left armed. A timer that outlives the caller's disconnect fires against a client
      // they have closed, and reconnects it behind them.
      expect(async.pendingTimers, isEmpty);
    });
  });

  test('does not retry a disconnect the caller asked for', () {
    fakeAsync((async) {
      final tester = buildTester(recover: true);

      tester.client.connect().ignore();
      async.flushMicrotasks();

      tester.client.disconnect().ignore();
      async.flushMicrotasks();
      expect(tester.connectionState, isA<Disconnected>());

      // Having been connected is not enough on its own: the source says this was deliberate.
      async.elapse(const Duration(minutes: 1));
      expect(tester.attempts, 1);
    });
  });

  group('while the network is down', () {
    test('does not retry a drop', () {
      fakeAsync((async) {
        final tester = buildTester(recover: true);

        tester.client.connect().ignore();
        async.flushMicrotasks();

        tester.network.disconnect();
        async.flushMicrotasks();

        // Losing the network takes the connection down, and there is nothing to reconnect to.
        async.elapse(const Duration(minutes: 1));
        expect(tester.attempts, 1);
      });
    });

    test('retries as soon as it comes back', () {
      fakeAsync((async) {
        final tester = buildTester(recover: true);

        tester.client.connect().ignore();
        async.flushMicrotasks();

        tester.network.disconnect();
        async.flushMicrotasks();
        expect(tester.connectionState, isA<Disconnected>());

        tester.network.connect();
        async.flushMicrotasks();

        // The network returning is the triggering event, so nothing waits out a backoff for it.
        expect(tester.attempts, 2);
        expect(tester.connectionState, isA<Connected>());
      });
    });
  });

  group('while the app is in the background', () {
    test('takes the connection down and leaves it down', () {
      fakeAsync((async) {
        final tester = buildTester(recover: true);

        tester.client.connect().ignore();
        async.flushMicrotasks();

        tester.lifecycle.background();
        async.flushMicrotasks();

        // A connection nobody is looking at costs battery for nothing.
        expect(tester.connectionState, isA<Disconnected>());

        async.elapse(const Duration(minutes: 1));
        expect(tester.attempts, 1);
      });
    });

    test('reconnects when the app is opened again', () {
      fakeAsync((async) {
        final tester = buildTester(recover: true);

        tester.client.connect().ignore();
        async.flushMicrotasks();

        tester.lifecycle.background();
        async.flushMicrotasks();

        tester.lifecycle.foreground();
        async.flushMicrotasks();

        expect(tester.attempts, 2);
        expect(tester.connectionState, isA<Connected>());
      });
    });
  });

  group('a policy the app supplied', () {
    test('can refuse a reconnection the built-in policies would allow', () {
      fakeAsync((async) {
        // No handler of its own, so this test owns the one it is testing.
        final tester = buildTester();
        ConnectionRecoveryHandler(
          client: tester.client,
          policies: [const _Refuses()],
        );

        tester.client.connect().ignore();
        async.flushMicrotasks();
        expect(tester.connectionState, isA<Connected>());

        // A drop that would otherwise be recovered from.
        tester.server.hangUp();
        async.flushMicrotasks();
        async.elapse(const Duration(minutes: 1));

        // Policies are combined with `and`, so an app can veto a reconnection the client is
        // otherwise happy to make.
        expect(tester.attempts, 1);
      });
    });

    test('is consulted alongside them rather than replacing them', () {
      fakeAsync((async) {
        final tester = buildTester();
        ConnectionRecoveryHandler(
          client: tester.client,
          policies: [const _Allows()],
        );

        tester.client.connect().ignore();
        async.flushMicrotasks();

        // A disconnect the caller asked for, which a built-in policy refuses. An app policy that
        // allows must not override that.
        tester.client.disconnect().ignore();
        async.flushMicrotasks();
        async.elapse(const Duration(minutes: 1));

        expect(tester.attempts, 1);
      });
    });
  });
}

/// An app policy that never wants a reconnection.
class _Refuses implements AutomaticReconnectionPolicy {
  const _Refuses();

  @override
  bool canBeReconnected() => false;
}

/// An app policy that always wants one.
class _Allows implements AutomaticReconnectionPolicy {
  const _Allows();

  @override
  bool canBeReconnected() => true;
}
