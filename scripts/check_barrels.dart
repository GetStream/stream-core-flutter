/// Public-Barrel Coverage Checker
///
/// Validates that every public source file in a package is exported by
/// exactly one of its public barrels, and that no internal source file
/// imports those barrels.
///
/// Driven by a `check_barrels.yaml` config file in the current directory.
/// See `packages/stream_core_flutter/check_barrels.yaml` for the schema.
///
/// Usage (run from the package root):
///   dart run $MELOS_ROOT_PATH/scripts/check_barrels.dart
///
/// Or via melos from anywhere in the monorepo:
///   melos run check:barrels
///
/// Checks performed:
///   1. Every public file under `lib/src/` is exported by exactly one barrel.
///      Generated files (`.g.dart`, `.g.theme.dart`, `.freezed.dart`), `part
///      of` files, and anything under an `internal_dirs` path are skipped.
///   2. Every barrel export resolves to an existing file.
///   3. No file under `lib/src/` imports a `forbidden_src_imports` entry.
///
/// Exits 0 on success, 1 on failure.
library;

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

// =============================================================================
// Configuration
// =============================================================================

const _kDefaultConfigFile = 'check_barrels.yaml';

// Implementation root convention for Dart packages.
const _kSourceRoot = 'lib/src';

// Generated file patterns that should never appear in a public barrel.
final _kGeneratedPatterns = [
  RegExp(r'\.g\.dart$'),
  RegExp(r'\.g\.theme\.dart$'),
  RegExp(r'\.freezed\.dart$'),
];

final _kExportRegex = RegExp(r"^export\s+'([^']+\.dart)'");
final _kImportRegex = RegExp(r"^\s*import\s+'([^']+)'");

// Configuration for the barrel checker, loaded from `check_barrels.yaml`.
class _Config {
  _Config({
    required this.packageName,
    required this.barrels,
    required this.forbiddenSrcImports,
    required this.internalDirs,
  });

  // Loads configuration from a YAML file.
  factory _Config.fromYaml(String yamlPath) {
    final yaml = loadYaml(File(yamlPath).readAsStringSync()) as YamlMap;

    List<String> stringList(String key) {
      final value = yaml[key];
      if (value == null) return const [];
      return (value as YamlList).cast<String>().toList();
    }

    return _Config(
      packageName: yaml['package_name'] as String,
      barrels: stringList('barrels'),
      forbiddenSrcImports: stringList('forbidden_src_imports'),
      internalDirs: stringList('internal_dirs').toSet(),
    );
  }

  // The package's `name:` from its `pubspec.yaml`. Used to detect
  // `package:` self-imports of the barrels from within `lib/src/`.
  final String packageName;

  // Public-barrel paths (relative to the package root). Every public file
  // under `lib/src/` must appear in exactly one of these.
  final List<String> barrels;

  // Library paths that files under `lib/src/` must never import. Typically
  // the barrels themselves plus any deprecated entry points.
  final List<String> forbiddenSrcImports;

  // Exact directory paths (relative to the package root) whose contents are
  // internal-only and excluded from the coverage check.
  final Set<String> internalDirs;
}

// Categorises an issue so the report can group + hint by kind.
enum _IssueKind {
  setup('Setup', 'Fix the configuration before re-running.'),
  coverage('Coverage gaps', 'Add the file to one of the public barrels (or move it under an internal_dirs path).'),
  duplicate('Duplicate exports', 'Remove the entry from all but one barrel.'),
  dangling('Dangling exports', 'The export points at a missing file — delete the export or restore the file.'),
  forbiddenImport('Forbidden barrel imports', 'Replace with a specific relative import to the source file.');

  const _IssueKind(this.title, this.hint);
  final String title;
  final String hint;
}

class _Issue {
  _Issue(this.kind, this.message);
  final _IssueKind kind;
  final String message;
}

// =============================================================================
// Main Entry Point
// =============================================================================

Future<void> main() async {
  final root = Directory.current.path;
  final configPath = p.join(root, _kDefaultConfigFile);
  if (!File(configPath).existsSync()) {
    stderr.writeln("[FAIL] Missing '$_kDefaultConfigFile' in $root");
    exitCode = 1;
    return;
  }

  final config = _Config.fromYaml(configPath);
  final issues = <_Issue>[];

  // 1. Collect every public source file under lib/src/.
  final srcFiles = await _collectPublicSrcFiles(root, config);

  // 2. Parse each barrel's exports and verify coverage.
  final exportedBy = _buildExportIndex(root, config, issues);
  _checkCoverage(srcFiles, exportedBy, issues);
  _checkDanglingExports(root, exportedBy, issues);

  // 3. Make sure no file under lib/src/ imports a forbidden barrel.
  await _checkForbiddenSrcImports(root, config, issues);

  _report(config, srcFiles.length, issues);
}

// =============================================================================
// Checks
// =============================================================================

