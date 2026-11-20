import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/video.dart';

void main() {
  group('StreamContextMenuHeading Golden Tests', () {
    for (final brightness in Brightness.values) {
      goldenTest(
        'renders headings in a menu in ${brightness.name} theme',
        fileName: 'stream_context_menu_heading_${brightness.name}',
        pumpBeforeTest: pumpOnce,
        builder: () => GoldenTestGroup(
          columns: 1,
          children: [
            GoldenTestScenario(
              name: 'heading',
              child: _buildInTheme(
                StreamContextMenuHeading(label: const Text('Microphone')),
                brightness: brightness,
              ),
            ),
            GoldenTestScenario(
              name: 'collapsible',
              child: _buildInTheme(
                Builder(
                  builder: (context) => StreamContextMenuHeading(
                    label: const Text('Devices'),
                    trailing: Icon(context.streamIcons.chevronDown),
                    expanded: false,
                    onTap: () {},
                  ),
                ),
                brightness: brightness,
              ),
            ),
            GoldenTestScenario(
              name: 'in a menu',
              child: _buildInTheme(
                StreamContextMenu(
                  children: [
                    StreamContextMenuHeading(label: const Text('Microphone')),
                    StreamContextMenuAction<void>(label: const Text('Built-in microphone')),
                    StreamContextMenuAction<void>(label: const Text('External microphone')),
                    const StreamContextMenuSeparator(),
                    Builder(
                      builder: (context) => StreamContextMenuHeading(
                        label: const Text('Speaker'),
                        trailing: Icon(context.streamIcons.chevronUp),
                        expanded: true,
                        onTap: () {},
                      ),
                    ),
                    StreamContextMenuAction<void>(label: const Text('Built-in speaker')),
                  ],
                ),
                brightness: brightness,
              ),
            ),
          ],
        ),
      );
    }
  });
}

Widget _buildInTheme(Widget child, {Brightness brightness = Brightness.light}) {
  final streamTheme = StreamTheme(brightness: brightness);
  return Theme(
    data: ThemeData(brightness: brightness, extensions: [streamTheme]),
    child: Builder(
      builder: (context) => Material(
        color: StreamTheme.of(context).colorScheme.backgroundApp,
        child: Padding(padding: const EdgeInsets.all(8), child: child),
      ),
    ),
  );
}
