import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

Widget _withStreamTheme(Widget child, {StreamAppStyle appStyle = StreamAppStyle.regular}) {
  return MaterialApp(
    theme: ThemeData(extensions: [StreamTheme(appStyle: appStyle)]),
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
  StreamAppBarBehavior? appBarBehavior,
  StreamBottomAppBarBehavior? bottomBarBehavior,
  PreferredSizeWidget? appBar,
  Widget? bottom,
  bool resizeToAvoidBottomInset = true,
  EdgeInsets devicePadding = EdgeInsets.zero,
  EdgeInsets viewInsets = EdgeInsets.zero,
  StreamAppStyle appStyle = StreamAppStyle.regular,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(extensions: [StreamTheme(appStyle: appStyle)]),
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
              appBarBehavior: appBarBehavior,
              bottomBarBehavior: bottomBarBehavior,
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
    testWidgets('forwards drawer/endDrawer to the underlying Scaffold', (tester) async {
      const drawer = Drawer(key: ValueKey('drawer'));
      const endDrawer = Drawer(key: ValueKey('end-drawer'));

      await tester.pumpWidget(
        _withStreamTheme(
          const StreamScaffold(
            drawer: drawer,
            endDrawer: endDrawer,
            body: SizedBox(),
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.drawer, same(drawer));
      expect(scaffold.endDrawer, same(endDrawer));
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
            appBarBehavior: StreamAppBarBehavior.floating,
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
    testWidgets('extends the body and drops the bottomNavigationBar slot', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          const StreamScaffold(
            bottomBarBehavior: StreamBottomAppBarBehavior.floating,
            bottom: SizedBox(height: 64),
            body: SizedBox(),
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.extendBody, isTrue);
      expect(scaffold.bottomNavigationBar, isNull);
    });

    testWidgets('tracks the bottom bar height into MediaQuery.padding when it resizes', (tester) async {
      final captured = _CapturedInsets();
      Future<void> pumpWithHeight(double height) => _pumpStreamScaffold(
        tester,
        bottomBarBehavior: StreamBottomAppBarBehavior.floating,
        bottom: SizedBox(height: height),
        body: _InsetProbe(captured),
      );

      await pumpWithHeight(64);
      expect(captured.padding!.bottom, 64);

      await pumpWithHeight(80);
      expect(captured.padding!.bottom, 80);
    });

    testWidgets('is not floating when no bottom widget is provided', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          const StreamScaffold(
            bottomBarBehavior: StreamBottomAppBarBehavior.floating,
            body: SizedBox(),
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.extendBody, isFalse);
    });
  });

  group('behavior resolution', () {
    testWidgets('falls back to the component theme when no instance behavior is set', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          const StreamAppBarTheme(
            data: StreamAppBarThemeData(style: StreamAppBarStyle(behavior: StreamAppBarBehavior.floating)),
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

    testWidgets('falls back to the ambient StreamAppStyle when neither instance nor theme set a behavior', (
      tester,
    ) async {
      await tester.pumpWidget(
        _withStreamTheme(
          const StreamScaffold(
            appBar: PreferredSize(preferredSize: Size.fromHeight(kToolbarHeight), child: SizedBox()),
            body: SizedBox(),
          ),
          appStyle: StreamAppStyle.floating,
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

      // A regular app bar consumes the system top; nothing enlarges it.
      expect(captured.padding!.top, lessThan(_kBarHeight));
    });

    testWidgets('floating app bar → padding.top = measured app-bar height', (tester) async {
      final captured = _CapturedInsets();
      await _pumpStreamScaffold(
        tester,
        appBarBehavior: StreamAppBarBehavior.floating,
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
        bottomBarBehavior: StreamBottomAppBarBehavior.floating,
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
        appBarBehavior: StreamAppBarBehavior.floating,
        bottomBarBehavior: StreamBottomAppBarBehavior.floating,
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
        appBarBehavior: StreamAppBarBehavior.floating,
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
        appBarBehavior: StreamAppBarBehavior.floating,
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
        appBarBehavior: StreamAppBarBehavior.floating,
        appBar: StreamAppBar(
          automaticallyImplyLeading: false,
          style: const StreamAppBarStyle(behavior: StreamAppBarBehavior.floating),
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
        appBarBehavior: StreamAppBarBehavior.floating,
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
        appBarBehavior: StreamAppBarBehavior.floating,
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
        appBarBehavior: StreamAppBarBehavior.floating,
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

  group('documented surprises', () {
    const device = EdgeInsets.only(top: 44);
    const headerKey = ValueKey('header');
    const firstItemKey = ValueKey('first');

    testWidgets('a non-top-level ListView still consumes the injected top padding (gap after header)', (
      tester,
    ) async {
      await _pumpStreamScaffold(
        tester,
        appBarBehavior: StreamAppBarBehavior.floating,
        appBar: _rawAppBar(),
        devicePadding: device,
        body: Column(
          children: [
            const SizedBox(key: headerKey, height: 40, width: double.infinity),
            Expanded(
              child: ListView(
                children: const [
                  SizedBox(key: firstItemKey, height: 40),
                  SizedBox(height: 1000),
                ],
              ),
            ),
          ],
        ),
      );

      final headerBottom = tester.getRect(find.byKey(headerKey)).bottom;
      final firstItemTop = tester.getRect(find.byKey(firstItemKey)).top;
      // The inner ListView adds the full injected top inset — max(system-top,
      // barHeight) — even though it is not the top-level scrollable, producing a
      // gap after the header.
      expect(firstItemTop - headerBottom, _kBarHeight);
    });

    testWidgets('reading MediaQuery.paddingOf AND leaving a BoxScrollView null-padding double-insets', (
      tester,
    ) async {
      await _pumpStreamScaffold(
        tester,
        appBarBehavior: StreamAppBarBehavior.floating,
        appBar: _rawAppBar(),
        devicePadding: device,
        body: Builder(
          builder: (context) {
            final topInset = MediaQuery.paddingOf(context).top;
            return ListView(
              children: [
                SizedBox(height: topInset), // manual read …
                const SizedBox(key: firstItemKey, height: 40),
              ],
            );
          },
        ),
      );

      // … while the null-padding ListView ALSO auto-consumes it → 2× inset.
      final firstItemTop = tester.getRect(find.byKey(firstItemKey)).top;
      expect(firstItemTop, _kBarHeight * 2);
    });

    // Mixed mode: floating app bar (top injected) + REGULAR bottom (docked, so
    // the body's bottom padding is stripped). This is what makes the channel
    // list's `bottomPadding > 0 ? … : null` resolve to null → the inner ListView
    // auto-consumes the top inset → gap after the header.
    Future<double> pumpMixedMode(WidgetTester tester, {required bool alwaysExplicit}) async {
      const searchKey = ValueKey('search');
      const firstKey = ValueKey('first');
      var capturedBottom = -1.0;
      await _pumpStreamScaffold(
        tester,
        appBarBehavior: StreamAppBarBehavior.floating,
        appBar: _rawAppBar(),
        bottomBarBehavior: StreamBottomAppBarBehavior.regular,
        bottom: const SizedBox(height: 80),
        devicePadding: const EdgeInsets.only(top: 44, bottom: 34),
        body: IndexedStack(
          children: [
            NestedScrollView(
              headerSliverBuilder: (ctx, _) {
                final topInset = MediaQuery.paddingOf(ctx).top;
                return [
                  SliverToBoxAdapter(child: SizedBox(height: topInset)),
                  const SliverToBoxAdapter(child: SizedBox(key: searchKey, height: 40)),
                ];
              },
              body: Builder(
                builder: (ctx) {
                  capturedBottom = MediaQuery.paddingOf(ctx).bottom;
                  final padding = alwaysExplicit
                      ? EdgeInsets.only(bottom: capturedBottom) // fix: always explicit
                      : (capturedBottom > 0 ? EdgeInsets.only(bottom: capturedBottom) : null); // current: null
                  return ListView(
                    padding: padding,
                    children: const [
                      SizedBox(key: firstKey, height: 40),
                      SizedBox(height: 2000),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      );
      expect(capturedBottom, 0); // regular bottom strips the body's bottom inset
      return tester.getRect(find.byKey(firstKey)).top - tester.getRect(find.byKey(searchKey)).bottom;
    }

    testWidgets('floating app bar + regular bottom: `… : null` padding re-consumes the top inset (gap)', (
      tester,
    ) async {
      // A regular bottom zeroes bottomPadding, so `bottomPadding > 0 ? … : null`
      // yields null → the non-top-level ListView auto-consumes the top inset.
      final gap = await pumpMixedMode(tester, alwaysExplicit: false);
      expect(gap, _kBarHeight);
    });

    testWidgets('… always-explicit padding (EdgeInsets.only(bottom: 0)) opts out → no gap', (tester) async {
      final gap = await pumpMixedMode(tester, alwaysExplicit: true);
      expect(gap, 0);
    });
  });

  group('keyboard interaction (floating bottom)', () {
    const bottomBarHeight = 64.0;
    const keyboard = 300.0;

    testWidgets('padding.bottom carries the bar height, not the keyboard', (tester) async {
      final captured = _CapturedInsets();
      await _pumpStreamScaffold(
        tester,
        bottomBarBehavior: StreamBottomAppBarBehavior.floating,
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
        bottomBarBehavior: StreamBottomAppBarBehavior.floating,
        bottom: const SizedBox(key: barKey, height: bottomBarHeight),
        viewInsets: const EdgeInsets.only(bottom: keyboard),
        body: const SizedBox.expand(),
      );

      final surfaceHeight = tester.view.physicalSize.height / tester.view.devicePixelRatio;
      final barBottom = tester.getRect(find.byKey(barKey)).bottom;
      expect(barBottom, lessThanOrEqualTo(surfaceHeight - keyboard + 0.5));
    });

    testWidgets('floating bottom bar stays at the surface bottom when resizeToAvoidBottomInset is false', (
      tester,
    ) async {
      const barKey = ValueKey('bar');
      await _pumpStreamScaffold(
        tester,
        bottomBarBehavior: StreamBottomAppBarBehavior.floating,
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
    testWidgets('keeps a regular bottom out of the bottomNavigationBar slot', (tester) async {
      await _pumpStreamScaffold(
        tester,
        appBarBehavior: StreamAppBarBehavior.floating,
        appBar: _rawAppBar(),
        bottomBarBehavior: StreamBottomAppBarBehavior.regular,
        bottom: const SizedBox(height: 64),
        body: const SizedBox.expand(),
      );

      // A regular bottom must never sit in bottomNavigationBar (that slot is not
      // lifted above the keyboard), regardless of the app-bar behavior.
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.bottomNavigationBar, isNull);
    });

    testWidgets('a regular bottom rides above the keyboard rather than behind it', (tester) async {
      const barKey = ValueKey('bar');
      const keyboard = 300.0;

      await _pumpStreamScaffold(
        tester,
        appBarBehavior: StreamAppBarBehavior.floating,
        appBar: _rawAppBar(),
        bottomBarBehavior: StreamBottomAppBarBehavior.regular,
        bottom: const SizedBox(key: barKey, height: 64),
        viewInsets: const EdgeInsets.only(bottom: keyboard),
        body: const SizedBox.expand(),
      );

      final surfaceHeight = tester.view.physicalSize.height / tester.view.devicePixelRatio;
      final barBottom = tester.getRect(find.byKey(barKey)).bottom;
      expect(barBottom, lessThanOrEqualTo(surfaceHeight - keyboard + 0.5));
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
