import 'dart:math' as math;

/// Interface that encapsulates the logic for computing delays for failed actions that need to be
/// retried.
///
/// This strategy manages the retry delay calculation with exponential backoff and jitter to avoid
/// overwhelming the backend service with simultaneous retry attempts from multiple clients.
abstract interface class RetryStrategy {
  /// Creates a [RetryStrategy] instance.
  factory RetryStrategy() = DefaultRetryStrategy;

  /// The number of consecutively failed retries.
  int get consecutiveFailuresCount;

  /// Increments the number of consecutively failed retries, making the next
  /// delay longer.
  ///
  /// This method should be called each time a retry attempt fails in order to
  /// gradually increase the delay between subsequent attempts.
  void incrementConsecutiveFailures();

  /// Resets the number of consecutively failed retries, making the next delay
  /// be the shortest one.
  ///
  /// This method should be called when a retry attempt succeeds in order to
  /// reset the backoff strategy for future retry attempts.
  void resetConsecutiveFailures();

  /// Calculates and returns the delay for the next retry.
  ///
  /// Consecutive calls after the same number of failures may return different
  /// delays due to randomization (jitter). This randomization helps avoid
  /// overwhelming the backend by preventing all clients from retrying at
  /// exactly the same time.
  ///
  /// Returns the delay for the next retry.
  Duration getNextRetryDelay();
}

/// Extension methods for the [RetryStrategy] interface.
extension RetryStrategyExtensions on RetryStrategy {
  /// Returns the delay for the next retry and then increments the number of
  /// consecutively failed retries.
  ///
  /// This method combines the functionality of getting the next retry delay
  /// and incrementing the failure count, making it convenient to use after a
  /// failed retry attempt.
  ///
  /// Returns the delay for the next retry.
  Duration getDelayAfterTheFailure() {
    final delay = getNextRetryDelay();
    incrementConsecutiveFailures();
    return delay;
  }
}

/// Default implementation of [RetryStrategy] that uses exponential backoff
/// with jitter.
///
/// The delay increases with each consecutive failure, up to a maximum limit
/// of [maximumReconnectionDelayInSeconds] seconds. The delay is randomized
/// within a range to prevent synchronized retries from multiple clients.
class DefaultRetryStrategy implements RetryStrategy {
  /// Maximum delay between reconnection attempts.
  static const maximumReconnectionDelayInSeconds = 25;

  @override
  int consecutiveFailuresCount = 0;

  @override
  void incrementConsecutiveFailures() => consecutiveFailuresCount++;

  @override
  void resetConsecutiveFailures() => consecutiveFailuresCount = 0;

  @override
  Duration getNextRetryDelay() {
    // The first time we get to retry, we do it without any delay.
    // Any subsequent time will be delayed by a random interval.
    if (consecutiveFailuresCount <= 0) return Duration.zero;

    final maxDelay = math.min(
      0.5 + consecutiveFailuresCount * 2,
      maximumReconnectionDelayInSeconds,
    );

    final minDelay = math.min(
      math.max(0.25, (consecutiveFailuresCount - 1) * 2),
      maximumReconnectionDelayInSeconds,
    );

    final rand = math.Random().nextDouble();
    final delayInSeconds = (rand * (maxDelay - minDelay) + minDelay).floor();

    return Duration(milliseconds: delayInSeconds * 1000);
  }
}
