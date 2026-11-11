import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

Widget _withStreamTheme(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [StreamTheme()]),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('StreamCheckbox semantics', () {
    testWidgets('semanticLabel and semanticHint are announced on the checkbox', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _withStreamTheme(
          StreamCheckbox(
            value: true,
            onChanged: (_) {},
            semanticLabel: 'Accept terms',
            semanticHint: 'Required to continue',
          ),
        ),
      );

      expect(
        tester.semantics.find(find.byType(StreamCheckbox)),
        isSemantics(
          label: 'Accept terms',
          hint: 'Required to continue',
          hasCheckedState: true,
          isChecked: true,
        ),
      );
      expect(find.bySemanticsLabel('Accept terms'), findsOneWidget);

      handle.dispose();
    });

    testWidgets('circular checkbox forwards semanticHint', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _withStreamTheme(
          StreamCheckbox.circular(
            value: false,
            onChanged: (_) {},
            semanticLabel: 'Option A',
            semanticHint: 'Selects option A',
          ),
        ),
      );

      expect(
        tester.semantics.find(find.byType(StreamCheckbox)),
        isSemantics(label: 'Option A', hint: 'Selects option A', hasCheckedState: true, isChecked: false),
      );

      handle.dispose();
    });

    testWidgets('without semanticHint, no hint is announced', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _withStreamTheme(
          StreamCheckbox(value: false, onChanged: (_) {}, semanticLabel: 'Accept terms'),
        ),
      );

      final node = tester.semantics.find(find.byType(StreamCheckbox));
      expect(node.label, 'Accept terms');
      expect(node.hint, isEmpty);

      handle.dispose();
    });

    testWidgets('semanticHint reaches a custom builder', (tester) async {
      StreamCheckboxProps? received;

      await tester.pumpWidget(
        _withStreamTheme(
          StreamComponentFactory(
            builders: StreamComponentBuilders(
              checkbox: (context, props) {
                received = props;
                return const SizedBox();
              },
            ),
            child: StreamCheckbox(value: false, onChanged: (_) {}, semanticHint: 'Hint'),
          ),
        ),
      );

      expect(received?.semanticHint, 'Hint');
    });
  });
}
