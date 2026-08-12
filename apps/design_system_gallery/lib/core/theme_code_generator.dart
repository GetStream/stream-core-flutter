import 'package:dart_style/dart_style.dart';
import 'package:flutter/material.dart';
import 'package:stream_core_flutter/core.dart';

import '../config/component_theme_descriptors.dart';
import '../config/theme_color_slot.dart';

/// One brightness's worth of input to [generateThemeCode]: the slots that
/// have been overridden, the raw brand/chrome seeds (if customized), and an
/// avatar palette override (if customized).
///
/// Mirrors a single [ThemeConfiguration]'s [ThemeConfiguration.overrides],
/// brand/chrome seed, and avatar palette override.
class ThemeExportSide {
  const ThemeExportSide({
    this.overrides = const {},
    this.brandSeed,
    this.chromeSeed,
    this.avatarPalette,
    this.componentOverrides = const {},
  });

  final Map<ThemeColorSlot, Color> overrides;
  final Color? brandSeed;
  final Color? chromeSeed;
  final List<StreamAvatarColorPair>? avatarPalette;

  /// Component theme overrides, keyed by [ComponentThemeDescriptor.name],
  /// then by property name. Mirrors [ThemeConfiguration.componentOverrides].
  final Map<String, Map<String, Color>> componentOverrides;
}

/// Generates a copy-pasteable Dart snippet reproducing [light] and [dark] as
/// a [StreamTheme]-based `MaterialApp` `theme`/`darkTheme` pair.
///
/// Only customized values are emitted — [StreamColorScheme]'s own defaults
/// fill in everything else. This deliberately does **not** value-diff
/// against `StreamColorScheme.light()`/`.dark()`: several colors (e.g.
/// `textLink`, `borderActive`) are themselves *derived* from `accentPrimary`/
/// `brand` inside those factories, and asymmetrically so between light and
/// dark. Diffing values would emit those derived colors as frozen overrides,
/// breaking the very derivation this snippet is meant to preserve for its
/// consumer. Only the [ThemeColorSlot]s actually present in
/// [ThemeExportSide.overrides] are emitted.
///
/// A slot set to the same color on both sides becomes a single `const`. Set
/// to different colors (or set on only one side) it becomes two consts,
/// suffixed `Light`/`Dark`. The same rule applies to the `brand`/`chrome`
/// seeds and to the avatar palette. When `brand` is customized but `chrome`
/// is not (on a given side), `chrome` is emitted as derived from `brand` at
/// [StreamColorScheme.neutralChroma] — mirroring
/// `ThemeConfiguration._rebuildTheme()` and `StreamColorScheme.fromSeed`.
String generateThemeCode({required ThemeExportSide light, required ThemeExportSide dark}) {
  final constLines = <String>[];
  final usedNames = <String>{};

  final brandPlan = _planValue('brand', light.brandSeed, dark.brandSeed, _colorLiteral, constLines, usedNames);
  final chromePlan = _planValue('chrome', light.chromeSeed, dark.chromeSeed, _colorLiteral, constLines, usedNames);

  final slotPlans = <ThemeColorSlot, _ConstPlan>{
    for (final slot in ThemeColorSlot.values)
      if (light.overrides.containsKey(slot) || dark.overrides.containsKey(slot))
        slot: _planValue(
          slot.parameterName,
          light.overrides[slot],
          dark.overrides[slot],
          _colorLiteral,
          constLines,
          usedNames,
        ),
  };

  final avatarPalettePlan = _planValue(
    'avatarPalette',
    light.avatarPalette,
    dark.avatarPalette,
    _avatarPaletteLiteral,
    constLines,
    usedNames,
    areEqual: _avatarPaletteEquals,
  );

  // Component property colors are edited per brightness on the export page
  // and start out unlinked, so light and dark routinely diverge here - they
  // go through the same shared/split const planning as every other value.
  final componentPlans = <String, Map<String, _ConstPlan>>{
    for (final descriptor in componentThemeDescriptors)
      if (light.componentOverrides.containsKey(descriptor.name) || dark.componentOverrides.containsKey(descriptor.name))
        descriptor.name: {
          for (final property in descriptor.properties)
            property: _planValue(
              _componentConstBaseName(descriptor.name, property),
              light.componentOverrides[descriptor.name]?[property],
              dark.componentOverrides[descriptor.name]?[property],
              _colorLiteral,
              constLines,
              usedNames,
            ),
        },
  };

  final lightScheme = _colorSchemeCall(
    brightness: Brightness.light,
    brandRef: brandPlan.refFor(Brightness.light),
    chromeRef: chromePlan.refFor(Brightness.light),
    slotPlans: slotPlans,
    avatarPaletteRef: avatarPalettePlan.refFor(Brightness.light),
  );
  final darkScheme = _colorSchemeCall(
    brightness: Brightness.dark,
    brandRef: brandPlan.refFor(Brightness.dark),
    chromeRef: chromePlan.refFor(Brightness.dark),
    slotPlans: slotPlans,
    avatarPaletteRef: avatarPalettePlan.refFor(Brightness.dark),
  );
  final lightComponentArgs = _componentThemeArgs(componentPlans, Brightness.light);
  final darkComponentArgs = _componentThemeArgs(componentPlans, Brightness.dark);

  final source =
      '''
void _f() {
${constLines.join('\n')}
${constLines.isNotEmpty ? '\n' : ''}final lightStreamTheme = StreamTheme(
  colorScheme: $lightScheme,
  $lightComponentArgs
);
final darkStreamTheme = StreamTheme(
  colorScheme: $darkScheme,
  $darkComponentArgs
);

MaterialApp(
  theme: ThemeData(
    brightness: Brightness.light,
    extensions: [lightStreamTheme],
  ),
  darkTheme: ThemeData(
    brightness: Brightness.dark,
    extensions: [darkStreamTheme],
  ),
);
}
''';

  final formatted = _dedent(DartFormatter(languageVersion: DartFormatter.latestLanguageVersion).format(source));
  return _forceMultilineStreamThemeAssignments(formatted);
}

