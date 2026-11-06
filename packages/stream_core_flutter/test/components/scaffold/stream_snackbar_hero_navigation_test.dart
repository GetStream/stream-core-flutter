import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

void main() {
  testWidgets('StreamScaffolds side by side each keep their snackbar through a push and a pop', (tester) async {
    final leftKey = GlobalKey();
    final rightKey = GlobalKey();
    final navigatorKey = GlobalKey<NavigatorState>();

    await _pumpApp(
      tester,
      navigatorKey: navigatorKey,
      home: Row(
        children: [
          Expanded(
            child: StreamScaffold(key: leftKey, body: const SizedBox.expand()),
          ),
          Expanded(
            child: StreamScaffold(key: rightKey, body: const SizedBox.expand()),
          ),
        ],
      ),
    );
    StreamSnackbarMessenger.of(leftKey.currentContext!).show(
      StreamSnackbar(message: const Text(_kMessage), duration: const Duration(minutes: 1)),
    );
    await tester.pumpAndSettle();

    expect(find.byWidgetPredicate(_isSnackbarHero), findsNothing);

    navigatorKey.currentState!
        .push(MaterialPageRoute<void>(builder: (_) => const StreamScaffold(body: SizedBox.expand())))
        .ignore();
    final paintedPerPanePerFrame = <(int, int)>[];
    for (var frame = 0; frame < 30; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      paintedPerPanePerFrame.add((_paintedCopiesIn(tester, leftKey), _paintedCopiesIn(tester, rightKey)));
    }
    navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(paintedPerPanePerFrame.expand((counts) => [counts.$1, counts.$2]), everyElement(lessThanOrEqualTo(1)));
  });

  testWidgets('tabs with their own navigators cross-fade the snackbar through a root push and pop', (
    tester,
  ) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    final tabKey = GlobalKey();

    await _pumpApp(
      tester,
      navigatorKey: navigatorKey,
      home: Scaffold(
        body: IndexedStack(
          children: [
            _TabNavigator(
              page: StreamScaffold(key: tabKey, body: const SizedBox.expand()),
            ),
            const _TabNavigator(page: StreamScaffold(body: SizedBox.expand())),
          ],
        ),
      ),
    );
    StreamSnackbarMessenger.of(tabKey.currentContext!).show(
      StreamSnackbar(message: const Text(_kMessage), duration: const Duration(minutes: 1)),
    );
    await tester.pumpAndSettle();

    final painted = await _paintedThroughPushAndPop(tester, navigatorKey);

    expect(tester.takeException(), isNull);
    expect(find.byWidgetPredicate(_isSnackbarHero), findsNothing);
    expect(painted, everyElement(lessThanOrEqualTo(2)));
    expect(_paintedCopies(tester), 1);
  });

  testWidgets(
    'branches hidden by Offstage and TickerMode cross-fade the snackbar through a root push and pop',
    (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      final tabKey = GlobalKey();

      Widget branch({required bool active, required Widget page}) {
        return Offstage(
          offstage: !active,
          child: TickerMode(
            enabled: active,
            child: _TabNavigator(page: page),
          ),
        );
      }

      await _pumpApp(
        tester,
        navigatorKey: navigatorKey,
        home: Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              branch(active: false, page: const StreamScaffold(body: SizedBox.expand())),
              branch(
                active: true,
                page: StreamScaffold(key: tabKey, body: const SizedBox.expand()),
              ),
            ],
          ),
        ),
      );
      StreamSnackbarMessenger.of(tabKey.currentContext!).show(
        StreamSnackbar(message: const Text(_kMessage), duration: const Duration(minutes: 1)),
      );
      await tester.pumpAndSettle();

      final painted = await _paintedThroughPushAndPop(tester, navigatorKey);

      expect(tester.takeException(), isNull);
      expect(find.byWidgetPredicate(_isSnackbarHero), findsNothing);
      expect(painted, everyElement(lessThanOrEqualTo(2)));
      expect(_paintedCopies(tester), 1);
    },
  );

  testWidgets('tabs with a page pushed inside one cross-fade the snackbar through a root push and pop', (tester) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    final tabNavigatorKey = GlobalKey<NavigatorState>();

    await _pumpApp(
      tester,
      navigatorKey: navigatorKey,
      home: Scaffold(
        body: IndexedStack(
          children: [
            _TabNavigator(
              navigatorKey: tabNavigatorKey,
              page: const StreamScaffold(body: SizedBox.expand()),
            ),
            const _TabNavigator(page: StreamScaffold(body: SizedBox.expand())),
          ],
        ),
      ),
    );
    await _push(tester, tabNavigatorKey, const StreamScaffold(body: SizedBox.expand()));
    StreamSnackbarMessenger.of(tabNavigatorKey.currentContext!).show(
      StreamSnackbar(message: const Text(_kMessage), duration: const Duration(minutes: 1)),
    );
    await tester.pumpAndSettle();

    final painted = await _paintedThroughPushAndPop(tester, navigatorKey);

    expect(tester.takeException(), isNull);
    expect(find.byWidgetPredicate(_isSnackbarHero), findsNothing);
    expect(painted, everyElement(lessThanOrEqualTo(2)));
    expect(_paintedCopies(tester), 1);
  });

  testWidgets('side-by-side navigators cross-fade the snackbar after a plain page is pushed and popped in one', (
    tester,
  ) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    final leftNavigatorKey = GlobalKey<NavigatorState>();
    final leftKey = GlobalKey();

    await _pumpApp(
      tester,
      navigatorKey: navigatorKey,
      home: Scaffold(
        body: Row(
          children: [
            Expanded(
              child: _Pane(navigatorKey: leftNavigatorKey, scaffoldKey: leftKey),
            ),
            const Expanded(child: _Pane()),
          ],
        ),
      ),
    );
    StreamSnackbarMessenger.of(leftKey.currentContext!).show(
      StreamSnackbar(message: const Text(_kMessage), duration: const Duration(minutes: 1)),
    );
    await tester.pumpAndSettle();

    await _push(tester, leftNavigatorKey, const ColoredBox(color: Colors.white));
    leftNavigatorKey.currentState!.pop();
    await tester.pumpAndSettle();
    final painted = await _paintedThroughPushAndPop(tester, navigatorKey);

    expect(tester.takeException(), isNull);
    expect(find.byWidgetPredicate(_isSnackbarHero), findsNothing);
    expect(painted, everyElement(lessThanOrEqualTo(3)));
  });

  testWidgets('side-by-side navigators cross-fade the snackbar after a dialog opens and closes in one', (tester) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    final leftNavigatorKey = GlobalKey<NavigatorState>();
    final leftKey = GlobalKey();

    await _pumpApp(
      tester,
      navigatorKey: navigatorKey,
      home: Scaffold(
        body: Row(
          children: [
            Expanded(
              child: _Pane(navigatorKey: leftNavigatorKey, scaffoldKey: leftKey),
            ),
            const Expanded(child: _Pane()),
          ],
        ),
      ),
    );
    StreamSnackbarMessenger.of(leftKey.currentContext!).show(
      StreamSnackbar(message: const Text(_kMessage), duration: const Duration(minutes: 1)),
    );
    await tester.pumpAndSettle();

    showDialog<void>(
      context: leftNavigatorKey.currentContext!,
      useRootNavigator: false,
      builder: (_) => const SizedBox(width: 100, height: 100),
    ).ignore();
    await tester.pumpAndSettle();
    leftNavigatorKey.currentState!.pop();
    await tester.pumpAndSettle();
    final painted = await _paintedThroughPushAndPop(tester, navigatorKey);

    expect(tester.takeException(), isNull);
    expect(find.byWidgetPredicate(_isSnackbarHero), findsNothing);
    expect(painted, everyElement(lessThanOrEqualTo(3)));
  });

  testWidgets('side-by-side navigators cross-fade the snackbar after a back swipe in one', (tester) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    final leftNavigatorKey = GlobalKey<NavigatorState>();
    final leftKey = GlobalKey();

    await _pumpApp(
      tester,
      navigatorKey: navigatorKey,
      home: Scaffold(
        body: Row(
          children: [
            Expanded(
              child: _Pane(navigatorKey: leftNavigatorKey, scaffoldKey: leftKey),
            ),
            const Expanded(child: _Pane()),
          ],
        ),
      ),
    );
    StreamSnackbarMessenger.of(leftKey.currentContext!).show(
      StreamSnackbar(message: const Text(_kMessage), duration: const Duration(minutes: 1)),
    );
    await tester.pumpAndSettle();

    leftNavigatorKey.currentState!
        .push(CupertinoPageRoute<void>(builder: (_) => const ColoredBox(color: Colors.white)))
        .ignore();
    await tester.pumpAndSettle();
    final gesture = await tester.startGesture(const Offset(5, 200));
    await gesture.moveBy(const Offset(300, 0));
    await gesture.up();
    await tester.pumpAndSettle();
    final painted = await _paintedThroughPushAndPop(tester, navigatorKey);

    expect(tester.takeException(), isNull);
    expect(find.byWidgetPredicate(_isSnackbarHero), findsNothing);
    expect(painted, everyElement(lessThanOrEqualTo(3)));
  });

  testWidgets('two colliding StreamScaffolds that mount in one frame never carry the hero together', (tester) async {
    final messenger = StreamSnackbarMessenger();
    addTearDown(messenger.dispose);
    messenger.show(StreamSnackbar(message: const Text(_kMessage)));
    // Skips the entry fade, so the first frame builds the snackbar outright.
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(
      accessibleNavigation: true,
    );
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    await _pumpApp(
      tester,
      messenger: messenger,
      home: const Scaffold(
        body: Row(
          children: [
            Expanded(child: _Pane()),
            Expanded(child: _Pane()),
          ],
        ),
      ),
    );

    expect(find.byWidgetPredicate(_isSnackbarHero).evaluate().length, lessThanOrEqualTo(1));
    await tester.pumpAndSettle();
    expect(find.byWidgetPredicate(_isSnackbarHero), findsNothing);
  });

  testWidgets('side-by-side panes and tabs cross-fade the snackbar through a sequence of navigations', (tester) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    final paneNavigatorKey = GlobalKey<NavigatorState>();
    final tabNavigatorKeys = [GlobalKey<NavigatorState>(), GlobalKey<NavigatorState>()];
    final paneKey = GlobalKey();
    final index = ValueNotifier(0);
    addTearDown(index.dispose);
    final tabs = [
      for (final key in tabNavigatorKeys) _Pane(navigatorKey: key),
    ];

    await _pumpApp(
      tester,
      navigatorKey: navigatorKey,
      home: Scaffold(
        body: Row(
          children: [
            Expanded(
              child: _Pane(navigatorKey: paneNavigatorKey, scaffoldKey: paneKey),
            ),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: index,
                builder: (context, index, _) => IndexedStack(index: index, children: tabs),
              ),
            ),
          ],
        ),
      ),
    );
    StreamSnackbarMessenger.of(paneKey.currentContext!).show(
      StreamSnackbar(message: const Text(_kMessage), duration: const Duration(minutes: 1)),
    );
    await tester.pumpAndSettle();

    Future<void> pushAndPop(GlobalKey<NavigatorState> key, Widget page) async {
      await _push(tester, key, page);
      key.currentState!.pop();
      await tester.pumpAndSettle();
    }

    const plainPage = ColoredBox(color: Colors.white);
    const scaffoldPage = StreamScaffold(body: SizedBox.expand());
    final steps = <String, Future<void> Function()>{
      'plain page in the pane': () => pushAndPop(paneNavigatorKey, plainPage),
      'StreamScaffold page in the pane': () => pushAndPop(paneNavigatorKey, scaffoldPage),
      'plain page in the first tab': () => pushAndPop(tabNavigatorKeys[0], plainPage),
      'StreamScaffold page in the first tab': () => pushAndPop(tabNavigatorKeys[0], scaffoldPage),
      'switch to the second tab': () async {
        index.value = 1;
        await tester.pumpAndSettle();
      },
      'plain page in the second tab': () => pushAndPop(tabNavigatorKeys[1], plainPage),
      'plain page pushed in the pane and left there': () => _push(tester, paneNavigatorKey, plainPage),
      'switch back to the first tab': () async {
        index.value = 0;
        await tester.pumpAndSettle();
      },
      'pane page popped': () async {
        paneNavigatorKey.currentState!.pop();
        await tester.pumpAndSettle();
      },
    };

    for (final MapEntry(key: step, value: run) in steps.entries) {
      await run();
      final painted = await _paintedThroughPushAndPop(tester, navigatorKey);

      expect(tester.takeException(), isNull, reason: 'after: $step');
      expect(find.byWidgetPredicate(_isSnackbarHero), findsNothing, reason: 'after: $step');
      expect(painted, everyElement(lessThanOrEqualTo(3)), reason: 'after: $step');
    }
  });

  // Random navigation in a layout of side-by-side navigators and tabs, with a
  // root page pushed and popped after every step. The seeds are fixed, so a
  // failure replays exactly.
  for (final seed in List.generate(40, (index) => index)) {
    testWidgets('a scope snackbar survives random navigation across nested navigators, seed $seed', (tester) async {
      final random = Random(seed);
      final navigatorKey = GlobalKey<NavigatorState>();
      final paneNavigatorKeys = List.generate(4, (_) => GlobalKey<NavigatorState>());
      final firstPaneKey = GlobalKey();
      final tabIndex = ValueNotifier(0);
      addTearDown(tabIndex.dispose);
      final tabs = [
        _TabNavigator(
          navigatorKey: paneNavigatorKeys[2],
          page: const StreamScaffold(body: SizedBox.expand()),
        ),
        _TabNavigator(
          navigatorKey: paneNavigatorKeys[3],
          page: const StreamScaffold(body: SizedBox.expand()),
        ),
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
                  child: _TabNavigator(
                    navigatorKey: paneNavigatorKeys[0],
                    page: StreamScaffold(key: firstPaneKey, body: const SizedBox.expand()),
                  ),
                ),
                Expanded(
                  child: _TabNavigator(
                    navigatorKey: paneNavigatorKeys[1],
                    page: const StreamScaffold(body: SizedBox.expand()),
                  ),
                ),
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
        await _pumpFrames(tester, const Duration(milliseconds: 400));
        navigatorKey.currentState!.pop();
        await _pumpFrames(tester, const Duration(milliseconds: 400));

        expect(tester.takeException(), isNull, reason: 'after: ${steps.join(', ')}');
      }
    });
  }
}

