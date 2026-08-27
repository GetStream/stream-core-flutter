import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/video.dart';

Widget _withStreamTheme(Widget child, {StreamTheme? streamTheme}) {
  return MaterialApp(
    theme: ThemeData(extensions: [streamTheme ?? StreamTheme()]),
    home: Scaffold(body: Center(child: child)),
  );
}

StreamSplitButton _splitButton({
  StreamButtonStyle style = StreamButtonStyle.primary,
  StreamButtonType type = StreamButtonType.solid,
  IconData trailingIcon = StreamIconData.caretDown,
  VoidCallback? onPressed,
  VoidCallback? onTrailingPressed,
  String? tooltip,
  String? trailingTooltip,
  StreamSplitButtonStyle? themeStyle,
}) {
  return StreamSplitButton.icon(
    icon: const Icon(StreamIconData.voiceFill),
    trailingIcon: Icon(trailingIcon),
    style: style,
    type: type,
    onPressed: onPressed,
    onTrailingPressed: onTrailingPressed,
    tooltip: tooltip,
    trailingTooltip: trailingTooltip,
    themeStyle: themeStyle,
  );
}

/// The shared surface both halves sit on.
Finder _surfaceFinder() {
  return find.descendant(of: find.byType(StreamSplitButton), matching: find.byType(DecoratedBox)).first;
}

/// The [ShapeDecoration] of the shared surface both halves sit on.
ShapeDecoration _surfaceOf(WidgetTester tester) {
  return tester.widget<DecoratedBox>(_surfaceFinder()).decoration as ShapeDecoration;
}

/// The resolved [ButtonStyle] of the half at [index] (0 leading, 1 trailing).
ButtonStyle _halfStyleOf(WidgetTester tester, int index) {
  final button = tester.widget<ElevatedButton>(
    find.descendant(of: find.byType(StreamSplitButton), matching: find.byType(ElevatedButton)).at(index),
  );
  return button.style!;
}

