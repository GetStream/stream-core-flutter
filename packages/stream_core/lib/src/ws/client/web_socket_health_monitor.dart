import 'dart:async';

import 'web_socket_connection_state.dart';

/// Interface for receiving WebSocket health monitoring events.
///
/// Implementations of this interface receive callbacks when health monitoring
/// events occur, such as when a ping should be sent or when the connection
/// is determined to be unhealthy.
abstract interface class WebSocketHealthListener {
  /// Called when the WebSocket connection is determined to be unhealthy.
  ///
  /// This typically occurs when no pong response is received within the
  /// configured timeout threshold after sending a ping request. Implementations
  /// should initiate a disconnection with an unhealthy connection source.
  void onUnhealthy();

  /// Called when it's time to send a ping request for health checking.
  ///
  /// The listener should send a ping message through the WebSocket connection
  /// to verify that the connection is still active and responsive. Implementations
  /// should build and send a ping request if the connection is currently established.
  void onPingRequested();
}

/// A health monitor for WebSocket connections with ping/pong management.
///
/// Manages the health checking mechanism for WebSocket connections by automatically
/// sending ping requests and monitoring for pong responses to detect unhealthy connections.
/// 
/// The monitor integrates with [WebSocketHealthListener] to provide automatic connection
/// health detection and recovery triggers.
///
/// ## Health Check Process
/// 
/// 1. **Automatic Start**: Monitoring begins when connection state becomes connected
/// 2. **Ping Scheduling**: Sends periodic ping requests at the configured interval
/// 3. **Pong Monitoring**: Starts timeout timer after each ping request
/// 4. **Unhealthy Detection**: Marks connection unhealthy if no pong received within threshold
/// 5. **Automatic Stop**: Stops monitoring when connection becomes inactive
class WebSocketHealthMonitor {
  /// Creates a new instance of [WebSocketHealthMonitor].
  WebSocketHealthMonitor({
    required WebSocketHealthListener listener,
    this.pingInterval = const Duration(seconds: 25),
    this.timeoutThreshold = const Duration(seconds: 3),
  }) : _listener = listener;

  /// The interval between ping requests for health checking.
  final Duration pingInterval;
  
  /// The maximum time to wait for a pong response before considering the connection unhealthy.
  final Duration timeoutThreshold;
  
  final WebSocketHealthListener _listener;

  Timer? _pingTimer;
  Timer? _pongTimer;

  /// Starts health monitoring with periodic ping requests.
  ///
  /// Called automatically when the WebSocket connection becomes active.
  /// Schedules the first ping request immediately if no monitoring is already active.
  void start() {
    if (_pingTimer?.isActive ?? false) return;

    _pongTimer?.cancel();
    return _schedulePing();
  }

  /// Handles pong response reception.
  ///
  /// Cancels the current pong timeout timer, indicating the connection is healthy.
  /// Called automatically when pong events are received from the WebSocket.
  void onPongReceived() => _pongTimer?.cancel();

  /// Handles connection state changes.
  ///
  /// Starts monitoring when the connection becomes active and stops monitoring
  /// when the connection becomes inactive. Called automatically by the WebSocket client.
  void onConnectionStateChanged(WebSocketConnectionState state) {
    if (state.isConnected) return start();
    return stop();
  }

  void _schedulePing() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(pingInterval, _sendPing);
  }

  void _sendPing(Timer pingTimer) {
    if (!pingTimer.isActive) return;

    _listener.onPingRequested();

    _pongTimer?.cancel();
    _pongTimer = Timer(timeoutThreshold, _listener.onUnhealthy);
  }

  /// Stops health monitoring and cancels all timers.
  ///
  /// Called automatically when the WebSocket connection becomes inactive or is closed.
  /// Cancels both the ping scheduling timer and any active pong timeout timer.
  void stop() {
    _pingTimer?.cancel();
    _pongTimer?.cancel();
  }
}
