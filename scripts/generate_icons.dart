/// Stream Icons Generator
///
/// Generates an icon font and Dart classes from SVG files using configuration
/// from a YAML config file.
///
/// Source SVGs come from the design-system-tokens repository:
/// https://github.com/GetStream/design-system-tokens/tree/main/assets/icons
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
///   5. Optionally generates SVG icon data class for colored SVG icons
///   6. Generates icon class for theme customization
///   7. Runs build_runner to generate the theme extension mixin
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
    this.inputSvgIconDir,
    this.inputDeprecatedFile,
    required this.outputFontFile,
    required this.outputFile,
    required this.outputDataFile,
    required this.outputLogFile,
    required this.fontName,
    required this.className,
    required this.dataClassName,
    required this.svgIconDataClassName,
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

    String? resolveOptionalPath(String key) {
      final value = config[key] as String?;
      if (value == null || value.isEmpty) return null;
      return p.normalize(p.join(configDir, value));
    }

    String resolvePath(String key) {
      final path = resolveOptionalPath(key);
      if (path == null || path.isEmpty) {
        throw IconGeneratorException('Missing required config: $key', exitCode: 2);
      }
      return path;
    }

    return IconGeneratorConfig(
      inputSvgDir: resolvePath('input_svg_dir'),
      inputSvgIconDir: resolveOptionalPath('input_svg_icon_dir'),
      inputDeprecatedFile: resolveOptionalPath('input_deprecated_file'),
      outputFontFile: resolvePath('output_font_file'),
      outputFile: resolvePath('output_file'),
      outputDataFile: resolvePath('output_data_file'),
      outputLogFile: resolvePath('output_log_file'),
      fontName: config['font_name'] as String? ?? 'Stream Icons',
      className: config['class_name'] as String? ?? 'StreamIcons',
      dataClassName: config['data_class_name'] as String? ?? 'StreamIconData',
      svgIconDataClassName: config['svg_icon_data_class_name'] as String? ?? 'StreamSvgIconData',
      package: config['package'] as String? ?? 'stream_core_flutter',
      normalize: config['normalize'] as bool? ?? true,
      ignoreShapes: config['ignore_shapes'] as bool? ?? true,
      recursive: config['recursive'] as bool? ?? true,
      format: config['format'] as bool? ?? true,
    );
  }

  final String inputSvgDir;
  final String? inputSvgIconDir;
  final String? inputDeprecatedFile;
  final String outputFontFile;
  final String outputFile;
  final String outputDataFile;
  final String outputLogFile;
  final String fontName;
  final String className;
  final String dataClassName;
  final String svgIconDataClassName;
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
  // 1. Read deprecations and SVG files
  final deprecatedIcons = _readDeprecatedIcons(config.inputDeprecatedFile, scriptDir);
  final svgMap = _readSvgFiles(
    config.inputSvgDir,
    config.recursive,
    scriptDir: scriptDir,
    logFilePath: config.outputLogFile,
    deprecatedIcons: deprecatedIcons,
  );
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
  var iconDataContent = generateFlutterClass(
    glyphList: fontResult.glyphList,
    familyName: fontResult.font.familyName,
    className: config.dataClassName,
    fontFileName: p.basename(config.outputFontFile),
    package: config.package,
  );
  iconDataContent = iconDataContent.replaceFirst(
    "import 'package:flutter/widgets.dart';",
    "part of '${p.basename(config.outputDataFile).replaceFirst('.g', '')}';",
  );
  // Update the icon data to include matchTextDirection: true for RTL icons.
  // Each entry in _rtlIcons is a base name (e.g. 'arrow-left').
  for (final baseName in _rtlIcons) {
    final camelBase = ReCase(baseName).camelCase;
    iconDataContent = iconDataContent.replaceAllMapped(
      RegExp('(static const IconData $camelBase = IconData\\([^)]+)\\)'),
      (match) => '${match.group(1)}, matchTextDirection: true)',
    );
  }
  // Deprecated icons always keep their glyph so the code points of the icons
  // after them stay put; only their Dart constant is annotated or dropped.
  iconDataContent = _applyDeprecations(iconDataContent, deprecatedIcons);

  // 5. Generate StreamSvgIconData class (if configured)
  final svgIconEntries = <SvgIconEntry>[];

  if (config.inputSvgIconDir != null) {
    svgIconEntries.addAll(_extractSvgIconEntries(config.inputSvgIconDir!, scriptDir));

    if (svgIconEntries.isNotEmpty) {
      final svgDataContent = _generateSvgIconDataClass(
        entries: svgIconEntries,
        className: config.svgIconDataClassName,
        package: config.package,
      );
      iconDataContent += '\n$svgDataContent';
    }
  }

  File(config.outputDataFile).writeAsStringSync(iconDataContent);
  _log('   ├─ ${p.relative(config.outputDataFile, from: scriptDir)}');

  // 6. Generate StreamIcons class
  final iconEntries = _extractIconEntries(fontResult.glyphList, deprecatedIcons);
  final classContent = _generateClass(
    iconEntries: iconEntries,
    svgIconEntries: svgIconEntries,
    className: config.className,
    dataClassName: config.dataClassName,
    svgIconDataClassName: config.svgIconDataClassName,
    iconDataFileName: p.basename(config.outputDataFile),
    outputFileName: p.basename(config.outputFile),
  );
  File(config.outputFile).writeAsStringSync(classContent);
  _log('   └─ ${p.relative(config.outputFile, from: scriptDir)}');

  // 7. Run build_runner to generate theme mixin
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

  // 8. Format generated files
  if (config.format) {
    _log('✨ Formatting...', section: true);
    final generatedThemeFile = config.outputFile.replaceFirst('.dart', '.g.theme.dart');
    await Process.run('dart', ['format', config.outputDataFile, config.outputFile, generatedThemeFile]);
  }
}

