import 'package:clock/clock.dart';

import 'stream_log_priority.dart';

/// A single log record, as a handler receives it.
///
/// Built only once a record has passed every gate, so nothing here is paid for by a record that
/// is filtered out.
///
/// Fields may be added over time. Consider implementing `StreamLogHandler` rather than depending
/// on this constructor, which is called by the SDK and not by handlers.
final class StreamLogRecord {
  /// Creates a [StreamLogRecord], stamping it with the current [time] and the next
  /// [sequenceNumber].
  StreamLogRecord({
    required this.priority,
    required this.tag,
    required this.message,
    this.error,
    this.stackTrace,
  }) : time = clock.now(),
       sequenceNumber = _sequence++;

  static var _sequence = 0;

  /// The severity of this record.
  final StreamLogPriority priority;

  /// The component this record came from.
  final String tag;

  /// What happened.
  final String message;

  /// When this record was created.
  ///
  /// The same instant for every handler that receives it, so one record does not turn up at two
  /// slightly different times in two destinations.
  final DateTime time;

  /// The position of this record in the order they were created, counting from zero.
  ///
  /// Records reaching a handler out of order, or with a gap, were reordered or dropped on the way.
  final int sequenceNumber;

  /// The cause, when this record describes a failure.
  final Object? error;

  /// Where the [error] was thrown, when it is known.
  final StackTrace? stackTrace;

  @override
  String toString() => '${priority.emoji} ${priority.label}/$tag: $message';
}
