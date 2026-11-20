import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/video.dart';

void main() {
  testWidgets('StreamContextMenuHeading without onTap is not interactive', (tester) async {
    await tester.pumpWidget(_wrap(StreamContextMenuHeading(label: const Text('Microphone'))));

    // The heading shares the row metrics of a menu item, so it is easy to
    // mistake for one; nothing in it should respond to a press.
    expect(
      find.descendant(of: find.byType(StreamContextMenuHeading), matching: find.byType(GestureDetector)),
      findsNothing,
    );
  });

  testWidgets('StreamContextMenuHeading calls onTap when tapped', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(StreamContextMenuHeading(label: const Text('Devices'), onTap: () => taps += 1)),
    );

    await tester.tap(find.text('Devices'));

    expect(taps, 1);
  });

  testWidgets('StreamContextMenuHeading draws a tertiary caption-emphasis label', (tester) async {
    await tester.pumpWidget(_wrap(StreamContextMenuHeading(label: const Text('Microphone'))));

    final streamTheme = _streamThemeOf(tester);
    final style = _labelStyleOf(tester, 'Microphone');
    expect(style.color, streamTheme.colorScheme.textTertiary);
    expect(style.fontSize, streamTheme.textTheme.captionEmphasis.fontSize);
    expect(style.fontWeight, streamTheme.textTheme.captionEmphasis.fontWeight);
  });

  testWidgets('StreamContextMenuHeading colors and sizes a trailing icon like its label', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StreamContextMenuHeading(label: const Text('Devices'), trailing: const Icon(Icons.expand_more)),
      ),
    );

    final iconText = tester.widget<RichText>(
      find.descendant(of: find.byType(Icon), matching: find.byType(RichText)),
    );
    expect(iconText.text.style!.color, _streamThemeOf(tester).colorScheme.textTertiary);
    expect(tester.getSize(find.byType(Icon)), const Size.square(16));
  });

  testWidgets('StreamContextMenuHeading lines up with a default StreamContextMenuAction', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StreamContextMenu(
          children: [
            StreamContextMenuHeading(label: const Text('Microphone')),
            StreamContextMenuAction<void>(label: const Text('Built-in')),
          ],
        ),
      ),
    );

    final headingRect = tester.getRect(find.byType(StreamContextMenuHeading));
    final actionRect = tester.getRect(find.byType(StreamContextMenuAction<void>));
    expect(headingRect.height, actionRect.height);
    expect(headingRect.width, actionRect.width);
    expect(tester.getTopLeft(find.text('Microphone')).dx, tester.getTopLeft(find.text('Built-in')).dx);
  });

  testWidgets('StreamContextMenuHeading puts the trailing widget at the far end', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StreamContextMenu(
          children: [
            StreamContextMenuHeading(label: const Text('Devices'), trailing: const Icon(Icons.expand_more)),
            StreamContextMenuAction<void>(label: const Text('Built-in'), trailing: const Icon(Icons.chevron_right)),
          ],
        ),
      ),
    );

    final headingTrailingRight = tester.getTopRight(find.byIcon(Icons.expand_more)).dx;
    final actionTrailingRight = tester.getTopRight(find.byIcon(Icons.chevron_right)).dx;
    expect(headingTrailingRight, actionTrailingRight);
  });

  testWidgets('StreamContextMenuHeading puts the trailing widget at the start edge in RTL', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StreamContextMenuHeading(label: const Text('Devices'), trailing: const Icon(Icons.expand_more)),
        rtl: true,
      ),
    );

    expect(
      tester.getTopLeft(find.byIcon(Icons.expand_more)).dx,
      lessThan(tester.getTopLeft(find.text('Devices')).dx),
    );
  });

  testWidgets('StreamContextMenuHeading grows with the text scale', (tester) async {
    await tester.pumpWidget(_wrap(StreamContextMenuHeading(label: const Text('Microphone')), textScale: 3));

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(StreamContextMenuHeading)).height, greaterThan(40));
  });

  testWidgets('StreamContextMenuHeading is announced as a header', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_wrap(StreamContextMenuHeading(label: const Text('Microphone'))));

    expect(
      tester.semantics.find(find.byType(StreamContextMenuHeading)),
      isSemantics(label: 'Microphone', isHeader: true, isButton: false, hasTapAction: false),
    );
    handle.dispose();
  });

  testWidgets('StreamContextMenuHeading with onTap is announced as a button with its expanded state', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _wrap(StreamContextMenuHeading(label: const Text('Devices'), expanded: false, onTap: () {})),
    );

    expect(
      tester.semantics.find(find.byType(StreamContextMenuHeading)),
      isSemantics(
        label: 'Devices',
        isHeader: true,
        isButton: true,
        hasTapAction: true,
        hasExpandedState: true,
        isExpanded: false,
      ),
    );
    handle.dispose();
  });

  testWidgets('StreamContextMenuHeading without onTap reports no expanded state', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_wrap(StreamContextMenuHeading(label: const Text('Devices'), expanded: true)));

    expect(
      tester.semantics.find(find.byType(StreamContextMenuHeading)),
      isSemantics(label: 'Devices', hasExpandedState: false),
    );
    handle.dispose();
  });

  testWidgets('StreamContextMenuHeading applies the StreamTheme heading theme', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StreamContextMenuHeading(label: const Text('Mic')),
        streamTheme: StreamTheme(
          contextMenuHeadingTheme: const StreamContextMenuHeadingThemeData(
            foregroundColor: Color(0xFF111111),
            textStyle: TextStyle(fontSize: 20),
            minimumSize: Size(200, 32),
            padding: EdgeInsets.zero,
          ),
        ),
      ),
    );

    final style = _labelStyleOf(tester, 'Mic');
    expect(style.color, const Color(0xFF111111));
    expect(style.fontSize, 20);
    expect(tester.getSize(find.byType(StreamContextMenuHeading)), const Size(200, 32));
  });

  testWidgets('StreamContextMenuHeadingTheme beats the StreamTheme heading theme', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StreamContextMenuHeadingTheme(
          data: const StreamContextMenuHeadingThemeData(foregroundColor: Color(0xFF222222)),
          child: StreamContextMenuHeading(label: const Text('Microphone')),
        ),
        streamTheme: StreamTheme(
          contextMenuHeadingTheme: const StreamContextMenuHeadingThemeData(
            foregroundColor: Color(0xFF111111),
            textStyle: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );

    final style = _labelStyleOf(tester, 'Microphone');
    expect(style.color, const Color(0xFF222222));
    expect(style.fontSize, 20);
  });

  testWidgets('StreamContextMenuHeading uses the themed overlay color when pressed', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StreamContextMenuHeadingTheme(
          data: const StreamContextMenuHeadingThemeData(
            overlayColor: WidgetStatePropertyAll(Color(0xFF333333)),
          ),
          child: StreamContextMenuHeading(label: const Text('Devices'), onTap: () {}),
        ),
      ),
    );

    final inkWell = tester.widget<InkWell>(find.byType(InkWell));
    expect(inkWell.overlayColor!.resolve({WidgetState.pressed}), const Color(0xFF333333));
  });

  testWidgets('StreamComponentFactory replaces the default context menu heading', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StreamComponentFactory(
          builders: StreamComponentBuilders(contextMenuHeading: (context, props) => const Text('custom')),
          child: StreamContextMenuHeading(label: const Text('Microphone')),
        ),
      ),
    );

    expect(find.text('custom'), findsOneWidget);
    expect(find.byType(DefaultStreamContextMenuHeading), findsNothing);
  });
}

StreamTheme _streamThemeOf(WidgetTester tester) => StreamTheme.of(tester.element(find.byType(Scaffold)));

TextStyle _labelStyleOf(WidgetTester tester, String label) {
  final element = tester.element(find.text(label));
  return DefaultTextStyle.of(element).style.merge(tester.widget<Text>(find.text(label)).style);
}

Widget _wrap(Widget child, {bool rtl = false, double textScale = 1, StreamTheme? streamTheme}) {
  return MaterialApp(
    theme: ThemeData(extensions: [streamTheme ?? StreamTheme()]),
    home: Directionality(
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      child: MediaQuery.withClampedTextScaling(
        minScaleFactor: textScale,
        maxScaleFactor: textScale,
        child: Scaffold(body: Center(child: child)),
      ),
    ),
  );
}
