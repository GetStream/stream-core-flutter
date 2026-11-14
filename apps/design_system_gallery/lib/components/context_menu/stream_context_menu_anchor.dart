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
  type: StreamContextMenuAnchor,
  path: '[Components]/Context Menu',
)
Widget buildStreamContextMenuAnchorPlayground(BuildContext context) {
  final itemCount = context.knobs.int.slider(
    label: 'Item Count',
    initialValue: 4,
    min: 1,
    description: 'Number of actions in the menu. Past the max height the menu scrolls.',
  );

  final longLabels = context.knobs.boolean(
    label: 'Long Labels',
    description: 'Give every action a label longer than the max width, to show it truncating.',
  );

  final showSeparator = context.knobs.boolean(
    label: 'Destructive Section',
    initialValue: true,
    description: 'Add a separator and a destructive action at the end of the menu.',
  );

  final elevation = context.knobs.double.slider(
    label: 'Elevation',
    initialValue: 3,
    max: 12,
    divisions: 12,
    description: 'How high the menu floats. 0 leaves it separated from the page by its border alone.',
  );

  final offsetY = context.knobs.double.slider(
    label: 'Alignment Offset',
    initialValue: 8,
    min: -8,
    max: 24,
    divisions: 32,
    description: 'Vertical gap between the anchor and the menu.',
  );

  final maxWidth = context.knobs.double.slider(
    label: 'Max Width',
    initialValue: StreamContextMenuAnchor.defaultConstraints.maxWidth,
    min: 200,
    max: 480,
    divisions: 28,
    description: 'Upper bound on the menu width. The menu sizes itself to its widest row below this.',
  );

  final maxHeight = context.knobs.double.slider(
    label: 'Max Height',
    initialValue: StreamContextMenuAnchor.defaultConstraints.maxHeight,
    min: 120,
    max: 600,
    divisions: 24,
    description: 'Upper bound on the menu height.',
  );

  final rowHeight = context.knobs.double.slider(
    label: 'Row Height',
    initialValue: 32,
    min: 32,
    max: 64,
    divisions: 8,
    description: 'Overrides the design row height through actionStyle, as a menu of avatars would.',
  );

  return Center(
    child: _MenuButton(
      label: 'Open menu',
      elevation: elevation,
      alignmentOffset: Offset(0, offsetY),
      constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
      actionStyle: rowHeight == 32
          ? null
          : StreamContextMenuActionStyle(minimumSize: WidgetStatePropertyAll(Size(200, rowHeight))),
      menuChildren: _menuChildren(
        context,
        itemCount: itemCount,
        longLabels: longLabels,
        showDestructive: showSeparator,
      ),
    ),
  );
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamContextMenuAnchor,
  path: '[Components]/Context Menu',
)
Widget buildStreamContextMenuAnchorShowcase(BuildContext context) {
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
        children: [
          _ExampleCard(
            title: 'Default',
            description: 'Rows use the denser Web / Menu Item metrics: 32px tall, a 200px minimum width, 16px icons.',
            child: _MenuButton(
              label: 'Options',
              alignmentOffset: const Offset(0, 8),
              menuChildren: _menuChildren(context, itemCount: 3, showDestructive: true),
            ),
          ),
          _ExampleCard(
            title: 'Flat',
            description: 'Elevation 0 for a menu that sits on the page, separated by its border alone.',
            child: _MenuButton(
              label: 'Options',
              elevation: 0,
              alignmentOffset: const Offset(0, 8),
              menuChildren: _menuChildren(context, itemCount: 3),
            ),
          ),
          _ExampleCard(
            title: 'Long labels',
            description: 'The menu stops at its max width and labels with an ellipsis overflow truncate.',
            child: _MenuButton(
              label: 'Microphone',
              alignmentOffset: const Offset(0, 8),
              menuChildren: _menuChildren(context, itemCount: 3, longLabels: true),
            ),
          ),
          _ExampleCard(
            title: 'Scrolling',
            description: 'Past the max height the menu scrolls inside its own surface.',
            child: _MenuButton(
              label: 'Choose',
              alignmentOffset: const Offset(0, 8),
              menuChildren: _menuChildren(context, itemCount: 20),
            ),
          ),
          _ExampleCard(
            title: 'Themed',
            description: 'A StreamContextMenuAnchorTheme sets the offset and a taller row for every anchor below it.',
            child: StreamContextMenuAnchorTheme(
              data: const StreamContextMenuAnchorThemeData(
                alignmentOffset: Offset(0, 4),
                actionStyle: StreamContextMenuActionStyle(
                  minimumSize: WidgetStatePropertyAll(Size(200, 40)),
                ),
              ),
              child: _MenuButton(
                label: 'Options',
                menuChildren: _menuChildren(context, itemCount: 3),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// =============================================================================
// Shared
// =============================================================================

List<Widget> _menuChildren(
  BuildContext context, {
  required int itemCount,
  bool longLabels = false,
  bool showDestructive = false,
}) {
  final icons = context.streamIcons;
  final options = [
    (icons.edit, 'Edit'),
    (icons.copy, 'Copy'),
    (icons.pin, 'Pin'),
    (icons.share, 'Share'),
    (icons.settings, 'Settings'),
  ];

  return [
    for (var index = 0; index < itemCount; index += 1)
      StreamContextMenuAction<void>(
        onTap: () {},
        leading: Icon(options[index % options.length].$1),
        label: Text(
          longLabels
              ? '${options[index % options.length].$2} with a label far longer than the menu is allowed to grow'
              : '${options[index % options.length].$2}${index >= options.length ? ' ${index + 1}' : ''}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    if (showDestructive) ...[
      const StreamContextMenuSeparator(),
      StreamContextMenuAction<void>.destructive(
        onTap: () {},
        leading: Icon(icons.delete),
        label: const Text('Delete'),
      ),
    ],
  ];
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.label,
    required this.menuChildren,
    this.elevation,
    this.alignmentOffset,
    this.constraints,
    this.actionStyle,
  });

  final String label;
  final List<Widget> menuChildren;
  final double? elevation;
  final Offset? alignmentOffset;
  final BoxConstraints? constraints;
  final StreamContextMenuActionStyle? actionStyle;

  @override
  Widget build(BuildContext context) {
    final icons = context.streamIcons;

    return StreamContextMenuAnchor(
      elevation: elevation,
      alignmentOffset: alignmentOffset,
      constraints: constraints,
      actionStyle: actionStyle,
      menuChildren: menuChildren,
      builder: (context, controller, child) => StreamButton(
        type: StreamButtonType.outline,
        style: StreamButtonStyle.secondary,
        iconRight: Icon(controller.isOpen ? icons.chevronUp : icons.chevronDown),
        onPressed: () => controller.isOpen ? controller.close() : controller.open(),
        child: Text(label),
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
          Padding(
            padding: EdgeInsets.all(spacing.md),
            child: Align(alignment: AlignmentDirectional.centerStart, child: child),
          ),
        ],
      ),
    );
  }
}
