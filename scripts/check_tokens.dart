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
// Every "nothing to check" path is a failure rather than a pass. A guard that
// exits 0 because it found nothing to inspect is worse than no guard: it prints
// the same tick as a real pass. So the package, the token directory, each
// per-mode file and the dimensions file must all exist, each must yield a
// plausible number of declarations, and the reference scan must actually open
// files.
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
///
/// An entry matching no declaration is itself a failure, so this cannot rot
/// into a list of names nobody can account for.
const _allowedUnused = <String>{};

const _packageName = 'stream_core_flutter';
const _tokenDir = 'lib/src/theme/primitives/internal/tokens';

/// Lower bound on the color constants each mode file must declare.
///
/// Guards against a parse that silently yields nothing — a reformat, a switch
/// to `static final`, a move to generated code. Deliberately far below the real
/// count (163 when this was written) so ordinary pruning never trips it.
const _minColorTokens = 50;

/// Lower bound on the dimension constants, on the same reasoning.
const _minDimensionTokens = 10;

void main(List<String> args) {
  // Resolved from the repo root rather than inherited from the caller's cwd,
  // so the check cannot be pointed at a package that has no tokens and pass.
  final packageRoot = args.isNotEmpty ? args.first : p.join(Directory.current.path, 'packages', _packageName);
  if (!Directory(packageRoot).existsSync()) {
    _fail(
      'Missing ${p.relative(packageRoot, from: Directory.current.path)}.\n'
      '  Run this from the repo root with `melos run check:tokens`, or pass\n'
      '  the package root as the first argument.',
    );
  }

  final tokenDir = Directory(p.join(packageRoot, _tokenDir));
  if (!tokenDir.existsSync()) {
    _fail(
      'Missing $_tokenDir.\n'
      '  If the vendored tokens moved, update _tokenDir here — do not let the\n'
      '  check quietly pass on a directory that is not there.',
    );
  }

  final libDir = Directory(p.join(packageRoot, 'lib'));
  if (!libDir.existsSync()) _fail('Missing lib/ in $_packageName.');

  final failures = <String>[];

  final declared = <String, Set<String>>{};
  for (final mode in const ['light', 'dark']) {
    final file = File(p.join(tokenDir.path, mode, 'stream_tokens.dart'));
    final label = p.relative(file.path, from: packageRoot);
    if (!file.existsSync()) _fail('Missing $label');
    declared[mode] = _declarations(file.readAsStringSync(), label);
    if (declared[mode]!.length < _minColorTokens) {
      _fail(
        'Only ${declared[mode]!.length} constants parsed from $label, expected at least $_minColorTokens.\n'
        '  Either the file shrank drastically or the declaration pattern no\n'
        '  longer matches it. Both mean this check has stopped checking.',
      );
    }
  }

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

  final modeFiles = {
    for (final mode in const ['light', 'dark']) p.normalize(p.join(tokenDir.path, mode, 'stream_tokens.dart')),
  };
  final colorScan = _references(libDir, modeFiles);
  if (colorScan.filesRead == 0) {
    _fail('Scanned no Dart files under lib/ — the reference search found nothing to read.');
  }

  final allColors = {...declared['light']!, ...declared['dark']!};
  final unused = allColors.where((name) => !colorScan.names.contains(name) && !_allowedUnused.contains(name)).toList()
    ..sort();
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
  final dimensionsLabel = p.relative(dimensionsFile.path, from: packageRoot);
  if (!dimensionsFile.existsSync()) _fail('Missing $dimensionsLabel');

  final declaredDimensions = _declarations(dimensionsFile.readAsStringSync(), dimensionsLabel);
  if (declaredDimensions.length < _minDimensionTokens) {
    _fail(
      'Only ${declaredDimensions.length} constants parsed from $dimensionsLabel, '
      'expected at least $_minDimensionTokens.',
    );
  }
  final dimensionScan = _references(libDir, {p.normalize(dimensionsFile.path)}, className: 'StreamTokensDimensions');
  final unusedDimensions =
      declaredDimensions.where((name) => !dimensionScan.names.contains(name) && !_allowedUnused.contains(name)).toList()
        ..sort();
  if (unusedDimensions.isNotEmpty) {
    failures.add(
      '${unusedDimensions.length} dimension token${unusedDimensions.length == 1 ? '' : 's'} '
      '${unusedDimensions.length == 1 ? 'is' : 'are'} never referenced:\n'
      '  ${_list(unusedDimensions)}\n'
      '  StreamSpacing, StreamRadius and StreamLineHeight are the only readers.\n'
      '  A dimension no class exposes belongs upstream, not here.',
    );
  }

  // Any other Dart file in the token directory is vendored too. Rather than
  // being invisible to this check, it has to be accounted for — that is how a
  // whole file of dead constants stayed hidden once already.
  final covered = {...modeFiles, p.normalize(dimensionsFile.path)};
  final uncovered =
      tokenDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart') && !covered.contains(p.normalize(f.path)))
          .map((f) => p.relative(f.path, from: packageRoot))
          .toList()
        ..sort();
  if (uncovered.isNotEmpty) {
    failures.add(
      '${uncovered.length} vendored token file${uncovered.length == 1 ? '' : 's'} '
      '${uncovered.length == 1 ? 'is' : 'are'} not covered by this check:\n'
      '  ${_list(uncovered)}\n'
      '  Give it a branch here, or delete it. A vendored file this check cannot\n'
      '  see is exactly the dead weight it exists to prevent.',
    );
  }

  // A name nobody declares cannot be "allowed to be unreferenced" — it is a
  // typo, or a leftover from a constant that has since been deleted.
  final staleAllowed = _allowedUnused.difference({...allColors, ...declaredDimensions}).toList()..sort();
  if (staleAllowed.isNotEmpty) {
    failures.add(
      '${staleAllowed.length} entr${staleAllowed.length == 1 ? 'y' : 'ies'} in _allowedUnused '
      'match${staleAllowed.length == 1 ? 'es' : ''} no declaration:\n'
      '  ${_list(staleAllowed)}\n'
      '  Remove them — an allowlist nobody can account for is not an allowlist.',
    );
  }

  if (failures.isNotEmpty) _fail(failures.join('\n\n'));

  stdout.writeln(
    '✓ ${declared['light']!.length} color tokens and ${declaredDimensions.length} dimension tokens, '
    'all referenced, light/ and dark/ in agreement '
    '(${colorScan.filesRead} Dart files scanned).',
  );
}

