import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

Widget _withStreamTheme(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [StreamTheme()]),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('StreamMediaBadge.semanticsLabel', () {
    testWidgets('when null, badge exposes its visual duration text to SR', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _withStreamTheme(
          const StreamMediaBadge(
            type: MediaBadgeType.video,
            duration: Duration(minutes: 1, seconds: 23),
            durationFormat: MediaBadgeDurationFormat.exact,
          ),
        ),
      );

      // Visual text is announced verbatim — TalkBack/VoiceOver read '1:23'.
      expect(find.bySemanticsLabel('1:23'), findsOneWidget);

      handle.dispose();
    });

    testWidgets('when set, badge replaces the visual content in the semantic tree', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _withStreamTheme(
          const StreamMediaBadge(
            type: MediaBadgeType.video,
            duration: Duration(minutes: 1, seconds: 23),
            durationFormat: MediaBadgeDurationFormat.exact,
            semanticsLabel: '1 minute 23 seconds',
          ),
        ),
      );

      // The caller-supplied label is what the SR reads.
      expect(find.bySemanticsLabel('1 minute 23 seconds'), findsOneWidget);

      // The visual duration text is hidden from the semantic tree via
      // ExcludeSemantics — the SR shouldn't announce both.
      expect(find.bySemanticsLabel('1:23'), findsNothing);

      handle.dispose();
    });
  });
}
