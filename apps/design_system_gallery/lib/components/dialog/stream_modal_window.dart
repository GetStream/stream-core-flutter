// ignore_for_file: experimental_member_use

import 'package:flutter/material.dart';
import 'package:stream_core_flutter/video.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamModalWindow,
  path: '[Components]/Dialog',
)
Widget buildStreamModalWindowPlayground(BuildContext context) {
  final tabCount = context.knobs.int.slider(
    label: 'Tabs',
    initialValue: 4,
    min: 1,
    max: _tabSpecs.length,
    description: 'How many tabs the sidebar lists. The first one holds a menu anchor.',
  );

  final initialIndex = context.knobs.int.slider(
    label: 'Initial Tab',
    max: _tabSpecs.length - 1,
    description: 'The tab selected when the window opens. Clamped to the tabs shown.',
  );

  final showCloseButton = context.knobs.boolean(
    label: 'Show Close Button',
    initialValue: true,
    description: 'Whether the header draws a close button.',
  );

  final longLabels = context.knobs.boolean(
    label: 'Long Labels',
    description: 'Give the tabs labels too long for the sidebar, to show them ellipsized.',
  );

  final narrow = context.knobs.boolean(
    label: 'Narrow Window',
    description: 'Limit the window to 480 wide, below the 560 at which the sidebar collapses to icons with tooltips.',
  );

  Widget buildWindow(BuildContext context) {
    final icons = context.streamIcons;

    return StreamModalWindow(
      initialIndex: initialIndex.clamp(0, tabCount - 1),
      showCloseButton: showCloseButton,
      constraints: narrow ? const BoxConstraints(maxWidth: 480, maxHeight: 520) : null,
      tabs: [
        for (final (index, spec) in _tabSpecs.take(tabCount).indexed)
          StreamModalWindowTab(
            icon: Icon(spec.icon(icons)),
            label: Text(longLabels ? spec.longLabel : spec.label),
            tooltip: longLabels ? spec.longLabel : null,
            builder: (context) => index == 0 ? const _DevicesTab() : _TextTab(spec.label),
          ),
      ],
    );
  }

  return Center(
    child: Builder(
      builder: (context) => StreamButton(
        onPressed: () => showStreamModalDialog<void>(context: context, builder: buildWindow),
        child: const Text('Open window'),
      ),
    ),
  );
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamModalWindow,
  path: '[Components]/Dialog',
)
Widget buildStreamModalWindowShowcase(BuildContext context) {
  final spacing = context.streamSpacing;

  Widget window(BuildContext context) {
    final icons = context.streamIcons;
    return StreamModalWindow(
      tabs: [
        for (final spec in _tabSpecs.take(3))
          StreamModalWindowTab(
            icon: Icon(spec.icon(icons)),
            label: Text(spec.label),
            builder: (context) => _TextTab(spec.label),
          ),
      ],
    );
  }

  return SingleChildScrollView(
    padding: EdgeInsets.all(spacing.lg),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.xl,
      children: [
        _Example(
          label: 'SIDEBAR WITH LABELS',
          caption: 'The sidebar lists the tabs, and the selected tab is drawn under its label',
          width: 784,
          child: Builder(builder: window),
        ),
        _Example(
          label: 'COLLAPSED SIDEBAR',
          caption: 'Below 560 wide, the sidebar shows only icons, each with a tooltip',
          width: 520,
          child: Builder(builder: window),
        ),
      ],
    ),
  );
}

// =============================================================================
// Shared Widgets
// =============================================================================

typedef _TabSpec = ({IconData Function(StreamIcons icons) icon, String label, String longLabel});

final _tabSpecs = <_TabSpec>[
  (icon: (icons) => icons.settings, label: 'Devices', longLabel: 'Audio and video devices'),
  (icon: (icons) => icons.bell, label: 'Notifications', longLabel: 'Notifications and sounds for every event'),
  (icon: (icons) => icons.user, label: 'Profile', longLabel: 'Profile, name and picture'),
  (icon: (icons) => icons.lock, label: 'Privacy', longLabel: 'Privacy and who can reach you'),
  (icon: (icons) => icons.info, label: 'About', longLabel: 'About this application'),
];

class _TextTab extends StatelessWidget {
  const _TextTab(this.name);

  final String name;

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;
    final style = context.streamTextTheme.bodyDefault.copyWith(color: context.streamColorScheme.textPrimary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.sm,
      children: [
        for (var i = 1; i <= 30; i += 1) Text('$name setting $i', style: style),
      ],
    );
  }
}

// A tab whose menu opens anchored even on a phone, because the window turns
// off the adaptive menu's sheet.
class _DevicesTab extends StatefulWidget {
  const _DevicesTab();

  @override
  State<_DevicesTab> createState() => _DevicesTabState();
}

class _DevicesTabState extends State<_DevicesTab> {
  static const _microphones = ['Built-in Microphone', 'USB Headset', 'Bluetooth Earbuds'];

  var _microphone = _microphones.first;

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;
    final textTheme = context.streamTextTheme;
    final colorScheme = context.streamColorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.xs,
      children: [
        Text('Microphone', style: textTheme.captionEmphasis.copyWith(color: colorScheme.textSecondary)),
        StreamAdaptiveMenuAnchor(
          title: 'Microphone',
          matchAnchorWidth: true,
          sections: [
            StreamMenuSection(
              options: [
                for (final microphone in _microphones)
                  StreamMenuOption(
                    label: microphone,
                    selected: microphone == _microphone,
                    onSelected: () => setState(() => _microphone = microphone),
                  ),
              ],
            ),
          ],
          builder: (context, handle) => StreamButton(
            style: StreamButtonStyle.secondary,
            type: StreamButtonType.outline,
            onPressed: handle.toggle,
            child: Text(_microphone),
          ),
        ),
      ],
    );
  }
}

// A window drawn in place rather than opened, on a scrim so its surface
// stands out from the page.
class _Example extends StatelessWidget {
  const _Example({required this.label, required this.caption, required this.width, required this.child});

  final String label;
  final String caption;
  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.xs,
      children: [
        Text(label, style: textTheme.captionEmphasis.copyWith(color: colorScheme.textTertiary)),
        Text(caption, style: textTheme.captionDefault.copyWith(color: colorScheme.textSecondary)),
        ClipRRect(
          borderRadius: BorderRadius.all(context.streamRadius.lg),
          child: SizedBox(
            width: width,
            height: 480,
            child: Stack(
              children: [
                const Positioned.fill(child: StreamBlurScrim()),
                child,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
