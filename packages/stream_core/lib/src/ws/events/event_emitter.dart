import '../../utils.dart';
import 'ws_event.dart';

/// A function that inspects an event and optionally resolves it into a
/// more specific or refined version of the same type.
///
/// If the resolver does not recognize or handle the event,
/// it returns `null`, allowing other resolvers to attempt resolution.
typedef EventResolver<T extends WsEvent> = T? Function(T event);

/// A read-only event emitter for WebSocket events.
///
/// Provides the same functionality as [SharedEmitter] but with type constraints
/// to ensure only [WsEvent] subtypes can be emitted. This is the read-only
/// interface used by consumers to listen for WebSocket events.
typedef EventEmitter<T extends WsEvent> = SharedEmitter<T>;

/// A mutable event emitter for WebSocket events with resolver support.
///
/// Extends [SharedEmitterImpl] to provide event resolution capabilities for WebSocket events.
/// Before emitting an event, the emitter applies a series of [EventResolver]s to inspect
/// and potentially transform the event. The first resolver that returns a non-null result
/// determines the event that will be emitted.
///
/// This is particularly useful for:
/// - Converting generic events to more specific event types
/// - Adding metadata or context to events
/// - Filtering or transforming events before emission
///
/// Example usage:
/// ```dart
/// final emitter = MutableEventEmitter<WsEvent>(
///   resolvers: [
///     (event) => event is GenericEvent ? SpecificEvent(event.data) : null,
///   ],
/// );
///
/// emitter.on<SpecificEvent>((event) {
///   // Handle SpecificEvent
/// });
///
/// emitter.emit(GenericEvent(data)); // Will be resolved to SpecificEvent
/// ```
class MutableEventEmitter<T extends WsEvent> extends SharedEmitterImpl<T> {
  /// Creates a new [MutableEventEmitter] with optional event resolvers.
  ///
  /// When [resolvers] are provided, they will be applied to each emitted event
  /// in order until one returns a non-null result. The [replay] and [sync]
  /// parameters are passed to the underlying [SharedEmitterImpl].
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
