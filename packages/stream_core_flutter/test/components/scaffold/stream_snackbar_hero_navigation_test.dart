import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

// Random navigation in a layout of side-by-side navigators and tabs, with a
// root page pushed and popped after every step. The seeds are fixed, so a
// failure replays exactly.
void main() {
  for (final seed in List.generate(40, (index) => index)) {
    testWidgets('a scope snackbar survives random navigation across nested navigators, seed $seed', (tester) async {
      final random = Random(seed);
      final navigatorKey = GlobalKey<NavigatorState>();
      final paneNavigatorKeys = List.generate(4, (_) => GlobalKey<NavigatorState>());
      final firstPaneKey = GlobalKey();
      final tabIndex = ValueNotifier(0);
      addTearDown(tabIndex.dispose);
      final tabs = [
        _Pane(navigatorKey: paneNavigatorKeys[2]),
        _Pane(navigatorKey: paneNavigatorKeys[3]),
      ];

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          theme: ThemeData(extensions: [StreamTheme()]),
          builder: (context, child) => StreamSnackbarScope(child: child!),
          home: Material(
            child: Row(
              children: [
                Expanded(
                  child: _Pane(navigatorKey: paneNavigatorKeys[0], scaffoldKey: firstPaneKey),
                ),
                Expanded(child: _Pane(navigatorKey: paneNavigatorKeys[1])),
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: tabIndex,
                    builder: (context, index, _) => IndexedStack(index: index, children: tabs),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      StreamSnackbarMessenger.of(firstPaneKey.currentContext!).show(
        StreamSnackbar(message: const Text(_kMessage), duration: const Duration(hours: 1)),
      );
      await tester.pumpAndSettle();

      final depths = List.filled(paneNavigatorKeys.length, 0);
      final steps = <String>[];
      for (var step = 0; step < 20; step++) {
        final action = random.nextInt(5);
        final pane = random.nextInt(paneNavigatorKeys.length);
        final navigator = paneNavigatorKeys[pane].currentState!;
        switch (action) {
          case 0:
            navigator.push(MaterialPageRoute<void>(builder: (_) => const ColoredBox(color: Colors.white))).ignore();
            depths[pane]++;
            steps.add('plain page in pane $pane');
          case 1:
            navigator
                .push(MaterialPageRoute<void>(builder: (_) => const StreamScaffold(body: SizedBox.expand())))
                .ignore();
            depths[pane]++;
            steps.add('StreamScaffold page in pane $pane');
          case 2 when depths[pane] > 0:
            navigator.pop();
            depths[pane]--;
            steps.add('pop in pane $pane');
          case 3:
            tabIndex.value = 1 - tabIndex.value;
            steps.add('switch tabs');
          default:
            steps.add('nothing');
        }
        // Either let the step settle or start the root transition in the
        // same frame.
        if (random.nextBool()) await tester.pumpAndSettle();

        navigatorKey.currentState!
            .push(MaterialPageRoute<void>(builder: (_) => const StreamScaffold(body: SizedBox.expand())))
            .ignore();
        await _pumpFrames(tester, 25);
        navigatorKey.currentState!.pop();
        await _pumpFrames(tester, 25);

        expect(tester.takeException(), isNull, reason: 'after: ${steps.join(', ')}');
      }
    });
  }
}

const _kMessage = 'Message copied';

Future<void> _pumpFrames(WidgetTester tester, int count) async {
  for (var frame = 0; frame < count; frame++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

// A pane with its own navigator, starting on a StreamScaffold. Its pages fly
// heroes, as go_router's nested navigators do.
class _Pane extends StatefulWidget {
  const _Pane({required this.navigatorKey, this.scaffoldKey});

  final GlobalKey<NavigatorState> navigatorKey;
  final Key? scaffoldKey;

  @override
  State<_Pane> createState() => _PaneState();
}

class _PaneState extends State<_Pane> {
  final _heroController = MaterialApp.createMaterialHeroController();

  @override
  void dispose() {
    _heroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HeroControllerScope(
      controller: _heroController,
      child: Navigator(
        key: widget.navigatorKey,
        onGenerateRoute: (_) => MaterialPageRoute<void>(
          builder: (_) => StreamScaffold(key: widget.scaffoldKey, body: const SizedBox.expand()),
        ),
      ),
    );
  }
}
