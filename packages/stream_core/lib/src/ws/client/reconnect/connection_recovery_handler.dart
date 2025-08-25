import 'dart:async';

import 'package:rxdart/utils.dart';

import '../../../logger/impl/tagged_logger.dart';
import '../../../utils.dart';
import '../stream_web_socket_client.dart';
import '../web_socket_connection_state.dart';
import 'automatic_reconnection_policy.dart';
import 'retry_strategy.dart';

/// A connection recovery handler with intelligent reconnection management.
///
/// Provides intelligent reconnection management with multiple policies and retry strategies
/// for [StreamWebSocketClient] instances. Automatically handles reconnection based on various
/// conditions like network state, app lifecycle, and connection errors.
///
/// The handler monitors connection state changes and applies configurable policies to determine
/// when reconnection should occur, implementing exponential backoff with jitter for optimal
/// retry behavior.
///
/// ## Built-in Policies
///
/// The handler automatically includes several reconnection policies:
/// - [WebSocketAutomaticReconnectionPolicy]: Checks whether reconnection is enabled based on disconnection source
/// - [InternetAvailabilityReconnectionPolicy]: Only allows reconnection when network is available
/// - [BackgroundStateReconnectionPolicy]: Prevents reconnection when app is in background
///
/// ## Example
/// ```dart
/// final recoveryHandler = ConnectionRecoveryHandler(
///   client: client,
///   networkStateProvider: NetworkStateProvider(),
///   appLifecycleStateProvider: AppLifecycleStateProvider(),
/// );
/// ```
class ConnectionRecoveryHandler extends Disposable {
  /// Creates a new instance of [ConnectionRecoveryHandler].
  ConnectionRecoveryHandler({
    required StreamWebSocketClient client,
    NetworkStateProvider? networkStateProvider,
    AppLifecycleStateProvider? appLifecycleStateProvider,
    List<AutomaticReconnectionPolicy>? policies,
    RetryStrategy? retryStrategy,
  })  : _client = client,
        _reconnectStrategy = retryStrategy ?? RetryStrategy(),
        _policies = <AutomaticReconnectionPolicy>[
          if (policies != null) ...policies,
          WebSocketAutomaticReconnectionPolicy(
            connectionState: client.connectionState,
          ),
          if (networkStateProvider case final provider?)
            InternetAvailabilityReconnectionPolicy(
              networkState: provider.state,
            ),
          if (appLifecycleStateProvider case final provider?)
            BackgroundStateReconnectionPolicy(
              appLifecycleState: provider.state,
            ),
        ] {
    // Listen to connection state changes.
    _client.connectionState.on(_onConnectionStateChanged).addTo(_subscriptions);

    // Listen to network state changes if a provider is given.
    if (networkStateProvider case final provider?) {
      provider.state.on(_onNetworkStateChanged).addTo(_subscriptions);
    }

    // Listen to app lifecycle state changes if a provider is given.
    if (appLifecycleStateProvider case final provider?) {
      provider.state.on(_onAppLifecycleStateChanged).addTo(_subscriptions);
    }
  }

  final StreamWebSocketClient _client;
  final RetryStrategy _reconnectStrategy;
  final List<AutomaticReconnectionPolicy> _policies;
  late final _logger = taggedLogger(tag: 'ConnectionRecoveryHandler');

  late final _subscriptions = CompositeSubscription();

  /// Attempts reconnection if policies allow it.
  ///
  /// Evaluates all configured policies and initiates reconnection when conditions are met.
  /// Called automatically by the handler based on state changes.
  void reconnectIfNeeded() {
    if (!_canBeReconnected()) return;
    _client.connect();
  }

  /// Disconnects the client if policies require it.
  ///
  /// Evaluates policies and disconnects when conditions indicate disconnection is needed
  /// (e.g., app backgrounded, network unavailable).
  void disconnectIfNeeded() {
    if (!_canBeDisconnected()) return;
    _client.disconnect(source: const DisconnectionSource.systemInitiated());
  }

  void _scheduleReconnectionIfNeeded() {
    if (!_canBeReconnected()) return;
    _scheduleReconnection();
  }

  Timer? _reconnectionTimer;
  void _scheduleReconnection() {
    final delay = _reconnectStrategy.getDelayAfterTheFailure();

    _reconnectionTimer?.cancel();
    _reconnectionTimer = Timer(delay, reconnectIfNeeded);
  }

  void _cancelReconnection() {
    if (_reconnectionTimer == null) return;

    _reconnectionTimer?.cancel();
    _reconnectionTimer = null;
  }

  bool _canBeReconnected() {
    return _policies.every((policy) => policy.canBeReconnected());
  }

  bool _canBeDisconnected() {
    return switch (_client.connectionState.value) {
      Connecting() || Authenticating() || Connected() => true,
      _ => false,
    };
  }

  void _onNetworkStateChanged(NetworkState status) {
    return switch (status) {
      NetworkState.connected => reconnectIfNeeded(),
      NetworkState.disconnected => disconnectIfNeeded(),
    };
  }

  void _onAppLifecycleStateChanged(AppLifecycleState state) {
    return switch (state) {
      AppLifecycleState.foreground => reconnectIfNeeded(),
      AppLifecycleState.background => disconnectIfNeeded(),
    };
  }

  void _onConnectionStateChanged(WebSocketConnectionState state) {
    return switch (state) {
      Connecting() => _cancelReconnection(),
      Connected() => _reconnectStrategy.resetConsecutiveFailures(),
      Disconnected() => _scheduleReconnectionIfNeeded(),
      // These states do not require any action.
      Initialized() || Authenticating() || Disconnecting() => null,
    };
  }

  @override
  Future<void> dispose() async {
    _cancelReconnection();
    await _subscriptions.dispose();
    return super.dispose();
  }
}
