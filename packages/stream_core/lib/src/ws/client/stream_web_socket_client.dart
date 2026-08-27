import 'dart:async';

import '../../errors.dart';
import '../../logger.dart';
import '../../utils.dart';
import '../events/ws_event.dart';
import '../events/ws_request.dart';
import 'engine/stream_web_socket_engine.dart';
import 'engine/web_socket_engine.dart';
import 'web_socket_authentication_handler.dart';
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

/// A function that builds the options for a connection attempt.
///
/// Called once per attempt, so the options can change between attempts.
typedef WebSocketOptionsBuilder = WebSocketOptions Function();

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
///   optionsBuilder: () => const WebSocketOptions(url: 'wss://api.example.com'),
///   // A WebSocketMessageCodec for the event and request types this SDK puts on the wire.
///   messageCodec: const AppWsCodec(),
///   onAuthenticate: (send, _) async {
///     final token = await tokenManager.getToken();
///     send(WsAuthMessageRequest(token: token.rawValue)).getOrThrow();
///   },
/// );
///
/// await client.connect();
/// ```
///
/// This client reports what it is doing under `SC:WsClient`, and the engine, health monitor and
/// authentication handler it owns under `SC:WsClient:Engine`, `:Health` and `:Auth`. Nothing is
/// written until an app installs a [StreamLogHandler]:
///
/// ```dart
/// StreamLogger.handler = const StreamLogHandler.filtered(StreamLogFilter.minPriority(StreamLogPriority.debug), StreamLogHandler.console());
/// ```
///
/// Give a second client its own `tag` to tell the two apart. Its collaborators are tagged from
/// it, so one prefix still selects the whole family:
///
/// ```dart
/// StreamWebSocketClient(tag: 'SC:Ws2', ...);
/// StreamLogger.filter = const StreamLogFilter.prefix({'SC:Ws2': StreamLogPriority.verbose});
/// ```
class StreamWebSocketClient with Disposable implements WebSocketHealthListener, WebSocketEngineListener<WsEvent> {
  /// Creates a new instance of [StreamWebSocketClient].
  StreamWebSocketClient({
    required this.optionsBuilder,
    WebSocketProvider? wsProvider,
    WebSocketAuthenticator? onAuthenticate,
    this.pingRequestBuilder = _defaultPingRequestBuilder,
    required WebSocketMessageCodec<WsEvent, WsRequest> messageCodec,
    Iterable<EventResolver<WsEvent>>? eventResolvers,
    String tag = 'SC:WsClient',
  }) : _logger = StreamLogger(tag) {
    _events = MutableEventEmitter(resolvers: eventResolvers);
    _engine = StreamWebSocketEngine(
      listener: this,
      wsProvider: wsProvider,
      messageCodec: messageCodec,
      tag: '$tag:Engine',
    );

    _healthMonitor = WebSocketHealthMonitor(listener: this, tag: '$tag:Health');

    _authenticationHandler = WebSocketAuthenticationHandler(
      send: send,
      authenticator: onAuthenticate,
      tag: '$tag:Auth',
      onFailure: (error) => disconnect(
        source: .authenticationFailed(error: _asAuthenticationFailure(error)),
      ),
    );
  }

  /// The function used to build the connection options for each attempt.
  final WebSocketOptionsBuilder optionsBuilder;

  /// The function used to build ping requests for health checks.
  final PingRequestBuilder pingRequestBuilder;

  final StreamLogger _logger;

  late final StreamWebSocketEngine<WsEvent, WsRequest> _engine;
  late final WebSocketAuthenticationHandler _authenticationHandler;
  late final WebSocketHealthMonitor _healthMonitor;

  // Bounds an attempt while `Connecting` or `Authenticating`; the health monitor takes over after.
  Timer? _connectTimeoutTimer;

  void _startConnectTimeout(Duration timeout) {
    _connectTimeoutTimer?.cancel();
    _connectTimeoutTimer = Timer(timeout, () {
      const source = DisconnectionSource.connectTimeout();
      unawaited(disconnect(source: source));
    });
  }

  void _cancelConnectTimeout() {
    _connectTimeoutTimer?.cancel();
    _connectTimeoutTimer = null;
  }

  /// The event emitter for WebSocket events.
  ///
  /// Use this to listen to incoming WebSocket events with type-safe event handling.
  EventEmitter<WsEvent> get events => _events;
  late final MutableEventEmitter<WsEvent> _events;

