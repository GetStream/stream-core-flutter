import 'dart:async';

import '../../utils.dart';
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

/// A function that builds the options for a connection attempt.
///
/// Called once per attempt, so the options may carry values that change over the
/// client's lifetime.
///
/// Returns the [WebSocketOptions] to open the connection with.
typedef WebSocketOptionsBuilder = WebSocketOptions Function();

/// A function that sends a request over a connection that is not usable yet.
///
/// Handed to a [WebSocketAuthenticator], which runs while the connection is
/// still being established and so cannot be given the client itself.
///
/// Returns a [Result] indicating whether the request was sent.
typedef WsSender = Result<void> Function(WsRequest request);

/// A function that authenticates a newly opened connection.
///
/// Called once the socket is open, while the state is [Authenticating]. Sending
/// the credentials the server expects is this function's job.
///
/// Returns a [Result] that fails when the credentials could not be sent, in
/// which case the connection is closed with [AuthenticationFailed] rather than
/// left waiting for a reply that never comes.
typedef WebSocketAuthenticator = Future<Result<void>> Function(WsSender send);

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
///   optionsBuilder: () => WebSocketOptions(url: 'wss://api.example.com'),
///   messageCodec: JsonMessageCodec(),
///   onAuthenticate: (send) async => send(AuthRequest(token: authToken)),
/// );
///
/// await client.connect();
/// ```
class StreamWebSocketClient with Disposable implements WebSocketHealthListener, WebSocketEngineListener<WsEvent> {
  /// Creates a new instance of [StreamWebSocketClient].
  StreamWebSocketClient({
    required this.optionsBuilder,
    this.onAuthenticate,
    WebSocketProvider? wsProvider,
    this.pingRequestBuilder = _defaultPingRequestBuilder,
    required WebSocketMessageCodec<WsEvent, WsRequest> messageCodec,
    Iterable<EventResolver<WsEvent>>? eventResolvers,
  }) {
    _events = MutableEventEmitter(resolvers: eventResolvers);
    _engine = StreamWebSocketEngine(
      listener: this,
      wsProvider: wsProvider,
      messageCodec: messageCodec,
    );
  }

  /// The function used to build the connection options for each attempt.
  final WebSocketOptionsBuilder optionsBuilder;

  /// The function used to build ping requests for health checks.
  final PingRequestBuilder pingRequestBuilder;

  /// The function used to authenticate a newly opened connection.
  final WebSocketAuthenticator? onAuthenticate;

  late final StreamWebSocketEngine<WsEvent, WsRequest> _engine;
  late final _healthMonitor = WebSocketHealthMonitor(listener: this);

  // Bounds a connection attempt that never reaches 'connected'.
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
    // Return early if the emitter is closed.
    if (_connectionStateEmitter.isClosed) return;

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
  /// If the connection is already established or in progress, this method returns immediately,
  /// as it does while a previous connection is still closing, and once [dispose] has been called.
  ///
  /// Returns a [Future] that completes once the socket is open — before the
  /// connection is authenticated, and well before it is [Connected]. Watch
  /// [connectionState] to know when it is usable.
  Future<void> connect() async {
    assert(!isDisposed, 'Cannot connect a disposed StreamWebSocketClient');
    if (isDisposed) return;

    // If the connection is already established or in the process of connecting,
    // do not initiate a new connection.
    if (connectionState.value is Connecting) return;
    if (connectionState.value is Authenticating) return;
    if (connectionState.value is Connected) return;

    // Nor while a previous connection is still closing: the socket it opened
    // would be brought down by the old one's close event, which would also
    // disarm the new attempt's timeout and leave it authenticating unwatched.
    if (connectionState.value is Disconnecting) return;

    // Update the connection state to 'connecting'.
    _connectionState = const WebSocketConnectionState.connecting();

    // Open the connection using the engine, with options built for this attempt.
    final options = optionsBuilder.call();

    // Time the whole handshake: nothing else watches 'authenticating'.
    _startConnectTimeout(options.connectTimeout);
    final result = await _engine.open(options);

    // If some failure occurs, disconnect and rethrow the error.
    return result.recover((_, _) => onClose()).getOrThrow();
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
    // A connection already going down keeps the source it started going down
    // with: whoever asked first described why. Without this the connect
    // timeout could replace a `ServerInitiated` closure, which is
    // reconnectable, with one that is not.
    if (connectionState.value case Disconnected() || Disconnecting()) return;

    // Stop the timeout from firing later and replacing this source.
    _cancelConnectTimeout();

    // Update the connection state to 'disconnecting'.
    _connectionState = WebSocketConnectionState.disconnecting(source: source);

    // Awaited so the connection is closed, rather than merely closing, once this
    // returns: a reconnect straight afterwards would otherwise race the close
    // and see the connection go down again.
    final result = await _engine.close(closeCode, source.closeReason);

    // The engine reports a failed close rather than throwing, and does not
    // notify its listener on that path. The connection is unusable either way,
    // so report it closed rather than leave it disconnecting for good.
    if (result.isFailure) onClose(closeCode, source.closeReason);
  }

  /// Releases every resource held by this client.
  ///
  /// Closes the connection along with [events] and [connectionState], after which
  /// this client cannot be connected again. Use [disconnect] for a connection that
  /// may be opened again.
  ///
  /// Returns a [Future] that completes once everything has been released.
  @override
  Future<void> dispose() async {
    await disconnect();
    _healthMonitor.stop();

    await _events.close();
    await _connectionStateEmitter.close();

    return super.dispose();
  }

  @override
  void onOpen() {
    // Update the connection state to 'authenticating'.
    _connectionState = const WebSocketConnectionState.authenticating();

    // The socket is open, so authenticate before the connection is usable.
    unawaited(_authenticate());
  }

  Future<void> _authenticate() async {
    final authenticate = onAuthenticate;
    if (authenticate == null) return;

    // Guarded rather than awaited directly: an authenticator that awaits a
    // token throws rather than returning a failure, and nothing observes this
    // future, so the error would escape and leave the connection
    // authenticating until the timeout reported a cause it does not know.
    final outcome = await runSafely(() => authenticate(send));
    final result = outcome.flatten<void>();

    // Close the connection rather than wait for a reply that cannot come.
    if (result.exceptionOrNull() case final error?) {
      final source = DisconnectionSource.authenticationFailed(error: error);
      return disconnect(source: source);
    }
  }

  @override
  void onClose([int? closeCode, String? closeReason]) {
    _cancelConnectTimeout();

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

    return unawaited(disconnect(source: source));
  }

  void _handleHealthCheckEvent(WsEvent event, HealthCheckInfo info) {
    print('WebSocketClient: Health check pong received: $info');

    // Ignore a pong that arrives once the connection is on its way down.
    if (connectionState.value case Disconnecting() || Disconnected()) return;

    _cancelConnectTimeout();

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
