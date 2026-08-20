import 'dart:io';

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/video.dart';

void main() {
  // Without the real glyphs a caret-up golden is indistinguishable from a
  // caret-down one, so this suite renders the shipped icon font rather than
  // the test framework's placeholder boxes.
  setUpAll(() async {
    final loader = FontLoader('packages/stream_core_flutter/${StreamIconData.iconFontFamily}')
      ..addFont(File('lib/fonts/stream_icons_font.otf').readAsBytes().then(ByteData.sublistView));
    await loader.load();
  });

  group('StreamSplitButton Golden Tests', () {
    goldenTest(
      'renders light theme matrix',
      fileName: 'stream_split_button_light',
      builder: _buildMatrix,
    );

    goldenTest(
      'renders dark theme matrix',
      fileName: 'stream_split_button_dark',
      builder: () => _buildMatrix(brightness: Brightness.dark),
    );

    goldenTest(
      'renders the pressed leading half',
      fileName: 'stream_split_button_pressed',
      whilePerforming: press(find.byIcon(StreamIconData.voiceFill)),
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'pressed',
            child: _buildInTheme(_splitButton(style: .secondary)),
          ),
        ],
      ),
    );

    goldenTest(
      'renders disabled halves',
      fileName: 'stream_split_button_disabled',
      builder: () => GoldenTestGroup(
        columns: 3,
        children: [
          GoldenTestScenario(
            name: 'leading disabled',
            child: _buildInTheme(_splitButton(style: .secondary, onPressed: null)),
          ),
          GoldenTestScenario(
            name: 'trailing disabled',
            child: _buildInTheme(_splitButton(style: .secondary, onTrailingPressed: null)),
          ),
          GoldenTestScenario(
            name: 'both disabled',
            child: _buildInTheme(
              _splitButton(style: .secondary, onPressed: null, onTrailingPressed: null),
            ),
          ),
        ],
      ),
    );
  });
}

GoldenTestGroup _buildMatrix({Brightness brightness = Brightness.light}) {
  return GoldenTestGroup(
    columns: StreamButtonType.values.length,
    children: [
      for (final style in StreamButtonStyle.values)
        for (final type in StreamButtonType.values)
          GoldenTestScenario(
            name: '${style.name} / ${type.name}',
            child: _buildInTheme(
              _splitButton(style: style, type: type),
              brightness: brightness,
            ),
          ),
    ],
  );
}

StreamSplitButton _splitButton({
  StreamButtonStyle style = StreamButtonStyle.primary,
  StreamButtonType type = StreamButtonType.solid,
  VoidCallback? onPressed = _noop,
  VoidCallback? onTrailingPressed = _noop,
}) {
  return StreamSplitButton.icon(
    icon: const Icon(StreamIconData.voiceFill),
    trailingIcon: const Icon(StreamIconData.caretDown),
    style: style,
    type: type,
    onPressed: onPressed,
    onTrailingPressed: onTrailingPressed,
  );
}

void _noop() {}

Widget _buildInTheme(
  Widget splitButton, {
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
          child: splitButton,
        ),
      ),
    ),
  );
}
