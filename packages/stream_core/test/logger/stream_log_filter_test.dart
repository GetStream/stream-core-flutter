import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

import '../helpers/logger.dart';

void main() {
  group('StreamLogFilter.minPriority', () {
    test('admits records at the level or above, whatever the tag', () {
      const filter = StreamLogFilter.minPriority(StreamLogPriority.warning);

      expect(filter.isLoggable(StreamLogPriority.debug, 'SC:Anything'), isFalse);
      expect(filter.isLoggable(StreamLogPriority.warning, 'SC:Anything'), isTrue);
      expect(filter.isLoggable(StreamLogPriority.error, 'SF:Something'), isTrue);
    });
  });

  group('StreamLogFilter.prefix', () {
    test('holds a matching tag to its own threshold', () {
      const filter = StreamLogFilter.prefix({'SC:Ws': StreamLogPriority.verbose});

      expect(filter.isLoggable(StreamLogPriority.verbose, 'SC:WsClient'), isTrue);
      expect(filter.isLoggable(StreamLogPriority.verbose, 'SC:Http'), isFalse);
    });

    test('holds everything else to `otherwise`', () {
      const filter = StreamLogFilter.prefix(
        {'SC:Ws': StreamLogPriority.verbose},
        otherwise: StreamLogPriority.error,
      );

      expect(filter.isLoggable(StreamLogPriority.warning, 'SC:Http'), isFalse);
      expect(filter.isLoggable(StreamLogPriority.error, 'SC:Http'), isTrue);
    });

    test('lets the longest prefix win, so a broad rule can be narrowed', () {
      const filter = StreamLogFilter.prefix({
        'SC:': StreamLogPriority.verbose,
        'SC:WsHealth': StreamLogPriority.warning,
      });

      expect(filter.isLoggable(StreamLogPriority.verbose, 'SC:WsClient'), isTrue);
      expect(filter.isLoggable(StreamLogPriority.verbose, 'SC:WsHealth'), isFalse);
      expect(filter.isLoggable(StreamLogPriority.warning, 'SC:WsHealth'), isTrue);
    });

    test('is independent of the order the rules were written in', () {
      const broadFirst = StreamLogFilter.prefix({
        'SC:': StreamLogPriority.verbose,
        'SC:WsHealth': StreamLogPriority.warning,
      });
      const narrowFirst = StreamLogFilter.prefix({
        'SC:WsHealth': StreamLogPriority.warning,
        'SC:': StreamLogPriority.verbose,
      });

      expect(
        broadFirst.isLoggable(StreamLogPriority.verbose, 'SC:WsHealth'),
        narrowFirst.isLoggable(StreamLogPriority.verbose, 'SC:WsHealth'),
      );
    });

    test('gates a logger before its message is built', () {
      var built = 0;
      final handler = RecordingLogHandler();
      const logger = StreamLogger('SC:WsHealth');

      withStreamLogger(
        handler: handler,
        filter: const StreamLogFilter.prefix({'SC:WsHealth': StreamLogPriority.warning}),
        () => logger.v(() => 'ping ${built++}'),
      );

      expect(built, 0);
      expect(handler.records, isEmpty);
    });
  });

  group('StreamLogFilter.always', () {
    test('leaves the decision to the handler', () {
      const filter = StreamLogFilter.always();

      expect(filter.isLoggable(StreamLogPriority.verbose, 'SC:Anything'), isTrue);
    });
  });
}
