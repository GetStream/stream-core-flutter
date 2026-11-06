import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

void main() {
  testWidgets('StreamSnackbarScope shows the new messenger snackbar after its messenger is swapped', (
    tester,
  ) async {
    final first = StreamSnackbarMessenger();
    final second = StreamSnackbarMessenger();
    addTearDown(first.dispose);
    addTearDown(second.dispose);
    const home = StreamScaffold(body: SizedBox.expand());

    await _pumpApp(tester, messenger: first, home: home);
    first.show(StreamSnackbar(message: const Text('First')));
    second.show(StreamSnackbar(message: const Text('Second')));
    await tester.pumpAndSettle();

    await _pumpApp(tester, messenger: second, home: home);
    await tester.pumpAndSettle();

    expect((_paintedCopies(tester, 'First'), _paintedCopies(tester, 'Second')), (0, 1));
    expect(first.currentSnackbar, isNotNull);
  });

  testWidgets('StreamSnackbarScope drops the old snackbar when swapped to an empty messenger', (tester) async {
    final first = StreamSnackbarMessenger();
    final second = StreamSnackbarMessenger();
    addTearDown(first.dispose);
    addTearDown(second.dispose);
    const home = StreamScaffold(body: SizedBox.expand());
    var pressed = 0;

    await _pumpApp(tester, messenger: first, home: home);
    first.show(
      StreamSnackbar(
        message: const Text(_kMessage),
        action: StreamSnackbarAction(label: const Text('Undo'), onPressed: () => pressed++),
      ),
    );
    await tester.pumpAndSettle();
    final undoCenter = tester.getCenter(find.text('Undo').hitTestable());

    await _pumpApp(tester, messenger: second, home: home);
    await tester.pumpAndSettle();
    await tester.tapAt(undoCenter);
    await tester.pump();

    expect(find.text('Undo').hitTestable(), findsNothing);
    expect(pressed, 0);
  });

  testWidgets('the action of a snackbar dismisses it on the messenger the scope was swapped to', (tester) async {
    final first = StreamSnackbarMessenger();
    final second = StreamSnackbarMessenger();
    addTearDown(first.dispose);
    addTearDown(second.dispose);
    const home = StreamScaffold(body: SizedBox.expand());

    StreamSnackbarClosedReason? closedReason;

    await _pumpApp(tester, messenger: first, home: home);
    await _pumpApp(tester, messenger: second, home: home);
    final controller = second.show(
      StreamSnackbar(
        message: const Text(_kMessage),
        action: StreamSnackbarAction(label: const Text('Undo'), onPressed: () {}),
      ),
    );
    unawaited(controller.closed.then((reason) => closedReason = reason));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Undo').hitTestable());
    await tester.pumpAndSettle();

    expect((closedReason, second.currentSnackbar), (StreamSnackbarClosedReason.action, null));
  });

  testWidgets('StreamSnackbarScope finishes a leaving snackbar when its messenger is swapped', (tester) async {
    final first = StreamSnackbarMessenger();
    final second = StreamSnackbarMessenger();
    addTearDown(first.dispose);
    addTearDown(second.dispose);
    const home = StreamScaffold(body: SizedBox.expand());
    StreamSnackbarClosedReason? closedReason;

    await _pumpApp(tester, messenger: first, home: home);
    final controller = first.show(StreamSnackbar(message: const Text(_kMessage)));
    unawaited(controller.closed.then((reason) => closedReason = reason));
    await tester.pumpAndSettle();
    controller.close();
    await tester.pump(const Duration(milliseconds: 100));

    await _pumpApp(tester, messenger: second, home: home);
    await tester.pumpAndSettle();

    expect((closedReason, first.currentSnackbar), (StreamSnackbarClosedReason.dismiss, null));
  });

  testWidgets('StreamSnackbarScope finishes a leaving snackbar when it is removed', (tester) async {
    final messenger = StreamSnackbarMessenger();
    addTearDown(messenger.dispose);
    StreamSnackbarClosedReason? closedReason;

    await _pumpApp(
      tester,
      messenger: messenger,
      home: const StreamScaffold(body: SizedBox.expand()),
    );
    final controller = messenger.show(StreamSnackbar(message: const Text(_kMessage)));
    unawaited(controller.closed.then((reason) => closedReason = reason));
    await tester.pumpAndSettle();
    controller.close();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();

    expect((closedReason, messenger.currentSnackbar), (StreamSnackbarClosedReason.dismiss, null));
  });

  testWidgets('StreamSnackbarScope shows a snackbar that replaces one animating out', (tester) async {
    final messenger = StreamSnackbarMessenger();
    addTearDown(messenger.dispose);

    await _pumpApp(
      tester,
      messenger: messenger,
      home: const StreamScaffold(body: SizedBox.expand()),
    );
    await _replaceWhileExiting(tester, messenger);

    expect(_paintedCopies(tester, 'Next'), 1);
    expect((messenger.currentSnackbar?.props.message as Text?)?.data, 'Next');
  });
}

const _kMessage = 'Message copied';
const double _kMargin = 12;

// Shared across pumps, so pumping again with another messenger rebuilds only
// the scope.
final _theme = ThemeData(
  extensions: [
    StreamTheme(
      snackbarTheme: const StreamSnackbarThemeData(
        style: StreamSnackbarStyle(margin: EdgeInsets.all(_kMargin)),
      ),
    ),
  ],
);

Future<void> _pumpApp(
  WidgetTester tester, {
  required Widget home,
  GlobalKey<NavigatorState>? navigatorKey,
  StreamSnackbarMessenger? messenger,
}) {
  return tester.pumpWidget(
    MaterialApp(
      navigatorKey: navigatorKey,
      theme: _theme,
      builder: (context, child) => switch (messenger) {
        final messenger? => StreamSnackbarScope.withState(messenger: messenger, child: child!),
        null => StreamSnackbarScope(child: child!),
      },
      home: home,
    ),
  );
}

// Shows a snackbar, starts hiding it, and replaces it while it animates out.
Future<void> _replaceWhileExiting(WidgetTester tester, StreamSnackbarMessenger messenger) async {
  messenger.show(StreamSnackbar(message: const Text(_kMessage)));
  await tester.pumpAndSettle();
  messenger.hideCurrent();
  await tester.pump(const Duration(milliseconds: 100));
  messenger.show(StreamSnackbar(message: const Text('Next')), replace: true);
  await tester.pumpAndSettle();
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
