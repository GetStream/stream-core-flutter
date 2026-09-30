import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/chat.dart';

/// Verifies that message texts rendered with the same theme and styles share
/// one markdown style sheet, and get a new one when the styles differ.
void main() {
  Widget wrap(List<Widget> children) {
    return MaterialApp(
      home: Theme(
        data: ThemeData(extensions: [StreamTheme()]),
        child: StreamMessageLayout(
          data: const StreamMessageLayoutData(),
          child: Column(children: children),
        ),
      ),
    );
  }

  List<MarkdownStyleSheet> styleSheetsOf(WidgetTester tester) {
    return [
      for (final body in tester.widgetList<MarkdownBody>(find.byType(MarkdownBody))) body.styleSheet!,
    ];
  }

  testWidgets('StreamMessageText shares one style sheet between messages with the same styles', (tester) async {
    await tester.pumpWidget(wrap([StreamMessageText('First'), StreamMessageText('Second')]));

    final [first, second] = styleSheetsOf(tester);
    expect(identical(first, second), isTrue);
  });

  testWidgets('StreamMessageText builds a separate style sheet for a different text style', (tester) async {
    await tester.pumpWidget(
      wrap([
        StreamMessageText('Plain'),
        StreamMessageText('Red', style: StreamMessageTextStyle(textColor: StreamMessageLayoutProperty.all(Colors.red))),
      ]),
    );

    final [plain, red] = styleSheetsOf(tester);
    expect(plain.p?.color, isNot(Colors.red));
    expect(red.p?.color, Colors.red);
  });
}
