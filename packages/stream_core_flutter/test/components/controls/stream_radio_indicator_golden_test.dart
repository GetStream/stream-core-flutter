import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/video.dart';

void main() {
  group('StreamRadioIndicator Golden Tests', () {
    for (final brightness in Brightness.values) {
      goldenTest(
        'fills when selected and outlines when it is not (${brightness.name})',
        fileName: 'stream_radio_indicator_${brightness.name}',
        builder: () => GoldenTestGroup(
          columns: 2,
          // The indicator is 16px wide, which is narrower than its own
          // scenario label; without a floor the two columns overlap.
          scenarioConstraints: const BoxConstraints.tightFor(width: 100),
          children: [
            GoldenTestScenario(
              name: 'selected',
              child: _buildInTheme(StreamRadioIndicator(selected: true), brightness: brightness),
            ),
            GoldenTestScenario(
              name: 'unselected',
              child: _buildInTheme(StreamRadioIndicator(selected: false), brightness: brightness),
            ),
          ],
        ),
      );
    }
  });
}

Widget _buildInTheme(Widget child, {required Brightness brightness}) {
  return Theme(
    data: ThemeData(
      brightness: brightness,
      extensions: [StreamTheme(brightness: brightness)],
    ),
    child: Builder(
      builder: (context) => Material(
        color: StreamTheme.of(context).colorScheme.backgroundApp,
        child: Padding(padding: const EdgeInsets.all(8), child: child),
      ),
    ),
  );
}
