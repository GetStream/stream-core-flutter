import 'dart:async';

import 'package:rxdart/rxdart.dart';

import 'result.dart';
import 'shared_emitter.dart';

/// A read-only emitter that maintains and broadcasts the current state.
///
/// Similar to Kotlin's `StateFlow`, this emitter always has a current value
/// available and new subscribers immediately receive the current state.
///
/// See also:
/// - [MutableStateEmitter] for the mutable variant.
/// - [SharedEmitter] for event emission without state.
abstract interface class StateEmitter<T> implements SharedEmitter<T> {
  /// The current state value.
  T get value;
}

/// A mutable emitter that maintains and broadcasts the current state.
///
/// Extends [StateEmitter] with the ability to update the state value.
/// Listeners are notified only when the value changes (conflation).
///
/// ```dart
/// final counter = MutableStateEmitter<int>(0);
///
/// counter.listen((value) {
///   print('State changed to: $value');
/// });
///
/// counter.value = 42; // Prints: State changed to: 42
/// counter.value = 42; // No output (same value)
/// ```
///
/// See also:
/// - [StateEmitter] for the read-only interface.
/// - [MutableStateEmitterExtension] for convenience methods.
abstract interface class MutableStateEmitter<T> extends StateEmitter<T> implements MutableSharedEmitter<T> {
  /// Creates a [MutableStateEmitter] with the given [initialValue].
  ///
  /// Supports synchronous or asynchronous state emission via [sync].
  factory MutableStateEmitter(
    T initialValue, {
    bool sync,
  }) = StateEmitterImpl<T>;

  /// The current state value.
  ///
  /// Setting a value equal to the current value does nothing (conflation).
  set value(T newValue);
}

/// Default implementation of [MutableStateEmitter] using a [BehaviorSubject].
///
/// Uses RxDart's [BehaviorSubject] to maintain state. New subscribers
/// immediately receive the current value. Only emits when the value changes.
///
/// ```dart
/// final emitter = MutableStateEmitter<String>('initial');
///
/// emitter.listen((value) {
///   print('State: $value');
/// }); // Immediately prints: State: initial
///
/// emitter.value = 'updated'; // Prints: State: updated
/// emitter.value = 'updated'; // No output (same value)
/// ```
///
/// See also:
/// - [MutableStateEmitter] for the interface.
class StateEmitterImpl<T> extends StreamView<T> implements MutableStateEmitter<T> {
  /// Creates a [StateEmitterImpl] with the given [initialValue].
  ///
  /// Supports synchronous or asynchronous state emission via [sync].
  StateEmitterImpl(
    T initialValue, {
    bool sync = false,
  }) : this._(BehaviorSubject<T>.seeded(initialValue, sync: sync));

  StateEmitterImpl._(this._state) : super(_state);

  final BehaviorSubject<T> _state;

  @override
  T get value => _state.value;

  @override
  set value(T newValue) {
    if (value == newValue) return;
    _state.add(newValue);
  }

  @override
  void emit(T newValue) => value = newValue;

  @override
  bool tryEmit(T newValue) => runSafelySync(() => emit(newValue)).isSuccess;

  @override
  bool get hasListener => _state.hasListener;

  @override
  bool get isClosed => _state.isClosed;

  @override
  Future<dynamic> close() => _state.close();
}

/// Convenience methods for [MutableStateEmitter].
extension MutableStateEmitterExtension<T> on MutableStateEmitter<T> {
  /// Returns a read-only view of this emitter.
  ///
  /// Useful for exposing state to consumers who should only be able to
  /// read, not modify the value.
  ///
  /// ```dart
  /// class CounterBloc {
  ///   final _count = MutableStateEmitter<int>(0);
  ///
  ///   StateEmitter<int> get count => _count.asStateEmitter();
  ///
  ///   void increment() => _count.update((c) => c + 1);
  /// }
  /// ```
  StateEmitter<T> asStateEmitter() => this;

  /// Applies the [updater] function to the current value and sets the result.
  ///
  /// ```dart
  /// counter.update((current) => current + 1);
  /// ```
  void update(T Function(T current) updater) {
    value = updater(value);
  }

  /// Applies the [updater] function to the current value, sets the result,
  /// and returns the previous value.
  ///
  /// ```dart
  /// final previous = counter.getAndUpdate((current) => current * 2);
  /// print(previous); // 5
  /// print(counter.value); // 10
  /// ```
  T getAndUpdate(T Function(T current) updater) {
    final previous = value;
    value = updater(value);
    return previous;
  }

  /// Applies the [updater] function to the current value, sets the result,
  /// and returns the new value.
  ///
  /// ```dart
  /// final newValue = counter.updateAndGet((current) => current * 2);
  /// print(newValue); // 10
  /// ```
  T updateAndGet(T Function(T current) updater) {
    final newValue = updater(value);
    value = newValue;
    return newValue;
  }
}
