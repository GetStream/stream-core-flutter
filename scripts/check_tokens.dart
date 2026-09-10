// Verifies the vendored design-token files carry nothing dead.
//
// `lib/src/theme/primitives/internal/tokens/{light,dark}/stream_tokens.dart`
// mirror a fraction of what the design-token repo publishes, by design: only
// the root semantics live there, and a component's values are re-derived from
// those in its own defaults. Nothing enforced that, so the files had grown to
// 502 constants of which 163 were read — two thirds dead weight, and every
// unread constant an invitation to reach for a token where a `colorScheme`
// field was meant.
//
// This check fails when a constant is declared and never referenced, and when
// the light and dark files disagree about which constants exist. It covers the
// mode-independent dimension tokens next to them on the same terms.
//
// Run with `melos run check:tokens`.
import 'dart:io';

import 'package:path/path.dart' as p;

/// Names that are allowed to be unreferenced.
///
/// Empty, and worth keeping that way — an entry here is a token the SDK
/// carries without using. Prefer deleting the constant and re-adding it when a
/// component needs it, since the design-token repo remains the source of truth
/// either way.
const _allowedUnused = <String>{};

const _tokenDir = 'lib/src/theme/primitives/internal/tokens';

void main(List<String> args) {
  final packageRoot = Directory.current.path;
  final tokenDir = Directory(p.join(packageRoot, _tokenDir));
  if (!tokenDir.existsSync()) {
    stdout.writeln('No vendored tokens in ${p.basename(packageRoot)}, skipping.');
    return;
  }

  final declared = <String, Set<String>>{};
  for (final mode in const ['light', 'dark']) {
    final file = File(p.join(tokenDir.path, mode, 'stream_tokens.dart'));
    if (!file.existsSync()) _fail('Missing ${p.relative(file.path, from: packageRoot)}');
    declared[mode] = _declarations(file.readAsStringSync());
  }

  final failures = <String>[];

  // Both modes must declare the same names — a field that resolves from a
  // constant in one mode and not the other silently falls back.
  final onlyLight = declared['light']!.difference(declared['dark']!);
  final onlyDark = declared['dark']!.difference(declared['light']!);
  if (onlyLight.isNotEmpty || onlyDark.isNotEmpty) {
    failures.add(
      'light/ and dark/ declare different constants.\n'
      '${onlyLight.isEmpty ? '' : '  only in light/: ${_list(onlyLight)}\n'}'
      '${onlyDark.isEmpty ? '' : '  only in dark/:  ${_list(onlyDark)}'}',
    );
  }

  final declaringFiles = {
    for (final mode in const ['light', 'dark']) p.normalize(p.join(tokenDir.path, mode, 'stream_tokens.dart')),
  };
  final referenced = _references(Directory(p.join(packageRoot, 'lib')), declaringFiles);
  final unused = {
    ...declared['light']!,
    ...declared['dark']!,
  }.where((name) => !referenced.contains(name) && !_allowedUnused.contains(name)).toList()..sort();

  if (unused.isNotEmpty) {
    failures.add(
      '${unused.length} vendored token${unused.length == 1 ? '' : 's'} '
      '${unused.length == 1 ? 'is' : 'are'} never referenced:\n'
      '  ${_list(unused)}\n'
      '  Only the root semantics belong here. A component derives its values\n'
      '  from a StreamColorScheme field, so a token no field reads is dead —\n'
      '  delete it, or wire up the field that should read it.',
    );
  }

  // The dimension tokens sit beside the per-mode files rather than inside them,
  // because the token repo publishes one set for every mode. Same rule: a
  // constant no class reads is dead weight.
  final dimensionsFile = File(p.join(tokenDir.path, 'stream_tokens_dimensions.dart'));
  var dimensions = 0;
  if (dimensionsFile.existsSync()) {
    final declaredDimensions = _declarations(dimensionsFile.readAsStringSync());
    dimensions = declaredDimensions.length;
    final readDimensions = _references(
      Directory(p.join(packageRoot, 'lib')),
      {p.normalize(dimensionsFile.path)},
      className: 'StreamTokensDimensions',
    );
    final unusedDimensions =
        declaredDimensions.where((name) => !readDimensions.contains(name) && !_allowedUnused.contains(name)).toList()
          ..sort();
    if (unusedDimensions.isNotEmpty) {
      failures.add(
        '${unusedDimensions.length} dimension token${unusedDimensions.length == 1 ? '' : 's'} '
        '${unusedDimensions.length == 1 ? 'is' : 'are'} never referenced:\n'
        '  ${_list(unusedDimensions)}\n'
        '  StreamSpacing, StreamRadius and StreamTokensTypography are the only\n'
        '  readers. A dimension no class exposes belongs upstream, not here.',
      );
    }
  }

  if (failures.isNotEmpty) _fail(failures.join('\n\n'));

  stdout.writeln(
    '✓ ${declared['light']!.length} color tokens and $dimensions dimension tokens, '
    'all referenced, light/ and dark/ in agreement.',
  );
}

/// The `static const <name>` declarations in a vendored token file.
Set<String> _declarations(String source) => RegExp(
  // The type annotation is optional: the color files omit it, the dimension
  // file needs `double` so its values satisfy Radius and TextStyle.
  r'static const (?:[\w<>?]+\s+)?(\w+)\s*=',
).allMatches(source).map((m) => m.group(1)!).toSet();

/// Every `<className>.<name>` reference under [libDir], ignoring the vendored
/// files themselves so a declaration does not count as its own use.
///
/// The typography and dimension files do read each other, so they are excluded
/// as declarations but not as readers — hence the per-file skip rather than a
/// whole-directory one.
Set<String> _references(
  Directory libDir,
  Set<String> declaringFiles, {
  String className = 'StreamTokens',
}) {
  final pattern = RegExp(
    '$className'
    r'\.(\w+)',
  );
  final found = <String>{};
  for (final entity in libDir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    if (declaringFiles.contains(p.normalize(entity.path))) continue;
    found.addAll(pattern.allMatches(entity.readAsStringSync()).map((m) => m.group(1)!));
  }
  return found;
}

String _list(Iterable<String> names) {
  final sorted = names.toList()..sort();
  if (sorted.length <= 12) return sorted.join(', ');
  return '${sorted.take(12).join(', ')} … and ${sorted.length - 12} more';
}

Never _fail(String message) {
  stderr.writeln('✗ $message');
  exit(1);
}
