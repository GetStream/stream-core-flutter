import 'package:meta/meta.dart';

import 'stream_log_config.dart';
import 'stream_log_filter.dart';
import 'stream_log_handler.dart';
import 'stream_log_priority.dart';
import 'stream_log_record.dart';

/// Builds a log message on demand.
///
/// Called only once a record is known to be wanted, so an interpolation this expensive is never
/// paid for by a record that is dropped.
typedef StreamLogMessage = String Function();

/// Writes log records under a tag.
///
/// Holding one costs nothing and it can be created anywhere — a field, a constructor, or a
/// top-level `final` in a file with no class at all:
///
/// ```dart
/// final _log = StreamLogger('SF:SdpEditor');
///
/// String editSdp(String sdp) {
///   _log.d(() => 'rewriting $sdp');
///   ...
/// }
/// ```
///
/// Where records go is resolved when a record is written, not when the logger is created, so a
/// logger built at class-load picks up whatever the app installs later:
///
/// ```dart
/// StreamLogger.handler = const StreamLogHandler.console();
/// StreamLogger.priority = StreamLogPriority.debug;
/// ```
///
/// Records go to one place, so routing two SDKs apart is a matter of a [StreamLogHandler] reading
/// [StreamLogRecord.tag] rather than of finding every component that had to be handed something.
/// For the exception, see [StreamLogger.detached].
final class StreamLogger {
  /// Creates a [StreamLogger] writing under [tag] to whatever the app has installed.
  const StreamLogger(this.tag) : _handler = null, _filter = null;

  /// Creates a [StreamLogger] that ignores what the app has installed.
  ///
  /// Records go to the given handler and are gated by the given filter alone, so a detached logger
  /// neither reads nor disturbs [StreamLogger.handler]. Use one to capture a component's records in
  /// a test, or to hold a subsystem to its own threshold and destination:
  ///
  /// ```dart
  /// final _log = StreamLogger.detached(
  ///   'SF:Upload',
  ///   handler: const StreamLogHandler.console(),
  ///   filter: const StreamLogFilter.minPriority(StreamLogPriority.debug),
  /// );
  /// ```
  ///
  /// A priority of its own is a [StreamLogFilter.minPriority], which is why there is no separate one.
  /// [filter] defaults to admitting [StreamLogPriority.warning] and above — unlike the ambient one,
  /// which admits nothing until an app names a priority, since a detached logger was handed its
  /// destination and so has already been asked for. Pass [StreamLogFilter.always] to leave the
  /// decision entirely to the handler.
  const StreamLogger.detached(
    this.tag, {
    required StreamLogHandler this._handler,
    StreamLogFilter this._filter = const .minPriority(.warning),
  });

  // Null means the ambient one, read when a record is written rather than when this was built.
  final StreamLogHandler? _handler;
  final StreamLogFilter? _filter;

  /// The name records from this logger carry.
  ///
  /// Conventionally an SDK prefix and a component, such as `SC:WsClient`, so records from several
  /// Stream SDKs stay apart in one log and a prefix can select a subsystem.
  ///
  /// See also:
  ///
  ///  * [StreamLogFilter.prefix], which turns this convention into a threshold per subsystem.
  final String tag;

  static StreamLogHandler _handlerOrDefault = StreamLogHandler.silent;
  static StreamLogFilter _filterOrDefault = _closed;
  // Admits nothing, which is where an app that has not asked for records starts.
  static const _closed = StreamLogFilter.minPriority(StreamLogPriority.none);

  // The one question the write path asks. `priority` and `filter` are two ways of describing it,
  // which is why installing either replaces what the other left behind.
  static bool _decide(StreamLogFilter filter, StreamLogPriority priority, String tag) {
    // A threshold rather than a severity: comparing it against itself would otherwise admit the one
    // record that shutting logging down cannot silence.
    if (priority == StreamLogPriority.none) return false;
    return filter.isLoggable(priority, tag);
  }

  /// Installs where every record goes, other than those from a [StreamLogger.detached] logger.
  ///
  /// A destination on its own reports nothing: name a [priority] beside it, or hand both to
  /// [configure] at once. Setting it applies to loggers that already exist, including any built at
  /// class-load, because a logger resolves this when it writes rather than when it was created.
  ///
  /// ```dart
  /// StreamLogger.handler = const StreamLogHandler.console();
  /// StreamLogger.priority = StreamLogPriority.warning;
  /// ```
  ///
  /// Write-only, so nothing can come to depend on what happens to be installed. Consider
  /// [StreamLogHandler.composite] to send records to more than one place.
  static set handler(StreamLogHandler handler) => _handlerOrDefault = handler;

