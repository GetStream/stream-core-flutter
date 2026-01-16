import 'shared_emitter.dart';

/// Base interface for events that can be emitted through an [EventEmitter].
///
/// Implement this interface to create custom event types:
///
/// ```dart
/// class UserLoggedIn implements StreamEvent {
///   final String userId;
///   UserLoggedIn(this.userId);
/// }
/// ```
abstract interface class StreamEvent {}

/// A function that inspects an [event] and optionally transforms it.
///
/// Returns a transformed event if the resolver handles it, or `null` to
/// pass the event to the next resolver in the chain.
///
/// ```dart
/// final resolver = (event) {
///   if (event is GenericEvent) return SpecificEvent(event.data);
///   return null; // Let other resolvers handle it
/// };
/// ```
typedef EventResolver<T extends StreamEvent> = T? Function(T event);

/// A read-only event emitter constrained to [StreamEvent] subtypes.
///
/// Type alias for [SharedEmitter] that enforces event type safety.
///
/// See also:
/// - [MutableEventEmitter] for the mutable variant with resolver support.
typedef EventEmitter<T extends StreamEvent> = SharedEmitter<T>;

/// A mutable event emitter with resolver support for event transformation.
///
/// Extends [SharedEmitterImpl] to apply a chain of [EventResolver]s before
/// emitting events. Each resolver inspects the event and can transform it
/// into a more specific type. The first resolver to return a non-null result
/// determines the final emitted event.
///
/// ```dart
/// final emitter = MutableEventEmitter<WsEvent>(
///   resolvers: [
///     (event) => event is RawEvent ? ParsedEvent(event.data) : null,
///   ],
/// );
///
/// emitter.on<ParsedEvent>((event) {
///   print('Received parsed: ${event.data}');
/// });
///
/// emitter.emit(RawEvent(data)); // Transformed and emitted as ParsedEvent
/// ```
///
/// See also:
/// - [EventEmitter] for the read-only interface.
/// - [EventResolver] for the resolver function signature.
final class MutableEventEmitter<T extends StreamEvent> extends SharedEmitterImpl<T>
    implements MutableSharedEmitter<T> {
  /// Creates a [MutableEventEmitter] with optional event [resolvers].
  ///
  /// Resolvers are applied in order to each emitted event until one returns
  /// a non-null result. Supports synchronous or asynchronous emission via
  /// [sync], and can replay the last [replay] events to new subscribers.
  MutableEventEmitter({
    super.replay = 0,
    super.sync = false,
    Iterable<EventResolver<T>>? resolvers,
  }) : _resolvers = resolvers ?? const {};

  final Iterable<EventResolver<T>> _resolvers;

  @override
  void emit(T value) {
    for (final resolver in _resolvers) {
      final result = resolver(value);
      if (result != null) return super.emit(result);
    }

    // No resolver matched — emit the event as-is.
    return super.emit(value);
  }
}
