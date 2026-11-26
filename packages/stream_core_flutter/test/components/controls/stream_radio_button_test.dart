import 'package:flutter/gestures.dart';
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

// A group of one radio button per value, selecting groupValue.
Widget _group<T>(
  List<T> values, {
  required T? groupValue,
  ValueChanged<T?>? onChanged,
  bool toggleable = false,
  bool? enabled,
  StreamRadioButtonSize? size,
}) {
  return RadioGroup<T>(
    groupValue: groupValue,
    onChanged: onChanged ?? (_) {},
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final value in values)
          StreamRadioButton<T>(
            key: ValueKey(value),
            value: value,
            toggleable: toggleable,
            enabled: enabled,
            size: size,
            semanticLabel: '$value',
          ),
      ],
    ),
  );
}

// A single radio button, selected or not, inside its own group.
Widget _radio({required bool selected, bool? enabled, StreamRadioButtonSize? size}) {
  return RadioGroup<bool>(
    groupValue: true,
    onChanged: (_) {},
    child: StreamRadioButton(value: selected, enabled: enabled, size: size),
  );
}

// The painted parts of the first radio button or indicator under [of].
class _Painted {
  _Painted(this.tester, this.of);

  final WidgetTester tester;
  final Finder of;

  Container get _outer => tester.widgetList<Container>(find.descendant(of: of, matching: find.byType(Container))).first;
  Finder get _indicator => find.descendant(of: of, matching: find.byType(Container)).last;

  Size get size => tester.getSize(find.descendant(of: of, matching: find.byType(Container)).first);
  Size get indicatorSize => tester.getSize(_indicator);
  Color? get background => (_outer.decoration! as ShapeDecoration).color;
  BorderSide get side => ((_outer.foregroundDecoration! as ShapeDecoration).shape as CircleBorder).side;
  Color? get indicator => (tester.widget<Container>(_indicator).decoration! as BoxDecoration).color;
  Color? get overlay {
    final center = find.descendant(of: of, matching: find.byType(Center)).last;
    final box = tester.widget<DecoratedBox>(find.ancestor(of: center, matching: find.byType(DecoratedBox)).first);
    return (box.decoration as ShapeDecoration).color;
  }
}

_Painted _paintedRadio(WidgetTester tester) => _Painted(tester, find.byType(StreamRadioButton<bool>).first);

Future<void> _focusWithKeyboard(WidgetTester tester) async {
  FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
  addTearDown(() => FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic);
  await tester.sendKeyEvent(LogicalKeyboardKey.tab);
  await tester.pump();
}

