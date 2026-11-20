import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/video.dart';

final _colorScheme = StreamColorScheme.light();

Widget _wrap(Widget child, {StreamTheme? streamTheme}) {
  return MaterialApp(
    theme: ThemeData(extensions: [streamTheme ?? StreamTheme.light()]),
    home: Scaffold(
      body: Center(child: SizedBox(width: 256, child: child)),
    ),
  );
}

BorderSide? _sideOf(DecoratedBox box) {
  final decoration = box.decoration;
  if (decoration is! ShapeDecoration) return null;
  final shape = decoration.shape;
  return shape is RoundedSuperellipseBorder ? shape.side : null;
}

// The ring is the only decorated box the field paints under an IgnorePointer.
Finder _ringBox() => find.descendant(
  of: find.descendant(of: find.byType(StreamSelectInput), matching: find.byType(IgnorePointer)),
  matching: find.byType(DecoratedBox),
);

BorderSide? _ring(WidgetTester tester) {
  final boxes = tester.widgetList<DecoratedBox>(_ringBox());
  return boxes.isEmpty ? null : _sideOf(boxes.single);
}

BorderSide? _border(WidgetTester tester) {
  final rings = tester.widgetList<DecoratedBox>(_ringBox()).toSet();
  final boxes = tester.widgetList<DecoratedBox>(
    find.descendant(of: find.byType(StreamSelectInput), matching: find.byType(DecoratedBox)),
  );
  return boxes.where((box) => !rings.contains(box)).map(_sideOf).nonNulls.single;
}

// Flutter suppresses hover and focus highlights while the last interaction was
// a touch, which is what a widget test starts out as.
void _useTraditionalHighlights(WidgetTester tester) {
  tester.binding.focusManager.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
  addTearDown(() => tester.binding.focusManager.highlightStrategy = FocusHighlightStrategy.automatic);
}

