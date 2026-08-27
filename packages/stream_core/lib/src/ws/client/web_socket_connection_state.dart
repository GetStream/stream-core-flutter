import 'package:equatable/equatable.dart';

import '../../errors.dart';
import '../../utils.dart';
import '../events/ws_event.dart';
import 'engine/web_socket_engine.dart';
import 'stream_web_socket_client.dart';

/// A state emitter for WebSocket connection state changes.
///
/// Provides read-only access to the current [WebSocketConnectionState] and allows
/// listening to state changes over time.
typedef ConnectionStateEmitter = StateEmitter<WebSocketConnectionState>;

/// A mutable state emitter for WebSocket connection state changes.
///
/// Extends [ConnectionStateEmitter] with the ability to update the current state.
/// Used internally by WebSocket client implementations to manage state transitions.
typedef MutableConnectionStateEmitter = MutableStateEmitter<WebSocketConnectionState>;

/// Represents the current state of a WebSocket connection.
///
/// A sealed class hierarchy that defines all possible states a WebSocket connection
/// can be in during its lifecycle. Each state provides specific information about
/// the connection status and determines available operations.
///
/// The connection progresses through states in this typical order:
/// 1. [Initialized] - Initial state before any connection attempt
/// 2. [Connecting] - Attempting to establish WebSocket connection
/// 3. [Authenticating] - Connection established, authenticating with server
/// 4. [Connected] - Fully connected and authenticated
/// 5. [Disconnecting] - Gracefully closing the connection
/// 6. [Disconnected] - Connection closed
///
/// States can transition directly to [Disconnected] from any other state in case
/// of errors or unexpected disconnections.
sealed class WebSocketConnectionState extends Equatable {
  const WebSocketConnectionState();

  /// Creates an [Initialized] connection state.
  ///
  /// This is the initial state before any connection attempt has been made.
  const factory WebSocketConnectionState.initialized() = Initialized;

  /// Creates a [Connecting] connection state.
  ///
  /// Indicates that a connection attempt is currently in progress.
  const factory WebSocketConnectionState.connecting() = Connecting;

  /// Creates an [Authenticating] connection state.
  ///
  /// Indicates that the WebSocket connection is established and authentication is in progress.
  const factory WebSocketConnectionState.authenticating() = Authenticating;

  /// Creates a [Connected] connection state.
  ///
  /// Indicates that the WebSocket is fully connected and authenticated with active health monitoring.
  const factory WebSocketConnectionState.connected({
    required HealthCheckInfo healthCheck,
  }) = Connected;

  /// Creates a [Disconnecting] connection state.
  ///
  /// Indicates that the connection is in the process of being gracefully closed.
  const factory WebSocketConnectionState.disconnecting({
    required DisconnectionSource source,
  }) = Disconnecting;

  /// Creates a [Disconnected] connection state.
  ///
  /// Indicates that the connection is closed and not available for communication.
  const factory WebSocketConnectionState.disconnected({
    required DisconnectionSource source,
  }) = Disconnected;

  /// Whether the connection state is in `connected` state.
  ///
  /// Returns `true` if the current state is [Connected], `false` otherwise.
  bool get isConnected => this is Connected;

  /// Whether the connection state is currently active.
  ///
  /// An active connection is any state except [Disconnected]. This includes
  /// transitional states like [Connecting], [Authenticating], and [Disconnecting].
  ///
  /// Returns `true` if the connection is not in [Disconnected] state.
  bool get isActive => this is! Disconnected;

  /// Whether automatic reconnection is enabled for this connection state.
  ///
  /// `false` for every state but [Disconnected], where it is the source's
  /// [DisconnectionSource.isReconnectable] and nothing more.
  ///
  /// {@macro webSocketReconnectionRules}
  bool get isAutomaticReconnectionEnabled => switch (this) {
    Disconnected(:final source) => source.isReconnectable,
    _ => false, // No automatic reconnection for other states
  };

