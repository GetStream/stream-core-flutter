/// The severity of a log record.
///
/// Ordered from least to most severe, so a threshold can be expressed by comparing a record's
/// level against it. [none] outranks every real severity, and so admits nothing.
enum StreamLogLevel implements Comparable<StreamLogLevel> {
  /// Fine-grained detail on a hot path, such as an individual heartbeat.
  verbose(value: 2, emoji: '🔍', label: 'V'),

  /// The steps a subsystem takes, such as a connection changing state.
  debug(value: 3, emoji: '🔧', label: 'D'),

  /// A milestone worth seeing without opting into the full trace.
  info(value: 4, emoji: 'ℹ️', label: 'I'),

  /// Something recoverable that the caller may still want to act on.
  warning(value: 5, emoji: '⚠️', label: 'W'),

  /// A failure.
  error(value: 6, emoji: '🚨', label: 'E'),

  /// A threshold that admits nothing, not a severity a record can carry.
  ///
  /// A filter held to it rejects every record, whatever its severity.
  none(value: 7, emoji: '📣', label: '*');

  const StreamLogLevel({required this.value, required this.emoji, required this.label});

  /// The rank of this level, where a higher number is more severe.
  final int value;

  /// A glyph identifying this level at a glance, for handlers that render one.
  final String emoji;

  /// A single-letter abbreviation of this level, for handlers that render one.
  final String label;

  @override
  String toString() => name;

  @override
  int compareTo(StreamLogLevel other) => value.compareTo(other.value);

  /// Whether this level is less severe than [other].
  bool operator <(StreamLogLevel other) => value < other.value;

  /// Whether this level is no more severe than [other].
  bool operator <=(StreamLogLevel other) => value <= other.value;

  /// Whether this level is more severe than [other].
  bool operator >(StreamLogLevel other) => value > other.value;

  /// Whether this level is at least as severe as [other].
  bool operator >=(StreamLogLevel other) => value >= other.value;
}
