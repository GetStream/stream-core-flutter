/// Style Guide Sync
///
/// Copies the shared style guides in `style_guides/` into another Stream
/// Flutter SDK checkout. The other repositories carry a copy rather than a
/// link, so their contributors and agents read the rules locally instead of
/// fetching them from this repository.
///
/// The guides are self-contained: they may link to each other and to absolute
/// URLs, but never to a file outside `style_guides/` (such as
/// `../STYLE_GUIDE.md`), because the copies land in repositories that have no
/// such file.
///
/// Usage (from anywhere in the monorepo):
///   melos run check:style_guides
///
/// Or directly:
///   dart run scripts/sync_style_guides.dart --check
///   dart run scripts/sync_style_guides.dart `<target-repo-dir>`
///
/// The `sync_style_guides` workflow runs it against each target on every
/// change to `main`, and opens a pull request in each one whose copy changed.
///
/// Steps:
///   1. Fails if a guide is itself a synced copy, or links to a relative path
///      outside `style_guides/`. With `--check`, stops there.
///   2. Writes each guide into `<target>/style_guides/` under a header naming
///      its source.
///   3. Deletes a guide from the target that no longer exists here, but only
///      if it carries that header, so a target's own files are never touched.
///
/// Exits 0 on success, 1 on failure, and 64 on a usage error.
library;

import 'dart:io';

import 'package:path/path.dart' as p;

const _sourceDir = 'style_guides';
const _syncMarker = '<!-- Synced from GetStream/stream-core-flutter';

String _header(String fileName) =>
    '$_syncMarker/$_sourceDir/$fileName. '
    'Do not edit this copy; change it upstream and the sync opens a PR here. -->\n\n';

// Matches the target of an inline markdown link or a reference definition, e.g.
// `](../STYLE_GUIDE.md#x)` or `]: ../STYLE_GUIDE.md`. Angle-bracket targets
// (`](<../x.md>)`) and raw HTML links are not matched, and a target inside the
// folder is not checked to exist.
final _linkTarget = RegExp(r'(?:\]\(|\]:[ \t]*)([^)\s]+)');

void main(List<String> args) {
  if (args.length != 1) {
    stderr.writeln('Usage: dart run scripts/sync_style_guides.dart (<target-repo-dir> | --check)');
    exit(64);
  }

  // Resolved from the script's own location rather than the caller's cwd, so
  // running it from a repository that holds synced copies cannot pick those up
  // as the source.
  final repoRoot = p.dirname(p.dirname(p.fromUri(Platform.script)));
  final source = Directory(p.join(repoRoot, _sourceDir));
  if (!source.existsSync()) {
    stderr.writeln('No `$_sourceDir/` in $repoRoot.');
    exit(1);
  }

  final guides = source.listSync().whereType<File>().where((f) => f.path.endsWith('.md')).toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  if (guides.isEmpty) {
    stderr.writeln('`$_sourceDir/` has no guides to copy.');
    exit(1);
  }

  final copies = [
    for (final guide in guides)
      if (guide.readAsStringSync().startsWith(_syncMarker)) p.relative(guide.path, from: repoRoot),
  ];
  if (copies.isNotEmpty) {
    stderr
      ..writeln('These are synced copies, not sources; edit the guides in stream-core-flutter:')
      ..writeAll(copies.map((c) => '  $c\n'));
    exit(1);
  }

  final escaping = [for (final guide in guides) ..._linksLeavingFolder(guide, source.path, repoRoot)];
  if (escaping.isNotEmpty) {
    stderr
      ..writeln('Guides in `$_sourceDir/` must not link outside the folder; use an absolute URL or drop the link:')
      ..writeAll(escaping.map((e) => '  $e\n'));
    exit(1);
  }

  if (args.single == '--check') {
    stdout.writeln('Checked ${guides.length} guide(s); no links leave $_sourceDir/');
    return;
  }

  final targetRoot = Directory(args.single);
  if (!FileSystemEntity.isDirectorySync(p.join(targetRoot.path, '.git')) &&
      !FileSystemEntity.isFileSync(p.join(targetRoot.path, '.git'))) {
    stderr.writeln('`${targetRoot.path}` is not a git checkout.');
    exit(1);
  }

  final target = Directory(p.join(targetRoot.path, _sourceDir))..createSync(recursive: true);
  final copied = <String>{};

  for (final guide in guides) {
    final name = p.basename(guide.path);
    File(p.join(target.path, name)).writeAsStringSync(_header(name) + guide.readAsStringSync());
    copied.add(name);
    stdout.writeln('Wrote $_sourceDir/$name');
  }

  for (final stale in target.listSync().whereType<File>()) {
    final name = p.basename(stale.path);
    if (copied.contains(name) || !name.endsWith('.md')) continue;
    if (!stale.readAsStringSync().startsWith(_syncMarker)) continue;
    stale.deleteSync();
    stdout.writeln('Deleted $_sourceDir/$name');
  }
}

// Returns `file:line: target` for every relative link in [guide] that resolves
// outside [sourceDir].
Iterable<String> _linksLeavingFolder(File guide, String sourceDir, String repoRoot) sync* {
  final lines = guide.readAsLinesSync();
  for (var i = 0; i < lines.length; i++) {
    for (final match in _linkTarget.allMatches(lines[i])) {
      final link = match[1]!;
      if (link.startsWith('#') || (Uri.tryParse(link)?.hasScheme ?? false)) continue;
      final path = link.split('#').first;
      if (p.isWithin(sourceDir, p.normalize(p.join(sourceDir, path)))) continue;
      yield '${p.relative(guide.path, from: repoRoot)}:${i + 1}: $link';
    }
  }
}
