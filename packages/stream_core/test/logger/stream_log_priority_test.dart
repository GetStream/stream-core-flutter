import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

void main() {
  group('StreamLogPriority', () {
    test('runs from least to most severe', () {
      // Every threshold in the logger is a comparison against one of these, so the order they sit
      // in is what decides which records a filter admits.
      expect(StreamLogPriority.values, [
        StreamLogPriority.verbose,
        StreamLogPriority.debug,
        StreamLogPriority.info,
        StreamLogPriority.warning,
        StreamLogPriority.error,
        StreamLogPriority.none,
      ]);
    });

    test('compares consistently in every direction', () {
      for (var i = 1; i < StreamLogPriority.values.length; i++) {
        final lower = StreamLogPriority.values[i - 1];
        final higher = StreamLogPriority.values[i];

        expect(lower < higher, isTrue, reason: '$lower < $higher');
        expect(lower <= higher, isTrue, reason: '$lower <= $higher');
        expect(higher > lower, isTrue, reason: '$higher > $lower');
        expect(higher >= lower, isTrue, reason: '$higher >= $lower');
        expect(lower.compareTo(higher), isNegative, reason: '$lower before $higher');
      }
    });

    test('is neither above nor below itself', () {
      expect(StreamLogPriority.info < StreamLogPriority.info, isFalse);
      expect(StreamLogPriority.info > StreamLogPriority.info, isFalse);
      expect(StreamLogPriority.info <= StreamLogPriority.info, isTrue);
      expect(StreamLogPriority.info >= StreamLogPriority.info, isTrue);
      expect(StreamLogPriority.info.compareTo(StreamLogPriority.info), isZero);
    });

    test('sorts by severity', () {
      final shuffled = [
        StreamLogPriority.error,
        StreamLogPriority.verbose,
        StreamLogPriority.none,
        StreamLogPriority.warning,
        StreamLogPriority.debug,
        StreamLogPriority.info,
      ];
      expect(shuffled, isNot(orderedEquals(StreamLogPriority.values)));

      shuffled.sort();

      expect(shuffled, orderedEquals(StreamLogPriority.values));
    });

    test('admits nothing as a threshold, being the most severe there is', () {
      expect(StreamLogPriority.values.every((it) => it <= StreamLogPriority.none), isTrue);
    });
  });
}
