import 'package:design_system_gallery/app/gallery_app.dart';
import 'package:design_system_gallery/config/preview_configuration.dart';
import 'package:design_system_gallery/config/theme_configuration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  group('StreamDesignSystemGallery', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(const StreamDesignSystemGallery());
      expect(find.byType(StreamDesignSystemGallery), findsOneWidget);
    });

    testWidgets('creates stateful widget', (tester) async {
      await tester.pumpWidget(const StreamDesignSystemGallery());
      final state = tester.state<State<StreamDesignSystemGallery>>(
        find.byType(StreamDesignSystemGallery),
      );
      expect(state, isNotNull);
    });

    testWidgets('provides ThemeConfiguration', (tester) async {
      await tester.pumpWidget(const StreamDesignSystemGallery());
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(MaterialApp));
      final themeConfig = Provider.of<ThemeConfiguration>(context, listen: false);
      expect(themeConfig, isNotNull);
    });

    testWidgets('provides PreviewConfiguration', (tester) async {
      await tester.pumpWidget(const StreamDesignSystemGallery());
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(MaterialApp));
      final previewConfig = Provider.of<PreviewConfiguration>(context, listen: false);
      expect(previewConfig, isNotNull);
    });

    testWidgets('creates MaterialApp', (tester) async {
      await tester.pumpWidget(const StreamDesignSystemGallery());
      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('MaterialApp has correct title', (tester) async {
      await tester.pumpWidget(const StreamDesignSystemGallery());
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.title, 'Stream Design System');
    });

    testWidgets('MaterialApp has debugShowCheckedModeBanner disabled', (tester) async {
      await tester.pumpWidget(const StreamDesignSystemGallery());
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.debugShowCheckedModeBanner, isFalse);
    });

    testWidgets('disposes configurations on unmount', (tester) async {
      await tester.pumpWidget(const StreamDesignSystemGallery());
      await tester.pumpAndSettle();

      // Pump a different widget to trigger dispose
      await tester.pumpWidget(const SizedBox());

      // If we get here without errors, dispose worked correctly
      expect(find.byType(StreamDesignSystemGallery), findsNothing);
    });

    testWidgets('initializes with light theme by default', (tester) async {
      await tester.pumpWidget(const StreamDesignSystemGallery());
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(MaterialApp));
      final themeConfig = Provider.of<ThemeConfiguration>(context, listen: false);
      expect(themeConfig.brightness, Brightness.light);
    });

    testWidgets('can toggle theme panel', (tester) async {
      await tester.pumpWidget(const StreamDesignSystemGallery());
      await tester.pumpAndSettle();

      // Verify initial state (should be shown by default)
      final stateBefore = tester.state(find.byType(StreamDesignSystemGallery))
          as dynamic;
      expect(stateBefore.showThemePanel, isTrue);
    });

    testWidgets('MultiProvider wraps Consumer', (tester) async {
      await tester.pumpWidget(const StreamDesignSystemGallery());
      await tester.pumpAndSettle();

      expect(find.byType(MultiProvider), findsOneWidget);
      expect(find.byType(Consumer<ThemeConfiguration>), findsOneWidget);
    });

    testWidgets('handles theme changes', (tester) async {
      await tester.pumpWidget(const StreamDesignSystemGallery());
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(MaterialApp));
      final themeConfig = Provider.of<ThemeConfiguration>(context, listen: false);

      // Change to dark theme
      themeConfig.brightness = Brightness.dark;
      await tester.pumpAndSettle();

      expect(themeConfig.brightness, Brightness.dark);
    });

    testWidgets('builds theme correctly', (tester) async {
      await tester.pumpWidget(const StreamDesignSystemGallery());
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme, isNotNull);
      expect(materialApp.darkTheme, isNotNull);
    });

    testWidgets('sets correct theme mode for light theme', (tester) async {
      await tester.pumpWidget(const StreamDesignSystemGallery());
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(MaterialApp));
      final themeConfig = Provider.of<ThemeConfiguration>(context, listen: false);
      themeConfig.brightness = Brightness.light;
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.themeMode, ThemeMode.light);
    });

    testWidgets('sets correct theme mode for dark theme', (tester) async {
      await tester.pumpWidget(const StreamDesignSystemGallery());
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(MaterialApp));
      final themeConfig = Provider.of<ThemeConfiguration>(context, listen: false);
      themeConfig.brightness = Brightness.dark;
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.themeMode, ThemeMode.dark);
    });
  });
}