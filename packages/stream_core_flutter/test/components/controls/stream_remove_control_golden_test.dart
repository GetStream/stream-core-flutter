import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';

void main() {
  group('StreamRemoveControl Golden Tests', () {
    goldenTest(
      'renders light theme',
      fileName: 'stream_remove_control_light',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 120),
        children: [
          GoldenTestScenario(
            name: 'padded (default)',
            child: _buildInTheme(
              StreamRemoveControl(onPressed: () {}),
            ),
          ),
          GoldenTestScenario(
            name: 'shrinkWrap',
            child: _buildInTheme(
              StreamRemoveControl(
                onPressed: () {},
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'renders dark theme',
      fileName: 'stream_remove_control_dark',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 120),
        children: [
          GoldenTestScenario(
            name: 'padded (default)',
            child: _buildInTheme(
              StreamRemoveControl(onPressed: () {}),
              brightness: Brightness.dark,
            ),
          ),
          GoldenTestScenario(
            name: 'shrinkWrap',
            child: _buildInTheme(
              StreamRemoveControl(
                onPressed: () {},
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              brightness: Brightness.dark,
            ),
          ),
        ],
      ),
    );
  });
}

Widget _buildInTheme(
  Widget control, {
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
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.topLeft,
            child: control,
          ),
        ),
      ),
    ),
  );
}
