import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

Widget _withStreamTheme(Widget child, {StreamAppStyle appStyle = StreamAppStyle.regular}) {
  return MaterialApp(
    theme: ThemeData(extensions: [StreamTheme(appStyle: appStyle)]),
    home: child,
  );
}

class _InsetsProbe extends StatelessWidget {
  const _InsetsProbe();

  @override
  Widget build(BuildContext context) {
    final insets = StreamScaffoldInsets.of(context);
    return Text('top:${insets.topPadding} bottom:${insets.bottomPadding}');
  }
}

void main() {
  group('StreamScaffoldInsets', () {
    testWidgets('of() asserts when no ancestor is present', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(const Scaffold(body: _InsetsProbe())),
      );

      expect(tester.takeException(), isA<AssertionError>());
    });

    testWidgets('maybeOf() returns null when no ancestor is present', (tester) async {
      StreamScaffoldInsets? result;
      await tester.pumpWidget(
        _withStreamTheme(
          Scaffold(
            body: Builder(
              builder: (context) {
                result = StreamScaffoldInsets.maybeOf(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(result, isNull);
    });
  });

  group('when neither slot is floating', () {
    testWidgets('injects zero insets and forwards drawer/endDrawer', (tester) async {
      const drawer = Drawer(key: ValueKey('drawer'));
      const endDrawer = Drawer(key: ValueKey('end-drawer'));

      await tester.pumpWidget(
        _withStreamTheme(
          const StreamScaffold(
            drawer: drawer,
            endDrawer: endDrawer,
            body: _InsetsProbe(),
          ),
        ),
      );

      expect(find.text('top:0.0 bottom:0.0'), findsOneWidget);

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
    testWidgets('extends the body behind the app bar and reports its height as topPadding', (tester) async {
      const appBarHeight = kToolbarHeight;

      await tester.pumpWidget(
        _withStreamTheme(
          const StreamScaffold(
            appBarBehavior: StreamAppBarBehavior.floating,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(appBarHeight),
              child: SizedBox(),
            ),
            body: _InsetsProbe(),
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.extendBodyBehindAppBar, isTrue);

      final topPadding = MediaQuery.paddingOf(tester.element(find.byType(_InsetsProbe))).top;
      expect(find.text('top:${appBarHeight + topPadding} bottom:0.0'), findsOneWidget);
    });
  });

  group('when the bottom widget is floating', () {
    testWidgets('extends the body, drops bottomNavigationBar, and reports the bottom height as bottomPadding', (
      tester,
    ) async {
      const bottomHeight = 64.0;

      await tester.pumpWidget(
        _withStreamTheme(
          const StreamScaffold(
            bottomBarBehavior: StreamBottomAppBarBehavior.floating,
            bottom: SizedBox(height: bottomHeight),
            body: _InsetsProbe(),
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.extendBody, isTrue);
      expect(scaffold.bottomNavigationBar, isNull);
      expect(find.text('top:0.0 bottom:$bottomHeight'), findsOneWidget);
    });

    testWidgets('reports the updated bottomPadding after the bottom widget resizes', (tester) async {
      Widget buildWithHeight(double height) {
        return _withStreamTheme(
          StreamScaffold(
            bottomBarBehavior: StreamBottomAppBarBehavior.floating,
            bottom: SizedBox(height: height),
            body: const _InsetsProbe(),
          ),
        );
      }

      await tester.pumpWidget(buildWithHeight(64));
      expect(find.text('top:0.0 bottom:64.0'), findsOneWidget);

      await tester.pumpWidget(buildWithHeight(80));
      expect(find.text('top:0.0 bottom:80.0'), findsOneWidget);
    });

    testWidgets('is not floating when no bottom widget is provided', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          const StreamScaffold(
            bottomBarBehavior: StreamBottomAppBarBehavior.floating,
            body: _InsetsProbe(),
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.extendBody, isFalse);
      expect(find.text('top:0.0 bottom:0.0'), findsOneWidget);
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
