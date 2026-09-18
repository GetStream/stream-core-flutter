import 'stream_log_filter.dart';
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
  /// A console may drop output that arrives in a burst of hundreds of lines. Consider handing
  /// records to `debugPrint` under Flutter, which paces them:
  ///
  /// ```dart
  /// StreamLogger.handler = StreamLogHandler.from((record) => debugPrint('$record'));
  /// ```
  ///
  /// Every line carries its priority and tag as text, an attached error and stack trace included,
  /// because no console takes a severity of its own.
  ///
  /// Set [emoji] to false where emoji render inconsistently, such as a CI log.
  ///
  /// Emits whatever [StreamLogger.priority] admits. Wrap in [StreamLogHandler.filtered] to hold
  /// this destination quieter than the rest.
  const factory StreamLogHandler.console({bool emoji}) = _ConsoleHandler;

  /// A handler giving every record to each of [handlers], in order.
  ///
  /// Every record reaches every one of them, so wrap any that should see less in
  /// [StreamLogHandler.filtered] — that is how one composite serves a verbose console during
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

  /// A handler that discards every record.
  ///
  /// What [StreamLogger.handler] is until an app installs something else.
  static const StreamLogHandler silent = _SilentHandler();

  /// Takes a record the filter admitted.
  ///
  /// Whether a record is worth building at all is `StreamLogger.filter`'s decision, so a handler
  /// receives whatever that admitted and discards here what it does not want. See
  /// [StreamLogHandler.filtered] for holding one destination to less than the rest.
  void handle(StreamLogRecord record);
}

final class _SilentHandler extends StreamLogHandler {
  const _SilentHandler();

  @override
  void handle(StreamLogRecord record) {
    /* no-op */
  }
}

final class _ConsoleHandler extends StreamLogHandler {
  const _ConsoleHandler({this.emoji = true});

  final bool emoji;

  // A legibility budget, not a platform limit. Counted rather than split, so a record that drew
  // its own structure keeps it.
  static const _lineLimit = 800;

  @override
  void handle(StreamLogRecord record) {
    final priority = record.priority;
    final marker = emoji ? '${priority.emoji} ' : '';
    final prefix = '${_timestamp(record.time)} $marker${priority.label}/${record.tag}:';

    // A console breaks on newlines anyway, and a line without the prefix loses its tag and time.
    for (final line in record.message.split('\n')) {
      _write(prefix, line);
    }

    // Prefixed so no line is lost to a tag filter, marked so none reads as a record of its own.
    for (final detail in [?record.error, ?record.stackTrace]) {
      for (final line in '$detail'.trimRight().split('\n')) {
        if (line.trim().isEmpty) continue;
        _write(prefix, line, marker: '↳ ');
      }
    }
  }

  static void _write(String prefix, String line, {String marker = ''}) {
    final room = _lineLimit - prefix.length - marker.length - 1;
    if (room <= 0 || line.length <= room) return print('$prefix $marker$line');

    final dropped = line.length - room;
    print('$prefix $marker${line.substring(0, room)}… $dropped more characters');
  }

  // No date: it repeats all session. The offset is what lines a record up against anything in UTC.
  static String _timestamp(DateTime time) {
    final offset = time.timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final offsetHours = offset.inHours.abs().toString().padLeft(2, '0');
    final offsetMinutes = offset.inMinutes.abs().remainder(60).toString().padLeft(2, '0');

    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    final seconds = time.second.toString().padLeft(2, '0');
    final milliseconds = time.millisecond.toString().padLeft(3, '0');

    return '$hours:$minutes:$seconds.$milliseconds$sign$offsetHours:$offsetMinutes';
  }
}

final class _CompositeHandler extends StreamLogHandler {
  const _CompositeHandler(this.handlers);

  final List<StreamLogHandler> handlers;

  @override
  void handle(StreamLogRecord record) {
    for (final handler in handlers) {
      handler.handle(record);
    }
  }
}

final class _FilteredHandler extends StreamLogHandler {
  const _FilteredHandler(this.filter, this.handler);

  final StreamLogFilter filter;
  final StreamLogHandler handler;

  @override
  void handle(StreamLogRecord record) {
    if (filter.isLoggable(record.priority, record.tag)) handler.handle(record);
  }
}

final class _CallbackHandler extends StreamLogHandler {
  const _CallbackHandler(this.callback);

  final StreamLogCallback callback;

  @override
  void handle(StreamLogRecord record) => callback(record);
}