const _kMessage = 'Message copied';

const double _kBarHeight = 56;

const double _kMargin = 12;

Future<void> _pumpApp(
  WidgetTester tester, {
  required Widget home,
  GlobalKey<NavigatorState>? navigatorKey,
  StreamSnackbarMessenger? messenger,
}) {
  final streamTheme = StreamTheme(
    snackbarTheme: const StreamSnackbarThemeData(
      style: StreamSnackbarStyle(margin: EdgeInsets.all(_kMargin)),
    ),
  );

  return tester.pumpWidget(
    MaterialApp(
      navigatorKey: navigatorKey,
      theme: ThemeData(extensions: [streamTheme]),
      builder: (context, child) => switch (messenger) {
        final messenger? => StreamSnackbarScope.withState(messenger: messenger, child: child!),
        null => StreamSnackbarScope(child: child!),
      },
      home: home,
    ),
  );
}

Future<void> _push(WidgetTester tester, GlobalKey<NavigatorState> navigatorKey, Widget page) async {
  navigatorKey.currentState!.push(MaterialPageRoute<void>(builder: (_) => page)).ignore();
  await tester.pumpAndSettle();
}

// Pushes a StreamScaffold onto [navigatorKey] and pops it again, returning
// the number of painted snackbar copies in each frame.
Future<List<int>> _paintedThroughPushAndPop(WidgetTester tester, GlobalKey<NavigatorState> navigatorKey) async {
  final painted = <int>[];
  Future<void> recordFrames() async {
    for (var frame = 0; frame < 30; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      painted.add(_paintedCopies(tester));
    }
  }

  navigatorKey.currentState!
      .push(
        MaterialPageRoute<void>(
          builder: (_) => const StreamScaffold(
            body: SizedBox.expand(),
            bottom: SizedBox(height: _kBarHeight),
          ),
        ),
      )
      .ignore();
  await recordFrames();
  navigatorKey.currentState!.pop();
  await recordFrames();
  return painted;
}

