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
  testWidgets('StreamAvatar renders a StreamNetworkImage when imageUrl is set', (tester) async {
    await tester.pumpWidget(
      _withStreamTheme(
        StreamAvatar(
          imageUrl: 'https://example.com/avatar.png',
          placeholder: (context) => const Text('A'),
        ),
      ),
    );

    final networkImage = tester.widget<StreamNetworkImage>(find.byType(StreamNetworkImage));
    expect(networkImage.props.url, equals('https://example.com/avatar.png'));
  });

  group('StreamAvatar a11y', () {
    testWidgets('semanticsLabel: null (default) — placeholder speaks for itself', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _withStreamTheme(
          StreamAvatar(placeholder: (_) => const Text('AB')),
        ),
      );

      // No semantic override on the avatar — the placeholder's own semantics
      // apply. Callers that want the avatar decorative should wrap it in
      // ExcludeSemantics themselves.
      expect(find.bySemanticsLabel('AB'), findsOneWidget);

      handle.dispose();
    });

    testWidgets('semanticsLabel: null wrapped in ExcludeSemantics — initials silent', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _withStreamTheme(
          ExcludeSemantics(
            child: StreamAvatar(placeholder: (_) => const Text('AB')),
          ),
        ),
      );

      // Canonical decorative-avatar pattern: caller wraps in ExcludeSemantics
      // (or an ancestor's `excludeSemantics: true`) when the surrounding row
      // already labels the avatar's context.
      expect(find.bySemanticsLabel('AB'), findsNothing);

      handle.dispose();
    });

    testWidgets('semanticsLabel non-null — labeled image node', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _withStreamTheme(
          StreamAvatar(
            semanticsLabel: 'Alice',
            placeholder: (_) => const Text('AB'),
          ),
        ),
      );

      expect(
        tester.getSemantics(find.byType(StreamAvatar)),
        isSemantics(label: 'Alice', isImage: true),
      );

      // The placeholder's initials must not surface as a separate semantic
      // node; they merge into the outer labeled node via excludeSemantics.
      expect(find.bySemanticsLabel('AB'), findsNothing);

      handle.dispose();
    });
  });
}
