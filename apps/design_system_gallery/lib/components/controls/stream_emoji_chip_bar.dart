import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamEmojiChipBar,
  path: '[Components]/Controls',
)
Widget buildStreamEmojiChipBarPlayground(BuildContext context) {
  return const _PlaygroundDemo();
}

class _PlaygroundDemo extends StatefulWidget {
  const _PlaygroundDemo();

  @override
  State<_PlaygroundDemo> createState() => _PlaygroundDemoState();
}

class _PlaygroundDemoState extends State<_PlaygroundDemo> {
  late List<StreamEmojiChipItem<String>> _items;
  String? _selected;

  @override
  void initState() {
    super.initState();
    _items = _buildItems(5);
  }

  List<StreamEmojiChipItem<String>> _buildItems(int count) {
    return [
      for (var i = 0; i < count && i < _reactions.length; i++)
        StreamEmojiChipItem(
          value: _reactions[i].$1,
          emoji: StreamUnicodeEmoji(_reactions[i].$1),
          count: _reactions[i].$2,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = context.knobs.int.slider(
      label: 'Item Count',
      initialValue: 5,
      min: 1,
      max: 8,
      description: 'Number of emoji filter items.',
    );

    final showLeading = context.knobs.boolean(
      label: 'Show Leading (Add Emoji)',
      initialValue: true,
      description: 'Whether to show the add-emoji chip before items.',
    );

    final isDisabled = context.knobs.boolean(
      label: 'Disabled',
      description: 'Whether the chip bar is non-interactive.',
    );

    if (itemCount != _items.length) {
      _items = _buildItems(itemCount);
      final values = _items.map((e) => e.value).toSet();
      if (_selected != null && !values.contains(_selected)) {
        _selected = null;
      }
    }

    return Center(
      child: StreamEmojiChipBar<String>(
        leading: showLeading
            ? StreamEmojiChip.addEmoji(
                onPressed: isDisabled
                    ? null
                    : () {
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            const SnackBar(
                              content: Text('Open reaction picker'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                      },
              )
            : null,
        items: _items,
        selected: _selected,
        onSelected: isDisabled
            ? null
            : (value) {
                setState(() => _selected = value);
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(
                        value == null ? 'Filter cleared (All)' : 'Filter: $value',
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
              },
      ),
    );
  }
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamEmojiChipBar,
  path: '[Components]/Controls',
)
Widget buildStreamEmojiChipBarShowcase(BuildContext context) {
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
          _VariantsSection(),
          _SelectionStatesSection(),
          _LayoutSection(),
          _RealWorldSection(),
        ],
      ),
    ),
  );
}

// =============================================================================
// Variants Section
// =============================================================================

class _VariantsSection extends StatelessWidget {
  const _VariantsSection();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final boxShadow = context.streamBoxShadow;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: [
        const _SectionLabel(label: 'VARIANTS'),
        Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          padding: EdgeInsets.symmetric(vertical: spacing.md),
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
            spacing: spacing.md,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing.md),
                child: Text(
                  'With leading add-emoji chip, without, and disabled states.',
                  style: textTheme.captionDefault.copyWith(
                    color: colorScheme.textSecondary,
                  ),
                ),
              ),
              _VariantDemo(
                label: 'With leading',
                child: StreamEmojiChipBar<String>(
                  leading: StreamEmojiChip.addEmoji(onPressed: () {}),
                  items: _sampleItems,
                  onSelected: (_) {},
                ),
              ),
              _VariantDemo(
                label: 'Without leading',
                child: StreamEmojiChipBar<String>(
                  items: _sampleItems,
                  onSelected: (_) {},
                ),
              ),
              _VariantDemo(
                label: 'With selection',
                child: StreamEmojiChipBar<String>(
                  leading: StreamEmojiChip.addEmoji(onPressed: () {}),
                  items: _sampleItems,
                  selected: '👍',
                  onSelected: (_) {},
                ),
              ),
              _VariantDemo(
                label: 'Disabled',
                child: StreamEmojiChipBar<String>(
                  leading: StreamEmojiChip.addEmoji(),
                  items: _sampleItems,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VariantDemo extends StatelessWidget {
  const _VariantDemo({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: spacing.xs,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.md),
          child: Text(
            label,
            style: textTheme.metadataEmphasis.copyWith(
              color: colorScheme.accentPrimary,
              fontFamily: 'monospace',
            ),
          ),
        ),
        child,
      ],
    );
  }
}

// =============================================================================
// Selection States Section
// =============================================================================

class _SelectionStatesSection extends StatelessWidget {
  const _SelectionStatesSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: const [
        _SectionLabel(label: 'SELECTION STATES'),
        _ExampleCard(
          title: 'Toggle Selection',
          description:
              'Tap a chip to select it. Tap again to deselect. '
              'Only one chip can be selected at a time.',
          child: _ToggleSelectionDemo(),
        ),
      ],
    );
  }
}

class _ToggleSelectionDemo extends StatefulWidget {
  const _ToggleSelectionDemo();

  @override
  State<_ToggleSelectionDemo> createState() => _ToggleSelectionDemoState();
}

