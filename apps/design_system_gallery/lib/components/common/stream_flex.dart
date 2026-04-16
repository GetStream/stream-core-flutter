import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamFlex,
  path: '[Components]/Common',
)
Widget buildStreamFlexPlayground(BuildContext context) {
  final direction = context.knobs.object.dropdown(
    label: 'Direction',
    options: Axis.values,
    labelBuilder: (value) => value.name,
    initialOption: Axis.horizontal,
    description: 'The main axis direction.',
  );

  final spacing = context.knobs.double.slider(
    label: 'Spacing',
    initialValue: -8,
    min: -24,
    max: 32,
    description: 'Space between children. Negative values cause overlap.',
  );

  final mainAxisAlignment = context.knobs.object.dropdown(
    label: 'Main Axis Alignment',
    options: MainAxisAlignment.values,
    labelBuilder: (value) => value.name,
    initialOption: MainAxisAlignment.start,
    description: 'How children are placed along the main axis.',
  );

  final crossAxisAlignment = context.knobs.object.dropdown(
    label: 'Cross Axis Alignment',
    options: [
      CrossAxisAlignment.start,
      CrossAxisAlignment.center,
      CrossAxisAlignment.end,
      CrossAxisAlignment.stretch,
    ],
    labelBuilder: (value) => value.name,
    initialOption: CrossAxisAlignment.center,
    description: 'How children are placed along the cross axis.',
  );

  final mainAxisSize = context.knobs.object.dropdown(
    label: 'Main Axis Size',
    options: MainAxisSize.values,
    labelBuilder: (value) => value.name,
    initialOption: MainAxisSize.min,
    description: 'Whether to maximize or minimize free space.',
  );

  final clipBehavior = context.knobs.object.dropdown(
    label: 'Clip Behavior',
    options: Clip.values,
    labelBuilder: (value) => value.name,
    initialOption: Clip.none,
    description: 'How to clip overflowing children.',
  );

  final childCount = context.knobs.int.slider(
    label: 'Child Count',
    initialValue: 5,
    min: 1,
    max: 8,
    description: 'Number of children.',
  );

  final variedSizes = context.knobs.boolean(
    label: 'Varied sizes',
    initialValue: true,
    description:
        'Give children different cross-axis sizes to '
        'demonstrate alignment behavior.',
  );

  final collapseOdd = context.knobs.boolean(
    label: 'Collapse odd children',
    description:
        'Odd-indexed children return null via NullableBuilder — '
        'StreamFlex skips their spacing slots entirely.',
  );

  return Center(
    child: StreamFlex(
      direction: direction,
      spacing: spacing,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      clipBehavior: clipBehavior,
      children: [
        for (var i = 0; i < childCount; i++)
          if (collapseOdd && i.isOdd)
            NullableBuilder(builder: (_) => null)
          else
            _PlaygroundChild(
              index: i,
              direction: direction,
              variedSizes: variedSizes,
            ),
      ],
    ),
  );
}

class _PlaygroundChild extends StatelessWidget {
  const _PlaygroundChild({
    required this.index,
    required this.direction,
    this.variedSizes = false,
  });

  final int index;
  final Axis direction;
  final bool variedSizes;

  static const _sizes = [40.0, 56.0, 36.0, 64.0, 44.0, 52.0, 32.0, 48.0];

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;

    final palette = _childPalette[index % _childPalette.length];
    final mainSize = variedSizes ? _sizes[index % _sizes.length] : 40.0;
    final crossSize = variedSizes ? _sizes[(index + 2) % _sizes.length] : 40.0;

