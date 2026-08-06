import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

/// Pumps [child] under a [MediaQuery] with the given system insets and returns
/// the resolved [EdgeInsets] the enclosed [StreamSafeArea] options produce.
Future<EdgeInsets> resolve(
  WidgetTester tester, {
  EdgeInsets viewPadding = EdgeInsets.zero,
  EdgeInsets viewInsets = EdgeInsets.zero,
  required EdgeInsets Function(BuildContext) compute,
}) async {
  late EdgeInsets result;
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(viewPadding: viewPadding, viewInsets: viewInsets),
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

void main() {
  group('StreamSafeArea.resolveInsets', () {
    testWidgets('adds the margin on top of the system inset per edge', (tester) async {
      final insets = await resolve(
        tester,
        viewPadding: const EdgeInsets.only(top: 44, bottom: 34, left: 10, right: 12),
        compute: (context) => StreamSafeArea.resolveInsets(context, margin: const EdgeInsets.all(24)),
      );

      expect(insets, const EdgeInsets.only(top: 68, bottom: 58, left: 34, right: 36));
    });

    testWidgets('drops the system inset on disabled edges but keeps the margin', (tester) async {
      final insets = await resolve(
        tester,
        viewPadding: const EdgeInsets.only(top: 44, bottom: 34),
        compute: (context) => StreamSafeArea.resolveInsets(context, top: false, margin: const EdgeInsets.all(24)),
      );

      // top edge ignores the 44 status bar but still gets the 24 margin.
      expect(insets.top, 24);
      expect(insets.bottom, 58);
    });

    testWidgets('ignores the keyboard by default', (tester) async {
      final insets = await resolve(
        tester,
        viewPadding: const EdgeInsets.only(bottom: 34),
        viewInsets: const EdgeInsets.only(bottom: 300),
        compute: (context) => StreamSafeArea.resolveInsets(context, margin: const EdgeInsets.all(24)),
      );

      // viewInsets (keyboard) is not consulted: 34 + 24, not 300 + 24.
      expect(insets.bottom, 58);
    });

    testWidgets('clears the keyboard when avoidKeyboard is set', (tester) async {
      final insets = await resolve(
        tester,
        viewPadding: const EdgeInsets.only(bottom: 34),
        viewInsets: const EdgeInsets.only(bottom: 300),
        compute: (context) =>
            StreamSafeArea.resolveInsets(context, margin: const EdgeInsets.all(24), avoidKeyboard: true),
      );

      // max(34, 300) + 24.
      expect(insets.bottom, 324);
    });
  });

  testWidgets('StreamSafeArea pads its child by the resolved insets', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(viewPadding: EdgeInsets.only(bottom: 34)),
        child: StreamSafeArea(
          top: false,
          margin: const EdgeInsets.all(24),
          child: Container(key: const ValueKey('child')),
        ),
      ),
    );

    final padding = tester.widget<Padding>(
      find.ancestor(of: find.byKey(const ValueKey('child')), matching: find.byType(Padding)).first,
    );
    expect(padding.padding, const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 58));
  });
}
