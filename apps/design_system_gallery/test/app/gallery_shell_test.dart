import 'package:design_system_gallery/app/gallery_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';

void main() {
  group('GalleryShell', () {
    Widget createTestableWidget({
      bool showThemePanel = true,
      VoidCallback? onToggleThemePanel,
    }) {
      return MaterialApp(
        theme: ThemeData(extensions: [StreamTheme()]),
        home: GalleryShell(
          showThemePanel: showThemePanel,
          onToggleThemePanel: onToggleThemePanel ?? () {},
        ),
      );
    }

    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(createTestableWidget());
      expect(find.byType(GalleryShell), findsOneWidget);
    });

    testWidgets('creates Scaffold', (tester) async {
      await tester.pumpWidget(createTestableWidget());
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows toolbar', (tester) async {
      await tester.pumpWidget(createTestableWidget());
      expect(find.byType(GalleryToolbar), findsOneWidget);
    });

    testWidgets('toolbar receives showThemePanel prop', (tester) async {
      await tester.pumpWidget(createTestableWidget(showThemePanel: true));
      final toolbar = tester.widget<GalleryToolbar>(find.byType(GalleryToolbar));
      expect(toolbar.showThemePanel, isTrue);

      await tester.pumpWidget(createTestableWidget(showThemePanel: false));
      final toolbar2 = tester.widget<GalleryToolbar>(find.byType(GalleryToolbar));
      expect(toolbar2.showThemePanel, isFalse);
    });

    testWidgets('toolbar receives onToggleThemePanel callback', (tester) async {
      var callbackInvoked = false;
      await tester.pumpWidget(createTestableWidget(
        onToggleThemePanel: () => callbackInvoked = true,
      ));

      final toolbar = tester.widget<GalleryToolbar>(find.byType(GalleryToolbar));
      toolbar.onToggleThemePanel();
      expect(callbackInvoked, isTrue);
    });

    testWidgets('contains theme customization panel', (tester) async {
      await tester.pumpWidget(createTestableWidget());
      expect(find.byType(ThemeCustomizationPanel), findsOneWidget);
    });

    testWidgets('theme panel is visible when showThemePanel is true', (tester) async {
      await tester.pumpWidget(createTestableWidget(showThemePanel: true));
      await tester.pumpAndSettle();

      final animatedSlide = tester.widget<AnimatedSlide>(
        find.ancestor(
          of: find.byType(ThemeCustomizationPanel),
          matching: find.byType(AnimatedSlide),
        ),
      );
      expect(animatedSlide.offset, Offset.zero);
    });

    testWidgets('theme panel is hidden when showThemePanel is false', (tester) async {
      await tester.pumpWidget(createTestableWidget(showThemePanel: false));
      await tester.pumpAndSettle();

      final animatedSlide = tester.widget<AnimatedSlide>(
        find.ancestor(
          of: find.byType(ThemeCustomizationPanel),
          matching: find.byType(AnimatedSlide),
        ),
      );
      expect(animatedSlide.offset, const Offset(1, 0));
    });

    testWidgets('uses correct panel animation duration', (tester) async {
      await tester.pumpWidget(createTestableWidget());

      final animatedSlide = tester.widget<AnimatedSlide>(
        find.ancestor(
          of: find.byType(ThemeCustomizationPanel),
          matching: find.byType(AnimatedSlide),
        ),
      );
      expect(animatedSlide.duration, kPanelAnimationDuration);
    });

    testWidgets('uses correct panel animation curve', (tester) async {
      await tester.pumpWidget(createTestableWidget());

      final animatedSlide = tester.widget<AnimatedSlide>(
        find.ancestor(
          of: find.byType(ThemeCustomizationPanel),
          matching: find.byType(AnimatedSlide),
        ),
      );
      expect(animatedSlide.curve, Curves.easeInOut);
    });

    testWidgets('theme panel has correct width', (tester) async {
      await tester.pumpWidget(createTestableWidget());

      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(ThemeCustomizationPanel),
          matching: find.byType(SizedBox),
        ),
      );
      expect(sizedBox.width, kThemePanelWidth);
    });

    testWidgets('contains Column in Scaffold body', (tester) async {
      await tester.pumpWidget(createTestableWidget());
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.body, isA<Column>());
    });

    testWidgets('contains Stack for content area', (tester) async {
      await tester.pumpWidget(createTestableWidget());
      expect(find.byType(Stack), findsOneWidget);
    });

    testWidgets('contains Expanded widget', (tester) async {
      await tester.pumpWidget(createTestableWidget());
      expect(find.byType(Expanded), findsAtLeastNWidgets(1));
    });

    testWidgets('applies padding when theme panel is shown on large screen', (tester) async {
      // Set large screen size
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createTestableWidget(showThemePanel: true));
      await tester.pumpAndSettle();

      final animatedPadding = tester.widget<AnimatedPadding>(
        find.ancestor(
          of: find.byType(Widgetbook),
          matching: find.byType(AnimatedPadding),
        ),
      );
      expect(animatedPadding.padding.resolve(TextDirection.ltr).right, kThemePanelWidth);

      addTearDown(tester.view.reset);
    });

    testWidgets('removes padding when theme panel is hidden', (tester) async {
      // Set large screen size
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createTestableWidget(showThemePanel: false));
      await tester.pumpAndSettle();

      final animatedPadding = tester.widget<AnimatedPadding>(
        find.ancestor(
          of: find.byType(Widgetbook),
          matching: find.byType(AnimatedPadding),
        ),
      );
      expect(animatedPadding.padding.resolve(TextDirection.ltr).right, 0);

      addTearDown(tester.view.reset);
    });

    testWidgets('uses overlay on small screens', (tester) async {
      // Set small screen size
      tester.view.physicalSize = const Size(600, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createTestableWidget(showThemePanel: true));
      await tester.pumpAndSettle();

      // On small screens with panel shown, padding should be 0 (overlay mode)
      final animatedPadding = tester.widget<AnimatedPadding>(
        find.ancestor(
          of: find.byType(Widgetbook),
          matching: find.byType(AnimatedPadding),
        ),
      );
      expect(animatedPadding.padding.resolve(TextDirection.ltr).right, 0);

      addTearDown(tester.view.reset);
    });

    test('kThemePanelWidth constant is defined', () {
      expect(kThemePanelWidth, 340.0);
    });

    test('kWidgetbookDesktopBreakpoint constant is defined', () {
      expect(kWidgetbookDesktopBreakpoint, 840.0);
    });

    test('kPanelAnimationDuration constant is defined', () {
      expect(kPanelAnimationDuration, const Duration(milliseconds: 250));
    });
  });

  group('_collapseDirectories', () {
    testWidgets('collapses WidgetbookFolder nodes', (tester) async {
      final folder = WidgetbookFolder(
        name: 'Test Folder',
        isInitiallyExpanded: true,
        children: [],
      );

      final collapsed = _collapseNode(folder);
      expect(collapsed, isA<WidgetbookFolder>());
      expect((collapsed as WidgetbookFolder).isInitiallyExpanded, isFalse);
    });

    testWidgets('keeps WidgetbookCategory expanded', (tester) async {
      final category = WidgetbookCategory(
        name: 'Test Category',
        children: [],
      );

      final collapsed = _collapseNode(category);
      expect(collapsed, isA<WidgetbookCategory>());
      expect((collapsed as WidgetbookCategory).name, 'Test Category');
    });

    testWidgets('collapses WidgetbookComponent nodes', (tester) async {
      final component = WidgetbookComponent(
        name: 'Test Component',
        isInitiallyExpanded: true,
        useCases: [
          WidgetbookUseCase(
            name: 'Test Use Case',
            builder: (context) => const SizedBox(),
          ),
        ],
      );

      final collapsed = _collapseNode(component);
      expect(collapsed, isA<WidgetbookComponent>());
      expect((collapsed as WidgetbookComponent).isInitiallyExpanded, isFalse);
    });

    testWidgets('preserves use cases when collapsing component', (tester) async {
      final component = WidgetbookComponent(
        name: 'Test Component',
        isInitiallyExpanded: true,
        useCases: [
          WidgetbookUseCase(
            name: 'Use Case 1',
            builder: (context) => const SizedBox(),
          ),
          WidgetbookUseCase(
            name: 'Use Case 2',
            builder: (context) => const SizedBox(),
          ),
        ],
      );

      final collapsed = _collapseNode(component);
      expect((collapsed as WidgetbookComponent).useCases.length, 2);
    });

    testWidgets('recursively collapses children', (tester) async {
      final category = WidgetbookCategory(
        name: 'Test Category',
        children: [
          WidgetbookFolder(
            name: 'Nested Folder',
            isInitiallyExpanded: true,
            children: [],
          ),
        ],
      );

      final collapsed = _collapseNode(category);
      final nestedFolder = (collapsed as WidgetbookCategory).children!.first as WidgetbookFolder;
      expect(nestedFolder.isInitiallyExpanded, isFalse);
    });

    testWidgets('handles empty children', (tester) async {
      final folder = WidgetbookFolder(
        name: 'Empty Folder',
        isInitiallyExpanded: true,
        children: [],
      );

      final collapsed = _collapseNode(folder);
      expect((collapsed as WidgetbookFolder).children, isEmpty);
    });

    testWidgets('preserves node names', (tester) async {
      final nodes = [
        WidgetbookFolder(name: 'Folder', isInitiallyExpanded: true, children: []),
        WidgetbookCategory(name: 'Category', children: []),
        WidgetbookComponent(
          name: 'Component',
          isInitiallyExpanded: true,
          useCases: [],
        ),
      ];

      for (final node in nodes) {
        final collapsed = _collapseNode(node);
        expect(collapsed.name, node.name);
      }
    });
  });
}