class _ToggleSelectionDemoState extends State<_ToggleSelectionDemo> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.sm,
      children: [
        StreamEmojiChipBar<String>(
          leading: StreamEmojiChip.addEmoji(onPressed: () {}),
          items: _sampleItems,
          selected: _selected,
          onSelected: (value) => setState(() => _selected = value),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.md),
          child: Text(
            _selected == null ? 'No filter active — showing all reactions' : 'Filtering by $_selected',
            style: textTheme.captionDefault.copyWith(
              color: colorScheme.textTertiary,
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Layout Section
// =============================================================================

class _LayoutSection extends StatelessWidget {
  const _LayoutSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: const [
        _SectionLabel(label: 'LAYOUT'),
        _ExampleCard(
          title: 'Overflow Scrolling',
          description:
              'When chips overflow the available width, the bar scrolls '
              'horizontally. Swipe to reveal more.',
          child: _OverflowScrollDemo(),
        ),
        _ExampleCard(
          title: 'Custom Spacing',
          description: 'Custom padding and spacing between chips.',
          child: _CustomSpacingDemo(),
        ),
      ],
    );
  }
}

class _OverflowScrollDemo extends StatelessWidget {
  const _OverflowScrollDemo();

  @override
  Widget build(BuildContext context) {
    return StreamEmojiChipBar<String>(
      leading: StreamEmojiChip.addEmoji(onPressed: () {}),
      items: _manyItems,
      onSelected: (_) {},
    );
  }
}

class _CustomSpacingDemo extends StatelessWidget {
  const _CustomSpacingDemo();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: [
        _VariantDemo(
          label: 'spacing: 16',
          child: StreamEmojiChipBar<String>(
            items: _sampleItems,
            spacing: 16,
            onSelected: (_) {},
          ),
        ),
        _VariantDemo(
          label: 'spacing: 2',
          child: StreamEmojiChipBar<String>(
            items: _sampleItems,
            spacing: 2,
            onSelected: (_) {},
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Real-World Section
// =============================================================================

class _RealWorldSection extends StatelessWidget {
  const _RealWorldSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: const [
        _SectionLabel(label: 'REAL-WORLD EXAMPLES'),
        _ExampleCard(
          title: 'Reaction Detail Sheet',
          description:
              'Filter bar above a user list — simulates the reaction detail '
              'sheet. Tap a chip to filter, tap again to show all.',
          child: _ReactionDetailExample(),
        ),
      ],
    );
  }
}

class _ReactionDetailExample extends StatefulWidget {
  const _ReactionDetailExample();

  @override
  State<_ReactionDetailExample> createState() => _ReactionDetailExampleState();
}

class _ReactionDetailExampleState extends State<_ReactionDetailExample> {
  String? _selected;

  static const _reactionUsers = [
    ('👍', ['Alice', 'Bob', 'Carol', 'Dan', 'Eve', 'Frank', 'Grace']),
    ('❤️', ['Alice', 'Carol', 'Eve', 'Grace', 'Ivy']),
    ('😂', ['Bob', 'Dan', 'Frank']),
    ('🔥', ['Carol', 'Eve']),
    ('😮', ['Dan']),
  ];

  late final _items = [
    for (final (emoji, users) in _reactionUsers)
      StreamEmojiChipItem(
        value: emoji,
        emoji: StreamUnicodeEmoji(emoji),
        count: users.length,
      ),
  ];

  List<(String emoji, String user)> get _filteredUsers {
    if (_selected == null) {
      return [
        for (final (emoji, users) in _reactionUsers)
          for (final user in users) (emoji, user),
      ];
    }
    final (emoji, users) = _reactionUsers.firstWhere((r) => r.$1 == _selected);
    return [for (final user in users) (emoji, user)];
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    final filtered = _filteredUsers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.md),
          child: Text(
            filtered.length == 1 ? '1 Reaction' : '${filtered.length} Reactions',
            style: textTheme.headingSm,
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: spacing.sm),
        StreamEmojiChipBar<String>(
          leading: StreamEmojiChip.addEmoji(onPressed: () {}),
          items: _items,
          selected: _selected,
          onSelected: (value) => setState(() => _selected = value),
        ),
        SizedBox(height: spacing.xs),
        for (final (emoji, user) in filtered) _ReactionUserTile(emoji: emoji, userName: user),
      ],
    );
  }
}

class _ReactionUserTile extends StatelessWidget {
  const _ReactionUserTile({required this.emoji, required this.userName});

  final String emoji;
  final String userName;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.md,
        vertical: spacing.xxs,
      ),
      child: Row(
        spacing: spacing.sm,
        children: [
          StreamAvatar(
            size: StreamAvatarSize.md,
            placeholder: (_) => Text(userName[0]),
          ),
          Expanded(
            child: Text(
              userName,
              style: textTheme.bodyDefault.copyWith(
                color: colorScheme.textPrimary,
              ),
            ),
          ),
          StreamEmoji(
            size: StreamEmojiSize.sm,
            emoji: StreamUnicodeEmoji(emoji),
          ),
        ],
      ),
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
            padding: EdgeInsets.symmetric(
              horizontal: spacing.md,
              vertical: spacing.sm,
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
            padding: EdgeInsets.symmetric(vertical: spacing.md),
            color: colorScheme.backgroundSurfaceSubtle,
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

// =============================================================================
// Helpers
// =============================================================================

const _reactions = [
  ('👍', 7),
  ('❤️', 5),
  ('😂', 3),
  ('🔥', 2),
  ('😮', 1),
  ('👏', 12),
  ('🎉', 4),
  ('😢', 2),
];

final _sampleItems = [
  for (final (emoji, count) in _reactions.take(5))
    StreamEmojiChipItem(
      value: emoji,
      emoji: StreamUnicodeEmoji(emoji),
      count: count,
    ),
];

final _manyItems = [
  for (final (emoji, count) in _reactions)
    StreamEmojiChipItem(
      value: emoji,
      emoji: StreamUnicodeEmoji(emoji),
      count: count,
    ),
];
