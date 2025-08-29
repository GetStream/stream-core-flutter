import 'state_emitter.dart';

typedef AppLifecycleStateEmitter = StateEmitter<AppLifecycleState>;

/// A utility class for monitoring application lifecycle state changes.
///
/// This interface defines the contract for an application lifecycle state provider
/// that can provide the current state of the application and a stream of state changes.
abstract interface class AppLifecycleStateProvider {
  /// A emitter that provides updates on the application lifecycle state.
  AppLifecycleStateEmitter get state;
}

/// Enum representing the lifecycle state of the application.
///
/// This enum defines two possible states for the application:
/// `foreground` and `background`.
enum AppLifecycleState {
  foreground,

  background,
}
