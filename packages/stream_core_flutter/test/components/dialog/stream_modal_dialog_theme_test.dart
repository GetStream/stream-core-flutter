import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/video.dart';

Widget _app({required Widget child, StreamModalDialogThemeData? modalDialogTheme}) {
  return MaterialApp(
    theme: ThemeData(extensions: [StreamTheme(modalDialogTheme: modalDialogTheme)]),
    home: Scaffold(body: child),
  );
}

/// A button that opens [builder] with [showStreamModalDialog] from wherever
/// it sits in the tree.
Widget _opener(WidgetBuilder builder) {
  return Builder(
    builder: (context) => TextButton(
      onPressed: () => showStreamModalDialog<void>(context: context, builder: builder),
      child: const Text('open'),
    ),
  );
}

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

Dialog _surface(WidgetTester tester) => tester.widget<Dialog>(find.byType(Dialog));

ColoredBox _scrimFill(WidgetTester tester) {
  return tester.widget<ColoredBox>(
    find.descendant(of: find.byType(StreamBlurScrim), matching: find.byType(ColoredBox)),
  );
}

Finder _surfaceMaterial() {
  return find.descendant(of: find.byType(Dialog), matching: find.byType(Material)).first;
}

void main() {
  testWidgets('resolves the design defaults without a theme', (tester) async {
    await tester.pumpWidget(_app(child: _opener((context) => StreamModalDialog(child: const Text('body')))));
    await _open(tester);

    final context = tester.element(find.text('body'));
    final surface = _surface(tester);
    expect(surface.backgroundColor, context.streamColorScheme.backgroundElevation1);
    expect(surface.elevation, context.streamElevation.level4);
    expect(surface.insetPadding, EdgeInsets.all(context.streamSpacing.xxl));
    expect(
      surface.shape,
      RoundedRectangleBorder(borderRadius: BorderRadius.all(context.streamRadius.xl)),
    );
    expect(_scrimFill(tester).color, context.streamColorScheme.backgroundScrim);
  });

  for (final useMaterial3 in [true, false]) {
    testWidgets('paints exactly the background color in dark mode (useMaterial3: $useMaterial3)', (tester) async {
      final streamTheme = StreamTheme(brightness: Brightness.dark);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.dark, useMaterial3: useMaterial3, extensions: [streamTheme]),
          home: StreamModalDialog(child: const Text('body')),
        ),
      );

      // The elevated PhysicalShape the surface's Material paints: its color is
      // the background after any elevation tint or overlay.
      final painted = tester.widget<PhysicalShape>(
        find.descendant(of: find.byType(Dialog), matching: find.byType(PhysicalShape)).first,
      );
      expect(painted.color, streamTheme.colorScheme.backgroundElevation1);
      expect(painted.elevation, streamTheme.elevation.level4);
    });
  }

  testWidgets('applies the surface values from StreamTheme', (tester) async {
    const shape = RoundedRectangleBorder();

    await tester.pumpWidget(
      _app(
        modalDialogTheme: const StreamModalDialogThemeData(
          backgroundColor: Colors.red,
          elevation: 2,
          shape: shape,
          insetPadding: EdgeInsets.all(4),
          constraints: BoxConstraints(maxWidth: 300),
        ),
        child: _opener((context) => StreamModalDialog(child: const Text('body'))),
      ),
    );
    await _open(tester);

    final surface = _surface(tester);
    expect(surface.backgroundColor, Colors.red);
    expect(surface.elevation, 2);
    expect(surface.shape, shape);
    expect(surface.insetPadding, const EdgeInsets.all(4));
    expect(tester.getSize(_surfaceMaterial()).width, lessThanOrEqualTo(300));
  });

  testWidgets('applies the header and footer styles from StreamTheme', (tester) async {
    const titleStyle = TextStyle(fontSize: 31, color: Colors.green);

    await tester.pumpWidget(
      _app(
        modalDialogTheme: const StreamModalDialogThemeData(
          headerStyle: StreamModalDialogHeaderStyle(padding: EdgeInsets.all(3), titleTextStyle: titleStyle),
          footerStyle: StreamModalDialogFooterStyle(padding: EdgeInsets.all(5), actionsSpacing: 17),
        ),
        child: _opener(
          (context) => StreamModalDialog(
            title: const Text('title'),
            actions: [
              StreamButton(onPressed: () {}, child: const Text('one')),
              StreamButton(onPressed: () {}, child: const Text('two')),
            ],
            child: const Text('body'),
          ),
        ),
      ),
    );
    await _open(tester);

    final title = tester.widget<RichText>(find.descendant(of: find.text('title'), matching: find.byType(RichText)));
    expect(title.text.style?.fontSize, 31);
    expect(title.text.style?.color, Colors.green);

    final paddings = tester.widgetList<Padding>(
      find.ancestor(of: find.text('title'), matching: find.byType(Padding)),
    );
    expect(paddings.map((padding) => padding.padding), contains(const EdgeInsets.all(3)));

    final footer = tester.widget<Row>(
      find.ancestor(of: find.text('one'), matching: find.byType(Row)).last,
    );
    expect(footer.spacing, 17);
    final footerPaddings = tester.widgetList<Padding>(
      find.ancestor(of: find.text('one'), matching: find.byType(Padding)),
    );
    expect(footerPaddings.map((padding) => padding.padding), contains(const EdgeInsets.all(5)));
  });

  testWidgets('applies the scrim values from StreamTheme', (tester) async {
    await tester.pumpWidget(
      _app(
        modalDialogTheme: const StreamModalDialogThemeData(scrimColor: Colors.purple, scrimBlurSigma: 4),
        child: _opener((context) => StreamModalDialog(child: const Text('body'))),
      ),
    );
    await _open(tester);

    expect(_scrimFill(tester).color, Colors.purple);
    final filter = tester.widget<BackdropFilter>(
      find.descendant(of: find.byType(StreamBlurScrim), matching: find.byType(BackdropFilter)),
    );
    expect(filter.filter, ImageFilter.blur(sigmaX: 4, sigmaY: 4));
  });

  testWidgets('a StreamModalDialogTheme around the caller reaches the dialog and the scrim', (tester) async {
    await tester.pumpWidget(
      _app(
        modalDialogTheme: const StreamModalDialogThemeData(backgroundColor: Colors.red, scrimColor: Colors.red),
        child: StreamModalDialogTheme(
          data: const StreamModalDialogThemeData(backgroundColor: Colors.blue, scrimColor: Colors.blue),
          child: _opener((context) => StreamModalDialog(child: const Text('body'))),
        ),
      ),
    );
    await _open(tester);

    expect(_surface(tester).backgroundColor, Colors.blue);
    expect(_scrimFill(tester).color, Colors.blue);
  });

  testWidgets('a local theme only overrides the fields it sets', (tester) async {
    await tester.pumpWidget(
      _app(
        modalDialogTheme: const StreamModalDialogThemeData(backgroundColor: Colors.red, elevation: 2),
        child: StreamModalDialogTheme(
          data: const StreamModalDialogThemeData(elevation: 7),
          child: _opener((context) => StreamModalDialog(child: const Text('body'))),
        ),
      ),
    );
    await _open(tester);

    expect(_surface(tester).backgroundColor, Colors.red);
    expect(_surface(tester).elevation, 7);
  });

  testWidgets('the constraints parameter beats the theme', (tester) async {
    await tester.pumpWidget(
      _app(
        modalDialogTheme: const StreamModalDialogThemeData(constraints: BoxConstraints(maxWidth: 300)),
        child: _opener(
          (context) => StreamModalDialog(
            constraints: const BoxConstraints.tightFor(width: 400, height: 200),
            child: const Text('body'),
          ),
        ),
      ),
    );
    await _open(tester);

    expect(tester.getSize(_surfaceMaterial()), const Size(400, 200));
  });

  testWidgets('the scrim parameters beat the theme', (tester) async {
    await tester.pumpWidget(
      _app(
        modalDialogTheme: const StreamModalDialogThemeData(scrimColor: Colors.purple, scrimBlurSigma: 4),
        child: const StreamBlurScrim(color: Colors.orange, blurSigma: 0),
      ),
    );

    expect(_scrimFill(tester).color, Colors.orange);
    expect(find.byType(BackdropFilter), findsNothing);
  });
}
