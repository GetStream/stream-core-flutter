import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

void main() {
  testWidgets('StreamScaffold shows a scope snackbar above a docked bottom', (tester) async {
    final bottomKey = GlobalKey();
    final bodyKey = GlobalKey();

    await _pumpApp(
      tester,
      home: StreamScaffold(
        body: SizedBox.expand(key: bodyKey),
        bottom: SizedBox(key: bottomKey, height: _kBarHeight),
      ),
    );
    await _showSnackbar(tester, bodyKey);

    expect(_snackbarRect(tester).bottom, _rectOf(tester, bottomKey).top - _kMargin);
  });

  testWidgets('StreamScaffold shows a scope snackbar above a floating bottom', (tester) async {
    final bottomKey = GlobalKey();
    final bodyKey = GlobalKey();

    await _pumpApp(
      tester,
      home: StreamScaffold(
        bottomSurfaceStyle: StreamSurfaceStyle.floating,
        body: SizedBox.expand(key: bodyKey),
        bottom: SizedBox(key: bottomKey, height: _kBarHeight),
      ),
    );
    await _showSnackbar(tester, bodyKey);

    expect(_snackbarRect(tester).bottom, _rectOf(tester, bottomKey).top - _kMargin);
  });

  testWidgets('StreamScaffold without a bottom shows a scope snackbar above the bottom inset', (tester) async {
    final bodyKey = GlobalKey();
    _setViewPadding(tester, bottom: _kHomeIndicator);

    await _pumpApp(
      tester,
      home: StreamScaffold(body: SizedBox.expand(key: bodyKey)),
    );
    await _showSnackbar(tester, bodyKey);

    expect(_snackbarRect(tester).bottom, _screenHeight(tester) - _kHomeIndicator - _kMargin);
  });

  testWidgets('StreamScaffold shows a scope snackbar above the keyboard when it resizes for it', (tester) async {
    final bodyKey = GlobalKey();
    _setKeyboard(tester, height: _kKeyboard);

    await _pumpApp(
      tester,
      home: StreamScaffold(
        body: SizedBox.expand(key: bodyKey),
        bottom: const SizedBox(height: _kBarHeight),
      ),
    );
    await _showSnackbar(tester, bodyKey);

    expect(_snackbarRect(tester).bottom, _screenHeight(tester) - _kKeyboard - _kBarHeight - _kMargin);
  });

  testWidgets('StreamScaffold leaves a scope snackbar behind the keyboard when it does not resize for it', (
    tester,
  ) async {
    final bodyKey = GlobalKey();
    _setKeyboard(tester, height: _kKeyboard);

    await _pumpApp(
      tester,
      home: StreamScaffold(
        resizeToAvoidBottomInset: false,
        body: SizedBox.expand(key: bodyKey),
        bottom: const SizedBox(height: _kBarHeight),
      ),
    );
    await _showSnackbar(tester, bodyKey);

    expect(_snackbarRect(tester).bottom, _screenHeight(tester) - _kBarHeight - _kMargin);
  });

  testWidgets('StreamScaffold gives a scope snackbar no vertical padding', (tester) async {
    final bodyKey = GlobalKey();
    EdgeInsets? snackbarPadding;
    _setViewPadding(tester, top: _kStatusBar, bottom: _kHomeIndicator);

    await _pumpApp(
      tester,
      home: _floatingScaffold(body: SizedBox.expand(key: bodyKey)),
    );
    StreamSnackbarMessenger.of(bodyKey.currentContext!).show(
      StreamSnackbar(
        message: Builder(
          builder: (context) {
            snackbarPadding = MediaQuery.paddingOf(context);
            return const Text(_kMessage);
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect((snackbarPadding!.top, snackbarPadding!.bottom), (0.0, 0.0));
  });

  testWidgets('StreamScaffold reports a scope snackbar its bottom leaves no room for', (tester) async {
    final bodyKey = GlobalKey();

    // A floating bottom overlaps the body instead of shrinking it, so an
    // oversized one leaves the body full height but no room above the bottom.
    await _pumpApp(
      tester,
      home: StreamScaffold(
        bottomSurfaceStyle: StreamSurfaceStyle.floating,
        body: SizedBox.expand(key: bodyKey),
        bottom: SizedBox(height: _screenHeight(tester) - _kMargin),
      ),
    );
    StreamSnackbarMessenger.of(bodyKey.currentContext!).show(StreamSnackbar(message: const Text(_kMessage)));
    await tester.pump();

    final exception = tester.takeException();
    expect(
      exception,
      isA<FlutterError>().having(
        (error) => error.message,
        'message',
        startsWith('StreamSnackbar presented off screen.'),
      ),
    );
  });
}

const _kMessage = 'Message copied';
const double _kBarHeight = 56;
const double _kMargin = 12;
const double _kHomeIndicator = 34;
const double _kStatusBar = 24;
const double _kKeyboard = 300;

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

StreamScaffold _floatingScaffold({required Widget body}) {
  return StreamScaffold(
    appBarSurfaceStyle: StreamSurfaceStyle.floating,
    bottomSurfaceStyle: StreamSurfaceStyle.floating,
    appBar: const PreferredSize(preferredSize: Size.fromHeight(_kBarHeight), child: SizedBox.expand()),
    bottom: const SizedBox(height: _kBarHeight),
    body: body,
  );
}

Future<void> _showSnackbar(WidgetTester tester, GlobalKey key) async {
  StreamSnackbarMessenger.of(key.currentContext!).show(StreamSnackbar(message: const Text(_kMessage)));
  await tester.pumpAndSettle();
}

void _setViewPadding(WidgetTester tester, {double top = 0, double bottom = 0}) {
  final ratio = tester.view.devicePixelRatio;
  tester.view.padding = FakeViewPadding(top: top * ratio, bottom: bottom * ratio);
  tester.view.viewPadding = FakeViewPadding(top: top * ratio, bottom: bottom * ratio);
  addTearDown(tester.view.reset);
}

void _setKeyboard(WidgetTester tester, {required double height}) {
  tester.view.viewInsets = FakeViewPadding(bottom: height * tester.view.devicePixelRatio);
  addTearDown(tester.view.reset);
}

double _screenHeight(WidgetTester tester) => tester.view.physicalSize.height / tester.view.devicePixelRatio;

Rect _snackbarRect(WidgetTester tester) {
  final painted = find.byType(StreamSnackbar).evaluate().where((element) => _isPainted(element.renderObject!));
  return tester.getRect(find.byElementPredicate(painted.contains));
}

Rect _rectOf(WidgetTester tester, GlobalKey key) => tester.getRect(find.byKey(key));

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
