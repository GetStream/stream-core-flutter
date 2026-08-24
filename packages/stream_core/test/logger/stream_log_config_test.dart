import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

import '../helpers/logger.dart';

const _logger = StreamLogger('SF:Component');

void main() {
  group('StreamLogger.configure', () {
    tearDown(StreamLogger.reset);

    test('leaves the logger alone when there is no config', () {
      final installed = RecordingLogHandler();
      StreamLogger.handler = installed;
      StreamLogger.priority = StreamLogPriority.verbose;

      StreamLogger.configure(null);
      _logger.d(() => 'another SDK, still heard');

      // A client the app gave no logging must not decide it for the SDK beside it.
      expect(installed.messages, ['another SDK, still heard']);
    });

    test('writes to the console, given a priority and nowhere to put it', () {
      final printed = capturePrints(() {
        StreamLogger.configure(const StreamLogConfig(priority: StreamLogPriority.debug));
        _logger.d(() => 'to the console');
      });

      expect(printed.single, contains('to the console'));
    });

    test('hears warnings, given a handler and no priority', () {
      final mine = RecordingLogHandler();

      StreamLogger.configure(StreamLogConfig(handler: mine));
      _logger
        ..d(() => 'commentary')
        ..w(() => 'worth acting on');

      expect(mine.messages, ['worth acting on']);
    });

    test('silences everything when asked for none', () {
      final mine = RecordingLogHandler();

      StreamLogger.configure(
        StreamLogConfig(priority: StreamLogPriority.none, handler: mine),
      );
      _logger.e(() => 'not even an error');

      expect(mine.records, isEmpty);
    });

    test('holds one subsystem apart from the rest, given a filter', () {
      final mine = RecordingLogHandler();

      StreamLogger.configure(
        StreamLogConfig(
          handler: mine,
          filter: const StreamLogFilter.prefix({'SF:Ws': StreamLogPriority.verbose}),
        ),
      );
      const StreamLogger('SF:Ws').v(() => 'the subsystem I turned up');
      _logger.d(() => 'the commentary I did not');

      // The filter has to survive the config that carries it: `priority` sets the same field, so a
      // config applying both would flatten the rule it was given.
      expect(mine.messages, ['the subsystem I turned up']);
    });
  });
}
