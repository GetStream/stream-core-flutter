import 'package:design_system_gallery/widgets/theme_studio/color_picker_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

void main() {
  Future<void> pumpAt(WidgetTester tester, Widget child, double width) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: [StreamTheme.light()]),
        home: Scaffold(
          body: SizedBox(width: width, child: child),
        ),
      ),
    );
  }

  Future<void> pump(WidgetTester tester, Widget child) => pumpAt(tester, child, 400);

  testWidgets('a null color renders a neutral placeholder and the text "default", not a hex code', (tester) async {
    await pump(
      tester,
      ColorPickerTile(label: 'backgroundOnline', color: null, isDefault: true, onColorChanged: (_) {}),
    );

    expect(find.text('default'), findsOneWidget);
    expect(find.byIcon(Icons.help_outline), findsOneWidget);
    expect(find.textContaining('#'), findsNothing);
  });

  testWidgets('a real, customized color renders its hex value, with the "default" caption hidden', (tester) async {
    await pump(
      tester,
      ColorPickerTile(
        label: 'accentError',
        color: const Color(0xFFAABBCC),
        onColorChanged: (_) {},
      ),
    );

    expect(find.text('#AABBCC'), findsOneWidget);
    // The "default" caption is always laid out (so a default tile and a
    // customized tile for the same slot are the same height), but it's
    // transparent - not visible - when the color isn't the default.
    final defaultCaption = tester.widget<Text>(find.text('default'));
    expect(defaultCaption.style?.color, StreamColors.transparent);
  });

  testWidgets('a default tile and a customized tile of the same slot are the same height', (tester) async {
    final defaultKey = GlobalKey();
    final customKey = GlobalKey();

    await pump(
      tester,
      Column(
        children: [
          ColorPickerTile(
            key: defaultKey,
            label: 'accentError',
            color: const Color(0xFFAABBCC),
            isDefault: true,
            onColorChanged: (_) {},
          ),
          ColorPickerTile(
            key: customKey,
            label: 'accentError',
            color: const Color(0xFF112233),
            onColorChanged: (_) {},
          ),
        ],
      ),
    );

    expect(tester.getSize(find.byKey(defaultKey)).height, tester.getSize(find.byKey(customKey)).height);
  });

  testWidgets('a long label is ellipsized rather than overflowing the row', (tester) async {
    // This is the exact failure mode the fix addresses: a long component
    // property name combined with the "default" badge used to overflow the
    // row (RenderFlex overflowed), not merely wrap awkwardly.
    await pump(
      tester,
      ColorPickerTile(
        label: 'aVeryLongComponentThemePropertyNameThatWouldNotFit',
        color: null,
        isDefault: true,
        onColorChanged: (_) {},
      ),
    );

    expect(tester.takeException(), isNull);
    final text = tester.widget<Text>(find.text('aVeryLongComponentThemePropertyNameThatWouldNotFit'));
    expect(text.maxLines, 1);
    expect(text.overflow, TextOverflow.ellipsis);
  });

  testWidgets('compact: false - the hex value sits beside the label/default column, not below it', (tester) async {
    await pumpAt(
      tester,
      ColorPickerTile(label: 'accentError', color: const Color(0xFFAABBCC), onColorChanged: (_) {}),
      300,
    );

    // The "default" caption is the second (bottom) line of the label
    // column - in the inline layout the hex value is a sibling of that
    // whole column, vertically centered against it, so it sits above the
    // caption's own line. In the stacked layout, checked below, hex is a
    // third line *underneath* the caption instead.
    final defaultCaptionTop = tester.getTopLeft(find.text('default')).dy;
    final hexTop = tester.getTopLeft(find.text('#AABBCC')).dy;

    expect(hexTop, lessThan(defaultCaptionTop));
    expect(tester.takeException(), isNull);
  });

  testWidgets('compact: true - the hex value moves below the label instead of squeezing beside it', (tester) async {
    await pumpAt(
      tester,
      ColorPickerTile(label: 'accentError', color: const Color(0xFFAABBCC), onColorChanged: (_) {}, compact: true),
      180,
    );

    final defaultCaptionTop = tester.getTopLeft(find.text('default')).dy;
    final hexTop = tester.getTopLeft(find.text('#AABBCC')).dy;

    expect(hexTop, greaterThan(defaultCaptionTop));
    expect(tester.takeException(), isNull);
  });

  testWidgets('compact: true - the hex value never overflows, even with a reset icon at an extreme width', (
    tester,
  ) async {
    // The stacked row (hex + reset + edit icons) can itself run out of room
    // at extreme widths - this is what forced the hex Text into a Flexible.
    await pumpAt(
      tester,
      ColorPickerTile(
        label: 'accentError',
        color: const Color(0xFFAABBCC),
        onColorChanged: (_) {},
        onReset: () {},
        compact: true,
      ),
      180,
    );

    expect(find.byIcon(Icons.restart_alt), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('compact: true - a default tile and a customized tile of the same slot are still the same height', (
    tester,
  ) async {
    final defaultKey = GlobalKey();
    final customKey = GlobalKey();

    await pumpAt(
      tester,
      Column(
        children: [
          ColorPickerTile(
            key: defaultKey,
            label: 'accentError',
            color: const Color(0xFFAABBCC),
            isDefault: true,
            onColorChanged: (_) {},
            compact: true,
          ),
          ColorPickerTile(
            key: customKey,
            label: 'accentError',
            color: const Color(0xFF112233),
            onColorChanged: (_) {},
            compact: true,
          ),
        ],
      ),
      180,
    );

    expect(tester.getSize(find.byKey(defaultKey)).height, tester.getSize(find.byKey(customKey)).height);
  });

  // The tile is one tappable InkWell, so its rows merge into a single
  // semantics node whose label concatenates them (e.g.
  // "accentError\ndefault\n#AABBCC"). Hence a RegExp: matching by exact
  // String would never hit an individual row's text.
  testWidgets('a customized tile does not announce "default" to a screen reader', (tester) async {
    // Disposed inline rather than via addTearDown: the binding's
    // "SemanticsHandle was active at the end of the test" check runs before
    // addTearDown callbacks do.
    final handle = tester.ensureSemantics();

    await pump(
      tester,
      ColorPickerTile(label: 'accentError', color: const Color(0xFFAABBCC), onColorChanged: (_) {}),
    );

    // The caption stays in the widget tree (it reserves height so default
    // and customized tiles align), but must be out of the semantics tree.
    expect(find.text('default'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('default')), findsNothing);
    // The rest of the tile is still announced.
    expect(find.bySemanticsLabel(RegExp('accentError')), findsOneWidget);

    handle.dispose();
  });

  testWidgets('a default tile does announce "default"', (tester) async {
    final handle = tester.ensureSemantics();

    await pump(
      tester,
      ColorPickerTile(label: 'accentError', color: const Color(0xFFAABBCC), isDefault: true, onColorChanged: (_) {}),
    );

    expect(find.bySemanticsLabel(RegExp('default')), findsOneWidget);

    handle.dispose();
  });

  group('isColorPickerTileCompact', () {
    const spacing = StreamSpacing();

    test('a wide outer width does not need the stacked layout', () {
      expect(isColorPickerTileCompact(350, spacing), isFalse);
    });

    test('a narrow outer width needs the stacked layout', () {
      expect(isColorPickerTileCompact(200, spacing), isTrue);
    });
  });
}