    return Container(
      width: direction == Axis.horizontal ? mainSize : crossSize,
      height: direction == Axis.vertical ? mainSize : crossSize,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: palette.bg,
        borderRadius: BorderRadius.all(radius.md),
        border: Border.all(color: colorScheme.backgroundSurface, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        '${index + 1}',
        style: textTheme.captionEmphasis.copyWith(color: palette.fg),
      ),
    );
  }
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamFlex,
  path: '[Components]/Common',
)
Widget buildStreamFlexShowcase(BuildContext context) {
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
          _SpacingValuesSection(),
          _CrossAxisAlignmentSection(),
          _CollapsedChildrenSection(),
          _NegativeSpacingSection(),
          _CombinedFeaturesSection(),
          _RealWorldSection(),
        ],
      ),
    ),
  );
}

// =============================================================================
// Spacing Values Section
// =============================================================================

class _SpacingValuesSection extends StatelessWidget {
  const _SpacingValuesSection();

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
        const _SectionLabel(label: 'SPACING VALUES'),
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
                'Positive spacing adds gaps, zero makes children flush, '
                'and negative spacing causes overlap.',
                style: textTheme.captionDefault.copyWith(
                  color: colorScheme.textSecondary,
                ),
              ),
              for (final (label, value) in _spacingValues) _SpacingDemo(label: label, spacing: value),
            ],
          ),
        ),
      ],
    );
  }
}

class _SpacingDemo extends StatelessWidget {
  const _SpacingDemo({required this.label, required this.spacing});

  final String label;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final themeSpacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: themeSpacing.xs,
      children: [
        Text(
          label,
          style: textTheme.metadataEmphasis.copyWith(
            color: colorScheme.accentPrimary,
            fontFamily: 'monospace',
          ),
        ),
        StreamRow(
          spacing: spacing,
          children: [
            for (var i = 0; i < 5; i++) _DemoChip(index: i),
          ],
        ),
      ],
    );
  }
}

// =============================================================================
// Cross-Axis Alignment Section
// =============================================================================

class _CrossAxisAlignmentSection extends StatelessWidget {
  const _CrossAxisAlignmentSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: const [
        _SectionLabel(label: 'CROSS-AXIS ALIGNMENT'),
        _ExampleCard(
          title: 'Alignment with Varied Sizes',
          description:
              'Children with different heights aligned to start, center, '
              'end, and stretch along the cross axis.',
          child: _CrossAxisDemo(),
        ),
      ],
    );
  }
}

class _CrossAxisDemo extends StatelessWidget {
  const _CrossAxisDemo();

  static const _alignments = [
    ('start', CrossAxisAlignment.start),
    ('center', CrossAxisAlignment.center),
    ('end', CrossAxisAlignment.end),
    ('stretch', CrossAxisAlignment.stretch),
  ];

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.lg,
      children: [
        for (final (label, alignment) in _alignments)
          _VariantDemo(
            label: 'crossAxisAlignment: $label',
            child: _CrossAxisRow(alignment: alignment),
          ),
      ],
    );
  }
}

class _CrossAxisRow extends StatelessWidget {
  const _CrossAxisRow({required this.alignment});

  final CrossAxisAlignment alignment;

  static const _heights = [28.0, 48.0, 36.0, 56.0, 40.0];

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;

