import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:unicode_emojis/unicode_emojis.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamEmojiChip,
  path: '[Components]/Controls',
)
Widget buildStreamEmojiChipPlayground(BuildContext context) {
  return const _PlaygroundDemo();
}

class _PlaygroundDemo extends StatefulWidget {
  const _PlaygroundDemo();

  @override
  State<_PlaygroundDemo> createState() => _PlaygroundDemoState();
}

class _PlaygroundDemoState extends State<_PlaygroundDemo> {
  var _isSelected = false;

  @override
  Widget build(BuildContext context) {
    final chipType = context.knobs.object.dropdown(
      label: 'Chip Type',
      options: _ChipType.values,
      initialOption: _ChipType.single,
      labelBuilder: (t) => t.label,
      description: 'Which chip variant to display.',
    );

    final isSingle = chipType == _ChipType.single;
    final isCluster = chipType == _ChipType.cluster;
    final isOverflow = chipType == _ChipType.overflow;
    final isAddEmoji = chipType == _ChipType.addEmoji;

    final emoji = isSingle
        ? context.knobs.object.dropdown(
            label: 'Emoji',
            options: _sampleEmojis,
            initialOption: _sampleEmojis.first,
            labelBuilder: (e) => '${e.emoji}  ${e.name}',
            description: 'The emoji to display.',
          )
        : null;

    final clusterSize = isCluster
        ? context.knobs.int.slider(
            label: 'Cluster Size',
            initialValue: 3,
            min: 1,
            max: _sampleEmojis.length,
            description: 'Number of emoji icons shown inside the cluster chip.',
          )
        : null;

    final overflowCount = isOverflow
        ? context.knobs.int.slider(
            label: 'Overflow Count',
            initialValue: 7,
            min: 1,
            max: 99,
            description: 'The overflow count displayed as +N.',
          )
        : null;

    final showCount =
        !isAddEmoji &&
        !isOverflow &&
        context.knobs.boolean(
          label: 'Show Count',
          initialValue: true,
          description: 'Whether to show the reaction count label.',
        );

    final count = (!isAddEmoji && !isOverflow && showCount)
        ? context.knobs.int.slider(
            label: 'Count',
            initialValue: isCluster ? 12 : 1,
            min: 1,
            max: 99,
            description: 'The reaction count to display.',
          )
        : null;

    final isDisabled = context.knobs.boolean(
      label: 'Disabled',
      description: 'Whether the chip is disabled (non-interactive).',
    );

    final showLongPress = context.knobs.boolean(
      label: 'Long Press',
      description: 'Whether long-press is handled (e.g. to open a skin-tone picker).',
    );

    void onPressed() {
      setState(() => _isSelected = !_isSelected);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(_isSelected ? 'Reaction added' : 'Reaction removed'),
            duration: const Duration(seconds: 1),
          ),
        );
    }

    void onLongPressed() {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Long pressed — e.g. open skin-tone picker'),
            duration: Duration(seconds: 1),
          ),
        );
    }

    return Center(
      child: switch (chipType) {
        _ChipType.addEmoji => StreamEmojiChip.addEmoji(
          onPressed: isDisabled ? null : onPressed,
          onLongPress: (showLongPress && !isDisabled) ? onLongPressed : null,
        ),
        _ChipType.overflow => StreamEmojiChip.overflow(
          count: overflowCount!,
          onPressed: isDisabled ? null : onPressed,
        ),
        _ChipType.cluster => StreamEmojiChip.cluster(
          emojis: [
            for (final e in _sampleEmojis.take(clusterSize!)) Text(e.emoji),
          ],
          count: count,
          isSelected: _isSelected,
          onPressed: isDisabled ? null : onPressed,
          onLongPress: (showLongPress && !isDisabled) ? onLongPressed : null,
        ),
        _ChipType.single => StreamEmojiChip(
          emoji: Text(emoji!.emoji),
          count: count,
          isSelected: _isSelected,
          onPressed: isDisabled ? null : onPressed,
          onLongPress: (showLongPress && !isDisabled) ? onLongPressed : null,
        ),
      },
    );
  }
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamEmojiChip,
  path: '[Components]/Controls',
)
Widget buildStreamEmojiChipShowcase(BuildContext context) {
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
          _TypeVariantsSection(),
          _ClusterVariantsSection(),
          _OverflowVariantsSection(),
          _CountValuesSection(),
          _StateMatrixSection(),
          _RealWorldSection(),
        ],
      ),
    ),
  );
}

