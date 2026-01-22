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
  type: StreamAvatarStack,
  path: '[Components]/Avatar',
)
Widget buildStreamAvatarStackPlayground(BuildContext context) {
  final avatarCount = context.knobs.int.slider(
    label: 'Avatar Count',
    initialValue: 4,
    min: 1,
    max: 10,
    description: 'Total number of avatars in the stack.',
  );

  final size = context.knobs.object.dropdown(
    label: 'Size',
    options: StreamAvatarSize.values,
    initialOption: StreamAvatarSize.md,
    labelBuilder: (option) => '${option.name.toUpperCase()} (${option.value.toInt()}px)',
    description: 'Size of each avatar in the stack.',
  );

  final overlap = context.knobs.double.slider(
    label: 'Overlap',
    initialValue: 0.3,
    max: 0.8,
    description: 'How much avatars overlap (0 = none, 0.8 = 80%).',
  );

  final maxAvatars = context.knobs.int.slider(
    label: 'Max Visible',
    initialValue: 5,
    min: 2,
    max: 10,
    description: 'Max avatars shown before "+N" indicator.',
  );

  final showImages = context.knobs.boolean(
    label: 'Show Images',
    initialValue: true,
    description: 'Use images or show initials placeholder.',
  );

  final colorScheme = context.streamColorScheme;
  final palette = colorScheme.avatarPalette;

  return Center(
    child: StreamAvatarStack(
      size: size,
      overlap: overlap,
      max: maxAvatars,
      children: [
        for (var i = 0; i < avatarCount; i++)
          StreamAvatar(
            imageUrl: showImages ? _sampleImages[i % _sampleImages.length] : null,
            backgroundColor: palette[i % palette.length].backgroundColor,
            foregroundColor: palette[i % palette.length].foregroundColor,
            placeholder: (context) => Text(_getInitials(i)),
          ),
      ],
    ),
  );
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamAvatarStack,
  path: '[Components]/Avatar',
)
Widget buildStreamAvatarStackShowcase(BuildContext context) {
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
          // Configuration options
          const _ConfigurationSection(),
          SizedBox(height: spacing.xl),

          // Usage patterns
          const _UsagePatternsSection(),
        ],
      ),
    ),
  );
}

// =============================================================================
// Configuration Section
// =============================================================================

