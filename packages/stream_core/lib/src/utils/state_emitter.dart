import 'dart:async';

import 'package:rxdart/rxdart.dart';

import 'shared_emitter.dart';

/// A state-aware emitter that maintains the current value and emits state changes.
///
/// Extends [SharedEmitter] with state management capabilities, allowing access to
/// the current value, error state, and providing a [ValueStream] for reactive programming.
/// Unlike regular emitters, state emitters always have a current value (after initialization)
/// and new subscribers immediately receive the current state.
abstract interface class StateEmitter<T> implements SharedEmitter<T> {
  /// The stream of state changes as a [ValueStream].
  ///
  /// A [ValueStream] is a special stream that always has a current value available
  /// and provides immediate access to the latest emitted value.
  ///
  /// Returns a [ValueStream] of type [T].
  @override
  ValueStream<T> get stream;

  /// The current value of the state.
  ///
  /// Throws a [StateError] if no value has been emitted yet or if the state is in an error state.
  ///
  /// Returns the current state value of type [T].
  T get value;

  /// The current value of the state, or `null` if no value is available.
  ///
  /// This is a safe alternative to [value] that returns `null` instead of throwing
  /// when no value is available.
  ///
  /// Returns the current state value or `null`.
  T? get valueOrNull;

  /// Whether the state emitter currently has a value.
  ///
  /// Returns `true` if a value has been emitted and is available, `false` otherwise.
  bool get hasValue;

  /// The current error of the state.
  ///
  /// Throws a [StateError] if the state is not in an error state.
  ///
  /// Returns the current error object.
  Object get error;

  /// The current error of the state, or `null` if no error is present.
  ///
  /// This is a safe alternative to [error] that returns `null` instead of throwing
  /// when no error is present.
  ///
  /// Returns the current error object or `null`.
  Object? get errorOrNull;

  /// Whether the state emitter currently has an error.
  ///
  /// Returns `true` if the state is in an error condition, `false` otherwise.
  bool get hasError;
}

/// A mutable state emitter that allows updating the current state value.
///
/// Combines the capabilities of [StateEmitter] and [MutableSharedEmitter] to provide
/// both state management and the ability to emit new values. The emitter maintains
/// the current state and notifies listeners when the state changes.
///
/// Example usage:
/// ```dart
/// final stateEmitter = MutableStateEmitter<int>(0);
///
/// stateEmitter.listen((value) {
///   print('State changed to: $value');
/// });
///
/// stateEmitter.value = 42; // Triggers listener with value 42
/// print(stateEmitter.value); // Prints: 42
/// ```
abstract interface class MutableStateEmitter<T>
    implements StateEmitter<T>, MutableSharedEmitter<T> {
  /// Creates a new [MutableStateEmitter] with the given [initialValue].
  ///
  /// When [sync] is `true`, state changes are emitted synchronously.
  factory MutableStateEmitter(
    T initialValue, {
    bool sync,
  }) = StateEmitterImpl<T>;

  /// Sets the current state value.
  ///
  /// This is equivalent to calling [emit] with the new value.
  /// Listeners will be notified of the state change if the new value
  /// is different from the current value.
  set value(T newValue);
}

/// The default implementation of [MutableStateEmitter] using a [BehaviorSubject].
///
/// This implementation uses RxDart's [BehaviorSubject] to maintain state and emit
/// changes to subscribers. The behavior subject ensures that new subscribers
/// immediately receive the current state value.
///
/// The emitter only emits new values when they differ from the current value,
/// preventing unnecessary notifications for identical state updates.
///
/// Example:
/// ```dart
/// final emitter = StateEmitterImpl<String>('initial');
///
/// emitter.listen((value) {
///   print('State: $value');
/// }); // Immediately prints: State: initial
///
/// emitter.value = 'updated'; // Prints: State: updated
/// emitter.value = 'updated'; // No output (same value)
/// ```
class StateEmitterImpl<T> implements MutableStateEmitter<T> {
  /// Creates a new instance of [StateEmitterImpl].
  StateEmitterImpl(
    T initialValue, {
    bool sync = false,
  }) : _state = BehaviorSubject<T>.seeded(initialValue, sync: sync);

  final BehaviorSubject<T> _state;

  @override
  ValueStream<T> get stream => _state.stream;

  @override
  T get value => _state.value;

  @override
  set value(T newValue) => emit(newValue);

  @override
  bool get hasValue => _state.hasValue;

  @override
  T? get valueOrNull => _state.valueOrNull;

  @override
  Object get error => _state.error;

  @override
  Object? get errorOrNull => _state.errorOrNull;

  @override
  bool get hasError => _state.hasError;

  @override
  void emit(T newValue) {
    if (value == newValue) return;
    _state.add(newValue);
  }

  @override
  bool tryEmit(T value) {
    if (_state.isClosed) return false;

    emit(value);
    return true;
  }

  @override
  Future<E> waitFor<E extends T>({Duration? timeLimit}) {
    final future = _state.whereType<E>().first;
    if (timeLimit == null) return future;

    return future.timeout(timeLimit);
  }

  @override
  StreamSubscription<E> on<E extends T>(
    void Function(E event) onEvent,
  ) {
    return _state.whereType<E>().listen(onEvent);
  }

  @override
  Future<T> firstWhere(
    bool Function(T element) test, {
    T Function()? orElse,
  }) {
    return _state.firstWhere(test, orElse: orElse);
  }

  @override
  StreamSubscription<T> listen(
    void Function(T value)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _state.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  Future<dynamic> close() => _state.close();
}
