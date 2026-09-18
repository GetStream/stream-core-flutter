import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/src/utils/list_extensions.dart';

void main() {
  group('IterableExtensions', () {
    test('sumOf sums selected values', () {
      final values = ['one', 'three', 'seven'];

      expect(values.sumOf((value) => value.length), 13);
      expect(<String>[].sumOf((value) => value.length), 0);
    });
  });

  group('ListExtensions', () {
    test('partition splits values in one pass while preserving order', () {
      final values = [1, 2, 3, 4, 5];
      var predicateCalls = 0;

      final (even, odd) = values.partition((value) {
        predicateCalls++;
        return value.isEven;
      });

      expect(even, [2, 4]);
      expect(odd, [1, 3, 5]);
      expect(predicateCalls, values.length);
    });
  });
}
