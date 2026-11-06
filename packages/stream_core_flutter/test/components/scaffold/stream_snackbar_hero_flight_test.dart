import 'dart:async';

import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

void main() {
  testWidgets('a scope snackbar moves to the StreamScaffold pushed over its page, and back on pop', (tester) async {
    final semantics = tester.ensureSemantics();
    final firstBottomKey = GlobalKey();
    final secondBottomKey = GlobalKey();
    final firstBodyKey = GlobalKey();
    final navigatorKey = GlobalKey<NavigatorState>();

    await _pumpApp(
      tester,
      navigatorKey: navigatorKey,
      home: StreamScaffold(
        body: SizedBox.expand(key: firstBodyKey),
        bottom: SizedBox(key: firstBottomKey, height: _kBarHeight),
      ),
    );
    StreamSnackbarMessenger.of(firstBodyKey.currentContext!).show(
      StreamSnackbar(message: const Text(_kMessage), duration: const Duration(minutes: 1)),
    );
    await tester.pumpAndSettle();

    await _push(
      tester,
      navigatorKey,
      StreamScaffold(
        body: const SizedBox.expand(),
        bottom: SizedBox(key: secondBottomKey, height: _kBarHeight * 2),
      ),
    );

    expect(_paintedCopies(tester), 1);
    expect(find.bySemanticsLabel(_kMessage), findsOneWidget);
    expect(_snackbarRect(tester).bottom, _rectOf(tester, secondBottomKey).top - _kMargin);

    navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();

    expect(_paintedCopies(tester), 1);
    expect(_snackbarRect(tester).bottom, _rectOf(tester, firstBottomKey).top - _kMargin);
    semantics.dispose();
  });

  testWidgets('a scope snackbar flies as one copy while a StreamScaffold is pushed over its page', (tester) async {
    final bodyKey = GlobalKey();
    final navigatorKey = GlobalKey<NavigatorState>();

    await _pumpApp(
      tester,
      navigatorKey: navigatorKey,
      home: StreamScaffold(body: SizedBox.expand(key: bodyKey)),
    );
    StreamSnackbarMessenger.of(bodyKey.currentContext!).show(
      StreamSnackbar(message: const Text(_kMessage), duration: const Duration(minutes: 1)),
    );
    await tester.pumpAndSettle();

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
    final paintedPerFrame = <int>[];
    for (var frame = 0; frame < 30; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      paintedPerFrame.add(_paintedCopies(tester));
    }

    expect(paintedPerFrame, everyElement(1));
  });

  testWidgets('a scope snackbar flies as one copy during a back swipe between StreamScaffolds', (tester) async {
    final bodyKey = GlobalKey();
    final navigatorKey = GlobalKey<NavigatorState>();

    await _pumpApp(
      tester,
      navigatorKey: navigatorKey,
      home: StreamScaffold(body: SizedBox.expand(key: bodyKey)),
    );
    navigatorKey.currentState!
        .push(
          CupertinoPageRoute<void>(
            builder: (_) => const StreamScaffold(
              body: SizedBox.expand(),
              bottom: SizedBox(height: _kBarHeight),
            ),
          ),
        )
        .ignore();
    await tester.pumpAndSettle();
    StreamSnackbarMessenger.of(navigatorKey.currentContext!).show(
      StreamSnackbar(message: const Text(_kMessage), duration: const Duration(minutes: 1)),
    );
    await tester.pumpAndSettle();

    final paintedPerFrame = <int>[];
    final gesture = await tester.startGesture(const Offset(5, 200));
    for (var step = 0; step < 10; step++) {
      await gesture.moveBy(const Offset(30, 0));
      await tester.pump(const Duration(milliseconds: 16));
      paintedPerFrame.add(_paintedCopies(tester));
    }
    await gesture.up();
    for (var frame = 0; frame < 30; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      paintedPerFrame.add(_paintedCopies(tester));
    }

    expect(paintedPerFrame, everyElement(1));
  });

  testWidgets('the remaining StreamScaffold carries the snackbar hero once its side-by-side neighbor leaves', (
    tester,
  ) async {
    final rightKey = GlobalKey();
    final navigatorKey = GlobalKey<NavigatorState>();
    final showLeft = ValueNotifier(true);
    addTearDown(showLeft.dispose);
    // The same instance on every build, so the right pane itself never
    // rebuilds when the left one leaves.
    final rightPane = Expanded(
      key: const ValueKey('right'),
      child: StreamScaffold(key: rightKey, body: const SizedBox.expand()),
    );

    await _pumpApp(
      tester,
      navigatorKey: navigatorKey,
      home: ValueListenableBuilder(
        valueListenable: showLeft,
        builder: (context, showLeft, _) => Row(
          children: [
            if (showLeft)
              const Expanded(
                key: ValueKey('left'),
                child: StreamScaffold(body: SizedBox.expand()),
              ),
            rightPane,
          ],
        ),
      ),
    );
    StreamSnackbarMessenger.of(rightKey.currentContext!).show(
      StreamSnackbar(message: const Text(_kMessage), duration: const Duration(minutes: 1)),
    );
    await tester.pumpAndSettle();

    showLeft.value = false;
    await tester.pumpAndSettle();

    expect(_snackbarHeroes(rightKey), findsOneWidget);
  });

  testWidgets('a StreamScaffold around tabs with their own navigators shows and flies the only copy', (tester) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    final shellKey = GlobalKey();

    await _pumpApp(
      tester,
      navigatorKey: navigatorKey,
      home: StreamScaffold(
        key: shellKey,
        body: const IndexedStack(
          children: [
            _TabNavigator(page: StreamScaffold(body: SizedBox.expand())),
            _TabNavigator(page: StreamScaffold(body: SizedBox.expand())),
          ],
        ),
        bottom: const SizedBox(height: _kBarHeight),
      ),
    );
    StreamSnackbarMessenger.of(shellKey.currentContext!).show(
      StreamSnackbar(message: const Text(_kMessage), duration: const Duration(minutes: 1)),
    );
    await tester.pumpAndSettle();

    expect(_snackbarHeroes(shellKey), findsOneWidget);
    expect(find.byType(Hero), findsOneWidget);

    final painted = await _paintedThroughPushAndPop(tester, navigatorKey);

    expect(tester.takeException(), isNull);
    expect(painted, everyElement(1));
  });

  testWidgets('a page pushed inside a nested navigator flies the snackbar', (tester) async {
    final tabNavigatorKey = GlobalKey<NavigatorState>();

    await _pumpApp(
      tester,
      home: Scaffold(
        body: _TabNavigator(
          navigatorKey: tabNavigatorKey,
          page: const StreamScaffold(body: SizedBox.expand()),
        ),
      ),
    );
    StreamSnackbarMessenger.of(tabNavigatorKey.currentContext!).show(
      StreamSnackbar(message: const Text(_kMessage), duration: const Duration(minutes: 1)),
    );
    await tester.pumpAndSettle();

    final painted = await _paintedThroughPushAndPop(tester, tabNavigatorKey);

    expect(tester.takeException(), isNull);
    expect(painted, everyElement(1));
  });

  testWidgets('a page in a nested navigator flies the snackbar through a root push and pop', (tester) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    final tabNavigatorKey = GlobalKey<NavigatorState>();

    await _pumpApp(
      tester,
      navigatorKey: navigatorKey,
      home: Scaffold(
        body: _TabNavigator(
          navigatorKey: tabNavigatorKey,
          page: const StreamScaffold(body: SizedBox.expand()),
        ),
      ),
    );
    StreamSnackbarMessenger.of(tabNavigatorKey.currentContext!).show(
      StreamSnackbar(message: const Text(_kMessage), duration: const Duration(minutes: 1)),
    );
    await tester.pumpAndSettle();

    final painted = await _paintedThroughPushAndPop(tester, navigatorKey);

    expect(tester.takeException(), isNull);
    expect(painted, everyElement(1));
  });

  testWidgets('a back swipe inside a nested navigator flies the snackbar', (tester) async {
    final tabNavigatorKey = GlobalKey<NavigatorState>();

    await _pumpApp(
      tester,
      home: Scaffold(
        body: _TabNavigator(
          navigatorKey: tabNavigatorKey,
          page: const StreamScaffold(body: SizedBox.expand()),
        ),
      ),
    );
    tabNavigatorKey.currentState!
        .push(CupertinoPageRoute<void>(builder: (_) => const StreamScaffold(body: SizedBox.expand())))
        .ignore();
    await tester.pumpAndSettle();
    StreamSnackbarMessenger.of(tabNavigatorKey.currentContext!).show(
      StreamSnackbar(message: const Text(_kMessage), duration: const Duration(minutes: 1)),
    );
    await tester.pumpAndSettle();

    final paintedPerFrame = <int>[];
    final gesture = await tester.startGesture(const Offset(5, 200));
    for (var step = 0; step < 10; step++) {
      await gesture.moveBy(const Offset(30, 0));
      await tester.pump(const Duration(milliseconds: 16));
      paintedPerFrame.add(_paintedCopies(tester));
    }
    await gesture.up();
    for (var frame = 0; frame < 30; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      paintedPerFrame.add(_paintedCopies(tester));
    }

    expect(tester.takeException(), isNull);
    expect(paintedPerFrame, everyElement(1));
  });
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

// The snackbar heroes inside the widget with [key].
Finder _snackbarHeroes(GlobalKey key) {
  return find.descendant(
    of: find.byKey(key),
    matching: find.byWidgetPredicate(_isSnackbarHero),
  );
}

Rect _snackbarRect(WidgetTester tester, [String text = _kMessage]) {
  final snackbars = find.ancestor(of: find.text(text), matching: find.byType(StreamSnackbar));
  final painted = snackbars.evaluate().where((element) => _isPainted(element.renderObject!));
  return tester.getRect(find.byElementPredicate(painted.contains));
}

Rect _rectOf(WidgetTester tester, GlobalKey key) => tester.getRect(find.byKey(key));

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
