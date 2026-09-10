import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

void main() {
  group('StreamErrorBadge Golden Tests', () {
    goldenTest(
      'renders light theme style and size matrix',
      fileName: 'stream_error_badge_light_matrix',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 100),
        children: [
          for (final style in StreamErrorBadgeStyle.values)
            for (final size in StreamErrorBadgeSize.values)
              GoldenTestScenario(
                name: '${style.name}_${size.name}',
                child: _buildInTheme(
                  StreamErrorBadge(style: style, size: size),
                ),
              ),
        ],
      ),
    );

    goldenTest(
      'renders dark theme style and size matrix',
      fileName: 'stream_error_badge_dark_matrix',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 100),
        children: [
          for (final style in StreamErrorBadgeStyle.values)
            for (final size in StreamErrorBadgeSize.values)
              GoldenTestScenario(
                name: '${style.name}_${size.name}',
                child: _buildInTheme(
                  StreamErrorBadge(style: style, size: size),
                  brightness: Brightness.dark,
                ),
              ),
        ],
      ),
    );

    // The border's job is to separate the badge from what it overlaps, and its
    // color tracks the app background — so it is only visible over something
    // else. These scenarios overlay a contrasting swatch to show it.
    goldenTest(
      'renders the border toggle over a contrasting surface',
      fileName: 'stream_error_badge_border_toggle',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 100),
        children: [
          for (final brightness in Brightness.values)
            for (final style in StreamErrorBadgeStyle.values)
              for (final showBorder in [true, false])
                GoldenTestScenario(
                  name:
                      '${brightness.name}_${style.name}_'
                      '${showBorder ? 'border' : 'no_border'}',
                  child: _buildInTheme(
                    StreamErrorBadge(style: style, showBorder: showBorder),
                    brightness: brightness,
                    overContrastingSurface: true,
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
  bool overContrastingSurface = false,
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
          child: Center(
            child: switch (overContrastingSurface) {
              true => ColoredBox(
                color: StreamTheme.of(context).colorScheme.accentNeutral,
                child: Padding(padding: const EdgeInsets.all(6), child: child),
              ),
              false => child,
            },
          ),
        ),
      ),
    ),
  );
}