  @override
  List<Object?> get props => [];
}

/// The initial state before any connection attempt has been made.
///
/// This is the default state when a [StreamWebSocketClient] is first created.
/// No network operations have been initiated and the client is ready to begin
/// a connection attempt.
final class Initialized extends WebSocketConnectionState {
  /// Creates an [Initialized] connection state.
  const Initialized();
}

/// The WebSocket is attempting to establish a connection.
///
/// This state indicates that a connection attempt is in progress. The client
/// is trying to establish a WebSocket connection to the server but has not
/// yet received confirmation that the connection is open.
final class Connecting extends WebSocketConnectionState {
  /// Creates a [Connecting] connection state.
  const Connecting();
}

/// The WebSocket connection is established and authentication is in progress.
///
/// This state indicates that the low-level WebSocket connection has been
/// successfully established, but the client is still in the process of
/// authenticating with the server before it can send and receive messages.
final class Authenticating extends WebSocketConnectionState {
  /// Creates an [Authenticating] connection state.
  const Authenticating();
}

/// The WebSocket is fully connected and authenticated.
///
/// This state indicates that the connection is fully established and the client
/// can send and receive messages. Health monitoring is active and the connection
/// is considered stable.
final class Connected extends WebSocketConnectionState {
  /// Creates a [Connected] connection state.
  const Connected({required this.healthCheck});

  /// Health check information for the active WebSocket connection.
  ///
  /// Contains details about the connection health monitoring, including
  /// connection ID and timing information used for ping/pong health checks.
  final HealthCheckInfo healthCheck;

  @override
  List<Object?> get props => [healthCheck];
}

/// The WebSocket connection is in the process of being closed.
///
/// This state indicates that a disconnection has been initiated and is in progress.
/// The connection is being gracefully closed and will transition to [Disconnected]
/// once the closure is complete.
final class Disconnecting extends WebSocketConnectionState {
  /// Creates a [Disconnecting] connection state.
  const Disconnecting({required this.source});

  /// The source that initiated the disconnection.
  ///
  /// Provides information about what triggered the disconnection, which affects
  /// whether automatic reconnection will be attempted.
  final DisconnectionSource source;

  @override
  List<Object?> get props => [source];
}

/// The WebSocket connection is closed and not available for communication.
///
/// This is the final state after a connection has been terminated. The connection
/// cannot send or receive messages and may be eligible for automatic reconnection
/// depending on the disconnection source.
final class Disconnected extends WebSocketConnectionState {
  /// Creates a [Disconnected] connection state.
  const Disconnected({required this.source});

  /// The source that caused the disconnection.
  ///
  /// Provides detailed information about why the connection was closed, including
  /// whether it was user-initiated, server-initiated, or due to system conditions.
  /// This information determines reconnection eligibility.
  final DisconnectionSource source;

  @override
  List<Object?> get props => [source];
}

/// Represents the source or cause of a WebSocket disconnection.
///
/// A sealed class hierarchy that categorizes different reasons why a WebSocket
/// connection was closed. The disconnection source determines whether automatic
/// reconnection should be attempted and provides context for error handling.
///
/// Each source type provides specific information about the disconnection cause:
/// - [UserInitiated]: Explicit disconnection requested by the application
/// - [ServerInitiated]: Server closed the connection, possibly with an error
/// - [SystemInitiated]: System-level disconnection (network, app lifecycle)
/// - [UnHealthyConnection]: Connection closed due to failed health checks
/// - [ConnectTimeout]: Attempt abandoned before the connection was established
/// - [AuthenticationFailed]: Socket opened, but its credentials never went out
sealed class DisconnectionSource extends Equatable {
  const DisconnectionSource();

  /// Creates a [UserInitiated] disconnection source.
  ///
  /// Indicates that the disconnection was explicitly requested by the application.
  /// Automatic reconnection is disabled for user-initiated disconnections.
  const factory DisconnectionSource.userInitiated() = UserInitiated;

