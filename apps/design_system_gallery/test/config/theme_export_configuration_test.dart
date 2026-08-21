import 'package:design_system_gallery/config/theme_color_slot.dart';
import 'package:design_system_gallery/config/theme_configuration.dart';
import 'package:design_system_gallery/config/theme_export_configuration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ThemeExportConfiguration', () {
    late ThemeConfiguration studio;

    setUp(() {
      studio = ThemeConfiguration.light();
    });

    tearDown(() {
      studio.dispose();
    });

    test('seeds light and dark from the studio overrides and brand seed', () {
      studio.setOverride(ThemeColorSlot.accentError, const Color(0xFF112233));
      studio.setBrandPrimaryColor(const Color(0xFF01D151));

      final export = ThemeExportConfiguration(studio);
      addTearDown(export.dispose);

      expect(export.light.resolve(ThemeColorSlot.accentError), const Color(0xFF112233));
      expect(export.dark.resolve(ThemeColorSlot.accentError), const Color(0xFF112233));
      expect(export.light.brandPrimaryColor, const Color(0xFF01D151));
      expect(export.dark.brandPrimaryColor, const Color(0xFF01D151));
      expect(export.light.brightness, Brightness.light);
      expect(export.dark.brightness, Brightness.dark);
    });

    test('never writes back to the studio configuration it was seeded from', () {
      final export = ThemeExportConfiguration(studio);
      addTearDown(export.dispose);

      export.setColor(ThemeColorSlot.accentError, const Color(0xFF445566), from: Brightness.light);

      expect(studio.isCustom(ThemeColorSlot.accentError), isFalse);
    });

    test('an accent* slot starts linked: editing one side edits both', () {
      final export = ThemeExportConfiguration(studio);
      addTearDown(export.dispose);

      expect(export.isSlotLinked(ThemeColorSlot.accentError), isTrue);

      export.setColor(ThemeColorSlot.accentError, const Color(0xFF445566), from: Brightness.light);

      expect(export.light.resolve(ThemeColorSlot.accentError), const Color(0xFF445566));
      expect(export.dark.resolve(ThemeColorSlot.accentError), const Color(0xFF445566));
    });

    test('a non-accent slot starts unlinked: editing one side leaves the other untouched', () {
      // textPrimary (like most text*/background*/border*/system* slots) is
      // typically inverted between light and dark, so linking it by default
      // would mean the very first edit overwrites the other side with a
      // value that's wrong for it.
      final export = ThemeExportConfiguration(studio);
      addTearDown(export.dispose);

      expect(export.isSlotLinked(ThemeColorSlot.textPrimary), isFalse);

      export.setColor(ThemeColorSlot.textPrimary, const Color(0xFF445566), from: Brightness.light);

      expect(export.light.resolve(ThemeColorSlot.textPrimary), const Color(0xFF445566));
      expect(export.dark.isCustom(ThemeColorSlot.textPrimary), isFalse);
    });

    test('brand and chrome seeds start linked', () {
      final export = ThemeExportConfiguration(studio);
      addTearDown(export.dispose);

      expect(export.isSeedLinked(ThemeSeedSlot.brand), isTrue);
      expect(export.isSeedLinked(ThemeSeedSlot.chrome), isTrue);
    });

    test('a component color starts unlinked: editing one side leaves the other untouched', () {
      final export = ThemeExportConfiguration(studio);
      addTearDown(export.dispose);
      export.addComponentTheme('Online Indicator');

      expect(export.isComponentColorLinked('Online Indicator', 'backgroundOnline'), isFalse);

      export.setComponentColor(
        'Online Indicator',
        'backgroundOnline',
        const Color(0xFF445566),
        from: Brightness.light,
      );

      expect(export.light.resolveComponentColor('Online Indicator', 'backgroundOnline'), const Color(0xFF445566));
      expect(export.dark.isComponentColorCustom('Online Indicator', 'backgroundOnline'), isFalse);
    });

    test('unlinking a slot makes edits independent', () {
      final export = ThemeExportConfiguration(studio);
      addTearDown(export.dispose);

      export.toggleSlotLinked(ThemeColorSlot.accentError);
      expect(export.isSlotLinked(ThemeColorSlot.accentError), isFalse);

      export.setColor(ThemeColorSlot.accentError, const Color(0xFF445566), from: Brightness.light);
      export.setColor(ThemeColorSlot.accentError, const Color(0xFF667788), from: Brightness.dark);

      expect(export.light.resolve(ThemeColorSlot.accentError), const Color(0xFF445566));
      expect(export.dark.resolve(ThemeColorSlot.accentError), const Color(0xFF667788));
    });

    test('relinking does not force light/dark back in sync until the next edit', () {
      final export = ThemeExportConfiguration(studio);
      addTearDown(export.dispose);

      export.toggleSlotLinked(ThemeColorSlot.accentError);
      export.setColor(ThemeColorSlot.accentError, const Color(0xFF445566), from: Brightness.light);
      export.setColor(ThemeColorSlot.accentError, const Color(0xFF667788), from: Brightness.dark);

      export.toggleSlotLinked(ThemeColorSlot.accentError);
      expect(export.isSlotLinked(ThemeColorSlot.accentError), isTrue);
      // Still diverged immediately after relinking.
      expect(export.light.resolve(ThemeColorSlot.accentError), const Color(0xFF445566));
      expect(export.dark.resolve(ThemeColorSlot.accentError), const Color(0xFF667788));

      // The next edit, from either side, applies to both again.
      export.setColor(ThemeColorSlot.accentError, const Color(0xFF999999), from: Brightness.dark);
      expect(export.light.resolve(ThemeColorSlot.accentError), const Color(0xFF999999));
      expect(export.dark.resolve(ThemeColorSlot.accentError), const Color(0xFF999999));
    });

    test('resetColor respects link state the same way as setColor', () {
      final export = ThemeExportConfiguration(studio);
      addTearDown(export.dispose);

      export.toggleSlotLinked(ThemeColorSlot.accentError);
      export.setColor(ThemeColorSlot.accentError, const Color(0xFF445566), from: Brightness.light);
      export.setColor(ThemeColorSlot.accentError, const Color(0xFF667788), from: Brightness.dark);

      export.resetColor(ThemeColorSlot.accentError, from: Brightness.light);

      expect(export.light.isCustom(ThemeColorSlot.accentError), isFalse);
      expect(export.dark.isCustom(ThemeColorSlot.accentError), isTrue);
    });

    test('brand/chrome seeds follow the same link semantics via setSeed/resetSeed', () {
      final export = ThemeExportConfiguration(studio);
      addTearDown(export.dispose);

      export.toggleSeedLinked(ThemeSeedSlot.brand);
      export.setSeed(ThemeSeedSlot.brand, const Color(0xFF01D151), from: Brightness.light);

      expect(export.light.brandIsCustom, isTrue);
      expect(export.dark.brandIsCustom, isFalse);

      export.resetSeed(ThemeSeedSlot.brand, from: Brightness.light);
      expect(export.light.brandIsCustom, isFalse);
    });

    test('cached Material themes are stable across reads and invalidated on change', () {
      final export = ThemeExportConfiguration(studio);
      addTearDown(export.dispose);

      final first = export.lightMaterialTheme;
      expect(identical(export.lightMaterialTheme, first), isTrue);

      export.setColor(ThemeColorSlot.accentError, const Color(0xFF445566), from: Brightness.light);

      expect(identical(export.lightMaterialTheme, first), isFalse);
    });

    test('generateCode reflects the current, possibly-diverged light/dark overrides', () {
      final export = ThemeExportConfiguration(studio);
      addTearDown(export.dispose);

      export.toggleSlotLinked(ThemeColorSlot.accentError);
      export.setColor(ThemeColorSlot.accentError, const Color(0xFFF98C26), from: Brightness.light);
      export.setColor(ThemeColorSlot.accentError, const Color(0xFFF6AB64), from: Brightness.dark);

      final code = export.generateCode();

      expect(code, contains('const accentErrorLight = Color.fromARGB(255, 249, 140, 38);'));
      expect(code, contains('const accentErrorDark = Color.fromARGB(255, 246, 171, 100);'));
    });

    test('dispose cleans up both child configurations', () {
      final export = ThemeExportConfiguration(studio);

      export.dispose();

      // Both children should be disposed too - further use throws.
      expect(() => export.light.addListener(() {}), throwsFlutterError);
      expect(() => export.dark.addListener(() {}), throwsFlutterError);
    });
  });
}
