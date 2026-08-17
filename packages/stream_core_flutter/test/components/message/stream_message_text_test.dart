import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stream_core_flutter/chat.dart';

MarkdownStyleSheet _pumpAndReadSheet(WidgetTester tester) {
  return tester.widget<MarkdownBody>(find.byType(MarkdownBody)).styleSheet!;
}

Widget _withTheme(Widget child, {ThemeData? theme}) {
  return MaterialApp(
    theme: (theme ?? ThemeData()).copyWith(extensions: [StreamTheme()]),
    home: Scaffold(body: child),
  );
}

void main() {
  group('StreamMessageText markdown style sheet', () {
    // `MarkdownStyleSheet.fromTheme` takes Flutter's own `ThemeData`, which is
    // an unrelated type to `material_ui`'s, so the widget bridges between them
    // by hand. These assertions pin the fields that bridge has to carry —
    // dropping one would silently fall back to a Material default.
    testWidgets('derives heading styles from the ambient text theme', (tester) async {
      const headline = TextStyle(fontSize: 33, fontWeight: FontWeight.w900);
      const title = TextStyle(fontSize: 27);

      await tester.pumpWidget(
        _withTheme(
          StreamMessageText('# Heading\n\nBody text'),
          theme: ThemeData(
            textTheme: const TextTheme(headlineSmall: headline, titleLarge: title),
          ),
        ),
      );

      final sheet = _pumpAndReadSheet(tester);
      expect(sheet.h1?.fontSize, headline.fontSize);
      expect(sheet.h1?.fontWeight, headline.fontWeight);
      expect(sheet.h2?.fontSize, title.fontSize);
    });

    testWidgets('sizes inline code relative to the body style', (tester) async {
      const body = TextStyle(fontSize: 20);

      await tester.pumpWidget(
        _withTheme(
          StreamMessageText('Body with `code`'),
          theme: ThemeData(textTheme: const TextTheme(bodyMedium: body)),
        ),
      );

      // `fromTheme` derives code from bodyMedium at 85% of its size, so a
      // bridge that dropped `textTheme` would land on Material's default 14.
      expect(_pumpAndReadSheet(tester).code?.fontSize, body.fontSize! * 0.85);
    });

    testWidgets('takes the code block and table colors from the ambient theme', (tester) async {
      const cardColor = Color(0xFFABCDEF);
      const dividerColor = Color(0xFF123456);

      await tester.pumpWidget(
        _withTheme(
          StreamMessageText('    code block'),
          theme: ThemeData(cardColor: cardColor, dividerColor: dividerColor),
        ),
      );

      final sheet = _pumpAndReadSheet(tester);
      expect((sheet.codeblockDecoration! as BoxDecoration).color, cardColor);
      expect(sheet.tableBorder?.top.color, dividerColor);
    });

    testWidgets('lets an explicit style sheet win over the derived one', (tester) async {
      const override = TextStyle(fontSize: 42);

      await tester.pumpWidget(
        _withTheme(
          StreamMessageText('# Heading', styleSheet: MarkdownStyleSheet(h1: override)),
          theme: ThemeData(
            textTheme: const TextTheme(headlineSmall: TextStyle(fontSize: 10)),
          ),
        ),
      );

      expect(_pumpAndReadSheet(tester).h1?.fontSize, override.fontSize);
    });
  });
}
