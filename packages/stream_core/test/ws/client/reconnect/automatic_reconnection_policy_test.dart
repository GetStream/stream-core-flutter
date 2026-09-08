import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

import '../../../helpers/ws_client_tester.dart';

/// A policy with a fixed answer, for testing how policies combine.
class _Fixed implements AutomaticReconnectionPolicy {
  const _Fixed({required this._answer});

  final bool _answer;

  @override
  bool canBeReconnected() => _answer;
}

void main() {
  group('the connection state policy', () {
    /// Builds the policy over a state a test controls.
    ({WebSocketAutomaticReconnectionPolicy policy, MutableStateEmitter<WebSocketConnectionState> state}) subject() {
      final state = MutableStateEmitter<WebSocketConnectionState>(const Initialized());
      addTearDown(state.close);

      return (
        policy: WebSocketAutomaticReconnectionPolicy(connectionState: state),
        state: state,
      );
    }

    test('allows a reconnection after a drop the client did not ask for', () {
      final (:policy, :state) = subject();

      state.value = const Disconnected(source: SystemInitiated());

      expect(policy.canBeReconnected(), isTrue);
    });

    test('refuses one after a disconnect the caller asked for', () {
      final (:policy, :state) = subject();

      state.value = const Disconnected(source: UserInitiated());

      expect(policy.canBeReconnected(), isFalse);
    });

    test('refuses one while a connection is still being made', () {
      final (:policy, :state) = subject();

      // A second attempt on top of one already running would leave a socket nothing closes.
      state.value = const Connecting();
      expect(policy.canBeReconnected(), isFalse);

      state.value = const Authenticating();
      expect(policy.canBeReconnected(), isFalse);
    });
  });

  group('the internet availability policy', () {
    test('allows a reconnection while the network is up', () {
      final network = TestNetworkStateProvider();
      addTearDown(network.close);

      expect(InternetAvailabilityReconnectionPolicy(networkState: network.state).canBeReconnected(), isTrue);
    });

    test('refuses one while the network is down', () {
      final network = TestNetworkStateProvider(NetworkState.disconnected);
      addTearDown(network.close);

      // An attempt made with no network fails immediately and spends a backoff step for nothing.
      expect(InternetAvailabilityReconnectionPolicy(networkState: network.state).canBeReconnected(), isFalse);
    });

    test('refuses one before the network has been looked at', () {
      final network = TestNetworkStateProvider(NetworkState.unknown);
      addTearDown(network.close);

      // Not yet known is not the same as available, and guessing costs an attempt.
      expect(InternetAvailabilityReconnectionPolicy(networkState: network.state).canBeReconnected(), isFalse);
    });
  });

  group('the background state policy', () {
    test('allows a reconnection while the app is in use', () {
      final lifecycle = TestLifecycleStateProvider();
      addTearDown(lifecycle.close);

      expect(BackgroundStateReconnectionPolicy(appLifecycleState: lifecycle.state).canBeReconnected(), isTrue);
    });

    test('refuses one while the app is put away', () {
      final lifecycle = TestLifecycleStateProvider(LifecycleState.background);
      addTearDown(lifecycle.close);

      // Nobody is looking at it, so a connection would cost battery for nothing.
      expect(BackgroundStateReconnectionPolicy(appLifecycleState: lifecycle.state).canBeReconnected(), isFalse);
    });

    test('refuses one before the lifecycle has been looked at', () {
      final lifecycle = TestLifecycleStateProvider(LifecycleState.unknown);
      addTearDown(lifecycle.close);

      expect(BackgroundStateReconnectionPolicy(appLifecycleState: lifecycle.state).canBeReconnected(), isFalse);
    });
  });

  group('policies combined', () {
    test('with `and`, one refusal is enough to stop a reconnection', () {
      final policy = CompositeReconnectionPolicy(
        operator: Operator.and,
        policies: const [_Fixed(answer: true), _Fixed(answer: false), _Fixed(answer: true)],
      );

      expect(policy.canBeReconnected(), isFalse);
    });

    test('with `and`, every policy has to agree', () {
      final policy = CompositeReconnectionPolicy(
        operator: Operator.and,
        policies: const [_Fixed(answer: true), _Fixed(answer: true)],
      );

      expect(policy.canBeReconnected(), isTrue);
    });

    test('with `or`, one policy is enough to allow a reconnection', () {
      final policy = CompositeReconnectionPolicy(
        operator: Operator.or,
        policies: const [_Fixed(answer: false), _Fixed(answer: true)],
      );

      expect(policy.canBeReconnected(), isTrue);
    });

    test('with `or`, every policy has to refuse to stop one', () {
      final policy = CompositeReconnectionPolicy(
        operator: Operator.or,
        policies: const [_Fixed(answer: false), _Fixed(answer: false)],
      );

      expect(policy.canBeReconnected(), isFalse);
    });
  });
}