/// Builds `StreamColorScheme.light(...)`/`.dark(...)` for one brightness:
/// `brand`/`chrome` (with chrome derived from brand when only brand was
/// customized), then every overridden [ThemeColorSlot] in declaration order.
String _colorSchemeCall({
  required Brightness brightness,
  required String? brandRef,
  required String? chromeRef,
  required Map<ThemeColorSlot, _ConstPlan> slotPlans,
  required String? avatarPaletteRef,
}) {
  final brightnessExpr = brightness == Brightness.light ? 'Brightness.light' : 'Brightness.dark';
  final factoryName = brightness == Brightness.light ? 'StreamColorScheme.light' : 'StreamColorScheme.dark';

  final args = <String>[];
  if (brandRef != null) {
    args.add('brand: StreamColorSwatch.fromColor($brandRef, brightness: $brightnessExpr)');
  }
  if (chromeRef != null) {
    args.add('chrome: StreamColorSwatch.fromColor($chromeRef, brightness: $brightnessExpr)');
  } else if (brandRef != null) {
    // Chrome wasn't customized on this side, but brand was: derive it from
    // brand at neutral chroma, matching ThemeConfiguration._rebuildTheme()
    // and StreamColorScheme.fromSeed.
    args.add(
      'chrome: StreamColorSwatch.fromColor($brandRef, brightness: $brightnessExpr, '
      'chroma: StreamColorScheme.neutralChroma)',
    );
  }
  for (final entry in slotPlans.entries) {
    final ref = entry.value.refFor(brightness);
    if (ref != null) args.add('${entry.key.parameterName}: $ref');
  }
  if (avatarPaletteRef != null) {
    args.add('avatarPalette: $avatarPaletteRef');
  }

  return '$factoryName(${args.join(', ')})';
}

/// A plan for emitting one or two `const` declarations for a value that may
/// differ between light and dark, plus how to reference it on each side.
class _ConstPlan {
  const _ConstPlan({this.sharedName, this.lightName, this.darkName});

  final String? sharedName;
  final String? lightName;
  final String? darkName;

  String? refFor(Brightness brightness) => sharedName ?? (brightness == Brightness.light ? lightName : darkName);
}

/// Plans const emission for a single named value across [light]/[dark]:
/// shared when both are set and equal, otherwise `Light`/`Dark`-suffixed and
/// emitted only for the sides that actually have a value. Appends the
/// resulting `const` declaration(s) to [constLines], guarding name
/// collisions via [usedNames].
_ConstPlan _planValue<T>(
  String baseName,
  T? light,
  T? dark,
  String Function(T value) literal,
  List<String> constLines,
  Set<String> usedNames, {
  bool Function(T a, T b)? areEqual,
}) {
  if (light == null && dark == null) return const _ConstPlan();

  final equal = light != null && dark != null && (areEqual?.call(light, dark) ?? light == dark);
  if (equal) {
    final name = _uniqueName(baseName, usedNames);
    constLines.add('const $name = ${literal(light)};');
    return _ConstPlan(sharedName: name);
  }

  String? lightName;
  String? darkName;
  if (light != null) {
    lightName = _uniqueName('${baseName}Light', usedNames);
    constLines.add('const $lightName = ${literal(light)};');
  }
  if (dark != null) {
    darkName = _uniqueName('${baseName}Dark', usedNames);
    constLines.add('const $darkName = ${literal(dark)};');
  }
  return _ConstPlan(lightName: lightName, darkName: darkName);
}

String _uniqueName(String base, Set<String> usedNames) {
  var name = base;
  var suffix = 2;
  while (!usedNames.add(name)) {
    name = '$base$suffix';
    suffix++;
  }
  return name;
}

