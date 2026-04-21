import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';

void main() {
  Widget buildSubject({
    required VoidCallback onPressed,
    MaterialTapTargetSize? tapTargetSize,
    VisualDensity? visualDensity,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    return Directionality(
      textDirection: textDirection,
      child: Theme(
        data: ThemeData(extensions: [StreamTheme()]),
        child: Align(
          alignment: Alignment.topLeft,
          child: StreamRemoveControl(
            onPressed: onPressed,
            tapTargetSize: tapTargetSize,
            visualDensity: visualDensity,
          ),
        ),
      ),
    );
  }

  group('tapTargetSize', () {
    testWidgets('defaults to padded (48x48)', (tester) async {
      await tester.pumpWidget(buildSubject(onPressed: () {}));

      final box = tester.renderObject<RenderBox>(
        find.byType(StreamTapTargetPadding),
      );
      expect(box.size, equals(const Size(48, 48)));
    });

    testWidgets('shrinkWrap matches the visible badge (20x20)', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          onPressed: () {},
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );

      final box = tester.renderObject<RenderBox>(
        find.byType(StreamTapTargetPadding),
      );
      expect(box.size, equals(const Size(20, 20)));
    });
  });

  group('hit testing', () {
    testWidgets(
      'padded: tap anywhere inside 48x48 fires onPressed',
      (tester) async {
        var taps = 0;
        await tester.pumpWidget(buildSubject(onPressed: () => taps++));

        final rect = tester.getRect(find.byType(StreamRemoveControl));
        expect(rect.size, equals(const Size(48, 48)));

        // Bottom-start corner — 28 dp away from the visible badge.
        await tester.tapAt(rect.bottomLeft + const Offset(1, -1));
        expect(taps, 1);

        // Top-end corner — right on the visible badge.
        await tester.tapAt(rect.topRight + const Offset(-4, 4));
        expect(taps, 2);
      },
    );

    testWidgets(
      'shrinkWrap: only taps inside the 20x20 badge fire',
      (tester) async {
        var taps = 0;
        await tester.pumpWidget(
          buildSubject(
            onPressed: () => taps++,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        );

        final rect = tester.getRect(find.byType(StreamRemoveControl));
        expect(rect.size, equals(const Size(20, 20)));

        await tester.tapAt(rect.center);
        expect(taps, 1);

        // Well outside the 20x20 badge — would have hit if padded.
        await tester.tapAt(rect.bottomRight + const Offset(10, 10));
        expect(taps, 1);
      },
    );
  });

  group('layout', () {
    testWidgets(
      'LTR: visible badge is flush with the top-right corner',
      (tester) async {
        await tester.pumpWidget(buildSubject(onPressed: () {}));

        final parent = tester.getRect(find.byType(StreamRemoveControl));
        // The visible 20x20 badge should be anchored to the top-end
        // corner of the 48x48 hit area.
        final badgeRect = tester.getRect(find.byType(Icon));
        expect(
          (badgeRect.center - parent.topRight).distance < 15,
          isTrue,
          reason: 'Icon center ${badgeRect.center} should be near '
              'the top-right corner ${parent.topRight}.',
        );
      },
    );

    testWidgets(
      'RTL: visible badge anchors to the top-left corner',
      (tester) async {
        await tester.pumpWidget(
          buildSubject(
            onPressed: () {},
            textDirection: TextDirection.rtl,
          ),
        );

        final parent = tester.getRect(find.byType(StreamRemoveControl));
        final badgeRect = tester.getRect(find.byType(Icon));
        expect(
          (badgeRect.center - parent.topLeft).distance < 15,
          isTrue,
          reason: 'Icon center ${badgeRect.center} should be near '
              'the top-left corner ${parent.topLeft} in RTL.',
        );
      },
    );
  });

  group('accessibility', () {
    testWidgets('exposes a button with the given semantic label', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(buildSubject(onPressed: () {}));

      expect(
        tester.getSemantics(find.byType(StreamRemoveControl)),
        matchesSemantics(
          isButton: true,
          label: 'Remove',
        ),
      );
      handle.dispose();
    });
  });
}
