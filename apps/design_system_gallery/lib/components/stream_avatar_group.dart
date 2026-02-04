import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const _sampleImages = [
  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
  'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200',
  'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=200',
  'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=200',
];

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamAvatarGroup,
  path: '[Components]/Avatar',
)
Widget buildStreamAvatarGroupPlayground(BuildContext context) {
  final size = context.knobs.object.dropdown(
    label: 'Size',
    options: StreamAvatarGroupSize.values,
    initialOption: StreamAvatarGroupSize.xl,
    labelBuilder: (option) => '${option.name.toUpperCase()} (${option.value.toInt()}px)',
    description: 'Avatar group diameter size preset.',
  );

  final avatarCount = context.knobs.int.slider(
    label: 'Avatar Count',
    initialValue: 4,
    min: 1,
    max: 5,
    description: 'Number of avatars to display.',
  );

  final showImages = context.knobs.boolean(
    label: 'Show Images',
    initialValue: true,
    description: 'Use images or show initials placeholder.',
  );

  final palette = context.streamColorScheme.avatarPalette;

  return Center(
    child: StreamAvatarGroup(
      size: size,
      children: List.generate(
        avatarCount,
        (index) => StreamAvatar(
          imageUrl: showImages ? _sampleImages[index % _sampleImages.length] : null,
          backgroundColor: palette[index % palette.length].backgroundColor,
          foregroundColor: palette[index % palette.length].foregroundColor,
          placeholder: (context) => Text(_getInitials(index)),
        ),
      ),
    ),
  );
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamAvatarGroup,
  path: '[Components]/Avatar',
)
Widget buildStreamAvatarGroupShowcase(BuildContext context) {
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

          // Avatar count variants
          const _AvatarCountSection(),
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
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: 'SIZE SCALE'),
        SizedBox(height: spacing.md),
        ...StreamAvatarGroupSize.values.map((size) => _SizeCard(size: size)),
      ],
    );
  }
}

class _SizeCard extends StatelessWidget {
  const _SizeCard({required this.size});

  final StreamAvatarGroupSize size;

  String _getUsage(StreamAvatarGroupSize size) {
    return switch (size) {
      StreamAvatarGroupSize.lg => 'Channel list items, compact group displays',
      StreamAvatarGroupSize.xl => 'Channel headers, prominent group displays',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final boxShadow = context.streamBoxShadow;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;
    final palette = colorScheme.avatarPalette;

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.sm),
      child: Container(
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
        child: Row(
          children: [
            // Avatar group preview
            SizedBox(
              width: 80,
              height: 80,
              child: Center(
                child: StreamAvatarGroup(
                  size: size,
                  children: List.generate(
                    4,
                    (index) => StreamAvatar(
                      imageUrl: _sampleImages[index % _sampleImages.length],
                      backgroundColor: palette[index % palette.length].backgroundColor,
                      foregroundColor: palette[index % palette.length].foregroundColor,
                      placeholder: (context) => Text(_getInitials(index)),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: spacing.md + spacing.xs),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'StreamAvatarGroupSize.${size.name}',
                        style: textTheme.captionEmphasis.copyWith(
                          color: colorScheme.accentPrimary,
                          fontFamily: 'monospace',
                        ),
                      ),
                      SizedBox(width: spacing.sm),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: spacing.xs + spacing.xxs,
                          vertical: spacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.backgroundSurfaceSubtle,
                          borderRadius: BorderRadius.all(radius.xs),
                        ),
                        child: Text(
                          '${size.value.toInt()}px',
                          style: textTheme.metadataEmphasis.copyWith(
                            color: colorScheme.textSecondary,
                            fontFamily: 'monospace',
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: spacing.xs + spacing.xxs),
                  Text(
                    _getUsage(size),
                    style: textTheme.captionDefault.copyWith(
                      color: colorScheme.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Avatar Count Section
// =============================================================================

class _AvatarCountSection extends StatelessWidget {
  const _AvatarCountSection();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final boxShadow = context.streamBoxShadow;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;
    final palette = colorScheme.avatarPalette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: 'AVATAR COUNT'),
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
                'Group displays adapt based on member count',
                style: textTheme.captionDefault.copyWith(
                  color: colorScheme.textSecondary,
                ),
              ),
              SizedBox(height: spacing.md),
              Wrap(
                spacing: spacing.lg,
                runSpacing: spacing.md,
                children: [
                  for (var count = 1; count <= 5; count++)
                    _CountDemo(
                      count: count,
                      children: List.generate(
                        count,
                        (index) => StreamAvatar(
                          imageUrl: _sampleImages[index % _sampleImages.length],
                          backgroundColor: palette[index % palette.length].backgroundColor,
                          foregroundColor: palette[index % palette.length].foregroundColor,
                          placeholder: (context) => Text(_getInitials(index)),
                        ),
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

class _CountDemo extends StatelessWidget {
  const _CountDemo({
    required this.count,
    required this.children,
  });

  final int count;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Column(
      children: [
        StreamAvatarGroup(
          size: StreamAvatarGroupSize.lg,
          children: children,
        ),
        SizedBox(height: spacing.sm),
        Text(
          '$count ${count == 1 ? 'member' : 'members'}',
          style: textTheme.metadataDefault.copyWith(
            color: colorScheme.textTertiary,
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
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;
    final palette = colorScheme.avatarPalette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: 'USAGE PATTERNS'),
        SizedBox(height: spacing.md),

        // Channel list item example
        _ExampleCard(
          title: 'Channel List Item',
          description: 'Group avatar in channel list',
          child: Row(
            children: [
              StreamAvatarGroup(
                size: StreamAvatarGroupSize.lg,
                children: List.generate(
                  3,
                  (index) => StreamAvatar(
                    imageUrl: _sampleImages[index % _sampleImages.length],
                    backgroundColor: palette[index % palette.length].backgroundColor,
                    foregroundColor: palette[index % palette.length].foregroundColor,
                    placeholder: (context) => Text(_getInitials(index)),
                  ),
                ),
              ),
              SizedBox(width: spacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Design Team',
                    style: textTheme.bodyEmphasis.copyWith(
                      color: colorScheme.textPrimary,
                    ),
                  ),
                  Text(
                    '3 members',
                    style: textTheme.captionDefault.copyWith(
                      color: colorScheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: spacing.sm),

        // Channel header example
        _ExampleCard(
          title: 'Channel Header',
          description: 'Large group avatar for channel details',
          child: Row(
            children: [
              StreamAvatarGroup(
                size: StreamAvatarGroupSize.xl,
                children: List.generate(
                  4,
                  (index) => StreamAvatar(
                    imageUrl: _sampleImages[index % _sampleImages.length],
                    backgroundColor: palette[index % palette.length].backgroundColor,
                    foregroundColor: palette[index % palette.length].foregroundColor,
                    placeholder: (context) => Text(_getInitials(index)),
                  ),
                ),
              ),
              SizedBox(width: spacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Product Launch',
                    style: textTheme.headingSm.copyWith(
                      color: colorScheme.textPrimary,
                    ),
                  ),
                  Text(
                    '4 participants',
                    style: textTheme.bodyDefault.copyWith(
                      color: colorScheme.textSecondary,
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

String _getInitials(int index) {
  const names = ['AB', 'CD', 'EF', 'GH', 'IJ'];
  return names[index % names.length];
}
