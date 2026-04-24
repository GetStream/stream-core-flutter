import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';

void main() {
  group('StreamSheetHeader Golden Tests', () {
    goldenTest(
      'renders light theme slot matrix',
      fileName: 'stream_sheet_header_light_matrix',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 360),
        children: [
          for (final scenario in _scenarios)
            GoldenTestScenario(
              name: scenario.name,
              child: _buildInTheme(scenario.build()),
            ),
        ],
      ),
    );

    goldenTest(
      'renders dark theme slot matrix',
      fileName: 'stream_sheet_header_dark_matrix',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 360),
        children: [
          for (final scenario in _scenarios)
            GoldenTestScenario(
              name: scenario.name,
              child: _buildInTheme(
                scenario.build(),
                brightness: Brightness.dark,
              ),
            ),
        ],
      ),
    );
  });
}

typedef _Scenario = ({String name, Widget Function() build});

final List<_Scenario> _scenarios = [
  (
    name: 'title_only',
    build: () => StreamSheetHeader(title: const Text('Details')),
  ),
  (
    name: 'title_and_subtitle',
    build: () => StreamSheetHeader(
      title: const Text('Details'),
      subtitle: const Text('Additional information'),
    ),
  ),
  (
    name: 'title_with_leading',
    build: () => StreamSheetHeader(
      leading: _placeholder(),
      title: const Text('Details'),
    ),
  ),
  (
    name: 'title_with_trailing',
    build: () => StreamSheetHeader(
      title: const Text('Details'),
      trailing: _placeholder(color: const Color(0xFF005FFF)),
    ),
  ),
  (
    name: 'title_with_both_sides',
    build: () => StreamSheetHeader(
      leading: _placeholder(),
      title: const Text('Details'),
      trailing: _placeholder(color: const Color(0xFF005FFF)),
    ),
  ),
  (
    name: 'full_with_subtitle',
    build: () => StreamSheetHeader(
      leading: _placeholder(),
      title: const Text('Edit profile'),
      subtitle: const Text('Tap to change your avatar'),
      trailing: _placeholder(color: const Color(0xFF005FFF)),
    ),
  ),
  (
    name: 'long_title_with_both_sides',
    build: () => StreamSheetHeader(
      leading: _placeholder(),
      title: const Text(
        'A rather long title that should ellipsize gracefully',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: _placeholder(color: const Color(0xFF005FFF)),
    ),
  ),
  (
    name: 'no_title_only_actions',
    build: () => StreamSheetHeader(
      leading: _placeholder(),
      trailing: _placeholder(color: const Color(0xFF005FFF)),
    ),
  ),
  (
    name: 'subtitle_only',
    build: () => StreamSheetHeader(
      subtitle: const Text('Subtitle without a title'),
    ),
  ),
];

Widget _placeholder({Color color = const Color(0xFFD5DBE1)}) {
  return Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
    ),
  );
}

Widget _buildInTheme(
  Widget child, {
  Brightness brightness = Brightness.light,
}) {
  final streamTheme = StreamTheme(brightness: brightness);
  return Theme(
    data: ThemeData(
      brightness: brightness,
      extensions: [streamTheme],
    ),
    child: Builder(
      builder: (context) => Material(
        color: StreamTheme.of(context).colorScheme.backgroundApp,
        child: child,
      ),
    ),
  );
}
