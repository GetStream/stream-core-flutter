import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

void main() {
  group('StreamInlineNotification Golden Tests', () {
    for (final brightness in Brightness.values) {
      goldenTest(
        'renders every type with and without a description in ${brightness.name} theme',
        fileName: 'stream_inline_notification_${brightness.name}_matrix',
        builder: () => GoldenTestGroup(
          columns: 1,
          scenarioConstraints: const BoxConstraints(maxWidth: 400),
          children: [
            for (final type in StreamInlineNotificationType.values) ...[
              GoldenTestScenario(
                name: '${type.name} · title only',
                child: _buildInTheme(
                  StreamInlineNotification(type: type, title: const Text('Changes are saved automatically')),
                  brightness: brightness,
                ),
              ),
              GoldenTestScenario(
                name: '${type.name} · with description',
                child: _buildInTheme(
                  StreamInlineNotification(
                    type: type,
                    title: const Text("Couldn't load content"),
                    description: const Text('Check your connection and try again.'),
                  ),
                  brightness: brightness,
                ),
              ),
            ],
          ],
        ),
      );
    }

    goldenTest(
      'wraps a long title and description at a narrow width',
      fileName: 'stream_inline_notification_narrow',
      builder: () => GoldenTestGroup(
        columns: 1,
        scenarioConstraints: const BoxConstraints(maxWidth: 260),
        children: [
          GoldenTestScenario(
            name: 'error · with description',
            child: _buildInTheme(
              StreamInlineNotification(
                type: .error,
                title: const Text("Couldn't load content because the connection dropped"),
                description: const Text('Check your connection, then try loading the content again.'),
              ),
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'renders without the leading icon',
      fileName: 'stream_inline_notification_without_icon',
      builder: () => GoldenTestGroup(
        columns: 1,
        scenarioConstraints: const BoxConstraints(maxWidth: 400),
        children: [
          GoldenTestScenario(
            name: 'info · no icon',
            child: _buildInTheme(
              StreamInlineNotification(showIcon: false, title: const Text('Changes are saved automatically')),
            ),
          ),
        ],
      ),
    );
  });
}

Widget _buildInTheme(Widget child, {Brightness brightness = Brightness.light}) {
  final streamTheme = StreamTheme(brightness: brightness);
  return Theme(
    data: ThemeData(brightness: brightness, extensions: [streamTheme]),
    child: Builder(
      builder: (context) => Material(
        color: StreamTheme.of(context).colorScheme.backgroundApp,
        child: Padding(padding: const EdgeInsets.all(8), child: child),
      ),
    ),
  );
}
