import 'dart:async';

import 'package:rxdart/rxdart.dart';

/// A read-only emitter that allows listening for events of type [T].
///
/// Listeners can subscribe to receive events, wait for specific event types,
/// and register handlers for certain event types. The emitter supports
/// type filtering, allowing listeners to only receive events of a specific
/// subtype of [T].
///
/// See also:
/// - [MutableSharedEmitter] for the mutable interface that allows emitting events.
abstract interface class SharedEmitter<T> {
  /// The stream of events emitted by this emitter.
  ///
  /// Returns a [Stream] that emits events of type [T].
  Stream<T> get stream;

  /// Waits for an event of type [E] to be emitted within the specified [timeLimit].
  ///
  /// If such an event is emitted, it is returned. If the time limit
  /// is exceeded without receiving the event, a [TimeoutException] is thrown.
  ///
  /// Returns a [Future] that completes with the first event of type [E].
  Future<E> waitFor<E extends T>({Duration? timeLimit});

  /// Registers a handler [onEvent] that will be invoked whenever an event of type [E] is emitted.
  ///
  /// Returns a [StreamSubscription] that can be used to manage the subscription.
  StreamSubscription<E> on<E extends T>(
    void Function(E event) onEvent,
  );

  /// Returns the first element that satisfies the given [test].
  ///
  /// If no such element is found and [orElse] is provided, calls [orElse] and returns its result.
  /// If no element is found and [orElse] is not provided, throws a [StateError].
  ///
  /// Returns a [Future] that completes with the first matching element.
  Future<T> firstWhere(
    bool Function(T element) test, {
    T Function()? orElse,
  });

  /// Subscribes to the emitter to receive events of type [T].
  ///
  /// The [onData] callback is invoked for each emitted value.
  /// Optional callbacks for [onError], [onDone], and [cancelOnError] can also be provided.
  ///
  /// Returns a [StreamSubscription] that can be used to manage the subscription.
  StreamSubscription<T> listen(
    void Function(T value)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  });
}

/// A mutable emitter that allows emitting events of type [T] to multiple listeners.
///
/// Listeners can subscribe to receive events, wait for specific event types,
/// and register handlers for certain event types. The emitter supports
/// type filtering, allowing listeners to only receive events of a specific
/// subtype of [T].
///
/// The emitter can be closed to release resources, after which no further
/// events can be emitted or listened to.
///
/// Example usage:
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
/// Make sure to call [close] when the emitter is no longer needed
/// to avoid memory leaks.
///
/// See also:
/// - [SharedEmitter] for the read-only interface.
abstract interface class MutableSharedEmitter<T> extends SharedEmitter<T> {
  /// Creates a new instance of [MutableSharedEmitter].
  ///
  /// When [replay] is greater than 0, the emitter will replay the last [replay] events
  /// to new subscribers. When [sync] is `true`, events are emitted synchronously.
  factory MutableSharedEmitter({
    int replay,
    bool sync,
  }) = SharedEmitterImpl<T>;

  /// Emits the [value] to the listeners.
  void emit(T value);

  /// Attempts to emit the [value] to the listeners.
  ///
  /// This method is similar to [emit], but does not throw exceptions
  /// if the emitter is closed.
  ///
  /// Returns `true` if the value was successfully emitted, `false` otherwise.
  bool tryEmit(T value);

  /// Closes the emitter and releases all resources.
  ///
  /// No further events can be emitted or listened to after calling this method.
  ///
  /// Returns a [Future] that completes when the emitter is fully closed.
  Future<dynamic> close();
}

/// The default implementation of [MutableSharedEmitter] using RxDart subjects.
///
/// This implementation supports synchronous or asynchronous event emission
/// and can optionally replay recent events to new subscribers. Uses [PublishSubject]
/// for normal operation or [ReplaySubject] when replay functionality is needed.
///
/// Example:
/// ```dart
/// final emitter = MutableSharedEmitter<int>();
///
/// emitter.on<int>((value) {
///   print('Received: $value');
/// });
///
/// emitter.emit(42); // Will emit 42 to all listeners
/// emitter.emit(10); // Will emit 10 to all listeners
/// ```
///
/// For replay functionality:
/// ```dart
/// final replayEmitter = MutableSharedEmitter<int>(replay: 2);
/// replayEmitter.emit(1);
/// replayEmitter.emit(2);
///
/// // New subscribers will immediately receive the last 2 values (1, 2)
/// replayEmitter.listen((value) => print(value));
/// ```
///
/// Make sure to call [close] when done to avoid memory leaks.
///
/// See also:
/// - [MutableSharedEmitter] for the interface.
/// - [PublishSubject] from `rxdart` for the underlying stream implementation.
class SharedEmitterImpl<T> implements MutableSharedEmitter<T> {
  /// Creates a new instance of [SharedEmitterImpl].
  SharedEmitterImpl({
    int replay = 0,
    bool sync = false,
  }) : _shared = switch (replay) {
          0 => PublishSubject<T>(sync: sync),
          > 0 => ReplaySubject<T>(maxSize: replay, sync: sync),
          _ => throw ArgumentError('Replay count cannot be negative'),
        };

  final Subject<T> _shared;

  @override
  Stream<T> get stream => _shared.stream;

  @override
  void emit(T value) => _shared.add(value);

  @override
  bool tryEmit(T value) {
    if (_shared.isClosed) return false;

    emit(value);
    return true;
  }

  @override
  Future<E> waitFor<E extends T>({Duration? timeLimit}) {
    final future = _shared.whereType<E>().first;
    if (timeLimit == null) return future;

    return future.timeout(timeLimit);
  }

  @override
  StreamSubscription<E> on<E extends T>(
    void Function(E event) onEvent,
  ) {
    return _shared.whereType<E>().listen(onEvent);
  }

  @override
  Future<T> firstWhere(
    bool Function(T element) test, {
    T Function()? orElse,
  }) {
    return _shared.firstWhere(test, orElse: orElse);
  }

  @override
  StreamSubscription<T> listen(
    void Function(T value)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _shared.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  Future<dynamic> close() => _shared.close();
}