// =============================================================================
// Type Variants Section
// =============================================================================

class _TypeVariantsSection extends StatelessWidget {
  const _TypeVariantsSection();

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
        const _SectionLabel(label: 'TYPE VARIANTS'),
        Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          padding: EdgeInsets.all(spacing.md),
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
              Text(
                'Single-emoji chip (with count, without count, selected), '
                'cluster chip, overflow chip, and Add Emoji chip.',
                style: textTheme.captionDefault.copyWith(color: colorScheme.textSecondary),
              ),
              Wrap(
                spacing: spacing.md,
                runSpacing: spacing.md,
                children: [
                  _TypeDemo(
                    label: 'With count',
                    child: StreamEmojiChip(
                      emoji: const Text('👍'),
                      count: 3,
                      onPressed: () {},
                    ),
                  ),
                  _TypeDemo(
                    label: 'Without count',
                    child: StreamEmojiChip(
                      emoji: const Text('👍'),
                      onPressed: () {},
                    ),
                  ),
                  _TypeDemo(
                    label: 'Selected',
                    child: StreamEmojiChip(
                      emoji: const Text('👍'),
                      count: 3,
                      isSelected: true,
                      onPressed: () {},
                    ),
                  ),
                  _TypeDemo(
                    label: 'Cluster',
                    child: StreamEmojiChip.cluster(
                      emojis: const [Text('👍'), Text('❤️'), Text('😂')],
                      count: 12,
                      onPressed: () {},
                    ),
                  ),
                  _TypeDemo(
                    label: 'Overflow',
                    child: StreamEmojiChip.overflow(
                      count: 7,
                      onPressed: () {},
                    ),
                  ),
                  _TypeDemo(
                    label: 'Add Emoji',
                    child: StreamEmojiChip.addEmoji(onPressed: () {}),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TypeDemo extends StatelessWidget {
  const _TypeDemo({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: spacing.xs,
      children: [
        child,
        Text(
          label,
          style: textTheme.metadataEmphasis.copyWith(
            color: colorScheme.accentPrimary,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Cluster Variants Section
// =============================================================================

class _ClusterVariantsSection extends StatelessWidget {
  const _ClusterVariantsSection();

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
        const _SectionLabel(label: 'CLUSTER VARIANTS'),
        Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          padding: EdgeInsets.all(spacing.md),
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
              Text(
                'Cluster chips render 1–4 emoji icons side-by-side, each '
                'individually sized. The total reaction count is shown after the icons.',
                style: textTheme.captionDefault.copyWith(color: colorScheme.textSecondary),
              ),
              Wrap(
                spacing: spacing.md,
                runSpacing: spacing.md,
                children: [
                  _TypeDemo(
                    label: '1 emoji',
                    child: StreamEmojiChip.cluster(
                      emojis: const [Text('👍')],
                      count: 5,
                      onPressed: () {},
                    ),
                  ),
                  _TypeDemo(
                    label: '2 emojis',
                    child: StreamEmojiChip.cluster(
                      emojis: const [Text('👍'), Text('❤️')],
                      count: 9,
                      onPressed: () {},
                    ),
                  ),
                  _TypeDemo(
                    label: '3 emojis',
                    child: StreamEmojiChip.cluster(
                      emojis: const [Text('👍'), Text('❤️'), Text('😂')],
                      count: 17,
                      onPressed: () {},
                    ),
                  ),
                  _TypeDemo(
                    label: '4 emojis',
                    child: StreamEmojiChip.cluster(
                      emojis: const [Text('👍'), Text('❤️'), Text('😂'), Text('🔥')],
                      count: 42,
                      onPressed: () {},
                    ),
                  ),
                  _TypeDemo(
                    label: 'no count',
                    child: StreamEmojiChip.cluster(
                      emojis: const [Text('👍'), Text('❤️'), Text('😂')],
                      onPressed: () {},
                    ),
                  ),
                  _TypeDemo(
                    label: 'selected',
                    child: StreamEmojiChip.cluster(
                      emojis: const [Text('👍'), Text('❤️'), Text('😂')],
                      count: 12,
                      isSelected: true,
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Overflow Variants Section
// =============================================================================

class _OverflowVariantsSection extends StatelessWidget {
  const _OverflowVariantsSection();

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
        const _SectionLabel(label: 'OVERFLOW VARIANTS'),
        Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          padding: EdgeInsets.all(spacing.md),
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
              Text(
                'Overflow chips display a +N label for collapsed items. '
                'The count uses the numeric text style rather than emoji sizing.',
                style: textTheme.captionDefault.copyWith(
                  color: colorScheme.textSecondary,
                ),
              ),
              Wrap(
                spacing: spacing.md,
                runSpacing: spacing.md,
                children: [
                  for (final count in [1, 3, 7, 15, 42, 99])
                    _TypeDemo(
                      label: '+$count',
                      child: StreamEmojiChip.overflow(
                        count: count,
                        onPressed: () {},
                      ),
                    ),
                  _TypeDemo(
                    label: 'disabled',
                    child: StreamEmojiChip.overflow(count: 5),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Count Values Section
// =============================================================================

class _CountValuesSection extends StatelessWidget {
  const _CountValuesSection();

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
        const _SectionLabel(label: 'COUNT VALUES'),
        Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          padding: EdgeInsets.all(spacing.md),
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
              Text(
                "Chips respect a minimum width so single-digit counts don't produce "
                'a narrow pill. Large counts expand the chip naturally.',
                style: textTheme.captionDefault.copyWith(color: colorScheme.textSecondary),
              ),
              Wrap(
                spacing: spacing.sm,
                runSpacing: spacing.sm,
                children: [
                  for (final count in [1, 9, 42, 99])
                    _TypeDemo(
                      label: 'count: $count',
                      child: StreamEmojiChip(
                        emoji: const Text('👍'),
                        count: count,
                        onPressed: () {},
                      ),
                    ),
                  _TypeDemo(
                    label: 'no count',
                    child: StreamEmojiChip(emoji: const Text('👍')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// State Matrix Section
// =============================================================================

class _StateMatrixSection extends StatelessWidget {
  const _StateMatrixSection();

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
        const _SectionLabel(label: 'STATE MATRIX'),
        Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          padding: EdgeInsets.all(spacing.md),
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
              Text(
                'Hover and press states are interactive — try them. '
                'Selected state applies only to single and cluster chips. '
                'Overflow chips do not support selection.',
                style: textTheme.captionDefault.copyWith(color: colorScheme.textSecondary),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 520),
                  child: Column(
                    spacing: spacing.md,
                    children: [
                      _StateRow(
                        stateLabel: '',
                        standardChip: Text(
                          'Single',
                          style: textTheme.metadataEmphasis.copyWith(
                            color: colorScheme.textTertiary,
                            fontSize: 10,
                          ),
                        ),
                        clusterChip: Text(
                          'Cluster',
                          style: textTheme.metadataEmphasis.copyWith(
                            color: colorScheme.textTertiary,
                            fontSize: 10,
                          ),
                        ),
                        overflowChip: Text(
                          'Overflow',
                          style: textTheme.metadataEmphasis.copyWith(
                            color: colorScheme.textTertiary,
                            fontSize: 10,
                          ),
                        ),
                        addEmojiChip: Text(
                          'Add Emoji',
                          style: textTheme.metadataEmphasis.copyWith(
                            color: colorScheme.textTertiary,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      _StateRow(
                        stateLabel: 'default',
                        standardChip: StreamEmojiChip(
                          emoji: const Text('👍'),
                          count: 3,
                          onPressed: () {},
                        ),
                        clusterChip: StreamEmojiChip.cluster(
                          emojis: const [Text('👍'), Text('❤️'), Text('😂')],
                          count: 12,
                          onPressed: () {},
                        ),
                        overflowChip: StreamEmojiChip.overflow(
                          count: 7,
                          onPressed: () {},
                        ),
                        addEmojiChip: StreamEmojiChip.addEmoji(onPressed: () {}),
                      ),
                      _StateRow(
                        stateLabel: 'selected',
                        standardChip: StreamEmojiChip(
                          emoji: const Text('👍'),
                          count: 3,
                          isSelected: true,
                          onPressed: () {},
                        ),
                        clusterChip: StreamEmojiChip.cluster(
                          emojis: const [Text('👍'), Text('❤️'), Text('😂')],
                          count: 12,
                          isSelected: true,
                          onPressed: () {},
                        ),
                        addEmojiChip: null,
                      ),
                      _StateRow(
                        stateLabel: 'disabled',
                        standardChip: StreamEmojiChip(
                          emoji: const Text('👍'),
                          count: 3,
                        ),
                        clusterChip: StreamEmojiChip.cluster(
                          emojis: const [Text('👍'), Text('❤️'), Text('😂')],
                          count: 12,
                        ),
                        overflowChip: StreamEmojiChip.overflow(count: 7),
                        addEmojiChip: StreamEmojiChip.addEmoji(),
                      ),
                      _StateRow(
                        stateLabel: 'selected\n+ disabled',
                        standardChip: StreamEmojiChip(
                          emoji: const Text('👍'),
                          count: 3,
                          isSelected: true,
                        ),
                        clusterChip: StreamEmojiChip.cluster(
                          emojis: const [Text('👍'), Text('❤️'), Text('😂')],
                          count: 12,
                          isSelected: true,
                        ),
                        addEmojiChip: null,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StateRow extends StatelessWidget {
  const _StateRow({
    required this.stateLabel,
    required this.standardChip,
    required this.clusterChip,
    this.overflowChip,
    required this.addEmojiChip,
  });

  final String stateLabel;
  final Widget standardChip;
  final Widget? clusterChip;
  final Widget? overflowChip;
  final Widget? addEmojiChip;

  static const _cellWidth = 108.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;

    Widget naText() => Text(
      'n/a',
      style: textTheme.metadataDefault.copyWith(
        color: colorScheme.textDisabled,
        fontSize: 10,
      ),
    );

    Widget cell(Widget? child) => SizedBox(
      width: _cellWidth,
      child: Center(child: child ?? naText()),
    );

    return Row(
      children: [
        SizedBox(
          width: 88,
          child: Text(
            stateLabel,
            style: textTheme.metadataEmphasis.copyWith(
              color: colorScheme.textSecondary,
              fontSize: 10,
            ),
          ),
        ),
        cell(standardChip),
        cell(clusterChip),
        cell(overflowChip),
        cell(addEmojiChip),
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
            title: 'Message Reactions',
            description:
                'Interactive reaction bar below a chat message — tap to toggle, '
                'long-press would open a skin-tone picker.',
            child: _MessageReactionsExample(),
          ),
          _ExampleCard(
            title: 'Clustered Reactions',
            description:
                'All reactions grouped into a single cluster chip — tap the chip '
                'to see the total count; commonly used in compact message threads.',
            child: _ClusteredReactionsExample(),
          ),
          _ExampleCard(
            title: 'Busy Reaction Bar',
            description:
                'Many reactions with large counts — shows wrap behaviour and '
                'minimum width enforcement.',
            child: _BusyReactionsExample(),
          ),
        ],
    );
  }
}

class _MessageReactionsExample extends StatefulWidget {
  const _MessageReactionsExample();

  @override
  State<_MessageReactionsExample> createState() => _MessageReactionsExampleState();
}

class _MessageReactionsExampleState extends State<_MessageReactionsExample> {
  final _counts = <String, int>{'👍': 3, '❤️': 1, '😂': 5};
  final _mine = <String>{'👍'};

  void _toggle(String emoji) {
    setState(() {
      if (_mine.contains(emoji)) {
        _mine.remove(emoji);
        _counts[emoji] = (_counts[emoji] ?? 1) - 1;
        if (_counts[emoji]! <= 0) _counts.remove(emoji);
      } else {
        _mine.add(emoji);
        _counts[emoji] = (_counts[emoji] ?? 0) + 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: spacing.xs,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 280),
          padding: EdgeInsets.symmetric(horizontal: spacing.md, vertical: spacing.sm),
          decoration: BoxDecoration(
            color: colorScheme.backgroundSurface,
            borderRadius: BorderRadius.all(radius.lg),
            border: Border.all(color: colorScheme.borderSubtle),
          ),
          child: Text(
            'Looks great! 🎉 Really happy with how this turned out.',
            style: textTheme.bodyDefault.copyWith(color: colorScheme.textPrimary),
          ),
        ),
        Wrap(
          spacing: spacing.xs,
          runSpacing: spacing.xs,
          children: [
            for (final entry in _counts.entries)
              StreamEmojiChip(
                emoji: Text(entry.key),
                count: entry.value,
                isSelected: _mine.contains(entry.key),
                onPressed: () => _toggle(entry.key),
                onLongPress: () {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text('Long pressed — open skin-tone picker'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                },
              ),
            StreamEmojiChip.addEmoji(
              onPressed: () {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text('Open reaction picker'),
                      duration: Duration(seconds: 1),
                    ),
                  );
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _ClusteredReactionsExample extends StatefulWidget {
  const _ClusteredReactionsExample();

  @override
  State<_ClusteredReactionsExample> createState() => _ClusteredReactionsExampleState();
}

class _ClusteredReactionsExampleState extends State<_ClusteredReactionsExample> {
  static const _allReactions = [
    ('👍', 4),
    ('❤️', 3),
    ('😂', 2),
    ('🔥', 1),
  ];

  var _isSelected = false;

  int get _totalCount => _allReactions.fold(0, (sum, r) => sum + r.$2);

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: spacing.xs,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 280),
          padding: EdgeInsets.symmetric(horizontal: spacing.md, vertical: spacing.sm),
          decoration: BoxDecoration(
            color: colorScheme.backgroundSurface,
            borderRadius: BorderRadius.all(radius.lg),
            border: Border.all(color: colorScheme.borderSubtle),
          ),
          child: Text(
            'Looks great! 🎉 Really happy with how this turned out.',
            style: textTheme.bodyDefault.copyWith(color: colorScheme.textPrimary),
          ),
        ),
        StreamEmojiChip.cluster(
          emojis: [for (final (emoji, _) in _allReactions) Text(emoji)],
          count: _totalCount,
          isSelected: _isSelected,
          onPressed: () {
            setState(() => _isSelected = !_isSelected);
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text('Cluster tapped — show reaction details'),
                  duration: Duration(seconds: 1),
                ),
              );
          },
        ),
      ],
    );
  }
}

class _BusyReactionsExample extends StatelessWidget {
  const _BusyReactionsExample();

  static const _reactions = [
    ('👍', 42),
    ('❤️', 99),
    ('😂', 17),
    ('🔥', 8),
    ('😮', 3),
    ('👏', 26),
    ('🎉', 1),
    ('😢', 5),
  ];

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Wrap(
      spacing: spacing.xs,
      runSpacing: spacing.xs,
      children: [
        for (final (emoji, count) in _reactions)
          StreamEmojiChip(
            emoji: Text(emoji),
            count: count,
            onPressed: () {},
          ),
        StreamEmojiChip.addEmoji(onPressed: () {}),
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
            padding: EdgeInsets.symmetric(horizontal: spacing.md, vertical: spacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.captionEmphasis.copyWith(color: colorScheme.textPrimary),
                ),
                Text(
                  description,
                  style: textTheme.metadataDefault.copyWith(color: colorScheme.textTertiary),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colorScheme.borderSubtle),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(spacing.md),
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
      padding: EdgeInsets.symmetric(horizontal: spacing.sm, vertical: spacing.xs),
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

enum _ChipType {
  single,
  cluster,
  overflow,
  addEmoji;

  String get label => switch (this) {
    _ChipType.single => 'Single',
    _ChipType.cluster => 'Cluster',
    _ChipType.overflow => 'Overflow',
    _ChipType.addEmoji => 'Add Emoji',
  };
}

Emoji _byName(String name) => UnicodeEmojis.allEmojis.firstWhere((e) => e.name == name);

final _sampleEmojis = [
  _byName('thumbs up sign'),
  _byName('heavy black heart'),
  _byName('face with tears of joy'),
  _byName('fire'),
  _byName('clapping hands sign'),
  _byName('party popper'),
  _byName('white heavy check mark'),
  _byName('rocket'),
];
