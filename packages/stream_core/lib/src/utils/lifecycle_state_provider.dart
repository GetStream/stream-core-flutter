import 'state_emitter.dart';

/// A type alias for a state emitter that emits [LifecycleState] values.
typedef LifecycleStateEmitter = StateEmitter<LifecycleState>;

/// A utility class for monitoring application lifecycle state changes.
///
/// This interface defines the contract for an application lifecycle state provider
/// that can provide the current state of the application and a stream of state changes.
abstract interface class LifecycleStateProvider {
  /// A emitter that provides updates on the application lifecycle state.
  LifecycleStateEmitter get state;
}

/// Enum representing the lifecycle state of the application.
///
/// This enum defines two possible states for the application:
/// `foreground` and `background`.
enum LifecycleState {
  /// The lifecycle state is not known, e.g., the initial state before any checks.
  unknown,

  /// The application is in the foreground and actively being used.
  foreground,

  /// The application is in the background and not actively being used.
  background,
}
