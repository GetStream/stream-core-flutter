import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/video.dart';

void main() {
  testWidgets('StreamContextMenuHeading without onTap takes no keyboard focus', (tester) async {
    await tester.pumpWidget(_wrap(StreamContextMenuHeading(label: const Text('Microphone'))));

    // The heading shares the row metrics of a menu item, so it is easy to
    // mistake for one; keyboard traversal should skip it.
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();

    expect(_headingHasFocus(tester), isFalse);
  });

  testWidgets('StreamContextMenuHeading with onTap is activated from the keyboard', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(StreamContextMenuHeading(label: const Text('Devices'), onTap: () => taps += 1)),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(_headingHasFocus(tester), isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(taps, 1);
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

  testWidgets('StreamContextMenuHeading reports an expanded section', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _wrap(StreamContextMenuHeading(label: const Text('Devices'), expanded: true, onTap: () {})),
    );

    expect(
      tester.semantics.find(find.byType(StreamContextMenuHeading)),
      isSemantics(label: 'Devices', hasExpandedState: true, isExpanded: true),
    );
    handle.dispose();
  });

  test('StreamContextMenuHeading rejects expanded without onTap', () {
    expect(() => StreamContextMenuHeading(label: const Text('Devices'), expanded: true), throwsAssertionError);
  });

  testWidgets('StreamContextMenuHeading applies the StreamTheme label style', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StreamContextMenuHeading(label: const Text('Mic')),
        streamTheme: StreamTheme(
          contextMenuHeadingTheme: const StreamContextMenuHeadingThemeData(
            foregroundColor: Color(0xFF111111),
            textStyle: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );

    final style = _labelStyleOf(tester, 'Mic');
    expect(style.color, const Color(0xFF111111));
    expect(style.fontSize, 20);
  });

  testWidgets('StreamContextMenuHeading applies a themed minimum size', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StreamContextMenuHeadingTheme(
          data: const StreamContextMenuHeadingThemeData(minimumSize: Size(300, 64)),
          child: StreamContextMenuHeading(label: const Text('Mic')),
        ),
      ),
    );

    expect(tester.getSize(find.byType(StreamContextMenuHeading)), const Size(300, 64));
  });

  testWidgets('StreamContextMenuHeading applies a themed maximum size', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StreamContextMenuHeadingTheme(
          data: const StreamContextMenuHeadingThemeData(minimumSize: Size.zero, maximumSize: Size(120, 40)),
          child: StreamContextMenuHeading(label: const Text('A very long heading that would not fit')),
        ),
      ),
    );

    expect(tester.getSize(find.byType(StreamContextMenuHeading)).width, 120);
  });

  testWidgets('StreamContextMenuHeading applies themed padding', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StreamContextMenuHeadingTheme(
          data: const StreamContextMenuHeadingThemeData(padding: EdgeInsetsDirectional.only(start: 30)),
          child: StreamContextMenuHeading(label: const Text('Mic')),
        ),
      ),
    );

    final headingLeft = tester.getTopLeft(find.byType(StreamContextMenuHeading)).dx;
    expect(tester.getTopLeft(find.text('Mic')).dx - headingLeft, 30);
  });

  testWidgets('StreamContextMenuHeading applies themed spacing before the trailing widget', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StreamContextMenuHeadingTheme(
          data: const StreamContextMenuHeadingThemeData(spacing: 24),
          child: StreamContextMenuHeading(label: const Text('Mic'), trailing: const Icon(Icons.expand_more)),
        ),
      ),
    );

    // The label is Expanded, so the gap is measured from its box, not its text.
    final labelRight = tester.getTopRight(find.byType(Expanded)).dx;
    expect(tester.getTopLeft(find.byType(Icon)).dx - labelRight, 24);
  });

  testWidgets('StreamContextMenuHeading applies a themed icon size', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StreamContextMenuHeadingTheme(
          data: const StreamContextMenuHeadingThemeData(iconSize: 24),
          child: StreamContextMenuHeading(label: const Text('Mic'), trailing: const Icon(Icons.expand_more)),
        ),
      ),
    );

    expect(tester.getSize(find.byType(Icon)), const Size.square(24));
  });

  testWidgets('StreamContextMenuHeading uses the themed shape for its highlight', (tester) async {
    const shape = StadiumBorder();
    await tester.pumpWidget(
      _wrap(
        StreamContextMenuHeadingTheme(
          data: const StreamContextMenuHeadingThemeData(shape: shape),
          child: StreamContextMenuHeading(label: const Text('Devices'), onTap: () {}),
        ),
      ),
    );

    expect(tester.widget<InkWell>(find.byType(InkWell)).customBorder, shape);
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

  testWidgets('StreamContextMenuHeading highlights pressed, hovered and focused states by default', (tester) async {
    await tester.pumpWidget(_wrap(StreamContextMenuHeading(label: const Text('Devices'), onTap: () {})));

    final colorScheme = _streamThemeOf(tester).colorScheme;
    final overlay = tester.widget<InkWell>(find.byType(InkWell)).overlayColor!;
    expect(overlay.resolve({WidgetState.pressed}), colorScheme.backgroundPressed);
    expect(overlay.resolve({WidgetState.hovered}), colorScheme.backgroundHover);
    expect(overlay.resolve({WidgetState.focused}), colorScheme.backgroundHover);
    expect(overlay.resolve({}), isNot(colorScheme.backgroundHover));
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

bool _headingHasFocus(WidgetTester tester) {
  final focused = FocusManager.instance.primaryFocus?.context;
  if (focused == null) return false;
  return find
      .descendant(of: find.byType(StreamContextMenuHeading), matching: find.byElementPredicate((e) => e == focused))
      .evaluate()
      .isNotEmpty;
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
