import '../../../errors.dart';
import '../../../user/token_manager.dart';
import '../../../utils.dart';
import '../web_socket_connection_state.dart';

/// An interface that defines a policy for determining whether the WebSocket
/// should attempt an automatic reconnection based on specific conditions.
abstract interface class AutomaticReconnectionPolicy {
  /// Determines whether the WebSocket should attempt to reconnect automatically.
  ///
  /// Returns `true` if the WebSocket should attempt to reconnect, `false` otherwise.
  bool canBeReconnected();
}

/// A reconnection policy that checks if automatic reconnection is enabled
/// based on the current state of the WebSocket connection.
class WebSocketAutomaticReconnectionPolicy implements AutomaticReconnectionPolicy {
  /// Creates a [WebSocketAutomaticReconnectionPolicy].
  WebSocketAutomaticReconnectionPolicy({required this.connectionState});

  /// The WebSocket client to check for reconnection settings.
  final ConnectionStateEmitter connectionState;

  @override
  bool canBeReconnected() {
    final state = connectionState.value;
    return state.isAutomaticReconnectionEnabled;
  }
}

/// A reconnection policy that checks for internet connectivity before allowing
/// reconnection. This prevents unnecessary reconnection attempts when there's no
/// network available.
class InternetAvailabilityReconnectionPolicy implements AutomaticReconnectionPolicy {
  /// Creates an [InternetAvailabilityReconnectionPolicy].
  InternetAvailabilityReconnectionPolicy({required this.networkState});

  final NetworkStateEmitter networkState;

  @override
  bool canBeReconnected() {
    final state = networkState.value;
    return state == NetworkState.connected;
  }
}

/// A reconnection policy that checks the application's lifecycle state before
/// allowing reconnection. This prevents reconnection when the app is in the
/// background to save battery and resources.
class BackgroundStateReconnectionPolicy implements AutomaticReconnectionPolicy {
  /// Creates a [BackgroundStateReconnectionPolicy].
  BackgroundStateReconnectionPolicy({required this.appLifecycleState});

  /// The provider that gives the current app lifecycle state.
  final LifecycleStateEmitter appLifecycleState;

  @override
  bool canBeReconnected() {
    final state = appLifecycleState.value;
    return state == LifecycleState.foreground;
  }
}

/// Defines logical operators for combining multiple reconnection policies.
enum Operator {
  /// Requires ALL policies to return `true` for reconnection to be allowed.
  /// If any policy returns `false`, reconnection will be prevented.
  and,

  /// Requires ANY policy to return `true` for reconnection to be allowed.
  /// If at least one policy returns `true`, reconnection will be attempted.
  or,
}

/// A composite reconnection policy that combines multiple [policies] using a
/// logical [operator] (AND/OR). This allows for complex reconnection
/// logic by combining multiple conditions.
class CompositeReconnectionPolicy implements AutomaticReconnectionPolicy {
  /// Creates a [CompositeReconnectionPolicy].
  CompositeReconnectionPolicy({
    required this.operator,
    required this.policies,
  });

  /// The logical operator to use when combining policies
  /// ([Operator.and] or [Operator.or]).
  final Operator operator;

  /// List of reconnection policies to evaluate.
  final List<AutomaticReconnectionPolicy> policies;

  @override
  bool canBeReconnected() {
    return switch (operator) {
      Operator.and => policies.every((it) => it.canBeReconnected()),
      Operator.or => policies.any((it) => it.canBeReconnected()),
    };
  }
}

/// A policy that only reconnects when the credential can be replaced.
///
/// A connection the server closed because the token expired is worth retrying,
/// but only with a different token — and whether one can be obtained is a
/// property of the [TokenProvider] rather than of the connection. A provider
/// that always returns the same token has nothing else to offer, so reconnecting
/// would present exactly what was just refused.
///
/// Pair it with whatever expires the cached token, so the attempt this permits
/// loads a fresh one.
class TokenRefreshReconnectionPolicy implements AutomaticReconnectionPolicy {
  /// Creates a [TokenRefreshReconnectionPolicy].
  const TokenRefreshReconnectionPolicy({
    required this.connectionState,
    required this.tokenManager,
  });

  /// The connection state to read the last disconnection from.
  final ConnectionStateEmitter connectionState;

  /// The manager whose provider decides whether another token is available.
  final TokenManager tokenManager;

  @override
  bool canBeReconnected() {
    final refusedTheToken = switch (connectionState.value) {
      Disconnected(source: ServerInitiated(:final error)) => error?.apiError?.isTokenExpiredError ?? false,
      _ => false,
    };

    // Every other disconnection is somebody else's call.
    if (!refusedTheToken) return true;

    return !tokenManager.usesStaticProvider;
  }
}
