import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamContextMenu,
  path: '[Components]/Context Menu',
)
Widget buildStreamContextMenuPlayground(BuildContext context) {
  return const _PlaygroundDemo();
}

class _PlaygroundDemo extends StatefulWidget {
  const _PlaygroundDemo();

  @override
  State<_PlaygroundDemo> createState() => _PlaygroundDemoState();
}

class _PlaygroundDemoState extends State<_PlaygroundDemo> {
  @override
  Widget build(BuildContext context) {
    final icons = context.streamIcons;

    final itemCount = context.knobs.int.slider(
      label: 'Item Count',
      initialValue: 5,
      min: 1,
      max: 8,
      description: 'Number of regular menu items to display.',
    );

    final showLeadingIcon = context.knobs.boolean(
      label: 'Leading Icon',
      initialValue: true,
      description: 'Show an icon before each item label.',
    );

    final showTrailingIcon = context.knobs.boolean(
      label: 'Trailing Icon',
      description: 'Show a chevron after each item label.',
    );

    final showSeparator = context.knobs.boolean(
      label: 'Separator',
      initialValue: true,
      description: 'Show a divider before the last item group.',
    );

    final showDestructiveItem = context.knobs.boolean(
      label: 'Destructive Item',
      initialValue: true,
      description: 'Include a destructive action at the end.',
    );

    final hasDisabledItem = context.knobs.boolean(
      label: 'Disabled Item',
      description: 'Make the second item disabled.',
    );

    void onTap(String label) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Tapped: $label'),
            duration: const Duration(seconds: 1),
          ),
        );
    }

    final itemData = <({String label, IconData icon})>[
      (label: 'Reply', icon: icons.arrowShareLeft),
      (label: 'Thread Reply', icon: icons.bubbleText6ChatMessage),
      (label: 'Pin to Conversation', icon: icons.pin),
      (label: 'Copy Message', icon: icons.squareBehindSquare2Copy),
      (label: 'Mark Unread', icon: icons.bubbleWideNotificationChatMessage),
      (label: 'Remind Me', icon: icons.bellNotification),
      (label: 'Save For Later', icon: icons.fileBend),
      (label: 'Flag Message', icon: icons.flag2),
    ];

    final items = <Widget>[
      for (var i = 0; i < itemCount; i++)
        StreamContextMenuItem(
          label: Text(itemData[i].label),
          leading: showLeadingIcon ? Icon(itemData[i].icon) : null,
          trailing: showTrailingIcon ? Icon(icons.chevronRight) : null,
          onPressed: (hasDisabledItem && i == 1) ? null : () => onTap(itemData[i].label),
        ),
      if (showSeparator && showDestructiveItem) const StreamContextMenuSeparator(),
      if (showDestructiveItem)
        StreamContextMenuItem.destructive(
          label: const Text('Delete Message'),
          leading: showLeadingIcon ? Icon(icons.trashBin) : null,
          onPressed: () => onTap('Delete Message'),
        ),
    ];

    return Center(
      child: StreamContextMenu(children: items),
    );
  }
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamContextMenu,
  path: '[Components]/Context Menu',
)
Widget buildStreamContextMenuShowcase(BuildContext context) {
  final colorScheme = context.streamColorScheme;
  final textTheme = context.streamTextTheme;
  final spacing = context.streamSpacing;

  return DefaultTextStyle(
    style: textTheme.bodyDefault.copyWith(color: colorScheme.textPrimary),
    child: SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ItemStatesSection(),
          SizedBox(height: spacing.xl),
          const _MenuCompositionsSection(),
          SizedBox(height: spacing.xl),
          const _RealWorldSection(),
        ],
      ),
    ),
  );
}

// =============================================================================
// Item States Section
// =============================================================================

class _ItemStatesSection extends StatelessWidget {
  const _ItemStatesSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: const [
        _SectionLabel(label: 'ITEM STATES'),
        _NormalStatesCard(),
        _DestructiveStatesCard(),
      ],
    );
  }
}

class _NormalStatesCard extends StatelessWidget {
  const _NormalStatesCard();

  @override
  Widget build(BuildContext context) {
    final icons = context.streamIcons;
    final spacing = context.streamSpacing;

    return _ExampleCard(
      title: 'Normal',
      description: 'Default styling for standard actions',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.xxs,
        children: [
          StreamContextMenuItem(
            label: const Text(
              'With Leading & Trailing',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            leading: Icon(icons.plusLarge),
            trailing: Icon(icons.chevronRight),
            onPressed: () {},
          ),
          StreamContextMenuItem(
            label: const Text('With Leading Only'),
            leading: Icon(icons.plusLarge),
            onPressed: () {},
          ),
          StreamContextMenuItem(
            label: const Text('Label Only'),
            onPressed: () {},
          ),
          StreamContextMenuItem(
            label: const Text('Disabled'),
            leading: Icon(icons.plusLarge),
            trailing: Icon(icons.chevronRight),
          ),
        ],
      ),
    );
  }
}

