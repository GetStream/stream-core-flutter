import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';

void main() {
  const childSize = Size(20, 20);
  const minSize = Size(48, 48);

  Widget buildSubject({
    required VoidCallback onTap,
    AlignmentGeometry alignment = Alignment.center,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    return Directionality(
      textDirection: textDirection,
      child: Align(
        alignment: Alignment.topLeft,
        child: StreamTapTargetPadding(
          minSize: minSize,
          alignment: alignment,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: SizedBox(
              width: childSize.width,
              height: childSize.height,
            ),
          ),
        ),
      ),
    );
  }

  group('layout', () {
    testWidgets('layout size grows to minSize when child is smaller', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(onTap: () {}),
      );

      final renderBox = tester.renderObject<RenderBox>(
        find.byType(StreamTapTargetPadding),
      );
      expect(renderBox.size, equals(minSize));
    });

    testWidgets('child keeps its own intrinsic size', (tester) async {
      await tester.pumpWidget(buildSubject(onTap: () {}));

      final childBox = tester.renderObject<RenderBox>(
        find.byType(GestureDetector),
      );
      expect(childBox.size, equals(childSize));
    });

    testWidgets(
      'child is positioned at topEnd in LTR (rendered top-right)',
      (tester) async {
        await tester.pumpWidget(
          buildSubject(
            onTap: () {},
            alignment: AlignmentDirectional.topEnd,
          ),
        );

        final parent = tester.getTopLeft(find.byType(StreamTapTargetPadding));
        final childTopLeft = tester.getTopLeft(find.byType(GestureDetector));
        expect(childTopLeft, equals(parent + const Offset(28, 0)));
      },
    );

    testWidgets(
      'child is positioned at topEnd in RTL (rendered top-left)',
      (tester) async {
        await tester.pumpWidget(
          buildSubject(
            onTap: () {},
            alignment: AlignmentDirectional.topEnd,
            textDirection: TextDirection.rtl,
          ),
        );

        final parent = tester.getTopLeft(find.byType(StreamTapTargetPadding));
        final childTopLeft = tester.getTopLeft(find.byType(GestureDetector));
        expect(childTopLeft, equals(parent));
      },
    );
  });

  group('hit testing', () {
    testWidgets('tap inside the visible child fires onTap', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        buildSubject(
          onTap: () => taps++,
          alignment: AlignmentDirectional.topEnd,
        ),
      );

      final childCenter = tester.getCenter(find.byType(GestureDetector));
      await tester.tapAt(childCenter);
      expect(taps, 1);
    });

    testWidgets(
      'tap in the padded region (far corner) still fires onTap',
      (tester) async {
        var taps = 0;
        await tester.pumpWidget(
          buildSubject(
            onTap: () => taps++,
            alignment: AlignmentDirectional.topEnd,
          ),
        );

        final parentRect = tester.getRect(find.byType(StreamTapTargetPadding));
        // Bottom-start corner is entirely within the 48x48 box but 28 dp
        // outside the 20x20 visible child (which is anchored topEnd).
        final paddedCorner = parentRect.bottomLeft + const Offset(1, -1);
        await tester.tapAt(paddedCorner);
        expect(taps, 1);
      },
    );

    testWidgets('tap outside the padded region does not fire', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        buildSubject(
          onTap: () => taps++,
          alignment: AlignmentDirectional.topEnd,
        ),
      );

      final parentRect = tester.getRect(find.byType(StreamTapTargetPadding));
      await tester.tapAt(parentRect.bottomRight + const Offset(1, 1));
      expect(taps, 0);
    });

    testWidgets(
      'RTL: tap in padded region (bottom-right) still fires onTap',
      (tester) async {
        var taps = 0;
        await tester.pumpWidget(
          buildSubject(
            onTap: () => taps++,
            alignment: AlignmentDirectional.topEnd,
            textDirection: TextDirection.rtl,
          ),
        );

        final parentRect = tester.getRect(find.byType(StreamTapTargetPadding));
        // In RTL, topEnd resolves to topLeft, so the padded region is on
        // the bottom-right.
        final paddedCorner = parentRect.bottomRight + const Offset(-1, -1);
        await tester.tapAt(paddedCorner);
        expect(taps, 1);
      },
    );
  });

  group('updates', () {
    testWidgets('changing minSize triggers relayout', (tester) async {
      Widget build(Size size) => Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: StreamTapTargetPadding(
            minSize: size,
            child: const SizedBox(width: 20, height: 20),
          ),
        ),
      );

      await tester.pumpWidget(build(const Size(48, 48)));
      expect(
        tester.renderObject<RenderBox>(find.byType(StreamTapTargetPadding)).size,
        equals(const Size(48, 48)),
      );

      await tester.pumpWidget(build(const Size(64, 64)));
      expect(
        tester.renderObject<RenderBox>(find.byType(StreamTapTargetPadding)).size,
        equals(const Size(64, 64)),
      );
    });

    testWidgets('changing alignment triggers relayout', (tester) async {
      Widget build(AlignmentGeometry alignment) => Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: StreamTapTargetPadding(
            minSize: const Size(48, 48),
            alignment: alignment,
            child: const SizedBox(width: 20, height: 20, key: ValueKey('child')),
          ),
        ),
      );

      await tester.pumpWidget(build(Alignment.center));
      final centerOffset =
          tester.getTopLeft(find.byKey(const ValueKey('child')));

      await tester.pumpWidget(build(AlignmentDirectional.topEnd));
      final topEndOffset =
          tester.getTopLeft(find.byKey(const ValueKey('child')));

      expect(topEndOffset, isNot(equals(centerOffset)));
    });
  });
}
