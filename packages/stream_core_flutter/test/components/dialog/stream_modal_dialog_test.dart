import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/video.dart';

Widget _app({
  required Widget child,
  Brightness brightness = Brightness.light,
  TargetPlatform? platform,
}) {
  return MaterialApp(
    theme: ThemeData(
      brightness: brightness,
      platform: platform,
      extensions: [StreamTheme(brightness: brightness)],
    ),
    home: Scaffold(body: Center(child: child)),
  );
}

/// Opens a dialog and leaves it open.
///
/// [onResult] is called once the dialog is dismissed, which is the only point
/// at which what it was popped with is known.
Future<void> _openDialog(
  WidgetTester tester, {
  required WidgetBuilder builder,
  ValueChanged<String?>? onResult,
  TargetPlatform? platform,
  Color? barrierColor,
  bool useSafeArea = true,
}) async {
  await tester.pumpWidget(
    _app(
      platform: platform,
      child: Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            final result = await showStreamModalDialog<String>(
              context: context,
              barrierColor: barrierColor,
              useSafeArea: useSafeArea,
              builder: builder,
            );
            onResult?.call(result);
          },
          child: const Text('open'),
        ),
      ),
    ),
  );

  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

ColoredBox _scrimFill(WidgetTester tester) {
  return tester.widget<ColoredBox>(
    find.descendant(of: find.byType(StreamBlurScrim), matching: find.byType(ColoredBox)),
  );
}

Finder _surfaceMaterial() {
  return find.descendant(of: find.byType(Dialog), matching: find.byType(Material)).first;
}

