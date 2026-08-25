import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

import '../helpers/logger.dart';

void main() {
  group('StreamLogFilter.minLevel', () {
    test('admits records at the level or above, whatever the tag', () {
      const filter = StreamLogFilter.minLevel(StreamLogLevel.warning);

      expect(filter.isLoggable(StreamLogLevel.debug, 'SC:Anything'), isFalse);
      expect(filter.isLoggable(StreamLogLevel.warning, 'SC:Anything'), isTrue);
      expect(filter.isLoggable(StreamLogLevel.error, 'SF:Something'), isTrue);
    });
  });

  group('StreamLogFilter.prefix', () {
    test('holds a matching tag to its own threshold', () {
      const filter = StreamLogFilter.prefix({'SC:Ws': StreamLogLevel.verbose});

      expect(filter.isLoggable(StreamLogLevel.verbose, 'SC:WsClient'), isTrue);
      expect(filter.isLoggable(StreamLogLevel.verbose, 'SC:Http'), isFalse);
    });

    test('holds everything else to `otherwise`', () {
      const filter = StreamLogFilter.prefix(
        {'SC:Ws': StreamLogLevel.verbose},
        otherwise: StreamLogLevel.error,
      );

      expect(filter.isLoggable(StreamLogLevel.warning, 'SC:Http'), isFalse);
      expect(filter.isLoggable(StreamLogLevel.error, 'SC:Http'), isTrue);
    });

    test('lets the longest prefix win, so a broad rule can be narrowed', () {
      const filter = StreamLogFilter.prefix({
        'SC:': StreamLogLevel.verbose,
        'SC:WsHealth': StreamLogLevel.warning,
      });

      expect(filter.isLoggable(StreamLogLevel.verbose, 'SC:WsClient'), isTrue);
      expect(filter.isLoggable(StreamLogLevel.verbose, 'SC:WsHealth'), isFalse);
      expect(filter.isLoggable(StreamLogLevel.warning, 'SC:WsHealth'), isTrue);
    });

    test('is independent of the order the rules were written in', () {
      const broadFirst = StreamLogFilter.prefix({
        'SC:': StreamLogLevel.verbose,
        'SC:WsHealth': StreamLogLevel.warning,
      });
      const narrowFirst = StreamLogFilter.prefix({
        'SC:WsHealth': StreamLogLevel.warning,
        'SC:': StreamLogLevel.verbose,
      });

      expect(
        broadFirst.isLoggable(StreamLogLevel.verbose, 'SC:WsHealth'),
        narrowFirst.isLoggable(StreamLogLevel.verbose, 'SC:WsHealth'),
      );
    });

    test('gates a logger before its message is built', () {
      var built = 0;
      final handler = RecordingLogHandler();
      const logger = StreamLogger('SC:WsHealth');

      withStreamLogger(
        handler: handler,
        filter: const StreamLogFilter.prefix({'SC:WsHealth': StreamLogLevel.warning}),
        () => logger.v(() => 'ping ${built++}'),
      );

      expect(built, 0);
      expect(handler.records, isEmpty);
    });
  });

  group('StreamLogFilter.always', () {
    test('leaves the decision to the handler', () {
      const filter = StreamLogFilter.always();

      expect(filter.isLoggable(StreamLogLevel.verbose, 'SC:Anything'), isTrue);
    });
  });
}
