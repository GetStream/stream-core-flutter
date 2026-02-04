import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamBadgeCount,
  path: '[Components]/Badge',
)
Widget buildStreamBadgeCountPlayground(BuildContext context) {
  final label = context.knobs.string(
    label: 'Label',
    initialValue: '5',
    description: 'The text to display in the badge.',
  );

  final size = context.knobs.object.dropdown<StreamBadgeCountSize>(
    label: 'Size',
    options: StreamBadgeCountSize.values,
    initialOption: StreamBadgeCountSize.xs,
    labelBuilder: (option) => '${option.name.toUpperCase()} (${option.value.toInt()}px)',
    description: 'The size of the badge.',
  );

  return Center(
    child: StreamBadgeCount(
      label: label,
      size: size,
    ),
  );
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamBadgeCount,
  path: '[Components]/Badge',
)
Widget buildStreamBadgeCountShowcase(BuildContext context) {
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
          // Size variants
          const _SizeVariantsSection(),
          SizedBox(height: spacing.xl),

          // Count variants
          const _CountVariantsSection(),
          SizedBox(height: spacing.xl),

          // Usage patterns
          const _UsagePatternsSection(),
        ],
      ),
    ),
  );
}

// =============================================================================
// Size Variants Section
// =============================================================================

class _SizeVariantsSection extends StatelessWidget {
  const _SizeVariantsSection();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final boxShadow = context.streamBoxShadow;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: 'SIZE VARIANTS'),
        SizedBox(height: spacing.md),
        Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          padding: EdgeInsets.all(spacing.md),
          decoration: BoxDecoration(
            color: colorScheme.backgroundSurface,
            borderRadius: BorderRadius.all(radius.lg),
            boxShadow: boxShadow.elevation1,
          ),
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.all(radius.lg),
            border: Border.all(color: colorScheme.borderSurfaceSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Badge sizes scale with count display',
                style: textTheme.captionDefault.copyWith(
                  color: colorScheme.textSecondary,
                ),
              ),
              SizedBox(height: spacing.md),
              Row(
                children: [
                  for (final size in StreamBadgeCountSize.values) ...[
                    _SizeDemo(size: size),
                    if (size != StreamBadgeCountSize.values.last) SizedBox(width: spacing.xl),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SizeDemo extends StatelessWidget {
  const _SizeDemo({required this.size});

  final StreamBadgeCountSize size;

  String _getPixelSize(StreamBadgeCountSize size) {
    return switch (size) {
      StreamBadgeCountSize.xs => '20px',
      StreamBadgeCountSize.sm => '24px',
      StreamBadgeCountSize.md => '32px',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Column(
      children: [
        SizedBox(
          width: 48,
          height: 32,
          child: Center(
            child: StreamBadgeCount(
              label: '5',
              size: size,
            ),
          ),
        ),
        SizedBox(height: spacing.sm),
        Text(
          size.name.toUpperCase(),
          style: textTheme.metadataEmphasis.copyWith(
            color: colorScheme.accentPrimary,
            fontFamily: 'monospace',
          ),
        ),
        Text(
          _getPixelSize(size),
          style: textTheme.metadataDefault.copyWith(
            color: colorScheme.textTertiary,
            fontFamily: 'monospace',
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Count Variants Section
// =============================================================================

class _CountVariantsSection extends StatelessWidget {
  const _CountVariantsSection();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final boxShadow = context.streamBoxShadow;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: 'COUNT VARIANTS'),
        SizedBox(height: spacing.md),
        Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          padding: EdgeInsets.all(spacing.md),
          decoration: BoxDecoration(
            color: colorScheme.backgroundSurface,
            borderRadius: BorderRadius.all(radius.lg),
            boxShadow: boxShadow.elevation1,
          ),
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.all(radius.lg),
            border: Border.all(color: colorScheme.borderSurfaceSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Badge adapts width based on count',
                style: textTheme.captionDefault.copyWith(
                  color: colorScheme.textSecondary,
                ),
              ),
              SizedBox(height: spacing.md),
              Wrap(
                spacing: spacing.md,
                runSpacing: spacing.md,
                children: const [
                  _CountDemo(count: 1),
                  _CountDemo(count: 9),
                  _CountDemo(count: 25),
                  _CountDemo(count: 99),
                  _CountDemo(count: 100),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CountDemo extends StatelessWidget {
  const _CountDemo({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    final displayText = count > 99 ? '99+' : '$count';

    return Column(
      children: [
        StreamBadgeCount(label: displayText),
        SizedBox(height: spacing.xs),
        Text(
          displayText,
          style: textTheme.metadataDefault.copyWith(
            color: colorScheme.textTertiary,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Usage Patterns Section
// =============================================================================

class _UsagePatternsSection extends StatelessWidget {
  const _UsagePatternsSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: 'USAGE PATTERNS'),
        SizedBox(height: spacing.md),

        // Avatar with badge
        const _ExampleCard(
          title: 'Avatar with Badge',
          description: 'Badge positioned on avatar corner',
          child: _AvatarWithBadgeGroup(),
        ),
        SizedBox(height: spacing.sm),

        // List item with badge
        const _ExampleCard(
          title: 'List Item',
          description: 'Badge in channel list item',
          child: _ListItemExample(),
        ),
      ],
    );
  }
}

class _AvatarWithBadgeGroup extends StatelessWidget {
  const _AvatarWithBadgeGroup();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Row(
      children: [
        const _AvatarWithBadge(name: 'John', count: 3),
        SizedBox(width: spacing.lg),
        const _AvatarWithBadge(name: 'Sarah', count: 12),
        SizedBox(width: spacing.lg),
        const _AvatarWithBadge(name: 'Alex', count: 99),
        SizedBox(width: spacing.lg),
        const _AvatarWithBadge(name: 'Team', count: 150),
      ],
    );
  }
}

class _AvatarWithBadge extends StatelessWidget {
  const _AvatarWithBadge({
    required this.name,
    required this.count,
  });

  final String name;
  final int count;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.streamTextTheme;
    final colorScheme = context.streamColorScheme;
    final spacing = context.streamSpacing;

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            StreamAvatar(
              size: StreamAvatarSize.lg,
              placeholder: (context) => Text(name[0]),
            ),
            Positioned(
              right: -4,
              top: -4,
              child: StreamBadgeCount(
                label: count > 99 ? '99+' : '$count',
                size: StreamBadgeCountSize.xs,
              ),
            ),
          ],
        ),
        SizedBox(height: spacing.sm),
        Text(
          name,
          style: textTheme.captionDefault.copyWith(
            color: colorScheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ListItemExample extends StatelessWidget {
  const _ListItemExample();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Column(
      children: [
        const _ChannelListItem(
          name: 'Design Team',
          message: 'New mockups ready for review',
          count: 3,
        ),
        SizedBox(height: spacing.sm),
        const _ChannelListItem(
          name: 'Engineering',
          message: 'PR merged successfully',
          count: 12,
        ),
      ],
    );
  }
}

class _ChannelListItem extends StatelessWidget {
  const _ChannelListItem({
    required this.name,
    required this.message,
    required this.count,
  });

  final String name;
  final String message;
  final int count;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.streamTextTheme;
    final colorScheme = context.streamColorScheme;
    final spacing = context.streamSpacing;

    return Row(
      children: [
        StreamAvatar(
          size: StreamAvatarSize.lg,
          placeholder: (context) => Text(name[0]),
        ),
        SizedBox(width: spacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: textTheme.bodyEmphasis.copyWith(
                  color: colorScheme.textPrimary,
                ),
              ),
              Text(
                message,
                style: textTheme.captionDefault.copyWith(
                  color: colorScheme.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        SizedBox(width: spacing.sm),
        StreamBadgeCount(label: '$count'),
      ],
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
        border: Border.all(color: colorScheme.borderSurfaceSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(spacing.md, spacing.sm, spacing.md, spacing.sm),
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
          Divider(
            height: 1,
            color: colorScheme.borderSurfaceSubtle,
          ),
          // Content
          Container(
            padding: EdgeInsets.all(spacing.md),
            color: colorScheme.backgroundSurface,
            child: child,
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Shared Widgets
// =============================================================================

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