/// Reads all SVG files from a directory.
///
/// The returned map is keyed by camelCase glyph name and ordered by the icon's
/// first-seen date recorded in [logFilePath], so the code points the font
/// generator assigns stay stable across runs.
///
/// Deprecated icons keep their place in that order even after their SVG file is
/// deleted: the glyph is then drawn from the replacement's SVG. Without this,
/// deleting an icon would shift the code point of every icon after it.
Map<String, String> _readSvgFiles(
  String directory,
  bool recursive, {
  required String scriptDir,
  required String logFilePath,
  required List<DeprecatedIcon> deprecatedIcons,
}) {
  _log('🔍 Reading SVGs: ${p.relative(directory, from: scriptDir)}');

  final dir = Directory(directory);
  if (!dir.existsSync()) {
    throw IconGeneratorException(
      'SVG source directory not found: $directory',
      exitCode: 2,
    );
  }

  _log('🔍 Reading log file: ${p.relative(logFilePath, from: scriptDir)}');
  final logFile = File(logFilePath);
  if (!logFile.existsSync()) {
    throw IconGeneratorException(
      'Log file not found: $logFile',
      exitCode: 2,
    );
  }
  final logContent = logFile.readAsStringSync();
  final logEntries = <String, String>{};
  for (final line in logContent.split('\n')) {
    final parts = line.split(';');
    if (parts.length == 2) {
      logEntries[parts[0]] = parts[1];
    }
  }

  final newAdditions = <String, String>{};

  String getAdditionDate(String fileName) {
    if (logEntries.containsKey(fileName)) {
      return logEntries[fileName]!;
    }
    final now = DateTime.now();
    newAdditions[fileName] = '${now.year}${now.month}${now.day}';
    return newAdditions[fileName]!;
  }

  final svgFileByName = <String, File>{
    for (final file
        in dir
            .listSync(recursive: recursive)
            .whereType<File>()
            .where((f) => p.extension(f.path).toLowerCase() == '.svg')
            .where((f) => !_excludedSvgIcons.contains(p.basenameWithoutExtension(f.path))))
      p.basenameWithoutExtension(file.path): file,
  };

  final deprecatedByName = {for (final icon in deprecatedIcons) icon.name: icon};

  // Guard against typos: an icon with no SVG file of its own only earns a glyph
  // because it already holds a code point. Without one there is nothing to
  // preserve, and letting it through would invent a glyph and pollute the log.
  for (final icon in deprecatedIcons) {
    if (!svgFileByName.containsKey(icon.name) && !logEntries.containsKey(icon.name)) {
      throw IconGeneratorException(
        'Deprecated icon "${icon.name}" has neither an SVG file nor a recorded code point. '
        'Check the spelling in the deprecated icons file.',
        exitCode: 2,
      );
    }
  }

  /// Resolves the SVG that should draw the glyph for [name].
  ///
  /// A deprecated icon is drawn from its replacement, so the deprecated name
  /// stays a valid glyph without keeping the retired artwork around.
  File svgSourceFor(String name) {
    final source = deprecatedByName[name]?.replacement ?? name;
    final file = svgFileByName[source];
    if (file == null) {
      throw IconGeneratorException(
        source == name
            ? 'No SVG file found for icon "$name" in $directory'
            : 'Replacement "$source" for deprecated icon "$name" has no SVG file in $directory',
        exitCode: 2,
      );
    }
    return file;
  }

  // Deprecated icons are included even when their own SVG file is gone, so the
  // glyph order — and with it every code point after them — is preserved.
  final names = {...svgFileByName.keys, ...deprecatedByName.keys}.toList()
    ..sort((a, b) {
      final dateDiff = getAdditionDate(a).compareTo(getAdditionDate(b));
      if (dateDiff != 0) return dateDiff;
      return a.compareTo(b);
    });

  for (final entries in newAdditions.entries) {
    logFile.writeAsStringSync('${entries.key};${entries.value}\n', mode: FileMode.append);
  }

  return {for (final name in names) name.camelCase: svgSourceFor(name).readAsStringSync()};
}

