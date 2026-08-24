/// The severity of a log record.
///
/// Ordered from least to most severe, so a threshold can be expressed by comparing a record's
/// priority against it. [none] outranks every real severity, and so admits nothing.
enum StreamLogPriority implements Comparable<StreamLogPriority> {
  /// Fine-grained detail on a hot path, such as an individual heartbeat.
  verbose(level: 2, emoji: '🔍', label: 'V'),

  /// The steps a subsystem takes, such as a connection changing state.
  debug(level: 3, emoji: '🔧', label: 'D'),

  /// A milestone worth seeing without opting into the full trace.
  info(level: 4, emoji: 'ℹ️', label: 'I'),

  /// Something recoverable that the caller may still want to act on.
  warning(level: 5, emoji: '⚠️', label: 'W'),

  /// A failure.
  error(level: 6, emoji: '🚨', label: 'E'),

  /// No severity, used as a threshold that admits nothing.
  ///
  /// Outranks every real severity, so a filter held to this admits no record. It is not a severity
  /// a record can carry: `StreamLogger.log` discards one written at this priority, which would
  /// otherwise be the only record that no threshold could suppress.
  none(level: 7, emoji: '📣', label: '*');

  const StreamLogPriority({required this.level, required this.emoji, required this.label});

  /// The rank of this priority, where a higher number is more severe.
  final int level;

  /// A glyph identifying this priority at a glance, for handlers that render one.
  final String emoji;

  /// A single-letter abbreviation of this priority, for handlers that render one.
  final String label;

  @override
  String toString() => name;

  @override
  int compareTo(StreamLogPriority other) => level.compareTo(other.level);

  /// Whether this priority is less severe than [other].
  bool operator <(StreamLogPriority other) => level < other.level;

  /// Whether this priority is no more severe than [other].
  bool operator <=(StreamLogPriority other) => level <= other.level;

  /// Whether this priority is more severe than [other].
  bool operator >(StreamLogPriority other) => level > other.level;

  /// Whether this priority is at least as severe as [other].
  bool operator >=(StreamLogPriority other) => level >= other.level;
}
