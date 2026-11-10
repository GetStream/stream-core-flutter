import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/video.dart';

List<StreamModalWindowTab> _tabs() => [
  for (final (name, icon) in [
    ('Device', const StreamIcons().settingsFill),
    ('Effects', const StreamIcons().blurFill),
  ])
    StreamModalWindowTab(
      icon: Icon(icon),
      label: Text(name),
      builder: (context) => Text('$name content'),
    ),
];

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  StreamModalWindowThemeData? modalWindowTheme,
  StreamModalDialogThemeData? modalDialogTheme,
}) async {
  tester.view.physicalSize = const Size(1024, 768);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(
        extensions: [StreamTheme(modalWindowTheme: modalWindowTheme, modalDialogTheme: modalDialogTheme)],
      ),
      home: Material(child: child),
    ),
  );
}

// The nearest focus traversal group around a row is the sidebar's.
Finder _sidebar() => find.ancestor(of: find.text('Effects'), matching: find.byType(FocusTraversalGroup)).first;

double _sidebarWidth(WidgetTester tester) => tester.getSize(_sidebar()).width;

Material _sidebarMaterial(WidgetTester tester) =>
    tester.widget<Material>(find.ancestor(of: _sidebar(), matching: find.byType(Material)).first);

Finder _surfaceMaterial() => find.descendant(of: find.byType(Dialog), matching: find.byType(Material)).first;

Dialog _surface(WidgetTester tester) => tester.widget<Dialog>(find.byType(Dialog));

Border? _sidebarBorder(WidgetTester tester) {
  final box = tester.widget<DecoratedBox>(
    find.ancestor(of: _sidebar(), matching: find.byType(DecoratedBox)).last,
  );
  final border = (box.decoration as BoxDecoration).border! as BorderDirectional;
  return Border(right: border.end);
}

