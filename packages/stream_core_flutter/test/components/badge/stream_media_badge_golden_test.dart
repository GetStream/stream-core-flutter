// ignore_for_file: avoid_redundant_argument_values

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';

void main() {
  group('StreamMediaBadge Golden Tests', () {
    goldenTest(
      'renders light theme type matrix',
      fileName: 'stream_media_badge_light_matrix',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 200),
        children: [
          for (final type in MediaBadgeType.values) ...[
            GoldenTestScenario(
              name: '${type.name}_no_duration',
              child: _buildInTheme(StreamMediaBadge(type: type)),
            ),
            GoldenTestScenario(
              name: '${type.name}_with_duration',
              child: _buildInTheme(
                StreamMediaBadge(
                  type: type,
                  duration: const Duration(seconds: 8),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    goldenTest(
      'renders dark theme type matrix',
      fileName: 'stream_media_badge_dark_matrix',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 200),
        children: [
          for (final type in MediaBadgeType.values) ...[
            GoldenTestScenario(
              name: '${type.name}_no_duration',
              child: _buildInTheme(
                StreamMediaBadge(type: type),
                brightness: Brightness.dark,
              ),
            ),
            GoldenTestScenario(
              name: '${type.name}_with_duration',
              child: _buildInTheme(
                StreamMediaBadge(
                  type: type,
                  duration: const Duration(seconds: 8),
                ),
                brightness: Brightness.dark,
              ),
            ),
          ],
        ],
      ),
    );

    goldenTest(
      'renders compact duration format correctly',
      fileName: 'stream_media_badge_compact_duration',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 200),
        children: [
          GoldenTestScenario(
            name: '8s',
            child: _buildInTheme(
              const StreamMediaBadge(
                type: MediaBadgeType.video,
                duration: Duration(seconds: 8),
                durationFormat: MediaBadgeDurationFormat.compact,
              ),
            ),
          ),
          GoldenTestScenario(
            name: '1m',
            child: _buildInTheme(
              const StreamMediaBadge(
                type: MediaBadgeType.video,
                duration: Duration(seconds: 60),
                durationFormat: MediaBadgeDurationFormat.compact,
              ),
            ),
          ),
          GoldenTestScenario(
            name: '10m',
            child: _buildInTheme(
              const StreamMediaBadge(
                type: MediaBadgeType.video,
                duration: Duration(seconds: 608), // 10:08 → 10m
                durationFormat: MediaBadgeDurationFormat.compact,
              ),
            ),
          ),
          GoldenTestScenario(
            name: '59m',
            child: _buildInTheme(
              const StreamMediaBadge(
                type: MediaBadgeType.video,
                duration: Duration(seconds: 3599), // 59:59 → 59m
                durationFormat: MediaBadgeDurationFormat.compact,
              ),
            ),
          ),
          GoldenTestScenario(
            name: '1h',
            child: _buildInTheme(
              const StreamMediaBadge(
                type: MediaBadgeType.video,
                duration: Duration(hours: 1),
                durationFormat: MediaBadgeDurationFormat.compact,
              ),
            ),
          ),
          GoldenTestScenario(
            name: '2h',
            child: _buildInTheme(
              const StreamMediaBadge(
                type: MediaBadgeType.video,
                duration: Duration(hours: 2),
                durationFormat: MediaBadgeDurationFormat.compact,
              ),
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'renders exact duration format correctly',
      fileName: 'stream_media_badge_exact_duration',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 200),
        children: [
          GoldenTestScenario(
            name: '0:08',
            child: _buildInTheme(
              const StreamMediaBadge(
                type: MediaBadgeType.video,
                duration: Duration(seconds: 8),
                durationFormat: MediaBadgeDurationFormat.exact,
              ),
            ),
          ),
          GoldenTestScenario(
            name: '10:08',
            child: _buildInTheme(
              const StreamMediaBadge(
                type: MediaBadgeType.video,
                duration: Duration(seconds: 608),
                durationFormat: MediaBadgeDurationFormat.exact,
              ),
            ),
          ),
          GoldenTestScenario(
            name: '59:59',
            child: _buildInTheme(
              const StreamMediaBadge(
                type: MediaBadgeType.video,
                duration: Duration(seconds: 3599),
                durationFormat: MediaBadgeDurationFormat.exact,
              ),
            ),
          ),
          GoldenTestScenario(
            name: '1:00:08',
            child: _buildInTheme(
              const StreamMediaBadge(
                type: MediaBadgeType.video,
                duration: Duration(hours: 1, seconds: 8),
                durationFormat: MediaBadgeDurationFormat.exact,
              ),
            ),
          ),
          GoldenTestScenario(
            name: '1:59:59',
            child: _buildInTheme(
              const StreamMediaBadge(
                type: MediaBadgeType.video,
                duration: Duration(hours: 1, minutes: 59, seconds: 59),
                durationFormat: MediaBadgeDurationFormat.exact,
              ),
            ),
          ),
        ],
      ),
    );
  });
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
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Center(child: child),
        ),
      ),
    ),
  );
}