/// Reads the deprecated-icon list from [path].
///
/// Each non-comment line follows `deprecated;replacement;included`, e.g.
/// `more;more-horizontal;true`. Returns an empty list when no file is
/// configured.
List<DeprecatedIcon> _readDeprecatedIcons(String? path, String scriptDir) {
  if (path == null) return const [];

  final file = File(path);
  if (!file.existsSync()) {
    throw IconGeneratorException('Deprecated icons file not found: $path', exitCode: 2);
  }

  _log('🔍 Reading deprecations: ${p.relative(path, from: scriptDir)}');

  final icons = <DeprecatedIcon>[];
  final lines = file.readAsLinesSync();
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i].trim();
    if (line.isEmpty || line.startsWith('#')) continue;

    final parts = line.split(';').map((part) => part.trim()).toList();
    if (parts.length != 3 || parts.any((part) => part.isEmpty)) {
      throw IconGeneratorException(
        'Malformed deprecation on ${p.basename(path)}:${i + 1}: "$line". '
        'Expected `deprecated;replacement;included`.',
        exitCode: 2,
      );
    }

    final included = switch (parts[2]) {
      'true' => true,
      'false' => false,
      _ => throw IconGeneratorException(
        'Malformed deprecation on ${p.basename(path)}:${i + 1}: '
        '"${parts[2]}" is not `true` or `false`.',
        exitCode: 2,
      ),
    };

    icons.add(DeprecatedIcon(name: parts[0], replacement: parts[1], included: included));
  }

  _log('   └─ ${icons.length} deprecated ${icons.length == 1 ? 'icon' : 'icons'}');
  return icons;
}

/// Annotates or removes the [StreamIconData] constants of deprecated icons.
///
/// The glyph itself is never touched — it stays in the font at its original
/// code point. Included icons only gain a `@Deprecated` annotation; excluded
/// ones lose their constant so they disappear from the public API.
String _applyDeprecations(String iconDataContent, List<DeprecatedIcon> deprecatedIcons) {
  var content = iconDataContent;

  for (final icon in deprecatedIcons) {
    final constantName = icon.name.camelCase;
    // Matches the doc comment plus the declaration, including the blank line
    // that separates it from the previous constant.
    final declaration = RegExp(
      '(\\n  /// Font icon named "__${constantName}__"\\n(?:  ///[^\\n]*\\n)*)'
      '(  static const IconData $constantName = IconData\\([^\\n]*\\n)',
    );

    if (!declaration.hasMatch(content)) {
      throw IconGeneratorException(
        'Deprecated icon "${icon.name}" has no generated constant — '
        'is it listed in _excludedSvgIcons?',
        exitCode: 2,
      );
    }

    content = icon.included
        ? content.replaceFirstMapped(
            declaration,
            (m) => "${m[1]}  @Deprecated('${icon.deprecationMessage}')\n${m[2]}",
          )
        : content.replaceFirst(declaration, '');
  }

  return content;
}