void main() {
  final colorScheme = StreamColorScheme.light();

  group('StreamRadioButtonSize', () {
    test('values lists every preset from small to large', () {
      expect(StreamRadioButtonSize.values, [
        StreamRadioButtonSize.sm,
        StreamRadioButtonSize.md,
        StreamRadioButtonSize.lg,
      ]);
    });

    test('lerps the diameter and the indicator', () {
      expect(
        StreamRadioButtonSize.lerp(StreamRadioButtonSize.sm, StreamRadioButtonSize.lg, 0.5),
        const StreamRadioButtonSize(diameter: 20, indicatorDiameter: 9),
      );
    });
  });

  group('StreamRadioButton sizes', () {
    const expected = [
      ('sm', StreamRadioButtonSize.sm, 16.0, 8.0),
      ('md', StreamRadioButtonSize.md, 20.0, 8.0),
      ('lg', StreamRadioButtonSize.lg, 24.0, 10.0),
    ];

    testWidgets('renders a custom size', (tester) async {
      const size = StreamRadioButtonSize(diameter: 32, indicatorDiameter: 12);
      await tester.pumpWidget(_withStreamTheme(_radio(selected: true, size: size)));

      expect(_paintedRadio(tester).size, const Size.square(32));
      expect(_paintedRadio(tester).indicatorSize, const Size.square(12));
    });

    for (final (name, size, diameter, indicator) in expected) {
      testWidgets('$name is ${diameter}px with a ${indicator}px indicator', (tester) async {
        await tester.pumpWidget(_withStreamTheme(_radio(selected: true, size: size)));

        expect(tester.getSize(find.byType(StreamRadioButton<bool>)), Size.square(diameter));
        expect(_paintedRadio(tester).indicatorSize, Size.square(indicator));
      });

      testWidgets('StreamRadioIndicator $name is ${diameter}px with a ${indicator}px indicator', (tester) async {
        await tester.pumpWidget(_withStreamTheme(StreamRadioIndicator(selected: true, size: size)));

        final painted = _Painted(tester, find.byType(StreamRadioIndicator));
        expect(tester.getSize(find.byType(StreamRadioIndicator)), Size.square(diameter));
        expect(painted.indicatorSize, Size.square(indicator));
      });
    }

    testWidgets('defaults to lg', (tester) async {
      await tester.pumpWidget(_withStreamTheme(_radio(selected: false)));

      expect(tester.getSize(find.byType(StreamRadioButton<bool>)), const Size.square(24));
    });
  });

  group('StreamRadioButton default style', () {
    testWidgets('fills with the accent color when selected', (tester) async {
      await tester.pumpWidget(_withStreamTheme(_radio(selected: true)));

      expect(_paintedRadio(tester).background, colorScheme.accentPrimary);
      expect(_paintedRadio(tester).indicator, colorScheme.textOnAccent);
      expect(_paintedRadio(tester).side, BorderSide.none);
    });

    testWidgets('is outlined with a hidden indicator when unselected', (tester) async {
      await tester.pumpWidget(_withStreamTheme(_radio(selected: false)));

      expect(_paintedRadio(tester).background, StreamColors.transparent);
      expect(_paintedRadio(tester).indicator, StreamColors.transparent);
      expect(_paintedRadio(tester).side, BorderSide(color: colorScheme.borderDefault));
    });

    testWidgets('uses the disabled colors when selected and disabled', (tester) async {
      await tester.pumpWidget(_withStreamTheme(_radio(selected: true, enabled: false)));

      expect(_paintedRadio(tester).background, colorScheme.backgroundDisabled);
      expect(_paintedRadio(tester).indicator, colorScheme.textDisabled);
      expect(_paintedRadio(tester).side, BorderSide.none);
    });

    testWidgets('uses the disabled border when unselected and disabled', (tester) async {
      await tester.pumpWidget(_withStreamTheme(_radio(selected: false, enabled: false)));

      expect(_paintedRadio(tester).side, BorderSide(color: colorScheme.borderDisabled));
    });

    testWidgets('overlays the hover color while hovered', (tester) async {
      await tester.pumpWidget(_withStreamTheme(_radio(selected: false)));

      FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
      addTearDown(() => FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic);
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer();
      await mouse.moveTo(tester.getCenter(find.byType(StreamRadioButton<bool>)));
      await tester.pump();

      expect(_paintedRadio(tester).overlay, colorScheme.backgroundHover);
    });

    testWidgets('overlays the pressed color while pressed', (tester) async {
      await tester.pumpWidget(_withStreamTheme(_radio(selected: false)));

      final press = await tester.startGesture(tester.getCenter(find.byType(StreamRadioButton<bool>)));
      await tester.pump(kPressTimeout);

      expect(_paintedRadio(tester).overlay, colorScheme.backgroundPressed);

      await press.up();
      await tester.pump();

      expect(_paintedRadio(tester).overlay, StreamColors.transparent);
    });

    for (final selected in [true, false]) {
      testWidgets('draws a 2px focus ring in place of the border (${selected ? 'on' : 'off'})', (tester) async {
        await tester.pumpWidget(_withStreamTheme(_radio(selected: selected)));

        await _focusWithKeyboard(tester);

        expect(_paintedRadio(tester).side, BorderSide(color: colorScheme.borderFocus, width: 2));
      });
    }
  });

  group('StreamRadioButton interaction', () {
    testWidgets('selects its value in the RadioGroup when tapped', (tester) async {
      final changes = <String?>[];
      await tester.pumpWidget(_withStreamTheme(_group<String>(['a', 'b'], groupValue: 'a', onChanged: changes.add)));

      await tester.tap(find.byKey(const ValueKey('b')));

      expect(changes, ['b']);
    });

    testWidgets('does not change the group when the selected radio button is tapped', (tester) async {
      final changes = <String?>[];
      await tester.pumpWidget(_withStreamTheme(_group<String>(['a', 'b'], groupValue: 'a', onChanged: changes.add)));

      await tester.tap(find.byKey(const ValueKey('a')));

      expect(changes, isEmpty);
    });

    testWidgets('deselects the group when a toggleable selected radio button is tapped', (tester) async {
      final changes = <String?>[];
      await tester.pumpWidget(
        _withStreamTheme(_group<String>(['a', 'b'], groupValue: 'a', onChanged: changes.add, toggleable: true)),
      );

      await tester.tap(find.byKey(const ValueKey('a')));

      expect(changes, [null]);
    });

    testWidgets('ignores taps when enabled is false', (tester) async {
      final changes = <String?>[];
      await tester.pumpWidget(
        _withStreamTheme(_group<String>(['a', 'b'], groupValue: 'a', onChanged: changes.add, enabled: false)),
      );

      await tester.tap(find.byKey(const ValueKey('b')));

      expect(changes, isEmpty);
    });

    testWidgets('is disabled without a RadioGroup above it', (tester) async {
      await tester.pumpWidget(_withStreamTheme(StreamRadioButton(value: 'a')));

      expect(
        _Painted(tester, find.byType(StreamRadioButton<String>)).side,
        BorderSide(color: colorScheme.borderDisabled),
      );
    });

    testWidgets('can be selected with the keyboard', (tester) async {
      final changes = <String?>[];
      await tester.pumpWidget(_withStreamTheme(_group<String>(['a'], groupValue: null, onChanged: changes.add)));

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();

      expect(changes, ['a']);
    });

    testWidgets('moves the selection with the arrow keys', (tester) async {
      String? groupValue = 'a';
      await tester.pumpWidget(
        _withStreamTheme(
          StatefulBuilder(
            builder: (context, setState) => _group(
              ['a', 'b'],
              groupValue: groupValue,
              onChanged: (value) => setState(() => groupValue = value),
            ),
          ),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      expect(groupValue, 'b');
    });
  });

  group('StreamRadioButton semantics', () {
    testWidgets(
      'announces a checked radio button in a group, not a button',
      (tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(_withStreamTheme(_group<String>(['USB headset'], groupValue: 'USB headset')));

        expect(
          tester.getSemantics(find.byType(StreamRadioButton<String>)),
          isSemantics(
            label: 'USB headset',
            hasCheckedState: true,
            isChecked: true,
            isInMutuallyExclusiveGroup: true,
            hasEnabledState: true,
            isEnabled: true,
            isFocusable: true,
            hasTapAction: true,
            hasFocusAction: true,
          ),
        );
        handle.dispose();
      },
      variant: const TargetPlatformVariant({TargetPlatform.android}),
    );

    testWidgets(
      'also marks the radio button as selected on Apple platforms',
      (tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(_withStreamTheme(_group<String>(['a'], groupValue: 'a')));

        expect(
          tester.getSemantics(find.byType(StreamRadioButton<String>)),
          containsSemantics(isChecked: true, hasSelectedState: true, isSelected: true, isButton: false),
        );
        handle.dispose();
      },
      variant: const TargetPlatformVariant({TargetPlatform.iOS, TargetPlatform.macOS}),
    );

    testWidgets(
      'hints that an unselected radio button is not selected on Apple platforms',
      (tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(_withStreamTheme(_group<String>(['a'], groupValue: null)));

        expect(
          tester.getSemantics(find.byType(StreamRadioButton<String>)),
          containsSemantics(isChecked: false, hasSelectedState: true, isSelected: false, hint: 'Not selected'),
        );
        handle.dispose();
      },
      variant: const TargetPlatformVariant({TargetPlatform.iOS, TargetPlatform.macOS}),
    );

    testWidgets('announces an unchecked radio button', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_withStreamTheme(_group<String>(['a'], groupValue: null)));

      expect(
        tester.getSemantics(find.byType(StreamRadioButton<String>)),
        containsSemantics(hasCheckedState: true, isChecked: false, isInMutuallyExclusiveGroup: true),
      );
      handle.dispose();
    });

    testWidgets('announces a disabled radio button', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_withStreamTheme(_group<String>(['a'], groupValue: null, enabled: false)));

      expect(
        tester.getSemantics(find.byType(StreamRadioButton<String>)),
        containsSemantics(hasEnabledState: true, isEnabled: false, hasTapAction: false),
      );
      handle.dispose();
    });
  });

  group('StreamRadioIndicator', () {
    testWidgets('adds no semantics, so the row it sits in announces the entry once', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _withStreamTheme(
          StreamListTile(
            leading: const StreamRadioIndicator(selected: true),
            title: const Text('USB headset'),
            onTap: () {},
          ),
        ),
      );

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
            leading: const StreamRadioIndicator(selected: false),
            title: const Text('USB headset'),
            onTap: () => taps++,
          ),
        ),
      );

      expect(find.descendant(of: find.byType(StreamRadioIndicator), matching: find.byType(Focus)), findsNothing);

      await tester.tap(find.byType(StreamRadioIndicator));
      expect(taps, 1);
    });

    testWidgets('uses the radio button theme', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          StreamRadioButtonTheme(
            data: StreamRadioButtonThemeData(style: StreamRadioButtonStyle.from(selectedBackgroundColor: Colors.green)),
            child: const StreamRadioIndicator(selected: true),
          ),
        ),
      );

      expect(_Painted(tester, find.byType(StreamRadioIndicator)).background, Colors.green);
    });

    testWidgets('has the enabled selected look', (tester) async {
      await tester.pumpWidget(_withStreamTheme(const StreamRadioIndicator(selected: true)));

      final painted = _Painted(tester, find.byType(StreamRadioIndicator));
      expect(painted.background, colorScheme.accentPrimary);
      expect(painted.indicator, colorScheme.textOnAccent);
      expect(painted.side, BorderSide.none);
    });

    testWidgets('is outlined when unselected', (tester) async {
      await tester.pumpWidget(_withStreamTheme(const StreamRadioIndicator(selected: false)));

      final painted = _Painted(tester, find.byType(StreamRadioIndicator));
      expect(painted.background, StreamColors.transparent);
      expect(painted.side, BorderSide(color: colorScheme.borderDefault));
    });

    testWidgets('uses the disabled colors when selected and not enabled', (tester) async {
      await tester.pumpWidget(_withStreamTheme(const StreamRadioIndicator(selected: true, enabled: false)));

      final painted = _Painted(tester, find.byType(StreamRadioIndicator));
      expect(painted.background, colorScheme.backgroundDisabled);
      expect(painted.indicator, colorScheme.textDisabled);
      expect(painted.side, BorderSide.none);
    });

    testWidgets('uses the disabled border when unselected and not enabled', (tester) async {
      await tester.pumpWidget(_withStreamTheme(const StreamRadioIndicator(selected: false, enabled: false)));

      expect(_Painted(tester, find.byType(StreamRadioIndicator)).side, BorderSide(color: colorScheme.borderDisabled));
    });

    testWidgets('animates a change of selected over 200ms', (tester) async {
      Widget indicator({required bool selected}) => _withStreamTheme(StreamRadioIndicator(selected: selected));

      await tester.pumpWidget(indicator(selected: false));
      final painted = _Painted(tester, find.byType(StreamRadioIndicator));
      expect(painted.indicatorSize, Size.zero);

      await tester.pumpWidget(indicator(selected: true));
      await tester.pump(const Duration(milliseconds: 100));

      expect(painted.indicatorSize.width, inExclusiveRange(0, 10));
      expect(painted.background, isNot(anyOf(StreamColors.transparent, colorScheme.accentPrimary)));

      await tester.pump(const Duration(milliseconds: 100));

      expect(painted.indicatorSize, const Size.square(10));
      expect(painted.background, colorScheme.accentPrimary);
    });
  });

  group('StreamRadioButton selection animation', () {
    testWidgets('starts at rest in its current state', (tester) async {
      await tester.pumpWidget(_withStreamTheme(_radio(selected: true)));

      expect(_paintedRadio(tester).indicatorSize, const Size.square(10));
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('grows the dot and blends the colors over 200ms when selected', (tester) async {
      String? selection = 'a';
      await tester.pumpWidget(
        _withStreamTheme(
          StatefulBuilder(
            builder: (context, setState) => _group<String>(
              ['a', 'b'],
              groupValue: selection,
              onChanged: (value) => setState(() => selection = value),
            ),
          ),
        ),
      );
      final b = _Painted(tester, find.byKey(const ValueKey('b')));
      expect(b.indicatorSize, Size.zero);
      expect(b.side, BorderSide(color: colorScheme.borderDefault));

      await tester.tap(find.byKey(const ValueKey('b')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(b.indicatorSize.width, inExclusiveRange(0, 10));
      expect(b.background, isNot(anyOf(StreamColors.transparent, colorScheme.accentPrimary)));
      expect(b.side, isNot(anyOf(BorderSide.none, BorderSide(color: colorScheme.borderDefault))));
      // The radio button losing the selection shrinks at the same time.
      expect(_Painted(tester, find.byKey(const ValueKey('a'))).indicatorSize.width, inExclusiveRange(0, 10));

      await tester.pumpAndSettle();

      expect(b.indicatorSize, const Size.square(10));
      expect(b.background, colorScheme.accentPrimary);
      expect(b.side, BorderSide.none);
      expect(_Painted(tester, find.byKey(const ValueKey('a'))).indicatorSize, Size.zero);
    });
  });

  group('StreamRadioButton theming', () {
    testWidgets('applies the global theme from StreamTheme', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          _radio(selected: true),
          streamTheme: StreamTheme(
            radioButtonTheme: StreamRadioButtonThemeData(
              style: StreamRadioButtonStyle.from(
                size: const StreamRadioButtonSize(diameter: 16, indicatorDiameter: 6),
                selectedBackgroundColor: Colors.green,
                selectedIndicatorColor: Colors.black,
              ),
            ),
          ),
        ),
      );

      expect(_paintedRadio(tester).size, const Size.square(16));
      expect(_paintedRadio(tester).indicatorSize, const Size.square(6));
      expect(_paintedRadio(tester).background, Colors.green);
      expect(_paintedRadio(tester).indicator, Colors.black);
    });

    testWidgets('themes the focus ring through side', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          StreamRadioButtonTheme(
            data: StreamRadioButtonThemeData(
              style: StreamRadioButtonStyle(
                side: WidgetStateBorderSide.resolveWith((states) {
                  if (states.contains(WidgetState.focused)) return const BorderSide(color: Colors.purple, width: 3);
                  return null;
                }),
              ),
            ),
            child: _radio(selected: false),
          ),
        ),
      );

      // States the theme leaves null keep the default border.
      expect(_paintedRadio(tester).side, BorderSide(color: colorScheme.borderDefault));

      await _focusWithKeyboard(tester);

      expect(_paintedRadio(tester).side, const BorderSide(color: Colors.purple, width: 3));
    });

    testWidgets('a themed side also applies while focused', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          StreamRadioButtonTheme(
            data: StreamRadioButtonThemeData(
              style: StreamRadioButtonStyle.from(side: const BorderSide(color: Colors.green, width: 2)),
            ),
            child: _radio(selected: false),
          ),
        ),
      );

      await _focusWithKeyboard(tester);

      expect(_paintedRadio(tester).side, const BorderSide(color: Colors.green, width: 2));
    });

    testWidgets('a local theme beats the global theme', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          StreamRadioButtonTheme(
            data: StreamRadioButtonThemeData(
              style: StreamRadioButtonStyle.from(selectedBackgroundColor: Colors.blue),
            ),
            child: _radio(selected: true),
          ),
          streamTheme: StreamTheme(
            radioButtonTheme: StreamRadioButtonThemeData(
              style: StreamRadioButtonStyle.from(selectedBackgroundColor: Colors.green, size: StreamRadioButtonSize.md),
            ),
          ),
        ),
      );

      expect(_paintedRadio(tester).background, Colors.blue);
      // Fields the local theme leaves unset still come from the global one.
      expect(_paintedRadio(tester).size, const Size.square(20));
    });

    testWidgets('the size parameter beats the theme size', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          StreamRadioButtonTheme(
            data: const StreamRadioButtonThemeData(style: StreamRadioButtonStyle(size: StreamRadioButtonSize.lg)),
            child: _radio(selected: true, size: StreamRadioButtonSize.sm),
          ),
        ),
      );

      expect(_paintedRadio(tester).size, const Size.square(16));
    });

    testWidgets('falls back to the defaults for fields the theme leaves unset', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          StreamRadioButtonTheme(
            data: const StreamRadioButtonThemeData(style: StreamRadioButtonStyle(size: StreamRadioButtonSize.md)),
            child: _radio(selected: true),
          ),
        ),
      );

      expect(_paintedRadio(tester).size, const Size.square(20));
      expect(_paintedRadio(tester).indicatorSize, const Size.square(8));
      expect(_paintedRadio(tester).background, colorScheme.accentPrimary);
    });
  });

  group('StreamRadioButtonStyle.from', () {
    const selected = {WidgetState.selected};
    const disabled = {WidgetState.disabled};
    const disabledSelected = {WidgetState.disabled, WidgetState.selected};

    test('sets each value for its own state only', () {
      final style = StreamRadioButtonStyle.from(
        backgroundColor: Colors.red,
        selectedBackgroundColor: Colors.green,
        disabledBackgroundColor: Colors.grey,
        indicatorColor: Colors.black,
        selectedIndicatorColor: Colors.white,
        disabledIndicatorColor: Colors.blueGrey,
        overlayColor: Colors.yellow,
        hoveredOverlayColor: Colors.orange,
        pressedOverlayColor: Colors.purple,
        side: const BorderSide(color: Colors.red),
        selectedSide: const BorderSide(color: Colors.green),
        disabledSide: const BorderSide(color: Colors.grey),
      );

      expect(style.backgroundColor!.resolve({}), Colors.red);
      expect(style.backgroundColor!.resolve(selected), Colors.green);
      expect(style.backgroundColor!.resolve(disabledSelected), Colors.grey);
      expect(style.indicatorColor!.resolve({}), Colors.black);
      expect(style.indicatorColor!.resolve(selected), Colors.white);
      expect(style.indicatorColor!.resolve(disabledSelected), Colors.blueGrey);
      expect(style.overlayColor!.resolve({}), Colors.yellow);
      expect(style.overlayColor!.resolve({WidgetState.hovered}), Colors.orange);
      expect(style.overlayColor!.resolve({WidgetState.hovered, WidgetState.pressed}), Colors.purple);
      expect(style.side!.resolve({}), const BorderSide(color: Colors.red));
      expect(style.side!.resolve(selected), const BorderSide(color: Colors.green));
      expect(style.side!.resolve(disabled), const BorderSide(color: Colors.grey));
    });

    test('leaves every property null when no value is given', () {
      final style = StreamRadioButtonStyle.from();

      expect(style.backgroundColor, isNull);
      expect(style.indicatorColor, isNull);
      expect(style.overlayColor, isNull);
      expect(style.side, isNull);
    });

    test('uses an unprefixed value for the states without their own', () {
      final style = StreamRadioButtonStyle.from(
        backgroundColor: Colors.red,
        side: const BorderSide(color: Colors.red),
      );

      expect(style.backgroundColor!.resolve(selected), Colors.red);
      expect(style.backgroundColor!.resolve(disabledSelected), Colors.red);
      expect(style.side!.resolve({WidgetState.focused}), const BorderSide(color: Colors.red));
    });

    testWidgets('keeps the default for every property it does not set', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          StreamRadioButtonTheme(
            data: StreamRadioButtonThemeData(
              style: StreamRadioButtonStyle.from(selectedBackgroundColor: Colors.green),
            ),
            child: Column(
              children: [
                _radio(selected: true),
                _radio(selected: false),
              ],
            ),
          ),
        ),
      );

      final radios = find.byType(StreamRadioButton<bool>);
      expect(_Painted(tester, radios.at(0)).background, Colors.green);
      expect(_Painted(tester, radios.at(0)).indicator, colorScheme.textOnAccent);
      expect(_Painted(tester, radios.at(0)).side, BorderSide.none);
      expect(_Painted(tester, radios.at(1)).side, BorderSide(color: colorScheme.borderDefault));
    });
  });

  group('StreamRadioButton factory', () {
    testWidgets('passes the props to the radioButton builder', (tester) async {
      StreamRadioButtonProps<Object?>? receivedProps;

      await tester.pumpWidget(
        _withStreamTheme(
          StreamComponentFactory(
            builders: StreamComponentBuilders(
              radioButton: (context, props) {
                receivedProps = props;
                return const Text('custom');
              },
            ),
            child: StreamRadioButton(value: 'a', size: StreamRadioButtonSize.sm),
          ),
        ),
      );

      expect(find.text('custom'), findsOneWidget);
      expect(find.byType(DefaultStreamRadioButton), findsNothing);
      expect(receivedProps, isA<StreamRadioButtonProps<String>>());
      expect(receivedProps?.value, 'a');
      expect(receivedProps?.size, StreamRadioButtonSize.sm);
    });

    testWidgets('a builder that wraps the default keeps the radio button in its group', (tester) async {
      final changes = <String?>[];

      await tester.pumpWidget(
        _withStreamTheme(
          StreamComponentFactory(
            builders: StreamComponentBuilders(
              radioButton: (context, props) => Padding(
                padding: const EdgeInsets.all(4),
                child: DefaultStreamRadioButton(props: props),
              ),
            ),
            child: _group<String>(['a', 'b'], groupValue: 'a', onChanged: changes.add),
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('b')));

      expect(changes, ['b']);
    });
  });
}
