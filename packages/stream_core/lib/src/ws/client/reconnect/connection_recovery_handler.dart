import 'dart:async';

import 'package:rxdart/utils.dart';

import '../../../logger.dart';
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
/// Only connections that were established are recovered. A first attempt that fails is reported
/// through [StreamWebSocketClient.connectionState] and left there, so it is not retried here, not
/// even when the network returns; making another belongs to whoever called
/// [StreamWebSocketClient.connect].
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
    LifecycleStateProvider? lifecycleStateProvider,
    this._keepConnectionAliveInBackground = false,
    List<AutomaticReconnectionPolicy>? policies,
    RetryStrategy? retryStrategy,
    String tag = 'SC:WsRecovery',
  }) : _client = client,
       _logger = StreamLogger(tag),
       _reconnectStrategy = retryStrategy ?? RetryStrategy(),
       _policies = <AutomaticReconnectionPolicy>[
         ...?policies,
         WebSocketAutomaticReconnectionPolicy(
           connectionState: client.connectionState,
         ),
         if (networkStateProvider case final provider?)
           InternetAvailabilityReconnectionPolicy(
             networkState: provider.state,
           ),
         if (lifecycleStateProvider case final provider?)
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
    if (lifecycleStateProvider case final provider?) {
      provider.state.on(_onAppLifecycleStateChanged).addTo(_subscriptions);
    }
  }

  final StreamWebSocketClient _client;
  final StreamLogger _logger;
  final RetryStrategy _reconnectStrategy;
  final bool _keepConnectionAliveInBackground;
  final List<AutomaticReconnectionPolicy> _policies;

  late final _subscriptions = CompositeSubscription();

  // True once a connection has been established, and false again if one closes for a reason this
  // handler will not act on. Tells a drop worth recovering apart from an attempt that never landed.
  var _hasEstablishedConnection = false;

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
    _logger.d(
      () => 'reconnect #${_reconnectStrategy.consecutiveFailuresCount} scheduled in ${delay.inMilliseconds}ms',
    );

    _reconnectionTimer?.cancel();
    _reconnectionTimer = Timer(delay, reconnectIfNeeded);
  }

  void _cancelReconnection() {
    if (_reconnectionTimer == null) return;

    _reconnectionTimer?.cancel();
    _reconnectionTimer = null;
  }

  bool _canBeReconnected() {
    if (!_hasEstablishedConnection) return false;
    return _policies.every((it) => it.canBeReconnected());
  }

  bool _canBeDisconnected() {
    return switch (_client.connectionState.value) {
      Connecting() || Authenticating() || Connected() => true,
      _ => false,
    };
  }

  void _onNetworkStateChanged(NetworkState status) {
    return switch (status) {
      NetworkState.unknown => () {}, // No action needed for unknown state.
      NetworkState.connected => reconnectIfNeeded(),
      NetworkState.disconnected => disconnectIfNeeded(),
    };
  }

  void _onAppLifecycleStateChanged(LifecycleState state) {
    return switch (state) {
      LifecycleState.unknown => () {}, // No action needed for unknown state.
      // If we want to keep the connection alive in the background, do nothing.
      LifecycleState.background when _keepConnectionAliveInBackground => () {},
      LifecycleState.background => disconnectIfNeeded(),
      LifecycleState.foreground => reconnectIfNeeded(),
    };
  }

  void _onConnectionStateChanged(WebSocketConnectionState state) {
    return switch (state) {
      Connecting() => _cancelReconnection(),
      Connected() => _onConnectionEstablished(),
      Disconnected(:final source) => _onConnectionLost(source),
      // These states do not require any action.
      Initialized() || Authenticating() || Disconnecting() => () {},
    };
  }

  void _onConnectionEstablished() {
    _hasEstablishedConnection = true;
    return _reconnectStrategy.resetConsecutiveFailures();
  }

  // Only the source matters here. The network and lifecycle are checked later, when a reconnect is
  // actually attempted, so a drop during an outage still counts as one worth recovering.
  void _onConnectionLost(DisconnectionSource source) {
    if (!source.isReconnectable) {
      _hasEstablishedConnection = false;
      return _cancelReconnection();
    }

    return _scheduleReconnectionIfNeeded();
  }

  @override
  Future<void> dispose() async {
    _cancelReconnection();
    await _subscriptions.dispose();
    return super.dispose();
  }
}
