// ignore_for_file: avoid_redundant_argument_values

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';

void main() {
  group('StreamButton Golden Tests', () {
    goldenTest(
      'renders light theme matrix',
      fileName: 'stream_button_light_matrix',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 400),
        children: [
          for (final style in StreamButtonStyle.values)
            for (final type in StreamButtonType.values)
              for (final size in StreamButtonSize.values)
                GoldenTestScenario(
                  name: '${style.name}_${type.name}_${size.name}',
                  child: _buildButtonInTheme(
                    StreamButton(
                      label: 'Button',
                      onTap: () {},
                      style: style,
                      type: type,
                      size: size,
                    ),
                  ),
                ),
        ],
      ),
    );

    goldenTest(
      'renders dark theme matrix',
      fileName: 'stream_button_dark_matrix',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 400),
        children: [
          for (final style in StreamButtonStyle.values)
            for (final type in StreamButtonType.values)
              for (final size in StreamButtonSize.values)
                GoldenTestScenario(
                  name: '${style.name}_${type.name}_${size.name}',
                  child: _buildButtonInTheme(
                    StreamButton(
                      label: 'Button',
                      onTap: () {},
                      style: style,
                      type: type,
                      size: size,
                    ),
                    brightness: Brightness.dark,
                  ),
                ),
        ],
      ),
    );

    goldenTest(
      'renders button with icons correctly',
      fileName: 'stream_button_with_icons',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 300),
        children: [
          GoldenTestScenario(
            name: 'icon left',
            child: _buildButtonInTheme(
              StreamButton(
                label: 'Button',
                onTap: () {},
                iconLeft: Icons.add,
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'icon right',
            child: _buildButtonInTheme(
              StreamButton(
                label: 'Button',
                onTap: () {},
                iconRight: Icons.arrow_forward,
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'both icons',
            child: _buildButtonInTheme(
              StreamButton(
                label: 'Button',
                onTap: () {},
                iconLeft: Icons.add,
                iconRight: Icons.arrow_forward,
              ),
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'renders icon only button correctly',
      fileName: 'stream_button_icon_only',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 300),
        children: [
          for (final style in StreamButtonStyle.values)
            for (final type in StreamButtonType.values)
              GoldenTestScenario(
                name: '${style.name}_${type.name}',
                child: _buildButtonInTheme(
                  StreamButton.icon(
                    onTap: () {},
                    style: style,
                    type: type,
                    icon: Icons.add,
                  ),
                ),
              ),
        ],
      ),
    );

    goldenTest(
      'renders disabled button correctly',
      fileName: 'stream_button_disabled',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 300),
        children: [
          for (final style in StreamButtonStyle.values)
            for (final type in StreamButtonType.values)
              GoldenTestScenario(
                name: '${style.name}_${type.name}',
                child: _buildButtonInTheme(
                  StreamButton(
                    label: 'Disabled',
                    onTap: null,
                    style: style,
                    type: type,
                  ),
                ),
              ),
        ],
      ),
    );
  });
}

Widget _buildButtonInTheme(
  Widget button, {
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
          child: button,
        ),
      ),
    ),
  );
}
