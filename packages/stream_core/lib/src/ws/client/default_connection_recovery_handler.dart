import '../../utils/network_monitor.dart';
import 'connection_recovery_handler.dart';
import 'web_socket_connection_state.dart';

class DefaultConnectionRecoveryHandler extends ConnectionRecoveryHandler
    with
        WebSocketAwareConnectionRecoveryHandler,
        NetworkAwareConnectionRecoveryHandler {
  DefaultConnectionRecoveryHandler({
    RetryStrategy? retryStrategy,
    required super.client,
    NetworkMonitor? networkMonitor,
  }) : super(
          retryStrategy: retryStrategy ?? DefaultRetryStrategy(),
          policies: <AutomaticReconnectionPolicy>[
            WebSocketAutomaticReconnectionPolicy(client: client),
            if (networkMonitor case final networkMonitor?)
              InternetAvailableReconnectionPolicy(
                networkMonitor: networkMonitor,
              ),
          ],
        ) {
    _subscribe(networkMonitor: networkMonitor);
  }

  void _subscribe({NetworkMonitor? networkMonitor}) {
    subscribeToNetworkChanges(networkMonitor);
    subscribeToWebSocketConnectionChanges();
  }
}

mixin NetworkAwareConnectionRecoveryHandler on ConnectionRecoveryHandler {
  void _networkStatusChanged(NetworkStatus status) {
    if (status == NetworkStatus.connected) {
      disconnectIfNeeded();
    } else {
      reconnectIfNeeded();
    }
  }

  void subscribeToNetworkChanges(NetworkMonitor? networkMonitor) {
    if (networkMonitor case final networkMonitor?) {
      subscriptions
          .add(networkMonitor.onStatusChange.listen(_networkStatusChanged));
    }
  }
}

mixin WebSocketAwareConnectionRecoveryHandler on ConnectionRecoveryHandler {
  void _websocketConnectionStateChanged(WebSocketConnectionState state) {
    switch (state) {
      case Connecting():
        cancelReconnectionTimer();
      case Connected():
        retryStrategy.resetConsecutiveFailures();
      case Disconnected():
        scheduleReconnectionTimerIfNeeded();
      case Initialized() || Authenticating() || Disconnecting():
        // Don't do anything
        break;
    }
  }

  void subscribeToWebSocketConnectionChanges() {
    subscriptions.add(
        client.connectionStateStream.listen(_websocketConnectionStateChanged));
  }
}