  /// Installs the lowest priority worth building a record for.
  ///
  /// Nothing is admitted until this is named, so an SDK stays silent in an app that has not asked
  /// for records, and a record it rejects is never built:
  ///
  /// ```dart
  /// StreamLogger.priority = StreamLogPriority.debug;
  /// ```
  ///
  /// Shorthand for a [StreamLogFilter.minPriority], so this and [filter] are one setting: whichever
  /// is written last decides.
  static set priority(StreamLogPriority priority) => filter = .minPriority(priority);

  /// Installs which records are built at all, for a rule [priority] cannot express.
  ///
  /// ```dart
  /// StreamLogger.filter = const StreamLogFilter.prefix(
  ///   {'SC:Ws': StreamLogPriority.verbose},
  ///   otherwise: StreamLogPriority.warning,
  /// );
  /// ```
  static set filter(StreamLogFilter filter) => _filterOrDefault = filter;

  /// Installs [config] in one step, or leaves the logger untouched where it is null.
  ///
  /// What a product client calls with whatever its own config was given, so that an app running
  /// two Stream SDKs gets the same answer from both, and neither decides logging for an app that
  /// never asked:
  ///
  /// ```dart
  /// StreamLogger.configure(config.logging);
  /// ```
  ///
  /// A config replaces both settings outright, so anything installed through [filter] before this
  /// is lost — including to a config that named only a [priority]. Put the rule in
  /// [StreamLogConfig.filter] instead, where a client carries it rather than flattening it.
  ///
  /// One logger serves the process, so this decides logging for every Stream SDK in it, not only
  /// the one whose config it came from, and two clients configured differently settle on whichever
  /// was constructed last. An app wanting one SDK's records and not another's says so by the prefix
  /// their tags carry:
  ///
  /// ```dart
  /// StreamLogConfig(
  ///   filter: StreamLogFilter.prefix(
  ///     {'SF:': StreamLogPriority.debug},
  ///     otherwise: StreamLogPriority.none,
  ///   ),
  /// )
  /// ```
  static void configure(StreamLogConfig? config) {
    if (config == null) return;

    _handlerOrDefault = config.handler;
    _filterOrDefault = config.filter ?? .minPriority(config.priority);
  }

  /// Puts [handler] and [priority] back to what they were before anything was installed.
  ///
  /// What an app installs is process-wide, so a test that installs a handler and leaves it there
  /// changes what every later test sees. Restoring by hand means naming the defaults, which a
  /// write-only setter gives no way to read:
  ///
  /// ```dart
  /// tearDown(StreamLogger.reset);
  /// ```
  @visibleForTesting
  static void reset() {
    _handlerOrDefault = StreamLogHandler.silent;
    _filterOrDefault = _closed;
  }

  /// Whether a record at [priority] would be kept by both the filter and the handler.
  ///
  /// Records are already gated, so this is only worth calling to guard a message that is
  /// expensive to build beyond its interpolation:
  ///
  /// ```dart
  /// if (_log.isLoggable(StreamLogPriority.verbose)) _log.v(() => describe(everyParticipant));
  /// ```
  bool isLoggable(StreamLogPriority priority) => _decide(_filter ?? _filterOrDefault, priority, tag);

  /// Writes a [StreamLogPriority.verbose] record.
  void v(
    StreamLogMessage message, {
    Object? error,
    StackTrace? stackTrace,
  }) => log(
    StreamLogPriority.verbose,
    message,
    error: error,
    stackTrace: stackTrace,
  );

  /// Writes a [StreamLogPriority.debug] record.
  void d(
    StreamLogMessage message, {
    Object? error,
    StackTrace? stackTrace,
  }) => log(
    StreamLogPriority.debug,
    message,
    error: error,
    stackTrace: stackTrace,
  );

  /// Writes a [StreamLogPriority.info] record.
  void i(
    StreamLogMessage message, {
    Object? error,
    StackTrace? stackTrace,
  }) => log(
    StreamLogPriority.info,
    message,
    error: error,
    stackTrace: stackTrace,
  );

  /// Writes a [StreamLogPriority.warning] record.
  void w(
    StreamLogMessage message, {
    Object? error,
    StackTrace? stackTrace,
  }) => log(
    StreamLogPriority.warning,
    message,
    error: error,
    stackTrace: stackTrace,
  );

  /// Writes a [StreamLogPriority.error] record.
  void e(
    StreamLogMessage message, {
    Object? error,
    StackTrace? stackTrace,
  }) => log(
    StreamLogPriority.error,
    message,
    error: error,
    stackTrace: stackTrace,
  );

  /// Writes a record at [priority].
  ///
  /// [message] is called only if the record is kept. [error] and [stackTrace] carry the cause
  /// when the record describes a failure.
  void log(
    StreamLogPriority priority,
    StreamLogMessage message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!isLoggable(priority)) return;

    final record = StreamLogRecord(
      priority: priority,
      tag: tag,
      message: message(),
      error: error,
      stackTrace: stackTrace,
    );

    return (_handler ?? _handlerOrDefault).handle(record);
  }
}
