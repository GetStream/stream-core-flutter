import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/src/utils/standard.dart';

void main() {
  group('Standard', () {
    test('let transforms the receiver', () {
      expect('stream'.let((value) => value.length), 6);
    });

    test('also invokes the block and returns the receiver', () {
      final receiver = <int>[];

      final result = receiver.also((value) => value.add(1));

      expect(result, same(receiver));
      expect(receiver, [1]);
    });

    test('apply invokes the block and returns the receiver', () {
      final receiver = <int>[];

      final result = receiver.apply((value) => value.add(1));

      expect(result, same(receiver));
      expect(receiver, [1]);
    });

    test('takeIf returns the receiver only when the predicate matches', () {
      expect(2.takeIf((value) => value.isEven), 2);
      expect(1.takeIf((value) => value.isEven), isNull);
    });

    test('takeUnless returns the receiver only when the predicate does not match', () {
      expect(1.takeUnless((value) => value.isEven), 1);
      expect(2.takeUnless((value) => value.isEven), isNull);
    });
  });

  test('repeat invokes the action with each zero-based index', () {
    final indices = <int>[];

    repeat(3, indices.add);

    expect(indices, [0, 1, 2]);
  });
}
