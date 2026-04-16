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
  String? _inlineTapped;
  String? _dialogReturned;

  @override
  Widget build(BuildContext context) {
    final icons = context.streamIcons;
    final spacing = context.streamSpacing;

    final actionCount = context.knobs.int.slider(
      label: 'Action Count',
      initialValue: 5,
      min: 1,
      max: 8,
      description: 'Number of regular menu actions to display.',
    );

    final showLeadingIcon = context.knobs.boolean(
      label: 'Leading Icon',
      initialValue: true,
      description: 'Show an icon before each action label.',
    );

    final showTrailingIcon = context.knobs.boolean(
      label: 'Trailing Icon',
      description: 'Show a chevron after each action label.',
    );

    final showSeparator = context.knobs.boolean(
      label: 'Separator',
      initialValue: true,
      description: 'Show a divider before the destructive group.',
    );

    final showDestructiveAction = context.knobs.boolean(
      label: 'Destructive Action',
      initialValue: true,
      description: 'Include a destructive action at the end.',
    );

    final hasDisabledAction = context.knobs.boolean(
      label: 'Disabled Action',
      description: 'Make the second action disabled.',
    );

    final actionData = <({String label, IconData icon})>[
      (label: 'Reply', icon: icons.reply),
      (label: 'Thread Reply', icon: icons.thread),
      (label: 'Pin to Conversation', icon: icons.pin),
      (label: 'Copy Message', icon: icons.copy),
      (label: 'Mark Unread', icon: icons.notification),
      (label: 'Remind Me', icon: icons.bell),
      (label: 'Save For Later', icon: icons.file),
      (label: 'Flag Message', icon: icons.flag),
    ];

    List<Widget> buildInlineActions() {
      return [
        for (var i = 0; i < actionCount; i++)
          StreamContextMenuAction<String>(
            value: actionData[i].label,
            label: Text(actionData[i].label),
            leading: showLeadingIcon ? Icon(actionData[i].icon) : null,
            trailing: showTrailingIcon ? Icon(icons.chevronRight) : null,
            enabled: !(hasDisabledAction && i == 1),
            onTap: () => setState(() => _inlineTapped = actionData[i].label),
          ),
        if (showSeparator && showDestructiveAction) const StreamContextMenuSeparator(),
        if (showDestructiveAction)
          StreamContextMenuAction<String>.destructive(
            value: 'Delete Message',
            label: const Text('Delete Message'),
            leading: showLeadingIcon ? Icon(icons.delete) : null,
            onTap: () => setState(() => _inlineTapped = 'Delete Message'),
          ),
      ];
    }

    List<Widget> buildDialogActions() {
      return [
        for (var i = 0; i < actionCount; i++)
          StreamContextMenuAction<String>(
            value: actionData[i].label,
            label: Text(actionData[i].label),
            leading: showLeadingIcon ? Icon(actionData[i].icon) : null,
            trailing: showTrailingIcon ? Icon(icons.chevronRight) : null,
            enabled: !(hasDisabledAction && i == 1),
          ),
        if (showSeparator && showDestructiveAction) const StreamContextMenuSeparator(),
        if (showDestructiveAction)
          StreamContextMenuAction<String>.destructive(
            value: 'Delete Message',
            label: const Text('Delete Message'),
            leading: showLeadingIcon ? Icon(icons.delete) : null,
          ),
      ];
    }

    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Inline header.
            Text(
              'Inline',
              style: textTheme.captionEmphasis.copyWith(
                color: colorScheme.textPrimary,
              ),
            ),
            SizedBox(height: spacing.xxs),
            Text(
              'Rendered directly — taps fire onTap',
              style: textTheme.metadataDefault.copyWith(
                color: colorScheme.textTertiary,
              ),
            ),
            SizedBox(height: spacing.sm),

            StreamContextMenu(children: buildInlineActions()),
            SizedBox(height: spacing.xs),
            _ResultChip(
              label: _inlineTapped != null ? 'onTap: "$_inlineTapped"' : 'Tap an action',
              isActive: _inlineTapped != null,
            ),

            Padding(
              padding: EdgeInsets.symmetric(vertical: spacing.xl),
              child: Divider(indent: spacing.xl, endIndent: spacing.xl),
            ),

            // Dialog header.
            Text(
              'Dialog',
              style: textTheme.captionEmphasis.copyWith(
                color: colorScheme.textPrimary,
              ),
            ),
            SizedBox(height: spacing.xxs),
            Text(
              'Opened in a route — taps return value via pop',
              style: textTheme.metadataDefault.copyWith(
                color: colorScheme.textTertiary,
              ),
            ),
            SizedBox(height: spacing.sm),

            StreamButton(
              label: 'Open as Dialog',
              type: StreamButtonType.outline,
              size: StreamButtonSize.small,
              onTap: () async {
                final result = await showDialog<String>(
                  context: context,
                  useRootNavigator: false,
                  builder: (_) => Dialog(
                    backgroundColor: StreamColors.transparent,
                    child: StreamContextMenu(
                      children: buildDialogActions(),
                    ),
                  ),
                );
                if (mounted && result != null) {
                  setState(() => _dialogReturned = result);
                }
              },
            ),
            SizedBox(height: spacing.xs),
            _ResultChip(
              label: _dialogReturned != null ? 'value: "$_dialogReturned"' : 'Open and select',
              isActive: _dialogReturned != null,
            ),
          ],
        ),
      ),
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
          const _ActionStatesSection(),
          SizedBox(height: spacing.xl),
          const _MenuCompositionsSection(),
          SizedBox(height: spacing.xl),
          const _DialogIntegrationSection(),
          SizedBox(height: spacing.xl),
          const _CustomThemingSection(),
          SizedBox(height: spacing.xl),
          const _RealWorldSection(),
        ],
      ),
    ),
  );
}

