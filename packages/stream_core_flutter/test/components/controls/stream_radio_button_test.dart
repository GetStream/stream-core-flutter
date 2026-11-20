import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/video.dart';

Widget _withStreamTheme(Widget child, {StreamTheme? streamTheme}) {
  return MaterialApp(
    theme: ThemeData(extensions: [streamTheme ?? StreamTheme()]),
    home: Scaffold(body: Center(child: child)),
  );
}

ButtonStyle _styleOf(WidgetTester tester) => tester.widget<IconButton>(find.byType(IconButton)).style!;

Size _sizeOf(WidgetTester tester) => tester.getSize(find.byType(StreamRadioButton));

// The size of the dot, which is the innermost decorated box.
Size _dotSizeOf(WidgetTester tester) {
  return tester.getSize(
    find.descendant(of: find.byType(DefaultStreamRadioButton), matching: find.byType(DecoratedBox)).last,
  );
}

const _selected = {WidgetState.selected};
const _disabled = {WidgetState.disabled};
const _disabledSelected = {WidgetState.disabled, WidgetState.selected};

// The shape the button paints, which carries the resolved border.
OutlinedBorder? _paintedShapeOf(WidgetTester tester) {
  return tester.widget<Material>(find.descendant(of: find.byType(IconButton), matching: find.byType(Material))).shape
      as OutlinedBorder?;
}