void main() {
  testWidgets('draws the title, the header actions and the footer actions', (tester) async {
    await _openDialog(
      tester,
      builder: (context) => StreamModalDialog(
        title: const Text('Choose what to share'),
        headerActions: [
          StreamButton.icon(icon: Icon(context.streamIcons.refresh), onPressed: () {}),
        ],
        actions: [
          StreamButton(onPressed: () {}, child: const Text('Cancel')),
          StreamButton(onPressed: () {}, child: const Text('Share')),
        ],
        child: const Text('body'),
      ),
    );

    expect(find.text('Choose what to share'), findsOneWidget);
    expect(find.byIcon(const StreamIcons().refresh), findsOneWidget);
    expect(find.text('body'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);
  });

  testWidgets('reads the title out as a heading', (tester) async {
    await _openDialog(
      tester,
      builder: (context) => StreamModalDialog(title: const Text('Settings'), child: const Text('body')),
    );

    expect(tester.getSemantics(find.text('Settings')), containsSemantics(isHeader: true));
  });

  testWidgets('names its route after the title', (tester) async {
    await _openDialog(
      tester,
      builder: (context) => StreamModalDialog(title: const Text('Settings'), child: const Text('body')),
    );

    expect(tester.getSemantics(find.text('Settings')), containsSemantics(namesRoute: true));
  });

  testWidgets('the close button dismisses with no value', (tester) async {
    String? result;
    var popped = false;

    await _openDialog(
      tester,
      builder: (context) => StreamModalDialog(child: const Text('body')),
      onResult: (value) {
        result = value;
        popped = true;
      },
    );

    await tester.tap(find.byIcon(const StreamIcons().xmark));
    await tester.pumpAndSettle();

    expect(find.text('body'), findsNothing);
    expect(popped, isTrue);
    expect(result, isNull);
  });

  testWidgets('the close button respects a PopScope that blocks the pop', (tester) async {
    await _openDialog(
      tester,
      builder: (context) => PopScope(
        canPop: false,
        child: StreamModalDialog(child: const Text('body')),
      ),
    );

    await tester.tap(find.byIcon(const StreamIcons().xmark));
    await tester.pumpAndSettle();

    expect(find.text('body'), findsOneWidget);
  });

  testWidgets('an untitled dialog is named Alert on Android', (tester) async {
    await _openDialog(
      tester,
      platform: TargetPlatform.android,
      builder: (context) => StreamModalDialog(child: const Text('body')),
    );

    expect(
      tester.getSemantics(find.bySemanticsLabel('Alert')),
      containsSemantics(label: 'Alert', namesRoute: true, scopesRoute: true),
    );
  });

  testWidgets('an untitled dialog is left unnamed on iOS', (tester) async {
    await _openDialog(
      tester,
      platform: TargetPlatform.iOS,
      builder: (context) => StreamModalDialog(child: const Text('body')),
    );

    expect(find.bySemanticsLabel('Alert'), findsNothing);
  });

  testWidgets('a titled dialog is named after its title, not Alert, on Android', (tester) async {
    await _openDialog(
      tester,
      platform: TargetPlatform.android,
      builder: (context) => StreamModalDialog(title: const Text('Settings'), child: const Text('body')),
    );

    expect(tester.getSemantics(find.text('Settings')), containsSemantics(namesRoute: true));
    expect(find.bySemanticsLabel('Alert'), findsNothing);
  });

  testWidgets('semanticLabel names the dialog instead of the title', (tester) async {
    await _openDialog(
      tester,
      builder: (context) => StreamModalDialog(
        title: const Text('Settings'),
        semanticLabel: 'Call settings',
        child: const Text('body'),
      ),
    );

    expect(
      tester.getSemantics(find.bySemanticsLabel('Call settings')),
      containsSemantics(label: 'Call settings', namesRoute: true, scopesRoute: true),
    );
    expect(tester.getSemantics(find.text('Settings')), containsSemantics(isHeader: true, namesRoute: false));
  });

  testWidgets('Tab keeps focus inside the dialog, whatever the navigator defaults to', (tester) async {
    await tester.pumpWidget(
      _app(
        child: Navigator(
          routeTraversalEdgeBehavior: TraversalEdgeBehavior.leaveFlutterView,
          onGenerateRoute: (settings) => MaterialPageRoute<void>(
            builder: (context) => TextButton(
              onPressed: () => showStreamModalDialog<void>(
                context: context,
                useRootNavigator: false,
                builder: (context) => StreamModalDialog(
                  actions: [
                    StreamButton(onPressed: () {}, child: const Text('one')),
                    StreamButton(onPressed: () {}, child: const Text('two')),
                  ],
                  child: const Text('body'),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final dialog = find.byType(StreamModalDialog);
    for (var i = 0; i < 6; i += 1) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      final focused = primaryFocus?.context;
      expect(focused, isNotNull);
      expect(find.ancestor(of: find.byElementPredicate((e) => e == focused), matching: dialog), findsOneWidget);
    }
  });

  testWidgets('keeps the dialog clear of the safe area', (tester) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(800, 600)
      ..padding = const FakeViewPadding(top: 100);
    addTearDown(tester.view.reset);

    await _openDialog(
      tester,
      builder: (context) => StreamModalDialog(
        child: ListView(children: [for (var i = 0; i < 100; i += 1) Text('row $i')]),
      ),
    );

    expect(tester.getRect(_surfaceMaterial()).top, greaterThanOrEqualTo(100));
  });

  testWidgets('ignores the safe area when useSafeArea is false', (tester) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(800, 600)
      ..padding = const FakeViewPadding(top: 100);
    addTearDown(tester.view.reset);

    await _openDialog(
      tester,
      useSafeArea: false,
      builder: (context) => StreamModalDialog(
        child: ListView(children: [for (var i = 0; i < 100; i += 1) Text('row $i')]),
      ),
    );

    expect(tester.getRect(_surfaceMaterial()).top, lessThan(100));
  });

  testWidgets('barrierColor overrides the scrim color', (tester) async {
    await _openDialog(
      tester,
      barrierColor: Colors.orange,
      builder: (context) => StreamModalDialog(child: const Text('body')),
    );

    expect(_scrimFill(tester).color, Colors.orange);
  });

  testWidgets('contentPadding pads the body', (tester) async {
    await _openDialog(
      tester,
      builder: (context) => StreamModalDialog(
        showCloseButton: false,
        contentPadding: const EdgeInsets.all(10),
        child: const SizedBox(width: 50, height: 50),
      ),
    );

    final body = tester.getRect(find.byType(SizedBox).last);
    final surface = tester.getRect(_surfaceMaterial());
    expect(surface.bottom - body.bottom, 10);
  });

  for (final (platform, padding) in [(TargetPlatform.macOS, 24.0), (TargetPlatform.android, 16.0)]) {
    testWidgets('on ${platform.name}, the body keeps $padding from the edge without a footer', (tester) async {
      await _openDialog(
        tester,
        platform: platform,
        builder: (context) => StreamModalDialog(
          title: const Text('Settings'),
          child: const SizedBox(width: 50, height: 50),
        ),
      );

      final body = tester.getRect(find.byType(SizedBox).last);
      final surface = tester.getRect(_surfaceMaterial());
      expect(surface.bottom - body.bottom, padding);
      expect(body.left - surface.left, padding);
    });

    testWidgets('on ${platform.name}, the body keeps $padding from the footer', (tester) async {
      await _openDialog(
        tester,
        platform: platform,
        builder: (context) => StreamModalDialog(
          title: const Text('Settings'),
          showCloseButton: false,
          actions: [StreamButton(onPressed: () {}, child: const Text('Done'))],
          child: const SizedBox(width: 50, height: 50),
        ),
      );

      final body = tester.getRect(find.byType(SizedBox).last);
      final button = tester.getRect(find.byType(StreamButton));
      final surface = tester.getRect(_surfaceMaterial());
      expect(button.top - body.bottom, padding);
      expect(surface.bottom - button.bottom, padding);
    });
  }

  group('transition', () {
    Future<void> open(WidgetTester tester, {AnimationStyle? animationStyle}) async {
      await tester.pumpWidget(
        _app(
          platform: TargetPlatform.android,
          child: Builder(
            builder: (context) => TextButton(
              onPressed: () => showStreamModalDialog<void>(
                context: context,
                animationStyle: animationStyle,
                builder: (context) => StreamModalDialog(child: const Text('body')),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pump();
    }

    double blurSigma(WidgetTester tester) {
      final scrim = tester.widget<StreamBlurScrim>(find.byType(StreamBlurScrim));
      return scrim.blurSigma!;
    }

    testWidgets('grows the blur with the animation', (tester) async {
      await open(tester);
      expect(blurSigma(tester), 0);

      await tester.pump(const Duration(milliseconds: 75));
      expect(blurSigma(tester), allOf(greaterThan(0), lessThan(25)));

      await tester.pumpAndSettle();
      expect(blurSigma(tester), 25);
    });

    testWidgets('takes 150 milliseconds by default', (tester) async {
      await open(tester);
      await tester.pump(const Duration(milliseconds: 150));

      expect(blurSigma(tester), 25);
    });

    testWidgets('animationStyle sets the duration and the curve', (tester) async {
      await open(
        tester,
        animationStyle: const AnimationStyle(duration: Duration(milliseconds: 400), curve: Curves.linear),
      );

      await tester.pump(const Duration(milliseconds: 200));
      expect(blurSigma(tester), moreOrLessEquals(12.5));

      await tester.pump(const Duration(milliseconds: 200));
      expect(blurSigma(tester), 25);
    });
  });

  testWidgets('on the web and desktop, a header with no title or buttons is 88 high', (tester) async {
    await _openDialog(
      tester,
      platform: TargetPlatform.macOS,
      builder: (context) => StreamModalDialog(
        showCloseButton: false,
        contentPadding: EdgeInsets.zero,
        child: const SizedBox.shrink(),
      ),
    );

    expect(tester.getSize(_surfaceMaterial()).height, 88);
  });

  testWidgets('on Android and iOS, a header with no title or buttons is 72 high', (tester) async {
    await _openDialog(
      tester,
      platform: TargetPlatform.iOS,
      builder: (context) => StreamModalDialog(
        showCloseButton: false,
        contentPadding: EdgeInsets.zero,
        child: const SizedBox.shrink(),
      ),
    );

    expect(tester.getSize(_surfaceMaterial()).height, 72);
  });

  testWidgets('on Android and iOS, the footer actions share its width equally', (tester) async {
    await _openDialog(
      tester,
      platform: TargetPlatform.android,
      builder: (context) => StreamModalDialog(
        actions: [
          StreamButton(onPressed: () {}, child: const Text('OK')),
          StreamButton(onPressed: () {}, child: const Text('Discard all changes')),
        ],
        child: const Text('body'),
      ),
    );

    final ok = tester.getSize(find.widgetWithText(StreamButton, 'OK'));
    final discard = tester.getSize(find.widgetWithText(StreamButton, 'Discard all changes'));
    expect(ok.width, discard.width);
  });

  testWidgets('on the web and desktop, the footer actions keep their own width', (tester) async {
    await _openDialog(
      tester,
      platform: TargetPlatform.windows,
      builder: (context) => StreamModalDialog(
        actions: [
          StreamButton(onPressed: () {}, child: const Text('OK')),
          StreamButton(onPressed: () {}, child: const Text('Discard all changes')),
        ],
        child: const Text('body'),
      ),
    );

    final ok = tester.getSize(find.widgetWithText(StreamButton, 'OK'));
    final discard = tester.getSize(find.widgetWithText(StreamButton, 'Discard all changes'));
    expect(ok.width, lessThan(discard.width));
  });

  testWidgets('the close button calls onClose instead of popping when given', (tester) async {
    var closed = 0;

    await _openDialog(
      tester,
      builder: (context) => StreamModalDialog(onClose: () => closed += 1, child: const Text('body')),
    );

    await tester.tap(find.byIcon(const StreamIcons().xmark));
    await tester.pumpAndSettle();

    expect(closed, 1);
    expect(find.text('body'), findsOneWidget);
  });

  testWidgets('pops with the value a footer action passes', (tester) async {
    String? result;

    await _openDialog(
      tester,
      builder: (context) => StreamModalDialog(
        actions: [
          StreamButton(onPressed: () => Navigator.pop(context, 'shared'), child: const Text('Share')),
        ],
        child: const Text('body'),
      ),
      onResult: (value) => result = value,
    );

    await tester.tap(find.text('Share'));
    await tester.pumpAndSettle();

    expect(result, 'shared');
  });

  testWidgets('draws no footer without actions', (tester) async {
    await _openDialog(
      tester,
      builder: (context) => StreamModalDialog(child: const Text('body')),
    );

    expect(find.byType(StreamButton), findsOneWidget); // the close button
  });

  testWidgets('draws no close button when showCloseButton is false', (tester) async {
    await _openDialog(
      tester,
      builder: (context) => StreamModalDialog(showCloseButton: false, child: const Text('body')),
    );

    expect(find.byIcon(const StreamIcons().xmark), findsNothing);
  });

  testWidgets('stays within the default constraints', (tester) async {
    await _openDialog(
      tester,
      builder: (context) => StreamModalDialog(
        child: ListView(children: [for (var i = 0; i < 100; i += 1) Text('row $i')]),
      ),
    );

    final size = tester.getSize(_surfaceMaterial());
    expect(size.width, lessThanOrEqualTo(720));
    expect(size.height, lessThanOrEqualTo(640));
  });

  testWidgets('the scrim follows a theme change while it is open', (tester) async {
    Widget app(Brightness brightness) => _app(
      brightness: brightness,
      child: Builder(
        builder: (context) => TextButton(
          onPressed: () => showStreamModalDialog<void>(
            context: context,
            builder: (context) => StreamModalDialog(child: const Text('body')),
          ),
          child: const Text('open'),
        ),
      ),
    );

    await tester.pumpWidget(app(Brightness.light));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.pumpWidget(app(Brightness.dark));
    await tester.pumpAndSettle();

    final dark = tester.element(find.text('body')).streamColorScheme;
    expect(dark.brightness, Brightness.dark);
    expect(_scrimFill(tester).color, dark.backgroundScrim);
  });

  testWidgets('a theme around the caller reaches the scrim and the dialog', (tester) async {
    await tester.pumpWidget(
      _app(
        child: Theme(
          data: ThemeData(
            brightness: Brightness.dark,
            extensions: [StreamTheme(brightness: Brightness.dark)],
          ),
          child: Builder(
            builder: (context) => TextButton(
              onPressed: () => showStreamModalDialog<void>(
                context: context,
                builder: (context) => StreamModalDialog(child: const Text('body')),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final colorScheme = tester.element(find.text('body')).streamColorScheme;
    expect(colorScheme.brightness, Brightness.dark);
    expect(_scrimFill(tester).color, colorScheme.backgroundScrim);
  });

  testWidgets('a tap outside dismisses it through the scrim', (tester) async {
    await _openDialog(
      tester,
      builder: (context) => StreamModalDialog(child: const Text('body')),
    );

    expect(find.byType(StreamBlurScrim), findsOneWidget);

    await tester.tapAt(Offset.zero);
    await tester.pumpAndSettle();

    expect(find.text('body'), findsNothing);
  });

  testWidgets('a tap outside does nothing when barrierDismissible is false', (tester) async {
    await tester.pumpWidget(
      _app(
        child: Builder(
          builder: (context) => TextButton(
            onPressed: () => showStreamModalDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (context) => StreamModalDialog(child: const Text('body')),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tapAt(Offset.zero);
    await tester.pumpAndSettle();

    expect(find.text('body'), findsOneWidget);
  });

  testWidgets('uses the builder from the component factory', (tester) async {
    StreamModalDialogProps? received;

    await tester.pumpWidget(
      _app(
        child: StreamComponentFactory(
          builders: StreamComponentBuilders(
            modalDialog: (context, props) {
              received = props;
              return const Text('custom dialog');
            },
          ),
          child: StreamModalDialog(title: const Text('title'), child: const Text('body')),
        ),
      ),
    );

    expect(find.text('custom dialog'), findsOneWidget);
    expect(find.byType(DefaultStreamModalDialog), findsNothing);
    expect(received?.showCloseButton, isTrue);
  });

  group('StreamBlurScrim', () {
    testWidgets('blurs by 25 on Android and iOS', (tester) async {
      await tester.pumpWidget(_app(platform: TargetPlatform.android, child: const StreamBlurScrim()));

      final filter = tester.widget<BackdropFilter>(find.byType(BackdropFilter));
      expect(filter.filter, ImageFilter.blur(sigmaX: 25, sigmaY: 25));
    });

    testWidgets('blurs by 12.5 on the web and desktop', (tester) async {
      await tester.pumpWidget(_app(platform: TargetPlatform.macOS, child: const StreamBlurScrim()));

      final filter = tester.widget<BackdropFilter>(find.byType(BackdropFilter));
      expect(filter.filter, ImageFilter.blur(sigmaX: 12.5, sigmaY: 12.5));
    });

    testWidgets('skips the blur at a sigma of 0', (tester) async {
      await tester.pumpWidget(_app(child: const StreamBlurScrim(blurSigma: 0)));

      expect(find.byType(BackdropFilter), findsNothing);
      expect(find.descendant(of: find.byType(StreamBlurScrim), matching: find.byType(ColoredBox)), findsOneWidget);
    });
  });

  group('on a folded window', () {
    const fold = Rect.fromLTWH(475, 0, 0, 669);

    Future<Rect> dialogRect(WidgetTester tester, {Offset? anchorPoint}) async {
      tester.view
        ..devicePixelRatio = 1.0
        ..physicalSize = const Size(951, 669)
        ..displayFeatures = const [
          DisplayFeature(
            bounds: fold,
            type: DisplayFeatureType.fold,
            state: DisplayFeatureState.postureHalfOpened,
          ),
        ];
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _app(
          child: Builder(
            builder: (context) => TextButton(
              onPressed: () => showStreamModalDialog<void>(
                context: context,
                anchorPoint: anchorPoint,
                builder: (context) => StreamModalDialog(title: const Text('title'), child: const Text('body')),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      return tester.getRect(find.byType(StreamModalDialog));
    }

    testWidgets('goes to the trailing half by default', (tester) async {
      final rect = await dialogRect(tester);

      expect(rect.left, greaterThanOrEqualTo(fold.right));
    });

    testWidgets('goes to the half the anchor point is in', (tester) async {
      final rect = await dialogRect(tester, anchorPoint: const Offset(100, 0));

      expect(rect.right, lessThanOrEqualTo(fold.left));
    });
  });
}
