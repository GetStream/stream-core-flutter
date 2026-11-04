import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

void main() {
  testWidgets('StreamScaffold nested in another StreamScaffold leaves the snackbar to the outer one', (tester) async {
    final outerBottomKey = GlobalKey();
    final bodyKey = GlobalKey();

    await _pumpApp(
      tester,
      home: StreamScaffold(
        body: StreamScaffold(body: SizedBox.expand(key: bodyKey)),
        bottom: SizedBox(key: outerBottomKey, height: _kBarHeight),
      ),
    );
    await _showSnackbar(tester, bodyKey);

    expect(_paintedCopies(tester), 1);
    expect(_snackbarRect(tester).bottom, _rectOf(tester, outerBottomKey).top - _kMargin);
  });

  testWidgets('a snackbar shown just after its page pops shows on the page below', (tester) async {
    final firstBottomKey = GlobalKey();
    final secondBodyKey = GlobalKey();
    final navigatorKey = GlobalKey<NavigatorState>();

    await _pumpApp(
      tester,
      navigatorKey: navigatorKey,
      home: StreamScaffold(
        body: const SizedBox.expand(),
        bottom: SizedBox(key: firstBottomKey, height: _kBarHeight),
      ),
    );
    await _push(tester, navigatorKey, StreamScaffold(body: SizedBox.expand(key: secondBodyKey)));

    final messenger = StreamSnackbarMessenger.of(secondBodyKey.currentContext!);
    navigatorKey.currentState!.pop();
    messenger.show(StreamSnackbar(message: const Text(_kMessage)));
    await tester.pumpAndSettle();

    expect(_paintedCopies(tester), 1);
    expect(_snackbarRect(tester).bottom, _rectOf(tester, firstBottomKey).top - _kMargin);
  });

  testWidgets('a snackbar from a page without a StreamScaffold stays hidden under that opaque page', (
    tester,
  ) async {
    final plainBodyKey = GlobalKey();
    final navigatorKey = GlobalKey<NavigatorState>();

    await _pumpApp(
      tester,
      navigatorKey: navigatorKey,
      home: const StreamScaffold(body: SizedBox.expand()),
    );
    await _push(tester, navigatorKey, Scaffold(body: SizedBox.expand(key: plainBodyKey)));
    await _showSnackbar(tester, plainBodyKey);

    expect(_paintedCopies(tester), 0);
  });

  testWidgets('a snackbar under a dialog without a StreamScaffold shows on the StreamScaffold beneath', (
    tester,
  ) async {
    final bottomKey = GlobalKey();
    final dialogKey = GlobalKey();
    final navigatorKey = GlobalKey<NavigatorState>();

    await _pumpApp(
      tester,
      navigatorKey: navigatorKey,
      home: StreamScaffold(
        body: const SizedBox.expand(),
        bottom: SizedBox(key: bottomKey, height: _kBarHeight),
      ),
    );
    await _showDialog(tester, navigatorKey, SizedBox(key: dialogKey, width: 100, height: 100));
    await _showSnackbar(tester, dialogKey);

    expect(_paintedCopies(tester), 1);
    expect(_snackbarRect(tester).bottom, _rectOf(tester, bottomKey).top - _kMargin);
  });

  testWidgets('a StreamScaffold inside a dialog shows the scope snackbar alongside the page beneath', (
    tester,
  ) async {
    final dialogBodyKey = GlobalKey();
    final navigatorKey = GlobalKey<NavigatorState>();

    await _pumpApp(
      tester,
      navigatorKey: navigatorKey,
      home: const StreamScaffold(body: SizedBox.expand()),
    );
    await _showDialog(
      tester,
      navigatorKey,
      SizedBox(
        width: 300,
        height: 300,
        child: StreamScaffold(body: SizedBox.expand(key: dialogBodyKey)),
      ),
    );
    await _showSnackbar(tester, dialogBodyKey);

    expect(_paintedCopies(tester), 2);
  });

  testWidgets('StreamSnackbarScope shows the snackbar once when a StreamScaffold mounts with one queued', (
    tester,
  ) async {
    final messenger = StreamSnackbarMessenger();
    addTearDown(messenger.dispose);
    messenger.show(StreamSnackbar(message: const Text(_kMessage)));
    // Skips the entry fade, so the first frame paints the snackbar outright.
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(
      accessibleNavigation: true,
    );
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    await _pumpApp(
      tester,
      messenger: messenger,
      home: const StreamScaffold(body: SizedBox.expand()),
    );

    expect(_paintedCopies(tester), 1);
  });

  testWidgets('StreamSnackbarScope paints a showing snackbar in the frame the last StreamScaffold leaves', (
    tester,
  ) async {
    final plainBodyKey = GlobalKey();
    final navigatorKey = GlobalKey<NavigatorState>();

    await _pumpApp(
      tester,
      navigatorKey: navigatorKey,
      home: Scaffold(body: SizedBox.expand(key: plainBodyKey)),
    );
    await _push(tester, navigatorKey, const StreamScaffold(body: SizedBox.expand()));
    await _showSnackbar(tester, plainBodyKey);

    // Once the leaving page's copy is gone, only the scope's copy is left; it
    // must be painted in every such frame, starting with the first.
    navigatorKey.currentState!.pop();
    final paintedAfterTheScaffoldLeft = <int>[];
    for (var frame = 0; frame < 60; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      final onlyTheScopeCopyIsLeft = find.text(_kMessage).evaluate().length == 1;
      if (onlyTheScopeCopyIsLeft) paintedAfterTheScaffoldLeft.add(_paintedCopies(tester));
    }

    expect(paintedAfterTheScaffoldLeft, allOf(isNotEmpty, everyElement(1)));
  });

  testWidgets('StreamSnackbarScope shows snackbars itself again after the last StreamScaffold pops', (tester) async {
    final plainBodyKey = GlobalKey();
    final navigatorKey = GlobalKey<NavigatorState>();

    await _pumpApp(
      tester,
      navigatorKey: navigatorKey,
      home: Scaffold(body: SizedBox.expand(key: plainBodyKey)),
    );
    await _push(tester, navigatorKey, const StreamScaffold(body: SizedBox.expand()));
    navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();

    await _showSnackbar(tester, plainBodyKey);

    expect(_paintedCopies(tester), 1);
  });

  testWidgets('a scope snackbar shown in a StreamScaffold reaches semantics once', (tester) async {
    final semantics = tester.ensureSemantics();
    final bodyKey = GlobalKey();

    await _pumpApp(
      tester,
      home: StreamScaffold(body: SizedBox.expand(key: bodyKey)),
    );
    await _showSnackbar(tester, bodyKey);

    expect(find.bySemanticsLabel(_kMessage), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('a scope snackbar reaches semantics once after the last StreamScaffold pops', (tester) async {
    final semantics = tester.ensureSemantics();
    final plainBodyKey = GlobalKey();
    final navigatorKey = GlobalKey<NavigatorState>();

    await _pumpApp(
      tester,
      navigatorKey: navigatorKey,
      home: Scaffold(body: SizedBox.expand(key: plainBodyKey)),
    );
    await _push(tester, navigatorKey, const StreamScaffold(body: SizedBox.expand()));
    navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();
    await _showSnackbar(tester, plainBodyKey);

    expect(find.bySemanticsLabel(_kMessage), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('StreamSnackbarScope stops tickers in its own copy while a StreamScaffold shows the snackbar', (
    tester,
  ) async {
    final bodyKey = GlobalKey();

    await _pumpApp(
      tester,
      home: StreamScaffold(body: SizedBox.expand(key: bodyKey)),
    );
    await _showSnackbar(tester, bodyKey);

    expect(TickerMode.valuesOf(_hiddenCopy(tester)).enabled, isFalse);
  });

  testWidgets('StreamSnackbarScope keeps focus out of its own copy while a StreamScaffold shows the snackbar', (
    tester,
  ) async {
    final messenger = StreamSnackbarMessenger();
    addTearDown(messenger.dispose);

    await _pumpApp(
      tester,
      messenger: messenger,
      home: const StreamScaffold(body: SizedBox.expand()),
    );
    messenger.show(
      StreamSnackbar(
        message: const Text(_kMessage),
        action: StreamSnackbarAction(label: const Text('Undo'), onPressed: () {}),
      ),
    );
    await tester.pumpAndSettle();
    final hiddenAction = find.descendant(
      of: find.byElementPredicate((element) => element == _hiddenCopy(tester)),
      matching: find.text('Undo'),
    );
    final focusNode = Focus.of(tester.element(hiddenAction));

    focusNode.requestFocus();
    await tester.pump();

    expect(focusNode.hasFocus, isFalse);
  });

  testWidgets('the action of a scope snackbar in a StreamScaffold dismisses that snackbar', (tester) async {
    final scopeMessenger = StreamSnackbarMessenger();
    final popupMessenger = StreamSnackbarMessenger();
    addTearDown(scopeMessenger.dispose);
    addTearDown(popupMessenger.dispose);

    await _pumpApp(
      tester,
      messenger: scopeMessenger,
      home: StreamSnackbarPopup.withState(
        messenger: popupMessenger,
        child: const StreamScaffold(body: SizedBox.expand()),
      ),
    );
    scopeMessenger.show(
      StreamSnackbar(
        message: const Text(_kMessage),
        action: StreamSnackbarAction(label: const Text('Undo'), onPressed: () {}),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Undo').hitTestable());
    await tester.pumpAndSettle();

    expect(scopeMessenger.currentSnackbar, isNull);
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

Future<void> _showDialog(WidgetTester tester, GlobalKey<NavigatorState> navigatorKey, Widget content) async {
  showDialog<void>(
    context: navigatorKey.currentContext!,
    builder: (_) => Center(child: content),
  ).ignore();
  await tester.pumpAndSettle();
}

Future<void> _showSnackbar(WidgetTester tester, GlobalKey key) async {
  StreamSnackbarMessenger.of(key.currentContext!).show(StreamSnackbar(message: const Text(_kMessage)));
  await tester.pumpAndSettle();
}

Rect _snackbarRect(WidgetTester tester) {
  final painted = find.byType(StreamSnackbar).evaluate().where((element) => _isPainted(element.renderObject!));
  return tester.getRect(find.byElementPredicate(painted.contains));
}

Rect _rectOf(WidgetTester tester, GlobalKey key) => tester.getRect(find.byKey(key));

// The scope's own copy of the snackbar, which it keeps unpainted while a
// StreamScaffold shows the snackbar.
Element _hiddenCopy(WidgetTester tester) {
  return find.byType(StreamSnackbar).evaluate().singleWhere((element) => !_isPainted(element.renderObject!));
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
