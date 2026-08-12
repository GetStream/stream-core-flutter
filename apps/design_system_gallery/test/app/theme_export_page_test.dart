import 'package:design_system_gallery/app/theme_export_page.dart';
import 'package:design_system_gallery/config/theme_configuration.dart';
import 'package:design_system_gallery/widgets/theme_export/message_bubble_preview.dart';
import 'package:design_system_gallery/widgets/theme_studio/color_picker_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// The two [ColorPickerTile]s (light, then dark) for the row labeled [label].
List<ColorPickerTile> _tilesFor(WidgetTester tester, String label) => tester
    .widgetList<ColorPickerTile>(find.byWidgetPredicate((w) => w is ColorPickerTile && w.label == label))
    .toList();

void main() {
  Future<void> pumpAt(WidgetTester tester, ThemeConfiguration studio, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ChangeNotifierProvider<ThemeConfiguration>.value(
        value: studio,
        child: const MaterialApp(home: ThemeExportPage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  // Side-by-side layout only shows above _kTabsBreakpoint (1200); force a
  // wide surface so both settings columns and the code pane are present.
  Future<void> pumpWide(WidgetTester tester, ThemeConfiguration studio) =>
      pumpAt(tester, studio, const Size(1400, 900));

  testWidgets('renders the light/dark settings columns and the code pane', (tester) async {
    final studio = ThemeConfiguration.light();
    addTearDown(studio.dispose);

    await pumpWide(tester, studio);

    expect(find.text('Export Theme'), findsOneWidget);
    expect(find.text('brand'), findsNWidgets(2)); // one per column
    expect(find.text('chrome'), findsNWidgets(2));
    expect(find.text('Dart code'), findsOneWidget);
    // The message preview sits below the settings columns (light + dark),
    // not inside the code pane.
    expect(find.byType(MessageBubblePreview), findsNWidgets(2));
    expect(find.byType(SelectableText), findsOneWidget);
  });

  testWidgets('section headers render once per column, not as a single full-width bar', (tester) async {
    final studio = ThemeConfiguration.light();
    addTearDown(studio.dispose);

    await pumpWide(tester, studio);

    expect(find.text('Accent Colors'), findsNWidgets(2));
    expect(find.text('Text Colors'), findsNWidgets(2));
  });

  testWidgets('scrolling the code block does not throw (Scrollbar needs its own controller)', (tester) async {
    final studio = ThemeConfiguration.light();
    addTearDown(studio.dispose);

    await pumpWide(tester, studio);

    await tester.drag(find.byType(SelectableText), const Offset(0, -100));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('seeds both columns from the studio brand color', (tester) async {
    final studio = ThemeConfiguration.light();
    addTearDown(studio.dispose);
    studio.setBrandPrimaryColor(const Color(0xFF01D151));

    await pumpWide(tester, studio);

    // Both columns should show the customized brand color, not "default".
    final brandTiles = _tilesFor(tester, 'brand');
    expect(brandTiles, hasLength(2));
    expect(brandTiles.every((t) => !t.isDefault), isTrue);

    // dart_style may wrap this call across lines, so match loosely.
    final code = tester.widget<SelectableText>(find.byType(SelectableText)).data!;
    expect(code, matches(RegExp(r'StreamColorSwatch\.fromColor\(\s*brand,\s*brightness:\s*Brightness\.light,?\s*\)')));
    expect(code, matches(RegExp(r'StreamColorSwatch\.fromColor\(\s*brand,\s*brightness:\s*Brightness\.dark,?\s*\)')));
  });

  testWidgets('tapping a link toggle unlinks that row, shown as a link_off icon', (tester) async {
    final studio = ThemeConfiguration.light();
    addTearDown(studio.dispose);

    await pumpWide(tester, studio);

    // brand, chrome and accent* start linked; most other slots don't (see
    // ThemeExportConfiguration) - so both icons are already present before
    // any tap. Tap the first link icon (brand's, since it's first in the
    // list and one of the slots that starts linked) and check the delta.
    final linkedCountBefore = tester.widgetList(find.byIcon(Icons.link)).length;
    final unlinkedCountBefore = tester.widgetList(find.byIcon(Icons.link_off)).length;
    expect(linkedCountBefore, greaterThan(0));

    await tester.tap(find.byIcon(Icons.link).first);
    await tester.pumpAndSettle();

    expect(tester.widgetList(find.byIcon(Icons.link)).length, linkedCountBefore - 1);
    expect(tester.widgetList(find.byIcon(Icons.link_off)).length, unlinkedCountBefore + 1);
  });

  testWidgets('Add component theme is offered on the export page, and adding one shows a row per column', (
    tester,
  ) async {
    final studio = ThemeConfiguration.light();
    addTearDown(studio.dispose);

    await pumpWide(tester, studio);

    // "Add component theme" is the last row, well below the ~51 color rows
    // above it in this lazily-built list - scroll it into view first.
    await tester.dragUntilVisible(
      find.text('Add component theme'),
      find.byType(CustomScrollView),
      const Offset(0, -500),
    );
    await tester.tap(find.text('Add component theme'));
    await tester.pumpAndSettle();

    // Avatar isn't offered - its color story is the Avatar Palette section.
    expect(find.text('Avatar'), findsNothing);
    expect(find.textContaining('Online Indicator'), findsOneWidget);

    await tester.tap(find.textContaining('Online Indicator'));
    await tester.pumpAndSettle();

    // The new section was inserted just above "Add component theme" -
    // ensure it's actually scrolled into view before asserting on it.
    await tester.dragUntilVisible(
      find.text('Remove component theme'),
      find.byType(CustomScrollView),
      const Offset(0, -300),
    );

    expect(find.text('Online Indicator'), findsNWidgets(2)); // one section header per column
    expect(_tilesFor(tester, 'backgroundOnline'), hasLength(2));
    expect(find.text('Remove component theme'), findsOneWidget);

    // Removing it drops the section and re-offers it in the picker.
    await tester.tap(find.text('Remove component theme'));
    await tester.pumpAndSettle();

    expect(find.text('Online Indicator'), findsNothing);
    expect(_tilesFor(tester, 'backgroundOnline'), isEmpty);
  });

  testWidgets("editing an unlinked slot's light side leaves the dark side untouched", (tester) async {
    final studio = ThemeConfiguration.light();
    addTearDown(studio.dispose);

    await pumpWide(tester, studio);

    final beforeTiles = _tilesFor(tester, 'brand');
    expect(beforeTiles, hasLength(2));
    expect(beforeTiles.every((t) => t.isDefault), isTrue);

    // Unlink brand's row (the first link toggle in the list).
    await tester.tap(find.byIcon(Icons.link).first);
    await tester.pumpAndSettle();

    // Open the light column's brand picker and apply.
    await tester.tap(find.text('brand').first);
    await tester.pumpAndSettle();
    expect(find.text('Apply'), findsOneWidget);
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    final afterTiles = _tilesFor(tester, 'brand');
    expect(afterTiles[0].isDefault, isFalse, reason: 'light side was edited');
    expect(afterTiles[1].isDefault, isTrue, reason: 'dark side is untouched while unlinked');
  });

  testWidgets('below the side-by-side breakpoint, settings and code collapse into two tabs', (tester) async {
    final studio = ThemeConfiguration.light();
    addTearDown(studio.dispose);

    // Below _kTabsBreakpoint (1200) - too narrow for fixed-width settings
    // columns plus a code pane that's still wide enough to be useful.
    await pumpAt(tester, studio, const Size(900, 900));

    expect(find.byType(TabBar), findsOneWidget);
    expect(find.text('Theme Settings'), findsOneWidget);
    expect(find.text('Dart Code'), findsOneWidget);

    // The Theme Settings tab is active first - settings render, code doesn't.
    expect(find.text('brand'), findsNWidgets(2));
    expect(find.text('Dart code'), findsNothing);

    await tester.tap(find.text('Dart Code'));
    await tester.pumpAndSettle();

    expect(find.text('Dart code'), findsOneWidget);
    expect(find.text('brand'), findsNothing);
  });

  testWidgets('at or above the breakpoint, settings and code render side by side with no tabs', (tester) async {
    final studio = ThemeConfiguration.light();
    addTearDown(studio.dispose);

    await pumpAt(tester, studio, const Size(1200, 900));

    expect(find.byType(TabBar), findsNothing);
    expect(find.text('brand'), findsNWidgets(2));
    expect(find.text('Dart code'), findsOneWidget);
  });
}
