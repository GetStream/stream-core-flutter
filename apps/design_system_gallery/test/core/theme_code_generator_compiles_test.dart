@Timeout(Duration(minutes: 5))
library;

import 'dart:convert';
import 'dart:io';

import 'package:design_system_gallery/config/component_theme_descriptors.dart';
import 'package:design_system_gallery/config/theme_color_slot.dart';
import 'package:design_system_gallery/core/theme_code_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

/// One named scenario: a light/dark pair of inputs, and the function name its
/// generated snippet is wrapped in inside the assembled Dart file.
class _Scenario {
  const _Scenario(this.name, this.light, this.dark);

  final String name;
  final ThemeExportSide light;
  final ThemeExportSide dark;
}

/// A deterministic, distinct color per index - the actual values are
/// irrelevant here, only that each emitted const gets a real Color literal.
Color _color(int index) => Color(0xFF000000 | (index * 0x00050307) & 0x00FFFFFF);

/// Every [ThemeColorSlot] overridden on both sides, with a *different* color
/// per side.
///
/// This is the scenario that earns this test its keep: it forces the
/// generator to emit all ~51 `parameterName` strings as named arguments to
/// both `StreamColorScheme.light()` and `.dark()`. Those names live in the
/// enum as plain strings, so nothing but a real type-check proves they're
/// actual parameters of the real API.
Map<ThemeColorSlot, Color> _allSlots({required int seed}) => {
  for (final (index, slot) in ThemeColorSlot.values.indexed) slot: _color(seed + index),
};

/// Every [ComponentThemeDescriptor] with every one of its properties set -
/// type-checks each descriptor's `themeParameterName`, `themeDataTypeName`
/// and property names, which are likewise only strings until compiled.
Map<String, Map<String, Color>> _allComponents({required int seed}) {
  var index = seed;
  return {
    for (final descriptor in componentThemeDescriptors)
      descriptor.name: {for (final property in descriptor.properties) property: _color(index++)},
  };
}

const _palette = [
  StreamAvatarColorPair(backgroundColor: Color(0xFFD6E4FF), foregroundColor: Color(0xFF1A2B5C)),
  StreamAvatarColorPair(backgroundColor: Color(0xFFCCFADE), foregroundColor: Color(0xFF0B3B24)),
];

final _scenarios = <_Scenario>[
  // Nothing customized - bare StreamColorScheme.light()/.dark().
  const _Scenario('nothingCustomized', ThemeExportSide(), ThemeExportSide()),

  // Brand only, shared: chrome is derived from brand at neutral chroma.
  const _Scenario(
    'brandOnlyShared',
    ThemeExportSide(brandSeed: Color(0xFF01D151)),
    ThemeExportSide(brandSeed: Color(0xFF01D151)),
  ),

  // The shape from the feature's own docs: shared brand, chrome customized
  // on dark only, one slot split between the two sides.
  const _Scenario(
    'sharedBrandSplitAccent',
    ThemeExportSide(brandSeed: Color(0xFF01D151), overrides: {ThemeColorSlot.accentError: Color(0xFFF98C26)}),
    ThemeExportSide(
      brandSeed: Color(0xFF01D151),
      chromeSeed: Color(0xFFCCFADE),
      overrides: {ThemeColorSlot.accentError: Color(0xFFF6AB64)},
    ),
  ),

  // A slot customized on one side only.
  const _Scenario(
    'lightOnlySlot',
    ThemeExportSide(overrides: {ThemeColorSlot.backgroundApp: Color(0xFFFAFAFA)}),
    ThemeExportSide(),
  ),

  // Avatar palette, shared and split.
  const _Scenario(
    'avatarPaletteShared',
    ThemeExportSide(avatarPalette: _palette),
    ThemeExportSide(avatarPalette: _palette),
  ),
  const _Scenario('avatarPaletteLightOnly', ThemeExportSide(avatarPalette: _palette), ThemeExportSide()),

  // Every color slot, split light/dark.
  _Scenario(
    'everyColorSlotSplit',
    ThemeExportSide(brandSeed: const Color(0xFF01D151), overrides: _allSlots(seed: 1)),
    ThemeExportSide(
      brandSeed: const Color(0xFF01D151),
      chromeSeed: const Color(0xFFCCFADE),
      overrides: _allSlots(seed: 500),
    ),
  ),

  // Every color slot, shared between sides (exercises the single-const path
  // for all of them, not just the suffixed one).
  _Scenario(
    'everyColorSlotShared',
    ThemeExportSide(overrides: _allSlots(seed: 1)),
    ThemeExportSide(overrides: _allSlots(seed: 1)),
  ),

  // Every component theme property, shared and split.
  _Scenario(
    'everyComponentThemeShared',
    ThemeExportSide(componentOverrides: _allComponents(seed: 1)),
    ThemeExportSide(componentOverrides: _allComponents(seed: 1)),
  ),
  _Scenario(
    'everyComponentThemeSplit',
    ThemeExportSide(componentOverrides: _allComponents(seed: 1)),
    ThemeExportSide(componentOverrides: _allComponents(seed: 900)),
  ),

  // Everything at once.
  _Scenario(
    'everythingAtOnce',
    ThemeExportSide(
      brandSeed: const Color(0xFF01D151),
      chromeSeed: const Color(0xFFCCFADE),
      overrides: _allSlots(seed: 1),
      avatarPalette: _palette,
      componentOverrides: _allComponents(seed: 1),
    ),
    ThemeExportSide(
      brandSeed: const Color(0xFF0A7F3C),
      overrides: _allSlots(seed: 500),
      avatarPalette: _palette,
      componentOverrides: _allComponents(seed: 900),
    ),
  ),
];