void main() {
  testWidgets('resolves the design defaults without a theme', (tester) async {
    await _pump(tester, StreamModalWindow(tabs: _tabs()));

    final context = tester.element(find.text('Device content'));
    expect(_sidebarWidth(tester), 200);
    expect(_surface(tester).backgroundColor, context.streamColorScheme.backgroundElevation1);
    expect(_sidebarMaterial(tester).color, context.streamColorScheme.backgroundElevation1);
    expect(_sidebarBorder(tester)?.right.color, context.streamColorScheme.borderSubtle);

    final scroll = tester.widget<SingleChildScrollView>(
      find.ancestor(of: find.text('Device content'), matching: find.byType(SingleChildScrollView)),
    );
    expect(
      scroll.padding,
      EdgeInsetsDirectional.only(
        start: context.streamSpacing.xl,
        end: context.streamSpacing.xl,
        bottom: context.streamSpacing.xxl,
      ),
    );
  });

  for (final useMaterial3 in [true, false]) {
    testWidgets('the sidebar and the surface paint one color in dark mode (useMaterial3: $useMaterial3)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final streamTheme = StreamTheme(brightness: Brightness.dark);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.dark, useMaterial3: useMaterial3, extensions: [streamTheme]),
          home: Material(child: StreamModalWindow(tabs: _tabs())),
        ),
      );

      // The colors the Materials paint, after any elevation tint or overlay.
      final surface = tester.widget<PhysicalShape>(
        find.descendant(of: find.byType(Dialog), matching: find.byType(PhysicalShape)).first,
      );
      final sidebar = tester.widget<PhysicalShape>(
        find.ancestor(of: _sidebar(), matching: find.byType(PhysicalShape)).first,
      );
      expect(surface.color, streamTheme.colorScheme.backgroundElevation1);
      expect(sidebar.color, surface.color);
    });
  }

  testWidgets('applies the values from StreamTheme', (tester) async {
    await _pump(
      tester,
      StreamModalWindow(tabs: _tabs()),
      modalWindowTheme: const StreamModalWindowThemeData(
        style: StreamModalWindowStyle(
          backgroundColor: Colors.red,
          sidebarWidth: 260,
          sidebarBackgroundColor: Colors.green,
          sidebarBorderColor: Colors.blue,
          contentPadding: EdgeInsets.all(3),
          navItemIconSize: 20,
        ),
      ),
    );

    expect(_sidebarWidth(tester), 260);
    expect(_surface(tester).backgroundColor, Colors.red);
    expect(_sidebarMaterial(tester).color, Colors.green);
    expect(_sidebarBorder(tester)?.right.color, Colors.blue);
    expect(tester.getSize(find.byIcon(const StreamIcons().blurFill)), const Size.square(20));

    final scroll = tester.widget<SingleChildScrollView>(
      find.ancestor(of: find.text('Device content'), matching: find.byType(SingleChildScrollView)),
    );
    expect(scroll.padding, const EdgeInsets.all(3));
  });

  testWidgets('a local theme overrides one value and inherits the rest', (tester) async {
    await _pump(
      tester,
      StreamModalWindowTheme(
        data: const StreamModalWindowThemeData(style: StreamModalWindowStyle(sidebarBorderColor: Colors.blue)),
        child: StreamModalWindow(tabs: _tabs()),
      ),
      modalWindowTheme: const StreamModalWindowThemeData(style: StreamModalWindowStyle(sidebarWidth: 240)),
    );

    expect(_sidebarWidth(tester), 240);
    expect(_sidebarBorder(tester)?.right.color, Colors.blue);
  });

  testWidgets('a local theme reaches a window opened as a dialog', (tester) async {
    await _pump(
      tester,
      StreamModalWindowTheme(
        data: const StreamModalWindowThemeData(style: StreamModalWindowStyle(sidebarWidth: 240)),
        child: Builder(
          builder: (context) => TextButton(
            onPressed: () => showStreamModalDialog<void>(
              context: context,
              builder: (context) => StreamModalWindow(tabs: _tabs()),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(_sidebarWidth(tester), 240);
  });

  testWidgets('navItemStyle merges with the default row style', (tester) async {
    await _pump(
      tester,
      StreamModalWindowTheme(
        data: const StreamModalWindowThemeData(
          style: StreamModalWindowStyle(navItemStyle: StreamListTileThemeData(shape: StadiumBorder())),
        ),
        child: StreamModalWindow(tabs: _tabs()),
      ),
    );

    final row = tester.element(find.text('Effects'));
    final rowTheme = StreamListTileTheme.of(row);
    expect(rowTheme.shape, const StadiumBorder());
    // The default padding is kept.
    expect(
      rowTheme.contentPadding,
      EdgeInsets.symmetric(horizontal: row.streamSpacing.sm, vertical: row.streamSpacing.xs),
    );
  });

  group('surface from the modal dialog theme', () {
    testWidgets('shares the dialog theme surface', (tester) async {
      const shape = RoundedRectangleBorder();

      await _pump(
        tester,
        StreamModalWindow(tabs: _tabs()),
        modalDialogTheme: const StreamModalDialogThemeData(
          backgroundColor: Colors.orange,
          elevation: 2,
          shape: shape,
          constraints: BoxConstraints(maxWidth: 600, maxHeight: 400),
        ),
      );

      final surface = _surface(tester);
      expect(surface.backgroundColor, Colors.orange);
      expect(surface.elevation, 2);
      expect(surface.shape, shape);
      // The sidebar follows the surface color it sits on.
      expect(_sidebarMaterial(tester).color, Colors.orange);
      expect(tester.getSize(_surfaceMaterial()), const Size(600, 400));
    });

    testWidgets('the window background beats the dialog background', (tester) async {
      await _pump(
        tester,
        StreamModalWindow(tabs: _tabs()),
        modalDialogTheme: const StreamModalDialogThemeData(backgroundColor: Colors.orange),
        modalWindowTheme: const StreamModalWindowThemeData(
          style: StreamModalWindowStyle(backgroundColor: Colors.red),
        ),
      );

      expect(_surface(tester).backgroundColor, Colors.red);
      expect(_sidebarMaterial(tester).color, Colors.red);
    });

    testWidgets('the header title style comes from the dialog theme', (tester) async {
      await _pump(
        tester,
        StreamModalWindow(tabs: _tabs()),
        modalDialogTheme: const StreamModalDialogThemeData(
          headerStyle: StreamModalDialogHeaderStyle(titleTextStyle: TextStyle(fontSize: 30)),
        ),
      );

      // The header's title is the second "Device": after the sidebar's.
      final title = tester.widget<RichText>(
        find.descendant(of: find.text('Device').last, matching: find.byType(RichText)),
      );
      expect(title.text.style?.fontSize, 30);
    });
  });

  testWidgets('the constraints param beats the dialog theme', (tester) async {
    await _pump(
      tester,
      StreamModalWindow(
        tabs: _tabs(),
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 500),
      ),
      modalDialogTheme: const StreamModalDialogThemeData(
        constraints: BoxConstraints(maxWidth: 600, maxHeight: 400),
      ),
    );

    expect(tester.getSize(_surfaceMaterial()), const Size(700, 500));
  });
}