  /// The current connection state of the WebSocket.
  ///
  /// Emits state changes as the WebSocket transitions through different connection states.
  ConnectionStateEmitter get connectionState => _connectionStateEmitter;
  late final _connectionStateEmitter = MutableConnectionStateEmitter(const .initialized());

  set _connectionState(WebSocketConnectionState connectionState) {
    if (_connectionStateEmitter.isClosed) return;

    // Return early if the state hasn't changed.
    if (_connectionStateEmitter.value == connectionState) return;

    final previous = _connectionStateEmitter.value;
    _connectionStateEmitter.value = connectionState;
    _logger.d(() => 'state: $previous -> $connectionState');

    _healthMonitor.onConnectionStateChanged(connectionState);
    _authenticationHandler.onConnectionStateChanged(connectionState);
  }

  /// Sends a message through the WebSocket connection.
  ///
  /// The [request] is encoded using the configured message codec and sent to the server.
  ///
  /// Returns a [Result] indicating success or failure of the send operation.
  Result<void> send(WsRequest request) => _engine.sendMessage(request);

  /// Establishes a WebSocket connection.
  ///
  /// If the connection is already established or in progress, this method returns immediately,
  /// as it does while a previous connection is still closing.
  ///
  /// Returns a [Future] that completes once the socket is open, before the connection is
  /// authenticated and well before it is [Connected]. Watch [connectionState] to know when it
  /// is usable, and to see an attempt that failed: a failure is reported there rather than thrown,
  /// so an attempt that never lands leaves the state [Disconnected] and nothing else.
  ///
  /// Throws a [StateError] once [dispose] has been called.
  Future<void> connect() async {
    // A socket opened here would be invisible: a disposed client reports no state and closes nothing.
    if (isDisposed) throw StateError('Cannot connect a disposed StreamWebSocketClient');

    // If the connection is already established or in the process of connecting,
    // do not initiate a new connection.
    if (connectionState.value is Connecting) return;
    if (connectionState.value is Authenticating) return;
    if (connectionState.value is Connected) return;
    if (connectionState.value is Disconnecting) return;

    // Update the connection state to 'connecting'.
    _connectionState = const WebSocketConnectionState.connecting();

    // Open the connection using the engine, with options built for this attempt.
    final options = optionsBuilder.call();
    _logger.d(() => 'connect to ${options.url}');

    // Bound the attempt, so one that never becomes usable is not waited on forever.
    _startConnectTimeout(options.connectTimeout);
    final result = await _engine.open(options);

    // Handed to `disconnect`, which reports the reason, closes the socket, and records the closure
    // even when the close fails. Returned, so a caller connecting again is not refused for the race.
    return result.getOrElse(
      (error, stackTrace) => disconnect(
        source: .serverInitiated(error: _asOpenFailure(error, stackTrace)),
      ),
    );
  }

  // The engine reports whatever the transport threw; an attempt that never
  // became usable is a network failure unless it already speaks for itself.
  StreamException _asOpenFailure(Object error, StackTrace? stackTrace) {
    return switch (error) {
      final StreamException exception => exception,
      _ => StreamNetworkException(
        message: 'Failed to open the connection',
        cause: error,
        stackTrace: stackTrace,
      ),
    };
  }

  // Credentials never went out — an authentication failure, unless the
  // authenticator already reported one of our own.
  StreamException _asAuthenticationFailure(Object error) {
    return switch (error) {
      final StreamException exception => exception,
      _ => StreamAuthenticationException(
        message: 'The connection could not be authenticated',
        cause: error,
      ),
    };
  }

  /// Closes the WebSocket connection.
  ///
  /// When [closeCode] is provided, uses the specified close code for the disconnection.
  /// The [source] indicates the reason for disconnection and affects reconnection behavior.
  ///
  /// A [UserInitiated] or [AuthenticationFailed] disconnection takes effect even on a connection
  /// that is already down or on its way down, which is what calls off a reconnection waiting to be
  /// made. Every other source leaves a closure already recorded as it is.
  ///
  /// Returns a [Future] that completes when the disconnection finishes.
  Future<void> disconnect({
    CloseCode closeCode = CloseCode.normalClosure,
    DisconnectionSource source = const UserInitiated(),
  }) async {
    _cancelConnectTimeout();

    if (connectionState.value case Initialized()) return;

    // A source that blocks reconnection overwrites one already recorded, or a pending reconnect
    // fires past it.
    final forceDisconnect = source is UserInitiated || source is AuthenticationFailed;
    if (connectionState.value case Disconnecting() when !forceDisconnect) return;
    if (connectionState.value case Disconnected() when !forceDisconnect) return;

    _logger.d(() => 'disconnect with $closeCode, source: $source');

    // Update the connection state to 'disconnecting'.
    _connectionState = WebSocketConnectionState.disconnecting(source: source);

    // Close the connection using the engine.
    final result = await _engine.close(closeCode, source.closeReason);

    // The engine announces nothing when a close fails, which would leave this stuck disconnecting.
    return result.getOrElse((_, _) => onClose(closeCode, source.closeReason));
  }

