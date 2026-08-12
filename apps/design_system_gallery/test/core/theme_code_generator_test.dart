import 'package:dart_style/dart_style.dart';
import 'package:design_system_gallery/config/theme_color_slot.dart';
import 'package:design_system_gallery/core/theme_code_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

/// Matches a `name(arg1, arg2, ...)` call regardless of how `dart_style`
/// wraps it across lines or whether it adds a trailing comma.
Matcher _callMatching(String name, List<String> args) {
  final argsPattern = args.map(RegExp.escape).join(r',\s*');
  return matches(RegExp('$name\\(\\s*$argsPattern,?\\s*\\)'));
}

void main() {
  group('generateThemeCode', () {
    test('nothing set emits bare StreamColorScheme calls and no consts', () {
      final code = generateThemeCode(light: const ThemeExportSide(), dark: const ThemeExportSide());

      expect(code, isNot(contains('const ')));
      expect(code, contains('StreamColorScheme.light()'));
      expect(code, contains('StreamColorScheme.dark()'));
      expect(code, contains('Brightness.light'));
      expect(code, contains('Brightness.dark'));
    });

    test('assigns each StreamTheme to a named variable, referenced (not inlined) in extensions', () {
      final code = generateThemeCode(light: const ThemeExportSide(), dark: const ThemeExportSide());

      expect(code, contains('final lightStreamTheme = StreamTheme('));
      expect(code, contains('final darkStreamTheme = StreamTheme('));
      // The lightStreamTheme/darkStreamTheme assignments come before
      // MaterialApp, so the Stream-specific part can be copied on its own.
      expect(code.indexOf('lightStreamTheme ='), lessThan(code.indexOf('MaterialApp(')));
      expect(code.indexOf('darkStreamTheme ='), lessThan(code.indexOf('MaterialApp(')));
      expect(code, contains('extensions: [lightStreamTheme]'));
      expect(code, contains('extensions: [darkStreamTheme]'));
    });

    test('a slot set to the same color on both sides becomes a single shared const', () {
      const color = Color(0xFFAABBCC);
      final code = generateThemeCode(
        light: const ThemeExportSide(overrides: {ThemeColorSlot.accentError: color}),
        dark: const ThemeExportSide(overrides: {ThemeColorSlot.accentError: color}),
      );

      expect('const accentError ='.allMatches(code).length, 1);
      expect(code, contains('accentError: accentError'));
      expect(code, isNot(contains('accentErrorLight')));
      expect(code, isNot(contains('accentErrorDark')));
    });

    test('a slot set to different colors on each side becomes two suffixed consts', () {
      final code = generateThemeCode(
        light: const ThemeExportSide(overrides: {ThemeColorSlot.accentError: Color(0xFFF98C26)}),
        dark: const ThemeExportSide(overrides: {ThemeColorSlot.accentError: Color(0xFFF6AB64)}),
      );

      expect(code, contains('const accentErrorLight = Color.fromARGB(255, 249, 140, 38);'));
      expect(code, contains('const accentErrorDark = Color.fromARGB(255, 246, 171, 100);'));
      expect(code, contains('accentError: accentErrorLight'));
      expect(code, contains('accentError: accentErrorDark'));
    });

    test('a slot set on only one side is emitted for that side only', () {
      final code = generateThemeCode(
        light: const ThemeExportSide(overrides: {ThemeColorSlot.borderFocus: Color(0xFF112233)}),
        dark: const ThemeExportSide(),
      );

      expect(code, contains('const borderFocusLight = Color.fromARGB(255, 17, 34, 51);'));
      expect(code, contains('borderFocus: borderFocusLight'));
      expect(code, isNot(contains('borderFocusDark')));

      final darkSchemeSpan = code.substring(code.indexOf('StreamColorScheme.dark('));
      expect(darkSchemeSpan, isNot(contains('borderFocus')));
    });

    test('brand-only customization derives chrome from brand at neutral chroma, on both sides', () {
      const brand = Color(0xFF01D151);
      final code = generateThemeCode(
        light: const ThemeExportSide(brandSeed: brand),
        dark: const ThemeExportSide(brandSeed: brand),
      );

      expect('const brand ='.allMatches(code).length, 1);
      expect(code, _callMatching('brand: StreamColorSwatch.fromColor', ['brand', 'brightness: Brightness.light']));
      expect(code, _callMatching('brand: StreamColorSwatch.fromColor', ['brand', 'brightness: Brightness.dark']));
      expect(
        code,
        _callMatching('chrome: StreamColorSwatch.fromColor', [
          'brand',
          'brightness: Brightness.light',
          'chroma: StreamColorScheme.neutralChroma',
        ]),
      );
      expect(
        code,
        _callMatching('chrome: StreamColorSwatch.fromColor', [
          'brand',
          'brightness: Brightness.dark',
          'chroma: StreamColorScheme.neutralChroma',
        ]),
      );
    });

    test('brand shared + chrome customized only on dark reproduces the target shape', () {
      const brand = Color(0xFF01D151);
      const chromeDark = Color(0xFFCCFADE);
      final code = generateThemeCode(
        light: const ThemeExportSide(brandSeed: brand),
        dark: const ThemeExportSide(brandSeed: brand, chromeSeed: chromeDark),
      );

      expect('const brand ='.allMatches(code).length, 1);
      expect(code, contains('const chromeDark = Color.fromARGB(255, 204, 250, 222);'));
      expect(code, isNot(contains('const chromeLight')));

      final lightSchemeSpan = code.substring(
        code.indexOf('StreamColorScheme.light('),
        code.indexOf('StreamColorScheme.dark('),
      );
      expect(lightSchemeSpan, contains('chroma: StreamColorScheme.neutralChroma'));

      final darkSchemeSpan = code.substring(code.indexOf('StreamColorScheme.dark('));
      expect(
        darkSchemeSpan,
        _callMatching('chrome: StreamColorSwatch.fromColor', ['chromeDark', 'brightness: Brightness.dark']),
      );
      expect(darkSchemeSpan, isNot(contains('neutralChroma')));
    });

    test('avatar palette is emitted only when customized, shared when equal on both sides', () {
      const palette = [
        StreamAvatarColorPair(backgroundColor: Color(0xFFAAAAAA), foregroundColor: Color(0xFF111111)),
      ];
      final withPalette = generateThemeCode(
        light: const ThemeExportSide(avatarPalette: palette),
        dark: const ThemeExportSide(avatarPalette: palette),
      );
      expect(withPalette, contains('const avatarPalette = ['));
      expect(withPalette, contains('avatarPalette: avatarPalette'));

      final withoutPalette = generateThemeCode(light: const ThemeExportSide(), dark: const ThemeExportSide());
      expect(withoutPalette, isNot(contains('avatarPalette')));
    });

    test('avatar palettes that differ between sides are emitted separately', () {
      const lightPalette = [
        StreamAvatarColorPair(backgroundColor: Color(0xFFAAAAAA), foregroundColor: Color(0xFF111111)),
      ];
      const darkPalette = [
        StreamAvatarColorPair(backgroundColor: Color(0xFF222222), foregroundColor: Color(0xFFBBBBBB)),
      ];
      final code = generateThemeCode(
        light: const ThemeExportSide(avatarPalette: lightPalette),
        dark: const ThemeExportSide(avatarPalette: darkPalette),
      );

      expect(code, contains('const avatarPaletteLight = ['));
      expect(code, contains('const avatarPaletteDark = ['));
      expect(code, contains('avatarPalette: avatarPaletteLight'));
      expect(code, contains('avatarPalette: avatarPaletteDark'));
    });

    test('emitted const names are unique even when a suffixed name could collide with a real slot name', () {
      // backgroundOverlayLight/backgroundOverlayDark are real slot names -
      // suffixing another base with Light/Dark must not silently collide.
      final code = generateThemeCode(
        light: const ThemeExportSide(
          overrides: {
            ThemeColorSlot.backgroundOverlayLight: Color(0xFF000001),
            ThemeColorSlot.backgroundOverlayDark: Color(0xFF000002),
          },
        ),
        dark: const ThemeExportSide(
          overrides: {
            ThemeColorSlot.backgroundOverlayLight: Color(0xFF000003),
            ThemeColorSlot.backgroundOverlayDark: Color(0xFF000004),
          },
        ),
      );

      final declaredNames = RegExp(r'const (\w+) =').allMatches(code).map((m) => m.group(1)).toList();
      expect(declaredNames.toSet(), hasLength(declaredNames.length));
    });

    test('the generated snippet is syntactically valid Dart', () {
      final code = generateThemeCode(
        light: const ThemeExportSide(
          brandSeed: Color(0xFF01D151),
          overrides: {ThemeColorSlot.accentError: Color(0xFFF98C26)},
        ),
        dark: const ThemeExportSide(
          brandSeed: Color(0xFF01D151),
          chromeSeed: Color(0xFFCCFADE),
          overrides: {ThemeColorSlot.accentError: Color(0xFFF6AB64)},
        ),
      );

      // Wrap the same way the generator does internally: if this parses and
      // formats without throwing, every emitted const and argument is
      // syntactically well-formed Dart.
      final wrapped = 'void f() {\n$code\n}\n';
      expect(
        () => DartFormatter(languageVersion: DartFormatter.latestLanguageVersion).format(wrapped),
        returnsNormally,
      );
    });

    test('a component theme override is emitted as a named arg on StreamTheme, not StreamColorScheme', () {
      final code = generateThemeCode(
        light: const ThemeExportSide(
          componentOverrides: {
            'Online Indicator': {'backgroundOnline': Color(0xFF112233)},
          },
        ),
        dark: const ThemeExportSide(
          componentOverrides: {
            'Online Indicator': {'backgroundOnline': Color(0xFF112233)},
          },
        ),
      );

      expect(code, contains('const onlineIndicatorBackgroundOnline = Color.fromARGB(255, 17, 34, 51);'));
      expect(
        code,
        _callMatching('onlineIndicatorTheme: StreamOnlineIndicatorThemeData', [
          'backgroundOnline: onlineIndicatorBackgroundOnline',
        ]),
      );
      // Not nested inside StreamColorScheme - it's a sibling of colorScheme:
      // on StreamTheme(...).
      expect(code, isNot(contains('StreamColorScheme.light(onlineIndicatorTheme')));
    });

    test('only overridden properties of a component are passed to its constructor', () {
      final code = generateThemeCode(
        light: const ThemeExportSide(
          componentOverrides: {
            'Online Indicator': {'backgroundOnline': Color(0xFF112233)},
          },
        ),
        dark: const ThemeExportSide(),
      );

      final lightSchemeSpan = code.substring(0, code.indexOf('darkStreamTheme'));
      expect(
        lightSchemeSpan,
        _callMatching('onlineIndicatorTheme: StreamOnlineIndicatorThemeData', [
          'backgroundOnline: onlineIndicatorBackgroundOnlineLight',
        ]),
      );
      expect(lightSchemeSpan, isNot(contains('backgroundOffline')));
      // Dark side has no override at all - no onlineIndicatorTheme arg there.
      final darkSchemeSpan = code.substring(code.indexOf('darkStreamTheme'));
      expect(darkSchemeSpan, isNot(contains('onlineIndicatorTheme')));
    });

    test('a component property set to different colors per side becomes two suffixed consts', () {
      // Component property colors start unlinked on the export page, so
      // diverging light/dark values are the common case, not an edge one.
      final code = generateThemeCode(
        light: const ThemeExportSide(
          componentOverrides: {
            'Online Indicator': {'backgroundOnline': Color(0xFF112233)},
          },
        ),
        dark: const ThemeExportSide(
          componentOverrides: {
            'Online Indicator': {'backgroundOnline': Color(0xFF445566)},
          },
        ),
      );

      expect(code, contains('const onlineIndicatorBackgroundOnlineLight = Color.fromARGB(255, 17, 34, 51);'));
      expect(code, contains('const onlineIndicatorBackgroundOnlineDark = Color.fromARGB(255, 68, 85, 102);'));
      // No shared const, since the two sides disagree.
      expect(code, isNot(contains('const onlineIndicatorBackgroundOnline =')));

      // Each side references its own const.
      final lightSpan = code.substring(0, code.indexOf('darkStreamTheme'));
      final darkSpan = code.substring(code.indexOf('darkStreamTheme'));
      expect(
        lightSpan,
        _callMatching('onlineIndicatorTheme: StreamOnlineIndicatorThemeData', [
          'backgroundOnline: onlineIndicatorBackgroundOnlineLight',
        ]),
      );
      expect(
        darkSpan,
        _callMatching('onlineIndicatorTheme: StreamOnlineIndicatorThemeData', [
          'backgroundOnline: onlineIndicatorBackgroundOnlineDark',
        ]),
      );
    });

    test('a component with no overridden properties is omitted entirely', () {
      final code = generateThemeCode(light: const ThemeExportSide(), dark: const ThemeExportSide());

      expect(code, isNot(contains('onlineIndicatorTheme')));
      expect(code, isNot(contains('StreamOnlineIndicatorThemeData')));
    });

    test('multiple components with several properties each are all emitted', () {
      final code = generateThemeCode(
        light: const ThemeExportSide(
          componentOverrides: {
            'Online Indicator': {'backgroundOnline': Color(0xFF111111), 'backgroundOffline': Color(0xFF222222)},
            'Badge Count': {'textColor': Color(0xFF333333)},
          },
        ),
        dark: const ThemeExportSide(
          componentOverrides: {
            'Online Indicator': {'backgroundOnline': Color(0xFF111111), 'backgroundOffline': Color(0xFF222222)},
            'Badge Count': {'textColor': Color(0xFF333333)},
          },
        ),
      );

      expect(
        code,
        _callMatching('onlineIndicatorTheme: StreamOnlineIndicatorThemeData', [
          'backgroundOnline: onlineIndicatorBackgroundOnline',
          'backgroundOffline: onlineIndicatorBackgroundOffline',
        ]),
      );
      expect(
        code,
        _callMatching('badgeCountTheme: StreamBadgeCountThemeData', ['textColor: badgeCountTextColor']),
      );
    });
  });
}
