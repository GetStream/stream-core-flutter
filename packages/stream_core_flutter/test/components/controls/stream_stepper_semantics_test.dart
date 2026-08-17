import 'package:flutter/semantics.dart' show SemanticsAction;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
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
    tester.semantics.performAction(
      find.semantics.byPredicate((n) => n.getSemanticsData().hasAction(action)),
      action,
    );
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
      await tester.pumpWidget(buildSubject(value: 5));

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
      await tester.pumpWidget(buildSubject(value: 0, onChanged: (_) {}));

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
      await tester.pumpWidget(buildSubject(value: 10, onChanged: (_) {}));

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

    testWidgets('at max: increase action is absent', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(buildSubject(value: 10, onChanged: (_) {}));

      final data = tester.getSemantics(find.byType(StreamStepper)).getSemanticsData();
      expect(data.hasAction(SemanticsAction.increase), isFalse);

      handle.dispose();
    });

    testWidgets('at min: decrease action is absent', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(buildSubject(value: 0, onChanged: (_) {}));

      final data = tester.getSemantics(find.byType(StreamStepper)).getSemanticsData();
      expect(data.hasAction(SemanticsAction.decrease), isFalse);

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
        final flags = node.getSemanticsData().flagsCollection;
        return flags.isButton || flags.isTextField || flags.isSlider;
      }).toList();

      expect(interactive, hasLength(1));
      expect(interactive.single.getSemanticsData().flagsCollection.isSlider, isTrue);

      handle.dispose();
    });
  });
}
