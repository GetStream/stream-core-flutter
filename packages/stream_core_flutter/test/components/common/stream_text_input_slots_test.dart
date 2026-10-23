import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

void main() {
  testWidgets(
    'StreamTextInput keeps receiving typed text after its leading and trailing are removed while focused',
    (tester) async {
      final showSlots = ValueNotifier(true);
      addTearDown(showSlots.dispose);

      await tester.pumpWidget(
        _ToggledTextInput(
          toggle: showSlots,
          builder: (context, show, _) => StreamTextInput(
            leading: show ? const Icon(Icons.drag_indicator) : null,
            trailing: show ? const Icon(Icons.remove_circle_outline) : null,
          ),
        ),
      );
      await tester.showKeyboard(find.byType(TextField));

      showSlots.value = false;
      await tester.pump();
      tester.testTextInput.enterText('Hello');
      await tester.pump();

      expect(find.text('Hello'), findsOneWidget);
    },
  );

  testWidgets(
    'StreamTextInput keeps receiving typed text after its leading and trailing are added while focused',
    (tester) async {
      final showSlots = ValueNotifier(false);
      addTearDown(showSlots.dispose);

      await tester.pumpWidget(
        _ToggledTextInput(
          toggle: showSlots,
          builder: (context, show, _) => StreamTextInput(
            leading: show ? const Icon(Icons.drag_indicator) : null,
            trailing: show ? const Icon(Icons.remove_circle_outline) : null,
          ),
        ),
      );
      await tester.showKeyboard(find.byType(TextField));

      showSlots.value = true;
      await tester.pump();
      tester.testTextInput.enterText('Hello');
      await tester.pump();

      expect(find.text('Hello'), findsOneWidget);
    },
  );

  testWidgets(
    'StreamTextInput keeps receiving typed text after its label is replaced by an outside helper text while focused',
    (tester) async {
      final showHelper = ValueNotifier(false);
      addTearDown(showHelper.dispose);

      await tester.pumpWidget(
        _ToggledTextInput(
          toggle: showHelper,
          builder: (context, show, _) => StreamTextInput(
            labelText: show ? null : 'Label',
            helperText: show ? 'Required' : null,
            style: const StreamTextInputStyle(helperAffinity: StreamHelperAffinity.outside),
          ),
        ),
      );
      await tester.showKeyboard(find.byType(TextField));

      showHelper.value = true;
      await tester.pump();
      tester.testTextInput.enterText('Hello');
      await tester.pump();

      expect(find.text('Hello'), findsOneWidget);
    },
  );
}

class _ToggledTextInput extends StatelessWidget {
  const _ToggledTextInput({required this.toggle, required this.builder});

  final ValueListenable<bool> toggle;
  final ValueWidgetBuilder<bool> builder;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(extensions: [StreamTheme()]),
      home: Scaffold(
        body: ValueListenableBuilder(
          valueListenable: toggle,
          builder: builder,
        ),
      ),
    );
  }
}
