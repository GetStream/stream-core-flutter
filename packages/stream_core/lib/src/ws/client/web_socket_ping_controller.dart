import 'dart:async';

import 'web_socket_connection_state.dart';

/// WebSocketPingController is used to monitor the health of the websocket connection.
/// It will send a ping message to the server every [_pingTimeInterval] and wait for a pong response.
/// If the pong response is not received within [_pongTimeout], the connection is considered disconnected.
///
/// The controller will automatically resume the ping timer when the connection is resumed.
///
/// The controller will automatically pause the ping timer when the connection is disconnected.
///
/// The controller will automatically resume the ping timer when the connection is resumed.
class WebSocketPingController {
  final WebSocketPingClient _client;

  final Duration _pingTimeInterval;
  final Duration _pongTimeout;
  Timer? _pongTimeoutTimer;
  Timer? _pingTimer;

  WebSocketPingController({
    required WebSocketPingClient client,
    Duration pingTimeInterval = const Duration(seconds: 25),
    Duration pongTimeout = const Duration(seconds: 3),
  })  : _client = client,
        _pingTimeInterval = pingTimeInterval,
        _pongTimeout = pongTimeout;

  void connectionStateChanged(WebSocketConnectionState connectionState) {
    _pongTimeoutTimer?.cancel();

    if (connectionState.isConnected) {
      print('Resume Websocket Ping timer');
      _pingTimer = Timer.periodic(_pingTimeInterval, (_) {
        sendPing();
      });
    } else {
      _pingTimer?.cancel();
    }
  }

  void sendPing() {
    print('WebSocket Ping');
    _schedulePongTimeoutTimer();
    _client.sendPing();
  }

  void pongReceived() {
    print('WebSocket Pong');
    _cancelPongTimeoutTimer();
  }

  void _schedulePongTimeoutTimer() {
    _pongTimeoutTimer?.cancel();
    _pongTimeoutTimer = Timer(_pongTimeout, _client.disconnectNoPongReceived);
  }

  void _cancelPongTimeoutTimer() {
    _pongTimeoutTimer?.cancel();
  }
}

abstract interface class WebSocketPingClient {
  void sendPing();
  void disconnectNoPongReceived();
}
