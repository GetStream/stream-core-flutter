import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

import '../helpers/logger.dart';

const _logger = StreamLogger('SC:Component');

void main() {
  group('StreamLogHandler.console', () {
    test('reaches the console, rather than only a service listener', () {
      final printed = withStreamLogger(
        handler: const StreamLogHandler.console(),
        () => capturePrints(() => _logger.e(() => 'a visible line')),
      );

      expect(printed.single, allOf(contains('a visible line'), contains('SC:Component')));
    });

    test('reports failures and stays quiet about the rest, having been given only a handler', () {
      // Deliberately not `withStreamLogger`, which opens the level up: this is about what an app
      // gets from installing a handler and nothing else.
      StreamLogger.root.handler = const StreamLogHandler.console();
      addTearDown(() {
        StreamLogger.root.handler = StreamLogHandler.silent;
        StreamLogger.root.priority = StreamLogPriority.warning;
      });

      final printed = capturePrints(() {
        _logger
          ..v(() => 'verbose')
          ..d(() => 'debug')
          ..i(() => 'info')
          ..w(() => 'warning')
          ..e(() => 'error');
      });

      expect(printed, hasLength(2));
      expect(printed.join(), allOf(contains('warning'), contains('error'), isNot(contains('info'))));
    });

    test('writes whatever the level admits, once it has been opened up', () {
      // The setup every migration guide shows, which silently dropped debug when the handler
      // carried a competing threshold of its own.
      StreamLogger.root.handler = const StreamLogHandler.console();
      StreamLogger.root.priority = StreamLogPriority.debug;
      addTearDown(() {
        StreamLogger.root.handler = StreamLogHandler.silent;
        StreamLogger.root.priority = StreamLogPriority.warning;
      });

      final printed = capturePrints(() => _logger.d(() => 'a debug line'));

      expect(printed.single, contains('a debug line'));
    });

    test('can be held quieter than the level, but never louder', () {
      final printed = withStreamLogger(
        handler: const StreamLogHandler.console(minPriority: StreamLogPriority.error),
        filter: const StreamLogFilter.minPriority(StreamLogPriority.debug),
        () => capturePrints(() {
          _logger
            ..d(() => 'debug')
            ..e(() => 'error');
        }),
      );

      expect(printed.single, contains('error'));
    });

    test('prints the cause of a failure after the message', () {
      final printed = withStreamLogger(
        handler: const StreamLogHandler.console(),
        () => capturePrints(
          () => _logger.e(() => 'failed', error: StateError('boom'), stackTrace: StackTrace.current),
        ),
      );

      expect(printed, hasLength(3));
      expect(printed[0], contains('failed'));
      expect(printed[1], contains('boom'));
    });
  });

  group('StreamLogHandler.composite', () {
    test('gives every handler the same record', () {
      final console = RecordingLogHandler();
      final crashReporter = RecordingLogHandler();

      withStreamLogger(
        handler: StreamLogHandler.composite([console, crashReporter]),
        () => _logger.w(() => 'seen by both'),
      );

      expect(console.messages, ['seen by both']);
      expect(crashReporter.messages, ['seen by both']);
    });

    test('lets each handler keep only what it wants', () {
      final everything = RecordingLogHandler();

      final printed = withStreamLogger(
        handler: StreamLogHandler.composite([
          everything,
          const StreamLogHandler.console(minPriority: StreamLogPriority.error),
        ]),
        () => capturePrints(() {
          _logger
            ..d(() => 'debug')
            ..e(() => 'error');
        }),
      );

      expect(everything.messages, ['debug', 'error']);
      expect(printed, hasLength(1));
    });

    test('builds a record any one of them wants', () {
      withStreamLogger(
        handler: StreamLogHandler.composite([
          const StreamLogHandler.console(minPriority: StreamLogPriority.none),
          RecordingLogHandler(),
        ]),
        () => expect(_logger.isLoggable(StreamLogPriority.verbose), isTrue),
      );
    });

    test('does nothing when it has no handlers', () {
      withStreamLogger(
        handler: const StreamLogHandler.composite([]),
        () {
          expect(() => _logger.e(() => 'nowhere to go'), returnsNormally);
          expect(_logger.isLoggable(StreamLogPriority.error), isFalse);
        },
      );
    });
  });

  group('StreamLogHandler.from', () {
    test('hands each record to the callback', () {
      final seen = <String>[];

      withStreamLogger(
        handler: StreamLogHandler.from((it) => seen.add('${it.priority} ${it.tag} ${it.message}')),
        () => _logger
          ..v(() => 'verbose')
          ..e(() => 'error'),
      );

      expect(seen, ['verbose SC:Component verbose', 'error SC:Component error']);
    });
  });

  group('StreamLogHandler.debugOnly', () {
    // Only half of this handler can be tested here: `dart test` runs with assertions enabled, so
    // the build where it goes quiet is by definition one this suite cannot be running in. That
    // half was checked by compiling a probe with `dart compile exe`, which strips them.

    test('passes records on where assertions are enabled, as they are under test', () {
      final inner = RecordingLogHandler();

      withStreamLogger(
        handler: StreamLogHandler.debugOnly(inner),
        () => _logger.e(() => 'seen while developing'),
      );

      expect(inner.messages, ['seen while developing']);
    });

    test('still lets the handler it wraps keep only what it wants', () {
      final printed = withStreamLogger(
        handler: const StreamLogHandler.debugOnly(
          StreamLogHandler.console(minPriority: StreamLogPriority.error),
        ),
        () => capturePrints(() {
          _logger
            ..d(() => 'debug')
            ..e(() => 'error');
        }),
      );

      expect(printed.single, contains('error'));
    });

    test('is const constructible', () {
      const handler = StreamLogHandler.debugOnly(StreamLogHandler.console());

      expect(handler, isA<StreamLogHandler>());
    });
  });

  group('StreamLogHandler.silent', () {
    test('discards every record and admits none', () {
      withStreamLogger(
        handler: StreamLogHandler.silent,
        () {
          expect(capturePrints(() => _logger.e(() => 'discarded')), isEmpty);
          expect(_logger.isLoggable(StreamLogPriority.error), isFalse);
        },
      );
    });
  });
}
