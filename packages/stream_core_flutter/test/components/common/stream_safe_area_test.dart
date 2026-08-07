import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

void main() {
  group('StreamSafeArea.resolveInsets', () {
    Future<EdgeInsets> resolve(
      WidgetTester tester, {
      EdgeInsets padding = EdgeInsets.zero,
      EdgeInsets viewPadding = EdgeInsets.zero,
      required EdgeInsets Function(BuildContext) compute,
    }) async {
      late EdgeInsets result;
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(padding: padding, viewPadding: viewPadding),
          child: Builder(
            builder: (context) {
              result = compute(context);
              return const SizedBox();
            },
          ),
        ),
      );
      return result;
    }

    testWidgets('adds the margin on top of the system inset per edge', (tester) async {
      final insets = await resolve(
        tester,
        padding: const EdgeInsets.only(top: 44, bottom: 34, left: 10, right: 12),
        viewPadding: const EdgeInsets.only(top: 44, bottom: 34, left: 10, right: 12),
        compute: (context) => StreamSafeArea.resolveInsets(context, margin: const EdgeInsets.all(24)),
      );

      expect(insets, const EdgeInsets.only(top: 68, bottom: 58, left: 34, right: 36));
    });

    testWidgets('drops the system inset on disabled edges but keeps the margin', (tester) async {
      final insets = await resolve(
        tester,
        padding: const EdgeInsets.only(top: 44, bottom: 34),
        viewPadding: const EdgeInsets.only(top: 44, bottom: 34),
        compute: (context) => StreamSafeArea.resolveInsets(context, top: false, margin: const EdgeInsets.all(24)),
      );

      // top edge ignores the 44 status bar but still gets the 24 margin.
      expect(insets.top, 24);
      expect(insets.bottom, 58);
    });

    testWidgets('measures the bottom from viewPadding so a keyboard does not collapse it', (tester) async {
      final insets = await resolve(
        tester,
        // A keyboard has consumed the bottom padding (34 -> 0, the default) but not viewPadding.
        viewPadding: const EdgeInsets.only(bottom: 34),
        compute: (context) => StreamSafeArea.resolveInsets(context, margin: const EdgeInsets.all(24)),
      );

      // viewPadding.bottom (34) + 24, not padding.bottom (0) + 24.
      expect(insets.bottom, 58);
    });

    testWidgets('floors each edge at the minimum, which a larger inset absorbs', (tester) async {
      final insets = await resolve(
        tester,
        padding: const EdgeInsets.only(top: 44, left: 10),
        viewPadding: const EdgeInsets.only(top: 44, left: 10, bottom: 12),
        compute: (context) => StreamSafeArea.resolveInsets(
          context,
          minimum: const EdgeInsets.all(32),
        ),
      );

      // top: max(44, 32) = 44 (inset wins); left: max(10, 32) = 32 (floor wins);
      // bottom: max(12, 32) = 32; right: max(0, 32) = 32.
      expect(insets, const EdgeInsets.only(top: 44, left: 32, right: 32, bottom: 32));
    });

    testWidgets('adds the margin on top of the minimum', (tester) async {
      final insets = await resolve(
        tester,
        viewPadding: const EdgeInsets.only(bottom: 10),
        compute: (context) => StreamSafeArea.resolveInsets(
          context,
          minimum: const EdgeInsets.only(bottom: 32),
          margin: const EdgeInsets.only(bottom: 8),
        ),
      );

      // max(10, 32) + 8 = 40.
      expect(insets.bottom, 40);
    });

    testWidgets('measures the bottom from padding when maintainBottomViewPadding is false', (tester) async {
      final insets = await resolve(
        tester,
        padding: const EdgeInsets.only(bottom: 10),
        viewPadding: const EdgeInsets.only(bottom: 50),
        compute: (context) => StreamSafeArea.resolveInsets(
          context,
          margin: const EdgeInsets.all(24),
          maintainBottomViewPadding: false,
        ),
      );

      // padding.bottom (10) + 24, not viewPadding.bottom (50) + 24.
      expect(insets.bottom, 34);
    });
  });

  group('StreamSafeArea widget', () {
    const childKey = ValueKey('child');

    /// The gap between the [StreamSafeArea]'s edges and its child, i.e. the
    /// insets it actually applied through the composed SafeArea + margin.
    EdgeInsets appliedInsets(WidgetTester tester) {
      final outer = tester.getRect(find.byType(StreamSafeArea));
      final child = tester.getRect(find.byKey(childKey));
      return EdgeInsets.fromLTRB(
        child.left - outer.left,
        child.top - outer.top,
        outer.right - child.right,
        outer.bottom - child.bottom,
      );
    }

    Future<void> pump(
      WidgetTester tester,
      StreamSafeArea widget, {
      EdgeInsets padding = EdgeInsets.zero,
      EdgeInsets viewPadding = EdgeInsets.zero,
      TextDirection textDirection = TextDirection.ltr,
    }) {
      return tester.pumpWidget(
        Directionality(
          textDirection: textDirection,
          child: MediaQuery(
            data: MediaQueryData(padding: padding, viewPadding: viewPadding),
            child: widget,
          ),
        ),
      );
    }

    testWidgets('insets its child by the system inset plus the margin', (tester) async {
      await pump(
        tester,
        const StreamSafeArea(
          top: false,
          margin: EdgeInsets.all(24),
          child: SizedBox.expand(key: childKey),
        ),
        padding: const EdgeInsets.only(bottom: 34, left: 10),
        viewPadding: const EdgeInsets.only(bottom: 34, left: 10),
      );

      // top: 0 (disabled) + 24; left: 10 + 24; bottom: 34 + 24. Matches resolveInsets.
      expect(appliedInsets(tester), const EdgeInsets.only(top: 24, left: 34, right: 24, bottom: 58));
    });

    testWidgets('insets physical edges the same way under RTL', (tester) async {
      const widget = StreamSafeArea(
        margin: EdgeInsets.only(left: 4, right: 8),
        child: SizedBox.expand(key: childKey),
      );
      const insets = EdgeInsets.only(left: 10, right: 30);

      await pump(tester, widget, padding: insets, viewPadding: insets);
      final ltr = appliedInsets(tester);

      await pump(tester, widget, padding: insets, viewPadding: insets, textDirection: TextDirection.rtl);
      final rtl = appliedInsets(tester);

      // Physical left = 10 + 4, right = 30 + 8; RTL does not swap them.
      expect(ltr, const EdgeInsets.only(left: 14, right: 38));
      expect(rtl, ltr);
    });

    testWidgets('keeps the bottom gap when a keyboard collapses the padding', (tester) async {
      await pump(
        tester,
        const StreamSafeArea(
          margin: EdgeInsets.all(24),
          child: SizedBox.expand(key: childKey),
        ),
        // A keyboard has collapsed padding.bottom to 0 (the default); viewPadding.bottom stays 34.
        viewPadding: const EdgeInsets.only(bottom: 34),
      );

      // The composed SafeArea's maintainBottomViewPadding keeps 34 + 24.
      expect(appliedInsets(tester).bottom, 58);
    });

    testWidgets('collapsing lerps the inset from full toward zero by the animation', (tester) async {
      Future<EdgeInsets> collapsedAt(double t) async {
        await pump(
          tester,
          StreamSafeArea.collapsing(
            animation: AlwaysStoppedAnimation(t),
            top: false,
            minimum: const EdgeInsets.only(bottom: 40),
            child: const SizedBox.expand(key: childKey),
          ),
          padding: const EdgeInsets.only(bottom: 20),
          viewPadding: const EdgeInsets.only(bottom: 20),
        );
        return appliedInsets(tester);
      }

      // bottom = max(20, 40) = 40 at t=0, lerped toward 0 as t -> 1.
      expect((await collapsedAt(0)).bottom, 40);
      expect((await collapsedAt(1)).bottom, 0);
      expect((await collapsedAt(0.5)).bottom, 20);
    });
  });
}
