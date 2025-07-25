import 'dart:async';
import 'dart:math' as math;

import '../../utils/network_monitor.dart';
import 'web_socket_client.dart';
import 'web_socket_connection_state.dart';

abstract class AutomaticReconnectionPolicy {
  bool canBeReconnected();
}

class ConnectionRecoveryHandler {
  ConnectionRecoveryHandler({
    RetryStrategy? retryStrategy,
    required this.client,
    this.networkMonitor,
  }) {
    this.retryStrategy = retryStrategy ?? DefaultRetryStrategy();

    policies = <AutomaticReconnectionPolicy>[
      WebSocketAutomaticReconnectionPolicy(client: client),
      if (networkMonitor case final networkMonitor?)
        InternetAvailableReconnectionPolicy(
          networkMonitor: networkMonitor,
        ),
    ];

    _subscribe();
  }

  Future<void> dispose() async {
    await Future.wait(
        subscriptions.map((subscription) => subscription.cancel()));
    subscriptions.clear();
    _cancelReconnectionTimer();
  }

  final WebSocketClient client;
  final NetworkMonitor? networkMonitor;
  late final List<AutomaticReconnectionPolicy> policies;
  List<StreamSubscription> subscriptions = [];
  late final RetryStrategy retryStrategy;
  Timer? _reconnectionTimer;

  void _reconnectIfNeeded() {
    if (!_canReconnectAutomatically()) return;

    client.connect();
  }

  void _disconnectIfNeeded() {
    final canBeDisconnected = switch (client.connectionState) {
      Connecting() || Connected() || Authenticating() => true,
      _ => false,
    };

    if (canBeDisconnected) {
      print('Disconnecting automatically');
      client.disconnect(source: DisconnectionSource.systemInitiated());
    }
  }

  void _scheduleReconnectionTimerIfNeeded() {
    if (!_canReconnectAutomatically()) return;

    final delay = retryStrategy.getDelayAfterFailure();
    print('Scheduling reconnection in ${delay.inSeconds} seconds');
    _reconnectionTimer = Timer(delay, _reconnectIfNeeded);
  }

  void _cancelReconnectionTimer() {
    if (_reconnectionTimer == null) return;

    print('Cancelling reconnection timer');
    _reconnectionTimer?.cancel();
    _reconnectionTimer = null;
  }

  void _subscribe() {
    subscriptions.add(
        client.connectionStateStream.listen(_websocketConnectionStateChanged));
    if (networkMonitor case final networkMonitor?) {
      subscriptions
          .add(networkMonitor.onStatusChange.listen(_networkStatusChanged));
    }
  }

  void _networkStatusChanged(NetworkStatus status) {
    if (status == NetworkStatus.connected) {
      _disconnectIfNeeded();
    } else {
      _reconnectIfNeeded();
    }
  }

  void _websocketConnectionStateChanged(WebSocketConnectionState state) {
    switch (state) {
      case Connecting():
        _cancelReconnectionTimer();
      case Connected():
        retryStrategy.resetConsecutiveFailures();
      case Disconnected():
        _scheduleReconnectionTimerIfNeeded();
      case Initialized() || Authenticating() || Disconnecting():
        // Don't do anything
        break;
    }
  }

  bool _canReconnectAutomatically() =>
      policies.every((policy) => policy.canBeReconnected());
}

class WebSocketAutomaticReconnectionPolicy
    implements AutomaticReconnectionPolicy {
  WebSocketClient client;

  WebSocketAutomaticReconnectionPolicy({required this.client});

  @override
  bool canBeReconnected() {
    return client.connectionState.isAutomaticReconnectionEnabled;
  }
}

class InternetAvailableReconnectionPolicy
    implements AutomaticReconnectionPolicy {
  NetworkMonitor networkMonitor;

  InternetAvailableReconnectionPolicy({required this.networkMonitor});

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
  static const maximumReconnectionDelayInSeconds = 25;

  DefaultRetryStrategy();

  @override
  Duration get nextRetryDelay {
    /// The first time we get to retry, we do it without any delay. Any subsequent time will
    /// be delayed by a random interval.
    if (consecutiveFailuresCount == 0) return Duration.zero;

    final maxDelay = math.min(
        0.5 + consecutiveFailuresCount * 2, maximumReconnectionDelayInSeconds);
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
