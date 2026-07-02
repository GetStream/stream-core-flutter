import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

void main() {
  Widget buildSubject({
    required int value,
    int min = 0,
    int max = 10,
    ValueChanged<int>? onChanged,
    String? semanticLabel,
  }) {
    return MaterialApp(
      theme: ThemeData(extensions: [StreamTheme()]),
      home: Scaffold(
        body: Center(
          child: StreamStepper(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
            semanticLabel: semanticLabel,
          ),
        ),
      ),
    );
  }

  void invoke(WidgetTester tester, SemanticsAction action) {
    final id = tester.getSemantics(find.byType(StreamStepper)).id;
    tester.binding.pipelineOwner.semanticsOwner!.performAction(id, action);
  }

  group('semantic shape', () {
    testWidgets('mid-range exposes slider + both directions', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        buildSubject(value: 5, semanticLabel: 'Quantity', onChanged: (_) {}),
      );

      expect(
        tester.getSemantics(find.byType(StreamStepper)),
        matchesSemantics(
          isSlider: true,
          isEnabled: true,
          hasEnabledState: true,
          label: 'Quantity',
          value: '5',
          increasedValue: '6',
          decreasedValue: '4',
          hasIncreaseAction: true,
          hasDecreaseAction: true,
        ),
      );

      handle.dispose();
    });

    testWidgets('disabled (onChanged null) drops actions', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(buildSubject(value: 5, onChanged: null));

      expect(
        tester.getSemantics(find.byType(StreamStepper)),
        matchesSemantics(
          isSlider: true,
          hasEnabledState: true,
          value: '5',
        ),
      );

      handle.dispose();
    });

    testWidgets('no semanticLabel → label is empty', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(buildSubject(value: 5, onChanged: (_) {}));

      final data = tester.getSemantics(find.byType(StreamStepper)).getSemanticsData();
      expect(data.label, isEmpty);
      expect(data.value, equals('5'));

      handle.dispose();
    });
  });

  group('boundaries', () {
    testWidgets('at min: no decrease action exposed', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(buildSubject(value: 0, min: 0, max: 10, onChanged: (_) {}));

      expect(
        tester.getSemantics(find.byType(StreamStepper)),
        matchesSemantics(
          isSlider: true,
          isEnabled: true,
          hasEnabledState: true,
          value: '0',
          increasedValue: '1',
          hasIncreaseAction: true,
        ),
      );

      handle.dispose();
    });

    testWidgets('at max: no increase action exposed', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(buildSubject(value: 10, min: 0, max: 10, onChanged: (_) {}));

      expect(
        tester.getSemantics(find.byType(StreamStepper)),
        matchesSemantics(
          isSlider: true,
          isEnabled: true,
          hasEnabledState: true,
          value: '10',
          decreasedValue: '9',
          hasDecreaseAction: true,
        ),
      );

      handle.dispose();
    });

    testWidgets('single-value range (min == max): no actions', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(buildSubject(value: 5, min: 5, max: 5, onChanged: (_) {}));

      final data = tester.getSemantics(find.byType(StreamStepper)).getSemanticsData();
      expect(data.value, equals('5'));
      expect(data.hasAction(SemanticsAction.increase), isFalse);
      expect(data.hasAction(SemanticsAction.decrease), isFalse);

      handle.dispose();
    });
  });

  group('actions', () {
    testWidgets('increase action calls onChanged with value + 1', (tester) async {
      final handle = tester.ensureSemantics();
      int? received;
      await tester.pumpWidget(buildSubject(value: 5, onChanged: (v) => received = v));

      invoke(tester, SemanticsAction.increase);
      expect(received, equals(6));

      handle.dispose();
    });

    testWidgets('decrease action calls onChanged with value - 1', (tester) async {
      final handle = tester.ensureSemantics();
      int? received;
      await tester.pumpWidget(buildSubject(value: 5, onChanged: (v) => received = v));

      invoke(tester, SemanticsAction.decrease);
      expect(received, equals(4));

      handle.dispose();
    });

    testWidgets('at max: invoking increase is a no-op (action absent)', (tester) async {
      final handle = tester.ensureSemantics();
      int? received;
      await tester.pumpWidget(
        buildSubject(value: 10, min: 0, max: 10, onChanged: (v) => received = v),
      );

      invoke(tester, SemanticsAction.increase);
      expect(received, isNull);

      handle.dispose();
    });

    testWidgets('at min: invoking decrease is a no-op (action absent)', (tester) async {
      final handle = tester.ensureSemantics();
      int? received;
      await tester.pumpWidget(
        buildSubject(value: 0, min: 0, max: 10, onChanged: (v) => received = v),
      );

      invoke(tester, SemanticsAction.decrease);
      expect(received, isNull);

      handle.dispose();
    });
  });

  group('exclusion', () {
    testWidgets('child buttons + text input do not produce extra focus stops', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        buildSubject(value: 5, semanticLabel: 'Quantity', onChanged: (_) {}),
      );

      final traversal = tester.semantics.simulatedAccessibilityTraversal().toList();
      final interactive = traversal.where((node) {
        final data = node.getSemanticsData();
        return data.hasFlag(SemanticsFlag.isButton) ||
            data.hasFlag(SemanticsFlag.isTextField) ||
            data.hasFlag(SemanticsFlag.isSlider);
      }).toList();

      expect(interactive, hasLength(1));
      expect(interactive.single.getSemanticsData().hasFlag(SemanticsFlag.isSlider), isTrue);

      handle.dispose();
    });
  });

  group('focus isolation', () {
    testWidgets('inner FocusScope blocks descendant focus traversal', (tester) async {
      await tester.pumpWidget(buildSubject(value: 5, onChanged: (_) {}));

      final scope = tester.widget<FocusScope>(
        find.descendant(
          of: find.byType(StreamStepper),
          matching: find.byType(FocusScope),
        ),
      );
      expect(scope.canRequestFocus, isFalse);
      expect(scope.descendantsAreFocusable, isFalse);
    });

    testWidgets('Tab traversal skips the stepper subtree', (tester) async {
      final beforeFocus = FocusNode(debugLabel: 'before');
      final afterFocus = FocusNode(debugLabel: 'after');
      addTearDown(beforeFocus.dispose);
      addTearDown(afterFocus.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [StreamTheme()]),
          home: Scaffold(
            body: Column(
              children: [
                Focus(focusNode: beforeFocus, child: const SizedBox(width: 1, height: 1)),
                StreamStepper(value: 5, onChanged: (_) {}),
                Focus(focusNode: afterFocus, child: const SizedBox(width: 1, height: 1)),
              ],
            ),
          ),
        ),
      );

      beforeFocus.requestFocus();
      await tester.pump();
      expect(beforeFocus.hasFocus, isTrue);

      beforeFocus.nextFocus();
      await tester.pump();

      expect(afterFocus.hasFocus, isTrue);
    });

    testWidgets('inner value display does not hit-test (IgnorePointer)', (tester) async {
      await tester.pumpWidget(buildSubject(value: 5, onChanged: (_) {}));

      final stepperRect = tester.getRect(find.byType(StreamStepper));
      final hits = HitTestResult();
      tester.binding.hitTestInView(hits, stepperRect.center, tester.view.viewId);
      final hitTextField = hits.path.any((entry) => entry.target is RenderEditable);
      expect(hitTextField, isFalse);
    });

    testWidgets('semantic increase action still drives the value through the FocusScope', (tester) async {
      final handle = tester.ensureSemantics();
      int? received;
      await tester.pumpWidget(buildSubject(value: 5, onChanged: (v) => received = v));

      invoke(tester, SemanticsAction.increase);
      expect(received, equals(6));

      handle.dispose();
    });
  });
}
