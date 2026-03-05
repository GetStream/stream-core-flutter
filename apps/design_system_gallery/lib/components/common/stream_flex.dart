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
          _PlaygroundChild(index: i, direction: direction),
      ],
    ),
  );
}

class _PlaygroundChild extends StatelessWidget {
  const _PlaygroundChild({required this.index, required this.direction});

  final int index;
  final Axis direction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;

    final palette = _childPalette[index % _childPalette.length];
    final size = 40.0 + (index % 3) * 12.0;

    return Container(
      width: direction == Axis.horizontal ? size : null,
      height: direction == Axis.vertical ? size : null,
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
          _NegativeSpacingSection(),
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
              for (final (label, value) in _spacingValues)
                _SpacingDemo(label: label, spacing: value),
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
      mainAxisSize: MainAxisSize.min,
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
      mainAxisSize: MainAxisSize.min,
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
          title: 'Notification Badges',
          description:
              'Overlapping badges that fan out, useful for showing '
              'multiple notification types.',
          child: _NotificationBadgesDemo(),
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
              mainAxisSize: MainAxisSize.min,
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
      mainAxisSize: MainAxisSize.min,
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
