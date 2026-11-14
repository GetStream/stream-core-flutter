import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/video.dart';

Widget _app({required Widget child, Brightness brightness = Brightness.light}) {
  return MaterialApp(
    theme: ThemeData(
      brightness: brightness,
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
}) async {
  await tester.pumpWidget(
    _app(
      child: Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            final result = await showStreamModalDialog<String>(
              context: context,
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
    expect(size.width, lessThanOrEqualTo(StreamModalDialog.defaultConstraints.maxWidth));
    expect(size.height, lessThanOrEqualTo(StreamModalDialog.defaultConstraints.maxHeight));
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
    testWidgets('blurs what is behind it by default', (tester) async {
      await tester.pumpWidget(_app(child: const StreamBlurScrim()));

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
