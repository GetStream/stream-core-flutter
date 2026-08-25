import 'stream_log_filter.dart';
import 'stream_log_handler.dart';
import 'stream_log_priority.dart';
import 'stream_logger.dart';

/// How much a Stream SDK reports, and where those records go.
///
/// What a product client takes in place of setting [StreamLogger.handler] and its neighbours
/// itself, so that every Stream SDK asks for logging the same way and settles it in one step:
///
/// ```dart
/// StreamFeedsClient(
///   apiKey: 'your-api-key',
///   user: user,
///   config: const FeedsConfig(
///     logging: StreamLogConfig(priority: StreamLogPriority.debug),
///   ),
/// );
/// ```
///
/// The logger is shared by every Stream SDK in a process, so a client that is given no config
/// installs nothing at all rather than deciding for the others.
class StreamLogConfig {
  /// Creates a [StreamLogConfig].
  const StreamLogConfig({
    this.priority = StreamLogPriority.warning,
    this.handler = defaultHandler,
    this.filter,
  });

  /// Where records go when a config names no handler of its own.
  static const defaultHandler = StreamLogHandler.console();

  /// The lowest priority worth reporting.
  ///
  /// [StreamLogPriority.none] silences a logger another SDK configured. Ignored where [filter] is
  /// given, which decides the same thing in more detail.
  final StreamLogPriority priority;

  /// Where records go.
  ///
  /// Compose with [defaultHandler] to keep the console alongside a handler of your own, and leave
  /// it out of the build your users run by naming it only where the app says it is developing:
  ///
  /// ```dart
  /// handler: StreamLogHandler.composite([
  ///   if (kDebugMode) StreamLogConfig.defaultHandler,
  ///   myCrashReporterHandler,
  /// ]),
  /// ```
  final StreamLogHandler handler;

  /// Which records are built at all, for a rule [priority] cannot express.
  ///
  /// Holds one subsystem to a different threshold than the rest:
  ///
  /// ```dart
  /// StreamLogConfig(
  ///   filter: StreamLogFilter.prefix(
  ///     {'SF:Ws': StreamLogPriority.verbose},
  ///     otherwise: StreamLogPriority.warning,
  ///   ),
  /// )
  /// ```
  final StreamLogFilter? filter;
}
