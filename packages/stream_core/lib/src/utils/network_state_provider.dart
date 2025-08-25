import 'state_emitter.dart';

typedef NetworkStateEmitter = StateEmitter<NetworkState>;

/// A utility class for monitoring network connectivity changes.
///
/// This interface defines the contract for a network monitor that can provide
/// the current network state and a stream of state changes.
abstract interface class NetworkStateProvider {
  /// A emitter that provides updates on the network state.
  NetworkStateEmitter get state;
}

/// Enum representing the state of network connectivity.
///
/// This enum defines two possible values to represent the state of network
/// connectivity: `connected` and `disconnected`.
enum NetworkState {
  /// Internet is available because at least one of the HEAD requests succeeded.
  connected,

  /// None of the HEAD requests succeeded. Basically, no internet.
  disconnected,
}
