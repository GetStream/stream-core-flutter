import 'package:alchemist/alchemist.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/video.dart';

void main() {
  group('StreamContextMenuAnchor Golden Tests', () {
    goldenTest(
      'renders the open menu in light theme',
      fileName: 'stream_context_menu_anchor_light',
      whilePerforming: _openMenu,
      builder: () => _buildScenario(name: 'open'),
    );

    goldenTest(
      'renders the open menu in dark theme',
      fileName: 'stream_context_menu_anchor_dark',
      whilePerforming: _openMenu,
      builder: () => _buildScenario(name: 'open', brightness: Brightness.dark),
    );

    goldenTest(
      'renders a long label truncated at the max width',
      fileName: 'stream_context_menu_anchor_long_label',
      whilePerforming: _openMenu,
      builder: () => _buildScenario(
        name: 'long label',
        labels: const ['Studio Display Microphone (Conference Room, 4th floor, east wing)', 'Speaker'],
      ),
    );

    goldenTest(
      'renders a flat menu',
      fileName: 'stream_context_menu_anchor_flat',
      whilePerforming: _openMenu,
      builder: () => _buildScenario(name: 'elevation 0', elevation: 0),
    );
  });
}

Future<AsyncCallback?> _openMenu(WidgetTester tester) async {
  await tester.tap(find.text('Options'));
  await tester.pumpAndSettle();
  return null;
}

// The menu panel is drawn in the nearest Overlay. The scenario carries its own
// so the open menu lands inside the captured area instead of the app's root
// overlay, which the golden capture leaves out.
GoldenTestGroup _buildScenario({
  required String name,
  Brightness brightness = Brightness.light,
  List<String> labels = const ['Edit', 'Copy', 'Pin'],
  double? elevation,
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
                height: 260,
                child: Overlay(
                  initialEntries: [
                    OverlayEntry(
                      builder: (context) => Align(
                        alignment: AlignmentDirectional.topStart,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: _anchor(context, labels: labels, elevation: elevation),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

Widget _anchor(BuildContext context, {required List<String> labels, double? elevation}) {
  final icons = context.streamIcons;
  final leadingIcons = [icons.edit, icons.copy, icons.pin];

  return StreamContextMenuAnchor(
    alignmentOffset: const Offset(0, 8),
    elevation: elevation,
    menuChildren: [
      for (final (index, label) in labels.indexed)
        StreamContextMenuAction<void>(
          onTap: () {},
          leading: Icon(leadingIcons[index % leadingIcons.length]),
          label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      const StreamContextMenuSeparator(),
      StreamContextMenuAction<void>.destructive(
        onTap: () {},
        leading: Icon(icons.delete),
        label: const Text('Delete'),
      ),
    ],
    builder: (context, controller, child) => StreamButton(
      onPressed: controller.open,
      child: const Text('Options'),
    ),
  );
}
