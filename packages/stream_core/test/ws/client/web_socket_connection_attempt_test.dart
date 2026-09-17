import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:stream_core/src/ws/client/web_socket_connection_attempt.dart';
import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

// Deliberately not a round number, so a bound reached early or late is visible.
const _bound = Duration(seconds: 7);

const _healthCheck = HealthCheckInfo(connectionId: 'connection-id');

/// The states a connection passes through before it starts closing.
const _beforeClosing = <WebSocketConnectionState>[
  Initialized(),
  Connecting(),
  Authenticating(),
  Connected(healthCheck: _healthCheck),
];

/// The states a connection passes through once it starts closing.
const _whileClosing = <WebSocketConnectionState>[
  Disconnecting(source: UserInitiated()),
  Disconnected(source: UserInitiated()),
];

/// Builds an attempt, along with how many times its bound has been reached.
({WebSocketConnectionAttempt attempt, int Function() timeouts}) _subject() {
  var timeouts = 0;
  return (attempt: WebSocketConnectionAttempt(onTimeout: () => timeouts++), timeouts: () => timeouts);
}

void main() {
  test('is the attempt in flight until it is ended', () {
    final (:attempt, timeouts: _) = _subject();

    expect(attempt.hasEnded, isFalse);
    attempt.end();
    expect(attempt.hasEnded, isTrue);
  });

  test('can be ended more than once', () {
    final (:attempt, timeouts: _) = _subject();

    // A disconnect ends the attempt and then reports `Disconnecting`, which ends it again.
    attempt.end();
    expect(attempt.end, returnsNormally);
  });

  group('valueUnlessEnded', () {
    test('gives back what the operation completed with, while the attempt is in flight', () {
      final (:attempt, timeouts: _) = _subject();

      expect(attempt.valueUnlessEnded(Future.value('options')), completion('options'));
    });

    test('gives back nothing for an operation that outlives the attempt', () {
      final (:attempt, timeouts: _) = _subject();

      // Never completes, so this can only settle through the attempt ending.
      final value = attempt.valueUnlessEnded(Completer<String>().future);
      attempt.end();

      expect(value, completion(isNull));
    });

    test('gives back nothing for an attempt that had already ended', () {
      final (:attempt, timeouts: _) = _subject();
      attempt.end();

      expect(attempt.valueUnlessEnded(Completer<String>().future), completion(isNull));
    });

    test('leaves an operation that beat the end alone', () {
      final (:attempt, timeouts: _) = _subject();

      final value = attempt.valueUnlessEnded(Future.value('options'));
      scheduleMicrotask(attempt.end);

      expect(value, completion('options'));
    });
  });

  group('boundBy', () {
    test('reaches its bound when the attempt does not become usable in time', () {
      fakeAsync((async) {
        final (:attempt, :timeouts) = _subject();
        attempt.boundBy(_bound);

        async.elapse(_bound - const Duration(milliseconds: 1));
        expect(timeouts(), 0);

        async.elapse(const Duration(milliseconds: 1));
        expect(timeouts(), 1);
      });
    });

    test('does not end the attempt when the bound is reached', () {
      fakeAsync((async) {
        final (:attempt, timeouts: _) = _subject();
        attempt.boundBy(_bound);
        async.elapse(_bound);

        // What a bound does is report; ending is the client's answer to it.
        expect(attempt.hasEnded, isFalse);
      });
    });

    test('drops the bound it had when given another', () {
      fakeAsync((async) {
        final (:attempt, :timeouts) = _subject();
        attempt
          ..boundBy(_bound)
          ..boundBy(_bound * 2);

        async.elapse(_bound);
        expect(timeouts(), 0, reason: 'the replaced bound should not fire');

        async.elapse(_bound);
        expect(timeouts(), 1);
      });
    });
  });

  group('stopBounding', () {
    test('leaves the attempt in flight with no deadline', () {
      fakeAsync((async) {
        final (:attempt, :timeouts) = _subject();
        attempt
          ..boundBy(_bound)
          ..stopBounding();

        async.elapse(_bound * 2);
        expect(timeouts(), 0);
        expect(attempt.hasEnded, isFalse);
      });
    });

    test('leaves the attempt able to be bounded again', () {
      fakeAsync((async) {
        final (:attempt, :timeouts) = _subject();
        attempt
          ..boundBy(_bound)
          ..stopBounding()
          ..boundBy(_bound);

        async.elapse(_bound);
        expect(timeouts(), 1);
      });
    });
  });

  test('gives up the bound it had when it ends', () {
    fakeAsync((async) {
      final (:attempt, :timeouts) = _subject();
      attempt
        ..boundBy(_bound)
        ..end();

      async.elapse(_bound * 2);
      expect(timeouts(), 0);
    });
  });

  group('onConnectionStateChanged', () {
    for (final state in _whileClosing) {
      test('ends the attempt on $state', () {
        final (:attempt, timeouts: _) = _subject();
        attempt.onConnectionStateChanged(state);

        expect(attempt.hasEnded, isTrue);
      });
    }

    for (final state in _beforeClosing) {
      test('leaves the attempt in flight on $state', () {
        final (:attempt, timeouts: _) = _subject();
        attempt.onConnectionStateChanged(state);

        expect(attempt.hasEnded, isFalse);
      });
    }
  });
}