class _ConfigurationSection extends StatelessWidget {
  const _ConfigurationSection();

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
        const _SectionLabel(label: 'CONFIGURATION'),
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
              // Overlap demonstration
              Text(
                'Overlap',
                style: textTheme.captionEmphasis.copyWith(
                  color: colorScheme.textPrimary,
                ),
              ),
              SizedBox(height: spacing.sm),
              Text(
                'Controls how much avatars overlap each other',
                style: textTheme.metadataDefault.copyWith(
                  color: colorScheme.textTertiary,
                ),
              ),
              SizedBox(height: spacing.sm),
              Row(
                children: [
                  _OverlapDemo(
                    label: '0.0',
                    overlap: 0,
                    palette: palette,
                  ),
                  SizedBox(width: spacing.lg),
                  _OverlapDemo(
                    label: '0.3',
                    overlap: 0.3,
                    palette: palette,
                  ),
                  SizedBox(width: spacing.lg),
                  _OverlapDemo(
                    label: '0.5',
                    overlap: 0.5,
                    palette: palette,
                  ),
                ],
              ),
              SizedBox(height: spacing.md),
              Divider(color: colorScheme.borderSurfaceSubtle),
              SizedBox(height: spacing.md),
              // Max avatars demonstration
              Text(
                'Max Visible',
                style: textTheme.captionEmphasis.copyWith(
                  color: colorScheme.textPrimary,
                ),
              ),
              SizedBox(height: spacing.sm),
              Text(
                'Shows "+N" indicator when avatars exceed max',
                style: textTheme.metadataDefault.copyWith(
                  color: colorScheme.textTertiary,
                ),
              ),
              SizedBox(height: spacing.sm),
              Row(
                children: [
                  _MaxDemo(
                    label: 'max: 3',
                    max: 3,
                    count: 6,
                    palette: palette,
                  ),
                  SizedBox(width: spacing.lg),
                  _MaxDemo(
                    label: 'max: 5',
                    max: 5,
                    count: 8,
                    palette: palette,
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

class _OverlapDemo extends StatelessWidget {
  const _OverlapDemo({
    required this.label,
    required this.overlap,
    required this.palette,
  });

  final String label;
  final double overlap;
  final List<StreamAvatarColorPair> palette;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Column(
      children: [
        StreamAvatarStack(
          size: StreamAvatarSize.sm,
          overlap: overlap,
          children: [
            for (var i = 0; i < 3; i++)
              StreamAvatar(
                backgroundColor: palette[i % palette.length].backgroundColor,
                foregroundColor: palette[i % palette.length].foregroundColor,
                placeholder: (context) => Text(_getInitials(i)),
              ),
          ],
        ),
        SizedBox(height: spacing.xs + spacing.xxs),
        Text(
          label,
          style: textTheme.metadataDefault.copyWith(
            color: colorScheme.textTertiary,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

class _MaxDemo extends StatelessWidget {
  const _MaxDemo({
    required this.label,
    required this.max,
    required this.count,
    required this.palette,
  });

  final String label;
  final int max;
  final int count;
  final List<StreamAvatarColorPair> palette;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Column(
      children: [
        StreamAvatarStack(
          size: StreamAvatarSize.sm,
          max: max,
          children: [
            for (var i = 0; i < count; i++)
              StreamAvatar(
                imageUrl: _sampleImages[i % _sampleImages.length],
                backgroundColor: palette[i % palette.length].backgroundColor,
                foregroundColor: palette[i % palette.length].foregroundColor,
                placeholder: (context) => Text(_getInitials(i)),
              ),
          ],
        ),
        SizedBox(height: spacing.xs + spacing.xxs),
        Text(
          label,
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
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;
    final palette = colorScheme.avatarPalette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: 'USAGE PATTERNS'),
        SizedBox(height: spacing.md),

        // Group chat example
        _ExampleCard(
          title: 'Group Chat',
          description: 'Show participants in a conversation',
          child: Row(
            children: [
              StreamAvatarStack(
                size: StreamAvatarSize.sm,
                children: [
                  for (var i = 0; i < 3; i++)
                    StreamAvatar(
                      imageUrl: _sampleImages[i],
                      backgroundColor: palette[i % palette.length].backgroundColor,
                      foregroundColor: palette[i % palette.length].foregroundColor,
                      placeholder: (context) => Text(_getInitials(i)),
                    ),
                ],
              ),
              SizedBox(width: spacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'John, Sarah, Mike',
                    style: textTheme.bodyEmphasis.copyWith(
                      color: colorScheme.textPrimary,
                    ),
                  ),
                  Text(
                    'Active now',
                    style: textTheme.captionDefault.copyWith(
                      color: colorScheme.accentSuccess,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: spacing.sm),

        // Team with overflow example
        _ExampleCard(
          title: 'Team Members',
          description: 'Show team with overflow indicator',
          child: Row(
            children: [
              StreamAvatarStack(
                size: StreamAvatarSize.sm,
                max: 4,
                children: [
                  for (var i = 0; i < 8; i++)
                    StreamAvatar(
                      imageUrl: _sampleImages[i % _sampleImages.length],
                      backgroundColor: palette[i % palette.length].backgroundColor,
                      foregroundColor: palette[i % palette.length].foregroundColor,
                      placeholder: (context) => Text(_getInitials(i)),
                    ),
                ],
              ),
              SizedBox(width: spacing.sm),
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
                    '8 members',
                    style: textTheme.captionDefault.copyWith(
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
  const names = ['AB', 'CD', 'EF', 'GH', 'IJ', 'KL', 'MN', 'OP'];
  return names[index % names.length];
}
