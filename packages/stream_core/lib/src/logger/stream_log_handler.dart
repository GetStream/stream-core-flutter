import 'stream_log_filter.dart';
import 'stream_log_priority.dart';
import 'stream_log_record.dart';
import 'stream_logger.dart';

/// Receives a log record on behalf of a [StreamLogHandler.from] handler.
typedef StreamLogCallback = void Function(StreamLogRecord record);

/// Where log records go.
///
/// An app installs one on [StreamLogger.handler], or passes one to a single component. Nothing is
/// installed by default, so an SDK stays silent until asked.
///
/// [StreamLogHandler.console] covers the common case. Subclass to send records somewhere else,
/// such as a crash reporter:
///
/// ```dart
/// final class CrashReporterHandler extends StreamLogHandler {
///   const CrashReporterHandler();
///
///   @override
///   void handle(StreamLogRecord record) => Crashlytics.instance.log('$record');
/// }
/// ```
///
/// Wrap it in [StreamLogHandler.filtered] to hold it to a threshold, rather than comparing
/// priorities inside it.
abstract class StreamLogHandler {
  /// Creates a [StreamLogHandler].
  const StreamLogHandler();

  /// A handler writing records to the console.
  ///
  /// Reaches the console of whatever runs the SDK — stdout under the Dart VM, the device log
  /// under Flutter, the browser console on the web — without depending on Flutter.
  ///
  /// Android discards console output that arrives in a burst of hundreds of lines. A connection
  /// reporting itself comes nowhere near that, but a product logging heavily can, so consider
  /// handing records to `debugPrint`, which paces them to stay under the limit:
  ///
  /// ```dart
  /// StreamLogger.handler = StreamLogHandler.from((record) => debugPrint('$record'));
  /// ```
  ///
  /// Emits whatever [StreamLogger.priority] admits. Wrap in [StreamLogHandler.filtered] to hold
  /// this destination quieter than the rest.
  const factory StreamLogHandler.console() = _ConsoleHandler;

  /// A handler giving every record to each of [handlers], in order.
  ///
  /// Each decides for itself what to keep, so one composite can serve a verbose console during
  /// development and a crash reporter that only wants failures.
  const factory StreamLogHandler.composite(List<StreamLogHandler> handlers) = _CompositeHandler;

  /// A handler giving [handler] only the records [filter] admits.
  ///
  /// The way one destination is held to a threshold of its own, which is the only direction a
  /// handler can move: a filter here narrows what `StreamLogger.filter` already admitted, and
  /// cannot widen it.
  ///
  /// ```dart
  /// StreamLogHandler.composite([
  ///   fileLogger,
  ///   StreamLogHandler.filtered(
  ///     const StreamLogFilter.minPriority(StreamLogPriority.error),
  ///     const StreamLogHandler.console(),
  ///   ),
  /// ]);
  /// ```
  ///
  /// [StreamLogFilter.prefix] narrows by tag rather than priority, which is how one SDK's records
  /// are sent somewhere the rest are not.
  const factory StreamLogHandler.filtered(StreamLogFilter filter, StreamLogHandler handler) = _FilteredHandler;

  /// A handler passing every record to [callback].
  ///
  /// The shortest route into a logging facility an app already has.
  const factory StreamLogHandler.from(StreamLogCallback callback) = _CallbackHandler;

  /// A handler giving records to [handler] only in a build that runs assertions.
  ///
  /// A Flutter debug build runs them; release and profile builds do not, and neither does a
  /// plain `dart run`. Keeps a console for whoever is developing without leaving one in the
  /// build a user runs:
  ///
  /// ```dart
  /// StreamLogger.handler = const StreamLogHandler.debugOnly(StreamLogHandler.console());
  /// ```
  ///
  /// Consider wrapping only what writes somewhere a user could see, and leaving a crash reporter
  /// to receive records in every build.
  const factory StreamLogHandler.debugOnly(StreamLogHandler handler) = _DebugOnlyHandler;

  /// A handler that discards every record.
  ///
  /// What [StreamLogger.handler] is until an app installs something else.
  static const StreamLogHandler silent = _SilentHandler();

  /// Whether this handler wants a record at [priority] from [tag].
  ///
  /// Consulted before the record is built, so a handler that gates here never pays for a message
  /// it would discard. Defaults to accepting everything `StreamLogger.priority` already admitted —
  /// a handler narrows what reaches it, and cannot widen it.
  bool isLoggable(StreamLogPriority priority, String tag) => true;

  /// Takes a record this handler has accepted.
  void handle(StreamLogRecord record);
}

final class _SilentHandler extends StreamLogHandler {
  const _SilentHandler();

  @override
  bool isLoggable(StreamLogPriority priority, String tag) => false;

  @override
  void handle(StreamLogRecord record) {
    /* no-op */
  }
}

final class _ConsoleHandler extends StreamLogHandler {
  const _ConsoleHandler();

  @override
  void handle(StreamLogRecord record) {
    print('${record.time} $record');
    if (record.error case final error?) print(error);
    if (record.stackTrace case final stackTrace?) print(stackTrace);
  }
}

final class _CompositeHandler extends StreamLogHandler {
  const _CompositeHandler(this.handlers);

  final List<StreamLogHandler> handlers;

  @override
  bool isLoggable(StreamLogPriority priority, String tag) {
    return handlers.any((it) => it.isLoggable(priority, tag));
  }

  @override
  void handle(StreamLogRecord record) {
    for (final handler in handlers) {
      // Asked again, because the record only had to interest one of them to be built.
      if (handler.isLoggable(record.priority, record.tag)) handler.handle(record);
    }
  }
}

final class _DebugOnlyHandler extends StreamLogHandler {
  const _DebugOnlyHandler(this.handler);

  final StreamLogHandler handler;

  // The one thing a release build can be asked about itself without depending on Flutter: an
  // assertion that runs is a build that kept them.
  static bool get _assertionsEnabled {
    var enabled = false;
    assert(enabled = true);
    return enabled;
  }

  @override
  bool isLoggable(StreamLogPriority priority, String tag) {
    return _assertionsEnabled && handler.isLoggable(priority, tag);
  }

  @override
  void handle(StreamLogRecord record) => handler.handle(record);
}

final class _FilteredHandler extends StreamLogHandler {
  const _FilteredHandler(this.filter, this.handler);

  final StreamLogFilter filter;
  final StreamLogHandler handler;

  @override
  bool isLoggable(StreamLogPriority priority, String tag) {
    return filter.isLoggable(priority, tag) && handler.isLoggable(priority, tag);
  }

  @override
  void handle(StreamLogRecord record) => handler.handle(record);
}

final class _CallbackHandler extends StreamLogHandler {
  const _CallbackHandler(this.callback);

  final StreamLogCallback callback;

  @override
  void handle(StreamLogRecord record) => callback(record);
}