    return Container(
      height: alignment == CrossAxisAlignment.stretch ? 56 : null,
      decoration: BoxDecoration(
        border: Border.all(
          color: colorScheme.borderSubtle,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
        borderRadius: BorderRadius.all(radius.md),
      ),
      child: StreamRow(
        spacing: 6,
        crossAxisAlignment: alignment,
        children: [
          for (var i = 0; i < 5; i++)
            Container(
              width: 40,
              height: alignment == CrossAxisAlignment.stretch ? null : _heights[i],
              decoration: BoxDecoration(
                color: _childPalette[i].bg,
                borderRadius: BorderRadius.all(radius.sm),
              ),
              alignment: Alignment.center,
              child: Text(
                '${i + 1}',
                style: textTheme.captionEmphasis.copyWith(
                  color: _childPalette[i].fg,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// =============================================================================
// Collapsed Children Section
// =============================================================================

class _CollapsedChildrenSection extends StatelessWidget {
  const _CollapsedChildrenSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: const [
        _SectionLabel(label: 'COLLAPSED CHILDREN'),
        _ExampleCard(
          title: 'NullableBuilder — Spacing Skipped',
          description:
              'Children that return null via NullableBuilder collapse to '
              'zero size and their spacing slot is removed entirely.',
          child: _CollapsedDemo(),
        ),
        _ExampleCard(
          title: 'StreamColumn vs Column',
          description:
              'In a regular Column, a SizedBox.shrink() still occupies a '
              'spacing slot. In StreamColumn, a collapsed child does not.',
          child: _ComparisonDemo(),
        ),
      ],
    );
  }
}

class _CollapsedDemo extends StatefulWidget {
  const _CollapsedDemo();

  @override
  State<_CollapsedDemo> createState() => _CollapsedDemoState();
}

class _CollapsedDemoState extends State<_CollapsedDemo> {
  final _hidden = <int>{};

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;
    final radius = context.streamRadius;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: [
        Wrap(
          spacing: spacing.xs,
          children: [
            for (var i = 0; i < 5; i++)
              FilterChip(
                label: Text(
                  'Child ${i + 1}',
                  style: textTheme.metadataDefault,
                ),
                selected: !_hidden.contains(i),
                onSelected: (selected) {
                  setState(() {
                    selected ? _hidden.remove(i) : _hidden.add(i);
                  });
                },
              ),
          ],
        ),
        Container(
          padding: EdgeInsets.all(spacing.sm),
          decoration: BoxDecoration(
            color: colorScheme.backgroundSurface,
            borderRadius: BorderRadius.all(radius.md),
          ),
          child: StreamRow(
            spacing: 8,
            children: [
              for (var i = 0; i < 5; i++)
                NullableBuilder(
                  builder: (_) => _hidden.contains(i) ? null : _DemoChip(index: i),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ComparisonDemo extends StatelessWidget {
  const _ComparisonDemo();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;
    final radius = context.streamRadius;

    Widget label(String text) => Text(
      text,
      style: textTheme.metadataEmphasis.copyWith(
        color: colorScheme.accentPrimary,
        fontFamily: 'monospace',
      ),
    );

    Widget chip(int index) => _DemoChip(index: index);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.lg,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: spacing.xs,
            children: [
              label('StreamRow (no extra gap)'),
              Container(
                padding: EdgeInsets.all(spacing.sm),
                decoration: BoxDecoration(
                  color: colorScheme.backgroundSurface,
                  borderRadius: BorderRadius.all(radius.md),
                ),
                child: StreamRow(
                  spacing: 8,
                  children: [
                    chip(0),
                    NullableBuilder(builder: (_) => null),
                    chip(2),
                    NullableBuilder(builder: (_) => null),
                    chip(4),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: spacing.xs,
            children: [
              label('Row (extra gaps remain)'),
              Container(
                padding: EdgeInsets.all(spacing.sm),
                decoration: BoxDecoration(
                  color: colorScheme.backgroundSurface,
                  borderRadius: BorderRadius.all(radius.md),
                ),
                child: Row(
                  spacing: 8,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    chip(0),
                    const SizedBox.shrink(),
                    chip(2),
                    const SizedBox.shrink(),
                    chip(4),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Negative Spacing Section
// =============================================================================

class _NegativeSpacingSection extends StatelessWidget {
  const _NegativeSpacingSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: const [
        _SectionLabel(label: 'NEGATIVE SPACING'),
        _ExampleCard(
          title: 'Z-Order (Paint Order)',
          description:
              'Later children paint on top of earlier ones. '
              'Child 1 is behind, child 5 is in front.',
          child: _ZOrderDemo(),
        ),
        _ExampleCard(
          title: 'Vertical Overlap',
          description: 'Negative spacing works on the vertical axis too.',
          child: _VerticalOverlapDemo(),
        ),
      ],
    );
  }
}

class _ZOrderDemo extends StatelessWidget {
  const _ZOrderDemo();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;

    return StreamRow(
      spacing: -16,
      children: [
        for (var i = 0; i < 5; i++)
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _childPalette[i].bg,
              borderRadius: BorderRadius.all(radius.lg),
              border: Border.all(
                color: colorScheme.backgroundSurface,
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '${i + 1}',
              style: textTheme.captionEmphasis.copyWith(
                color: _childPalette[i].fg,
              ),
            ),
          ),
      ],
    );
  }
}

class _VerticalOverlapDemo extends StatelessWidget {
  const _VerticalOverlapDemo();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;
    final boxShadow = context.streamBoxShadow;

    return StreamColumn(
      spacing: -12,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < 4; i++)
          Container(
            width: 200,
            padding: EdgeInsets.symmetric(
              horizontal: spacing.md,
              vertical: spacing.sm,
            ),
            decoration: BoxDecoration(
              color: _childPalette[i].bg,
              borderRadius: BorderRadius.all(radius.lg),
              border: Border.all(
                color: colorScheme.backgroundSurface,
                width: 2,
              ),
              boxShadow: boxShadow.elevation1,
            ),
            child: Text(
              'Card ${i + 1}',
              style: textTheme.captionEmphasis.copyWith(
                color: _childPalette[i].fg,
              ),
            ),
          ),
      ],
    );
  }
}

// =============================================================================
// Combined Features Section
// =============================================================================

class _CombinedFeaturesSection extends StatelessWidget {
  const _CombinedFeaturesSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: const [
        _SectionLabel(label: 'COMBINED FEATURES'),
        _ExampleCard(
          title: 'Negative Spacing + Collapsed Children',
          description:
              'Overlapping avatars where members can be toggled off. '
              'Hidden avatars collapse without leaving a gap or '
              'disrupting the overlap pattern.',
          child: _CombinedDemo(),
        ),
      ],
    );
  }
}

class _CombinedDemo extends StatefulWidget {
  const _CombinedDemo();

  @override
  State<_CombinedDemo> createState() => _CombinedDemoState();
}

class _CombinedDemoState extends State<_CombinedDemo> {
  static const _names = ['Alice', 'Bob', 'Carol', 'Dave', 'Eve', 'Frank'];

  final _visible = List.filled(_names.length, true);

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;
    final radius = context.streamRadius;

    final visibleCount = _visible.where((v) => v).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: [
        Wrap(
          spacing: spacing.xs,
          runSpacing: spacing.xs,
          children: [
            for (var i = 0; i < _names.length; i++)
              FilterChip(
                label: Text(_names[i], style: textTheme.metadataDefault),
                selected: _visible[i],
                onSelected: (selected) {
                  setState(() => _visible[i] = selected);
                },
              ),
          ],
        ),
        Container(
          padding: EdgeInsets.all(spacing.md),
          decoration: BoxDecoration(
            color: colorScheme.backgroundSurface,
            borderRadius: BorderRadius.all(radius.md),
          ),
          child: Row(
            spacing: spacing.sm,
            children: [
              StreamRow(
                spacing: -10,
                children: [
                  for (var i = 0; i < _names.length; i++)
                    NullableBuilder(
                      builder: (_) {
                        if (!_visible[i]) return null;
                        return DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.backgroundSurface,
                              width: 2,
                            ),
                          ),
                          child: StreamAvatar(
                            size: StreamAvatarSize.sm,
                            backgroundColor: _childPalette[i % _childPalette.length].bg,
                            foregroundColor: _childPalette[i % _childPalette.length].fg,
                            placeholder: (_) => Text(
                              _names[i][0],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
              Text(
                '$visibleCount member${visibleCount == 1 ? '' : 's'} online',
                style: textTheme.captionDefault.copyWith(
                  color: colorScheme.textSecondary,
                ),
              ),
            ],
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
          title: 'Avatar Stack',
          description:
              'Overlapping circular avatars — a common pattern for '
              'showing group participants.',
          child: _AvatarStackDemo(),
        ),
        _ExampleCard(
          title: 'Message Reactions',
          description:
              'Overlapping emoji reaction pills, similar to how chat '
              'apps display grouped reactions.',
          child: _ReactionBarDemo(),
        ),
        _ExampleCard(
          title: 'Read Receipts',
          description:
              'Tiny overlapping avatars showing who has read a message. '
              'Uses both negative spacing and collapsed children — '
              'offline users are hidden with NullableBuilder.',
          child: _ReadReceiptsDemo(),
        ),
        _ExampleCard(
          title: 'Notification Badges',
          description:
              'Overlapping badges that fan out, useful for showing '
              'multiple notification types.',
          child: _NotificationBadgesDemo(),
        ),
        _ExampleCard(
          title: 'Progress Steps',
          description:
              'Connected progress steps using negative spacing to '
              'overlap step circles onto the connector line.',
          child: _ProgressStepsDemo(),
        ),
      ],
    );
  }
}

class _AvatarStackDemo extends StatelessWidget {
  const _AvatarStackDemo();

  static const _initials = ['AL', 'BK', 'CM', 'DP', 'EW'];

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.lg,
      children: [
        for (final overlap in [-8.0, -12.0, -16.0])
          _VariantDemo(
            label: 'spacing: ${overlap.toInt()}',
            child: StreamRow(
              spacing: overlap,
              children: [
                for (var i = 0; i < _initials.length; i++)
                  StreamAvatar(
                    size: StreamAvatarSize.md,
                    backgroundColor: _childPalette[i].bg,
                    foregroundColor: _childPalette[i].fg,
                    placeholder: (_) => Text(_initials[i]),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _NotificationBadgesDemo extends StatelessWidget {
  const _NotificationBadgesDemo();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;

    final badges = [
      (
        StreamColors.red.shade400.withValues(alpha: 0.85),
        StreamColors.red.shade900,
        '3',
      ),
      (
        StreamColors.yellow.shade400.withValues(alpha: 0.85),
        StreamColors.yellow.shade900,
        '!',
      ),
      (
        StreamColors.blue.shade400.withValues(alpha: 0.85),
        StreamColors.blue.shade900,
        '7',
      ),
    ];

    return StreamRow(
      spacing: -6,
      children: [
        for (final (bg, fg, label) in badges)
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.all(radius.max),
              border: Border.all(
                color: colorScheme.backgroundSurface,
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: textTheme.metadataEmphasis.copyWith(
                color: fg,
                fontSize: 11,
              ),
            ),
          ),
      ],
    );
  }
}

class _ReactionBarDemo extends StatelessWidget {
  const _ReactionBarDemo();

  static const _reactions = [
    ('👍', 4),
    ('❤️', 2),
    ('😂', 7),
    ('🎉', 1),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;

    return StreamRow(
      spacing: -4,
      children: [
        for (final (emoji, count) in _reactions)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.backgroundSurface,
              borderRadius: BorderRadius.all(radius.max),
              border: Border.all(color: colorScheme.borderSubtle),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 14)),
                Text(
                  '$count',
                  style: textTheme.metadataEmphasis.copyWith(
                    color: colorScheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ReadReceiptsDemo extends StatelessWidget {
  const _ReadReceiptsDemo();

  static const _readers = [
    ('A', true),
    ('B', true),
    ('C', false),
    ('D', true),
    ('E', false),
    ('F', true),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    final onlineCount = _readers.where((r) => r.$2).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.sm,
      children: [
        Row(
          spacing: spacing.sm,
          children: [
            Text(
              'Seen by',
              style: textTheme.captionDefault.copyWith(
                color: colorScheme.textSecondary,
              ),
            ),
            StreamRow(
              spacing: -6,
              children: [
                for (final (initial, online) in _readers)
                  NullableBuilder(
                    builder: (_) {
                      if (!online) return null;
                      final idx = _readers.indexWhere((r) => r.$1 == initial);
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.backgroundSurfaceSubtle,
                            width: 1.5,
                          ),
                        ),
                        child: StreamAvatar(
                          size: StreamAvatarSize.xs,
                          backgroundColor: _childPalette[idx % _childPalette.length].bg,
                          foregroundColor: _childPalette[idx % _childPalette.length].fg,
                          placeholder: (_) => Text(
                            initial,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
            Text(
              '$onlineCount',
              style: textTheme.metadataEmphasis.copyWith(
                color: colorScheme.textTertiary,
              ),
            ),
          ],
        ),
        Text(
          'C and E are offline — their avatars collapse with no gap.',
          style: textTheme.metadataDefault.copyWith(
            color: colorScheme.textTertiary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

class _ProgressStepsDemo extends StatelessWidget {
  const _ProgressStepsDemo();

  static const _steps = ['Order', 'Payment', 'Shipping', 'Delivered'];

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    const completedCount = 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.sm,
      children: [
        StreamRow(
          spacing: -1,
          children: [
            for (var i = 0; i < _steps.length; i++) ...[
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: i <= completedCount ? colorScheme.accentPrimary : colorScheme.backgroundSurfaceStrong,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.backgroundSurfaceSubtle,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: i < completedCount
                    ? Icon(
                        Icons.check,
                        size: 14,
                        color: colorScheme.textOnAccent,
                      )
                    : Text(
                        '${i + 1}',
                        style: textTheme.metadataEmphasis.copyWith(
                          color: i == completedCount ? colorScheme.textOnAccent : colorScheme.textTertiary,
                          fontSize: 11,
                        ),
                      ),
              ),
              if (i < _steps.length - 1)
                Container(
                  width: 40,
                  height: 2,
                  color: i < completedCount ? colorScheme.accentPrimary : colorScheme.borderSubtle,
                ),
            ],
          ],
        ),
        StreamRow(
          spacing: -1,
          children: [
            for (var i = 0; i < _steps.length; i++) ...[
              SizedBox(
                width: 28,
                child: Text(
                  _steps[i],
                  textAlign: TextAlign.center,
                  style: textTheme.metadataDefault.copyWith(
                    color: i <= completedCount ? colorScheme.accentPrimary : colorScheme.textTertiary,
                    fontSize: 9,
                  ),
                ),
              ),
              if (i < _steps.length - 1) const SizedBox(width: 40),
            ],
          ],
        ),
      ],
    );
  }
}

// =============================================================================
// Shared Widgets
// =============================================================================

class _DemoChip extends StatelessWidget {
  const _DemoChip({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;

    final palette = _childPalette[index % _childPalette.length];

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: palette.bg,
        borderRadius: BorderRadius.all(radius.md),
        border: Border.all(color: colorScheme.backgroundSurface, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        '${index + 1}',
        style: textTheme.captionEmphasis.copyWith(color: palette.fg),
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
        Text(
          label,
          style: textTheme.metadataEmphasis.copyWith(
            color: colorScheme.accentPrimary,
            fontFamily: 'monospace',
          ),
        ),
        child,
      ],
    );
  }
}

// =============================================================================
// Helpers
// =============================================================================

const _spacingValues = [
  ('spacing: 12', 12.0),
  ('spacing: 0', 0.0),
  ('spacing: -8', -8.0),
  ('spacing: -16', -16.0),
];

final _childPalette = [
  (
    bg: StreamColors.blue.shade400.withValues(alpha: 0.8),
    fg: StreamColors.blue.shade900,
  ),
  (
    bg: StreamColors.cyan.shade400.withValues(alpha: 0.8),
    fg: StreamColors.cyan.shade900,
  ),
  (
    bg: StreamColors.green.shade400.withValues(alpha: 0.8),
    fg: StreamColors.green.shade900,
  ),
  (
    bg: StreamColors.purple.shade400.withValues(alpha: 0.8),
    fg: StreamColors.purple.shade900,
  ),
  (
    bg: StreamColors.yellow.shade400.withValues(alpha: 0.8),
    fg: StreamColors.yellow.shade900,
  ),
];
