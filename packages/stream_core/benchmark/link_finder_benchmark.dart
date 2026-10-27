/// Link Finder Benchmark
///
/// Measures one `findLinks` call over typical messages, long texts in several
/// scripts, and inputs built to make a link scanner slow. Each score is the
/// time of a single call, in microseconds.
///
/// Usage (run from `packages/stream_core`):
///   dart run benchmark/link_finder_benchmark.dart
///
/// For numbers close to a release build, compile it ahead of time first:
///   dart compile exe benchmark/link_finder_benchmark.dart -o benchmark.exe
///   ./benchmark.exe
library;

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:stream_core/stream_core.dart';

void main() {
  for (final (name, text) in _inputs) {
    _FindLinksBenchmark(name, text).report();
  }
}

final _inputs = <(String, String)>[
  ('short message', 'Some link: youtube.com'),
  (
    'typical message',
    'Hey! The release notes are at getstream.io/chat/docs and the demo is '
        'on youtube.com/watch?v=abc. Ping me at me@x.io if anything breaks 🙂',
  ),
  ('prose with links, 3.6k', 'See getstream.io/chat or https://x.io/a?b=c, or mail me@x.io. ' * 60),
  ('plain words, 5k', 'hello ' * 850),
  ('many links, 5k', 'a.co ' * 1000),
  ('Cyrillic, 5k', 'Привет мир. ' * 420),
  ('Chinese mixed with ASCII, 5k', '中a' * 2500),
  ('emoji, 2k', '🐼a.b ' * 400),

  // Inputs built to make a link scanner slow.
  ('Chinese, ASCII and dots, 10k', '中a.' * 3400),
  ('closing parentheses, 20k', ')' * 20000),
  ('dots, 20k', '.' * 20000),
  ('one-letter labels, 10k', 'a.' * 5000),
];

// Measures one `findLinks` call over [text].
class _FindLinksBenchmark extends BenchmarkBase {
  _FindLinksBenchmark(String name, this.text) : super('findLinks: $name');

  final String text;

  @override
  void run() => findLinks(text);

  // One call per measurement, so the score is the time of a single call.
  @override
  void exercise() => run();
}