/// Extracts icon entries from glyph list.
///
/// Deprecated icons are dropped when they are not `included`, and carry a
/// deprecation message when they are. Either way their glyph stays in the font.
List<IconEntry> _extractIconEntries(List<GenericGlyph> glyphList, List<DeprecatedIcon> deprecatedIcons) {
  final deprecatedByFieldName = {for (final icon in deprecatedIcons) icon.name.camelCase: icon};

  return glyphList
      .where((g) => g.metadata.name?.isNotEmpty ?? false)
      .map((g) => IconEntry.fromGlyphName(g.metadata.name!))
      .where((e) => deprecatedByFieldName[e.fieldName]?.included ?? true)
      .map((e) => e.deprecatedWith(deprecatedByFieldName[e.fieldName]))
      .toList()
    ..sort((a, b) => a.fieldName.compareTo(b.fieldName));
}

/// Reads SVG icon filenames from a directory and creates entries.
///
/// Returns an empty list if the directory does not exist.
List<SvgIconEntry> _extractSvgIconEntries(String directory, String configDir) {
  final dir = Directory(directory);
  if (!dir.existsSync()) return [];

  final svgFiles = dir.listSync().whereType<File>().where((f) => p.extension(f.path).toLowerCase() == '.svg').toList()
    ..sort((a, b) => p.basename(a.path).compareTo(p.basename(b.path)));

  return svgFiles.map((f) => SvgIconEntry.fromFile(f.path, configDir)).toList()
    ..sort((a, b) => a.fieldName.compareTo(b.fieldName));
}

// =============================================================================
// StreamSvgIconData Class Generation
// =============================================================================

/// Generates the [StreamSvgIconData] holder class with colored SVG icon
/// constants.
String _generateSvgIconDataClass({
  required List<SvgIconEntry> entries,
  required String className,
  required String package,
}) {
  final clazz = Class(
    (b) => b
      ..docs.add(
        '/// Colored SVG icon data constants.\n'
        '///\n'
        '/// These icons preserve their original colors and should be used with\n'
        '/// [SvgIcon] widget, not the standard [Icon] widget.',
      )
      ..name = className
      ..constructors.add(
        Constructor(
          (c) => c
            ..constant = true
            ..name = '_',
        ),
      )
      ..fields.addAll([
        Field(
          (f) => f
            ..static = true
            ..modifier = FieldModifier.constant
            ..type = refer('String')
            ..name = '_package'
            ..assignment = Code("'$package'"),
        ),
        ...entries.map(
          (e) => Field(
            (f) => f
              ..docs.add('/// The ${e.humanReadable} colored SVG icon.')
              ..static = true
              ..modifier = FieldModifier.constant
              ..type = refer('SvgIconData')
              ..name = e.fieldName
              ..assignment = Code("SvgIconData('${e.assetPath}', package: _package, preserveColors: true)"),
          ),
        ),
      ]),
  );

  final emitter = DartEmitter(useNullSafetySyntax: true);
  return clazz.accept(emitter).toString();
}

// =============================================================================
// StreamIcons Class Generation
// =============================================================================