// Walks `lib/src/` and returns the set of relative paths considered public.
Future<Set<String>> _collectPublicSrcFiles(String root, _Config config) async {
  final files = <String>{};
  await for (final entity in Directory(p.join(root, _kSourceRoot)).list(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final rel = p.relative(entity.path, from: root);
    if (_isInternalPath(rel, config) || _isGenerated(rel)) continue;
    if (_isPartFile(await entity.readAsString())) continue;
    files.add(rel);
  }
  return files;
}

// Parses each barrel's exports and returns a `file -> [barrels]` index. Also
// records a `setup` issue for any missing barrel.
Map<String, List<String>> _buildExportIndex(String root, _Config config, List<_Issue> issues) {
  final exportedBy = <String, List<String>>{};
  for (final barrel in config.barrels) {
    final file = File(p.join(root, barrel));
    if (!file.existsSync()) {
      issues.add(_Issue(_IssueKind.setup, 'Barrel not found: $barrel'));
      continue;
    }
    for (final exported in _readBarrelExports(file, barrel)) {
      exportedBy.putIfAbsent(exported, () => []).add(barrel);
    }
  }
  return exportedBy;
}

// Verifies the `file -> [barrels]` index against the discovered source set:
// every src file must be exported by exactly one barrel.
void _checkCoverage(Set<String> srcFiles, Map<String, List<String>> exportedBy, List<_Issue> issues) {
  for (final entry in exportedBy.entries) {
    if (entry.value.length > 1) {
      issues.add(
        _Issue(
          _IssueKind.duplicate,
          '${entry.key}  →  exported by ${entry.value.join(' and ')}',
        ),
      );
    }
  }
  for (final path in srcFiles) {
    if (!exportedBy.containsKey(path)) {
      issues.add(_Issue(_IssueKind.coverage, path));
    }
  }
}

// Catches barrels that re-export deleted/moved files.
void _checkDanglingExports(String root, Map<String, List<String>> exportedBy, List<_Issue> issues) {
  for (final entry in exportedBy.entries) {
    if (!File(p.join(root, entry.key)).existsSync()) {
      issues.add(
        _Issue(
          _IssueKind.dangling,
          '${entry.key}  ←  ${entry.value.join(', ')}',
        ),
      );
    }
  }
}

// Scans every file under `lib/src/` and flags imports of a forbidden barrel
// — whether expressed as a `package:` URI or a relative path.
Future<void> _checkForbiddenSrcImports(String root, _Config config, List<_Issue> issues) async {
  final forbiddenPackageUris = config.forbiddenSrcImports
      .map((libPath) => _packageUri(config.packageName, libPath))
      .toSet();

  await for (final entity in Directory(p.join(root, _kSourceRoot)).list(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final rel = p.relative(entity.path, from: root);
    if (_isGenerated(rel)) continue;
    final src = await entity.readAsString();
    if (_isPartFile(src)) continue;

    for (final line in const LineSplitter().convert(src)) {
      final match = _kImportRegex.firstMatch(line);
      if (match == null) continue;
      final uri = match.group(1)!;
      if (forbiddenPackageUris.contains(uri) || _resolvesToForbidden(rel, uri, config.forbiddenSrcImports)) {
        issues.add(_Issue(_IssueKind.forbiddenImport, '$rel  →  imports $uri'));
      }
    }
  }
}

// =============================================================================
// Reporting
// =============================================================================

// Prints a grouped, human-readable report and sets `exitCode` on failure.
void _report(_Config config, int srcCount, List<_Issue> issues) {
  if (issues.isEmpty) {
    stdout.writeln('[OK] Barrel check passed for ${config.packageName}');
    stdout.writeln('     $srcCount public files in $_kSourceRoot, all classified by:');
    for (final barrel in config.barrels) {
      stdout.writeln('       - $barrel');
    }
    return;
  }

  final byKind = <_IssueKind, List<_Issue>>{};
  for (final issue in issues) {
    byKind.putIfAbsent(issue.kind, () => []).add(issue);
  }

  stderr.writeln('[FAIL] Barrel check failed for ${config.packageName}  (${issues.length} issue(s))');
  for (final kind in _IssueKind.values) {
    final group = byKind[kind];
    if (group == null || group.isEmpty) continue;
    stderr
      ..writeln()
      ..writeln('  ${kind.title}  (${group.length})')
      ..writeln('  hint: ${kind.hint}');
    final sorted = [...group]..sort((a, b) => a.message.compareTo(b.message));
    for (final issue in sorted) {
      stderr.writeln('    • ${issue.message}');
    }
  }
  exitCode = 1;
}

// =============================================================================
// Helpers
// =============================================================================

// `true` if [rel] sits inside one of the configured internal directories.
bool _isInternalPath(String rel, _Config config) => config.internalDirs.any((dir) => p.isWithin(dir, rel));

// `true` for build-time generated artefacts that should never be barrelled.
bool _isGenerated(String rel) => _kGeneratedPatterns.any((pattern) => pattern.hasMatch(rel));

// `true` if [src] is a `part of` file (and so contributes no top-level
// declarations of its own).
bool _isPartFile(String src) {
  for (final line in const LineSplitter().convert(src)) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('//')) continue;
    return trimmed.startsWith('part of ');
  }
  return false;
}

// Builds the `package:<name>/<rel>.dart` URI for a path inside `lib/`.
String _packageUri(String packageName, String libPath) {
  final relToLib = p.relative(libPath, from: 'lib');
  return 'package:$packageName/$relToLib';
}

// `true` if a relative `import` from [fromRel] resolves to one of the
// forbidden paths.
bool _resolvesToForbidden(String fromRel, String importUri, List<String> forbidden) {
  if (importUri.startsWith('package:') || importUri.startsWith('dart:')) return false;
  final resolved = p.normalize(p.join(p.dirname(fromRel), importUri));
  return forbidden.contains(resolved);
}

// Returns the set of relative paths exported by [file], skipping any
// `package:` re-exports (which target other packages).
Set<String> _readBarrelExports(File file, String barrel) {
  final exports = <String>{};
  final barrelDir = p.dirname(barrel);
  for (final line in file.readAsLinesSync()) {
    final match = _kExportRegex.firstMatch(line.trim());
    if (match == null) continue;
    final target = match.group(1)!;
    if (target.startsWith('package:')) continue;
    exports.add(p.normalize(p.join(barrelDir, target)));
  }
  return exports;
}
