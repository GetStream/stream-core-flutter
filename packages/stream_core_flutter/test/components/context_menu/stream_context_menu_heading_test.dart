import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/video.dart';

void main() {
  testWidgets('StreamContextMenuHeading without onTap takes no keyboard focus', (tester) async {
    await tester.pumpWidget(_wrap(StreamContextMenuHeading(label: const Text('Microphone'))));

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

  testWidgets('StreamContextMenuHeading draws a tertiary body-emphasis label', (tester) async {
    await tester.pumpWidget(_wrap(StreamContextMenuHeading(label: const Text('Microphone'))));

    final streamTheme = _streamThemeOf(tester);
    final style = _labelStyleOf(tester, 'Microphone');
    expect(style.color, streamTheme.colorScheme.textTertiary);
    expect(style.fontSize, streamTheme.textTheme.bodyEmphasis.fontSize);
    expect(style.fontWeight, streamTheme.textTheme.bodyEmphasis.fontWeight);
  });

  testWidgets('StreamContextMenuHeading with onTap draws a tertiary body-emphasis label', (tester) async {
    await tester.pumpWidget(_wrap(StreamContextMenuHeading(label: const Text('Devices'), onTap: () {})));

    final streamTheme = _streamThemeOf(tester);
    final style = _labelStyleOf(tester, 'Devices');
    expect(style.color, streamTheme.colorScheme.textTertiary);
    expect(style.fontSize, streamTheme.textTheme.bodyEmphasis.fontSize);
    expect(style.fontWeight, streamTheme.textTheme.bodyEmphasis.fontWeight);
  });

  testWidgets('StreamContextMenuHeading colors and sizes a trailing icon like its label', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StreamContextMenuHeading(label: const Text('Devices'), trailing: const Icon(Icons.expand_more)),
      ),
    );

    expect(_iconColorOf(tester), _streamThemeOf(tester).colorScheme.textTertiary);
    expect(tester.getSize(find.byType(Icon)), const Size.square(20));
  });

  testWidgets('StreamContextMenuHeading with onTap colors and sizes a trailing icon like its label', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StreamContextMenuHeading(
          label: const Text('Devices'),
          trailing: const Icon(Icons.expand_more),
          onTap: () {},
        ),
      ),
    );

    expect(_iconColorOf(tester), _streamThemeOf(tester).colorScheme.textTertiary);
    expect(tester.getSize(find.byType(Icon)), const Size.square(20));
  });

  testWidgets('StreamContextMenuHeading draws a disabled label and icon when not enabled', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StreamContextMenuHeading(
          label: const Text('Devices'),
          trailing: const Icon(Icons.expand_more),
          enabled: false,
          onTap: () {},
        ),
      ),
    );

    final textDisabled = _streamThemeOf(tester).colorScheme.textDisabled;
    expect(_labelStyleOf(tester, 'Devices').color, textDisabled);
    expect(_iconColorOf(tester), textDisabled);
  });

  testWidgets('StreamContextMenuHeading without onTap draws a disabled label when not enabled', (tester) async {
    await tester.pumpWidget(_wrap(StreamContextMenuHeading(label: const Text('Microphone'), enabled: false)));

    expect(_labelStyleOf(tester, 'Microphone').color, _streamThemeOf(tester).colorScheme.textDisabled);
  });

  testWidgets('StreamContextMenuHeading does not call onTap when not enabled', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(StreamContextMenuHeading(label: const Text('Devices'), enabled: false, onTap: () => taps += 1)),
    );

    await tester.tap(find.text('Devices'));

    expect(taps, 0);
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
    expect(tester.getTopLeft(find.text('Microphone')).dx, tester.getTopLeft(find.text('Built-in')).dx);
  });

  testWidgets('StreamContextMenuHeading with onTap lines up with a default StreamContextMenuAction', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StreamContextMenu(
          children: [
            StreamContextMenuHeading(label: const Text('Devices'), onTap: () {}),
            StreamContextMenuAction<void>(label: const Text('Built-in')),
          ],
        ),
      ),
    );

    final headingRect = tester.getRect(find.byType(StreamContextMenuHeading));
    final actionRect = tester.getRect(find.byType(StreamContextMenuAction<void>));
    expect(headingRect.height, actionRect.height);
    expect(tester.getTopLeft(find.text('Devices')).dx, tester.getTopLeft(find.text('Built-in')).dx);
  });

  testWidgets('StreamContextMenuHeading sizes its menu to the default action size of 242 by 40', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StreamContextMenu(
          children: [StreamContextMenuHeading(label: const Text('Microphone'))],
        ),
      ),
    );

    expect(tester.getSize(find.byType(StreamContextMenuHeading)), const Size(242, 40));
  });

  testWidgets('StreamContextMenuHeading with onTap sizes its menu to the default action size of 242 by 40', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        StreamContextMenu(
          children: [StreamContextMenuHeading(label: const Text('Devices'), onTap: () {})],
        ),
      ),
    );

    expect(tester.getSize(find.byType(StreamContextMenuHeading)), const Size(242, 40));
  });

  testWidgets('StreamContextMenuHeading colors and sizes a leading icon like its label', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StreamContextMenuHeading(label: const Text('Video quality'), leading: const Icon(Icons.chevron_left)),
      ),
    );

    expect(_iconColorOf(tester), _streamThemeOf(tester).colorScheme.textTertiary);
    expect(tester.getSize(find.byType(Icon)), const Size.square(20));
  });

  testWidgets('StreamContextMenuHeading with onTap colors and sizes a leading icon like its label', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StreamContextMenuHeading(
          label: const Text('Video quality'),
          leading: const Icon(Icons.chevron_left),
          onTap: () {},
        ),
      ),
    );

    expect(_iconColorOf(tester), _streamThemeOf(tester).colorScheme.textTertiary);
    expect(tester.getSize(find.byType(Icon)), const Size.square(20));
  });

  testWidgets('StreamContextMenuHeading lines up a leading widget with the leading of an action', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StreamContextMenu(
          children: [
            StreamContextMenuHeading(
              label: const Text('Video quality'),
              leading: const Icon(Icons.chevron_left),
              onTap: () {},
            ),
            StreamContextMenuAction<void>(label: const Text('Auto'), leading: const Icon(Icons.check)),
          ],
        ),
      ),
    );

    expect(tester.getTopLeft(find.byIcon(Icons.chevron_left)).dx, tester.getTopLeft(find.byIcon(Icons.check)).dx);
    expect(tester.getTopLeft(find.text('Video quality')).dx, tester.getTopLeft(find.text('Auto')).dx);
  });

  testWidgets('StreamContextMenuHeading puts the leading widget 8 before the label', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StreamContextMenuHeading(label: const Text('Video quality'), leading: const Icon(Icons.chevron_left)),
      ),
    );

    final iconRect = tester.getRect(find.byIcon(Icons.chevron_left));
    final headingRect = tester.getRect(find.byType(StreamContextMenuHeading));
    expect(iconRect.left - headingRect.left, 12);
    expect(tester.getTopLeft(find.text('Video quality')).dx - iconRect.right, 8);
  });

  testWidgets('StreamContextMenuHeading puts the leading widget at the start edge, on the right, in RTL', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        StreamContextMenuHeading(label: const Text('Video quality'), leading: const Icon(Icons.chevron_left)),
        rtl: true,
      ),
    );

    expect(
      tester.getTopLeft(find.byIcon(Icons.chevron_left)).dx,
      greaterThan(tester.getTopRight(find.text('Video quality')).dx),
    );
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

  testWidgets('StreamContextMenuHeading puts the trailing widget at the end edge, on the left, in RTL', (tester) async {
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
      _wrap(StreamContextMenuHeading(label: const Text('Devices'), isExpanded: false, onTap: () {})),
    );

    expect(
      tester.semantics.find(find.byType(StreamContextMenuHeading)),
      isSemantics(
        label: 'Devices',
        isHeader: true,
        isButton: true,
        hasTapAction: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasExpandedState: true,
        isExpanded: false,
      ),
    );
    handle.dispose();
  });

  testWidgets('StreamContextMenuHeading reports an expanded section', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _wrap(StreamContextMenuHeading(label: const Text('Devices'), isExpanded: true, onTap: () {})),
    );

    expect(
      tester.semantics.find(find.byType(StreamContextMenuHeading)),
      isSemantics(label: 'Devices', hasExpandedState: true, isExpanded: true),
    );
    handle.dispose();
  });

  testWidgets('StreamContextMenuHeading with onTap is announced as a disabled button when not enabled', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _wrap(StreamContextMenuHeading(label: const Text('Devices'), enabled: false, onTap: () {})),
    );

    expect(
      tester.semantics.find(find.byType(StreamContextMenuHeading)),
      isSemantics(
        label: 'Devices',
        isHeader: true,
        isButton: true,
        hasTapAction: false,
        hasEnabledState: true,
        isEnabled: false,
      ),
    );
    handle.dispose();
  });

  testWidgets('StreamContextMenuHeading applies the StreamTheme label style', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StreamContextMenuHeading(label: const Text('Mic')),
        streamTheme: StreamTheme(
          contextMenuHeadingTheme: const StreamContextMenuHeadingThemeData(
            style: StreamContextMenuHeadingStyle(
              foregroundColor: WidgetStatePropertyAll(Color(0xFF111111)),
              textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 20)),
            ),
          ),
        ),
      ),
    );

    final style = _labelStyleOf(tester, 'Mic');
    expect(style.color, const Color(0xFF111111));
    expect(style.fontSize, 20);
  });

  testWidgets('StreamContextMenuHeadingTheme beats the StreamTheme heading theme', (tester) async {
    await tester.pumpWidget(
      _wrap(
        _headingTheme(
          const StreamContextMenuHeadingStyle(foregroundColor: WidgetStatePropertyAll(Color(0xFF222222))),
          child: StreamContextMenuHeading(label: const Text('Microphone')),
        ),
        streamTheme: StreamTheme(
          contextMenuHeadingTheme: const StreamContextMenuHeadingThemeData(
            style: StreamContextMenuHeadingStyle(
              foregroundColor: WidgetStatePropertyAll(Color(0xFF111111)),
              textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 20)),
            ),
          ),
        ),
      ),
    );

    final style = _labelStyleOf(tester, 'Microphone');
    expect(style.color, const Color(0xFF222222));
    expect(style.fontSize, 20);
  });

  testWidgets('StreamContextMenuHeading applies a themed minimum size', (tester) async {
    await tester.pumpWidget(
      _wrap(
        _headingTheme(
          const StreamContextMenuHeadingStyle(minimumSize: WidgetStatePropertyAll(Size(300, 64))),
          child: StreamContextMenu(
            children: [StreamContextMenuHeading(label: const Text('Mic'))],
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(StreamContextMenuHeading)), const Size(300, 64));
  });

  testWidgets('StreamContextMenuHeading applies a themed maximum size', (tester) async {
    await tester.pumpWidget(
      _wrap(
        _headingTheme(
          const StreamContextMenuHeadingStyle(
            minimumSize: WidgetStatePropertyAll(Size.zero),
            maximumSize: WidgetStatePropertyAll(Size(120, 40)),
          ),
          child: StreamContextMenuHeading(label: const Text('A very long heading that would not fit')),
        ),
      ),
    );

    expect(tester.getSize(find.byType(StreamContextMenuHeading)).width, 120);
  });

  testWidgets('StreamContextMenuHeading applies themed padding', (tester) async {
    await tester.pumpWidget(
      _wrap(
        _headingTheme(
          const StreamContextMenuHeadingStyle(padding: WidgetStatePropertyAll(EdgeInsetsDirectional.only(start: 30))),
          child: StreamContextMenuHeading(label: const Text('Mic')),
        ),
      ),
    );

    final headingLeft = tester.getTopLeft(find.byType(StreamContextMenuHeading)).dx;
    expect(tester.getTopLeft(find.text('Mic')).dx - headingLeft, 30);
  });

  testWidgets('StreamContextMenuHeading applies a themed icon size', (tester) async {
    await tester.pumpWidget(
      _wrap(
        _headingTheme(
          const StreamContextMenuHeadingStyle(iconSize: WidgetStatePropertyAll(24)),
          child: StreamContextMenuHeading(label: const Text('Mic'), trailing: const Icon(Icons.expand_more)),
        ),
      ),
    );

    expect(tester.getSize(find.byType(Icon)), const Size.square(24));
  });

  testWidgets('StreamContextMenuHeading takes its minimum size from the action theme', (tester) async {
    await tester.pumpWidget(
      _wrap(
        _actionTheme(
          const StreamContextMenuActionStyle(minimumSize: WidgetStatePropertyAll(Size(200, 32))),
          child: StreamContextMenu(
            children: [StreamContextMenuHeading(label: const Text('Mic'))],
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(StreamContextMenuHeading)).width, 200);
  });

  testWidgets('StreamContextMenuHeading with onTap takes its padding from the action theme', (tester) async {
    await tester.pumpWidget(
      _wrap(
        _actionTheme(
          const StreamContextMenuActionStyle(padding: WidgetStatePropertyAll(EdgeInsetsDirectional.only(start: 30))),
          child: StreamContextMenuHeading(label: const Text('Mic'), onTap: () {}),
        ),
      ),
    );

    final headingLeft = tester.getTopLeft(find.byType(StreamContextMenuHeading)).dx;
    expect(tester.getTopLeft(find.text('Mic')).dx - headingLeft, 30);
  });

  testWidgets('StreamContextMenuHeadingTheme metrics beat the action theme metrics', (tester) async {
    await tester.pumpWidget(
      _wrap(
        _actionTheme(
          const StreamContextMenuActionStyle(minimumSize: WidgetStatePropertyAll(Size(200, 32))),
          child: _headingTheme(
            const StreamContextMenuHeadingStyle(minimumSize: WidgetStatePropertyAll(Size(300, 64))),
            child: StreamContextMenu(
              children: [StreamContextMenuHeading(label: const Text('Mic'))],
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(StreamContextMenuHeading)), const Size(300, 64));
  });

  testWidgets('StreamContextMenuHeading with onTap uses the themed shape for its surface', (tester) async {
    await tester.pumpWidget(
      _wrap(
        _headingTheme(
          const StreamContextMenuHeadingStyle(shape: WidgetStatePropertyAll(StadiumBorder())),
          child: StreamContextMenuHeading(label: const Text('Devices'), onTap: () {}),
        ),
      ),
    );

    expect(_surfaceOf(tester).shape, isA<StadiumBorder>());
  });

  testWidgets('StreamContextMenuHeading with onTap rounds its surface with the large radius', (tester) async {
    await tester.pumpWidget(_wrap(StreamContextMenuHeading(label: const Text('Devices'), onTap: () {})));

    final shape = _surfaceOf(tester).shape! as RoundedRectangleBorder;
    expect(shape.borderRadius, BorderRadius.all(_streamThemeOf(tester).radius.lg));
  });

  testWidgets('StreamContextMenuHeading highlights a hovered heading', (tester) async {
    await tester.pumpWidget(_wrap(StreamContextMenuHeading(label: const Text('Devices'), onTap: () {})));

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: tester.getCenter(find.text('Devices')));
    await tester.pumpAndSettle();

    expect(_inkOf(tester), paints..rect(color: _streamThemeOf(tester).colorScheme.backgroundHover));
  });

  testWidgets('StreamContextMenuHeading highlights a pressed heading', (tester) async {
    await tester.pumpWidget(_wrap(StreamContextMenuHeading(label: const Text('Devices'), onTap: () {})));

    final gesture = await tester.startGesture(tester.getCenter(find.text('Devices')));
    addTearDown(gesture.up);
    await tester.pumpAndSettle();

    expect(_inkOf(tester), paints..rect(color: _streamThemeOf(tester).colorScheme.backgroundPressed));
  });

  testWidgets('StreamContextMenuHeading draws a focus ring around a focused heading', (tester) async {
    await tester.pumpWidget(_wrap(StreamContextMenuHeading(label: const Text('Devices'), onTap: () {})));

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();

    final shape = _surfaceOf(tester).shape! as OutlinedBorder;
    expect(shape.side, BorderSide(color: _streamThemeOf(tester).colorScheme.borderFocus, width: 2));
  });

  testWidgets('StreamContextMenuHeading does not fill a focused heading', (tester) async {
    await tester.pumpWidget(_wrap(StreamContextMenuHeading(label: const Text('Devices'), onTap: () {})));

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();

    final colorScheme = _streamThemeOf(tester).colorScheme;
    expect(_inkOf(tester), isNot(paints..rect(color: colorScheme.backgroundHover)));
    expect(_inkOf(tester), isNot(paints..rect(color: colorScheme.backgroundPressed)));
  });

  testWidgets('StreamContextMenuHeading uses the themed overlay color when pressed', (tester) async {
    await tester.pumpWidget(
      _wrap(
        _headingTheme(
          const StreamContextMenuHeadingStyle(overlayColor: WidgetStatePropertyAll(Color(0xFF333333))),
          child: StreamContextMenuHeading(label: const Text('Devices'), onTap: () {}),
        ),
      ),
    );

    final gesture = await tester.startGesture(tester.getCenter(find.text('Devices')));
    addTearDown(gesture.up);
    await tester.pumpAndSettle();

    expect(_inkOf(tester), paints..rect(color: const Color(0xFF333333)));
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

Color? _iconColorOf(WidgetTester tester) {
  final iconText = tester.widget<RichText>(find.descendant(of: find.byType(Icon), matching: find.byType(RichText)));
  return iconText.text.style!.color;
}

// The surface a tappable heading draws its highlight and outline on.
Material _surfaceOf(WidgetTester tester) {
  return tester.widget<Material>(
    find.descendant(of: find.byType(StreamContextMenuHeading), matching: find.byType(Material)).first,
  );
}

MaterialInkController _inkOf(WidgetTester tester) => Material.of(tester.element(find.text('Devices')));

Widget _headingTheme(StreamContextMenuHeadingStyle style, {required Widget child}) {
  return StreamContextMenuHeadingTheme(
    data: StreamContextMenuHeadingThemeData(style: style),
    child: child,
  );
}

Widget _actionTheme(StreamContextMenuActionStyle style, {required Widget child}) {
  return StreamContextMenuActionTheme(
    data: StreamContextMenuActionThemeData(style: style),
    child: child,
  );
}

Widget _wrap(
  Widget child, {
  bool rtl = false,
  double textScale = 1,
  StreamTheme? streamTheme,
}) {
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
