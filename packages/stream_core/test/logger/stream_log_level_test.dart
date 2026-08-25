import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

void main() {
  group('StreamLogLevel', () {
    test('runs from least to most severe', () {
      // Every threshold in the logger is a comparison against one of these, so the order they sit
      // in is what decides which records a filter admits.
      expect(StreamLogLevel.values, [
        StreamLogLevel.verbose,
        StreamLogLevel.debug,
        StreamLogLevel.info,
        StreamLogLevel.warning,
        StreamLogLevel.error,
        StreamLogLevel.none,
      ]);
    });

    test('compares consistently in every direction', () {
      for (var i = 1; i < StreamLogLevel.values.length; i++) {
        final lower = StreamLogLevel.values[i - 1];
        final higher = StreamLogLevel.values[i];

        expect(lower < higher, isTrue, reason: '$lower < $higher');
        expect(lower <= higher, isTrue, reason: '$lower <= $higher');
        expect(higher > lower, isTrue, reason: '$higher > $lower');
        expect(higher >= lower, isTrue, reason: '$higher >= $lower');
        expect(lower.compareTo(higher), isNegative, reason: '$lower before $higher');
      }
    });

    test('is neither above nor below itself', () {
      expect(StreamLogLevel.info < StreamLogLevel.info, isFalse);
      expect(StreamLogLevel.info > StreamLogLevel.info, isFalse);
      expect(StreamLogLevel.info <= StreamLogLevel.info, isTrue);
      expect(StreamLogLevel.info >= StreamLogLevel.info, isTrue);
      expect(StreamLogLevel.info.compareTo(StreamLogLevel.info), isZero);
    });

    test('sorts by severity', () {
      final shuffled = [
        StreamLogLevel.error,
        StreamLogLevel.verbose,
        StreamLogLevel.none,
        StreamLogLevel.warning,
        StreamLogLevel.debug,
        StreamLogLevel.info,
      ];
      expect(shuffled, isNot(orderedEquals(StreamLogLevel.values)));

      shuffled.sort();

      expect(shuffled, orderedEquals(StreamLogLevel.values));
    });

    test('admits nothing as a threshold, being the most severe there is', () {
      expect(StreamLogLevel.values.every((it) => it <= StreamLogLevel.none), isTrue);
    });
  });
}
