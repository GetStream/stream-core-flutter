import '../../errors/client_exception.dart';
import '../../utils/shared_emitter.dart';
import '../events/sendable_event.dart';
import '../events/ws_event.dart';
import 'web_socket_connection_state.dart';
import 'web_socket_engine.dart';
import 'web_socket_ping_controller.dart';

class WebSocketClient implements WebSocketEngineListener, WebSocketPingClient {

  WebSocketClient({
    required String url,
    required this.eventDecoder,
    this.pingReguestBuilder,
    this.onConnectionEstablished,
    this.onConnected,
    WebSocketEnvironment environment = const WebSocketEnvironment(),
  }) {
    engine = environment.createEngine(
      url: url,
      listener: this,
    );

    pingController = environment.createPingController(client: this);
  }
  late final WebSocketEngine engine;
  late final WebSocketPingController pingController;
  final PingReguestBuilder? pingReguestBuilder;
  final VoidCallback? onConnectionEstablished;
  final VoidCallback? onConnected;
  final EventDecoder eventDecoder;

  WebSocketConnectionState _connectionStateValue =
      WebSocketConnectionState.initialized();

  set _connectionState(WebSocketConnectionState connectionState) {
    if (connectionState == _connectionStateValue) return;

    print('Connection state changed to ${connectionState.runtimeType}');
    pingController.connectionStateChanged(connectionState);
    _connectionStateStreamController.emit(connectionState);
    _connectionStateValue = connectionState;
  }

  WebSocketConnectionState get connectionState => _connectionStateValue;
  SharedEmitter<WebSocketConnectionState> get connectionStateStream =>
      _connectionStateStreamController;
  final _connectionStateStreamController =
      MutableSharedEmitterImpl<WebSocketConnectionState>();

  SharedEmitter<WsEvent> get events => _events;
  final _events = MutableSharedEmitterImpl<WsEvent>();

  String? get connectionId => _connectionId;
  String? _connectionId;

  void send(SendableEvent message) {
    engine.send(message: message);
  }

  //#region Connection
  void connect() {
    if (connectionState is Connecting ||
        connectionState is Authenticating ||
        connectionState is Connected) {
      return;
    }

    _connectionState = WebSocketConnectionState.connecting();
    engine.connect();
  }

  void disconnect({
    CloseCode code = CloseCode.normalClosure,
    DisconnectionSource source = const UserInitiated(),
  }) {
    _connectionState = WebSocketConnectionState.disconnecting(
      source: source,
    );

    engine.disconnect(code.code, source.toString());
  }

  void dispose() {
    pingController.dispose();
    _connectionStateStreamController.close();
    _events.close();
  }
  //#endregion

  //#region WebSocketEngineListener
  @override
  void webSocketDidConnect() {
    print('Web socket connection established');
    _connectionState = WebSocketConnectionState.authenticating();
    onConnectionEstablished?.call();
  }

  @override
  void webSocketDidDisconnect(WebSocketEngineException? exception) {
    switch (connectionState) {
      case Connecting() || Authenticating() || Connected():
        _connectionState = WebSocketConnectionState.disconnected(
          source: DisconnectionSource.serverInitiated(
            error: WebSocketException(exception),
          ),
        );
      case final Disconnecting disconnecting:
        _connectionState =
            WebSocketConnectionState.disconnected(source: disconnecting.source);
      case Initialized() || Disconnected():
        print(
          'Web socket can not be disconnected when in ${connectionState.runtimeType} state',
        );
    }
  }

  void _handleHealthCheckEvent(HealthCheckInfo healthCheckInfo) {
    final wasAuthenticating = connectionState is Authenticating;

    _connectionState = WebSocketConnectionState.connected(
      healthCheckInfo: healthCheckInfo,
    );
    _connectionId = healthCheckInfo.connectionId;
    pingController.pongReceived();

    if (wasAuthenticating) {
      onConnected?.call();
    }
  }

  @override
  void webSocketDidReceiveMessage(Object message) {
    final event = eventDecoder(message);
    if (event == null) {
      print('Received message is an unhandled event: $message');
      return;
    }

    if (event.healthCheckInfo case final healthCheckInfo?) {
      _handleHealthCheckEvent(healthCheckInfo);
    }

    if (event.error case final error?) {
      _connectionState = WebSocketConnectionState.disconnecting(
        source: ServerInitiated(error: ClientException(error: error)),
      );
    }

    _events.emit(event);
  }

  @override
  void webSocketDidReceiveError(Object error, StackTrace stackTrace) {
    _connectionState = WebSocketConnectionState.disconnecting(
      source: ServerInitiated(error: ClientException(error: error)),
    );
  }
  //#endregion

  //#region Ping client
  @override
  void sendPing() {
    if (connectionState.isConnected) {
      final healthCheckEvent = pingReguestBuilder?.call() ??
          HealthCheckPingEvent(connectionId: _connectionId);
      engine.send(message: healthCheckEvent);
    }
  }

  @override
  void disconnectNoPongReceived() {
    print('disconnecting from ${engine.url}');
    disconnect(
      source: DisconnectionSource.noPongReceived(),
    );
  }
  //#endregion
}

class WebSocketEnvironment {
  const WebSocketEnvironment();

  WebSocketEngine createEngine({
    required String url,
    required WebSocketEngineListener listener,
  }) =>
      URLSessionWebSocketEngine(url: url, listener: listener);

  WebSocketPingController createPingController({
    required WebSocketPingClient client,
  }) =>
      WebSocketPingController(client: client);
}

typedef EventDecoder = WsEvent? Function(Object message);
typedef PingReguestBuilder = SendableEvent Function();
typedef VoidCallback = void Function();

enum CloseCode {
  invalid(0),
  normalClosure(1000),
  goingAway(1001),
  protocolError(1002),
  unsupportedData(1003),
  noStatusReceived(1005),
  abnormalClosure(1006),
  invalidFramePayloadData(1007),
  policyViolation(1008),
  messageTooBig(1009),
  mandatoryExtensionMissing(1010),
  internalServerError(1011),
  tlsHandshakeFailure(1015);

  const CloseCode(this.code);
  final int code;
}
