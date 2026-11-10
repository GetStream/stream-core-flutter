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

BorderSide? _sideOfWidth(WidgetTester tester, double width) {
  for (final box in tester.widgetList<DecoratedBox>(find.byType(DecoratedBox))) {
    final decoration = box.decoration;
    if (decoration is! ShapeDecoration) continue;
    final shape = decoration.shape;
    if (shape is! RoundedSuperellipseBorder) continue;
    if (shape.side.width == width) return shape.side;
  }
  return null;
}

BorderSide? _border(WidgetTester tester) => _sideOfWidth(tester, 1);
BorderSide? _ring(WidgetTester tester) => _sideOfWidth(tester, 2);

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

  testWidgets('disabled uses the disabled border and ignores taps', (tester) async {
    await tester.pumpWidget(_wrap(StreamSelectInput(hintText: 'Default')));

    expect(_border(tester)?.color, _colorScheme.borderDisabled);

    await tester.tap(find.byType(StreamSelectInput));
    await tester.pump();

    expect(_ring(tester), isNull);
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

  testWidgets('hover draws the hover ring', (tester) async {
    _useTraditionalHighlights(tester);

    var pressed = 0;
    await tester.pumpWidget(_wrap(StreamSelectInput(hintText: 'Default', onPressed: () => pressed += 1)));

    await _hover(tester);

    expect(_ring(tester)?.color, _colorScheme.borderHover);
    expect(_border(tester)?.color, _colorScheme.borderDefault);

    await tester.tap(find.byType(StreamSelectInput));
    await tester.pump();
    expect(pressed, 1);
  });

  testWidgets('the ring paints half its width outside the field', (tester) async {
    _useTraditionalHighlights(tester);

    await tester.pumpWidget(_wrap(StreamSelectInput(hintText: 'Default', onPressed: () {})));
    await _hover(tester);

    final ringBox = find.byWidgetPredicate((widget) {
      if (widget is! DecoratedBox) return false;
      final decoration = widget.decoration;
      return decoration is ShapeDecoration && (decoration.shape as RoundedSuperellipseBorder).side.width == 2;
    });
    final fieldRect = tester.getRect(
      find.descendant(of: find.byType(StreamSelectInput), matching: find.byType(Container)).first,
    );
    final ringRect = tester.getRect(ringBox);
    expect(ringRect, fieldRect.inflate(1));
  });

  testWidgets('focus draws the focus ring and Enter activates', (tester) async {
    _useTraditionalHighlights(tester);

    var pressed = 0;
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      _wrap(StreamSelectInput(hintText: 'Default', focusNode: focusNode, onPressed: () => pressed += 1)),
    );

    focusNode.requestFocus();
    await tester.pumpAndSettle();

    expect(_ring(tester)?.color, _colorScheme.borderFocus);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(pressed, 1);
  });

  testWidgets('ghost has no base border until a state applies', (tester) async {
    await tester.pumpWidget(
      _wrap(StreamSelectInput(type: StreamSelectInputType.ghost, hintText: 'Default', onPressed: () {})),
    );

    expect(_border(tester)?.color, Colors.transparent);
  });

  testWidgets('ghost shows the active border while expanded', (tester) async {
    await tester.pumpWidget(
      _wrap(StreamSelectInput(type: StreamSelectInputType.ghost, value: 'Mic', expanded: true, onPressed: () {})),
    );

    expect(_border(tester)?.color, _colorScheme.borderActive);
  });

  testWidgets('exposes a button with its label, value and expanded state to semantics', (tester) async {
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
      ),
    );
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
              style: StreamSelectInputStyle(focusRing: BorderSide(color: Colors.green, width: 2)),
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
