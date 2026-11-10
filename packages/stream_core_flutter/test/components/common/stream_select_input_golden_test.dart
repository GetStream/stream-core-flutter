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

  group('StreamSelectInput Golden Tests', () {
    for (final brightness in Brightness.values) {
      goldenTest(
        'renders the type by state matrix in ${brightness.name} theme',
        fileName: 'stream_select_input_${brightness.name}',
        builder: () => GoldenTestGroup(
          columns: 2,
          scenarioConstraints: const BoxConstraints.tightFor(width: 220),
          children: [
            GoldenTestScenario(
              name: 'placeholder',
              child: _buildInTheme(
                StreamSelectInput(hintText: 'Default', onPressed: () {}),
                brightness: brightness,
              ),
            ),
            GoldenTestScenario(
              name: 'value with leading icon',
              child: _buildInTheme(
                StreamSelectInput(
                  leading: const Icon(StreamIconData.voiceFill),
                  value: 'MacBook Pro Microphone',
                  onPressed: () {},
                ),
                brightness: brightness,
              ),
            ),
            GoldenTestScenario(
              name: 'label',
              child: _buildInTheme(
                StreamSelectInput(labelText: 'Microphone', value: 'Jabra Evolve2 65', onPressed: () {}),
                brightness: brightness,
              ),
            ),
            GoldenTestScenario(
              name: 'expanded',
              child: _buildInTheme(
                StreamSelectInput(value: 'Jabra Evolve2 65', expanded: true, onPressed: () {}),
                brightness: brightness,
              ),
            ),
            GoldenTestScenario(
              name: 'error with helper text',
              child: _buildInTheme(
                StreamSelectInput(
                  value: 'Jabra Evolve2 65',
                  helperText: 'This device is no longer available',
                  helperState: StreamHelperState.error,
                  onPressed: () {},
                ),
                brightness: brightness,
              ),
            ),
            GoldenTestScenario(
              name: 'disabled',
              child: _buildInTheme(StreamSelectInput(hintText: 'Default'), brightness: brightness),
            ),
            GoldenTestScenario(
              name: 'ghost',
              child: _buildInTheme(
                StreamSelectInput(type: StreamSelectInputType.ghost, value: 'Jabra Evolve2 65', onPressed: () {}),
                brightness: brightness,
              ),
            ),
            GoldenTestScenario(
              name: 'overflowing value',
              child: _buildInTheme(
                StreamSelectInput(
                  value: 'Studio Display Microphone (Conference Room, 4th floor)',
                  onPressed: () {},
                ),
                brightness: brightness,
              ),
            ),
          ],
        ),
      );

      goldenTest(
        // Hover draws the same ring in a different color, so this covers the
        // geometry of both: 2px, painted 1px outside the field.
        'draws the focus ring outside the field in ${brightness.name} theme',
        fileName: 'stream_select_input_focused_${brightness.name}',
        constraints: const BoxConstraints.tightFor(width: 260, height: 80),
        // The ring is suppressed while the last interaction was a touch, as it
        // is in a freshly pumped widget test, so this switches to the
        // traditional highlight strategy before focusing the field.
        pumpBeforeTest: (tester) async {
          tester.binding.focusManager.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
          addTearDown(() => tester.binding.focusManager.highlightStrategy = FocusHighlightStrategy.automatic);
          Focus.of(tester.element(find.text('Jabra Evolve2 65'))).requestFocus();
          await tester.pumpAndSettle();
        },
        builder: () => _buildInTheme(
          Center(
            child: SizedBox(
              width: 220,
              child: StreamSelectInput(value: 'Jabra Evolve2 65', onPressed: () {}),
            ),
          ),
          brightness: brightness,
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
