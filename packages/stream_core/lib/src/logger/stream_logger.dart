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
/// StreamLogger.root
///   ..handler = const StreamLogHandler.console()
///   ..priority = StreamLogPriority.debug;
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
  /// neither reads nor disturbs [StreamLogger.root]. Use one to capture a component's records in
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
  /// [filter] defaults to the same threshold [StreamLoggerRoot.filter] starts at, so detaching a logger
  /// changes where its records go without also changing how many there are. Pass
  /// [StreamLogFilter.always] to leave the decision entirely to the handler.
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

  /// The logger every tagged logger reads its handler and filter from.
  ///
  /// One root serves the process, so what is installed here decides logging for every Stream SDK
  /// in it:
  ///
  /// ```dart
  /// StreamLogger.root
  ///   ..handler = const StreamLogHandler.console()
  ///   ..priority = StreamLogPriority.debug;
  /// ```
  ///
  /// A destination and a threshold are two settings, and records need both: a threshold with
  /// nowhere to write is silence, and the root writes nowhere until a handler is installed.
  /// Consider [configure], which takes both at once.
  static final root = StreamLoggerRoot._();

  /// Installs [config] on the [root], or leaves it untouched where the config is null.
  ///
  /// What a product client calls with whatever its own config was given, so that an app running
  /// two Stream SDKs gets the same answer from both, and neither decides logging for an app that
  /// never asked:
  ///
  /// ```dart
  /// StreamLogger.configure(config.logging);
  /// ```
  ///
  /// Unlike setting the root's fields one at a time, a config carries a destination of its own, so
  /// one naming only a priority still reports somewhere.
  ///
  /// A config replaces both settings outright, so anything installed through [StreamLoggerRoot.filter]
  /// before this is lost — including to a config that named only a priority. Put the rule in
  /// [StreamLogConfig.filter] instead, where a client carries it rather than flattening it.
  ///
  /// One root serves the process, so this decides logging for every Stream SDK in it, not only the
  /// one whose config it came from, and two clients configured differently settle on whichever was
  /// constructed last. An app wanting one SDK's records and not another's says so by the prefix
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

    root
      ..handler = config.handler
      ..filter = config.filter ?? .minPriority(config.priority);
  }

  /// Puts the [root] back to what it was before anything was installed.
  ///
  /// What an app installs is process-wide, so a test that installs a handler and leaves it there
  /// changes what every later test sees:
  ///
  /// ```dart
  /// tearDown(StreamLogger.reset);
  /// ```
  ///
  /// Consider saving and restoring [StreamLoggerRoot.handler] instead, for a test that has to run
  /// inside one that already installed something.
  @visibleForTesting
  static void reset() {
    root
      ..handler = StreamLogHandler.silent
      ..filter = const .minPriority(.warning);
  }

  /// Whether a record at [priority] would be kept by both the filter and the handler.
  ///
  /// Records are already gated, so this is only worth calling to guard a message that is
  /// expensive to build beyond its interpolation:
  ///
  /// ```dart
  /// if (_log.isLoggable(StreamLogPriority.verbose)) _log.v(() => describe(everyParticipant));
  /// ```
  bool isLoggable(StreamLogPriority priority) {
    if (!(_filter ?? root.filter).isLoggable(priority, tag)) return false;
    return (_handler ?? root.handler).isLoggable(priority, tag);
  }

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

    return (_handler ?? root.handler).handle(record);
  }
}

/// The handler and filter every tagged [StreamLogger] resolves against.
///
/// Reached through [StreamLogger.root]; there is one for the process, and it is created there.
final class StreamLoggerRoot {
  StreamLoggerRoot._();

  /// Where every record goes, other than those from a [StreamLogger.detached] logger.
  ///
  /// Everything is discarded until this is set, so an SDK is silent in an app that has not asked
  /// for records. Setting it applies to loggers that already exist, including any built at
  /// class-load, because a logger resolves this when it writes rather than when it was created.
  ///
  /// Consider [StreamLogHandler.composite] to send records to more than one place.
  StreamLogHandler handler = StreamLogHandler.silent;

  /// Which records are built at all.
  ///
  /// Consulted before a record's message is called, so one it rejects costs nothing beyond the
  /// closure. Defaults to admitting [StreamLogPriority.warning] and above, so an app that installs
  /// a handler and nothing else hears about failures and not the running commentary.
  ///
  /// ```dart
  /// StreamLogger.root.filter = const StreamLogFilter.prefix(
  ///   {'SC:Ws': StreamLogPriority.verbose},
  ///   otherwise: StreamLogPriority.warning,
  /// );
  /// ```
  StreamLogFilter filter = const .minPriority(.warning);

  /// Sets [filter] to admit [priority] and above.
  ///
  /// ```dart
  /// StreamLogger.root.priority = StreamLogPriority.debug;
  /// ```
  ///
  /// Write-only, because a [filter] can hold each subsystem to a threshold of its own, which no
  /// single priority can report back.
  set priority(StreamLogPriority priority) => filter = .minPriority(priority);
}