// =============================================================================
// Action States Section
// =============================================================================

class _ActionStatesSection extends StatelessWidget {
  const _ActionStatesSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: const [
        _SectionLabel(label: 'ACTION STATES'),
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
          StreamContextMenuAction<void>(
            label: const Text(
              'With Leading & Trailing',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            leading: Icon(icons.plus),
            trailing: Icon(icons.chevronRight),
          ),
          StreamContextMenuAction<void>(
            label: const Text('With Leading Only'),
            leading: Icon(icons.plus),
          ),
          StreamContextMenuAction<void>(
            label: const Text('Label Only'),
          ),
          StreamContextMenuAction<void>(
            label: const Text('Disabled'),
            leading: Icon(icons.plus),
            trailing: Icon(icons.chevronRight),
            enabled: false,
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
          StreamContextMenuAction<void>.destructive(
            label: const Text(
              'With Leading & Trailing',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            leading: Icon(icons.delete),
            trailing: Icon(icons.chevronRight),
          ),
          StreamContextMenuAction<void>.destructive(
            label: const Text('With Leading Only'),
            leading: Icon(icons.delete),
          ),
          StreamContextMenuAction<void>.destructive(
            label: const Text('Label Only'),
          ),
          StreamContextMenuAction<void>.destructive(
            label: const Text('Disabled'),
            leading: Icon(icons.delete),
            trailing: Icon(icons.chevronRight),
            enabled: false,
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
          description: 'Basic actions without icons',
          child: Center(
            child: StreamContextMenu(
              children: [
                StreamContextMenuAction<void>(
                  label: const Text('Cut'),
                ),
                StreamContextMenuAction<void>(
                  label: const Text('Copy'),
                ),
                StreamContextMenuAction<void>(
                  label: const Text('Paste'),
                ),
              ],
            ),
          ),
        ),
        _ExampleCard(
          title: 'With Icons',
          description: 'Actions with leading icons',
          child: Center(
            child: StreamContextMenu(
              children: [
                StreamContextMenuAction<void>(
                  label: const Text('Reply'),
                  leading: Icon(icons.reply),
                ),
                StreamContextMenuAction<void>(
                  label: const Text('Copy Message'),
                  leading: Icon(icons.copy),
                ),
                StreamContextMenuAction<void>(
                  label: const Text('Flag Message'),
                  leading: Icon(icons.flag),
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
                StreamContextMenuAction<void>(
                  label: const Text('Reply'),
                  leading: Icon(icons.reply),
                ),
                StreamContextMenuAction<void>(
                  label: const Text('Copy Message'),
                  leading: Icon(icons.copy),
                ),
                const StreamContextMenuSeparator(),
                StreamContextMenuAction<void>.destructive(
                  label: const Text('Delete'),
                  leading: Icon(icons.delete),
                ),
              ],
            ),
          ),
        ),
        _ExampleCard(
          title: 'Auto-Separated',
          description: 'Using StreamContextMenuAction.separated',
          child: Center(
            child: StreamContextMenu(
              children: StreamContextMenuAction.separated(
                items: [
                  StreamContextMenuAction<void>(
                    label: const Text('Reply'),
                    leading: Icon(icons.reply),
                  ),
                  StreamContextMenuAction<void>(
                    label: const Text('Copy Message'),
                    leading: Icon(icons.copy),
                  ),
                  StreamContextMenuAction<void>(
                    label: const Text('Flag Message'),
                    leading: Icon(icons.flag),
                  ),
                ],
              ),
            ),
          ),
        ),
        _ExampleCard(
          title: 'Auto-Sectioned',
          description: 'Using StreamContextMenuAction.sectioned',
          child: Center(
            child: StreamContextMenu(
              children: StreamContextMenuAction.sectioned(
                sections: [
                  [
                    StreamContextMenuAction<void>(
                      label: const Text('Reply'),
                      leading: Icon(icons.reply),
                    ),
                    StreamContextMenuAction<void>(
                      label: const Text('Copy Message'),
                      leading: Icon(icons.copy),
                    ),
                    StreamContextMenuAction<void>(
                      label: const Text('Flag Message'),
                      leading: Icon(icons.flag),
                    ),
                  ],
                  [
                    StreamContextMenuAction<void>.destructive(
                      label: const Text('Delete Message'),
                      leading: Icon(icons.delete),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        _ExampleCard(
          title: 'Auto-Partitioned',
          description: 'Using StreamContextMenuAction.partitioned',
          child: Center(
            child: StreamContextMenu(
              children: StreamContextMenuAction.partitioned(
                items: [
                  StreamContextMenuAction<void>(
                    label: const Text('Reply'),
                    leading: Icon(icons.reply),
                  ),
                  StreamContextMenuAction<void>(
                    label: const Text('Copy Message'),
                    leading: Icon(icons.copy),
                  ),
                  StreamContextMenuAction<void>(
                    label: const Text('Flag Message'),
                    leading: Icon(icons.flag),
                  ),
                  StreamContextMenuAction<void>.destructive(
                    label: const Text('Delete Message'),
                    leading: Icon(icons.delete),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Dialog Integration Section
// =============================================================================

enum _SampleAction { reply, copy, flag, delete }

class _DialogIntegrationSection extends StatelessWidget {
  const _DialogIntegrationSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: const [
        _SectionLabel(label: 'DIALOG INTEGRATION'),
        _TypedValueReturnCard(),
        _EnumValueReturnCard(),
      ],
    );
  }
}

class _TypedValueReturnCard extends StatefulWidget {
  const _TypedValueReturnCard();

  @override
  State<_TypedValueReturnCard> createState() => _TypedValueReturnCardState();
}

class _TypedValueReturnCardState extends State<_TypedValueReturnCard> {
  String? _result;

  @override
  Widget build(BuildContext context) {
    final icons = context.streamIcons;
    final spacing = context.streamSpacing;

    return _ExampleCard(
      title: 'String Value Return',
      description: 'Actions carry a String value returned via Navigator.pop',
      child: Center(
        child: Column(
          spacing: spacing.sm,
          children: [
            StreamButton(
              label: 'Open Menu',
              type: StreamButtonType.outline,
              size: StreamButtonSize.small,
              onTap: () async {
                final result = await showDialog<String>(
                  context: context,
                  builder: (_) => Dialog(
                    backgroundColor: StreamColors.transparent,
                    child: StreamContextMenu(
                      children: [
                        StreamContextMenuAction<String>(
                          value: 'reply',
                          label: const Text('Reply'),
                          leading: Icon(icons.reply),
                        ),
                        StreamContextMenuAction<String>(
                          value: 'copy',
                          label: const Text('Copy Message'),
                          leading: Icon(icons.copy),
                        ),
                        StreamContextMenuAction<String>(
                          value: 'flag',
                          label: const Text('Flag Message'),
                          leading: Icon(icons.flag),
                        ),
                      ],
                    ),
                  ),
                );
                setState(() => _result = result);
              },
            ),
            _ResultChip(
              label: _result != null ? '"$_result"' : 'No selection yet',
              isActive: _result != null,
            ),
          ],
        ),
      ),
    );
  }
}

class _EnumValueReturnCard extends StatefulWidget {
  const _EnumValueReturnCard();

  @override
  State<_EnumValueReturnCard> createState() => _EnumValueReturnCardState();
}

class _EnumValueReturnCardState extends State<_EnumValueReturnCard> {
  _SampleAction? _result;

  @override
  Widget build(BuildContext context) {
    final icons = context.streamIcons;
    final spacing = context.streamSpacing;

    return _ExampleCard(
      title: 'Enum Value Return',
      description: 'Type-safe actions using an enum as the value type',
      child: Center(
        child: Column(
          spacing: spacing.sm,
          children: [
            StreamButton(
              label: 'Open Menu',
              type: StreamButtonType.outline,
              size: StreamButtonSize.small,
              onTap: () async {
                final result = await showDialog<_SampleAction>(
                  context: context,
                  builder: (_) => Dialog(
                    backgroundColor: StreamColors.transparent,
                    child: StreamContextMenu(
                      children: [
                        StreamContextMenuAction<_SampleAction>(
                          value: _SampleAction.reply,
                          label: const Text('Reply'),
                          leading: Icon(icons.reply),
                        ),
                        StreamContextMenuAction<_SampleAction>(
                          value: _SampleAction.copy,
                          label: const Text('Copy Message'),
                          leading: Icon(icons.copy),
                        ),
                        StreamContextMenuAction<_SampleAction>(
                          value: _SampleAction.flag,
                          label: const Text('Flag Message'),
                          leading: Icon(icons.flag),
                        ),
                        const StreamContextMenuSeparator(),
                        StreamContextMenuAction<_SampleAction>.destructive(
                          value: _SampleAction.delete,
                          label: const Text('Delete Message'),
                          leading: Icon(icons.delete),
                        ),
                      ],
                    ),
                  ),
                );
                setState(() => _result = result);
              },
            ),
            _ResultChip(
              label: _result != null ? '_SampleAction.${_result!.name}' : 'No selection yet',
              isActive: _result != null,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Custom Theming Section
// =============================================================================

class _CustomThemingSection extends StatelessWidget {
  const _CustomThemingSection();

  @override
  Widget build(BuildContext context) {
    final icons = context.streamIcons;
    final spacing = context.streamSpacing;
    final colorScheme = context.streamColorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: [
        const _SectionLabel(label: 'CUSTOM THEMING'),
        _ExampleCard(
          title: 'Compact Style',
          description: 'Smaller padding and text for dense layouts',
          child: Center(
            child: StreamContextMenuActionTheme(
              data: const StreamContextMenuActionThemeData(
                style: StreamContextMenuActionStyle(
                  minimumSize: WidgetStatePropertyAll(Size(200, 32)),
                  iconSize: WidgetStatePropertyAll(16),
                  padding: WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
              ),
              child: StreamContextMenu(
                children: [
                  StreamContextMenuAction<void>(
                    label: const Text('Reply'),
                    leading: Icon(icons.reply),
                  ),
                  StreamContextMenuAction<void>(
                    label: const Text('Copy'),
                    leading: Icon(icons.copy),
                  ),
                  StreamContextMenuAction<void>(
                    label: const Text('Flag'),
                    leading: Icon(icons.flag),
                  ),
                ],
              ),
            ),
          ),
        ),
        _ExampleCard(
          title: 'Sub-Menu Navigation',
          description: 'Back action with tertiary styling via a local theme',
          child: Center(
            child: StreamContextMenu(
              children: [
                StreamContextMenuActionTheme(
                  data: StreamContextMenuActionThemeData(
                    style: StreamContextMenuActionStyle(
                      foregroundColor: WidgetStatePropertyAll(
                        colorScheme.textTertiary,
                      ),
                      iconColor: WidgetStatePropertyAll(
                        colorScheme.textTertiary,
                      ),
                    ),
                  ),
                  child: StreamContextMenuAction<void>(
                    label: const Text('Reactions'),
                    leading: Icon(icons.chevronLeft),
                  ),
                ),
                StreamContextMenuAction<void>(
                  label: const Text('Love'),
                  leading: Icon(icons.emoji),
                ),
                StreamContextMenuAction<void>(
                  label: const Text('Smile'),
                  leading: Icon(icons.emoji),
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
                StreamContextMenuAction<void>(
                  label: const Text('Reply'),
                  leading: Icon(icons.reply),
                ),
                StreamContextMenuAction<void>(
                  label: const Text('Thread Reply'),
                  leading: Icon(icons.thread),
                ),
                StreamContextMenuAction<void>(
                  label: const Text('Pin to Conversation'),
                  leading: Icon(icons.pin),
                ),
                StreamContextMenuAction<void>(
                  label: const Text('Copy Message'),
                  leading: Icon(icons.copy),
                ),
                StreamContextMenuAction<void>(
                  label: const Text('Mark Unread'),
                  leading: Icon(icons.notification),
                ),
                StreamContextMenuAction<void>(
                  label: const Text('Remind Me'),
                  leading: Icon(icons.bell),
                ),
                StreamContextMenuAction<void>(
                  label: const Text('Save For Later'),
                  leading: Icon(icons.file),
                ),
                StreamContextMenuAction<void>(
                  label: const Text('Flag Message'),
                  leading: Icon(icons.flag),
                ),
                StreamContextMenuAction<void>(
                  label: const Text('Mute User'),
                  leading: Icon(icons.mute),
                ),
                const StreamContextMenuSeparator(),
                StreamContextMenuAction<void>.destructive(
                  label: const Text('Block User'),
                  leading: Icon(icons.noSign),
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
                StreamContextMenuAction<void>(
                  label: const Text('Reply'),
                  leading: Icon(icons.reply),
                ),
                StreamContextMenuAction<void>(
                  label: const Text('Thread Reply'),
                  leading: Icon(icons.thread),
                ),
                StreamContextMenuAction<void>(
                  label: const Text('Pin to Conversation'),
                  leading: Icon(icons.pin),
                ),
                StreamContextMenuAction<void>(
                  label: const Text('Copy Message'),
                  leading: Icon(icons.copy),
                ),
                StreamContextMenuAction<void>(
                  label: const Text('Edit Message'),
                  leading: Icon(icons.edit),
                ),
                const StreamContextMenuSeparator(),
                StreamContextMenuAction<void>.destructive(
                  label: const Text('Delete Message'),
                  leading: Icon(icons.delete),
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

class _ResultChip extends StatelessWidget {
  const _ResultChip({required this.label, required this.isActive});

  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.sm,
        vertical: spacing.xs,
      ),
      decoration: BoxDecoration(
        color: isActive ? colorScheme.accentPrimary.withValues(alpha: 0.1) : colorScheme.backgroundSurfaceSubtle,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isActive ? colorScheme.accentPrimary : colorScheme.borderDefault,
        ),
      ),
      child: Text(
        label,
        style: textTheme.metadataEmphasis.copyWith(
          fontFamily: isActive ? 'monospace' : null,
          color: isActive ? colorScheme.accentPrimary : colorScheme.textTertiary,
        ),
      ),
    );
  }
}
