import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/chat.dart';

void main() {
  testWidgets('an end-aligned row reads mark, separator, edited, status and timestamp, then username', (
    tester,
  ) async {
    final metadata = StreamMessageMetadata(
      timestamp: const Text('09:41'),
      status: const Icon(StreamIconData.checks),
      username: const Text('Alice'),
      mark: const Text('Played'),
      edited: const Text('Edited'),
    );
    await _pumpMetadata(tester, metadata);

    final status = tester.getTopLeft(find.byType(Icon)).dx;
    expect(_left(tester, 'Played'), lessThan(_left(tester, '·')));
    expect(_left(tester, '·'), lessThan(_left(tester, 'Edited')));
    expect(_left(tester, 'Edited'), lessThan(status));
    expect(status, lessThan(_left(tester, '09:41')));
    expect(_left(tester, '09:41'), lessThan(_left(tester, 'Alice')));
  });

  testWidgets('a start-aligned row reads username, status and timestamp, edited, separator, then mark', (
    tester,
  ) async {
    final metadata = StreamMessageMetadata(
      timestamp: const Text('09:41'),
      status: const Icon(StreamIconData.checks),
      username: const Text('Alice'),
      mark: const Text('Played'),
      edited: const Text('Edited'),
    );
    await _pumpMetadata(tester, metadata, alignment: StreamMessageAlignment.start);

    final status = tester.getTopLeft(find.byType(Icon)).dx;
    expect(_left(tester, 'Alice'), lessThan(status));
    expect(status, lessThan(_left(tester, '09:41')));
    expect(_left(tester, '09:41'), lessThan(_left(tester, 'Edited')));
    expect(_left(tester, 'Edited'), lessThan(_left(tester, '·')));
    expect(_left(tester, '·'), lessThan(_left(tester, 'Played')));
  });

  testWidgets('a right-to-left row mirrors the order', (tester) async {
    final metadata = Directionality(
      textDirection: TextDirection.rtl,
      child: StreamMessageMetadata(
        timestamp: const Text('09:41'),
        mark: const Text('Played'),
      ),
    );
    await _pumpMetadata(tester, metadata);

    expect(_left(tester, '09:41'), lessThan(_left(tester, '·')));
    expect(_left(tester, '·'), lessThan(_left(tester, 'Played')));
  });

  testWidgets('the mark uses the accent color by default', (tester) async {
    final metadata = StreamMessageMetadata(
      timestamp: const Text('09:41'),
      mark: const Text('Played by 2'),
    );
    await _pumpMetadata(tester, metadata);

    final style = _textStyle(tester, 'Played by 2');
    expect(style?.color, _colorScheme(tester).accentPrimary);
  });

  testWidgets('the mark uses the color from the message item theme', (tester) async {
    const themedColor = Color(0xFF00AA55);
    final metadata = StreamMessageItemTheme(
      data: StreamMessageItemThemeData(
        metadata: StreamMessageMetadataStyle.from(markColor: themedColor),
      ),
      child: StreamMessageMetadata(
        timestamp: const Text('09:41'),
        mark: const Text('Played'),
      ),
    );
    await _pumpMetadata(tester, metadata);

    expect(_textStyle(tester, 'Played')?.color, themedColor);
  });

  testWidgets('the mark uses the text style from its own style', (tester) async {
    const fontSize = 21.0;
    final metadata = StreamMessageMetadata(
      timestamp: const Text('09:41'),
      mark: const Text('Played'),
      style: StreamMessageMetadataStyle.from(
        markTextStyle: const TextStyle(fontSize: fontSize),
      ),
    );
    await _pumpMetadata(tester, metadata);

    expect(_textStyle(tester, 'Played')?.fontSize, fontSize);
  });

  testWidgets('the separator uses the text style from its own style', (tester) async {
    const fontSize = 21.0;
    final metadata = StreamMessageMetadata(
      timestamp: const Text('09:41'),
      mark: const Text('Played'),
      style: StreamMessageMetadataStyle.from(
        separatorTextStyle: const TextStyle(fontSize: fontSize),
      ),
    );
    await _pumpMetadata(tester, metadata);

    expect(_textStyle(tester, '·')?.fontSize, fontSize);
  });

  testWidgets('no separator shows without a mark', (tester) async {
    final metadata = StreamMessageMetadata(timestamp: const Text('09:41'));
    await _pumpMetadata(tester, metadata);

    expect(find.text('·'), findsNothing);
  });

  testWidgets('the separator uses the tertiary text color by default', (tester) async {
    final metadata = StreamMessageMetadata(
      timestamp: const Text('09:41'),
      mark: const Text('Played'),
    );
    await _pumpMetadata(tester, metadata);

    expect(_textStyle(tester, '·')?.color, _colorScheme(tester).textTertiary);
  });

  testWidgets('the separator uses the separator color from its style', (tester) async {
    const separatorColor = Color(0xFF00AA55);
    final metadata = StreamMessageMetadata(
      timestamp: const Text('09:41'),
      mark: const Text('Played'),
      style: StreamMessageMetadataStyle.from(separatorColor: separatorColor),
    );
    await _pumpMetadata(tester, metadata);

    expect(_textStyle(tester, '·')?.color, separatorColor);
  });

  testWidgets('screen readers skip the separator', (tester) async {
    final semantics = tester.ensureSemantics();
    final metadata = StreamMessageMetadata(
      timestamp: const Text('09:41'),
      mark: const Text('Played'),
    );
    await _pumpMetadata(tester, metadata);

    expect(find.bySemanticsLabel('·'), findsNothing);
    expect(find.bySemanticsLabel('Played'), findsOneWidget);
    // Disposed inline: the test binding checks for open semantics handles
    // before tear-downs run.
    semantics.dispose();
  });
}

Future<void> _pumpMetadata(
  WidgetTester tester,
  Widget metadata, {
  StreamMessageAlignment alignment = StreamMessageAlignment.end,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(extensions: [StreamTheme()]),
      home: Center(
        child: StreamMessageLayout(
          data: StreamMessageLayoutData(alignment: alignment),
          child: metadata,
        ),
      ),
    ),
  );
}

TextStyle? _textStyle(WidgetTester tester, String text) {
  final richText = find.descendant(
    of: find.text(text),
    matching: find.byType(RichText),
  );
  return tester.widget<RichText>(richText).text.style;
}

StreamColorScheme _colorScheme(WidgetTester tester) {
  return tester.element(find.byType(StreamMessageMetadata)).streamColorScheme;
}

double _left(WidgetTester tester, String text) => tester.getTopLeft(find.text(text)).dx;