  /// Creates a [ServerInitiated] disconnection source.
  ///
  /// Indicates that the server closed the connection, optionally with error details.
  /// Reconnection eligibility depends on the specific error type.
  const factory DisconnectionSource.serverInitiated({
    StreamException? error,
  }) = ServerInitiated;

  /// Creates a [SystemInitiated] disconnection source.
  ///
  /// Indicates that the connection was closed due to system-level conditions
  /// such as network changes or application lifecycle events.
  const factory DisconnectionSource.systemInitiated() = SystemInitiated;

  /// Creates an [UnHealthyConnection] disconnection source.
  ///
  /// Indicates that the connection was closed due to failed health checks,
  /// typically when ping requests do not receive pong responses.
  const factory DisconnectionSource.unHealthyConnection() = UnHealthyConnection;

  /// Creates a [ConnectTimeout] disconnection source.
  ///
  /// Indicates that the connection never became usable within the allotted
  /// time, so it was abandoned before it was ever established.
  const factory DisconnectionSource.connectTimeout() = ConnectTimeout;

  /// Creates an [AuthenticationFailed] disconnection source.
  ///
  /// Indicates that the connection opened but could not be authenticated, so it
  /// was closed without ever being usable.
  const factory DisconnectionSource.authenticationFailed({StreamException? error}) = AuthenticationFailed;

  /// A human-readable description of the disconnection source.
  ///
  /// Provides a descriptive string that explains why the connection was closed.
  /// This is typically used for logging and debugging purposes.
  ///
  /// Returns a descriptive string for the disconnection cause.
  String get closeReason => switch (this) {
    UserInitiated() => 'User initiated disconnection',
    ServerInitiated() => 'Server initiated disconnection',
    SystemInitiated() => 'System initiated disconnection',
    UnHealthyConnection() => 'Unhealthy connection (no pong received)',
    ConnectTimeout() => 'Timed out before the connection was established',
    AuthenticationFailed() => 'Authentication failed',
  };

  /// What closed the connection, or `null` when this source carries no cause.
  ///
  /// For a [ServerInitiated] closure this is the [StreamException] that was
  /// reported; for an [AuthenticationFailed] one, whatever prevented the
  /// credentials from going out.
  Object? get cause => switch (this) {
    ServerInitiated(:final error) => error,
    AuthenticationFailed(:final error) => error,
    UserInitiated() || SystemInitiated() || UnHealthyConnection() || ConnectTimeout() => null,
  };

  /// Whether a connection closed for this reason is worth opening again.
  ///
  /// {@template webSocketReconnectionRules}
  /// - [UserInitiated] — no, the caller asked for the connection to close.
  /// - [AuthenticationFailed] — no, credentials that never went out will not go out on a retry.
  /// - [SystemInitiated], [UnHealthyConnection], [ConnectTimeout] — yes.
  /// - [ServerInitiated] — decided by the error it carries:
  ///   - no error — yes, the closure said nothing against trying again.
  ///   - a server verdict ([StreamApiException]) — no when the server said retrying will not help
  ///     ([StreamApiException.unrecoverable]), when the token's signature or the API key is refused (configuration a
  ///     retry reproduces), or for any other 4xx. Yes for an expired token (the reconnect
  ///     authenticates with a fresh one), a token not valid yet (clock skew a later attempt can get
  ///     past), a rate limit, and 5xx.
  ///   - a transport failure ([StreamNetworkException]) — yes, except a bare normal closure
  ///     (code 1000) with no error event before it, which is the server deliberately ending the
  ///     session.
  ///   - anything else — yes for an SDK-side failure, no for credentials that could not be sent
  ///     (a retry changes nothing).
  ///
  /// Necessary, but not on its own sufficient. Whether a reconnection is then actually made is
  /// decided by `ConnectionRecoveryHandler`, which recovers only a connection that was established,
  /// and only while the network and the app lifecycle allow it — so a first connection that times
  /// out stays down, where one that times out on the way back does not.
  /// {@endtemplate}
  bool get isReconnectable => switch (this) {
    UserInitiated() => false,
    AuthenticationFailed() => false,
    SystemInitiated() => true,
    UnHealthyConnection() => true,
    ConnectTimeout() => true,
    ServerInitiated(:final error) => switch (error) {
      null => true,
      StreamApiException(unrecoverable: true) => false,
      StreamApiException(isTokenSignatureInvalid: true) => false,
      StreamApiException(isApiKeyInvalid: true) => false,
      StreamApiException(isTokenExpired: true) => true,
      StreamApiException(isTokenNotYetValid: true) => true,
      StreamApiException(isRateLimited: true) => true,
      StreamApiException(:final statusCode) => statusCode < 400 || statusCode >= 500,
      StreamNetworkException(closeCode: CloseCode.normalClosure) => false,
      StreamNetworkException() => true,
      StreamAuthenticationException() => false,
      StreamClientException() => true,
    },
  };