void main() {
  group('StreamSplitButton surface', () {
    testWidgets('paints the background a StreamButton of the same variant would', (tester) async {
      // The whole point of the component: the surface and the halves resolve
      // from one button style, so they cannot drift into different colours.
      for (final style in StreamButtonStyle.values) {
        await tester.pumpWidget(
          _withStreamTheme(
            Column(
              children: [
                _splitButton(style: style, onPressed: () {}, onTrailingPressed: () {}),
                StreamButton.icon(icon: const Icon(Icons.mic), style: style, onPressed: () {}),
              ],
            ),
          ),
        );

        final reference = tester.widget<ElevatedButton>(
          find.descendant(of: find.byType(StreamButton).last, matching: find.byType(ElevatedButton)),
        );

        expect(
          _surfaceOf(tester).color,
          reference.style!.backgroundColor!.resolve(<WidgetState>{}),
          reason: 'surface should match a $style StreamButton',
        );
      }
    });

    testWidgets('follows a StreamButtonTheme override', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          streamTheme: StreamTheme(
            buttonTheme: const StreamButtonThemeData(
              primary: StreamButtonTypeStyle(
                solid: StreamButtonThemeStyle(backgroundColor: WidgetStatePropertyAll(Color(0xFF00FF00))),
              ),
            ),
          ),
          _splitButton(onPressed: () {}, onTrailingPressed: () {}),
        ),
      );

      expect(_surfaceOf(tester).color, const Color(0xFF00FF00));
    });

    testWidgets('halves paint neither background nor border', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          _splitButton(type: StreamButtonType.outline, onPressed: () {}, onTrailingPressed: () {}),
        ),
      );

      for (var index = 0; index < 2; index++) {
        final style = _halfStyleOf(tester, index);
        expect(style.backgroundColor!.resolve(<WidgetState>{})!.a, 0);
        expect(style.side?.resolve(<WidgetState>{}), isNull);
        expect(style.elevation!.resolve(<WidgetState>{}), 0);
      }
    });

    testWidgets('outline draws a single border around the whole control', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          _splitButton(type: StreamButtonType.outline, onPressed: () {}, onTrailingPressed: () {}),
        ),
      );

      final shape = _surfaceOf(tester).shape as OutlinedBorder;
      expect(shape.side.style, BorderStyle.solid);
    });

    testWidgets('solid draws no border', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(_splitButton(onPressed: () {}, onTrailingPressed: () {})),
      );

      final shape = _surfaceOf(tester).shape as OutlinedBorder;
      expect(shape.side.style, BorderStyle.none);
    });

    testWidgets('only takes the disabled surface once both halves are disabled', (tester) async {
      final streamTheme = StreamTheme();
      final enabledColor = streamTheme.colorScheme.accentPrimary;
      final disabledColor = streamTheme.colorScheme.backgroundDisabled;

      await tester.pumpWidget(
        _withStreamTheme(streamTheme: streamTheme, _splitButton(onPressed: () {})),
      );
      expect(_surfaceOf(tester).color, enabledColor);

      await tester.pumpWidget(
        _withStreamTheme(streamTheme: streamTheme, _splitButton(onTrailingPressed: () {})),
      );
      expect(_surfaceOf(tester).color, enabledColor);

      await tester.pumpWidget(_withStreamTheme(streamTheme: streamTheme, _splitButton()));
      expect(_surfaceOf(tester).color, disabledColor);
    });
  });

  group('StreamSplitButton layout', () {
    testWidgets('matches the design: 89x48 control over an 81x40 surface', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(_splitButton(style: .secondary, onPressed: () {}, onTrailingPressed: () {})),
      );

      // The control is wider than the surface it paints: the same 4pt inset
      // that lets the tap targets overhang the surface vertically is mirrored
      // horizontally, so neighbouring widgets do not butt against the ends.
      expect(tester.getSize(find.byType(StreamSplitButton)), const Size(89, 48));
      expect(tester.getSize(_surfaceFinder()), const Size(81, 40));

      final halves = find.descendant(of: find.byType(StreamSplitButton), matching: find.byType(StreamButton));
      expect(tester.getSize(halves.at(0)), const Size(32, 32));
      expect(tester.getSize(halves.at(1)), const Size(32, 32));

      // The icons are drawn at 20 in a 40-tall surface. Get either number
      // wrong and the glyphs read as too big for the control.
      expect(_halfStyleOf(tester, 0).iconSize!.resolve(<WidgetState>{}), 20);
      expect(_halfStyleOf(tester, 1).iconSize!.resolve(<WidgetState>{}), 20);
    });

    testWidgets('paints a surface as tall as a lone medium StreamButton', (tester) async {
      // The reason the surface is not simply the height of the tap targets:
      // side by side with a plain icon button, the two have to line up.
      await tester.pumpWidget(
        _withStreamTheme(
          Column(
            children: [
              _splitButton(style: .secondary, onPressed: () {}, onTrailingPressed: () {}),
              StreamButton.icon(icon: const Icon(Icons.mic), style: .secondary, onPressed: () {}),
            ],
          ),
        ),
      );

      final reference = tester.getSize(
        find.descendant(of: find.byType(StreamButton).last, matching: find.byType(Material)).first,
      );
      expect(tester.getSize(_surfaceFinder()).height, reference.height);
    });

    testWidgets('keeps a full-height tap target per half whatever the button theme asks for', (tester) async {
      // A theme that shrink-wraps every button must not shrink the halves
      // below the platform tap target. Note the design makes the halves
      // narrower than tall, so they clear the height but not the width the
      // platform guidelines ask for.
      await tester.pumpWidget(
        _withStreamTheme(
          streamTheme: StreamTheme(
            buttonTheme: StreamButtonThemeData.all(
              StreamButtonTypeStyle.all(
                StreamButtonThemeStyle.from(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              ),
            ),
          ),
          _splitButton(
            onPressed: () {},
            onTrailingPressed: () {},
            tooltip: 'Mute',
            trailingTooltip: 'Audio settings',
          ),
        ),
      );

      final handle = tester.ensureSemantics();
      for (final tooltip in ['Mute', 'Audio settings']) {
        final node = tester.getSemantics(find.byTooltip(tooltip));
        expect(node.rect.height, kMinInteractiveDimension, reason: '$tooltip tap target height');
      }
      handle.dispose();
    });

    testWidgets('taps land on the half they overhang, not its neighbour', (tester) async {
      // Each half's target is taller than what it paints, so the two overhang
      // the surface. Material's own tap-target padding answers every hit test
      // regardless of position, which would let the trailing half swallow taps
      // meant for the leading one.
      var pressed = 0;
      var trailingPressed = 0;

      await tester.pumpWidget(
        _withStreamTheme(
          _splitButton(
            onPressed: () => pressed++,
            onTrailingPressed: () => trailingPressed++,
            tooltip: 'Mute',
            trailingTooltip: 'Audio settings',
          ),
        ),
      );

      final control = tester.getRect(find.byType(StreamSplitButton));
      final leading = tester.getRect(find.byTooltip('Mute'));
      final trailing = tester.getRect(find.byTooltip('Audio settings'));
      expect(leading.top, greaterThan(control.top), reason: 'the paint should sit inside the target');

      await tester.tapAt(Offset(leading.center.dx, control.top + 2));
      await tester.pumpAndSettle();
      expect((pressed, trailingPressed), (1, 0));

      await tester.tapAt(Offset(trailing.center.dx, control.bottom - 2));
      await tester.pumpAndSettle();
      expect((pressed, trailingPressed), (1, 1));
    });

    testWidgets('separates the halves with a divider inset from the rounded ends', (tester) async {
      final streamTheme = StreamTheme();
      await tester.pumpWidget(
        _withStreamTheme(
          streamTheme: streamTheme,
          _splitButton(onPressed: () {}, onTrailingPressed: () {}),
        ),
      );

      final divider = find.descendant(of: find.byType(StreamSplitButton), matching: find.byType(ColoredBox));
      expect(tester.widget<ColoredBox>(divider).color, streamTheme.colorScheme.borderDefault);
      expect(tester.getSize(divider), const Size(1, 24));
    });

    testWidgets('honours separator overrides', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          _splitButton(
            onPressed: () {},
            onTrailingPressed: () {},
            themeStyle: const StreamSplitButtonStyle(
              separatorColor: WidgetStatePropertyAll(Color(0xFFFF0000)),
              separatorThickness: 2,
              separatorHeight: 10,
            ),
          ),
        ),
      );

      final divider = find.descendant(of: find.byType(StreamSplitButton), matching: find.byType(ColoredBox));
      expect(tester.widget<ColoredBox>(divider).color, const Color(0xFFFF0000));
      expect(tester.getSize(divider), const Size(2, 10));
    });
  });

  group('StreamSplitButton icons', () {
    testWidgets('renders the leading icon before the trailing one', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(_splitButton(onPressed: () {}, onTrailingPressed: () {})),
      );

      final leading = tester.getCenter(find.byIcon(StreamIconData.voiceFill));
      final trailing = tester.getCenter(find.byIcon(StreamIconData.caretDown));
      expect(leading.dx, lessThan(trailing.dx));
    });

    testWidgets('takes whichever caret the trailing half should show', (tester) async {
      // The half can open a menu above or below, so the caret is the caller's
      // to pick rather than something the component hard-codes.
      await tester.pumpWidget(
        _withStreamTheme(
          _splitButton(trailingIcon: StreamIconData.caretUp, onPressed: () {}, onTrailingPressed: () {}),
        ),
      );

      expect(find.byIcon(StreamIconData.caretUp), findsOneWidget);
      expect(find.byIcon(StreamIconData.caretDown), findsNothing);
    });

    testWidgets('mirrors the halves in RTL', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          Directionality(
            textDirection: TextDirection.rtl,
            child: _splitButton(onPressed: () {}, onTrailingPressed: () {}),
          ),
        ),
      );

      final leading = tester.getCenter(find.byIcon(StreamIconData.voiceFill));
      final trailing = tester.getCenter(find.byIcon(StreamIconData.caretDown));
      expect(leading.dx, greaterThan(trailing.dx));
    });
  });

  group('StreamSplitButton interaction', () {
    testWidgets('each half fires only its own callback', (tester) async {
      var pressed = 0;
      var trailingPressed = 0;

      await tester.pumpWidget(
        _withStreamTheme(
          _splitButton(
            onPressed: () => pressed++,
            onTrailingPressed: () => trailingPressed++,
            tooltip: 'Mute',
            trailingTooltip: 'Audio settings',
          ),
        ),
      );

      await tester.tap(find.byTooltip('Mute'));
      await tester.pumpAndSettle();
      expect((pressed, trailingPressed), (1, 0));

      await tester.tap(find.byTooltip('Audio settings'));
      await tester.pumpAndSettle();
      expect((pressed, trailingPressed), (1, 1));
    });

    testWidgets('a disabled half stays inert while the other still works', (tester) async {
      var trailingPressed = 0;

      await tester.pumpWidget(
        _withStreamTheme(
          _splitButton(
            onTrailingPressed: () => trailingPressed++,
            tooltip: 'Mute',
            trailingTooltip: 'Audio settings',
          ),
        ),
      );

      await tester.tap(find.byTooltip('Mute'));
      await tester.tap(find.byTooltip('Audio settings'));
      await tester.pumpAndSettle();

      expect(trailingPressed, 1);
    });

    testWidgets('exposes one accessibility node per half', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _withStreamTheme(
          _splitButton(
            onPressed: () {},
            onTrailingPressed: () {},
            tooltip: 'Mute',
            trailingTooltip: 'Audio settings',
          ),
        ),
      );

      for (final tooltip in ['Mute', 'Audio settings']) {
        expect(
          tester.getSemantics(find.byTooltip(tooltip)),
          isSemantics(
            tooltip: tooltip,
            isButton: true,
            isEnabled: true,
            hasEnabledState: true,
            hasTapAction: true,
          ),
        );
      }

      handle.dispose();
    });
  });

  group('StreamSplitButton factory', () {
    testWidgets('defers to a StreamComponentFactory builder', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          StreamComponentFactory(
            builders: StreamComponentBuilders(
              splitButton: (context, props) => Text('custom ${props.tooltip}'),
            ),
            child: _splitButton(onPressed: () {}, onTrailingPressed: () {}, tooltip: 'Mute'),
          ),
        ),
      );

      expect(find.text('custom Mute'), findsOneWidget);
      expect(find.byType(DefaultStreamSplitButton), findsNothing);
    });
  });
}
