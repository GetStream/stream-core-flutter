import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stream_core_flutter/core.dart';

Widget _withStreamTheme(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [StreamTheme()]),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('StreamAvatarGroup a11y', () {
    testWidgets('semanticsLabel: null (default) — composes through, child placeholders speak', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _withStreamTheme(
          StreamAvatarGroup(
            children: [
              StreamAvatar(placeholder: (_) => const Text('AB')),
              StreamAvatar(placeholder: (_) => const Text('CD')),
              StreamAvatar(placeholder: (_) => const Text('EF')),
            ],
          ),
        ),
      );

      // No wrapper on the group — each child's own semantics apply. Callers
      // wanting the group decorative wrap in ExcludeSemantics themselves.
      expect(find.bySemanticsLabel('AB'), findsOneWidget);
      expect(find.bySemanticsLabel('CD'), findsOneWidget);
      expect(find.bySemanticsLabel('EF'), findsOneWidget);

      handle.dispose();
    });

    testWidgets('semanticsLabel non-null — labeled image node', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _withStreamTheme(
          StreamAvatarGroup(
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
        tester.getSemantics(find.byType(StreamAvatarGroup)),
        isSemantics(label: 'Alice, Bob and 1 other', isImage: true),
      );

      // Child initials and any overflow "+N" badge merge into the outer
      // labeled node — not surfaced as separate semantic children.
      expect(find.bySemanticsLabel('AB'), findsNothing);
      expect(find.bySemanticsLabel('CD'), findsNothing);
      expect(find.bySemanticsLabel('EF'), findsNothing);

      handle.dispose();
    });

    testWidgets('semanticsLabel: null — individually-labeled children still announce', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _withStreamTheme(
          StreamAvatarGroup(
            children: [
              StreamAvatar(semanticsLabel: 'Alice', placeholder: (_) => const Text('AB')),
              StreamAvatar(semanticsLabel: 'Bob', placeholder: (_) => const Text('CD')),
            ],
          ),
        ),
      );

      // Each labeled child speaks for itself — the group applies no override.
      expect(find.bySemanticsLabel('Alice'), findsOneWidget);
      expect(find.bySemanticsLabel('Bob'), findsOneWidget);

      handle.dispose();
    });

    testWidgets('semanticsLabel non-null with 4+ children hides the "+N" overflow badge', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _withStreamTheme(
          StreamAvatarGroup(
            semanticsLabel: 'Alice, Bob and 3 others',
            children: List.generate(
              5,
              (i) => StreamAvatar(placeholder: (_) => Text('U$i')),
            ),
          ),
        ),
      );

      // The overflow badge renders "+3" visually but must not surface as its
      // own semantic node.
      expect(find.bySemanticsLabel('+3'), findsNothing);

      handle.dispose();
    });
  });
}