String _generateClass({
  required List<IconEntry> iconEntries,
  required String className,
  required String dataClassName,
  required String svgIconDataClassName,
  required String iconDataFileName,
  required String outputFileName,
  List<SvgIconEntry> svgIconEntries = const [],
}) {
  final partThemeFileName = outputFileName.replaceFirst('.dart', '.g.theme.dart');
  final hasSvgIcons = svgIconEntries.isNotEmpty;
  // `allIcons` and the constructor defaults reference the deprecated icons this
  // class deliberately keeps, so the whole file opts out of the lint.
  final hasDeprecatedIcons = iconEntries.any((e) => e.deprecationMessage != null);

  final clazz = Class(
    (b) => b
      ..docs.add(_buildClassDocs(className, dataClassName))
      ..annotations.addAll([refer('themeGen'), refer('immutable')])
      ..name = className
      ..mixins.add(refer('_\$$className'))
      ..constructors.add(
        _buildConstructor(iconEntries, dataClassName, svgIconEntries, svgIconDataClassName),
      )
      ..fields.addAll([..._buildFields(iconEntries), ..._buildSvgIconFields(svgIconEntries)])
      ..methods.addAll(_buildMethods(iconEntries, className, svgIconEntries)),
  );

  final library = Library(
    (b) => b
      ..comments.addAll([
        'GENERATED CODE - DO NOT MODIFY BY HAND',
        'Generated by scripts/generate_icons.dart',
        '',
        'To regenerate: melos run generate:icons',
        if (hasDeprecatedIcons) ...['', 'ignore_for_file: deprecated_member_use_from_same_package'],
      ])
      ..directives.addAll([
        Directive.import('package:flutter/widgets.dart'),
        if (hasSvgIcons) Directive.import('package:svg_icon_widget/svg_icon_widget.dart'),
        Directive.import('package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart'),
        Directive.part(partThemeFileName),
        Directive.part(iconDataFileName),
      ])
      ..body.add(clazz),
  );

  final emitter = DartEmitter(useNullSafetySyntax: true);
  return library.accept(emitter).toString();
}

Constructor _buildConstructor(
  List<IconEntry> entries,
  String iconsClassName, [
  List<SvgIconEntry> svgEntries = const [],
  String svgIconDataClassName = '',
]) {
  return Constructor(
    (c) => c
      ..constant = true
      ..docs.add('/// Creates an icon set with optional overrides.')
      ..optionalParameters.addAll([
        ...entries.map(
          (e) => Parameter(
            (p) => p
              ..name = e.fieldName
              ..named = true
              ..toThis = true
              ..annotations.addAll(_deprecatedAnnotation(e))
              ..defaultTo = Code('$iconsClassName.${e.constantName}'),
          ),
        ),
        ...svgEntries.map(
          (e) => Parameter(
            (p) => p
              ..name = e.fieldName
              ..named = true
              ..toThis = true
              ..defaultTo = Code('$svgIconDataClassName.${e.fieldName}'),
          ),
        ),
      ]),
  );
}

Iterable<Field> _buildFields(List<IconEntry> entries) {
  return entries.map(
    (e) => Field(
      (f) => f
        ..docs.add('/// The ${e.humanReadable} icon.')
        ..annotations.addAll(_deprecatedAnnotation(e))
        ..modifier = FieldModifier.final$
        ..type = refer('IconData')
        ..name = e.fieldName,
    ),
  );
}

/// The `@Deprecated` annotation for [entry], or nothing if it is not deprecated.
Iterable<Expression> _deprecatedAnnotation(IconEntry entry) {
  final message = entry.deprecationMessage;
  return [
    if (message != null) refer('Deprecated').call([literalString(message)]),
  ];
}

Iterable<Field> _buildSvgIconFields(List<SvgIconEntry> entries) {
  return entries.map(
    (e) => Field(
      (f) => f
        ..docs.add(
          '/// The ${e.humanReadable} colored SVG icon.\n///\n/// This is an [SvgIconData] — use with [SvgIcon], not [Icon].',
        )
        ..modifier = FieldModifier.final$
        ..type = refer('SvgIconData')
        ..name = e.fieldName,
    ),
  );
}

