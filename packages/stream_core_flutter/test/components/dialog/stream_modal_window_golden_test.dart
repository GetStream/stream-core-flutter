import 'dart:io';

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/video.dart';

void main() {
  // Renders the shipped icon font, so the tab icons and the close button read
  // as glyphs rather than the test framework's placeholder box.
  setUpAll(() async {
    final loader = FontLoader('packages/stream_core_flutter/${StreamIconData.iconFontFamily}')
      ..addFont(File('lib/fonts/stream_icons_font.otf').readAsBytes().then(ByteData.sublistView));
    await loader.load();
  });

  group('StreamModalWindow Golden Tests', () {
    for (final brightness in Brightness.values) {
      goldenTest(
        'renders the sidebar and the selected tab in ${brightness.name} theme',
        fileName: 'stream_modal_window_${brightness.name}',
        builder: () => GoldenTestGroup(
          columns: 1,
          children: [
            GoldenTestScenario(
              name: 'sidebar with labels',
              child: _buildInTheme(
                StreamModalWindow(tabs: _tabs()),
                brightness: brightness,
                // The window's 720 x 640, plus the space the dialog keeps
                // around it.
                size: const Size(784, 704),
              ),
            ),
          ],
        ),
      );

      goldenTest(
        'collapses the sidebar to icons when narrow in ${brightness.name} theme',
        fileName: 'stream_modal_window_collapsed_${brightness.name}',
        builder: () => GoldenTestGroup(
          columns: 1,
          children: [
            GoldenTestScenario(
              name: 'collapsed sidebar',
              child: _buildInTheme(
                StreamModalWindow(tabs: _tabs(), initialIndex: 1),
                brightness: brightness,
                size: const Size(520, 400),
              ),
            ),
          ],
        ),
      );
    }
  });
}

List<StreamModalWindowTab> _tabs() => [
  for (final (name, icon) in [
    ('Device', const StreamIcons().settingsFill),
    ('Effects', const StreamIcons().blurFill),
    ('Captions', const StreamIcons().captionFill),
  ])
    StreamModalWindowTab(
      icon: Icon(icon),
      label: Text(name),
      builder: (context) => Text('$name content'),
    ),
];

Widget _buildInTheme(Widget child, {required Size size, Brightness brightness = Brightness.light}) {
  final streamTheme = StreamTheme(brightness: brightness);
  return Theme(
    data: ThemeData(brightness: brightness, extensions: [streamTheme]),
    child: Builder(
      // On the scrim, the way showStreamModalDialog draws it. Clipped, so the
      // blur stays inside the scenario.
      builder: (context) => ClipRect(
        child: ColoredBox(
          color: StreamTheme.of(context).colorScheme.backgroundApp,
          child: SizedBox.fromSize(
            size: size,
            child: Stack(
              children: [
                const Positioned.fill(child: StreamBlurScrim()),
                child,
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
