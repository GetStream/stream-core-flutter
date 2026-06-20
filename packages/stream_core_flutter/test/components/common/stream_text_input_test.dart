import 'dart:ui' show SemanticsAction, Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

Widget _withStreamTheme(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [StreamTheme()]),
    home: Scaffold(body: child),
  );
}

void main() {
  group('StreamTextInput a11y', () {
    testWidgets('meets accessibility guidelines', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _withStreamTheme(StreamTextInput(hintText: 'Email')),
      );

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));

      handle.dispose();
    });

    testWidgets('exposes isTextField with hintText as the label', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _withStreamTheme(StreamTextInput(hintText: 'Email')),
      );

      expect(
        tester.getSemantics(find.byType(StreamTextInput)),
        isSemantics(
          isTextField: true,
          label: 'Email',
          hasTapAction: true,
          isEnabled: true,
          hasEnabledState: true,
        ),
      );

      handle.dispose();
    });

    testWidgets('disabled — value is still announced; tap exposed but enabled=false', (tester) async {
      final handle = tester.ensureSemantics();
      final controller = TextEditingController(text: 'existing');
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _withStreamTheme(
          StreamTextInput(hintText: 'Email', enabled: false, controller: controller),
        ),
      );

      // A disabled field still announces its current text to SR users so
      // they can read what's been entered. `tap` is exposed but the
      // `enabled: false` flag tells the platform not to dispatch it.
      expect(
        tester.getSemantics(find.byType(StreamTextInput)),
        isSemantics(
          isTextField: true,
          value: 'existing',
          isEnabled: false,
          hasEnabledState: true,
          hasTapAction: true,
          hasFocusAction: false,
        ),
      );

      handle.dispose();
    });

    testWidgets('read-only — isReadOnly, no tap action, focus action exposed', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _withStreamTheme(StreamTextInput(hintText: 'Email', readOnly: true)),
      );

      // Read-only fields don't expose `tap` (tapping would normally request
      // the keyboard which isn't applicable), but they remain focusable so
      // SR users can navigate to them and read the value with selection
      // gestures.
      expect(
        tester.getSemantics(find.byType(StreamTextInput)),
        isSemantics(
          isTextField: true,
          isReadOnly: true,
          label: 'Email',
          isEnabled: true,
          hasEnabledState: true,
          hasTapAction: false,
          hasFocusAction: true,
        ),
      );

      handle.dispose();
    });

    testWidgets('hint is only the semantic label while the field is empty', (tester) async {
      // Once the user enters text, the hint is hidden visually and should
      // disappear from the semantic label so SR users don't hear it
      // duplicated alongside the value.
      final handle = tester.ensureSemantics();
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _withStreamTheme(StreamTextInput(hintText: 'Email', controller: controller)),
      );

      var node = tester.getSemantics(find.byType(StreamTextInput));
      expect(node.label, 'Email');
      expect(node.value, '');

      controller.text = 'user@example.com';
      await tester.pump();

      node = tester.getSemantics(find.byType(StreamTextInput));
      expect(node.label, '');
      expect(node.value, 'user@example.com');

      handle.dispose();
    });

    testWidgets('focused flag tracks the focus node state', (tester) async {
      final handle = tester.ensureSemantics();
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);

      await tester.pumpWidget(
        _withStreamTheme(StreamTextInput(hintText: 'Email', focusNode: focusNode)),
      );

      expect(
        tester.getSemantics(find.byType(StreamTextInput)).getSemanticsData().flagsCollection.isFocused,
        Tristate.isFalse,
      );

      focusNode.requestFocus();
      await tester.pump();

      expect(
        tester.getSemantics(find.byType(StreamTextInput)).getSemanticsData().flagsCollection.isFocused,
        Tristate.isTrue,
      );

      handle.dispose();
    });

    testWidgets('SemanticsAction.tap actually focuses the field', (tester) async {
      // Verifies the wiring — not just that the action is exposed, but that
      // invoking it (the way TalkBack/VoiceOver would) actually moves focus
      // to the underlying editable.
      final handle = tester.ensureSemantics();
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);

      await tester.pumpWidget(
        _withStreamTheme(StreamTextInput(hintText: 'Email', focusNode: focusNode)),
      );

      expect(focusNode.hasFocus, isFalse);

      tester.semantics.performAction(
        find.semantics.byLabel('Email'),
        SemanticsAction.tap,
      );
      await tester.pumpAndSettle();

      expect(focusNode.hasFocus, isTrue);

      handle.dispose();
    });

    testWidgets('helperText with error state surfaces as the semantic hint', (tester) async {
      // The error lands on the field's semantic `hint` and the helper
      // container becomes a live region so SR auto-fires on appearance.
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _withStreamTheme(
          StreamTextInput(
            hintText: 'Email',
            helperText: 'Invalid email address',
            helperState: StreamHelperState.error,
          ),
        ),
      );

      expect(
        tester.getSemantics(find.byType(StreamTextInput)).hint,
        'Invalid email address',
      );
      expect(
        tester.getSemantics(find.byType(StreamHelperText)).getSemanticsData().flagsCollection.isLiveRegion,
        isTrue,
      );

      handle.dispose();
    });

    testWidgets('helperText with info state does not become the semantic hint', (tester) async {
      // Info / success helpers should NOT appear as the field's hint —
      // hint is reserved for validation errors. They still get their own
      // semantic node (not a live region) for users navigating the tree.
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _withStreamTheme(
          StreamTextInput(
            hintText: 'Email',
            helperText: 'We never share your email.',
            helperState: StreamHelperState.info,
          ),
        ),
      );

      expect(tester.getSemantics(find.byType(StreamTextInput)).hint, '');
      expect(
        tester.getSemantics(find.byType(StreamHelperText)).getSemanticsData().flagsCollection.isLiveRegion,
        isFalse,
      );

      handle.dispose();
    });

    testWidgets('maxLength surfaces as maxValueLength / currentValueLength', (tester) async {
      final handle = tester.ensureSemantics();
      final controller = TextEditingController(text: 'hi');
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _withStreamTheme(StreamTextInput(hintText: 'Code', controller: controller, maxLength: 6)),
      );

      final node = tester.getSemantics(find.byType(StreamTextInput));
      expect(node.maxValueLength, 6);
      expect(node.currentValueLength, 2);

      handle.dispose();
    });

    testWidgets('leading → trailing traversal order is logical, not visual', (tester) async {
      // Without sort keys, RTL flips the row's visual order so SR would
      // traverse trailing-then-leading. The sort keys force logical order
      // regardless of text direction.
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [StreamTheme()]),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: StreamTextInput(
                hintText: 'Email',
                leading: const Icon(Icons.alternate_email, semanticLabel: 'leading-mail'),
                trailing: StreamButton.icon(
                  icon: const Icon(Icons.close),
                  tooltip: 'Clear',
                  onPressed: () {},
                ),
              ),
            ),
          ),
        ),
      );

      final order = tester.semantics.simulatedAccessibilityTraversal().map((n) => '${n.label}|${n.tooltip}').toList();
      final leadingIndex = order.indexWhere((s) => s.contains('leading-mail'));
      final trailingIndex = order.indexWhere((s) => s.contains('Clear'));

      expect(leadingIndex, isNonNegative, reason: 'leading should be in traversal');
      expect(trailingIndex, greaterThan(leadingIndex), reason: 'leading must precede trailing logically, not visually');

      handle.dispose();
    });

    testWidgets(
      'interactive trailing widget is not merged into the input chassis',
      (tester) async {
        final handle = tester.ensureSemantics();

        await tester.pumpWidget(
          _withStreamTheme(
            StreamTextInput(
              hintText: 'Search',
              trailing: StreamButton.icon(
                icon: const Icon(Icons.close),
                tooltip: 'Clear',
                onPressed: () {},
              ),
            ),
          ),
        );

        final buttonNode = tester.semantics.find(find.byType(StreamButton));
        final inputNode = tester.semantics.find(find.byType(StreamTextInput));
        expect(buttonNode.id, isNot(inputNode.id));

        expect(
          buttonNode,
          isSemantics(
            tooltip: 'Clear',
            isButton: true,
            hasTapAction: true,
          ),
        );

        handle.dispose();
      },
    );
  });
}
