import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:stream_core_flutter/chat.dart';

void main() {
  goldenTest(
    'StreamMessageMark renders its neutral and highlighted labels in light and dark themes',
    fileName: 'stream_message_mark',
    builder: () => GoldenTestGroup(
      scenarioConstraints: const BoxConstraints(maxWidth: 320),
      children: [
        for (final brightness in Brightness.values) ...[
          GoldenTestScenario(
            name: '${brightness.name}_not_played',
            child: _buildInTheme(
              brightness: brightness,
              mark: StreamMessageMark(
                label: const Text('Not played'),
              ),
            ),
          ),
          GoldenTestScenario(
            name: '${brightness.name}_played',
            child: _buildInTheme(
              brightness: brightness,
              mark: StreamMessageMark(
                label: const Text('Played'),
                highlighted: true,
              ),
            ),
          ),
          GoldenTestScenario(
            name: '${brightness.name}_no_separator',
            child: _buildInTheme(
              brightness: brightness,
              mark: StreamMessageMark(
                label: const Text('Played by 3'),
                highlighted: true,
                separator: null,
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

Widget _buildInTheme({
  required Brightness brightness,
  required Widget mark,
}) {
  return Theme(
    data: ThemeData(
      brightness: brightness,
      extensions: [StreamTheme(brightness: brightness)],
    ),
    child: Builder(
      builder: (context) => Material(
        color: StreamTheme.of(context).colorScheme.backgroundApp,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: StreamMessageLayout(
            data: const StreamMessageLayoutData(
              alignment: StreamMessageAlignment.end,
            ),
            child: StreamMessageMetadata(
              timestamp: const Text('09:41'),
              mark: mark,
            ),
          ),
        ),
      ),
    ),
  );
}
