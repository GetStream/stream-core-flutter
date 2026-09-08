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
  StreamSplitButtonVariant variant = StreamSplitButtonVariant.regular,
  IconData trailingIcon = StreamIconData.caretDown,
  VoidCallback? onLeadingPressed,
  VoidCallback? onTrailingPressed,
  String? leadingTooltip,
  String? trailingTooltip,
  StreamSplitButtonStyle? themeStyle,
}) {
  return StreamSplitButton.icon(
    leadingIcon: const Icon(StreamIconData.voiceFill),
    trailingIcon: Icon(trailingIcon),
    variant: variant,
    onLeadingPressed: onLeadingPressed,
    onTrailingPressed: onTrailingPressed,
    leadingTooltip: leadingTooltip,
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
      const buttonStyles = {
        StreamSplitButtonVariant.regular: StreamButtonStyle.secondary,
        StreamSplitButtonVariant.destructive: StreamButtonStyle.destructive,
      };

      for (final MapEntry(key: variant, value: buttonStyle) in buttonStyles.entries) {
        await tester.pumpWidget(
          _withStreamTheme(
            Column(
              children: [
                _splitButton(variant: variant, onLeadingPressed: () {}, onTrailingPressed: () {}),
                StreamButton.icon(icon: const Icon(Icons.mic), style: buttonStyle, onPressed: () {}),
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
          reason: 'surface should match a $buttonStyle StreamButton',
        );
      }
    });

    testWidgets('follows a StreamButtonTheme override', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          streamTheme: StreamTheme(
            buttonTheme: const StreamButtonThemeData(
              secondary: StreamButtonTypeStyle(
                solid: StreamButtonThemeStyle(backgroundColor: WidgetStatePropertyAll(Color(0xFF00FF00))),
              ),
            ),
          ),
          _splitButton(onLeadingPressed: () {}, onTrailingPressed: () {}),
        ),
      );

      expect(_surfaceOf(tester).color, const Color(0xFF00FF00));
    });

    testWidgets('halves paint neither background nor border', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(_splitButton(onLeadingPressed: () {}, onTrailingPressed: () {})),
      );

      for (var index = 0; index < 2; index++) {
        final style = _halfStyleOf(tester, index);
        expect(style.backgroundColor!.resolve(<WidgetState>{})!.a, 0);
        expect(style.side?.resolve(<WidgetState>{}), isNull);
        expect(style.elevation!.resolve(<WidgetState>{}), 0);
      }
    });

    testWidgets('draws no border of its own', (tester) async {
      // Neither variant is outlined.
      await tester.pumpWidget(
        _withStreamTheme(_splitButton(onLeadingPressed: () {}, onTrailingPressed: () {})),
      );

      final shape = _surfaceOf(tester).shape as OutlinedBorder;
      expect(shape.side.style, BorderStyle.none);
    });

    testWidgets('draws a themed border once around the whole control', (tester) async {
      // A theme may still ask for one, and then it wraps the pair rather than
      // outlining each half.
      await tester.pumpWidget(
        _withStreamTheme(
          _splitButton(
            onLeadingPressed: () {},
            onTrailingPressed: () {},
            themeStyle: const StreamSplitButtonStyle(
              buttonStyle: StreamButtonThemeStyle(borderColor: WidgetStatePropertyAll(Color(0xFF00FF00))),
            ),
          ),
        ),
      );

      final shape = _surfaceOf(tester).shape as OutlinedBorder;
      expect(shape.side.color, const Color(0xFF00FF00));

      for (var index = 0; index < 2; index++) {
        expect(_halfStyleOf(tester, index).side?.resolve(<WidgetState>{}), isNull);
      }
    });

    testWidgets('only takes the disabled surface once both halves are disabled', (tester) async {
      final streamTheme = StreamTheme();
      final enabledColor = streamTheme.colorScheme.backgroundSurface;
      final disabledColor = streamTheme.colorScheme.backgroundDisabled;

      await tester.pumpWidget(
        _withStreamTheme(streamTheme: streamTheme, _splitButton(onLeadingPressed: () {})),
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
        _withStreamTheme(_splitButton(onLeadingPressed: () {}, onTrailingPressed: () {})),
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
              _splitButton(onLeadingPressed: () {}, onTrailingPressed: () {}),
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
            onLeadingPressed: () {},
            onTrailingPressed: () {},
            leadingTooltip: 'Mute',
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
            onLeadingPressed: () => pressed++,
            onTrailingPressed: () => trailingPressed++,
            leadingTooltip: 'Mute',
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
          _splitButton(onLeadingPressed: () {}, onTrailingPressed: () {}),
        ),
      );

      final divider = find.descendant(of: find.byType(StreamSplitButton), matching: find.byType(ColoredBox));
      expect(tester.widget<ColoredBox>(divider).color, streamTheme.colorScheme.borderDefault);
      expect(tester.getSize(divider), const Size(1, 24));
    });

    // The divider is drawn on the shared surface, so which colour it takes is
    // a question about that surface rather than about the button's style.
    // At full strength the white hairline cuts the accent surface in two, so
    // the design knocks it back to 35%.
    testWidgets('draws the divider against an accent fill at 35% opacity', (tester) async {
      final streamTheme = StreamTheme();

      await tester.pumpWidget(
        _withStreamTheme(
          streamTheme: streamTheme,
          _splitButton(variant: .destructive, onLeadingPressed: () {}, onTrailingPressed: () {}),
        ),
      );

      final divider = find.descendant(of: find.byType(StreamSplitButton), matching: find.byType(ColoredBox));
      expect(
        tester.widget<ColoredBox>(divider).color,
        streamTheme.colorScheme.borderOnAccent.withValues(alpha: 0.35),
      );
    });

    // A disabled button drops its accent fill for the shared disabled surface,
    // so the divider has to come back to the hairline that reads on it — it
    // used to take borderDisabled and vanish.
    testWidgets('keeps the divider visible while disabled', (tester) async {
      final streamTheme = StreamTheme();

      for (final variant in StreamSplitButtonVariant.values) {
        await tester.pumpWidget(
          _withStreamTheme(streamTheme: streamTheme, _splitButton(variant: variant)),
        );

        final divider = find.descendant(of: find.byType(StreamSplitButton), matching: find.byType(ColoredBox));
        expect(
          tester.widget<ColoredBox>(divider).color,
          streamTheme.colorScheme.borderDefault,
          reason: 'disabled $variant',
        );
      }
    });

    testWidgets('takes the separator style of its own variant', (tester) async {
      // Each variant carries its own entry, so styling the destructive one
      // must leave the regular one alone.
      const themeData = StreamSplitButtonThemeData(
        regular: StreamSplitButtonStyle(separatorColor: WidgetStatePropertyAll(Color(0xFF00FF00))),
        destructive: StreamSplitButtonStyle(separatorColor: WidgetStatePropertyAll(Color(0xFF0000FF))),
      );

      const expected = {
        StreamSplitButtonVariant.regular: Color(0xFF00FF00),
        StreamSplitButtonVariant.destructive: Color(0xFF0000FF),
      };

      for (final MapEntry(key: variant, value: color) in expected.entries) {
        await tester.pumpWidget(
          _withStreamTheme(
            streamTheme: StreamTheme(splitButtonTheme: themeData),
            _splitButton(variant: variant, onLeadingPressed: () {}, onTrailingPressed: () {}),
          ),
        );
        // Settled, or a subtree can still be reporting the previous
        // iteration's colours when it is read.
        await tester.pumpAndSettle();

        final divider = find.descendant(of: find.byType(StreamSplitButton), matching: find.byType(ColoredBox));
        expect(tester.widget<ColoredBox>(divider).color, color, reason: '$variant');
      }
    });

    testWidgets('leaves a variant with no entry on its defaults', (tester) async {
      final streamTheme = StreamTheme(
        splitButtonTheme: const StreamSplitButtonThemeData(
          destructive: StreamSplitButtonStyle(separatorThickness: 4),
        ),
      );

      await tester.pumpWidget(
        _withStreamTheme(
          streamTheme: streamTheme,
          _splitButton(onLeadingPressed: () {}, onTrailingPressed: () {}),
        ),
      );

      final divider = find.descendant(of: find.byType(StreamSplitButton), matching: find.byType(ColoredBox));
      expect(tester.getSize(divider), const Size(1, 24));
    });

    testWidgets('honours separator overrides', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          _splitButton(
            onLeadingPressed: () {},
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
        _withStreamTheme(_splitButton(onLeadingPressed: () {}, onTrailingPressed: () {})),
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
          _splitButton(trailingIcon: StreamIconData.caretUp, onLeadingPressed: () {}, onTrailingPressed: () {}),
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
            child: _splitButton(onLeadingPressed: () {}, onTrailingPressed: () {}),
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
            onLeadingPressed: () => pressed++,
            onTrailingPressed: () => trailingPressed++,
            leadingTooltip: 'Mute',
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
            leadingTooltip: 'Mute',
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
            onLeadingPressed: () {},
            onTrailingPressed: () {},
            leadingTooltip: 'Mute',
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
              splitButton: (context, props) => Text('custom ${props.leadingTooltip}'),
            ),
            child: _splitButton(onLeadingPressed: () {}, onTrailingPressed: () {}, leadingTooltip: 'Mute'),
          ),
        ),
      );

      expect(find.text('custom Mute'), findsOneWidget);
      expect(find.byType(DefaultStreamSplitButton), findsNothing);
    });
  });
}
