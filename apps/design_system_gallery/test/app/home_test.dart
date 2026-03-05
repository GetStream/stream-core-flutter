import 'package:design_system_gallery/app/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';

void main() {
  group('GalleryHomePage', () {
    Widget createTestableWidget() {
      return MaterialApp(
        theme: ThemeData(extensions: [StreamTheme()]),
        home: const GalleryHomePage(),
      );
    }

    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(createTestableWidget());
      expect(find.byType(GalleryHomePage), findsOneWidget);
    });

    testWidgets('displays correct title', (tester) async {
      await tester.pumpWidget(createTestableWidget());
      expect(find.text('Stream Design System'), findsOneWidget);
    });

    testWidgets('displays correct subtitle', (tester) async {
      await tester.pumpWidget(createTestableWidget());
      expect(
        find.text(
          'A comprehensive design system for building beautiful, '
          'consistent chat and activity feed experiences.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('displays Stream logo', (tester) async {
      await tester.pumpWidget(createTestableWidget());
      expect(find.byType(_StreamLogo), findsOneWidget);
    });

    testWidgets('displays feature chips', (tester) async {
      await tester.pumpWidget(createTestableWidget());
      expect(find.byType(_FeatureChips), findsOneWidget);
    });

    testWidgets('displays getting started hint', (tester) async {
      await tester.pumpWidget(createTestableWidget());
      expect(find.byType(_GettingStartedHint), findsOneWidget);
    });

    testWidgets('uses ColoredBox as background', (tester) async {
      await tester.pumpWidget(createTestableWidget());
      expect(find.byType(ColoredBox), findsAtLeastNWidgets(1));
    });

    testWidgets('uses Center for layout', (tester) async {
      await tester.pumpWidget(createTestableWidget());
      expect(find.byType(Center), findsOneWidget);
    });

    testWidgets('uses SingleChildScrollView for scrolling', (tester) async {
      await tester.pumpWidget(createTestableWidget());
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('has constrained width', (tester) async {
      await tester.pumpWidget(createTestableWidget());
      final constrainedBox = tester.widget<ConstrainedBox>(
        find.ancestor(
          of: find.byType(Column),
          matching: find.byType(ConstrainedBox),
        ).first,
      );
      expect(constrainedBox.constraints.maxWidth, 560);
    });

    testWidgets('main column has correct alignment', (tester) async {
      await tester.pumpWidget(createTestableWidget());
      final column = tester.widget<Column>(
        find.descendant(
          of: find.byType(ConstrainedBox),
          matching: find.byType(Column),
        ).first,
      );
      expect(column.mainAxisAlignment, MainAxisAlignment.center);
    });
  });

  group('_StreamLogo', () {
    Widget createTestableWidget() {
      return MaterialApp(
        theme: ThemeData(extensions: [StreamTheme()]),
        home: const Scaffold(body: _StreamLogo()),
      );
    }

    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(createTestableWidget());
      expect(find.byType(_StreamLogo), findsOneWidget);
    });

    testWidgets('uses SvgIcon', (tester) async {
      await tester.pumpWidget(createTestableWidget());
      expect(find.byType(SvgIcon), findsOneWidget);
    });

    testWidgets('has correct size', (tester) async {
      await tester.pumpWidget(createTestableWidget());
      final svgIcon = tester.widget<SvgIcon>(find.byType(SvgIcon));
      expect(svgIcon.size, 80);
    });
  });

  group('_FeatureChips', () {
    Widget createTestableWidget() {
      return MaterialApp(
        theme: ThemeData(extensions: [StreamTheme()]),
        home: const Scaffold(body: _FeatureChips()),
      );
    }

    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(createTestableWidget());
      expect(find.byType(_FeatureChips), findsOneWidget);
    });

    testWidgets('uses Wrap for layout', (tester) async {
      await tester.pumpWidget(createTestableWidget());
      expect(find.byType(Wrap), findsOneWidget);
    });

    testWidgets('Wrap has center alignment', (tester) async {
      await tester.pumpWidget(createTestableWidget());
      final wrap = tester.widget<Wrap>(find.byType(Wrap));
      expect(wrap.alignment, WrapAlignment.center);
    });

    testWidgets('displays all feature chips', (tester) async {
      await tester.pumpWidget(createTestableWidget());
      expect(find.byType(_FeatureChip), findsNWidgets(4));
    });

    testWidgets('displays Themeable chip', (tester) async {
      await tester.pumpWidget(createTestableWidget());
      expect(find.text('Themeable'), findsOneWidget);
    });

    testWidgets('displays Dark Mode chip', (tester) async {
      await tester.pumpWidget(createTestableWidget());
      expect(find.text('Dark Mode'), findsOneWidget);
    });

    testWidgets('displays Responsive chip', (tester) async {
      await tester.pumpWidget(createTestableWidget());
      expect(find.text('Responsive'), findsOneWidget);
    });

    testWidgets('displays Accessible chip', (tester) async {
      await tester.pumpWidget(createTestableWidget());
      expect(find.text('Accessible'), findsOneWidget);
    });
  });

  group('_FeatureChip', () {
    Widget createTestableWidget({
      required IconData icon,
      required String label,
    }) {
      return MaterialApp(
        theme: ThemeData(extensions: [StreamTheme()]),
        home: Scaffold(
          body: _FeatureChip(icon: icon, label: label),
        ),
      );
    }

    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(createTestableWidget(
        icon: Icons.palette_outlined,
        label: 'Test',
      ));
      expect(find.byType(_FeatureChip), findsOneWidget);
    });

    testWidgets('displays icon', (tester) async {
      await tester.pumpWidget(createTestableWidget(
        icon: Icons.palette_outlined,
        label: 'Test',
      ));
      expect(find.byIcon(Icons.palette_outlined), findsOneWidget);
    });

    testWidgets('displays label', (tester) async {
      await tester.pumpWidget(createTestableWidget(
        icon: Icons.palette_outlined,
        label: 'Test Label',
      ));
      expect(find.text('Test Label'), findsOneWidget);
    });

    testWidgets('uses Container with decoration', (tester) async {
      await tester.pumpWidget(createTestableWidget(
        icon: Icons.palette_outlined,
        label: 'Test',
      ));
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(_FeatureChip),
          matching: find.byType(Container),
        ),
      );
      expect(container.decoration, isA<BoxDecoration>());
    });

    testWidgets('uses Row for layout', (tester) async {
      await tester.pumpWidget(createTestableWidget(
        icon: Icons.palette_outlined,
        label: 'Test',
      ));
      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('Row has min size', (tester) async {
      await tester.pumpWidget(createTestableWidget(
        icon: Icons.palette_outlined,
        label: 'Test',
      ));
      final row = tester.widget<Row>(find.byType(Row));
      expect(row.mainAxisSize, MainAxisSize.min);
    });

    testWidgets('icon has correct size', (tester) async {
      await tester.pumpWidget(createTestableWidget(
        icon: Icons.palette_outlined,
        label: 'Test',
      ));
      final icon = tester.widget<Icon>(find.byIcon(Icons.palette_outlined));
      expect(icon.size, 16);
    });
  });

  group('_GettingStartedHint', () {
    Widget createTestableWidget() {
      return MaterialApp(
        theme: ThemeData(extensions: [StreamTheme()]),
        home: const Scaffold(body: _GettingStartedHint()),
      );
    }

    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(createTestableWidget());
      expect(find.byType(_GettingStartedHint), findsOneWidget);
    });

    testWidgets('displays hint text', (tester) async {
      await tester.pumpWidget(createTestableWidget());
      expect(
        find.text('Select a component from the sidebar to get started'),
        findsOneWidget,
      );
    });

    testWidgets('displays arrow icon', (tester) async {
      await tester.pumpWidget(createTestableWidget());
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('uses Container with decoration', (tester) async {
      await tester.pumpWidget(createTestableWidget());
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(_GettingStartedHint),
          matching: find.byType(Container),
        ),
      );
      expect(container.decoration, isA<BoxDecoration>());
    });

    testWidgets('uses Row for layout', (tester) async {
      await tester.pumpWidget(createTestableWidget());
      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('Row has min size', (tester) async {
      await tester.pumpWidget(createTestableWidget());
      final row = tester.widget<Row>(find.byType(Row));
      expect(row.mainAxisSize, MainAxisSize.min);
    });

    testWidgets('text is flexible', (tester) async {
      await tester.pumpWidget(createTestableWidget());
      expect(find.byType(Flexible), findsOneWidget);
    });

    testWidgets('icon has correct size', (tester) async {
      await tester.pumpWidget(createTestableWidget());
      final icon = tester.widget<Icon>(find.byIcon(Icons.arrow_back));
      expect(icon.size, 18);
    });
  });
}