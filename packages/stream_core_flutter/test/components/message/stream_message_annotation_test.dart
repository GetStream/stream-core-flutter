import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/chat.dart';

/// Verifies how [StreamMessageAnnotation] lays its slots out: on a single line
/// while they fit, and as two lines — with the separator dropped — when they
/// don't.
void main() {
  // The test font draws every glyph as a square of the font size, so the
  // annotation below measures ~470px on one line. These two widths sit either
  // side of that, with [wrapped] still wide enough for the label alone.
  const roomy = 600.0;
  const wrapped = 400.0;

  Widget wrap({
    required Widget child,
    double width = roomy,
    StreamMessageAlignment alignment = StreamMessageAlignment.start,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    return MaterialApp(
      home: Directionality(
        textDirection: textDirection,
        child: Theme(
          data: ThemeData(extensions: [StreamTheme()]),
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: width,
              child: StreamMessageLayout(
                data: StreamMessageLayoutData(alignment: alignment),
                // Aligning rather than sizing keeps the width bounded while
                // letting the annotation shrink-wrap, so its own size can be
                // measured.
                child: Align(alignment: AlignmentDirectional.centerStart, child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget subject({
    Widget? separator = StreamMessageAnnotation.separator,
    Widget? trailing = const Text('Show original'),
    String label = 'Translated from English',
    VoidCallback? onTap,
  }) {
    return StreamMessageAnnotation(
      onTap: onTap,
      leading: const Icon(Icons.translate),
      label: Text(label),
      separator: separator,
      trailing: trailing,
    );
  }

  Rect rectOf(WidgetTester tester, Finder finder) {
    final box = tester.renderObject<RenderBox>(finder);
    return box.localToGlobal(Offset.zero) & box.size;
  }

  Rect rowRect(WidgetTester tester) => rectOf(tester, find.byType(StreamMessageAnnotation));
  Rect labelRect(WidgetTester tester) => rectOf(tester, find.text('Translated from English'));
  Rect trailingRect(WidgetTester tester) => rectOf(tester, find.text('Show original'));

  group('single line', () {
    testWidgets('keeps every slot on one line, in order', (tester) async {
      await tester.pumpWidget(wrap(child: subject()));

      final label = labelRect(tester);
      final separator = rectOf(tester, find.text('·'));
      final trailing = trailingRect(tester);

      // Slots are centered against the tallest one rather than top-aligned,
      // so their centers are what line up.
      expect(label.center.dy, moreOrLessEquals(separator.center.dy, epsilon: 1));
      expect(label.center.dy, moreOrLessEquals(trailing.center.dy, epsilon: 1));

      expect(separator.left, greaterThanOrEqualTo(label.right));
      expect(trailing.left, greaterThanOrEqualTo(separator.right));
    });

    testWidgets('omits the separator when none is given', (tester) async {
      await tester.pumpWidget(wrap(child: subject(separator: null)));

      expect(find.text('·'), findsNothing);
      expect(trailingRect(tester).left, greaterThanOrEqualTo(labelRect(tester).right));
    });

    testWidgets('omits the separator when there is nothing to separate', (tester) async {
      await tester.pumpWidget(wrap(child: subject(trailing: null)));

      expect(find.text('·'), findsNothing);
    });

    testWidgets('gives the separator room of its own', (tester) async {
      await tester.pumpWidget(wrap(child: subject()));
      final withSeparator = rowRect(tester).width;

      await tester.pumpWidget(wrap(child: subject(separator: null)));
      final withoutSeparator = rowRect(tester).width;

      expect(withSeparator, greaterThan(withoutSeparator));
    });

    testWidgets('hides the separator from assistive technologies', (tester) async {
      await tester.pumpWidget(wrap(child: subject()));

      expect(find.bySemanticsLabel('Translated from English'), findsOneWidget);
      expect(find.bySemanticsLabel('Show original'), findsOneWidget);
      expect(find.bySemanticsLabel('·'), findsNothing);
    });
  });

  group('wrapped', () {
    testWidgets('moves the trailing slot to its own line', (tester) async {
      await tester.pumpWidget(wrap(width: wrapped, child: subject()));

      expect(trailingRect(tester).top, greaterThanOrEqualTo(labelRect(tester).bottom));
    });

    testWidgets('keeps the label on a single line', (tester) async {
      await tester.pumpWidget(wrap(child: subject()));
      final unwrapped = labelRect(tester).height;

      await tester.pumpWidget(wrap(width: wrapped, child: subject()));

      expect(labelRect(tester).height, unwrapped);
    });

    testWidgets('drops the separator', (tester) async {
      await tester.pumpWidget(wrap(width: wrapped, child: subject()));
      final withSeparator = rowRect(tester).size;

      await tester.pumpWidget(wrap(width: wrapped, child: subject(separator: null)));
      final withoutSeparator = rowRect(tester).size;

      // A dropped separator claims neither width nor a gap, so a wrapped row
      // measures the same with and without one.
      expect(withSeparator, withoutSeparator);
    });

    testWidgets('indents the trailing slot to the label for a start-aligned message', (tester) async {
      await tester.pumpWidget(wrap(width: wrapped, child: subject()));

      expect(trailingRect(tester).left, moreOrLessEquals(labelRect(tester).left, epsilon: 1));
    });

    testWidgets('flushes both lines to the end edge for an end-aligned message', (tester) async {
      await tester.pumpWidget(
        wrap(width: wrapped, alignment: StreamMessageAlignment.end, child: subject()),
      );

      final row = rowRect(tester);
      expect(labelRect(tester).right, moreOrLessEquals(row.right, epsilon: 1));
      expect(trailingRect(tester).right, moreOrLessEquals(row.right, epsilon: 1));
    });

    testWidgets('wraps the label itself when it has a line to spare', (tester) async {
      await tester.pumpWidget(wrap(child: subject()));
      final oneLine = labelRect(tester).height;

      await tester.pumpWidget(wrap(width: 200, child: subject()));

      final label = labelRect(tester);
      // The label took more than one line, and the trailing slot still sits
      // below all of them.
      expect(label.height, greaterThan(oneLine));
      expect(trailingRect(tester).top, greaterThanOrEqualTo(label.bottom));
    });

    testWidgets('taps on the second line still reach the row', (tester) async {
      var tapped = 0;
      await tester.pumpWidget(
        wrap(
          width: wrapped,
          child: subject(onTap: () => tapped++),
        ),
      );

      await tester.tap(find.text('Show original'));

      expect(tapped, 1);
    });
  });

  group('rtl', () {
    testWidgets('mirrors the single-line order', (tester) async {
      await tester.pumpWidget(wrap(textDirection: TextDirection.rtl, child: subject()));

      final label = labelRect(tester);
      final separator = rectOf(tester, find.text('·'));
      final trailing = trailingRect(tester);

      expect(separator.right, lessThanOrEqualTo(label.left));
      expect(trailing.right, lessThanOrEqualTo(separator.left));
    });

    testWidgets('mirrors the wrapped indent', (tester) async {
      await tester.pumpWidget(
        wrap(width: wrapped, textDirection: TextDirection.rtl, child: subject()),
      );

      final label = labelRect(tester);
      final trailing = trailingRect(tester);

      expect(trailing.top, greaterThanOrEqualTo(label.bottom));
      expect(trailing.right, moreOrLessEquals(label.right, epsilon: 1));
    });
  });
}
