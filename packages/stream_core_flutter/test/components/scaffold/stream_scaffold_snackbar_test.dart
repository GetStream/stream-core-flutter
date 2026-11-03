import 'package:flutter/material.dart';
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

    expect(_snackbarRect(tester).bottom, lessThanOrEqualTo(_rectOf(tester, bottomKey).top));
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

    expect(_snackbarRect(tester).bottom, lessThanOrEqualTo(_rectOf(tester, bottomKey).top));
  });

  testWidgets('StreamScaffold shows a scope snackbar above the bottom accessory', (tester) async {
    final accessoryKey = GlobalKey();
    final bodyKey = GlobalKey();

    await _pumpApp(
      tester,
      home: StreamScaffold(
        body: SizedBox.expand(key: bodyKey),
        bottom: const SizedBox(height: _kBarHeight),
        bottomAccessory: SizedBox(key: accessoryKey, height: _kAccessoryHeight),
      ),
    );
    await _showSnackbar(tester, bodyKey);

    expect(_snackbarRect(tester).bottom, lessThanOrEqualTo(_rectOf(tester, accessoryKey).top));
  });

  testWidgets('StreamScaffold floats the bottom accessory just above a docked bottom', (tester) async {
    final accessoryKey = GlobalKey();
    final bottomKey = GlobalKey();

    await _pumpApp(
      tester,
      home: StreamScaffold(
        body: const SizedBox.expand(),
        bottom: SizedBox(key: bottomKey, height: _kBarHeight),
        bottomAccessory: SizedBox(key: accessoryKey, height: _kAccessoryHeight),
      ),
    );

    expect(_rectOf(tester, accessoryKey).bottom, _rectOf(tester, bottomKey).top);
  });

  testWidgets('StreamScaffold adds the bottom accessory height to the body bottom padding', (tester) async {
    double? bodyBottomPadding;

    await _pumpApp(
      tester,
      home: StreamScaffold(
        body: Builder(
          builder: (context) {
            bodyBottomPadding = MediaQuery.paddingOf(context).bottom;
            return const SizedBox.expand();
          },
        ),
        bottom: const SizedBox(height: _kBarHeight),
        bottomAccessory: const SizedBox(height: _kAccessoryHeight),
      ),
    );

    expect(bodyBottomPadding, _kAccessoryHeight);
  });

  testWidgets('StreamScaffold moves a showing snackbar down when the bottom accessory is removed', (tester) async {
    final bottomKey = GlobalKey();
    final bodyKey = GlobalKey();
    final showAccessory = ValueNotifier(true);
    addTearDown(showAccessory.dispose);

    await _pumpApp(
      tester,
      home: ValueListenableBuilder(
        valueListenable: showAccessory,
        builder: (context, show, _) => StreamScaffold(
          body: SizedBox.expand(key: bodyKey),
          bottom: SizedBox(key: bottomKey, height: _kBarHeight),
          bottomAccessory: show ? const SizedBox(height: _kAccessoryHeight) : null,
        ),
      ),
    );
    await _showSnackbar(tester, bodyKey);
    final bottomWithAccessory = _snackbarRect(tester).bottom;

    showAccessory.value = false;
    await tester.pump();

    final bottomWithoutAccessory = _snackbarRect(tester).bottom;
    expect(bottomWithoutAccessory - bottomWithAccessory, _kAccessoryHeight);
  });

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

    expect(find.byType(StreamSnackbar), findsOneWidget);
    expect(_snackbarRect(tester).bottom, lessThanOrEqualTo(_rectOf(tester, outerBottomKey).top));
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
    navigatorKey.currentState!
        .push(
          MaterialPageRoute<void>(
            builder: (_) => StreamScaffold(body: SizedBox.expand(key: secondBodyKey)),
          ),
        )
        .ignore();
    await tester.pumpAndSettle();

    final messenger = StreamSnackbarMessenger.of(secondBodyKey.currentContext!);
    navigatorKey.currentState!.pop();
    messenger.show(StreamSnackbar(message: const Text(_kMessage)));
    await tester.pumpAndSettle();

    expect(find.text(_kMessage), findsOneWidget);
    expect(_snackbarRect(tester).bottom, lessThanOrEqualTo(_rectOf(tester, firstBottomKey).top));
  });

  testWidgets('a default StreamSnackbarPopup in the bottom slot shows its snackbars above the bottom', (
    tester,
  ) async {
    final bottomKey = GlobalKey();
    final anchorKey = GlobalKey();

    await _pumpApp(
      tester,
      home: StreamScaffold(
        body: const SizedBox.expand(),
        bottom: StreamSnackbarPopup(
          child: SizedBox(
            key: bottomKey,
            height: _kBarHeight,
            child: SizedBox(key: anchorKey),
          ),
        ),
        bottomAccessory: const SizedBox(height: _kAccessoryHeight),
      ),
    );
    await _showSnackbar(tester, anchorKey);

    expect(find.byType(StreamSnackbar), findsOneWidget);
    expect(_snackbarRect(tester).bottom, lessThan(_rectOf(tester, bottomKey).top - _kAccessoryHeight));
  });

  testWidgets('StreamSnackbarScope shows the snackbar once when a StreamScaffold mounts with one queued', (
    tester,
  ) async {
    final messenger = StreamSnackbarMessenger();
    addTearDown(messenger.dispose);
    messenger.show(StreamSnackbar(message: const Text(_kMessage)));

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: [StreamTheme()]),
        builder: (context, child) => StreamSnackbarScope.withState(messenger: messenger, child: child!),
        home: const StreamScaffold(body: SizedBox.expand()),
      ),
    );

    expect(find.text(_kMessage), findsOneWidget);
  });
}

const _kMessage = 'Message copied';
const double _kBarHeight = 56;
const double _kAccessoryHeight = 40;

Future<void> _pumpApp(
  WidgetTester tester, {
  required Widget home,
  GlobalKey<NavigatorState>? navigatorKey,
}) {
  return tester.pumpWidget(
    MaterialApp(
      navigatorKey: navigatorKey,
      theme: ThemeData(extensions: [StreamTheme()]),
      builder: (context, child) => StreamSnackbarScope(child: child!),
      home: home,
    ),
  );
}

Future<void> _showSnackbar(WidgetTester tester, GlobalKey key) async {
  StreamSnackbarMessenger.of(key.currentContext!).show(StreamSnackbar(message: const Text(_kMessage)));
  await tester.pumpAndSettle();
}

Rect _snackbarRect(WidgetTester tester) => tester.getRect(find.byType(StreamSnackbar));

Rect _rectOf(WidgetTester tester, GlobalKey key) => tester.getRect(find.byKey(key));
