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
  group('StreamSwitch semantics', () {
    testWidgets('semanticLabel and semanticHint are announced on the switch', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _withStreamTheme(
          StreamSwitch(
            value: true,
            onChanged: (_) {},
            semanticLabel: 'Notifications',
            semanticHint: 'Mutes all channels when off',
          ),
        ),
      );

      expect(
        tester.semantics.find(find.byType(StreamSwitch)),
        isSemantics(
          label: 'Notifications',
          hint: 'Mutes all channels when off',
          hasToggledState: true,
          isToggled: true,
        ),
      );
      expect(find.bySemanticsLabel('Notifications'), findsOneWidget);

      handle.dispose();
    });

    testWidgets('semanticHint alone is announced on the switch', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _withStreamTheme(
          StreamSwitch(value: false, onChanged: (_) {}, semanticHint: 'Mutes all channels'),
        ),
      );

      expect(
        tester.semantics.find(find.byType(StreamSwitch)),
        isSemantics(hint: 'Mutes all channels', hasToggledState: true, isToggled: false),
      );

      handle.dispose();
    });

    testWidgets('without them, no label or hint is added', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _withStreamTheme(StreamSwitch(value: false, onChanged: (_) {})),
      );

      final node = tester.semantics.find(find.byType(StreamSwitch));
      expect(node.label, isEmpty);
      expect(node.hint, isEmpty);

      handle.dispose();
    });

    testWidgets('semanticHint reaches a custom builder', (tester) async {
      StreamSwitchProps? received;

      await tester.pumpWidget(
        _withStreamTheme(
          StreamComponentFactory(
            builders: StreamComponentBuilders(
              toggleSwitch: (context, props) {
                received = props;
                return const SizedBox();
              },
            ),
            child: StreamSwitch(value: false, onChanged: (_) {}, semanticHint: 'Hint'),
          ),
        ),
      );

      expect(received?.semanticHint, 'Hint');
    });
  });
}
