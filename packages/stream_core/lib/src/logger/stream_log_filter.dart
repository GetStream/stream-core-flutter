import 'stream_log_priority.dart';

/// Decides which records are worth building, independently of where they end up.
///
/// A filter answers the question a handler cannot answer cheaply: whether a record is wanted at
/// all. It is consulted before the message is built, so a record it rejects costs nothing.
///
/// The default admits everything and leaves the decision to the handler, which is enough until an
/// app wants one subsystem louder than the rest:
///
/// ```dart
/// StreamLogger.root.filter = const StreamLogFilter.prefix(
///   {'SC:Ws': StreamLogPriority.verbose},
///   otherwise: StreamLogPriority.warning,
/// );
/// ```
abstract class StreamLogFilter {
  /// Creates a [StreamLogFilter].
  const StreamLogFilter();

  /// A filter admitting every record, leaving the decision to the handler.
  const factory StreamLogFilter.always() = _AlwaysFilter;

  /// A filter admitting records at [priority] or above, whatever their tag.
  const factory StreamLogFilter.minPriority(StreamLogPriority priority) = _MinPriorityFilter;

  /// A filter admitting records by the prefix of their tag.
  ///
  /// The longest prefix in [priorities] matching a tag decides it, so a broad rule can be narrowed by
  /// a longer one. A tag matching no prefix is held to [otherwise].
  ///
  /// What a record costs grows with the number of rules, so consider keeping [priorities] to the
  /// subsystems actually being tuned.
  const factory StreamLogFilter.prefix(
    Map<String, StreamLogPriority> priorities, {
    StreamLogPriority otherwise,
  }) = _PrefixFilter;

  /// Whether a record at [priority] from [tag] is worth building.
  bool isLoggable(StreamLogPriority priority, String tag);
}

final class _AlwaysFilter extends StreamLogFilter {
  const _AlwaysFilter();

  @override
  bool isLoggable(StreamLogPriority priority, String tag) => true;
}

final class _MinPriorityFilter extends StreamLogFilter {
  const _MinPriorityFilter(this.priority);

  final StreamLogPriority priority;

  @override
  bool isLoggable(StreamLogPriority priority, String tag) => priority >= this.priority;
}

final class _PrefixFilter extends StreamLogFilter {
  const _PrefixFilter(this.priorities, {this.otherwise = StreamLogPriority.warning});

  final Map<String, StreamLogPriority> priorities;
  final StreamLogPriority otherwise;

  @override
  bool isLoggable(StreamLogPriority priority, String tag) {
    var matched = otherwise;
    var matchedLength = -1;

    for (final MapEntry(key: prefix, value: threshold) in priorities.entries) {
      if (prefix.length <= matchedLength) continue;
      if (!tag.startsWith(prefix)) continue;

      matched = threshold;
      matchedLength = prefix.length;
    }

    return priority >= matched;
  }
}
