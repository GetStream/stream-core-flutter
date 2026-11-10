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

/// The size of the dot, which is the innermost decorated box.
Size _dotSizeOf(WidgetTester tester) {
  return tester.getSize(
    find.descendant(of: find.byType(DefaultStreamRadioButton), matching: find.byType(DecoratedBox)).last,
  );
}

const _selected = {WidgetState.selected};
const _disabled = {WidgetState.disabled};
const _disabledSelected = {WidgetState.disabled, WidgetState.selected};

void main() {
  final colorScheme = StreamColorScheme.light();

  group('StreamRadioButton sizes', () {
    const expected = {
      StreamRadioButtonSize.sm: (16.0, 8.0),
      StreamRadioButtonSize.md: (20.0, 8.0),
      StreamRadioButtonSize.lg: (24.0, 10.0),
    };

    for (final MapEntry(key: size, value: (diameter, dot)) in expected.entries) {
      testWidgets('${size.name} is ${diameter}px with a ${dot}px dot', (tester) async {
        await tester.pumpWidget(_withStreamTheme(StreamRadioButton(selected: true, size: size, onChanged: (_) {})));

        expect(_sizeOf(tester), Size.square(diameter));
        expect(_dotSizeOf(tester), Size.square(dot));
      });

      testWidgets('decorative ${size.name} is ${diameter}px with a ${dot}px dot', (tester) async {
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
      await tester.pumpWidget(_withStreamTheme(StreamRadioButton(selected: true)));

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
      await tester.pumpWidget(_withStreamTheme(StreamRadioButton(selected: false)));

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
                size: StreamRadioButtonSize.sm,
                dotSize: 6,
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
