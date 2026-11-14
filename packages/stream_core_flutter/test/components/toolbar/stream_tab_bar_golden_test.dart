import 'dart:io';

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/video.dart';

void main() {
  // Renders the shipped icon font so the icon tabs show real glyphs rather
  // than the test framework's placeholder boxes.
  setUpAll(() async {
    final loader = FontLoader('packages/stream_core_flutter/${StreamIconData.iconFontFamily}')
      ..addFont(File('lib/fonts/stream_icons_font.otf').readAsBytes().then(ByteData.sublistView));
    await loader.load();
  });

  group('StreamTabBar Golden Tests', () {
    for (final brightness in Brightness.values) {
      goldenTest(
        'renders ${brightness.name} theme matrix',
        fileName: 'stream_tab_bar_${brightness.name}',
        builder: () => GoldenTestGroup(
          columns: 1,
          scenarioConstraints: const BoxConstraints(maxWidth: 400),
          children: [
            GoldenTestScenario(
              name: 'first selected',
              child: _buildInTheme(_labelTabBar(selectedIndex: 0), brightness: brightness),
            ),
            GoldenTestScenario(
              name: 'last selected',
              child: _buildInTheme(_labelTabBar(selectedIndex: 2), brightness: brightness),
            ),
            GoldenTestScenario(
              name: 'with icons',
              child: _buildInTheme(
                StreamTabBar(
                  selectedIndex: 0,
                  onSelected: (_) {},
                  tabs: const [
                    StreamTabBarItem(label: 'Entire Screen', icon: Icon(StreamIconData.presentDesktopFill)),
                    StreamTabBarItem(label: 'Window', icon: Icon(StreamIconData.gridFill)),
                  ],
                ),
                brightness: brightness,
              ),
            ),
          ],
        ),
      );
    }

    goldenTest(
      'truncates a long label',
      fileName: 'stream_tab_bar_long_label',
      builder: () => GoldenTestGroup(
        columns: 1,
        scenarioConstraints: const BoxConstraints(maxWidth: 240),
        children: [
          GoldenTestScenario(
            name: 'ellipsis',
            child: _buildInTheme(
              StreamTabBar(
                selectedIndex: 1,
                onSelected: (_) {},
                tabs: const [
                  StreamTabBarItem(label: 'A label far too long to fit its share'),
                  StreamTabBarItem(label: 'Short'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  });
}

StreamTabBar _labelTabBar({required int selectedIndex}) {
  return StreamTabBar(
    selectedIndex: selectedIndex,
    onSelected: (_) {},
    tabs: const [
      StreamTabBarItem(label: 'All'),
      StreamTabBarItem(label: 'Unread'),
      StreamTabBarItem(label: 'Mentions'),
    ],
  );
}

Widget _buildInTheme(Widget child, {Brightness brightness = Brightness.light}) {
  final streamTheme = StreamTheme(brightness: brightness);
  return Theme(
    data: ThemeData(brightness: brightness, extensions: [streamTheme]),
    child: Builder(
      builder: (context) => Material(
        color: StreamTheme.of(context).colorScheme.backgroundApp,
        child: SizedBox(width: 400, child: child),
      ),
    ),
  );
}
