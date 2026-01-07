import 'dart:async';

import 'package:rxdart/rxdart.dart';

import 'result.dart';

/// A read-only emitter that broadcasts events to multiple listeners.
///
/// Similar to Kotlin's `SharedFlow`, this emitter allows multiple subscribers
/// to receive events of type [T]. Implements [Stream] to provide stream
/// functionality directly, allowing this emitter to be used anywhere a stream
/// is expected.
///
/// See also:
/// - [MutableSharedEmitter] for the mutable variant that allows emitting events.
/// - [SharedEmitterExtension] for convenience methods like [on] and [waitFor].
abstract interface class SharedEmitter<T> implements Stream<T> {
  /// Whether this emitter is closed.
  ///
  /// A closed emitter cannot emit new values.
  bool get isClosed;
}

/// A mutable emitter that broadcasts events to multiple listeners.
///
/// Extends [SharedEmitter] with the ability to emit events and close
/// the emitter. Listeners can subscribe to receive events, wait for specific
/// event types, and register handlers for certain event types.
///
/// ```dart
/// final emitter = MutableSharedEmitter<MyEvent>();
///
/// emitter.on<SpecificEvent>((event) {
///   // Handle SpecificEvent
/// });
///
/// emitter.emit(MyEvent());
/// ```
///
/// Call [close] when this emitter is no longer needed to release resources.
///
/// See also:
/// - [SharedEmitter] for the read-only interface.
abstract interface class MutableSharedEmitter<T> extends SharedEmitter<T> {
  /// Creates a [MutableSharedEmitter].
  ///
  /// Supports synchronous or asynchronous event emission via [sync], and
  /// can optionally replay the last [replay] events to new subscribers.
  factory MutableSharedEmitter({
    int replay,
    bool sync,
  }) = SharedEmitterImpl<T>;

  /// Emits the given [value] to all active listeners.
  void emit(T value);

  /// Attempts to emit the given [value] to all active listeners.
  ///
  /// Returns `true` if the value was successfully emitted, or `false` if
  /// emission failed for any reason (e.g., emitter is closed or an error
  /// occurred). Unlike [emit], this method never throws.
  bool tryEmit(T value);

  /// Whether this emitter has any active listeners.
  bool get hasListener;

  /// Closes this emitter, preventing any further events from being emitted.
  Future<dynamic> close();
}

/// Default implementation of [MutableSharedEmitter] using RxDart subjects.
///
/// Uses [PublishSubject] for normal operation or [ReplaySubject] when replay
/// functionality is needed. Extends [StreamView] to delegate all stream
/// operations to the underlying subject.
///
/// ```dart
/// final emitter = MutableSharedEmitter<int>();
///
/// // Can be used directly as a stream
/// emitter.where((value) => value > 10).listen((value) {
///   print('Received: $value');
/// });
///
/// emitter.emit(42);
/// ```
///
/// For replay functionality:
///
/// ```dart
/// final replayEmitter = MutableSharedEmitter<int>(replay: 2);
/// replayEmitter.emit(1);
/// replayEmitter.emit(2);
///
/// // New subscribers immediately receive the last 2 values (1, 2)
/// replayEmitter.listen(print);
/// ```
///
/// See also:
/// - [MutableSharedEmitter] for the interface.
class SharedEmitterImpl<T> extends StreamView<T>
    implements MutableSharedEmitter<T> {
  /// Creates a [SharedEmitterImpl].
  ///
  /// Supports synchronous or asynchronous event emission via [sync], and
  /// can optionally replay the last [replay] events to new subscribers.
  SharedEmitterImpl({
    int replay = 0,
    bool sync = false,
  }) : this._(_createSubject(replay, sync));

  SharedEmitterImpl._(this._shared) : super(_shared);

  static Subject<T> _createSubject<T>(int replay, bool sync) {
    return switch (replay) {
      0 => PublishSubject<T>(sync: sync),
      > 0 => ReplaySubject<T>(maxSize: replay, sync: sync),
      _ => throw ArgumentError('Replay count cannot be negative'),
    };
  }

  final Subject<T> _shared;

  @override
  void emit(T value) => _shared.add(value);

  @override
  bool tryEmit(T value) => runSafelySync(() => emit(value)).isSuccess;

  @override
  bool get hasListener => _shared.hasListener;

  @override
  bool get isClosed => _shared.isClosed;

  @override
  Future<dynamic> close() => _shared.close();
}

/// Type conversion methods for [MutableSharedEmitter].
extension MutableSharedEmitterExtension<T> on MutableSharedEmitter<T> {
  /// Returns a read-only view of this emitter.
  ///
  /// Useful for exposing this emitter to consumers who should only be able
  /// to listen, not emit.
  ///
  /// ```dart
  /// class MyService {
  ///   final _events = MutableSharedEmitter<Event>();
  ///
  ///   SharedEmitter<Event> get events => _events.asSharedEmitter();
  /// }
  /// ```
  SharedEmitter<T> asSharedEmitter() => this;
}

/// Convenience methods for [SharedEmitter] event handling.
extension SharedEmitterExtension<T> on SharedEmitter<T> {
  /// Waits for and returns the first event of type [E] emitted by this emitter.
  ///
  /// Throws a [TimeoutException] if [timeLimit] is exceeded before receiving
  /// an event of type [E].
  ///
  /// Throws a [StateError] if this emitter closes before an event of type [E]
  /// is received.
  ///
  /// ```dart
  /// final event = await emitter.waitFor<SpecificEvent>(
  ///   timeLimit: Duration(seconds: 5),
  /// );
  /// ```
  Future<E> waitFor<E extends T>({Duration? timeLimit}) {
    final future = whereType<E>().first;
    if (timeLimit == null) return future;

    return future.timeout(timeLimit);
  }

  /// Listens for events of type [E] and invokes [onEvent] for each one.
  ///
  /// ```dart
  /// emitter.on<UserLoggedIn>((event) {
  ///   print('User logged in: ${event.userId}');
  /// });
  /// ```
  StreamSubscription<E> on<E extends T>(
    void Function(E event) onEvent,
  ) {
    return whereType<E>().listen(onEvent);
  }
}
