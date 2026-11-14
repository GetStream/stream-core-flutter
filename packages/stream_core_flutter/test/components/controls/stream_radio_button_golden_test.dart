import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/video.dart';

void main() {
  group('StreamRadioButton Golden Tests', () {
    for (final brightness in Brightness.values) {
      goldenTest(
        'renders the size and state matrix (${brightness.name})',
        fileName: 'stream_radio_button_${brightness.name}',
        builder: () => GoldenTestGroup(
          columns: 4,
          // The radio button is at most 24px wide, which is narrower than its
          // own scenario label; without a floor the columns overlap.
          scenarioConstraints: const BoxConstraints.tightFor(width: 140),
          children: [
            for (final size in StreamRadioButtonSize.values) ...[
              for (final enabled in [true, false])
                for (final selected in [true, false])
                  GoldenTestScenario(
                    name: '${size.name} ${enabled ? 'enabled' : 'disabled'} ${selected ? 'on' : 'off'}',
                    child: _buildInTheme(
                      StreamRadioButton(selected: selected, size: size, onChanged: enabled ? (_) {} : null),
                      brightness: brightness,
                    ),
                  ),
            ],
            for (final selected in [true, false])
              GoldenTestScenario(
                name: 'decorative ${selected ? 'on' : 'off'}',
                child: _buildInTheme(StreamRadioButton.decorative(selected: selected), brightness: brightness),
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
