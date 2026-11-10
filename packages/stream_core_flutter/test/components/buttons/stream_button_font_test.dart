import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

// The label's style comes from the button theme, which sets no font family,
// so the family has to come from the text style around the button, as it
// does for every other Stream text.
TextStyle _labelStyle(WidgetTester tester) {
  return tester
      .widget<RichText>(find.descendant(of: find.byType(StreamButton), matching: find.byType(RichText)))
      .text
      .style!;
}

void main() {
  testWidgets("uses the app's font family for its label", (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(fontFamily: 'AppFont', extensions: [StreamTheme()]),
        home: Scaffold(
          body: Center(
            child: StreamButton(onPressed: () {}, child: const Text('Label')),
          ),
        ),
      ),
    );

    expect(_labelStyle(tester).fontFamily, 'AppFont');
  });

  testWidgets('uses the font family of the text style around it', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: [StreamTheme()]),
        home: Scaffold(
          body: Center(
            child: DefaultTextStyle(
              style: const TextStyle(fontFamily: 'LocalFont', fontFamilyFallback: ['Fallback']),
              child: StreamButton(onPressed: () {}, child: const Text('Label')),
            ),
          ),
        ),
      ),
    );

    final style = _labelStyle(tester);
    expect(style.fontFamily, 'LocalFont');
    expect(style.fontFamilyFallback, ['Fallback']);
  });

  testWidgets('keeps a font family set by the theme style', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(fontFamily: 'AppFont', extensions: [StreamTheme()]),
        home: Scaffold(
          body: Center(
            child: StreamButton(
              onPressed: () {},
              themeStyle: const StreamButtonThemeStyle(
                textStyle: WidgetStatePropertyAll(TextStyle(fontFamily: 'ButtonFont')),
              ),
              child: const Text('Label'),
            ),
          ),
        ),
      ),
    );

    expect(_labelStyle(tester).fontFamily, 'ButtonFont');
  });
}
