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
  group('StreamAvatarStack a11y', () {
    testWidgets('semanticsLabel: null (default) — composes through, child placeholders speak', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _withStreamTheme(
          StreamAvatarStack(
            children: [
              StreamAvatar(placeholder: (_) => const Text('AB')),
              StreamAvatar(placeholder: (_) => const Text('CD')),
              StreamAvatar(placeholder: (_) => const Text('EF')),
            ],
          ),
        ),
      );

      // No wrapper on the stack — each child's own semantics apply. Callers
      // wanting the stack decorative wrap in ExcludeSemantics themselves.
      expect(find.bySemanticsLabel('AB'), findsOneWidget);
      expect(find.bySemanticsLabel('CD'), findsOneWidget);
      expect(find.bySemanticsLabel('EF'), findsOneWidget);

      handle.dispose();
    });

    testWidgets('semanticsLabel non-null — labeled image node', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _withStreamTheme(
          StreamAvatarStack(
            semanticsLabel: 'Alice, Bob and 1 other',
            children: [
              StreamAvatar(placeholder: (_) => const Text('AB')),
              StreamAvatar(placeholder: (_) => const Text('CD')),
              StreamAvatar(placeholder: (_) => const Text('EF')),
            ],
          ),
        ),
      );

      expect(
        tester.getSemantics(find.byType(StreamAvatarStack)),
        isSemantics(label: 'Alice, Bob and 1 other', isImage: true),
      );

      expect(find.bySemanticsLabel('AB'), findsNothing);
      expect(find.bySemanticsLabel('CD'), findsNothing);
      expect(find.bySemanticsLabel('EF'), findsNothing);

      handle.dispose();
    });

    testWidgets('semanticsLabel: null — individually-labeled children still announce', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _withStreamTheme(
          StreamAvatarStack(
            children: [
              StreamAvatar(semanticsLabel: 'Alice', placeholder: (_) => const Text('AB')),
              StreamAvatar(semanticsLabel: 'Bob', placeholder: (_) => const Text('CD')),
            ],
          ),
        ),
      );

      expect(find.bySemanticsLabel('Alice'), findsOneWidget);
      expect(find.bySemanticsLabel('Bob'), findsOneWidget);

      handle.dispose();
    });

    testWidgets('overflow "+N" badge hidden from semantics regardless of label', (tester) async {
      final handle = tester.ensureSemantics();

      // 6 children with default max = 5 → 5 visible + "+1" badge.
      await tester.pumpWidget(
        _withStreamTheme(
          StreamAvatarStack(
            semanticsLabel: 'Alice and 5 others',
            children: List.generate(
              6,
              (i) => StreamAvatar(placeholder: (_) => Text('U$i')),
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('+1'), findsNothing);

      handle.dispose();
    });
  });
}