// A tab that keeps its own navigator, starting on [page]. Its pages fly
// heroes, as go_router's nested navigators do.
class _TabNavigator extends StatefulWidget {
  const _TabNavigator({this.navigatorKey, required this.page});

  final GlobalKey<NavigatorState>? navigatorKey;
  final Widget page;

  @override
  State<_TabNavigator> createState() => _TabNavigatorState();
}

class _TabNavigatorState extends State<_TabNavigator> {
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
        onGenerateRoute: (_) => MaterialPageRoute<void>(builder: (_) => widget.page),
      ),
    );
  }
}

bool _isSnackbarHero(Widget widget) => widget is Hero && widget.tag is ObjectKey;

// A pane with its own navigator, starting on a StreamScaffold.
class _Pane extends StatelessWidget {
  const _Pane({this.navigatorKey, this.scaffoldKey});

  final GlobalKey<NavigatorState>? navigatorKey;
  final Key? scaffoldKey;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (_) => MaterialPageRoute<void>(
        builder: (_) => StreamScaffold(key: scaffoldKey, body: const SizedBox.expand()),
      ),
    );
  }
}

int _paintedCopiesIn(WidgetTester tester, GlobalKey key) {
  final copies = find.descendant(of: find.byKey(key), matching: find.text(_kMessage));
  return copies.evaluate().where((element) => _isPainted(element.renderObject!)).length;
}

Future<void> _pumpFrames(WidgetTester tester, Duration duration) async {
  const frame = Duration(milliseconds: 16);
  for (var elapsed = Duration.zero; elapsed < duration; elapsed += frame) {
    await tester.pump(frame);
  }
}

// The number of copies of [text] the last frame painted: onstage, not inside a
// subtree a render object skips painting, and not waiting on a repaint the
// frame missed. A fade at zero opacity still counts as painted, so entry
// animations and page transitions don't hide a copy.
int _paintedCopies(WidgetTester tester, [String text = _kMessage]) {
  return find.text(text).evaluate().where((element) => _isPainted(element.renderObject!)).length;
}

bool _isPainted(RenderObject renderObject) {
  var child = renderObject;
  var parent = child.parent;
  while (parent != null) {
    if (parent.debugNeedsPaint) return false;
    final isFade = parent is RenderOpacity || parent is RenderAnimatedOpacity;
    if (!isFade && !parent.paintsChild(child)) return false;
    child = parent;
    parent = child.parent;
  }
  return true;
}
