import 'package:fake_async/fake_async.dart';
import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

/// Records what the monitor asked of the connection it is watching.
class _Listener implements WebSocketHealthListener {
  var _pings = 0;
  var _unhealthy = 0;

  /// How many times the monitor asked for a ping to be sent.
  int get pings => _pings;

  /// How many times it reported the connection unhealthy.
  int get unhealthy => _unhealthy;

  @override
  void onPingRequested() => _pings++;

  @override
  void onUnhealthy() => _unhealthy++;
}

// Deliberately not the defaults, so these also pin that the monitor uses what it was given.
const _pingInterval = Duration(seconds: 10);
const _timeout = Duration(seconds: 2);

({WebSocketHealthMonitor monitor, _Listener listener}) _subject() {
  final listener = _Listener();
  return (
    monitor: WebSocketHealthMonitor(
      listener: listener,
      pingInterval: _pingInterval,
      timeoutThreshold: _timeout,
    ),
    listener: listener,
  );
}

void main() {
  test('asks for nothing until it is started', () {
    fakeAsync((async) {
      final (monitor: _, :listener) = _subject();

      async.elapse(_pingInterval * 5);

      expect(listener.pings, 0);
      expect(listener.unhealthy, 0);
    });
  });

  test('waits out the interval before the first ping', () {
    fakeAsync((async) {
      final (:monitor, :listener) = _subject();
      monitor.start();

      // A connection that has just answered does not need asking again straight away.
      async.elapse(_pingInterval - const Duration(seconds: 1));
      expect(listener.pings, 0);

      async.elapse(const Duration(seconds: 1));
      expect(listener.pings, 1);

      monitor.stop();
    });
  });

  test('keeps asking for as long as the answers keep coming', () {
    fakeAsync((async) {
      final (:monitor, :listener) = _subject();
      monitor.start();

      for (var i = 0; i < 4; i++) {
        async.elapse(_pingInterval);
        monitor.onPongReceived();
      }

      expect(listener.pings, 4);
      expect(listener.unhealthy, 0);

      monitor.stop();
    });
  });

  test('reports the connection unhealthy when an answer does not arrive', () {
    fakeAsync((async) {
      final (:monitor, :listener) = _subject();
      monitor.start();

      async.elapse(_pingInterval);
      expect(listener.pings, 1);
      expect(listener.unhealthy, 0);

      // Still inside the window the peer has to answer in.
      async.elapse(_timeout - const Duration(seconds: 1));
      expect(listener.unhealthy, 0);

      async.elapse(const Duration(seconds: 1));
      expect(listener.unhealthy, 1);

      monitor.stop();
    });
  });

  test('holds off on the verdict while answers arrive in time', () {
    fakeAsync((async) {
      final (:monitor, :listener) = _subject();
      monitor.start();

      // An answer that lands just inside the window, as a slow connection gives.
      async.elapse(_pingInterval);
      async.elapse(_timeout - const Duration(milliseconds: 1));
      monitor.onPongReceived();

      async.elapse(const Duration(seconds: 1));
      expect(listener.unhealthy, 0);

      monitor.stop();
    });
  });

  test('asks for nothing once it is stopped', () {
    fakeAsync((async) {
      final (:monitor, :listener) = _subject();
      monitor.start();
      async.elapse(_pingInterval);

      monitor.stop();
      async.elapse(_pingInterval * 5);

      // The one ping from before it stopped, and nothing after.
      expect(listener.pings, 1);
      expect(async.pendingTimers, isEmpty);
    });
  });

  test('does not deliver a verdict it had already reached when stopped', () {
    fakeAsync((async) {
      final (:monitor, :listener) = _subject();
      monitor.start();

      // A ping went unanswered, so the verdict is pending.
      async.elapse(_pingInterval);
      monitor.stop();

      async.elapse(_timeout * 2);

      // Reported after the connection was closed, this would reopen one nobody asked for.
      expect(listener.unhealthy, 0);
    });
  });

  group('following the connection state', () {
    test('starts watching once a connection is established', () {
      fakeAsync((async) {
        final (:monitor, :listener) = _subject();

        monitor.onConnectionStateChanged(
          const Connected(healthCheck: HealthCheckInfo(connectionId: 'connection-id')),
        );
        async.elapse(_pingInterval);

        expect(listener.pings, 1);

        monitor.stop();
      });
    });

    test('stops watching once it is not', () {
      fakeAsync((async) {
        final (:monitor, :listener) = _subject();
        monitor.onConnectionStateChanged(
          const Connected(healthCheck: HealthCheckInfo(connectionId: 'connection-id')),
        );

        monitor.onConnectionStateChanged(const Disconnected(source: UserInitiated()));
        async.elapse(_pingInterval * 3);

        expect(listener.pings, 0);
        expect(async.pendingTimers, isEmpty);
      });
    });

    test('watches nothing while a connection is still being made', () {
      fakeAsync((async) {
        final (:monitor, :listener) = _subject();

        // The connect timeout is what bounds an attempt; pinging a socket that has not been
        // accepted yet would report it unhealthy before it ever had a chance.
        monitor.onConnectionStateChanged(const Connecting());
        monitor.onConnectionStateChanged(const Authenticating());
        async.elapse(_pingInterval * 2);

        expect(listener.pings, 0);
      });
    });

    test('keeps a fixed cadence when an answer arrives mid-interval', () {
      fakeAsync((async) {
        final (:monitor, :listener) = _subject();
        monitor.onConnectionStateChanged(
          const Connected(healthCheck: HealthCheckInfo(connectionId: 'connection-id')),
        );

        async.elapse(_pingInterval * 0.6);
        expect(listener.pings, 0);

        // Every answer arrives as another `Connected`, which asks the monitor to start again.
        monitor.onPongReceived();
        monitor.onConnectionStateChanged(
          const Connected(healthCheck: HealthCheckInfo(connectionId: 'answered')),
        );

        async.elapse(_pingInterval * 0.5);

        // Starting again would reschedule the ping, so each answer would push the next one a full
        // interval away and a connection answering steadily would be asked less and less often.
        expect(listener.pings, 1);
        expect(listener.unhealthy, 0);

        monitor.stop();
      });
    });
  });
}