Future<void> _hover(WidgetTester tester) async {
  final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
  addTearDown(gesture.removePointer);
  await gesture.addPointer(location: tester.getCenter(find.byType(StreamSelectInput)));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('default has the default border and no ring', (tester) async {
    await tester.pumpWidget(_wrap(StreamSelectInput(hintText: 'Default', onPressed: () {})));

    expect(_border(tester)?.color, _colorScheme.borderDefault);
    expect(_ring(tester), isNull);
  });

  testWidgets('expanded uses the active border', (tester) async {
    await tester.pumpWidget(_wrap(StreamSelectInput(value: 'Mic', expanded: true, onPressed: () {})));

    expect(_border(tester)?.color, _colorScheme.borderActive);
  });

  testWidgets('expanded shows the caret pointing up', (tester) async {
    await tester.pumpWidget(_wrap(StreamSelectInput(value: 'Mic', expanded: true, onPressed: () {})));

    expect(find.byIcon(StreamIconData.caretUp), findsOneWidget);
    expect(find.byIcon(StreamIconData.caretDown), findsNothing);
  });

  testWidgets('collapsed shows the caret pointing down', (tester) async {
    await tester.pumpWidget(_wrap(StreamSelectInput(value: 'Mic', onPressed: () {})));

    expect(find.byIcon(StreamIconData.caretDown), findsOneWidget);
  });

  testWidgets('error state uses the error border', (tester) async {
    await tester.pumpWidget(
      _wrap(StreamSelectInput(value: 'Mic', helperState: StreamHelperState.error, onPressed: () {})),
    );

    expect(_border(tester)?.color, _colorScheme.borderError);
  });

  testWidgets('disabled uses the disabled border', (tester) async {
    await tester.pumpWidget(_wrap(StreamSelectInput(hintText: 'Default')));

    expect(_border(tester)?.color, _colorScheme.borderDisabled);
  });

  group('border precedence', () {
    testWidgets('disabled beats error', (tester) async {
      await tester.pumpWidget(_wrap(StreamSelectInput(value: 'Mic', helperState: StreamHelperState.error)));

      expect(_border(tester)?.color, _colorScheme.borderDisabled);
    });

    testWidgets('disabled beats expanded', (tester) async {
      await tester.pumpWidget(_wrap(StreamSelectInput(value: 'Mic', expanded: true)));

      expect(_border(tester)?.color, _colorScheme.borderDisabled);
    });

    testWidgets('error beats expanded', (tester) async {
      await tester.pumpWidget(
        _wrap(
          StreamSelectInput(
            value: 'Mic',
            expanded: true,
            helperState: StreamHelperState.error,
            onPressed: () {},
          ),
        ),
      );

      expect(_border(tester)?.color, _colorScheme.borderError);
    });
  });

  testWidgets('tapping the field calls onPressed once', (tester) async {
    var pressed = 0;
    await tester.pumpWidget(_wrap(StreamSelectInput(hintText: 'Default', onPressed: () => pressed += 1)));

    await tester.tap(find.byType(StreamSelectInput));
    await tester.pump();

    expect(pressed, 1);
  });

  testWidgets('the caret follows the hint color while nothing is selected', (tester) async {
    await tester.pumpWidget(_wrap(StreamSelectInput(hintText: 'Default', onPressed: () {})));

    expect(IconTheme.of(tester.element(find.byIcon(StreamIconData.caretDown))).color, _colorScheme.textTertiary);
  });

  testWidgets('the caret uses the disabled text color when disabled', (tester) async {
    await tester.pumpWidget(_wrap(StreamSelectInput(value: 'Mic')));

    expect(IconTheme.of(tester.element(find.byIcon(StreamIconData.caretDown))).color, _colorScheme.textDisabled);
  });

  testWidgets('shows the hint in the hint color while nothing is selected', (tester) async {
    await tester.pumpWidget(_wrap(StreamSelectInput(hintText: 'Default', onPressed: () {})));

    expect(tester.widget<Text>(find.text('Default')).style?.color, _colorScheme.textTertiary);
  });

  testWidgets('shows the value in the primary text color', (tester) async {
    await tester.pumpWidget(_wrap(StreamSelectInput(value: 'Mic', hintText: 'Default', onPressed: () {})));

    expect(find.text('Default'), findsNothing);
    expect(tester.widget<Text>(find.text('Mic')).style?.color, _colorScheme.textPrimary);
  });

  testWidgets('renders the label and helper text', (tester) async {
    await tester.pumpWidget(
      _wrap(StreamSelectInput(labelText: 'Microphone', helperText: 'Pick one', onPressed: () {})),
    );

    expect(find.text('Microphone'), findsOneWidget);
    expect(find.text('Pick one'), findsOneWidget);
  });

  testWidgets('hover draws the hover ring over the default border', (tester) async {
    _useTraditionalHighlights(tester);

    await tester.pumpWidget(_wrap(StreamSelectInput(hintText: 'Default', onPressed: () {})));

    await _hover(tester);

    expect(_ring(tester)?.color, _colorScheme.borderHover);
    expect(_border(tester)?.color, _colorScheme.borderDefault);
  });

  testWidgets('hovering a disabled field draws no ring', (tester) async {
    _useTraditionalHighlights(tester);

    await tester.pumpWidget(_wrap(StreamSelectInput(hintText: 'Default')));

    await _hover(tester);

    expect(_ring(tester), isNull);
  });

  testWidgets('the ring paints half its width outside the field', (tester) async {
    _useTraditionalHighlights(tester);

    await tester.pumpWidget(_wrap(StreamSelectInput(hintText: 'Default', onPressed: () {})));
    await _hover(tester);

    final fieldRect = tester.getRect(
      find.descendant(of: find.byType(StreamSelectInput), matching: find.byType(Container)).first,
    );
    expect(tester.getRect(_ringBox()), fieldRect.inflate(1));
  });

  testWidgets('an outside-aligned ring is still centered on the field edge', (tester) async {
    _useTraditionalHighlights(tester);

    await tester.pumpWidget(
      _wrap(
        StreamSelectInput(
          hintText: 'Default',
          style: const StreamSelectInputStyle(
            hoverRing: BorderSide(width: 4, strokeAlign: BorderSide.strokeAlignOutside),
          ),
          onPressed: () {},
        ),
      ),
    );
    await _hover(tester);

    final fieldRect = tester.getRect(
      find.descendant(of: find.byType(StreamSelectInput), matching: find.byType(Container)).first,
    );
    // An outside stroke paints beyond its box, so the box shrinks by half the
    // width to keep the stroke centered on the field's edge.
    expect(tester.getRect(_ringBox()), fieldRect.deflate(2));
  });

  testWidgets('focus draws the focus ring', (tester) async {
    _useTraditionalHighlights(tester);

    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(_wrap(StreamSelectInput(hintText: 'Default', focusNode: focusNode, onPressed: () {})));

    focusNode.requestFocus();
    await tester.pumpAndSettle();

    expect(_ring(tester)?.color, _colorScheme.borderFocus);
  });

  testWidgets('the focus ring beats the hover ring', (tester) async {
    _useTraditionalHighlights(tester);

    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(_wrap(StreamSelectInput(hintText: 'Default', focusNode: focusNode, onPressed: () {})));

    focusNode.requestFocus();
    await _hover(tester);

    expect(_ring(tester)?.color, _colorScheme.borderFocus);
  });

  testWidgets('swapping the focus node clears the focus ring', (tester) async {
    _useTraditionalHighlights(tester);

    final first = FocusNode();
    final second = FocusNode();
    addTearDown(first.dispose);
    addTearDown(second.dispose);

    await tester.pumpWidget(_wrap(StreamSelectInput(hintText: 'Default', focusNode: first, onPressed: () {})));
    first.requestFocus();
    await tester.pumpAndSettle();

    await tester.pumpWidget(_wrap(StreamSelectInput(hintText: 'Default', focusNode: second, onPressed: () {})));
    await tester.pumpAndSettle();

    expect(_ring(tester), isNull);
  });

  testWidgets('a disabled field does not take focus', (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(_wrap(StreamSelectInput(hintText: 'Default', focusNode: focusNode)));

    focusNode.requestFocus();
    await tester.pumpAndSettle();

    expect(focusNode.hasFocus, isFalse);
  });

  for (final key in [LogicalKeyboardKey.enter, LogicalKeyboardKey.space]) {
    testWidgets('${key.keyLabel} activates the focused field', (tester) async {
      var pressed = 0;
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);

      await tester.pumpWidget(
        _wrap(StreamSelectInput(hintText: 'Default', focusNode: focusNode, onPressed: () => pressed += 1)),
      );

      focusNode.requestFocus();
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(key);
      await tester.pump();

      expect(pressed, 1);
    });
  }

  group('ghost style', () {
    testWidgets('has no base border until a state applies', (tester) async {
      await tester.pumpWidget(
        _wrap(StreamSelectInput(style: const StreamSelectInputStyle.ghost(), hintText: 'Default', onPressed: () {})),
      );

      expect(_border(tester)?.color, const Color(0x00000000));
    });

    testWidgets('shows the active border while expanded', (tester) async {
      await tester.pumpWidget(
        _wrap(
          StreamSelectInput(
            style: const StreamSelectInputStyle.ghost(),
            value: 'Mic',
            expanded: true,
            onPressed: () {},
          ),
        ),
      );

      expect(_border(tester)?.color, _colorScheme.borderActive);
    });

    testWidgets('shows the error border', (tester) async {
      await tester.pumpWidget(
        _wrap(
          StreamSelectInput(
            style: const StreamSelectInputStyle.ghost(),
            value: 'Mic',
            helperState: StreamHelperState.error,
            onPressed: () {},
          ),
        ),
      );

      expect(_border(tester)?.color, _colorScheme.borderError);
    });

    testWidgets('shows the disabled border', (tester) async {
      await tester.pumpWidget(_wrap(StreamSelectInput(style: const StreamSelectInputStyle.ghost(), value: 'Mic')));

      expect(_border(tester)?.color, _colorScheme.borderDisabled);
    });

    testWidgets('applies from the theme to every field in the subtree', (tester) async {
      await tester.pumpWidget(
        _wrap(
          StreamSelectInputTheme(
            data: const StreamSelectInputThemeData(style: StreamSelectInputStyle.ghost()),
            child: StreamSelectInput(hintText: 'Default', onPressed: () {}),
          ),
        ),
      );

      expect(_border(tester)?.color, const Color(0x00000000));
    });
  });

  group('semantics', () {
    testWidgets('meets accessibility guidelines', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(_wrap(StreamSelectInput(labelText: 'Language', value: 'English', onPressed: () {})));

      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));

      handle.dispose();
    });

    testWidgets('exposes a button with its label, value and expanded state', (tester) async {
      await tester.pumpWidget(
        _wrap(StreamSelectInput(labelText: 'Microphone', value: 'Mic', expanded: true, onPressed: () {})),
      );

      expect(
        tester.getSemantics(find.byType(StreamSelectInput)),
        isSemantics(
          label: 'Microphone',
          value: 'Mic',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasExpandedState: true,
          isExpanded: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
    });

    testWidgets('a semantic tap calls onPressed', (tester) async {
      final handle = tester.ensureSemantics();

      var pressed = 0;
      await tester.pumpWidget(_wrap(StreamSelectInput(labelText: 'Microphone', onPressed: () => pressed += 1)));

      tester.semantics.tap(find.semantics.byLabel('Microphone'));
      await tester.pump();

      expect(pressed, 1);

      handle.dispose();
    });

    testWidgets('a disabled field has no tap action', (tester) async {
      await tester.pumpWidget(_wrap(StreamSelectInput(labelText: 'Microphone', value: 'Mic')));

      expect(
        tester.getSemantics(find.byType(StreamSelectInput)),
        isSemantics(label: 'Microphone', isButton: true, hasEnabledState: true, isEnabled: false, hasTapAction: false),
      );
    });

    testWidgets('announces the hint as the hint while nothing is selected', (tester) async {
      await tester.pumpWidget(
        _wrap(StreamSelectInput(labelText: 'Language', hintText: 'Choose a language', onPressed: () {})),
      );

      expect(
        tester.getSemantics(find.byType(StreamSelectInput)),
        isSemantics(label: 'Language', value: '', hint: 'Choose a language', isButton: true),
      );
    });

    testWidgets('without a label, announces the hint as the label', (tester) async {
      await tester.pumpWidget(_wrap(StreamSelectInput(hintText: 'Choose a language', onPressed: () {})));

      expect(
        tester.getSemantics(find.byType(StreamSelectInput)),
        isSemantics(label: 'Choose a language', value: '', isButton: true),
      );
    });

    testWidgets('semanticLabel replaces labelText without changing what is drawn', (tester) async {
      await tester.pumpWidget(
        _wrap(StreamSelectInput(labelText: 'Mic', semanticLabel: 'Microphone', value: 'Jabra', onPressed: () {})),
      );

      expect(find.text('Mic'), findsOneWidget);
      expect(
        tester.getSemantics(find.byType(StreamSelectInput)),
        isSemantics(label: 'Microphone', value: 'Jabra', isButton: true),
      );
    });
  });

  testWidgets('a factory builder replaces the default implementation', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: [StreamTheme.light()]),
        home: StreamComponentFactory(
          builders: StreamComponentBuilders(
            selectInput: (context, props) => Text('custom ${props.value}'),
          ),
          child: StreamSelectInput(value: 'Mic', onPressed: () {}),
        ),
      ),
    );

    expect(find.text('custom Mic'), findsOneWidget);
    expect(find.byType(DefaultStreamSelectInput), findsNothing);
  });

  group('theming', () {
    testWidgets('applies the border from StreamTheme', (tester) async {
      await tester.pumpWidget(
        _wrap(
          StreamSelectInput(hintText: 'Default', onPressed: () {}),
          streamTheme: StreamTheme(
            selectInputTheme: const StreamSelectInputThemeData(
              style: StreamSelectInputStyle(border: BorderSide(color: Colors.green)),
            ),
          ),
        ),
      );

      expect(_border(tester)?.color, Colors.green);
    });

    testWidgets('a local StreamSelectInputTheme overrides StreamTheme', (tester) async {
      await tester.pumpWidget(
        _wrap(
          StreamSelectInputTheme(
            data: const StreamSelectInputThemeData(style: StreamSelectInputStyle(iconColor: Colors.orange)),
            child: StreamSelectInput(value: 'Mic', onPressed: () {}),
          ),
          streamTheme: StreamTheme(
            selectInputTheme: const StreamSelectInputThemeData(style: StreamSelectInputStyle(iconColor: Colors.green)),
          ),
        ),
      );

      expect(IconTheme.of(tester.element(find.byIcon(StreamIconData.caretDown))).color, Colors.orange);
    });

    testWidgets('the widget style beats the theme', (tester) async {
      await tester.pumpWidget(
        _wrap(
          StreamSelectInputTheme(
            data: const StreamSelectInputThemeData(
              style: StreamSelectInputStyle(errorBorder: BorderSide(color: Colors.green)),
            ),
            child: StreamSelectInput(
              value: 'Mic',
              helperState: StreamHelperState.error,
              style: const StreamSelectInputStyle(errorBorder: BorderSide(color: Colors.purple)),
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(_border(tester)?.color, Colors.purple);
    });

    testWidgets('applies the themed focus ring', (tester) async {
      _useTraditionalHighlights(tester);

      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);

      await tester.pumpWidget(
        _wrap(
          StreamSelectInputTheme(
            data: const StreamSelectInputThemeData(
              style: StreamSelectInputStyle(focusRing: BorderSide(color: Colors.green)),
            ),
            child: StreamSelectInput(hintText: 'Default', focusNode: focusNode, onPressed: () {}),
          ),
        ),
      );

      focusNode.requestFocus();
      await tester.pumpAndSettle();

      expect(_ring(tester)?.color, Colors.green);
    });

    testWidgets('applies a themed text style and resolves it per state', (tester) async {
      await tester.pumpWidget(
        _wrap(
          StreamSelectInputTheme(
            data: StreamSelectInputThemeData(
              style: StreamSelectInputStyle(
                textStyle: WidgetStateTextStyle.resolveWith(
                  (states) => TextStyle(
                    color: states.contains(WidgetState.disabled) ? Colors.grey : Colors.green,
                  ),
                ),
              ),
            ),
            child: Column(
              children: [
                StreamSelectInput(value: 'Enabled', onPressed: () {}),
                StreamSelectInput(value: 'Disabled'),
              ],
            ),
          ),
        ),
      );

      expect(tester.widget<Text>(find.text('Enabled')).style?.color, Colors.green);
      expect(tester.widget<Text>(find.text('Disabled')).style?.color, Colors.grey);
    });

    testWidgets('the icon color defaults to the color of the shown text', (tester) async {
      await tester.pumpWidget(
        _wrap(
          StreamSelectInput(
            value: 'Mic',
            style: const StreamSelectInputStyle(textStyle: TextStyle(color: Colors.green)),
            onPressed: () {},
          ),
        ),
      );

      expect(IconTheme.of(tester.element(find.byIcon(StreamIconData.caretDown))).color, Colors.green);
    });

    testWidgets('resolves a WidgetStateBorderSide against the field state', (tester) async {
      _useTraditionalHighlights(tester);

      await tester.pumpWidget(
        _wrap(
          StreamSelectInput(
            hintText: 'Default',
            style: StreamSelectInputStyle(
              border: WidgetStateBorderSide.resolveWith(
                (states) => BorderSide(color: states.contains(WidgetState.hovered) ? Colors.green : Colors.grey),
              ),
            ),
            onPressed: () {},
          ),
        ),
      );

      expect(_border(tester)?.color, Colors.grey);

      await _hover(tester);

      expect(_border(tester)?.color, Colors.green);
    });

    testWidgets('resolves a WidgetStateColor fill against the field state', (tester) async {
      await tester.pumpWidget(
        _wrap(
          StreamSelectInput(
            value: 'Mic',
            style: StreamSelectInputStyle(
              fillColor: WidgetStateColor.resolveWith(
                (states) => states.contains(WidgetState.disabled) ? Colors.grey : Colors.green,
              ),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(of: find.byType(StreamSelectInput), matching: find.byType(Container)).first,
      );
      expect((container.decoration! as ShapeDecoration).color, Colors.grey);
    });

    testWidgets('the widget icon color beats the theme', (tester) async {
      await tester.pumpWidget(
        _wrap(
          StreamSelectInputTheme(
            data: const StreamSelectInputThemeData(style: StreamSelectInputStyle(iconColor: Colors.green)),
            child: StreamSelectInput(
              value: 'Mic',
              style: const StreamSelectInputStyle(iconColor: Colors.purple),
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(IconTheme.of(tester.element(find.byIcon(StreamIconData.caretDown))).color, Colors.purple);
    });
  });
}