String _colorLiteral(Color color) {
  final argb = color.toARGB32();
  final a = (argb >> 24) & 0xFF;
  final r = (argb >> 16) & 0xFF;
  final g = (argb >> 8) & 0xFF;
  final b = argb & 0xFF;
  return 'Color.fromARGB($a, $r, $g, $b)';
}

String _avatarPaletteLiteral(List<StreamAvatarColorPair> palette) {
  final entries = palette
      .map(
        (pair) =>
            'StreamAvatarColorPair('
            'backgroundColor: ${_colorLiteral(pair.backgroundColor)}, '
            'foregroundColor: ${_colorLiteral(pair.foregroundColor)})',
      )
      .join(', ');
  return '[$entries]';
}

bool _avatarPaletteEquals(List<StreamAvatarColorPair> a, List<StreamAvatarColorPair> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i].backgroundColor.toARGB32() != b[i].backgroundColor.toARGB32()) return false;
    if (a[i].foregroundColor.toARGB32() != b[i].foregroundColor.toARGB32()) return false;
  }
  return true;
}

/// A stable, readable const base name for one component property, e.g.
/// `('Badge Count', 'textColor')` -> `'badgeCountTextColor'`.
String _componentConstBaseName(String componentName, String property) {
  final pascalComponent = componentName.split(' ').join();
  final camelComponent = pascalComponent[0].toLowerCase() + pascalComponent.substring(1);
  final pascalProperty = property[0].toUpperCase() + property.substring(1);
  return '$camelComponent$pascalProperty';
}

/// Builds the `avatarTheme: StreamAvatarThemeData(...)`-style named
/// arguments (one per component with at least one overridden property on
/// [brightness]) to splice into a `StreamTheme(...)` call.
String _componentThemeArgs(Map<String, Map<String, _ConstPlan>> componentPlans, Brightness brightness) {
  final args = <String>[];
  for (final descriptor in componentThemeDescriptors) {
    final propertyPlans = componentPlans[descriptor.name];
    if (propertyPlans == null) continue;

    final ctorArgs = <String>[];
    for (final property in descriptor.properties) {
      final ref = propertyPlans[property]?.refFor(brightness);
      if (ref != null) ctorArgs.add('$property: $ref');
    }
    if (ctorArgs.isEmpty) continue;

    args.add('${descriptor.themeParameterName}: ${descriptor.themeDataTypeName}(${ctorArgs.join(', ')}),');
  }
  return args.join('\n');
}

/// Rewrites a `final x = StreamTheme(...)` assignment that [DartFormatter]
/// collapsed onto a single line (because its arguments happened to be short
/// enough to fit) into the same one-argument-per-line shape used whenever
/// there's enough content to force wrapping. Without this, "nothing
/// customized" exports as a compact one-liner that reads as visually
/// inconsistent with — and, in a narrow code pane, wraps far worse than —
/// the multi-line shape every non-trivial export gets for free.
///
/// `dart_style`'s tall-style formatter (Dart 3.7+) decides line-splitting
/// purely from content width; it doesn't treat a trailing comma in the
/// input as a "keep this expanded" hint the way the old formatter did, so
/// there's no formatter option to lean on for this — hence the targeted
/// rewrite instead.
String _forceMultilineStreamThemeAssignments(String formatted) {
  final pattern = RegExp(r'^final (\w+) = StreamTheme\((.*)\);$', multiLine: true);
  return formatted.replaceAllMapped(pattern, (match) {
    final varName = match.group(1);
    final args = _splitTopLevelArgs(match.group(2)!);
    final argLines = args.map((arg) => '  $arg,').join('\n');
    return 'final $varName = StreamTheme(\n$argLines\n);';
  });
}

/// Splits a comma-separated argument list on commas at paren/bracket depth
/// zero only, so a nested call's own commas (e.g. inside
/// `StreamAvatarThemeData(backgroundColor: x, foregroundColor: y)`) aren't
/// mistaken for top-level argument separators.
List<String> _splitTopLevelArgs(String argsList) {
  final args = <String>[];
  var depth = 0;
  var start = 0;
  for (var i = 0; i < argsList.length; i++) {
    final char = argsList[i];
    if (char == '(' || char == '[' || char == '{') depth++;
    if (char == ')' || char == ']' || char == '}') depth--;
    if (char == ',' && depth == 0) {
      args.add(argsList.substring(start, i).trim());
      start = i + 1;
    }
  }
  final last = argsList.substring(start).trim();
  if (last.isNotEmpty) args.add(last);
  return args;
}

/// Strips the synthetic `void _f() { ... }` wrapper used to get valid,
/// [DartFormatter]-formatted output for a snippet that isn't itself a
/// compilation unit, and removes one level of indentation.
String _dedent(String formatted) {
  final lines = formatted.split('\n');
  // Drop the wrapper's opening `void _f() {` and closing `}` (plus the
  // trailing blank line DartFormatter leaves after the final `}`).
  final body = lines.sublist(1, lines.length - 2);
  return body.map((line) => line.startsWith('  ') ? line.substring(2) : line).join('\n');
}