Iterable<Method> _buildMethods(
  List<IconEntry> entries,
  String className, [
  List<SvgIconEntry> svgEntries = const [],
]) {
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
    // allSvgIcons getter (only when SVG icons exist)
    if (svgEntries.isNotEmpty)
      Method(
        (m) => m
          ..docs.add(_allSvgIconsDoc)
          ..type = MethodType.getter
          ..returns = refer('Map<String, SvgIconData>')
          ..name = 'allSvgIcons'
          ..lambda = true
          ..body = Code('{${svgEntries.map((e) => "'${e.fieldName}': ${e.fieldName}").join(', ')}}'),
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

const _allSvgIconsDoc = '''
/// A map of all colored SVG icons keyed by their field name.
///
/// These icons preserve their original colors and should be used with
/// [SvgIcon] widget, not the standard [Icon] widget.
///
/// ```dart
/// final icon = context.streamIcons.allSvgIcons['giphy'];
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
    this.deprecationMessage,
  });

  /// Creates an entry from a glyph name (e.g., "__IconFlag2__").
  factory IconEntry.fromGlyphName(String glyphName) {
    final sanitized = _sanitizeName(glyphName);
    final withoutPrefix = sanitized.startsWith('Icon') ? sanitized.substring(4) : sanitized;

    return IconEntry(
      fieldName: ReCase(withoutPrefix).camelCase,
      constantName: ReCase(sanitized).camelCase,
      humanReadable: ReCase(withoutPrefix).sentenceCase.toLowerCase(),
    );
  }

  final String fieldName;
  final String constantName;
  final String humanReadable;

  /// The `@Deprecated` message to emit, or `null` when the icon is current.
  final String? deprecationMessage;

  /// Returns a copy carrying [icon]'s deprecation message, or this entry
  /// unchanged when [icon] is `null`.
  IconEntry deprecatedWith(DeprecatedIcon? icon) {
    if (icon == null) return this;
    return IconEntry(
      fieldName: fieldName,
      constantName: constantName,
      humanReadable: humanReadable,
      deprecationMessage: icon.deprecationMessage,
    );
  }

  /// Sanitizes a name to be a valid Dart identifier.
  static String _sanitizeName(String name) {
    return name
        .replaceAll(RegExp(r'^_+|_+$'), '') // Remove leading/trailing underscores
        .replaceAllMapped(RegExp(r'[-_](\d)'), (m) => m.group(1)!) // Remove separators before digits
        .replaceAllMapped(RegExp('[-_]([a-zA-Z])'), (m) => m.group(1)!.toUpperCase()); // camelCase
  }
}

/// An icon that is on its way out, as declared in the deprecated icons file.
///
/// The glyph is always kept in the font so that removing an icon never shifts
/// the code points of the icons that come after it. [replacement] names the icon
/// whose SVG draws that glyph — it may be [name] itself, which keeps the
/// original artwork while still retiring the name.
class DeprecatedIcon {
  const DeprecatedIcon({
    required this.name,
    required this.replacement,
    required this.included,
  });

  /// The deprecated icon's file name, without extension (e.g. `more`).
  final String name;

  /// The icon whose SVG draws this glyph (e.g. `more-horizontal`).
  final String replacement;

  /// Whether the icon is still exposed in the generated Dart classes.
  ///
  /// When `true` it is generated with a `@Deprecated` annotation; when `false`
  /// it is left out entirely and only the font glyph remains.
  final bool included;

  /// Whether the icon keeps drawing its own artwork.
  bool get isSelfReplacing => name == replacement;

  /// The message for the generated `@Deprecated` annotation.
  String get deprecationMessage =>
      isSelfReplacing ? 'This icon will be removed in a future release.' : 'Use ${replacement.camelCase} instead.';
}

/// Represents a single colored SVG icon with its naming variants and asset path.
class SvgIconEntry {
  const SvgIconEntry({
    required this.fieldName,
    required this.assetPath,
    required this.humanReadable,
  });

  /// Creates an entry from an SVG file path.
  ///
  /// Strips the `icon_` prefix from the filename and converts to camelCase.
  /// The [assetPath] is computed relative to [configDir].
  factory SvgIconEntry.fromFile(String filePath, String configDir) {
    final baseName = p.basenameWithoutExtension(filePath);
    final withoutPrefix = baseName.startsWith('icon_') ? baseName.substring(5) : baseName;

    return SvgIconEntry(
      fieldName: ReCase(withoutPrefix).camelCase,
      assetPath: p.relative(filePath, from: configDir),
      humanReadable: ReCase(withoutPrefix).sentenceCase.toLowerCase(),
    );
  }

  final String fieldName;
  final String assetPath;
  final String humanReadable;
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

const _excludedSvgIcons = [
  // Multi color icons are added separately
  'giphy',
  'imgur',
  // Loading icons are a Flutter widget
  'loading',
];

const _rtlIcons = [
  'arrow-left',
  'arrow-right',
  'arrow-up-right',
  'audio',
  'chevron-left',
  'chevron-right',
  'leave',
  'megaphone',
  'mute',
  'reply',
  'search',
  'send',
  'sidebar',
  'video',
  'video-fill',
];