/// The `static const <name>` declarations in a vendored token file.
///
/// [source] is stripped of comments and string literals first, so a name in
/// prose is neither counted as a declaration nor able to keep a dead constant
/// alive. [label] names the file in any failure message.
Set<String> _declarations(String source, String label) {
  final code = _stripCommentsAndStrings(source);
  final names = RegExp(
    // The type annotation is optional: the color files omit it, the dimension
    // file needs `double` so its values satisfy Radius and TextStyle.
    r'static\s+const\s+(?:[\w<>?,\s]+\s+)?(\w+)\s*=',
  ).allMatches(code).map((m) => m.group(1)!).toSet();

  // A declaration this pattern misses is invisible to every check below — it
  // escapes both the dead-token scan and the light/dark parity check. Compare
  // against a count that cannot drift out of step with it.
  final occurrences = RegExp(r'static\s+const\s').allMatches(code).length;
  if (occurrences != names.length) {
    _fail(
      'Parsed ${names.length} declarations from $label but found $occurrences `static const` occurrences.\n'
      '  Some declaration form is not understood, and whatever this pattern\n'
      '  misses is silently exempt from every check below.',
    );
  }
  return names;
}

/// Result of a reference scan: the names found, and how many files were read.
///
/// The file count is what separates "nothing is unreferenced" from "nothing was
/// examined".
typedef _Scan = ({Set<String> names, int filesRead});

/// Every `<className>.<name>` reference under [libDir], ignoring the vendored
/// files in [declaringFiles] so a declaration does not count as its own use.
///
/// Comments and string literals are stripped before matching. Without that a
/// stale `[StreamTokens.foo]` in a doc comment keeps a dead constant alive —
/// and `comment_references` is disabled in `analysis_options.yaml`, so such a
/// reference is not even a lint.
_Scan _references(Directory libDir, Set<String> declaringFiles, {String className = 'StreamTokens'}) {
  final pattern = RegExp(
    '$className'
    r'\.(\w+)',
  );
  final found = <String>{};
  var filesRead = 0;
  for (final entity in libDir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    if (declaringFiles.contains(p.normalize(entity.path))) continue;
    filesRead++;
    found.addAll(pattern.allMatches(_stripCommentsAndStrings(entity.readAsStringSync())).map((m) => m.group(1)!));
  }
  return (names: found, filesRead: filesRead);
}

/// Drops comments and string literals, keeping everything else verbatim.
///
/// Crude on purpose: it only has to be right for the vendored token files and
/// the primitives that read them, which are constant declarations and field
/// defaults rather than arbitrary Dart.
String _stripCommentsAndStrings(String source) {
  final out = StringBuffer();
  var i = 0;
  while (i < source.length) {
    if (source.startsWith('//', i)) {
      while (i < source.length && source[i] != '\n') {
        i++;
      }
      continue;
    }
    if (source.startsWith('/*', i)) {
      final end = source.indexOf('*/', i + 2);
      i = end == -1 ? source.length : end + 2;
      continue;
    }
    final ch = source[i];
    if (ch == "'" || ch == '"') {
      final delim = source.startsWith(ch * 3, i) ? ch * 3 : ch;
      i += delim.length;
      while (i < source.length) {
        if (source[i] == r'\') {
          i += 2;
          continue;
        }
        if (source.startsWith(delim, i)) {
          i += delim.length;
          break;
        }
        i++;
      }
      continue;
    }
    out.write(ch);
    i++;
  }
  return out.toString();
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
