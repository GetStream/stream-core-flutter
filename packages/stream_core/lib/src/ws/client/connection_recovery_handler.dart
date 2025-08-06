import 'dart:async';
import 'dart:math' as math;

import 'package:meta/meta.dart';

import '../../utils/network_monitor.dart';
import 'web_socket_client.dart';
import 'web_socket_connection_state.dart';

// ignore: one_member_abstracts
abstract class AutomaticReconnectionPolicy {
  bool canBeReconnected();
}

class ConnectionRecoveryHandler {
  ConnectionRecoveryHandler({
    required this.retryStrategy,
    required this.client,
    required this.policies,
  });

  final WebSocketClient client;
  final List<AutomaticReconnectionPolicy> policies;
  final List<StreamSubscription<dynamic>> subscriptions = [];
  final RetryStrategy retryStrategy;
  Timer? _reconnectionTimer;

  @protected
  void reconnectIfNeeded() {
    if (!_canReconnectAutomatically()) return;

    client.connect();
  }

  @protected
  void disconnectIfNeeded() {
    final canBeDisconnected = switch (client.connectionState) {
      Connecting() || Connected() || Authenticating() => true,
      _ => false,
    };

    if (canBeDisconnected) {
      print('Disconnecting automatically');
      client.disconnect(source: DisconnectionSource.systemInitiated());
    }
  }

  @protected
  void scheduleReconnectionTimerIfNeeded() {
    if (!_canReconnectAutomatically()) return;

    final delay = retryStrategy.getDelayAfterFailure();
    print('Scheduling reconnection in ${delay.inSeconds} seconds');
    _reconnectionTimer = Timer(delay, reconnectIfNeeded);
  }

  @protected
  void cancelReconnectionTimer() {
    if (_reconnectionTimer == null) return;

    print('Cancelling reconnection timer');
    _reconnectionTimer?.cancel();
    _reconnectionTimer = null;
  }

  Future<void> dispose() async {
    await Future.wait(
      subscriptions.map((subscription) => subscription.cancel()),
    );
    subscriptions.clear();
    cancelReconnectionTimer();
  }

  bool _canReconnectAutomatically() =>
      policies.every((policy) => policy.canBeReconnected());
}

class WebSocketAutomaticReconnectionPolicy
    implements AutomaticReconnectionPolicy {
  WebSocketAutomaticReconnectionPolicy({required this.client});

  final WebSocketClient client;

  @override
  bool canBeReconnected() {
    return client.connectionState.isAutomaticReconnectionEnabled;
  }
}

class InternetAvailableReconnectionPolicy
    implements AutomaticReconnectionPolicy {
  InternetAvailableReconnectionPolicy({required this.networkMonitor});
  final NetworkMonitor networkMonitor;

  @override
  bool canBeReconnected() {
    return networkMonitor.currentStatus == NetworkStatus.connected;
  }
}

abstract class RetryStrategy {
  /// Returns the # of consecutively failed retries.
  int get consecutiveFailuresCount;

  /// Increments the # of consecutively failed retries making the next delay longer.
  void incrementConsecutiveFailures();

  /// Resets the # of consecutively failed retries making the next delay be the shortest one.
  void resetConsecutiveFailures();

  /// Calculates and returns the delay for the next retry.
  ///
  /// Consecutive calls after the same # of failures may return different delays. This randomization is done to
  /// make the retry intervals slightly different for different callers to avoid putting the backend down by
  /// making all the retries at the same time.
  Duration get nextRetryDelay;

  /// Returns the delay and then increments # of consecutively failed retries.
  Duration getDelayAfterFailure() {
    final delay = nextRetryDelay;
    incrementConsecutiveFailures();
    return delay;
  }
}

class DefaultRetryStrategy extends RetryStrategy {
  DefaultRetryStrategy();
  static const maximumReconnectionDelayInSeconds = 25;

  @override
  Duration get nextRetryDelay {
    /// The first time we get to retry, we do it without any delay. Any subsequent time will
    /// be delayed by a random interval.
    if (consecutiveFailuresCount == 0) return Duration.zero;

    final maxDelay = math.min(
      0.5 + consecutiveFailuresCount * 2,
      maximumReconnectionDelayInSeconds,
    );
    final minDelay = math.min(
      math.max(0.25, (consecutiveFailuresCount - 1) * 2),
      maximumReconnectionDelayInSeconds,
    );

    final delayInSeconds =
        math.Random().nextDouble() * (maxDelay - minDelay) + minDelay;

    return Duration(milliseconds: (delayInSeconds * 1000).toInt());
  }

  @override
  int consecutiveFailuresCount = 0;

  @override
  void incrementConsecutiveFailures() {
    consecutiveFailuresCount++;
  }

  @override
  void resetConsecutiveFailures() {
    consecutiveFailuresCount = 0;
  }
}
