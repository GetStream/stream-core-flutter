/// Stream Icons Generator
///
/// Generates an icon font and Dart classes from SVG files using configuration
/// from a YAML config file.
///
/// Usage:
///   dart run scripts/generate_icons.dart
///
/// Looks for 'stream_icons.yaml' in the current directory.
///
/// This script:
///   1. Reads configuration from the specified YAML file
///   2. Reads SVG files from the configured source directory
///   3. Generates an OTF font file
///   4. Generates icon data class with icon constants
///   5. Generates icon class for theme customization
///   6. Runs build_runner to generate the theme extension mixin
library;

import 'dart:io';

import 'package:code_builder/code_builder.dart';
import 'package:icon_font_generator/icon_font_generator.dart';
import 'package:path/path.dart' as p;
import 'package:recase/recase.dart';
import 'package:yaml/yaml.dart';

// =============================================================================
// Configuration
// =============================================================================

/// Configuration for the icon generator, loaded from stream_icons.yaml.
class IconGeneratorConfig {
  const IconGeneratorConfig({
    required this.inputSvgDir,
    required this.outputFontFile,
    required this.outputFile,
    required this.outputDataFile,
    required this.fontName,
    required this.className,
    required this.dataClassName,
    required this.package,
    required this.normalize,
    required this.ignoreShapes,
    required this.recursive,
    required this.format,
  });

  /// Loads configuration from a YAML file.
  factory IconGeneratorConfig.fromYaml(String yamlPath) {
    final file = File(yamlPath);
    if (!file.existsSync()) {
      throw IconGeneratorException('Configuration file not found: $yamlPath', exitCode: 2);
    }

    final config = loadYaml(file.readAsStringSync()) as YamlMap;
    final configDir = p.dirname(yamlPath);

    // Helper to resolve paths relative to the config file directory
    String resolvePath(String key) {
      final value = config[key] as String?;
      if (value == null || value.isEmpty) {
        throw IconGeneratorException('Missing required config: $key', exitCode: 2);
      }
      return p.normalize(p.join(configDir, value));
    }

    return IconGeneratorConfig(
      inputSvgDir: resolvePath('input_svg_dir'),
      outputFontFile: resolvePath('output_font_file'),
      outputFile: resolvePath('output_file'),
      outputDataFile: resolvePath('output_data_file'),
      fontName: config['font_name'] as String? ?? 'Stream Icons',
      className: config['class_name'] as String? ?? 'StreamIcons',
      dataClassName: config['data_class_name'] as String? ?? 'StreamIconData',
      package: config['package'] as String? ?? 'stream_core_flutter',
      normalize: config['normalize'] as bool? ?? true,
      ignoreShapes: config['ignore_shapes'] as bool? ?? true,
      recursive: config['recursive'] as bool? ?? true,
      format: config['format'] as bool? ?? true,
    );
  }

  final String inputSvgDir;
  final String outputFontFile;
  final String outputFile;
  final String outputDataFile;
  final String fontName;
  final String className;
  final String dataClassName;
  final String package;
  final bool normalize;
  final bool ignoreShapes;
  final bool recursive;
  final bool format;
}

// =============================================================================
// Main Entry Point
// =============================================================================

const _kDefaultConfigFile = 'stream_icons.yaml';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  try {
    final configPath = _resolveConfigPath();

    _log('📄 Loading config: ${p.basename(configPath)}');
    final config = IconGeneratorConfig.fromYaml(configPath);
    final configDir = p.dirname(configPath);

    await _generateIcons(config, configDir);

    _log('✅ Completed in ${stopwatch.elapsedMilliseconds}ms');
  } on IconGeneratorException catch (e) {
    _logError(e.message);
    exit(e.exitCode);
  } catch (e, stack) {
    _logError('Unexpected error: $e');
    _logError(stack.toString());
    exit(1);
  }
}

/// Resolves the config file path in current directory.
String _resolveConfigPath() {
  final configPath = p.join(Directory.current.path, _kDefaultConfigFile);

  if (!File(configPath).existsSync()) {
    throw const IconGeneratorException(
      "Configuration file '$_kDefaultConfigFile' not found in current directory.",
      exitCode: 66,
    );
  }

  return configPath;
}

// =============================================================================
// Icon Generation
// =============================================================================

