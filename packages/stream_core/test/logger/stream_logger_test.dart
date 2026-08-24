import 'package:clock/clock.dart';
import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

import '../helpers/logger.dart';

const _logger = StreamLogger('SC:Component');

void main() {
  group('StreamLogger', () {
    test('writes every record under its own tag', () {
      final handler = RecordingLogHandler();

      withStreamLogger(handler: handler, () {
        _logger
          ..v(() => 'v')
          ..d(() => 'd')
          ..i(() => 'i')
          ..w(() => 'w')
          ..e(() => 'e');
      });

      expect(handler.tags, everyElement('SC:Component'));
      expect(handler.records.map((it) => it.priority), [
        StreamLogPriority.verbose,
        StreamLogPriority.debug,
        StreamLogPriority.info,
        StreamLogPriority.warning,
        StreamLogPriority.error,
      ]);
    });

    test('is silent until an app installs a handler', () {
      var built = 0;

      final printed = capturePrints(() => _logger.e(() => 'nobody is listening ${built++}'));

      expect(printed, isEmpty);
      expect(built, 0, reason: 'a message no handler wants is never built');
    });

    test('is const constructible, so a component can hold one as a static field', () {
      // A logger needing construction would cost an allocation per component, and could not be
      // held by a top-level function.
      expect(_logger.tag, 'SC:Component');
    });

    test('resolves the handler when it writes, not when it was created', () {
      // `_logger` is a top-level const, created long before this handler existed.
      final handler = RecordingLogHandler();

      withStreamLogger(handler: handler, () => _logger.e(() => 'after configuration'));

      expect(handler.messages, ['after configuration']);
    });

    test('stops writing to a handler that has been replaced', () {
      final first = RecordingLogHandler();

      withStreamLogger(handler: first, () {});
      _logger.e(() => 'after the handler went away');

      expect(first.records, isEmpty);
    });

    test('carries the cause of a failure, whichever level reports it', () {
      final handler = RecordingLogHandler();
      final error = StateError('boom');
      final stackTrace = StackTrace.current;

      withStreamLogger(handler: handler, () {
        _logger
          ..v(() => 'v', error: error, stackTrace: stackTrace)
          ..d(() => 'd', error: error, stackTrace: stackTrace)
          ..i(() => 'i', error: error, stackTrace: stackTrace)
          ..w(() => 'w', error: error, stackTrace: stackTrace)
          ..e(() => 'e', error: error, stackTrace: stackTrace)
          ..log(StreamLogPriority.error, () => 'log', error: error, stackTrace: stackTrace);
      });

      // Each of these forwards to `log` separately, so one that dropped an argument would go
      // unnoticed if only the level it was most obviously needed for were checked.
      expect(handler.records, hasLength(6));
      expect(handler.records.map((it) => it.error), everyElement(error));
      expect(handler.records.map((it) => it.stackTrace), everyElement(stackTrace));
    });

    test('leaves the cause empty when a record describes no failure', () {
      final handler = RecordingLogHandler();

      withStreamLogger(handler: handler, () {
        _logger
          ..v(() => 'v')
          ..d(() => 'd')
          ..i(() => 'i')
          ..w(() => 'w')
          ..e(() => 'e')
          ..log(StreamLogPriority.error, () => 'log');
      });

      // A handler forwarding to a crash reporter decides what to report on whether there is a
      // cause, so a record inventing one would file an incident for a routine line.
      expect(handler.records, hasLength(6));
      expect(handler.records.map((it) => it.error), everyElement(isNull));
      expect(handler.records.map((it) => it.stackTrace), everyElement(isNull));
    });

    test('never builds a message no handler wants', () {
      var built = 0;

      withStreamLogger(
        handler: const StreamLogHandler.console(minPriority: StreamLogPriority.error),
        () => capturePrints(() => _logger.v(() => 'expensive ${built++}')),
      );

      expect(built, 0);
    });

    test('isLoggable answers for the filter and the handler together', () {
      withStreamLogger(
        handler: const StreamLogHandler.console(minPriority: StreamLogPriority.warning),
        filter: const StreamLogFilter.minPriority(StreamLogPriority.debug),
        () {
          expect(_logger.isLoggable(StreamLogPriority.verbose), isFalse, reason: 'the filter rejects it');
          expect(_logger.isLoggable(StreamLogPriority.debug), isFalse, reason: 'the handler rejects it');
          expect(_logger.isLoggable(StreamLogPriority.warning), isTrue);
        },
      );
    });
  });

  group('StreamLogger.reset', () {
    test('puts back both the handler and the priority', () {
      final installed = RecordingLogHandler();
      StreamLogger.handler = installed;
      StreamLogger.priority = StreamLogPriority.verbose;

      StreamLogger.reset();

      // A consumer restoring by hand would have to name defaults a write-only setter gives no way
      // to read, so both have to come back together.
      final printed = capturePrints(() {
        _logger
          ..d(() => 'below the default threshold')
          ..e(() => 'nowhere to go');
      });

      expect(installed.records, isEmpty, reason: 'the handler was put back');
      expect(printed, isEmpty, reason: 'nothing is installed to print with');
      expect(_logger.isLoggable(StreamLogPriority.debug), isFalse, reason: 'the priority was put back');
    });
  });

  group('StreamLogger.detached', () {
    test('writes to its own handler, ignoring what the app installed', () {
      final mine = RecordingLogHandler();
      final installed = RecordingLogHandler();
      final logger = StreamLogger.detached('SC:Detached', handler: mine);

      withStreamLogger(handler: installed, () => logger.e(() => 'to mine only'));

      expect(mine.messages, ['to mine only']);
      expect(installed.records, isEmpty);
    });

    test('writes even when the app installed nothing', () {
      final mine = RecordingLogHandler();
      final logger = StreamLogger.detached('SC:Detached', handler: mine);

      logger.e(() => 'nothing ambient is needed');

      expect(mine.messages, ['nothing ambient is needed']);
    });

    test('is held to its own threshold, not the installed one', () {
      final mine = RecordingLogHandler();
      final logger = StreamLogger.detached(
        'SC:Detached',
        handler: mine,
        filter: const StreamLogFilter.minPriority(StreamLogPriority.error),
      );

      withStreamLogger(filter: const StreamLogFilter.always(), () {
        logger
          ..w(() => 'below its own threshold, though the installed one admits it')
          ..e(() => 'at it');
      });

      expect(mine.messages, ['at it']);
    });

    test('leaves what the app installed alone', () {
      final installed = RecordingLogHandler();
      final logger = StreamLogger.detached('SC:Detached', handler: RecordingLogHandler());

      withStreamLogger(handler: installed, () {
        logger.e(() => 'mine');
        const StreamLogger('SC:Component').e(() => 'theirs');
      });

      expect(installed.messages, ['theirs']);
    });

    test('starts at the threshold an attached logger starts at', () {
      final mine = RecordingLogHandler();
      final logger = StreamLogger.detached('SC:Detached', handler: mine);

      logger
        ..d(() => 'below the default threshold')
        ..w(() => 'at it');

      // Detaching changes where a logger's records go. Left to admit everything, it would also
      // quietly change how many there are.
      expect(mine.messages, ['at it']);
    });

    test('admits everything when asked to', () {
      final mine = RecordingLogHandler();
      final logger = StreamLogger.detached(
        'SC:Detached',
        handler: mine,
        filter: const StreamLogFilter.always(),
      );

      logger.v(() => 'the quietest record there is');

      expect(mine.messages, ['the quietest record there is']);
    });

    test('is unmoved by the installed handler and priority changing after it was built', () {
      final mine = RecordingLogHandler();
      final logger = StreamLogger.detached('SC:Detached', handler: mine);

      addTearDown(() {
        StreamLogger.handler = StreamLogHandler.silent;
        StreamLogger.priority = StreamLogPriority.warning;
      });

      // An attached logger resolves both of these every time it writes, so a detached one reading
      // either would drift as an app reconfigured itself.
      for (final installed in [RecordingLogHandler(), RecordingLogHandler()]) {
        StreamLogger.handler = installed;
        StreamLogger.priority = StreamLogPriority.verbose;

        logger
          ..d(() => 'still below its own threshold')
          ..e(() => 'still its own handler');

        expect(installed.records, isEmpty, reason: 'a detached logger writes nowhere else');
      }

      expect(mine.messages, ['still its own handler', 'still its own handler']);
    });

    test('is const constructible', () {
      const logger = StreamLogger.detached('SC:Detached', handler: StreamLogHandler.console());

      expect(logger.tag, 'SC:Detached');
    });
  });

  group('StreamLogRecord', () {
    test('reads its time from the clock, so a test can pin it', () {
      final handler = RecordingLogHandler();
      final instant = DateTime.utc(2026, 8, 24, 12);

      withStreamLogger(
        handler: handler,
        () => withClock(Clock.fixed(instant), () => _logger.e(() => 'at a known time')),
      );

      expect(handler.records.single.time, instant);
    });

    test('gives every handler in a composite the same instant', () {
      final console = RecordingLogHandler();
      final crashReporter = RecordingLogHandler();

      withStreamLogger(
        handler: StreamLogHandler.composite([console, crashReporter]),
        () => _logger.e(() => 'seen by both'),
      );

      expect(console.records.single.time, crashReporter.records.single.time);
    });

    test('numbers records in the order they were created', () {
      final handler = RecordingLogHandler();

      withStreamLogger(handler: handler, () {
        _logger
          ..e(() => 'first')
          ..e(() => 'second');
      });

      final [first, second] = handler.records;
      expect(second.sequenceNumber, first.sequenceNumber + 1);
    });
  });
}
