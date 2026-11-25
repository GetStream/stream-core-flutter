import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

void main() {
  group('StreamEmptyState Golden Tests', () {
    for (final brightness in Brightness.values) {
      goldenTest(
        'renders every slot combination in ${brightness.name} theme',
        fileName: 'stream_empty_state_${brightness.name}_matrix',
        builder: () => GoldenTestGroup(
          columns: 1,
          scenarioConstraints: const BoxConstraints(maxWidth: 400),
          children: [
            GoldenTestScenario(
              name: 'description only',
              child: _buildInTheme(
                (context) => StreamEmptyState(
                  icon: Icon(context.streamIcons.search),
                  description: const Text('No results'),
                ),
                brightness: brightness,
              ),
            ),
            GoldenTestScenario(
              name: 'title only',
              child: _buildInTheme(
                (context) => StreamEmptyState(
                  icon: Icon(context.streamIcons.recordLibraryFill),
                  title: const Text('No recordings'),
                ),
                brightness: brightness,
              ),
            ),
            GoldenTestScenario(
              name: 'with description',
              child: _buildInTheme(
                (context) => StreamEmptyState(
                  icon: Icon(context.streamIcons.recordLibraryFill),
                  title: const Text('No recordings'),
                  description: const Text('Recordings you make show up here.'),
                ),
                brightness: brightness,
              ),
            ),
            GoldenTestScenario(
              name: 'without icon',
              child: _buildInTheme(
                (context) => StreamEmptyState(
                  title: const Text('No recordings'),
                  description: const Text('Recordings you make show up here.'),
                ),
                brightness: brightness,
              ),
            ),
            GoldenTestScenario(
              name: 'with action',
              child: _buildInTheme(
                (context) => StreamEmptyState(
                  icon: Icon(context.streamIcons.exclamationCircleFill),
                  title: const Text("Couldn't load recordings"),
                  description: const Text('Check your connection and try again.'),
                  action: StreamButton(
                    style: StreamButtonStyle.secondary,
                    type: StreamButtonType.outline,
                    onPressed: () {},
                    child: const Text('Try again'),
                  ),
                ),
                brightness: brightness,
              ),
            ),
          ],
        ),
      );
    }

    goldenTest(
      'wraps a long description',
      fileName: 'stream_empty_state_long_description',
      builder: () => GoldenTestGroup(
        columns: 1,
        scenarioConstraints: const BoxConstraints(maxWidth: 320),
        children: [
          GoldenTestScenario(
            name: 'narrow',
            child: _buildInTheme(
              (context) => StreamEmptyState(
                icon: Icon(context.streamIcons.recordLibraryFill),
                title: const Text('No recordings'),
                description: const Text(
                  'Recordings you make during this call show up here once they have finished processing.',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  });
}

Widget _buildInTheme(WidgetBuilder builder, {Brightness brightness = Brightness.light}) {
  final streamTheme = StreamTheme(brightness: brightness);
  return Theme(
    data: ThemeData(brightness: brightness, extensions: [streamTheme]),
    child: Builder(
      builder: (context) => Material(
        color: StreamTheme.of(context).colorScheme.backgroundApp,
        child: builder(context),
      ),
    ),
  );
}
