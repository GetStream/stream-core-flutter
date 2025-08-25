import 'dart:async';

import '../../logger/logger.dart';
import '../../utils.dart';
import '../events/event_emitter.dart';
import '../events/ws_event.dart';
import '../events/ws_request.dart';
import 'engine/stream_web_socket_engine.dart';
import 'engine/web_socket_engine.dart';
import 'web_socket_connection_state.dart';
import 'web_socket_health_monitor.dart';

/// A function that builds ping requests for health checks.
///
/// The [info] parameter contains health check information from the current connection.
///
/// Returns a [WsRequest] that will be sent as a ping message.
typedef PingRequestBuilder = WsRequest Function([HealthCheckInfo? info]);
WsRequest _defaultPingRequestBuilder([HealthCheckInfo? info]) {
  return HealthCheckPingEvent(connectionId: info?.connectionId);
}

/// A WebSocket client with connection management and event handling.
///
/// The primary interface for WebSocket connections in the Stream Core SDK that provides
/// functionality for real-time communication with automatic reconnection, health monitoring,
/// and sophisticated state management.
///
/// Each [StreamWebSocketClient] instance manages its own connection lifecycle and maintains
/// state that can be observed for real-time updates. The client handles message encoding/decoding,
/// connection recovery, and event distribution.
///
/// ## Example
/// ```dart
/// final client = StreamWebSocketClient(
///   options: WebSocketOptions(url: 'wss://api.example.com'),
///   messageCodec: JsonMessageCodec(),
///   onConnectionEstablished: () {
///     client.send(AuthRequest(token: authToken));
///   },
/// );
///
/// await client.connect();
/// ```
class StreamWebSocketClient
    implements WebSocketHealthListener, WebSocketEngineListener<WsEvent> {
  /// Creates a new instance of [StreamWebSocketClient].
  StreamWebSocketClient({
    String tag = 'StreamWebSocketClient',
    required this.options,
    this.onConnectionEstablished,
    WebSocketProvider? wsProvider,
    this.pingRequestBuilder = _defaultPingRequestBuilder,
    required WebSocketMessageCodec<WsEvent, WsRequest> messageCodec,
    Iterable<EventResolver<WsEvent>>? eventResolvers,
  }) : _logger = TaggedLogger(tag) {
    _events = MutableEventEmitter(resolvers: eventResolvers);
    _engine = StreamWebSocketEngine(
      listener: this,
      wsProvider: wsProvider,
      messageCodec: messageCodec,
    );
  }

  final TaggedLogger _logger;

  /// The WebSocket connection options including URL and configuration.
  final WebSocketOptions options;

  /// The function used to build ping requests for health checks.
  final PingRequestBuilder pingRequestBuilder;

  /// Called when the WebSocket connection is established and ready for authentication.
  final void Function()? onConnectionEstablished;

  late final StreamWebSocketEngine<WsEvent, WsRequest> _engine;
  late final _healthMonitor = WebSocketHealthMonitor(listener: this);

  /// The event emitter for WebSocket events.
  ///
  /// Use this to listen to incoming WebSocket events with type-safe event handling.
  EventEmitter get events => _events;
  late final MutableEventEmitter _events;

  /// The current connection state of the WebSocket.
  ///
  /// Emits state changes as the WebSocket transitions through different connection states.
  ConnectionStateEmitter get connectionState => _connectionStateEmitter;
  late final _connectionStateEmitter = MutableConnectionStateEmitter(
    const WebSocketConnectionState.initialized(),
  );

  set _connectionState(WebSocketConnectionState connectionState) {
    // Return early if the state hasn't changed.
    if (_connectionStateEmitter.value == connectionState) return;

    print('WebSocketClient: Connection state changed to $connectionState');
    _connectionStateEmitter.value = connectionState;
    _healthMonitor.onConnectionStateChanged(connectionState);
  }

  /// Sends a message through the WebSocket connection.
  ///
  /// The [request] is encoded using the configured message codec and sent to the server.
  ///
  /// Returns a [Result] indicating success or failure of the send operation.
  Result<void> send(WsRequest request) => _engine.sendMessage(request);

  /// Establishes a WebSocket connection.
  ///
  /// The connection state can be monitored through [connectionState] for real-time updates.
  /// If the connection is already established or in progress, this method returns immediately.
  ///
  /// Returns a [Future] that completes when the connection attempt finishes.
  Future<void> connect() async {
    // If the connection is already established or in the process of connecting,
    // do not initiate a new connection.
    if (connectionState.value is Connecting) return;
    if (connectionState.value is Authenticating) return;
    if (connectionState.value is Connected) return;

    // Update the connection state to 'connecting'.
    _connectionState = const WebSocketConnectionState.connecting();

    // Open the connection using the engine.
    final result = await _engine.open(options);

    // If some failure occurs, disconnect and rethrow the error.
    return result.onFailure((_, __) => disconnect()).getOrThrow();
  }

  /// Closes the WebSocket connection.
  ///
  /// When [closeCode] is provided, uses the specified close code for the disconnection.
  /// The [source] indicates the reason for disconnection and affects reconnection behavior.
  ///
  /// Returns a [Future] that completes when the disconnection finishes.
  Future<void> disconnect({
    CloseCode closeCode = CloseCode.normalClosure,
    DisconnectionSource source = const UserInitiated(),
  }) async {
    // If the connection is already disconnected, do nothing.
    if (connectionState.value is Disconnected) return;

    // Update the connection state to 'disconnecting'.
    _connectionState = WebSocketConnectionState.disconnecting(source: source);

    // Close the connection using the engine.
    unawaited(_engine.close(closeCode, source.closeReason));
  }

  @override
  void onOpen() {
    // Update the connection state to 'authenticating'.
    _connectionState = const WebSocketConnectionState.authenticating();

    // Notify that the connection has been established and we are ready
    // to authenticate.
    onConnectionEstablished?.call();
  }

  @override
  void onClose([int? closeCode, String? closeReason]) {
    final source = switch (connectionState.value) {
      // If we were already disconnecting, keep the caller-provided source.
      Disconnecting(:final source) => source,

      // Any active state that wasn’t user/system initiated becomes server initiated.
      Connecting() || Authenticating() || Connected() => ServerInitiated(
          error: WebSocketEngineException(
            code: closeCode,
            reason: closeReason,
          ),
        ),

      // Not meaningful to transition from these; just log and bail.
      Initialized() || Disconnected() => null,
    };

    if (source == null) return;

    // Update the connection state to 'disconnected' with the source.
    _connectionState = WebSocketConnectionState.disconnected(source: source);
  }

  @override
  void onError(Object error, [StackTrace? stackTrace]) {
    final source = ServerInitiated(
      error: WebSocketEngineException(error: error),
    );

    // Update the connection state to 'disconnecting' with the source.
    //
    // Note: We don't have to use `Disconnected` state here because the socket
    // automatically closes the connection after sending the error.
    _connectionState = WebSocketConnectionState.disconnecting(source: source);
  }

  @override
  void onMessage(WsEvent event) {
    // If the event is an error event, handle it.
    if (event.error case final error?) {
      return _handleErrorEvent(event, error);
    }

    // If the event is a health check event, handle it.
    if (event.healthCheckInfo case final healthCheckInfo?) {
      return _handleHealthCheckEvent(event, healthCheckInfo);
    }

    // Emit the decoded event.
    _events.emit(event);
  }

  void _handleErrorEvent(WsEvent event, Object error) {
    final source = ServerInitiated(
      error: WebSocketEngineException(error: error),
    );

    // Update the connection state to 'disconnecting'.
    _connectionState = WebSocketConnectionState.disconnecting(source: source);
  }

  void _handleHealthCheckEvent(WsEvent event, HealthCheckInfo info) {
    print('WebSocketClient: Health check pong received: $info');

    // Update the connection state with health check info.
    _connectionState = WebSocketConnectionState.connected(healthCheck: info);

    // Notify the health monitor that a pong has been received.
    _healthMonitor.onPongReceived();

    // Emit the health check event.
    //
    // Note: We send the event even after handling it to allow
    // listeners to react to it if needed.
    _events.emit(event);
  }

  @override
  void onPingRequested() {
    // Send a ping request if the connection is established.
    if (connectionState.value case Connected(:final healthCheck)) {
      final pingRequest = pingRequestBuilder(healthCheck);

      // Send the ping request.
      send(pingRequest);
      print('WebSocketClient: Ping request sent: $pingRequest');
    }
  }

  @override
  void onUnhealthy() {
    // Disconnect the socket if it becomes unhealthy.
    const source = DisconnectionSource.unHealthyConnection();
    return unawaited(disconnect(source: source));
  }
}