class _DestructiveStatesCard extends StatelessWidget {
  const _DestructiveStatesCard();

  @override
  Widget build(BuildContext context) {
    final icons = context.streamIcons;
    final spacing = context.streamSpacing;

    return _ExampleCard(
      title: 'Destructive',
      description: 'Error styling for dangerous actions',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.xxs,
        children: [
          StreamContextMenuItem.destructive(
            label: const Text(
              'With Leading & Trailing',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            leading: Icon(icons.trashBin),
            trailing: Icon(icons.chevronRight),
            onPressed: () {},
          ),
          StreamContextMenuItem.destructive(
            label: const Text('With Leading Only'),
            leading: Icon(icons.trashBin),
            onPressed: () {},
          ),
          StreamContextMenuItem.destructive(
            label: const Text('Label Only'),
            onPressed: () {},
          ),
          StreamContextMenuItem.destructive(
            label: const Text('Disabled'),
            leading: Icon(icons.trashBin),
            trailing: Icon(icons.chevronRight),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Menu Compositions Section
// =============================================================================

class _MenuCompositionsSection extends StatelessWidget {
  const _MenuCompositionsSection();

  @override
  Widget build(BuildContext context) {
    final icons = context.streamIcons;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: [
        const _SectionLabel(label: 'MENU COMPOSITIONS'),
        _ExampleCard(
          title: 'Simple Menu',
          description: 'Basic items without icons',
          child: Center(
            child: StreamContextMenu(
              children: [
                StreamContextMenuItem(
                  label: const Text('Cut'),
                  onPressed: () {},
                ),
                StreamContextMenuItem(
                  label: const Text('Copy'),
                  onPressed: () {},
                ),
                StreamContextMenuItem(
                  label: const Text('Paste'),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
        _ExampleCard(
          title: 'With Icons',
          description: 'Items with leading icons',
          child: Center(
            child: StreamContextMenu(
              children: [
                StreamContextMenuItem(
                  label: const Text('Reply'),
                  leading: Icon(icons.arrowShareLeft),
                  onPressed: () {},
                ),
                StreamContextMenuItem(
                  label: const Text('Copy Message'),
                  leading: Icon(icons.squareBehindSquare2Copy),
                  onPressed: () {},
                ),
                StreamContextMenuItem(
                  label: const Text('Flag Message'),
                  leading: Icon(icons.flag2),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
        _ExampleCard(
          title: 'With Separator',
          description: 'Groups divided by a separator',
          child: Center(
            child: StreamContextMenu(
              children: [
                StreamContextMenuItem(
                  label: const Text('Reply'),
                  leading: Icon(icons.arrowShareLeft),
                  onPressed: () {},
                ),
                StreamContextMenuItem(
                  label: const Text('Copy Message'),
                  leading: Icon(icons.squareBehindSquare2Copy),
                  onPressed: () {},
                ),
                const StreamContextMenuSeparator(),
                StreamContextMenuItem.destructive(
                  label: const Text('Delete'),
                  leading: Icon(icons.trashBin),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
        _ExampleCard(
          title: 'Auto-Separated',
          description: 'Using StreamContextMenu.separated',
          child: Center(
            child: StreamContextMenu.separated(
              children: [
                StreamContextMenuItem(
                  label: const Text('Reply'),
                  leading: Icon(icons.arrowShareLeft),
                  onPressed: () {},
                ),
                StreamContextMenuItem(
                  label: const Text('Copy Message'),
                  leading: Icon(icons.squareBehindSquare2Copy),
                  onPressed: () {},
                ),
                StreamContextMenuItem(
                  label: const Text('Flag Message'),
                  leading: Icon(icons.flag2),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
        _ExampleCard(
          title: 'Sub-Menu Navigation',
          description: 'Back item with nested items',
          child: Center(
            child: StreamContextMenu(
              children: [
                StreamContextMenuItemTheme(
                  data: StreamContextMenuItemThemeData(
                    style: StreamContextMenuItemStyle(
                      foregroundColor: WidgetStatePropertyAll(
                        context.streamColorScheme.textTertiary,
                      ),
                      iconColor: WidgetStatePropertyAll(
                        context.streamColorScheme.textTertiary,
                      ),
                    ),
                  ),
                  child: StreamContextMenuItem(
                    label: const Text('Reactions'),
                    leading: Icon(icons.chevronLeft),
                    onPressed: () {},
                  ),
                ),
                StreamContextMenuItem(
                  label: const Text('Love'),
                  leading: Icon(icons.heart2),
                  onPressed: () {},
                ),
                StreamContextMenuItem(
                  label: const Text('Smile'),
                  leading: Icon(icons.emojiSmile),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Real-World Examples Section
// =============================================================================

class _RealWorldSection extends StatelessWidget {
  const _RealWorldSection();

  @override
  Widget build(BuildContext context) {
    final icons = context.streamIcons;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: [
        const _SectionLabel(label: 'REAL-WORLD EXAMPLES'),
        _ExampleCard(
          title: 'Incoming Message Actions',
          description: 'Actions for a message from another user',
          child: Center(
            child: StreamContextMenu(
              children: [
                StreamContextMenuItem(
                  label: const Text('Reply'),
                  leading: Icon(icons.arrowShareLeft),
                  onPressed: () {},
                ),
                StreamContextMenuItem(
                  label: const Text('Thread Reply'),
                  leading: Icon(icons.bubbleText6ChatMessage),
                  onPressed: () {},
                ),
                StreamContextMenuItem(
                  label: const Text('Pin to Conversation'),
                  leading: Icon(icons.pin),
                  onPressed: () {},
                ),
                StreamContextMenuItem(
                  label: const Text('Copy Message'),
                  leading: Icon(icons.squareBehindSquare2Copy),
                  onPressed: () {},
                ),
                StreamContextMenuItem(
                  label: const Text('Mark Unread'),
                  leading: Icon(icons.bubbleWideNotificationChatMessage),
                  onPressed: () {},
                ),
                StreamContextMenuItem(
                  label: const Text('Remind Me'),
                  leading: Icon(icons.bellNotification),
                  onPressed: () {},
                ),
                StreamContextMenuItem(
                  label: const Text('Save For Later'),
                  leading: Icon(icons.fileBend),
                  onPressed: () {},
                ),
                StreamContextMenuItem(
                  label: const Text('Flag Message'),
                  leading: Icon(icons.flag2),
                  onPressed: () {},
                ),
                StreamContextMenuItem(
                  label: const Text('Mute User'),
                  leading: Icon(icons.mute),
                  onPressed: () {},
                ),
                const StreamContextMenuSeparator(),
                StreamContextMenuItem.destructive(
                  label: const Text('Block User'),
                  leading: Icon(icons.circleBanSign),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
        _ExampleCard(
          title: 'Outgoing Message Actions',
          description: 'Actions for a message sent by the current user',
          child: Center(
            child: StreamContextMenu(
              children: [
                StreamContextMenuItem(
                  label: const Text('Reply'),
                  leading: Icon(icons.arrowShareLeft),
                  onPressed: () {},
                ),
                StreamContextMenuItem(
                  label: const Text('Thread Reply'),
                  leading: Icon(icons.bubbleText6ChatMessage),
                  onPressed: () {},
                ),
                StreamContextMenuItem(
                  label: const Text('Pin to Conversation'),
                  leading: Icon(icons.pin),
                  onPressed: () {},
                ),
                StreamContextMenuItem(
                  label: const Text('Copy Message'),
                  leading: Icon(icons.squareBehindSquare2Copy),
                  onPressed: () {},
                ),
                StreamContextMenuItem(
                  label: const Text('Edit Message'),
                  leading: Icon(icons.editBig),
                  onPressed: () {},
                ),
                const StreamContextMenuSeparator(),
                StreamContextMenuItem.destructive(
                  label: const Text('Delete Message'),
                  leading: Icon(icons.trashBin),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Shared Widgets
// =============================================================================

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
      clipBehavior: Clip.antiAlias,
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
            padding: EdgeInsets.fromLTRB(
              spacing.md,
              spacing.sm,
              spacing.md,
              spacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.captionEmphasis.copyWith(
                    color: colorScheme.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: textTheme.metadataDefault.copyWith(
                    color: colorScheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colorScheme.borderSubtle),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(spacing.md),
            color: colorScheme.backgroundSurface,
            child: child,
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.sm,
        vertical: spacing.xs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.accentPrimary,
        borderRadius: BorderRadius.all(radius.xs),
      ),
      child: Text(
        label,
        style: textTheme.metadataEmphasis.copyWith(
          color: colorScheme.textOnAccent,
          letterSpacing: 1,
          fontSize: 9,
        ),
      ),
    );
  }
}
