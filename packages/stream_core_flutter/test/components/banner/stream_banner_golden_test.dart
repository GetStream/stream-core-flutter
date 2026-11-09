import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

void main() {
  group('StreamBanner Golden Tests', () {
    for (final brightness in Brightness.values) {
      goldenTest(
        'renders every type in ${brightness.name} theme',
        fileName: 'stream_banner_${brightness.name}_matrix',
        pumpBeforeTest: pumpOnce,
        builder: () => GoldenTestGroup(
          columns: 1,
          scenarioConstraints: const BoxConstraints(maxWidth: 400),
          children: [
            for (final type in StreamBannerType.values)
              GoldenTestScenario(
                name: type.name,
                child: _buildInTheme(
                  StreamBanner(type: type, title: const Text('Waiting for network…')),
                  brightness: brightness,
                ),
              ),
          ],
        ),
      );
    }

    goldenTest(
      'wraps a long title',
      fileName: 'stream_banner_long_title',
      builder: () => GoldenTestGroup(
        columns: 1,
        scenarioConstraints: const BoxConstraints(maxWidth: 320),
        children: [
          GoldenTestScenario(
            name: 'error',
            child: _buildInTheme(
              StreamBanner(
                type: .error,
                title: const Text("Couldn't load content because the connection dropped while it was being fetched"),
              ),
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
        child: Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: child),
      ),
    ),
  );
}
