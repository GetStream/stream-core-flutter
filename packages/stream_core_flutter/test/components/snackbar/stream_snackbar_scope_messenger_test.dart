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
}

const _kMessage = 'Message copied';
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