void main() {
  final colorScheme = StreamColorScheme.light();

  group('StreamRadioButton sizes', () {
    const expected = [
      ('sm', StreamRadioButtonSize.sm, 16.0, 8.0),
      ('md', StreamRadioButtonSize.md, 20.0, 8.0),
      ('lg', StreamRadioButtonSize.lg, 24.0, 10.0),
    ];

    test('values lists every preset from small to large', () {
      expect(StreamRadioButtonSize.values, [for (final (_, size, _, _) in expected) size]);
    });

    test('lerps the diameter and the dot', () {
      expect(
        StreamRadioButtonSize.lerp(StreamRadioButtonSize.sm, StreamRadioButtonSize.lg, 0.5),
        const StreamRadioButtonSize(diameter: 20, dotDiameter: 9),
      );
    });

    testWidgets('renders a custom size', (tester) async {
      const size = StreamRadioButtonSize(diameter: 32, dotDiameter: 12);
      await tester.pumpWidget(_withStreamTheme(StreamRadioButton(selected: true, size: size, onChanged: (_) {})));

      expect(_sizeOf(tester), const Size.square(32));
      expect(_dotSizeOf(tester), const Size.square(12));
    });

    for (final (name, size, diameter, dot) in expected) {
      testWidgets('$name is ${diameter}px with a ${dot}px dot', (tester) async {
        await tester.pumpWidget(_withStreamTheme(StreamRadioButton(selected: true, size: size, onChanged: (_) {})));

        expect(_sizeOf(tester), Size.square(diameter));
        expect(_dotSizeOf(tester), Size.square(dot));
      });

      testWidgets('decorative $name is ${diameter}px with a ${dot}px dot', (tester) async {
        await tester.pumpWidget(_withStreamTheme(StreamRadioButton.decorative(selected: true, size: size)));

        expect(_sizeOf(tester), Size.square(diameter));
        expect(_dotSizeOf(tester), Size.square(dot));
      });
    }

    testWidgets('defaults to lg', (tester) async {
      await tester.pumpWidget(_withStreamTheme(StreamRadioButton(selected: false, onChanged: (_) {})));

      expect(_sizeOf(tester), const Size.square(24));
    });
  });

  group('StreamRadioButton default style', () {
    late ButtonStyle style;

    Future<void> pump(WidgetTester tester) async {
      await tester.pumpWidget(_withStreamTheme(StreamRadioButton(selected: false, onChanged: (_) {})));
      style = _styleOf(tester);
    }

    testWidgets('fills with the accent color when selected', (tester) async {
      await pump(tester);

      expect(style.backgroundColor!.resolve({}), StreamColors.transparent);
      expect(style.backgroundColor!.resolve(_selected), colorScheme.accentPrimary);
      expect(style.backgroundColor!.resolve(_disabledSelected), colorScheme.backgroundDisabled);
    });

    testWidgets('shows the dot only when selected', (tester) async {
      await pump(tester);

      expect(style.foregroundColor!.resolve({}), StreamColors.transparent);
      expect(style.foregroundColor!.resolve(_selected), colorScheme.textOnAccent);
      expect(style.foregroundColor!.resolve(_disabledSelected), colorScheme.textDisabled);
    });

    testWidgets('outlines when unselected and drops the border when selected', (tester) async {
      await pump(tester);

      expect(style.side!.resolve({}), BorderSide(color: colorScheme.borderDefault));
      expect(style.side!.resolve(_selected), BorderSide.none);
      expect(style.side!.resolve(_disabled), BorderSide(color: colorScheme.borderDisabled));
      expect(style.side!.resolve(_disabledSelected), BorderSide.none);
    });

    testWidgets('draws a 2px focus ring whether selected or not', (tester) async {
      await pump(tester);

      final ring = BorderSide(color: colorScheme.borderFocus, width: 2);
      expect(style.side!.resolve({WidgetState.focused}), ring);
      expect(style.side!.resolve({WidgetState.focused, WidgetState.selected}), ring);
    });

    testWidgets('overlays the hover and pressed colors', (tester) async {
      await pump(tester);

      expect(style.overlayColor!.resolve({WidgetState.hovered}), colorScheme.backgroundHover);
      expect(style.overlayColor!.resolve({WidgetState.pressed}), colorScheme.backgroundPressed);
      expect(style.overlayColor!.resolve({WidgetState.focused}), StreamColors.transparent);
    });
  });

  group('StreamRadioButton interaction', () {
    testWidgets('calls onChanged with true when an unselected radio button is tapped', (tester) async {
      final calls = <bool>[];
      await tester.pumpWidget(_withStreamTheme(StreamRadioButton(selected: false, onChanged: calls.add)));

      await tester.tap(find.byType(StreamRadioButton));

      expect(calls, [true]);
    });

    testWidgets('does not call onChanged when the selected radio button is tapped', (tester) async {
      final calls = <bool>[];
      await tester.pumpWidget(_withStreamTheme(StreamRadioButton(selected: true, onChanged: calls.add)));

      await tester.tap(find.byType(StreamRadioButton));

      expect(calls, isEmpty);
    });

    testWidgets('is disabled when onChanged is null', (tester) async {
      await tester.pumpWidget(_withStreamTheme(StreamRadioButton(selected: true, onChanged: null)));

      expect(tester.widget<IconButton>(find.byType(IconButton)).onPressed, isNull);
    });

    testWidgets('can be selected with the keyboard', (tester) async {
      final calls = <bool>[];
      await tester.pumpWidget(_withStreamTheme(StreamRadioButton(selected: false, onChanged: calls.add)));

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();

      expect(calls, [true]);
    });
  });

  group('StreamRadioButton semantics', () {
    testWidgets('announces a checked radio button in a group', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _withStreamTheme(StreamRadioButton(selected: true, onChanged: (_) {}, semanticLabel: 'USB headset')),
      );

      expect(
        tester.getSemantics(find.byType(StreamRadioButton)),
        containsSemantics(
          label: 'USB headset',
          hasCheckedState: true,
          isChecked: true,
          isInMutuallyExclusiveGroup: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
          isFocusable: true,
        ),
      );
      // Checked, not also "selected", so screen readers announce it once.
      expect(
        tester.getSemantics(find.byType(StreamRadioButton)),
        containsSemantics(hasSelectedState: false),
      );
      handle.dispose();
    });

    testWidgets('announces an unchecked radio button', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_withStreamTheme(StreamRadioButton(selected: false, onChanged: (_) {})));

      expect(
        tester.getSemantics(find.byType(StreamRadioButton)),
        containsSemantics(hasCheckedState: true, isChecked: false, isInMutuallyExclusiveGroup: true),
      );
      handle.dispose();
    });

    testWidgets('announces a disabled radio button', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_withStreamTheme(StreamRadioButton(selected: false, onChanged: null)));

      expect(
        tester.getSemantics(find.byType(StreamRadioButton)),
        containsSemantics(hasEnabledState: true, isEnabled: false, hasTapAction: false),
      );
      handle.dispose();
    });
  });

  group('StreamRadioButton.decorative', () {
    testWidgets('adds no semantics, so the row it sits in announces the entry once', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _withStreamTheme(
          StreamListTile(
            leading: StreamRadioButton.decorative(selected: true),
            title: const Text('USB headset'),
            onTap: () {},
          ),
        ),
      );

      expect(find.byType(IconButton), findsNothing);
      expect(
        tester.getSemantics(find.byType(StreamListTile)),
        isNot(containsSemantics(hasCheckedState: true)),
      );
      expect(
        tester.getSemantics(find.byType(StreamListTile)),
        isNot(containsSemantics(isInMutuallyExclusiveGroup: true)),
      );
      handle.dispose();
    });

    testWidgets('takes no tap and no focus of its own', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _withStreamTheme(
          StreamListTile(
            leading: StreamRadioButton.decorative(selected: false),
            title: const Text('USB headset'),
            onTap: () => taps++,
          ),
        ),
      );

      expect(find.descendant(of: find.byType(StreamRadioButton), matching: find.byType(Focus)), findsNothing);

      await tester.tap(find.byType(StreamRadioButton));
      expect(taps, 1);
    });

    testWidgets('uses the theme', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          StreamRadioButtonTheme(
            data: StreamRadioButtonThemeData(style: StreamRadioButtonStyle.from(selectedFillColor: Colors.green)),
            child: StreamRadioButton.decorative(selected: true),
          ),
        ),
      );

      final ring = tester
          .widgetList<DecoratedBox>(
            find.descendant(of: find.byType(DefaultStreamRadioButton), matching: find.byType(DecoratedBox)),
          )
          .first;
      expect((ring.decoration as ShapeDecoration).color, Colors.green);
    });

    testWidgets('has the enabled selected look', (tester) async {
      await tester.pumpWidget(_withStreamTheme(StreamRadioButton.decorative(selected: true)));

      final ring = tester
          .widgetList<DecoratedBox>(
            find.descendant(of: find.byType(DefaultStreamRadioButton), matching: find.byType(DecoratedBox)),
          )
          .first;
      final decoration = ring.decoration as ShapeDecoration;
      expect(decoration.color, colorScheme.accentPrimary);
      expect(decoration.shape, const CircleBorder());
    });

    testWidgets('is outlined when unselected', (tester) async {
      await tester.pumpWidget(_withStreamTheme(StreamRadioButton.decorative(selected: false)));

      final ring = tester
          .widgetList<DecoratedBox>(
            find.descendant(of: find.byType(DefaultStreamRadioButton), matching: find.byType(DecoratedBox)),
          )
          .first;
      final decoration = ring.decoration as ShapeDecoration;
      expect(decoration.color, StreamColors.transparent);
      expect(decoration.shape, CircleBorder(side: BorderSide(color: colorScheme.borderDefault)));
    });
  });

  group('StreamRadioButton theming', () {
    testWidgets('applies the global theme from StreamTheme', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          StreamRadioButton(selected: true, onChanged: (_) {}),
          streamTheme: StreamTheme(
            radioButtonTheme: StreamRadioButtonThemeData(
              style: StreamRadioButtonStyle.from(
                size: const StreamRadioButtonSize(diameter: 16, dotDiameter: 6),
                selectedFillColor: Colors.green,
                selectedDotColor: Colors.black,
              ),
            ),
          ),
        ),
      );

      expect(_sizeOf(tester), const Size.square(16));
      expect(_dotSizeOf(tester), const Size.square(6));
      expect(_styleOf(tester).backgroundColor!.resolve(_selected), Colors.green);
      expect(_styleOf(tester).foregroundColor!.resolve(_selected), Colors.black);
    });

    testWidgets('keeps the focus ring when the theme sets the border', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          StreamRadioButtonTheme(
            data: StreamRadioButtonThemeData(
              style: StreamRadioButtonStyle.from(
                side: const BorderSide(color: Colors.green, width: 2),
                selectedSide: BorderSide.none,
              ),
            ),
            child: StreamRadioButton(selected: false, onChanged: (_) {}),
          ),
        ),
      );

      expect(_paintedShapeOf(tester)?.side, const BorderSide(color: Colors.green, width: 2));

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      expect(_paintedShapeOf(tester)?.side, BorderSide(color: colorScheme.borderFocus, width: 2));
    });

    testWidgets('a local theme beats the global theme', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          StreamRadioButtonTheme(
            data: StreamRadioButtonThemeData(
              style: StreamRadioButtonStyle.from(selectedFillColor: Colors.blue),
            ),
            child: StreamRadioButton(selected: true, onChanged: (_) {}),
          ),
          streamTheme: StreamTheme(
            radioButtonTheme: StreamRadioButtonThemeData(
              style: StreamRadioButtonStyle.from(selectedFillColor: Colors.green, size: StreamRadioButtonSize.md),
            ),
          ),
        ),
      );

      expect(_styleOf(tester).backgroundColor!.resolve(_selected), Colors.blue);
      // Fields the local theme leaves unset still come from the global one.
      expect(_sizeOf(tester), const Size.square(20));
    });

    testWidgets('the size parameter beats the theme size', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          StreamRadioButtonTheme(
            data: const StreamRadioButtonThemeData(style: StreamRadioButtonStyle(size: StreamRadioButtonSize.lg)),
            child: StreamRadioButton(selected: true, size: StreamRadioButtonSize.sm, onChanged: (_) {}),
          ),
        ),
      );

      expect(_sizeOf(tester), const Size.square(16));
    });

    testWidgets('falls back to the defaults for fields the theme leaves unset', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          StreamRadioButtonTheme(
            data: const StreamRadioButtonThemeData(style: StreamRadioButtonStyle(size: StreamRadioButtonSize.md)),
            child: StreamRadioButton(selected: true, onChanged: (_) {}),
          ),
        ),
      );

      expect(_sizeOf(tester), const Size.square(20));
      expect(_dotSizeOf(tester), const Size.square(8));
      expect(_styleOf(tester).backgroundColor!.resolve(_selected), colorScheme.accentPrimary);
    });
  });

  group('StreamRadioButtonStyle.from', () {
    test('sets each value for its own state only', () {
      final style = StreamRadioButtonStyle.from(
        fillColor: Colors.red,
        selectedFillColor: Colors.green,
        disabledFillColor: Colors.grey,
        dotColor: Colors.black,
        selectedDotColor: Colors.white,
        disabledDotColor: Colors.blueGrey,
        overlayColor: Colors.yellow,
        hoveredOverlayColor: Colors.orange,
        pressedOverlayColor: Colors.purple,
        side: const BorderSide(color: Colors.red),
        selectedSide: const BorderSide(color: Colors.green),
        disabledSide: const BorderSide(color: Colors.grey),
      );

      expect(style.fillColor!.resolve({}), Colors.red);
      expect(style.fillColor!.resolve(_selected), Colors.green);
      expect(style.fillColor!.resolve(_disabledSelected), Colors.grey);
      expect(style.dotColor!.resolve({}), Colors.black);
      expect(style.dotColor!.resolve(_selected), Colors.white);
      expect(style.dotColor!.resolve(_disabledSelected), Colors.blueGrey);
      expect(style.overlayColor!.resolve({}), Colors.yellow);
      expect(style.overlayColor!.resolve({WidgetState.hovered}), Colors.orange);
      expect(style.overlayColor!.resolve({WidgetState.hovered, WidgetState.pressed}), Colors.purple);
      expect(style.side!.resolve({}), const BorderSide(color: Colors.red));
      expect(style.side!.resolve(_selected), const BorderSide(color: Colors.green));
      expect(style.side!.resolve(_disabled), const BorderSide(color: Colors.grey));
    });

    test('leaves every property null when no value is given', () {
      final style = StreamRadioButtonStyle.from();

      expect(style.fillColor, isNull);
      expect(style.dotColor, isNull);
      expect(style.overlayColor, isNull);
      expect(style.side, isNull);
    });

    testWidgets('keeps the default for every state it does not set', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          StreamRadioButtonTheme(
            data: StreamRadioButtonThemeData(
              style: StreamRadioButtonStyle.from(
                selectedFillColor: Colors.green,
                selectedSide: const BorderSide(color: Colors.green),
              ),
            ),
            child: StreamRadioButton(selected: false, onChanged: (_) {}),
          ),
        ),
      );

      final style = _styleOf(tester);
      expect(style.backgroundColor!.resolve(_selected), Colors.green);
      expect(style.backgroundColor!.resolve({}), StreamColors.transparent);
      expect(style.backgroundColor!.resolve(_disabledSelected), colorScheme.backgroundDisabled);
      expect(style.side!.resolve(_selected), const BorderSide(color: Colors.green));
      expect(style.side!.resolve({}), BorderSide(color: colorScheme.borderDefault));
      expect(style.side!.resolve(_disabled), BorderSide(color: colorScheme.borderDisabled));
    });
  });

  group('StreamRadioButtonProps', () {
    test('rejects onChanged or a semanticLabel on a decorative radio button', () {
      expect(() => StreamRadioButtonProps(selected: true, decorative: true, onChanged: (_) {}), throwsAssertionError);
      expect(
        () => StreamRadioButtonProps(selected: true, decorative: true, semanticLabel: 'USB headset'),
        throwsAssertionError,
      );
    });

    test('copyWith replaces only the given fields', () {
      const props = StreamRadioButtonProps(selected: false, size: StreamRadioButtonSize.sm, semanticLabel: 'USB');
      final copy = props.copyWith(selected: true);

      expect(copy.selected, isTrue);
      expect(copy.size, StreamRadioButtonSize.sm);
      expect(copy.semanticLabel, 'USB');
      expect(copy.decorative, isFalse);
    });
  });

  group('StreamRadioButton factory', () {
    testWidgets('uses the radioButton builder from StreamComponentFactory', (tester) async {
      StreamRadioButtonProps? receivedProps;

      await tester.pumpWidget(
        _withStreamTheme(
          StreamComponentFactory(
            builders: StreamComponentBuilders(
              radioButton: (context, props) {
                receivedProps = props;
                return const Text('custom');
              },
            ),
            child: StreamRadioButton.decorative(selected: true, size: StreamRadioButtonSize.sm),
          ),
        ),
      );

      expect(find.text('custom'), findsOneWidget);
      expect(find.byType(DefaultStreamRadioButton), findsNothing);
      expect(receivedProps?.selected, isTrue);
      expect(receivedProps?.decorative, isTrue);
      expect(receivedProps?.size, StreamRadioButtonSize.sm);
    });
  });
}
