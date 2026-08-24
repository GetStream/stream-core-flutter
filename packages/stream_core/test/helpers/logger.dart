import 'dart:async';

import 'package:stream_core/stream_core.dart';

/// A [StreamLogHandler] that keeps every record it is given, for a test to assert on.
final class RecordingLogHandler extends StreamLogHandler {
  RecordingLogHandler();

  final records = <StreamLogRecord>[];

  Iterable<String> get messages => records.map((it) => it.message);

  Iterable<String> get tags => records.map((it) => it.tag);

  @override
  void handle(StreamLogRecord record) => records.add(record);
}

/// Runs [body] with [handler] and [filter] installed as the ambient ones, restoring both after.
///
/// What an app installs is process-wide, so a test that sets it without clearing up changes what
/// every later test sees. The defaults are put back rather than whatever was there before, which
/// a write-only setter cannot read.
///
/// An asynchronous [body] is awaited before either is put back, so a handler stays installed for
/// the work it was meant to capture rather than only up to the first `await`.
///
/// Consider [StreamLogger.detached] for a component that can be handed its own logger, which
/// needs no clearing up at all.
T withStreamLogger<T>(
  T Function() body, {
  StreamLogHandler? handler,
  StreamLogFilter? filter,
}) {
  if (handler != null) StreamLogger.handler = handler;
  // A test installing a handler wants to see what reached it, so nothing is held back unless the
  // test says so.
  StreamLogger.filter = filter ?? const StreamLogFilter.always();

  final T result;
  try {
    result = body();
  } catch (_) {
    StreamLogger.reset();
    rethrow;
  }

  if (result is Future) return result.whenComplete(StreamLogger.reset) as T;

  StreamLogger.reset();
  return result;
}

/// Runs [body] and returns everything it printed.
List<String> capturePrints(void Function() body) {
  final lines = <String>[];
  final spec = ZoneSpecification(print: (_, _, _, line) => lines.add(line));
  runZoned(body, zoneSpecification: spec);
  return lines;
}
