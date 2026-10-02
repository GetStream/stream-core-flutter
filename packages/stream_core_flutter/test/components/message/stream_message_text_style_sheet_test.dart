import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/chat.dart';

void main() {
  testWidgets('StreamMessageText shares one style sheet between messages with the same styles', (tester) async {
    await _pumpMessageTexts(tester, [StreamMessageText('First'), StreamMessageText('Second')]);

    final [first, second] = _styleSheetsOf(tester);
    expect(identical(first, second), isTrue);
  });

  testWidgets('StreamMessageText builds a separate style sheet for a different text style', (tester) async {
    final red = StreamMessageTextStyle(textColor: StreamMessageLayoutProperty.all(Colors.red));

    await _pumpMessageTexts(tester, [StreamMessageText('Plain'), StreamMessageText('Red', style: red)]);

    final [plainSheet, redSheet] = _styleSheetsOf(tester);
    expect(identical(plainSheet, redSheet), isFalse);
    expect(redSheet.p?.color, Colors.red);
  });

  testWidgets("StreamMessageText keeps each message's style sheet override separate", (tester) async {
    await _pumpMessageTexts(tester, [
      StreamMessageText('Visible', styleSheet: MarkdownStyleSheet(tableScrollbarThumbVisibility: true)),
      StreamMessageText('Hidden', styleSheet: MarkdownStyleSheet(tableScrollbarThumbVisibility: false)),
    ]);

    final [visible, hidden] = _styleSheetsOf(tester);
    expect(visible.tableScrollbarThumbVisibility, isTrue);
    expect(hidden.tableScrollbarThumbVisibility, isFalse);
  });

  testWidgets('StreamMessageText rebuilds its style sheet from a new theme', (tester) async {
    const headline = TextStyle(fontSize: 40);
    final theme = ThemeData(extensions: [StreamTheme()]);

    await _pumpMessageTexts(tester, [StreamMessageText('Hello')], theme: theme);
    final [before] = _styleSheetsOf(tester);
    expect(before.h1?.fontSize, isNot(headline.fontSize));

    await _pumpMessageTexts(
      tester,
      [StreamMessageText('Hello')],
      theme: theme.copyWith(textTheme: theme.textTheme.copyWith(headlineSmall: headline)),
    );

    final [after] = _styleSheetsOf(tester);
    expect(after.h1?.fontSize, headline.fontSize);
  });
}

Future<void> _pumpMessageTexts(WidgetTester tester, List<Widget> children, {ThemeData? theme}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Theme(
        data: theme ?? ThemeData(extensions: [StreamTheme()]),
        child: StreamMessageLayout(
          data: const StreamMessageLayoutData(),
          child: Column(children: children),
        ),
      ),
    ),
  );
}

List<MarkdownStyleSheet> _styleSheetsOf(WidgetTester tester) {
  return [
    for (final body in tester.widgetList<MarkdownBody>(find.byType(MarkdownBody))) body.styleSheet!,
  ];
}
