import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

Widget _withStreamTheme(
  Widget child, {
  StreamTheme? streamTheme,
  ElevatedButtonThemeData? elevatedButtonTheme,
}) {
  return MaterialApp(
    theme: ThemeData(
      extensions: [streamTheme ?? StreamTheme()],
      elevatedButtonTheme: elevatedButtonTheme,
    ),
    home: Scaffold(body: Center(child: child)),
  );
}

/// The [Material] that [ElevatedButton] renders its surface with — the one
/// carrying the resolved elevation and background colour.
Material _surfaceOf(WidgetTester tester) {
  return tester.widget<Material>(
    find.descendant(of: find.byType(StreamButton), matching: find.byType(Material)).first,
  );
}

void main() {
  group('StreamButton floating', () {
    testWidgets('resolves its elevation from StreamTheme.elevation', (tester) async {
      // Not just "is elevated": the value has to come from the theme primitive,
      // so an app that retunes the elevation scale retunes floating buttons.
      await tester.pumpWidget(
        _withStreamTheme(
          streamTheme: StreamTheme(elevation: const StreamElevation(level3: 20)),
          StreamButton(
            onPressed: () {},
            isFloating: true,
            child: const Text('Floating'),
          ),
        ),
      );

      expect(_surfaceOf(tester).elevation, 20);
    });

    testWidgets('is flat when not floating, whatever the theme says', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          streamTheme: StreamTheme(elevation: const StreamElevation(level3: 20)),
          StreamButton(
            onPressed: () {},
            child: const Text('Flat'),
          ),
        ),
      );

      expect(_surfaceOf(tester).elevation, 0);
    });

    // Regression: outline and ghost fell back to a transparent background when
    // disabled, so a disabled floating button lost its pill and only the shadow
    // was left.
    for (final type in [StreamButtonType.outline, StreamButtonType.ghost]) {
      testWidgets('disabled ${type.name} keeps its pill surface', (tester) async {
        final streamTheme = StreamTheme();

        await tester.pumpWidget(
          _withStreamTheme(
            streamTheme: streamTheme,
            StreamButton(
              type: type,
              isFloating: true,
              child: const Text('Floating'),
            ),
          ),
        );

        expect(_surfaceOf(tester).color, streamTheme.colorScheme.backgroundElevation1);
      });
    }

    testWidgets('lifts further on hover', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          streamTheme: StreamTheme(elevation: const StreamElevation(level4: 20)),
          StreamButton(
            onPressed: () {},
            isFloating: true,
            child: const Text('Floating'),
          ),
        ),
      );

      // Resting is level3, left at its default here.
      expect(_surfaceOf(tester).elevation, const StreamElevation().level3);

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: tester.getCenter(find.byType(StreamButton)));
      addTearDown(gesture.removePointer);
      await tester.pumpAndSettle();

      expect(_surfaceOf(tester).elevation, 20);
    });
  });

  group('StreamButton.icon a11y', () {
    testWidgets('enabled — label, isButton, isEnabled, hasTapAction', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _withStreamTheme(
          StreamButton.icon(
            icon: const Icon(Icons.add),
            tooltip: 'Add',
            onPressed: () {},
          ),
        ),
      );

      expect(
        tester.getSemantics(find.byType(StreamButton)),
        isSemantics(
          tooltip: 'Add',
          isButton: true,
          isEnabled: true,
          hasEnabledState: true,
          hasTapAction: true,
        ),
      );

      handle.dispose();
    });

    testWidgets('disabled (onPressed: null) — no tap action, !isEnabled', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _withStreamTheme(
          StreamButton.icon(
            icon: const Icon(Icons.add),
            tooltip: 'Add',
          ),
        ),
      );

      expect(
        tester.getSemantics(find.byType(StreamButton)),
        isSemantics(
          tooltip: 'Add',
          isButton: true,
          isEnabled: false,
          hasEnabledState: true,
          hasTapAction: false,
        ),
      );

      handle.dispose();
    });

    testWidgets('selected — hasSelectedState, isSelected', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _withStreamTheme(
          StreamButton.icon(
            icon: const Icon(Icons.add),
            tooltip: 'Add',
            isSelected: true,
            onPressed: () {},
          ),
        ),
      );

      expect(
        tester.getSemantics(find.byType(StreamButton)),
        isSemantics(
          tooltip: 'Add',
          isButton: true,
          isSelected: true,
          hasSelectedState: true,
        ),
      );

      handle.dispose();
    });

    testWidgets('renders a Material Tooltip for sighted users', (tester) async {
      // Sighted users see the tooltip on hover / long-press; SR users get
      // the label through Tooltip's internal Semantics merged into the
      // button's tappable node (covered by the "enabled" test above).
      await tester.pumpWidget(
        _withStreamTheme(
          StreamButton.icon(
            icon: const Icon(Icons.add),
            tooltip: 'Add attachment',
            onPressed: () {},
          ),
        ),
      );

      expect(find.byTooltip('Add attachment'), findsOneWidget);
    });

    testWidgets('meets tap-target guidelines', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _withStreamTheme(
          StreamButton.icon(
            icon: const Icon(Icons.add),
            tooltip: 'Add',
            onPressed: () {},
          ),
        ),
      );

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));

      handle.dispose();
    });
  });

  group('StreamButton.icon long press', () {
    testWidgets('calls onLongPress instead of showing the tooltip', (tester) async {
      var pressed = 0;
      var longPressed = 0;
      await tester.pumpWidget(
        _withStreamTheme(
          StreamButton.icon(
            icon: const Icon(Icons.send),
            tooltip: 'Send',
            onPressed: () => pressed++,
            onLongPress: () => longPressed++,
          ),
        ),
      );

      await tester.longPress(find.byType(StreamButton));
      await tester.pumpAndSettle();

      expect(longPressed, 1);
      expect(pressed, 0);
      expect(find.text('Send'), findsNothing);
    });

    testWidgets('exposes a long-press action to accessibility services', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _withStreamTheme(
          StreamButton.icon(
            icon: const Icon(Icons.send),
            tooltip: 'Send',
            onPressed: () {},
            onLongPress: () {},
          ),
        ),
      );

      expect(
        tester.getSemantics(find.byType(StreamButton)),
        isSemantics(tooltip: 'Send', isButton: true, hasTapAction: true, hasLongPressAction: true),
      );

      handle.dispose();
    });

    testWidgets('still calls onPressed on a tap', (tester) async {
      var pressed = 0;
      await tester.pumpWidget(
        _withStreamTheme(
          StreamButton.icon(
            icon: const Icon(Icons.send),
            tooltip: 'Send',
            onPressed: () => pressed++,
            onLongPress: () {},
          ),
        ),
      );

      await tester.tap(find.byType(StreamButton));

      expect(pressed, 1);
    });
  });

  group('StreamButton (with child) a11y', () {
    testWidgets('label comes from child Text widget', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _withStreamTheme(
          StreamButton(
            onPressed: () {},
            child: const Text('Submit'),
          ),
        ),
      );

      expect(
        tester.getSemantics(find.byType(StreamButton)),
        isSemantics(
          label: 'Submit',
          isButton: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );

      handle.dispose();
    });
  });

  group('StreamButton semanticLabel and semanticHint', () {
    testWidgets('semanticLabel replaces the child label', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _withStreamTheme(
          StreamButton(
            semanticLabel: 'Submit the form',
            onPressed: () {},
            child: const Text('Submit'),
          ),
        ),
      );

      expect(
        tester.semantics.find(find.byType(StreamButton)),
        isSemantics(
          label: 'Submit the form',
          isButton: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );
      expect(find.bySemanticsLabel('Submit'), findsNothing);

      handle.dispose();
    });

    testWidgets('semanticHint is announced after the child label', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _withStreamTheme(
          StreamButton(
            semanticHint: 'Sends your answers',
            onPressed: () {},
            child: const Text('Submit'),
          ),
        ),
      );

      expect(
        tester.semantics.find(find.byType(StreamButton)),
        isSemantics(
          label: 'Submit',
          hint: 'Sends your answers',
          isButton: true,
          hasTapAction: true,
        ),
      );

      handle.dispose();
    });

    testWidgets('a disabled button keeps its label, hint and disabled state', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _withStreamTheme(
          StreamButton(
            semanticLabel: 'Submit the form',
            semanticHint: 'Sends your answers',
            child: const Text('Submit'),
          ),
        ),
      );

      expect(
        tester.semantics.find(find.byType(StreamButton)),
        isSemantics(
          label: 'Submit the form',
          hint: 'Sends your answers',
          isButton: true,
          hasEnabledState: true,
          isEnabled: false,
          hasTapAction: false,
        ),
      );

      handle.dispose();
    });

    testWidgets('icon button: semanticLabel replaces the tooltip in semantics', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _withStreamTheme(
          StreamButton.icon(
            icon: const Icon(Icons.add),
            tooltip: 'Add',
            semanticLabel: 'Add attachment',
            semanticHint: 'Opens the attachment picker',
            onPressed: () {},
          ),
        ),
      );

      final node = tester.semantics.find(find.byType(StreamButton));
      expect(
        node,
        isSemantics(
          label: 'Add attachment',
          hint: 'Opens the attachment picker',
          isButton: true,
          hasTapAction: true,
        ),
      );
      // Announced once: the tooltip is not also read.
      expect(node.tooltip, isEmpty);
      // The visual tooltip is still there for sighted users.
      expect(find.byTooltip('Add'), findsOneWidget);

      handle.dispose();
    });

    testWidgets('icon button: semanticHint alone keeps the tooltip as label', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _withStreamTheme(
          StreamButton.icon(
            icon: const Icon(Icons.add),
            tooltip: 'Add',
            semanticHint: 'Opens the attachment picker',
            onPressed: () {},
          ),
        ),
      );

      expect(
        tester.semantics.find(find.byType(StreamButton)),
        isSemantics(
          tooltip: 'Add',
          hint: 'Opens the attachment picker',
          isButton: true,
        ),
      );

      handle.dispose();
    });

    testWidgets('without them, no label or hint is added', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _withStreamTheme(
          StreamButton.icon(
            icon: const Icon(Icons.add),
            tooltip: 'Add',
            onPressed: () {},
          ),
        ),
      );

      final node = tester.semantics.find(find.byType(StreamButton));
      expect(node.label, isEmpty);
      expect(node.hint, isEmpty);
      expect(node.tooltip, 'Add');

      handle.dispose();
    });

    testWidgets('semantic props reach a custom builder', (tester) async {
      StreamButtonProps? received;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [StreamTheme()]),
          home: StreamComponentFactory(
            builders: StreamComponentBuilders(
              button: (context, props) {
                received = props;
                return const SizedBox();
              },
            ),
            child: StreamButton(
              semanticLabel: 'Label',
              semanticHint: 'Hint',
              onPressed: () {},
              child: const Text('Submit'),
            ),
          ),
        ),
      );

      expect(received?.semanticLabel, 'Label');
      expect(received?.semanticHint, 'Hint');
    });
  });

  // Test for https://github.com/GetStream/stream-chat-flutter/issues/2786
  testWidgets(
    'host-app ElevatedButtonThemeData.iconColor does not leak into StreamButton icons',
    (tester) async {
      const hostIconColor = Color(0xFF00FF00);

      Color? capturedIconColor;
      await tester.pumpWidget(
        _withStreamTheme(
          elevatedButtonTheme: const ElevatedButtonThemeData(
            style: ButtonStyle(iconColor: WidgetStatePropertyAll(hostIconColor)),
          ),
          StreamButton.icon(
            onPressed: () {},
            icon: Builder(
              builder: (context) {
                capturedIconColor = IconTheme.of(context).color;
                return const Icon(Icons.add);
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(capturedIconColor, isNot(hostIconColor));
    },
  );
}
