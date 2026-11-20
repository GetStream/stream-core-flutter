import 'package:alchemist/alchemist.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/video.dart';

void main() {
  group('StreamAdaptiveMenuAnchor Golden Tests', () {
    goldenTest(
      'renders the anchored menu in light theme',
      fileName: 'stream_adaptive_menu_anchor_menu_light',
      whilePerforming: _openMenu,
      builder: () => _buildScenario(name: 'anchored', useSheet: false),
    );

    goldenTest(
      'renders the anchored menu in dark theme',
      fileName: 'stream_adaptive_menu_anchor_menu_dark',
      whilePerforming: _openMenu,
      builder: () => _buildScenario(name: 'anchored', useSheet: false, brightness: Brightness.dark),
    );

    goldenTest(
      'renders the sheet in light theme',
      fileName: 'stream_adaptive_menu_anchor_sheet_light',
      whilePerforming: _openMenu,
      builder: () => _buildScenario(name: 'sheet', useSheet: true),
    );

    goldenTest(
      'renders the sheet in dark theme',
      fileName: 'stream_adaptive_menu_anchor_sheet_dark',
      whilePerforming: _openMenu,
      builder: () => _buildScenario(name: 'sheet', useSheet: true, brightness: Brightness.dark),
    );
  });
}

Future<AsyncCallback?> _openMenu(WidgetTester tester) async {
  await tester.tap(find.text('Devices'));
  await tester.pumpAndSettle();
  return null;
}

// Both presentations are drawn above the page: the anchored menu in the
// nearest Overlay, the sheet in a route of the nearest Navigator. The scenario
// carries its own Navigator, and with it an Overlay, so the open menu lands
// inside the captured area instead of the app's root overlay, which the
// golden capture leaves out.
GoldenTestGroup _buildScenario({
  required String name,
  required bool useSheet,
  Brightness brightness = Brightness.light,
}) {
  return GoldenTestGroup(
    children: [
      GoldenTestScenario(
        name: name,
        child: Theme(
          data: ThemeData(
            brightness: brightness,
            extensions: [StreamTheme(brightness: brightness)],
          ),
          child: Builder(
            builder: (context) => Material(
              color: context.streamColorScheme.backgroundApp,
              child: SizedBox(
                width: 360,
                height: 400,
                child: Navigator(
                  onGenerateRoute: (_) => PageRouteBuilder<void>(
                    pageBuilder: (context, _, _) => Material(
                      color: context.streamColorScheme.backgroundApp,
                      child: Align(
                        alignment: AlignmentDirectional.topStart,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: _anchor(useSheet: useSheet),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

Widget _anchor({required bool useSheet}) {
  return StreamAdaptiveMenuAnchor(
    title: 'Devices',
    useSheet: useSheet,
    sections: [
      StreamMenuSection(
        heading: 'Microphone',
        options: [
          StreamMenuOption(label: 'Built-in microphone', selected: true, onSelected: () {}),
          StreamMenuOption(label: 'External microphone', selected: false, onSelected: () {}),
        ],
      ),
      StreamMenuSection(
        heading: 'Speaker',
        collapsible: true,
        initiallyCollapsed: false,
        options: [
          StreamMenuOption(label: 'Built-in speakers', selected: true, onSelected: () {}),
        ],
      ),
      StreamMenuSection(
        options: [
          StreamMenuOption(label: 'Noise cancellation', trailing: const Text('On'), onSelected: () {}),
        ],
      ),
    ],
    builder: (context, handle) => StreamButton(
      onPressed: handle.toggle,
      child: const Text('Devices'),
    ),
  );
}
