// ignore_for_file: avoid_redundant_argument_values

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';

void main() {
  group('StreamCommandChip Golden Tests', () {
    goldenTest(
      'renders light theme',
      fileName: 'stream_command_chip_light',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 300),
        children: [
          GoldenTestScenario(
            name: 'short label',
            child: _buildInTheme(
              StreamCommandChip(label: '/giphy', onDismiss: () {}),
            ),
          ),
          GoldenTestScenario(
            name: 'long label',
            child: _buildInTheme(
              StreamCommandChip(label: '/very-long-command-name', onDismiss: () {}),
            ),
          ),
          GoldenTestScenario(
            name: 'no dismiss',
            child: _buildInTheme(
              StreamCommandChip(label: '/giphy'),
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'renders dark theme',
      fileName: 'stream_command_chip_dark',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 300),
        children: [
          GoldenTestScenario(
            name: 'short label',
            child: _buildInTheme(
              StreamCommandChip(label: '/giphy', onDismiss: () {}),
              brightness: Brightness.dark,
            ),
          ),
          GoldenTestScenario(
            name: 'long label',
            child: _buildInTheme(
              StreamCommandChip(label: '/very-long-command-name', onDismiss: () {}),
              brightness: Brightness.dark,
            ),
          ),
          GoldenTestScenario(
            name: 'no dismiss',
            child: _buildInTheme(
              StreamCommandChip(label: '/giphy'),
              brightness: Brightness.dark,
            ),
          ),
        ],
      ),
    );
  });
}

Widget _buildInTheme(
  Widget chip, {
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
          child: chip,
        ),
      ),
    ),
  );
}
