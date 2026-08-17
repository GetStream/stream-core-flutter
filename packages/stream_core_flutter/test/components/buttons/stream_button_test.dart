import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
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
