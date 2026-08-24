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
/// A tag is a path: `SF:Ws:Engine` sits under `SF:Ws`, which sits under `SF:`. A product settles
/// its own branch through [configure], so two Stream SDKs in one app each report on their own
/// terms without either being handed a logger to pass around. For the exception, see
/// [StreamLogger.detached].
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
  /// [filter] defaults to the same threshold [StreamLogger.priority] starts at, so detaching a logger
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

  static StreamLogHandler _handlerOrDefault = StreamLogHandler.silent;
  static StreamLogFilter _filterOrDefault = const .minPriority(.warning);
  static var _handlerInstalled = false;

  // Keyed by the tag prefix a product's records share, so one product's config settles its own
  // branch and no one else's.
  static final _parents = <String, StreamLogConfig>{};

  static StreamLogConfig? _parentOf(String tag) {
    if (_parents.isEmpty) return null;

    StreamLogConfig? matched;
    var matchedLength = -1;

    for (final MapEntry(key: prefix, value: config) in _parents.entries) {
      if (prefix.length <= matchedLength) continue;
      if (!tag.startsWith(prefix)) continue;

      matched = config;
      matchedLength = prefix.length;
    }

    return matched;
  }

  static StreamLogFilter _filterFor(StreamLogConfig? parent) {
    if (parent == null) return _filterOrDefault;
    return parent.filter ?? .minPriority(parent.priority);
  }

  static StreamLogHandler _handlerFor(StreamLogConfig? parent) {
    if (parent?.handler case final handler?) return handler;
    if (_handlerInstalled) return _handlerOrDefault;
    // A branch asked for records with nowhere to put them, which would otherwise be silence.
    return parent != null ? StreamLogConfig.defaultHandler : _handlerOrDefault;
  }

  /// Installs where every record goes, other than those from a [StreamLogger.detached] logger.
  ///
  /// Everything is discarded until this is set, so an SDK is silent in an app that has not asked
  /// for records. Setting it applies to loggers that already exist, including any built at
  /// class-load, because a logger resolves this when it writes rather than when it was created.
  ///
  /// ```dart
  /// StreamLogger.handler = const StreamLogHandler.console();
  /// ```
  ///
  /// Write-only, so nothing can come to depend on what happens to be installed. Consider
  /// [StreamLogHandler.composite] to send records to more than one place.
  static set handler(StreamLogHandler handler) {
    _handlerOrDefault = handler;
    _handlerInstalled = true;
  }

  /// Installs the lowest priority worth building a record for.
  ///
  /// Defaults to [StreamLogPriority.warning], so an app that installs a handler and nothing else
  /// hears about failures and not the running commentary:
  ///
  /// ```dart
  /// StreamLogger.priority = StreamLogPriority.debug;
  /// ```
  ///
  /// Shorthand for a [StreamLogFilter.minPriority], so this and [filter] are one setting: whichever
  /// is written last decides.
  static set priority(StreamLogPriority priority) => _filterOrDefault = .minPriority(priority);

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
  /// Given a [parent], the config settles that branch of the tag tree and leaves the rest of the
  /// process alone. A product client names the prefix its own records share, so two Stream SDKs
  /// configured differently each get what they asked for rather than the one built last deciding
  /// for both:
  ///
  /// ```dart
  /// StreamLogger.configure(config.logging, parent: 'SF:');
  /// ```
  ///
  /// A branch is the narrower statement, so it decides its own tags over anything installed through
  /// [filter] or [priority], which keep the tags no branch claimed. Without a [parent] the config
  /// governs everything, replacing both outright.
  ///
  /// A config naming no handler writes wherever the app already installed one, or to
  /// [StreamLogConfig.defaultHandler] if it installed none, so asking for records never redirects
  /// them away from a destination the app chose.
  static void configure(StreamLogConfig? config, {String? parent}) {
    if (config == null) return;

    if (parent != null) {
      _parents[parent] = config;
      return;
    }

    if (config.handler case final handler?) {
      _handlerOrDefault = handler;
      _handlerInstalled = true;
    } else if (!_handlerInstalled) {
      _handlerOrDefault = StreamLogConfig.defaultHandler;
      _handlerInstalled = true;
    }

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
    _filterOrDefault = const .minPriority(.warning);
    _handlerInstalled = false;
    _parents.clear();
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
    if (_handler case final handler?) {
      if (!_filter!.isLoggable(priority, tag)) return false;
      return handler.isLoggable(priority, tag);
    }

    final parent = _parentOf(tag);
    if (!_filterFor(parent).isLoggable(priority, tag)) return false;
    return _handlerFor(parent).isLoggable(priority, tag);
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
    final handler = _handler ?? _handlerFor(_parentOf(tag));
    if (!isLoggable(priority)) return;

    final record = StreamLogRecord(
      priority: priority,
      tag: tag,
      message: message(),
      error: error,
      stackTrace: stackTrace,
    );

    return handler.handle(record);
  }
}
