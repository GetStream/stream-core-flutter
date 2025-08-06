import 'package:equatable/equatable.dart';

import '../../errors/client_exception.dart';
import '../events/ws_event.dart';
import 'web_socket_ping_controller.dart';

/// A web socket connection state.
sealed class WebSocketConnectionState extends Equatable {
  const WebSocketConnectionState();

  factory WebSocketConnectionState.initialized() => const Initialized();
  factory WebSocketConnectionState.connecting() => const Connecting();
  factory WebSocketConnectionState.authenticating() => const Authenticating();
  factory WebSocketConnectionState.connected({
    HealthCheckInfo? healthCheckInfo,
  }) =>
      Connected(healthCheckInfo: healthCheckInfo);
  factory WebSocketConnectionState.disconnecting({
    required DisconnectionSource source,
  }) =>
      Disconnecting(source: source);
  factory WebSocketConnectionState.disconnected({
    required DisconnectionSource source,
  }) =>
      Disconnected(source: source);

  /// Checks if the connection state is connected.
  bool get isConnected => this is Connected;

  /// Returns false if the connection state is in the `notConnected` state.
  bool get isActive => this is! Disconnected;

  /// Returns `true` is the state requires and allows automatic reconnection.
  bool get isAutomaticReconnectionEnabled {
    if (this is! Disconnected) {
      return false;
    }

    final source = (this as Disconnected).source;

    return switch (source) {
      final ServerInitiated serverInitiated =>
        serverInitiated.error != null, //TODO: Implement
      UserInitiated() => false,
      SystemInitiated() => true,
      NoPongReceived() => true,
    };
  }

  @override
  List<Object?> get props => [];
}

/// The initial state meaning that  there was no atempt to connect yet.
final class Initialized extends WebSocketConnectionState {
  /// The initial state meaning that  there was no atempt to connect yet.
  const Initialized();
}

/// The web socket is connecting.
final class Connecting extends WebSocketConnectionState {
  /// The web socket is connecting.
  const Connecting();
}

/// The web socket is connected, client is authenticating.
final class Authenticating extends WebSocketConnectionState {
  /// The web socket is connected, client is authenticating.
  const Authenticating();
}

/// The web socket was connected.
final class Connected extends WebSocketConnectionState {
  /// The web socket was connected.
  const Connected({this.healthCheckInfo});

  /// Health check info on the websocket connection.
  final HealthCheckInfo? healthCheckInfo;

  @override
  List<Object?> get props => [healthCheckInfo];
}

/// The web socket is disconnecting.
final class Disconnecting extends WebSocketConnectionState {
  /// The web socket is disconnecting. [source] contains more info about the source of the event.
  const Disconnecting({required this.source});

  /// Contains more info about the source of the event.
  final DisconnectionSource source;

  @override
  List<Object?> get props => [source];
}

/// The web socket is not connected. Contains the source/reason why the disconnection has happened.
final class Disconnected extends WebSocketConnectionState {
  /// The web socket is not connected. Contains the source/reason why the disconnection has happened.
  const Disconnected({required this.source});

  /// Provides additional information about the source of disconnecting.
  final DisconnectionSource source;

  @override
  List<Object?> get props => [source];
}

/// Provides additional information about the source of disconnecting.
sealed class DisconnectionSource extends Equatable {
  const DisconnectionSource();

  factory DisconnectionSource.userInitiated() => const UserInitiated();
  factory DisconnectionSource.serverInitiated({ClientException? error}) =>
      ServerInitiated(error: error);
  factory DisconnectionSource.systemInitiated() => const SystemInitiated();
  factory DisconnectionSource.noPongReceived() => const NoPongReceived();

  /// Returns the underlaying error if connection cut was initiated by the server.
  ClientException? get serverError =>
      this is ServerInitiated ? (this as ServerInitiated).error : null;

  @override
  List<Object?> get props => [];
}

/// A user initiated web socket disconnecting.
final class UserInitiated extends DisconnectionSource {
  /// A user initiated web socket disconnecting.
  const UserInitiated();
}

/// A server initiated web socket disconnecting, an optional error object is provided.
final class ServerInitiated extends DisconnectionSource {
  /// A server initiated web socket disconnecting, an optional error object is provided.
  const ServerInitiated({this.error});

  /// The error that caused the disconnection.
  final ClientException? error;

  @override
  List<Object?> get props => [error];

  bool get isAutomaticReconnectionEnabled {
    if (error case final WebSocketEngineException webSocketEngineException) {
      if (webSocketEngineException.code ==
          WebSocketEngineException.stopErrorCode) {
        return false;
      }
    }

    return true;
  }
}

/// The system initiated web socket disconnecting.
final class SystemInitiated extends DisconnectionSource {
  /// The system initiated web socket disconnecting.
  const SystemInitiated();
}

/// [WebSocketPingController] didn't get a pong response.
final class NoPongReceived extends DisconnectionSource {
  /// [WebSocketPingController] didn't get a pong response.
  const NoPongReceived();
}
