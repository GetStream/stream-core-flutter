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
  type: StreamRadioIndicator,
  path: '[Components]/Controls',
)
Widget buildStreamRadioIndicatorPlayground(BuildContext context) {
  final selected = context.knobs.boolean(
    label: 'Selected',
    initialValue: true,
    description: 'Whether the entry this indicator belongs to is the selected one.',
  );

  final size = context.knobs.double.slider(
    label: 'Size',
    min: 12,
    max: 32,
    initialValue: 16,
    divisions: 10,
    description: 'Diameter of the indicator, set through StreamRadioIndicatorStyle.size.',
  );

  final dotSize = context.knobs.double.slider(
    label: 'Dot Size',
    min: 4,
    max: 16,
    initialValue: 8,
    divisions: 12,
    description: 'Diameter of the selected dot, set through StreamRadioIndicatorStyle.dotSize.',
  );

  return Center(
    child: StreamRadioIndicatorTheme(
      data: StreamRadioIndicatorThemeData(
        style: StreamRadioIndicatorStyle(size: size, dotSize: dotSize),
      ),
      child: StreamRadioIndicator(selected: selected),
    ),
  );
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamRadioIndicator,
  path: '[Components]/Controls',
)
Widget buildStreamRadioIndicatorShowcase(BuildContext context) {
  final colorScheme = context.streamColorScheme;
  final textTheme = context.streamTextTheme;
  final spacing = context.streamSpacing;

  return DefaultTextStyle(
    style: textTheme.bodyDefault.copyWith(color: colorScheme.textPrimary),
    child: SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.xl,
        children: const [
          _StatesSection(),
          _SelectionListSection(),
          _ThemedSection(),
        ],
      ),
    ),
  );
}

class _StatesSection extends StatelessWidget {
  const _StatesSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return _ExampleCard(
      title: 'States',
      description: 'Filled with a dot when selected, outlined when not.',
      child: Row(
        spacing: spacing.xl,
        children: [
          for (final selected in [true, false])
            Row(
              spacing: spacing.sm,
              children: [
                StreamRadioIndicator(selected: selected),
                Text(selected ? 'selected' : 'unselected'),
              ],
            ),
        ],
      ),
    );
  }
}

class _SelectionListSection extends StatefulWidget {
  const _SelectionListSection();

  @override
  State<_SelectionListSection> createState() => _SelectionListSectionState();
}

class _SelectionListSectionState extends State<_SelectionListSection> {
  static const _options = ['Built-in microphone', 'USB headset', 'Bluetooth earbuds'];

  var _selected = _options.first;

  @override
  Widget build(BuildContext context) {
    return _ExampleCard(
      title: 'Selection list',
      description: 'The row owns the tap target and the semantics; the indicator only marks which entry is selected.',
      child: Column(
        children: [
          for (final option in _options)
            StreamListTile(
              leading: StreamRadioIndicator(selected: option == _selected),
              title: Text(option),
              selected: option == _selected,
              onTap: () => setState(() => _selected = option),
            ),
        ],
      ),
    );
  }
}

class _ThemedSection extends StatelessWidget {
  const _ThemedSection();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final spacing = context.streamSpacing;

    return _ExampleCard(
      title: 'Themed',
      description: 'StreamRadioIndicatorStyle.from overrides the selected fill and the unselected border.',
      child: StreamRadioIndicatorTheme(
        data: StreamRadioIndicatorThemeData(
          style: StreamRadioIndicatorStyle.from(
            selectedFillColor: colorScheme.accentSuccess,
            side: BorderSide(color: colorScheme.accentSuccess, width: 2),
          ),
        ),
        child: Row(
          spacing: spacing.xl,
          children: [
            StreamRadioIndicator(selected: true),
            StreamRadioIndicator(selected: false),
          ],
        ),
      ),
    );
  }
}

class _ExampleCard extends StatelessWidget {
  const _ExampleCard({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final boxShadow = context.streamBoxShadow;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.backgroundSurfaceSubtle,
        borderRadius: BorderRadius.all(radius.lg),
        boxShadow: boxShadow.elevation1,
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.all(radius.lg),
        border: Border.all(color: colorScheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(spacing.md, spacing.sm, spacing.md, spacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.captionEmphasis.copyWith(color: colorScheme.textPrimary)),
                Text(description, style: textTheme.metadataDefault.copyWith(color: colorScheme.textTertiary)),
              ],
            ),
          ),
          Divider(height: 1, color: colorScheme.borderSubtle),
          Padding(padding: EdgeInsets.all(spacing.md), child: child),
        ],
      ),
    );
  }
}
