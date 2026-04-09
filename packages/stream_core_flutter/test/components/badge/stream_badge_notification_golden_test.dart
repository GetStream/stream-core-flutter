import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';

void main() {
  group('StreamBadgeNotification Golden Tests', () {
    goldenTest(
      'renders light theme type and size matrix',
      fileName: 'stream_badge_notification_light_matrix',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 100),
        children: [
          for (final type in StreamBadgeNotificationType.values)
            for (final size in StreamBadgeNotificationSize.values)
              GoldenTestScenario(
                name: '${type.name}_${size.name}',
                child: _buildInTheme(
                  StreamBadgeNotification(
                    label: '1',
                    type: type,
                    size: size,
                  ),
                ),
              ),
        ],
      ),
    );

    goldenTest(
      'renders dark theme type and size matrix',
      fileName: 'stream_badge_notification_dark_matrix',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 100),
        children: [
          for (final type in StreamBadgeNotificationType.values)
            for (final size in StreamBadgeNotificationSize.values)
              GoldenTestScenario(
                name: '${type.name}_${size.name}',
                child: _buildInTheme(
                  StreamBadgeNotification(
                    label: '1',
                    type: type,
                    size: size,
                  ),
                  brightness: Brightness.dark,
                ),
              ),
        ],
      ),
    );

    goldenTest(
      'renders count variants correctly',
      fileName: 'stream_badge_notification_counts',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 100),
        children: [
          for (final count in ['1', '9', '25', '99', '99+'])
            GoldenTestScenario(
              name: 'count_$count',
              child: _buildInTheme(
                StreamBadgeNotification(label: count),
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
