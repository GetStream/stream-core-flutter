import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

Widget _withStreamTheme(Widget child, {StreamSurfaceStyle surfaceStyle = StreamSurfaceStyle.regular}) {
  return MaterialApp(
    theme: ThemeData(extensions: [StreamTheme(surfaceStyle: surfaceStyle)]),
    home: child,
  );
}

// ---------------------------------------------------------------------------
// Harness for the MediaQuery inset-injection tests
// ---------------------------------------------------------------------------

const double _kBarHeight = 56;

/// Captures the effective insets seen by the scaffold body during build.
class _CapturedInsets {
  EdgeInsets? padding;
  EdgeInsets? viewPadding;
  EdgeInsets? viewInsets;
}

class _InsetProbe extends StatelessWidget {
  const _InsetProbe(this.captured);

  final _CapturedInsets captured;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    captured
      ..padding = mediaQuery.padding
      ..viewPadding = mediaQuery.viewPadding
      ..viewInsets = mediaQuery.viewInsets;

    return const SizedBox.expand();
  }
}

/// A bare [PreferredSizeWidget] that does NOT self-inset the status bar — used
/// to exercise the top-inset formula without [StreamAppBar]'s internal padding.
PreferredSizeWidget _rawAppBar({double height = _kBarHeight, Key? childKey}) {
  return PreferredSize(
    preferredSize: Size.fromHeight(height),
    child: SizedBox(key: childKey, height: height, width: double.infinity),
  );
}

/// Pumps a [StreamScaffold] with configurable behaviors and simulated device
/// insets (notch / home-indicator / keyboard) injected above the scaffold.
Future<void> _pumpStreamScaffold(
  WidgetTester tester, {
  required Widget body,
  StreamSurfaceStyle? appBarSurfaceStyle,
  StreamSurfaceStyle? bottomSurfaceStyle,
  PreferredSizeWidget? appBar,
  Widget? bottom,
  bool resizeToAvoidBottomInset = true,
  EdgeInsets devicePadding = EdgeInsets.zero,
  EdgeInsets viewInsets = EdgeInsets.zero,
  StreamSurfaceStyle surfaceStyle = StreamSurfaceStyle.regular,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(extensions: [StreamTheme(surfaceStyle: surfaceStyle)]),
      home: Builder(
        builder: (context) {
          final base = MediaQuery.of(context);
          return MediaQuery(
            data: base.copyWith(
              padding: devicePadding,
              viewPadding: devicePadding,
              viewInsets: viewInsets,
            ),
            child: StreamScaffold(
              appBarSurfaceStyle: appBarSurfaceStyle,
              bottomSurfaceStyle: bottomSurfaceStyle,
              appBar: appBar,
              bottom: bottom,
              resizeToAvoidBottomInset: resizeToAvoidBottomInset,
              body: body,
            ),
          );
        },
      ),
    ),
  );
}