Future<void> _generateIcons(IconGeneratorConfig config, String scriptDir) async {
  // 1. Read SVG files
  final svgMap = _readSvgFiles(config.inputSvgDir, config.recursive, scriptDir);
  if (svgMap.isEmpty) {
    throw const IconGeneratorException('No SVG files found', exitCode: 2);
  }

  // 2. Generate font
  _log('🔨 Generating font from ${svgMap.length} icons...', section: true);
  final fontResult = svgToOtf(
    svgMap: svgMap,
    fontName: config.fontName,
    normalize: config.normalize,
    ignoreShapes: config.ignoreShapes,
  );

  // 3. Write font file
  _ensureDirectoryExists(config.outputFontFile);
  writeToFile(config.outputFontFile, fontResult.font);
  _log('   └─ ${p.relative(config.outputFontFile, from: scriptDir)}');

  // 4. Generate StreamIconData class
  _log('📝 Generating Dart classes...', section: true);
  final iconDataContent = generateFlutterClass(
    glyphList: fontResult.glyphList,
    familyName: fontResult.font.familyName,
    className: config.dataClassName,
    fontFileName: p.basename(config.outputFontFile),
    package: config.package,
  );
  File(config.outputDataFile).writeAsStringSync(iconDataContent);
  _log('   ├─ ${p.relative(config.outputDataFile, from: scriptDir)}');

  // 5. Generate StreamIcons class
  final iconEntries = _extractIconEntries(fontResult.glyphList);
  final classContent = _generateClass(
    iconEntries: iconEntries,
    className: config.className,
    dataClassName: config.dataClassName,
    iconDataFileName: p.basename(config.outputDataFile),
    outputFileName: p.basename(config.outputFile),
  );
  File(config.outputFile).writeAsStringSync(classContent);
  _log('   └─ ${p.relative(config.outputFile, from: scriptDir)}');

  // 6. Run build_runner to generate theme mixin
  _log('🔧 Running build_runner...', section: true);
  final packageDir = config.outputFile.substring(0, config.outputFile.indexOf('/lib/'));
  final buildResult = await Process.run(
    'dart',
    ['run', 'build_runner', 'build', '--delete-conflicting-outputs'],
    workingDirectory: packageDir,
  );
  if (buildResult.exitCode != 0) {
    _logError('build_runner failed:');
    _logError(buildResult.stderr.toString());
    throw IconGeneratorException('build_runner failed', exitCode: buildResult.exitCode);
  }
  _log('   └─ ${p.basename(config.outputFile).replaceFirst('.dart', '.g.theme.dart')}');

  // 7. Format generated files
  if (config.format) {
    _log('✨ Formatting...', section: true);
    final generatedThemeFile = config.outputFile.replaceFirst('.dart', '.g.theme.dart');
    await Process.run('dart', ['format', config.outputDataFile, config.outputFile, generatedThemeFile]);
  }
}

/// Reads all SVG files from a directory.
Map<String, String> _readSvgFiles(String directory, bool recursive, String scriptDir) {
  _log('🔍 Reading SVGs: ${p.relative(directory, from: scriptDir)}');

  final dir = Directory(directory);
  if (!dir.existsSync()) {
    throw IconGeneratorException(
      'SVG source directory not found: $directory',
      exitCode: 2,
    );
  }

  final svgFiles =
      dir
          .listSync(recursive: recursive)
          .whereType<File>()
          .where((f) => p.extension(f.path).toLowerCase() == '.svg')
          .toList()
        ..sort((a, b) => p.basename(a.path).compareTo(p.basename(b.path)));

  return {
    for (final file in svgFiles) p.basenameWithoutExtension(file.path): file.readAsStringSync(),
  };
}

/// Extracts icon entries from glyph list.
List<IconEntry> _extractIconEntries(List<GenericGlyph> glyphList) {
  return glyphList
      .where((g) => g.metadata.name?.isNotEmpty ?? false)
      .map((g) => IconEntry.fromGlyphName(g.metadata.name!))
      .toList()
    ..sort((a, b) => a.fieldName.compareTo(b.fieldName));
}

// =============================================================================
// StreamIcons Class Generation
// =============================================================================

String _generateClass({
  required List<IconEntry> iconEntries,
  required String className,
  required String dataClassName,
  required String iconDataFileName,
  required String outputFileName,
}) {
  // Derive part file name (e.g., stream_icons.dart -> stream_icons.g.theme.dart)
  final partFileName = outputFileName.replaceFirst('.dart', '.g.theme.dart');

  final clazz = Class(
    (b) => b
      ..docs.add(_buildClassDocs(className, dataClassName))
      ..annotations.addAll([refer('themeGen'), refer('immutable')])
      ..name = className
      ..mixins.add(refer('_\$$className'))
      ..constructors.add(_buildConstructor(iconEntries, dataClassName))
      ..fields.addAll(_buildFields(iconEntries))
      ..methods.addAll(_buildMethods(iconEntries, className)),
  );

  final library = Library(
    (b) => b
      ..comments.addAll([
        'GENERATED CODE - DO NOT MODIFY BY HAND',
        'Generated by scripts/generate_icons.dart',
        '',
        'To regenerate: melos run generate:icons',
      ])
      ..directives.addAll([
        Directive.import('package:flutter/widgets.dart'),
        Directive.import('package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart'),
        Directive.import(iconDataFileName),
        Directive.part(partFileName),
      ])
      ..body.add(clazz),
  );

  final emitter = DartEmitter(useNullSafetySyntax: true);
  return library.accept(emitter).toString();
}

Constructor _buildConstructor(List<IconEntry> entries, String iconsClassName) {
  return Constructor(
    (c) => c
      ..constant = true
      ..docs.add('/// Creates an icon set with optional overrides.')
      ..optionalParameters.addAll(
        entries.map(
          (e) => Parameter(
            (p) => p
              ..name = e.fieldName
              ..named = true
              ..toThis = true
              ..defaultTo = Code('$iconsClassName.${e.constantName}'),
          ),
        ),
      ),
  );
}

