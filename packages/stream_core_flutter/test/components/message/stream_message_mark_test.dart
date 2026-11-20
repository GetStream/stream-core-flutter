import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/chat.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: ThemeData(extensions: [StreamTheme()]),
      home: Center(
        child: StreamMessageLayout(
          data: const StreamMessageLayoutData(
            alignment: StreamMessageAlignment.end,
          ),
          child: child,
        ),
      ),
    );
  }

  Color? labelColor(WidgetTester tester, String label) {
    final richText = find.descendant(
      of: find.text(label),
      matching: find.byType(RichText),
    );
    return tester.widget<RichText>(richText).text.style?.color;
  }

  StreamColorScheme colorScheme(WidgetTester tester) {
    final context = tester.element(find.byType(StreamMessageMark));
    return context.streamColorScheme;
  }

  testWidgets('a mark that is not highlighted uses the muted color', (tester) async {
    await tester.pumpWidget(wrap(StreamMessageMark(label: const Text('Not played'))));

    expect(labelColor(tester, 'Not played'), colorScheme(tester).textTertiary);
  });

  testWidgets('a highlighted mark uses the accent color', (tester) async {
    await tester.pumpWidget(
      wrap(StreamMessageMark(label: const Text('Played'), highlighted: true)),
    );

    expect(labelColor(tester, 'Played'), colorScheme(tester).accentPrimary);
  });

  testWidgets('a mark uses the color from the message item theme', (tester) async {
    const themedColor = Color(0xFF00AA55);
    final mark = StreamMessageItemTheme(
      data: StreamMessageItemThemeData(
        mark: StreamMessageMarkStyle.from(color: themedColor),
      ),
      child: StreamMessageMark(label: const Text('Not played')),
    );
    await tester.pumpWidget(wrap(mark));

    expect(labelColor(tester, 'Not played'), themedColor);
  });

  testWidgets('a mark shows no separator when given none', (tester) async {
    final mark = StreamMessageMark(label: const Text('Played'), separator: null);
    await tester.pumpWidget(wrap(mark));

    expect(find.text('·'), findsNothing);
  });

  testWidgets('a mark shows a separator after the label by default', (tester) async {
    await tester.pumpWidget(wrap(StreamMessageMark(label: const Text('Played'))));

    final labelRight = tester.getTopRight(find.text('Played')).dx;
    final separatorLeft = tester.getTopLeft(find.text('·')).dx;
    expect(separatorLeft, greaterThan(labelRight));
  });

  testWidgets('tapping a mark with onTap calls it', (tester) async {
    var taps = 0;
    final mark = StreamMessageMark(
      label: const Text('Played by 2'),
      onTap: () => taps += 1,
    );
    await tester.pumpWidget(wrap(mark));

    await tester.tap(find.text('Played by 2'));

    expect(taps, 1);
  });

  testWidgets('metadata shows the mark before the timestamp', (tester) async {
    final metadata = StreamMessageMetadata(
      timestamp: const Text('09:41'),
      mark: StreamMessageMark(label: const Text('Played')),
    );
    await tester.pumpWidget(wrap(metadata));

    final markRight = tester.getTopRight(find.text('Played')).dx;
    final timestampLeft = tester.getTopLeft(find.text('09:41')).dx;
    expect(timestampLeft, greaterThan(markRight));
  });
}