void main() {
  group('when neither slot is floating', () {
    testWidgets('forwards the full drawer configuration to the underlying Scaffold', (tester) async {
      const drawer = Drawer(key: ValueKey('drawer'));
      const endDrawer = Drawer(key: ValueKey('end-drawer'));
      const scrimColor = Color(0xFF123456);

      await tester.pumpWidget(
        _withStreamTheme(
          StreamScaffold(
            drawer: drawer,
            endDrawer: endDrawer,
            onDrawerChanged: (_) {},
            onEndDrawerChanged: (_) {},
            drawerScrimColor: scrimColor,
            drawerEdgeDragWidth: 42,
            drawerEnableOpenDragGesture: false,
            endDrawerEnableOpenDragGesture: false,
            drawerDragStartBehavior: DragStartBehavior.down,
            drawerBarrierDismissible: false,
            restorationId: 'scaffold-restoration',
            body: const SizedBox(),
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.drawer, same(drawer));
      expect(scaffold.endDrawer, same(endDrawer));
      // Callbacks are compared by presence: a mis-wire to null would fail here.
      expect(scaffold.onDrawerChanged, isNotNull);
      expect(scaffold.onEndDrawerChanged, isNotNull);
      expect(scaffold.drawerScrimColor, scrimColor);
      expect(scaffold.drawerEdgeDragWidth, 42);
      expect(scaffold.drawerEnableOpenDragGesture, isFalse);
      expect(scaffold.endDrawerEnableOpenDragGesture, isFalse);
      expect(scaffold.drawerDragStartBehavior, DragStartBehavior.down);
      expect(scaffold.drawerBarrierDismissible, isFalse);
      expect(scaffold.restorationId, 'scaffold-restoration');
    });

    testWidgets('places a regular bottom widget below the body instead of in bottomNavigationBar', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          const StreamScaffold(
            body: SizedBox(),
            bottom: Text('Bottom bar'),
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.bottomNavigationBar, isNull);
      expect(find.text('Bottom bar'), findsOneWidget);
    });
  });

  group('when the app bar is floating', () {
    testWidgets('extends the body behind the app bar', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          const StreamScaffold(
            appBarSurfaceStyle: StreamSurfaceStyle.floating,
            appBar: PreferredSize(preferredSize: Size.fromHeight(kToolbarHeight), child: SizedBox()),
            body: SizedBox(),
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.extendBodyBehindAppBar, isTrue);
    });
  });

  group('when the bottom widget is floating', () {
    testWidgets('keeps a floating bottom widget out of the bottomNavigationBar slot', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          const StreamScaffold(
            bottomSurfaceStyle: StreamSurfaceStyle.floating,
            bottom: SizedBox(height: 64),
            body: SizedBox(),
          ),
        ),
      );

      // The floating bottom overlaps the body from within it (see
      // _StreamScaffoldBody), never via the Scaffold's bottomNavigationBar slot.
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.bottomNavigationBar, isNull);
    });

    testWidgets('tracks the bottom bar height into MediaQuery.padding when it resizes', (tester) async {
      final captured = _CapturedInsets();
      Future<void> pumpWithHeight(double height) => _pumpStreamScaffold(
        tester,
        bottomSurfaceStyle: StreamSurfaceStyle.floating,
        bottom: SizedBox(height: height),
        body: _InsetProbe(captured),
      );

      await pumpWithHeight(64);
      expect(captured.padding!.bottom, 64);

      await pumpWithHeight(80);
      expect(captured.padding!.bottom, 80);
    });

    testWidgets('injects no bottom inset when floating is set but no bottom widget is provided', (tester) async {
      final captured = _CapturedInsets();
      await _pumpStreamScaffold(
        tester,
        bottomSurfaceStyle: StreamSurfaceStyle.floating,
        devicePadding: const EdgeInsets.only(bottom: 34),
        body: _InsetProbe(captured),
      );

      // With no bottom widget the floating layout is skipped, so the body keeps
      // the raw device inset — nothing is added.
      expect(captured.padding!.bottom, 34);
    });
  });

  group('surfaceStyle resolution', () {
    testWidgets('falls back to the component theme when no instance surfaceStyle is set', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          const StreamAppBarTheme(
            data: StreamAppBarThemeData(style: StreamAppBarStyle(surfaceStyle: StreamSurfaceStyle.floating)),
            child: StreamScaffold(
              appBar: PreferredSize(preferredSize: Size.fromHeight(kToolbarHeight), child: SizedBox()),
              body: SizedBox(),
            ),
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.extendBodyBehindAppBar, isTrue);
    });

    testWidgets('falls back to the ambient StreamSurfaceStyle when neither instance nor theme set a surfaceStyle', (
      tester,
    ) async {
      await tester.pumpWidget(
        _withStreamTheme(
          const StreamScaffold(
            appBar: PreferredSize(preferredSize: Size.fromHeight(kToolbarHeight), child: SizedBox()),
            body: SizedBox(),
          ),
          surfaceStyle: StreamSurfaceStyle.floating,
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.extendBodyBehindAppBar, isTrue);
    });
  });

  // P0 — correctness of the injection --------------------------------------

  group('inset injection · mode matrix', () {
    const device = EdgeInsets.only(top: 44, bottom: 34);
    const bottomBarHeight = 64.0;

    testWidgets('both regular → no floating inset added', (tester) async {
      final captured = _CapturedInsets();
      await _pumpStreamScaffold(
        tester,
        appBar: _rawAppBar(),
        bottom: const SizedBox(height: bottomBarHeight),
        devicePadding: device,
        body: _InsetProbe(captured),
      );

      // A regular app bar consumes the system top; nothing enlarges it, and the
      // docked bottom owns the home-indicator inset (stripped from the body).
      expect(captured.padding!.top, 0);
      expect(captured.padding!.bottom, 0);
    });

    testWidgets('floating app bar → padding.top = measured app-bar height', (tester) async {
      final captured = _CapturedInsets();
      await _pumpStreamScaffold(
        tester,
        appBarSurfaceStyle: StreamSurfaceStyle.floating,
        appBar: _rawAppBar(),
        devicePadding: device,
        body: _InsetProbe(captured),
      );

      expect(captured.padding!.top, _kBarHeight); // max(44 system, 56 measured bar)
      expect(captured.padding!.bottom, 34); // system inset preserved
    });

    testWidgets('floating bottom → padding.bottom = measured bar height', (tester) async {
      final captured = _CapturedInsets();
      await _pumpStreamScaffold(
        tester,
        bottomSurfaceStyle: StreamSurfaceStyle.floating,
        bottom: const SizedBox(height: bottomBarHeight),
        devicePadding: device,
        body: _InsetProbe(captured),
      );

      expect(captured.padding!.top, 44); // system inset preserved
      expect(captured.padding!.bottom, bottomBarHeight); // max(34, 64)
    });

    testWidgets('both floating → both insets injected', (tester) async {
      final captured = _CapturedInsets();
      await _pumpStreamScaffold(
        tester,
        appBarSurfaceStyle: StreamSurfaceStyle.floating,
        bottomSurfaceStyle: StreamSurfaceStyle.floating,
        appBar: _rawAppBar(),
        bottom: const SizedBox(height: bottomBarHeight),
        devicePadding: device,
        body: _InsetProbe(captured),
      );

      expect(captured.padding!.top, _kBarHeight);
      expect(captured.padding!.bottom, bottomBarHeight);
    });
  });

  group('inset injection · top is the measured app-bar height', () {
    const device = EdgeInsets.only(top: 44);
    const firstItemKey = ValueKey('first');

    testWidgets('padding.top follows the app-bar height, not a fixed formula', (tester) async {
      final captured = _CapturedInsets();
      await _pumpStreamScaffold(
        tester,
        appBarSurfaceStyle: StreamSurfaceStyle.floating,
        appBar: _rawAppBar(height: 80),
        devicePadding: device,
        body: _InsetProbe(captured),
      );

      expect(captured.padding!.top, 80); // measured 80px bar, not 80 + system top
    });

    testWidgets('a non-self-insetting bar insets content to its exact bottom edge (no gap)', (tester) async {
      const barKey = ValueKey('bar');
      await _pumpStreamScaffold(
        tester,
        appBarSurfaceStyle: StreamSurfaceStyle.floating,
        appBar: _rawAppBar(childKey: barKey),
        devicePadding: device,
        body: ListView(
          children: const [
            SizedBox(key: firstItemKey, height: 40),
            SizedBox(height: 1000),
          ],
        ),
      );

      final barBottom = tester.getRect(find.byKey(barKey)).bottom;
      final firstItemTop = tester.getRect(find.byKey(firstItemKey)).top;
      expect(barBottom, _kBarHeight); // raw bar renders at 0..56, no self-inset
      // Measured top → the first item sits exactly at the bar's bottom, no gap.
      expect(firstItemTop, barBottom);
    });

    testWidgets('StreamAppBar(primary: true) self-insets, so the body aligns with its bottom edge', (tester) async {
      const firstItemKey = ValueKey('first');
      await _pumpStreamScaffold(
        tester,
        appBarSurfaceStyle: StreamSurfaceStyle.floating,
        appBar: StreamAppBar(
          automaticallyImplyLeading: false,
          style: const StreamAppBarStyle(surfaceStyle: StreamSurfaceStyle.floating),
          title: const Text('Title'),
        ),
        devicePadding: device,
        body: ListView(
          children: const [
            SizedBox(key: firstItemKey, height: 40),
            SizedBox(height: 1000),
          ],
        ),
      );

      final barBottom = tester.getRect(find.byType(StreamAppBar)).bottom;
      final firstItemTop = tester.getRect(find.byKey(firstItemKey)).top;
      expect(firstItemTop, kStreamToolbarHeight + 44);
      expect(firstItemTop, moreOrLessEquals(barBottom, epsilon: 0.5)); // aligned, no gap
    });
  });

  // P1 — double-inset & regression risks ------------------------------------

  group('auto-inset behaviour for scrollables', () {
    const device = EdgeInsets.only(top: 44);
    const firstItemKey = ValueKey('first');

    Widget listBody({EdgeInsets? padding}) => ListView(
      padding: padding,
      children: const [
        SizedBox(key: firstItemKey, height: 40),
        SizedBox(height: 1000),
      ],
    );

    testWidgets('null-padding ListView auto-insets while its viewport still spans full height', (tester) async {
      await _pumpStreamScaffold(
        tester,
        appBarSurfaceStyle: StreamSurfaceStyle.floating,
        appBar: _rawAppBar(),
        devicePadding: device,
        body: listBody(),
      );

      final listTop = tester.getRect(find.byType(ListView)).top;
      final firstItemTop = tester.getRect(find.byKey(firstItemKey)).top;
      expect(listTop, 0); // viewport fills → content scrolls behind the bar
      expect(firstItemTop, _kBarHeight); // first item rests clear
    });

    testWidgets('explicit padding opts out of auto-inset', (tester) async {
      await _pumpStreamScaffold(
        tester,
        appBarSurfaceStyle: StreamSurfaceStyle.floating,
        appBar: _rawAppBar(),
        devicePadding: device,
        body: listBody(padding: EdgeInsets.zero),
      );

      final firstItemTop = tester.getRect(find.byKey(firstItemKey)).top;
      expect(firstItemTop, 0); // injection ignored — developer opted out
    });

    testWidgets('SafeArea shrinks the viewport instead of scrolling behind, and does not double-inset', (
      tester,
    ) async {
      await _pumpStreamScaffold(
        tester,
        appBarSurfaceStyle: StreamSurfaceStyle.floating,
        appBar: _rawAppBar(),
        devicePadding: device,
        body: SafeArea(child: listBody()),
      );

      final listTop = tester.getRect(find.byType(ListView)).top;
      final firstItemTop = tester.getRect(find.byKey(firstItemKey)).top;
      expect(listTop, _kBarHeight); // viewport pushed down (shrunk)
      expect(firstItemTop, _kBarHeight); // inset once, not doubled
    });
  });

  group('keyboard interaction (floating bottom)', () {
    const bottomBarHeight = 64.0;
    const keyboard = 300.0;

    testWidgets('padding.bottom carries the bar height, not the keyboard', (tester) async {
      final captured = _CapturedInsets();
      await _pumpStreamScaffold(
        tester,
        bottomSurfaceStyle: StreamSurfaceStyle.floating,
        bottom: const SizedBox(height: bottomBarHeight),
        devicePadding: const EdgeInsets.only(bottom: 34),
        viewInsets: const EdgeInsets.only(bottom: keyboard),
        body: _InsetProbe(captured),
      );

      expect(captured.padding!.bottom, bottomBarHeight); // 64, not 364 — keyboard not folded into padding
    });

    testWidgets('floating bottom bar rides above the keyboard when resizeToAvoidBottomInset is true', (tester) async {
      const barKey = ValueKey('bar');
      await _pumpStreamScaffold(
        tester,
        bottomSurfaceStyle: StreamSurfaceStyle.floating,
        bottom: const SizedBox(key: barKey, height: bottomBarHeight),
        viewInsets: const EdgeInsets.only(bottom: keyboard),
        body: const SizedBox.expand(),
      );

      final surfaceHeight = tester.view.physicalSize.height / tester.view.devicePixelRatio;
      final barBottom = tester.getRect(find.byKey(barKey)).bottom;
      expect(barBottom, moreOrLessEquals(surfaceHeight - keyboard, epsilon: 0.5));
    });

    testWidgets('floating bottom bar stays at the surface bottom when resizeToAvoidBottomInset is false', (
      tester,
    ) async {
      const barKey = ValueKey('bar');
      await _pumpStreamScaffold(
        tester,
        bottomSurfaceStyle: StreamSurfaceStyle.floating,
        bottom: const SizedBox(key: barKey, height: bottomBarHeight),
        viewInsets: const EdgeInsets.only(bottom: keyboard),
        resizeToAvoidBottomInset: false,
        body: const SizedBox.expand(),
      );

      final surfaceHeight = tester.view.physicalSize.height / tester.view.devicePixelRatio;
      final barBottom = tester.getRect(find.byKey(barKey)).bottom;
      expect(barBottom, moreOrLessEquals(surfaceHeight, epsilon: 0.5));
    });
  });

  group('regular bottom with a floating app bar', () {
    testWidgets('a regular bottom rides above the keyboard rather than behind it', (tester) async {
      const barKey = ValueKey('bar');
      const keyboard = 300.0;

      await _pumpStreamScaffold(
        tester,
        appBarSurfaceStyle: StreamSurfaceStyle.floating,
        appBar: _rawAppBar(),
        bottomSurfaceStyle: StreamSurfaceStyle.regular,
        bottom: const SizedBox(key: barKey, height: 64),
        viewInsets: const EdgeInsets.only(bottom: keyboard),
        body: const SizedBox.expand(),
      );

      final surfaceHeight = tester.view.physicalSize.height / tester.view.devicePixelRatio;
      final barBottom = tester.getRect(find.byKey(barKey)).bottom;
      expect(barBottom, moreOrLessEquals(surfaceHeight - keyboard, epsilon: 0.5));
    });
  });

  testWidgets('a docked (regular) bottom strips the bottom system inset from the body', (tester) async {
    final captured = _CapturedInsets();
    await _pumpStreamScaffold(
      tester,
      bottom: const SizedBox(height: 64), // regular / docked
      devicePadding: const EdgeInsets.only(bottom: 34),
      body: _InsetProbe(captured),
    );

    // The docked bottom owns the home-indicator inset, so the body sees 0 — its
    // scrollables rest on the bottom widget, not 34px above it.
    expect(captured.padding!.bottom, 0);
  });

  testWidgets('extends the body regardless of whether the app bar floats', (tester) async {
    // Pinned rather than following the app bar: a body that changes shape when
    // the app bar switches between regular and floating throws mid-layout if it
    // hosts an overlay child.
    await tester.pumpWidget(
      _withStreamTheme(
        StreamScaffold(appBarSurfaceStyle: StreamSurfaceStyle.regular, appBar: _rawAppBar(), body: const SizedBox()),
      ),
    );
    expect(tester.widget<Scaffold>(find.byType(Scaffold)).extendBody, isTrue);

    await tester.pumpWidget(
      _withStreamTheme(
        StreamScaffold(appBarSurfaceStyle: StreamSurfaceStyle.floating, appBar: _rawAppBar(), body: const SizedBox()),
      ),
    );
    expect(tester.widget<Scaffold>(find.byType(Scaffold)).extendBody, isTrue);
  });

  testWidgets('applies the given background color', (tester) async {
    const backgroundColor = Color(0xFF123456);

    await tester.pumpWidget(
      _withStreamTheme(
        const StreamScaffold(backgroundColor: backgroundColor, body: SizedBox()),
      ),
    );

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, equals(backgroundColor));
  });
}
