import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

void main() {
  test('retries the first time without waiting', () {
    final strategy = RetryStrategy();

    // A connection that has just dropped is most likely to come straight back, and a delay here is
    // felt by whoever is looking at the screen.
    expect(strategy.getNextRetryDelay(), Duration.zero);
  });

  test('waits longer the more attempts have failed', () {
    final strategy = RetryStrategy();

    final delays = <Duration>[];
    for (var i = 0; i < 6; i++) {
      delays.add(strategy.getDelayAfterTheFailure());
    }

    // Not strictly increasing, because each delay is drawn from a range, but the ranges climb: a
    // server that is struggling is asked less and less often.
    expect(delays.first, Duration.zero);
    expect(delays.last, greaterThan(delays[1]));
    expect(delays, everyElement(lessThanOrEqualTo(const Duration(seconds: 25))));
  });

  test('never waits longer than the ceiling', () {
    final strategy = RetryStrategy();

    for (var i = 0; i < 100; i++) {
      strategy.incrementConsecutiveFailures();
    }

    // Without a ceiling a long outage would push the next attempt hours away, and the connection
    // would not come back for a user who is waiting on it.
    expect(
      strategy.getNextRetryDelay(),
      lessThanOrEqualTo(const Duration(seconds: DefaultRetryStrategy.maximumReconnectionDelayInSeconds)),
    );
  });

  test('spreads the delay across a range, so clients do not retry in lockstep', () {
    // Every client that dropped when a server went down would otherwise come back at the same
    // instant and take it down again.
    final delays = <Duration>{};
    for (var i = 0; i < 200; i++) {
      final strategy = RetryStrategy();
      for (var f = 0; f < 5; f++) {
        strategy.incrementConsecutiveFailures();
      }
      delays.add(strategy.getNextRetryDelay());
    }

    expect(delays, hasLength(greaterThan(1)));
  });

  test('counts the failures it has seen', () {
    final strategy = RetryStrategy();
    expect(strategy.consecutiveFailuresCount, 0);

    strategy.getDelayAfterTheFailure();
    strategy.getDelayAfterTheFailure();

    expect(strategy.consecutiveFailuresCount, 2);
  });

  test('starts over once a connection is established', () {
    final strategy = RetryStrategy();
    for (var i = 0; i < 5; i++) {
      strategy.getDelayAfterTheFailure();
    }

    strategy.resetConsecutiveFailures();

    // The backoff a previous outage built up does not apply to the next one, which starts with the
    // immediate retry a fresh drop deserves.
    expect(strategy.consecutiveFailuresCount, 0);
    expect(strategy.getNextRetryDelay(), Duration.zero);
  });
}
