// Copies the shared style guides into another Stream Flutter SDK checkout.
//
// `style_guides/` holds the guides every Stream Flutter SDK follows. The other
// repositories carry a copy rather than a link, so their contributors and
// agents read the rules locally instead of fetching them from this repository.
// The `sync_style_guides` workflow runs this script against each of them and
// opens a pull request when the copy changes.
//
// The guides are self-contained: they may link to each other and to absolute
// URLs, but never to a file outside `style_guides/` (such as
// `../STYLE_GUIDE.md`). This repository's style guide points at them, not the
// other way around, and the copies land in repositories that have no such
// file. A relative link that leaves the folder fails the run.
//
// Each copy gets a header saying where it came from. A copied guide that no
// longer exists here is deleted from the target, but only if it carries the
// header, so a target's own files in `style_guides/` are never touched.
//
// Run with `dart run scripts/sync_style_guides.dart <target-repo-dir>`, or with
// `--check` instead of a target to only validate the links.
import 'dart:io';

import 'package:path/path.dart' as p;

const _sourceDir = 'style_guides';
const _syncMarker = '<!-- Synced from GetStream/stream-core-flutter';

String _header(String fileName) =>
    '$_syncMarker/$_sourceDir/$fileName. '
    'Do not edit this copy; change it upstream and the sync opens a PR here. -->\n\n';

// Matches the target of an inline markdown link or a reference definition, e.g.
// `](../STYLE_GUIDE.md#x)` or `]: ../STYLE_GUIDE.md`.
final _linkTarget = RegExp(r'(?:\]\(|\]:[ \t]*)([^)\s]+)');

void main(List<String> args) {
  if (args.length != 1) {
    stderr.writeln('Usage: dart run scripts/sync_style_guides.dart (<target-repo-dir> | --check)');
    exit(64);
  }

  final source = Directory(_sourceDir);
  if (!source.existsSync()) {
    stderr.writeln('No `$_sourceDir/` here; run this from the stream-core-flutter root.');
    exit(1);
  }

  final guides = source.listSync().whereType<File>().where((f) => f.path.endsWith('.md')).toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  if (guides.isEmpty) {
    stderr.writeln('`$_sourceDir/` has no guides to copy.');
    exit(1);
  }

  final escaping = [for (final guide in guides) ..._linksLeavingFolder(guide)];
  if (escaping.isNotEmpty) {
    stderr
      ..writeln('Guides in `$_sourceDir/` must not link outside the folder; use an absolute URL or drop the link:')
      ..writeAll(escaping.map((e) => '  $e\n'));
    exit(1);
  }

  if (args.single == '--check') {
    stdout.writeln('${guides.length} guide(s) checked; no links leave `$_sourceDir/`.');
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
    stdout.writeln('copied $name');
  }

  for (final stale in target.listSync().whereType<File>()) {
    final name = p.basename(stale.path);
    if (copied.contains(name) || !name.endsWith('.md')) continue;
    if (!stale.readAsStringSync().startsWith(_syncMarker)) continue;
    stale.deleteSync();
    stdout.writeln('deleted $name');
  }
}

// Returns `file:line: target` for every relative link in [guide] that resolves
// outside `style_guides/`.
Iterable<String> _linksLeavingFolder(File guide) sync* {
  final lines = guide.readAsLinesSync();
  for (var i = 0; i < lines.length; i++) {
    for (final match in _linkTarget.allMatches(lines[i])) {
      final link = match[1]!;
      if (link.startsWith('#') || Uri.tryParse(link)?.hasScheme ?? false) continue;
      final path = link.split('#').first;
      if (p.isWithin(_sourceDir, p.normalize(p.join(_sourceDir, path)))) continue;
      yield '${guide.path}:${i + 1}: $link';
    }
  }
}