  @override
  List<Object?> get props => [];
}

/// A disconnection that was explicitly requested by the application.
///
/// This source indicates that the disconnection was intentionally triggered
/// by application code, typically through a call to `disconnect()`. Automatic
/// reconnection is disabled for user-initiated disconnections.
final class UserInitiated extends DisconnectionSource {
  /// Creates a [UserInitiated] disconnection source.
  const UserInitiated();
}

/// A disconnection that was initiated by the server.
///
/// This source indicates that the server closed the WebSocket connection,
/// either gracefully or due to an error condition. The optional [error]
/// provides additional context about the disconnection cause.
final class ServerInitiated extends DisconnectionSource {
  /// Creates a [ServerInitiated] disconnection source.
  const ServerInitiated({this.error});

  /// The error that caused the server to close the connection.
  ///
  /// A [StreamApiException] when the server reported why — the same payload a
  /// rejected REST call carries — and a [StreamNetworkException] describing
  /// the closure when it did not.
  final StreamException? error;

  @override
  List<Object?> get props => [error];
}

/// A disconnection that was initiated by system-level conditions.
///
/// This source indicates that the connection was closed due to system events
/// such as network connectivity changes, application lifecycle transitions,
/// or other environmental factors outside of direct user or server control.
final class SystemInitiated extends DisconnectionSource {
  /// Creates a [SystemInitiated] disconnection source.
  const SystemInitiated();
}

/// A disconnection caused by failed connection health checks.
///
/// This source indicates that the connection was closed because health
/// monitoring detected an unresponsive connection, typically when ping
/// requests do not receive corresponding pong responses within the timeout.
final class UnHealthyConnection extends DisconnectionSource {
  /// Creates an [UnHealthyConnection] disconnection source.
  const UnHealthyConnection();
}

/// A disconnection caused by the connection not becoming usable in time.
///
/// This source indicates that the connection was abandoned while it was still
/// being established, so it was never usable.
final class ConnectTimeout extends DisconnectionSource {
  /// Creates a [ConnectTimeout] disconnection source.
  const ConnectTimeout();
}

/// A disconnection caused by the connection failing to authenticate.
///
/// This source indicates that the socket opened but the credentials could not be loaded or sent, so
/// the connection was never usable. A server rejecting credentials it did receive is reported as an
/// error event instead.
final class AuthenticationFailed extends DisconnectionSource {
  /// Creates an [AuthenticationFailed] disconnection source.
  const AuthenticationFailed({this.error});

  /// The error that prevented the connection from authenticating.
  ///
  /// Usually a [StreamAuthenticationException] whose [StreamException.cause]
  /// is whatever the authenticator threw.
  final StreamException? error;

  @override
  List<Object?> get props => [error];
}