/// Assembles every scenario's snippet into a single compilable library.
///
/// Each snippet goes in its own function body, so the `const` declarations
/// the generator emits are scoped per scenario and can't collide across
/// them.
String _buildSource() {
  final buffer = StringBuffer()
    ..writeln('// GENERATED by theme_code_generator_compiles_test.dart.')
    ..writeln('// Transient: written, analyzed and deleted by that test.')
    ..writeln('//')
    // The generated snippet ends in a bare `MaterialApp(...);` - it shows a
    // consumer where the themes plug in, and is deliberately a statement
    // rather than something assigned or returned.
    ..writeln('// ignore_for_file: unnecessary_statements')
    ..writeln()
    ..writeln("import 'package:flutter/material.dart';")
    ..writeln("import 'package:stream_core_flutter/core.dart';")
    ..writeln();

  for (final scenario in _scenarios) {
    buffer
      ..writeln('void ${scenario.name}() {')
      ..writeln(generateThemeCode(light: scenario.light, dark: scenario.dark))
      ..writeln('}')
      ..writeln();
  }

  return buffer.toString();
}

/// The source with 1-based line numbers, so an analyzer diagnostic's
/// `line:col` can be read straight off a failure message.
String _numbered(String source) {
  final lines = const LineSplitter().convert(source);
  final width = lines.length.toString().length;
  return [
    for (final (index, line) in lines.indexed) '${(index + 1).toString().padLeft(width)} | $line',
  ].join('\n');
}

void main() {
  test('every generated snippet type-checks against the real stream_core_flutter API', () async {
    final source = _buildSource();

    // Must live inside this package so `package:` imports resolve through
    // its own .dart_tool/package_config.json.
    final file = File('test/core/generated/export_snippets.dart');
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(source);
    addTearDown(() {
      if (file.parent.existsSync()) file.parent.deleteSync(recursive: true);
    });

    // Only compile errors matter here. Lints and warnings are the *snippet
    // consumer's* style problem, not a correctness signal for this
    // generator - and the repo's own strict lint set would flag plenty in
    // deliberately exhaustive generated code.
    final ProcessResult result;
    try {
      result = await Process.run('dart', [
        'analyze',
        '--no-fatal-warnings',
        '--format=machine',
        file.path,
      ]);
    } on ProcessException catch (error) {
      fail('Could not run `dart analyze` - is the Dart SDK on PATH? ($error)');
    }

    // `dart analyze` exits 0 (clean), 1 (infos), 2 (warnings) or 3 (errors);
    // anything else means it didn't get far enough to have an opinion, and
    // an empty diagnostic list would then be a false pass.
    expect(
      result.exitCode,
      isIn([0, 1, 2, 3]),
      reason: '`dart analyze` failed to run.\nstdout:\n${result.stdout}\nstderr:\n${result.stderr}',
    );

    final diagnostics = const LineSplitter().convert(result.stdout.toString());
    final errors = diagnostics.where((line) => line.startsWith('ERROR|')).toList();

    expect(
      errors,
      isEmpty,
      reason:
          'The generated snippet does not compile against the real API.\n'
          'Analyzer errors:\n${errors.join('\n')}\n\n'
          'Generated source:\n${_numbered(source)}',
    );
  });
}
