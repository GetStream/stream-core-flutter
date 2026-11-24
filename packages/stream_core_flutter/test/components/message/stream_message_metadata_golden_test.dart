import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:stream_core_flutter/chat.dart';

void main() {
  goldenTest(
    'StreamMessageMetadata renders start- and end-aligned rows with a mark in light and dark themes',
    fileName: 'stream_message_metadata',
    builder: () => GoldenTestGroup(
      scenarioConstraints: const BoxConstraints(minWidth: 320, maxWidth: 320),
      children: [
        for (final brightness in Brightness.values)
          for (final alignment in StreamMessageAlignment.values)
            GoldenTestScenario(
              name: '${brightness.name}_${alignment.name}',
              child: _buildInTheme(
                brightness: brightness,
                alignment: alignment,
              ),
            ),
      ],
    ),
  );
}

Widget _buildInTheme({
  required Brightness brightness,
  required StreamMessageAlignment alignment,
}) {
  final theme = switch (brightness) {
    .light => StreamTheme.light(),
    .dark => StreamTheme.dark(),
  };

  return Theme(
    data: ThemeData(brightness: brightness, extensions: [theme]),
    child: Builder(
      builder: (context) => Material(
        color: context.streamColorScheme.backgroundApp,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: switch (alignment) {
              .start => AlignmentDirectional.centerStart,
              .end => AlignmentDirectional.centerEnd,
            },
            child: StreamMessageLayout(
              data: StreamMessageLayoutData(alignment: alignment),
              child: StreamMessageMetadata(
                timestamp: const Text('09:41'),
                status: const Icon(StreamIconData.checks),
                username: const Text('Alice'),
                mark: const Text('Played by 3'),
                edited: const Text('Edited'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