Iterable<Field> _buildFields(List<IconEntry> entries) {
  return entries.map(
    (e) => Field(
      (f) => f
        ..docs.add('/// The ${e.humanReadable} icon.')
        ..modifier = FieldModifier.final$
        ..type = refer('IconData')
        ..name = e.fieldName,
    ),
  );
}

Iterable<Method> _buildMethods(List<IconEntry> entries, String className) {
  return [
    // allIcons getter
    Method(
      (m) => m
        ..docs.add(_allIconsDoc)
        ..type = MethodType.getter
        ..returns = refer('Map<String, IconData>')
        ..name = 'allIcons'
        ..lambda = true
        ..body = Code('{${entries.map((e) => "'${e.fieldName}': ${e.fieldName}").join(', ')}}'),
    ),
    // lerp static method
    Method(
      (m) => m
        ..docs.add('/// Linearly interpolate between two [$className] objects.')
        ..static = true
        ..returns = refer('$className?')
        ..name = 'lerp'
        ..requiredParameters.addAll([
          Parameter(
            (p) => p
              ..name = 'a'
              ..type = refer('$className?'),
          ),
          Parameter(
            (p) => p
              ..name = 'b'
              ..type = refer('$className?'),
          ),
          Parameter(
            (p) => p
              ..name = 't'
              ..type = refer('double'),
          ),
        ])
        ..lambda = true
        ..body = Code('_\$$className.lerp(a, b, t)'),
    ),
  ];
}

// =============================================================================
// Documentation Templates
// =============================================================================

String _buildClassDocs(String className, String iconsClassName) =>
    '''
/// Provides customizable icons for the Stream design system.
///
/// [$className] allows customization of icons used throughout Stream widgets.
/// Each icon is exposed as a field that defaults to the corresponding
/// [$iconsClassName] constant.
///
/// {@tool snippet}
///
/// Access icons via context:
///
/// ```dart
/// final icon = context.streamIcons.settingsGear2;
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Override specific icons in [StreamTheme]:
///
/// ```dart
/// StreamTheme(
///   icons: $className(
///     settingsGear2: Icons.settings_outlined,
///     lock: Icons.lock_outline,
///   ),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Use copyWith for partial overrides:
///
/// ```dart
/// final customIcons = const $className().copyWith(
///   settingsGear2: Icons.settings_outlined,
/// );
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [$iconsClassName], which contains the raw icon data constants.
///  * [StreamTheme], which accepts custom icons via the [icons] parameter.''';

const _allIconsDoc = '''
/// A map of all available icons keyed by their field name.
///
/// Useful for dynamic icon lookup by string name.
///
/// ```dart
/// final icon = context.streamIcons.allIcons['settingsGear2'];
/// ```''';

// =============================================================================
// Icon Entry Model
// =============================================================================

/// Represents a single icon with its naming variants.
class IconEntry {
  const IconEntry({
    required this.fieldName,
    required this.constantName,
    required this.humanReadable,
  });

  /// Creates an entry from a glyph name (e.g., "__IconFlag2__").
  factory IconEntry.fromGlyphName(String glyphName) {
    final sanitized = _sanitizeName(glyphName);
    final withoutPrefix = sanitized.startsWith('Icon') ? sanitized.substring(4) : sanitized;

    return IconEntry(
      fieldName: ReCase(withoutPrefix).camelCase,
      constantName: 'icon${sanitized.startsWith('Icon') ? sanitized.substring(4) : ReCase(sanitized).pascalCase}',
      humanReadable: ReCase(withoutPrefix).sentenceCase.toLowerCase(),
    );
  }

  final String fieldName;
  final String constantName;
  final String humanReadable;

  /// Sanitizes a name to be a valid Dart identifier.
  static String _sanitizeName(String name) {
    return name
        .replaceAll(RegExp(r'^_+|_+$'), '') // Remove leading/trailing underscores
        .replaceAllMapped(RegExp(r'[-_](\d)'), (m) => m.group(1)!) // Remove separators before digits
        .replaceAllMapped(RegExp('[-_]([a-zA-Z])'), (m) => m.group(1)!.toUpperCase()); // camelCase
  }
}

// =============================================================================
// Utilities
// =============================================================================

/// Ensures the parent directory of a file exists.
void _ensureDirectoryExists(String filePath) {
  final dir = Directory(p.dirname(filePath));
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }
}

void _log(String message, {bool section = false}) {
  if (section) stdout.writeln();
  stdout.writeln(message);
}

void _logError(String message) => stderr.writeln('❌ $message');

// =============================================================================
// Exceptions
// =============================================================================

/// Exception thrown by the icon generator.
class IconGeneratorException implements Exception {
  const IconGeneratorException(this.message, {this.exitCode = 1});

  final String message;
  final int exitCode;

  @override
  String toString() => message;
}
