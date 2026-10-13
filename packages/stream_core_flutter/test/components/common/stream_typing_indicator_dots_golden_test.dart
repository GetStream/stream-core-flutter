import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:stream_core_flutter/core.dart';

void main() {
  goldenTest(
    'StreamTypingIndicatorDots renders the static frame in light and dark themes, LTR and RTL',
    fileName: 'stream_typing_indicator_dots_static_frame',
    builder: () => GoldenTestGroup(
      scenarioConstraints: const BoxConstraints(maxWidth: 120),
      children: [
        for (final brightness in Brightness.values)
          for (final textDirection in TextDirection.values)
            GoldenTestScenario(
              name: '${brightness.name}_${textDirection.name}',
              child: _buildInTheme(brightness: brightness, textDirection: textDirection),
            ),
      ],
    ),
  );
}

// Animations are disabled so the indicator holds its static frame, which keeps
// the capture deterministic.
Widget _buildInTheme({
  required Brightness brightness,
  required TextDirection textDirection,
}) {
  return Theme(
    data: ThemeData(
      brightness: brightness,
      extensions: [StreamTheme(brightness: brightness)],
    ),
    child: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: Directionality(
          textDirection: textDirection,
          child: Material(
            color: StreamTheme.of(context).colorScheme.backgroundApp,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(child: StreamTypingIndicatorDots()),
            ),
          ),
        ),
      ),
    ),
  );
}
