import 'stream_log_level.dart';

/// Decides which records are worth building, independently of where they end up.
///
/// A filter answers the question a handler cannot answer cheaply: whether a record is wanted at
/// all. It is consulted before the message is built, so a record it rejects costs nothing.
///
/// The default admits everything and leaves the decision to the handler, which is enough until an
/// app wants one subsystem louder than the rest:
///
/// ```dart
/// StreamLogger.filter = const StreamLogFilter.prefix(
///   {'SC:Ws': StreamLogLevel.verbose},
///   otherwise: StreamLogLevel.warning,
/// );
/// ```
abstract class StreamLogFilter {
  /// Creates a [StreamLogFilter].
  const StreamLogFilter();

  /// A filter admitting every record, leaving the decision to the handler.
  const factory StreamLogFilter.always() = _AlwaysFilter;

  /// A filter admitting records at [level] or above, whatever their tag.
  const factory StreamLogFilter.minLevel(StreamLogLevel level) = _MinLevelFilter;

  /// A filter admitting records by the prefix of their tag.
  ///
  /// The longest prefix in [levels] matching a tag decides it, so a broad rule can be narrowed by
  /// a longer one. A tag matching no prefix is held to [otherwise].
  ///
  /// What a record costs grows with the number of rules, so consider keeping [levels] to the
  /// subsystems actually being tuned.
  const factory StreamLogFilter.prefix(
    Map<String, StreamLogLevel> levels, {
    StreamLogLevel otherwise,
  }) = _PrefixFilter;

  /// Whether a record at [level] from [tag] is worth building.
  bool isLoggable(StreamLogLevel level, String tag);
}

final class _AlwaysFilter extends StreamLogFilter {
  const _AlwaysFilter();

  @override
  bool isLoggable(StreamLogLevel level, String tag) => true;
}

final class _MinLevelFilter extends StreamLogFilter {
  const _MinLevelFilter(this.level);

  final StreamLogLevel level;

  @override
  bool isLoggable(StreamLogLevel level, String tag) {
    // `none` outranks every severity, so comparing against it would admit the records a threshold
    // of `none` exists to reject.
    if (this.level == StreamLogLevel.none) return false;
    return level >= this.level;
  }
}

final class _PrefixFilter extends StreamLogFilter {
  const _PrefixFilter(this.levels, {this.otherwise = StreamLogLevel.warning});

  final Map<String, StreamLogLevel> levels;
  final StreamLogLevel otherwise;

  @override
  bool isLoggable(StreamLogLevel level, String tag) {
    var matched = otherwise;
    var matchedLength = -1;

    for (final MapEntry(key: prefix, value: threshold) in levels.entries) {
      if (prefix.length <= matchedLength) continue;
      if (!tag.startsWith(prefix)) continue;

      matched = threshold;
      matchedLength = prefix.length;
    }

    if (matched == StreamLogLevel.none) return false;
    return level >= matched;
  }
}
