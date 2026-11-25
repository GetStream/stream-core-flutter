import 'package:alchemist/alchemist.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
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
          // The radio button is narrower than its own scenario label; without
          // a floor the columns overlap.
          scenarioConstraints: const BoxConstraints.tightFor(width: 140),
          children: [
            for (final (name, size) in [
              ('sm', StreamRadioButtonSize.sm),
              ('md', StreamRadioButtonSize.md),
              ('lg', StreamRadioButtonSize.lg),
            ]) ...[
              for (final enabled in [true, false])
                for (final selected in [true, false])
                  GoldenTestScenario(
                    name: '$name ${enabled ? 'enabled' : 'disabled'} ${selected ? 'on' : 'off'}',
                    child: _buildInTheme(
                      _radio(selected: selected, size: size, enabled: enabled),
                      brightness: brightness,
                    ),
                  ),
            ],
            for (final selected in [true, false])
              GoldenTestScenario(
                name: 'indicator ${selected ? 'on' : 'off'}',
                child: _buildInTheme(StreamRadioIndicator(selected: selected), brightness: brightness),
              ),
          ],
        ),
      );

      goldenTest(
        'renders the hovered, pressed and focused states (${brightness.name})',
        fileName: 'stream_radio_button_interactions_${brightness.name}',
        whilePerforming: _interact,
        builder: () => GoldenTestGroup(
          columns: 2,
          scenarioConstraints: const BoxConstraints.tightFor(width: 140),
          children: [
            for (final interaction in ['hovered', 'pressed'])
              for (final selected in [true, false])
                GoldenTestScenario(
                  name: '$interaction ${selected ? 'on' : 'off'}',
                  child: _buildInTheme(
                    _radio(key: ValueKey(interaction), selected: selected),
                    brightness: brightness,
                  ),
                ),
            // Only one radio button can hold the focus at a time.
            GoldenTestScenario(
              name: 'focused off',
              child: _buildInTheme(_radio(selected: false, autofocus: true), brightness: brightness),
            ),
          ],
        ),
      );
    }
  });
}

// Hovers every radio button keyed 'hovered' with its own mouse, presses every
// one keyed 'pressed', and shows the focus highlight of the focused one.
Future<AsyncCallback?> _interact(WidgetTester tester) async {
  FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;

  final mice = <TestGesture>[];
  for (final (index, element) in find.byKey(const ValueKey('hovered')).evaluate().indexed) {
    final mouse = TestGesture(
      dispatcher: tester.sendEventToBinding,
      pointer: 100 + index,
      kind: PointerDeviceKind.mouse,
      device: 100 + index,
    );
    await mouse.addPointer(location: tester.getCenter(find.byWidget(element.widget)));
    mice.add(mouse);
  }
  final presses = [
    for (final element in find.byKey(const ValueKey('pressed')).evaluate())
      await tester.startGesture(tester.getCenter(find.byWidget(element.widget))),
  ];
  await tester.pump(kPressTimeout);
  await tester.pump();

  return () async {
    for (final press in presses) {
      await press.up();
    }
    for (final mouse in mice) {
      await mouse.removePointer();
    }
    FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic;
  };
}

Widget _radio({
  Key? key,
  required bool selected,
  StreamRadioButtonSize? size,
  bool enabled = true,
  bool autofocus = false,
}) {
  return RadioGroup<bool>(
    groupValue: true,
    onChanged: (_) {},
    child: StreamRadioButton(key: key, value: selected, size: size, enabled: enabled, autofocus: autofocus),
  );
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