  @override
  void onOpen() {
    // Update the connection state to 'authenticating'.
    _connectionState = const WebSocketConnectionState.authenticating();

    // The socket is open but not yet usable: the credentials go out before the server will serve it.
    unawaited(_authenticationHandler.authenticate());
  }

  @override
  void onClose([int? closeCode, String? closeReason]) {
    final source = switch (connectionState.value) {
      // If we were already disconnecting, keep the caller-provided source.
      Disconnecting(:final source) => source,

      // Any active state that wasn’t user/system initiated becomes server initiated.
      Connecting() || Authenticating() || Connected() => ServerInitiated(
        error: StreamNetworkException(
          message: closeReason ?? 'The connection was closed unexpectedly',
          closeCode: closeCode,
        ),
      ),

      // Not meaningful to transition from these.
      Initialized() || Disconnected() => null,
    };

    if (source == null) return;
    _cancelConnectTimeout();

    // Update the connection state to 'disconnected' with the source.
    _connectionState = WebSocketConnectionState.disconnected(source: source);
  }

  @override
  void onError(Object error, [StackTrace? stackTrace]) {
    _logger.e(() => 'socket failed', error: error, stackTrace: stackTrace);

    final source = ServerInitiated(
      error: StreamNetworkException(
        message: 'The connection reported an error',
        cause: error,
        stackTrace: stackTrace,
      ),
    );

    // Update the connection state to 'disconnecting' with the source.
    //
    // The socket closes itself after an error, so the closure that follows records the disconnection.
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
    _logger.w(() => 'server sent an error event', error: error);

    // A server error event is a verdict — the same payload a rejected REST
    // call carries, delivered over the socket instead.
    final exception = switch (error) {
      final StreamException exception => exception,
      final StreamApiError apiError => StreamApiException.fromApiError(apiError),
      _ => StreamClientException(
        message: 'The server reported an error the client could not interpret',
        cause: error,
      ),
    };

    final source = ServerInitiated(error: exception);
    return unawaited(disconnect(source: source));
  }

  void _handleHealthCheckEvent(WsEvent event, HealthCheckInfo info) {
    // Still authenticating counts too: with no authenticator we never send anything, so this pong
    // is the only sign we get that the connection works.
    if (connectionState.value case Authenticating() || Connected()) {
      // The connection is established, so the attempt is no longer being timed.
      _cancelConnectTimeout();

      // Update the connection state with health check info.
      _connectionState = WebSocketConnectionState.connected(healthCheck: info);

      // Notify the health monitor that a pong has been received.
      _healthMonitor.onPongReceived();

      // Emit the health check event.
      //
      // Emitted as well as handled, so a listener can react to it too.
      _events.emit(event);
    }
  }

  @override
  void onPingRequested() {
    // Send a ping request if the connection is established.
    if (connectionState.value case Connected(:final healthCheck)) {
      final pingRequest = pingRequestBuilder(healthCheck);

      // Send the ping request.
      send(pingRequest);
    }
  }

  @override
  void onUnhealthy() {
    // Disconnect the socket if it becomes unhealthy.
    const source = DisconnectionSource.unHealthyConnection();
    return unawaited(disconnect(source: source));
  }

  /// Releases every resource held by this client.
  ///
  /// Closes the connection along with [events] and [connectionState],
  /// after which this client cannot be connected again.
  /// For a connection that may be opened again, consider [disconnect].
  ///
  /// Returns a [Future] that completes once everything is closed.
  @override
  Future<void> dispose() async {
    await disconnect();

    _healthMonitor.stop();

    await _events.close();
    await _connectionStateEmitter.close();

    return super.dispose();
  }
}
