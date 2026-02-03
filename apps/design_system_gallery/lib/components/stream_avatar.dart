import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const _sampleImageUrl = 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200';

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamAvatar,
  path: '[Components]/Avatar',
)
Widget buildStreamAvatarPlayground(BuildContext context) {
  final imageUrl = context.knobs.stringOrNull(
    label: 'Image URL',
    initialValue: _sampleImageUrl,
    description: 'URL for the avatar image. Leave empty to show placeholder.',
  );

  final size = context.knobs.object.dropdown(
    label: 'Size',
    options: StreamAvatarSize.values,
    initialOption: StreamAvatarSize.lg,
    labelBuilder: (option) => '${option.name.toUpperCase()} (${option.value.toInt()}px)',
    description: 'Avatar diameter size preset.',
  );

  final showBorder = context.knobs.boolean(
    label: 'Show Border',
    initialValue: true,
    description: 'Whether to show a border around the avatar.',
  );

  final initials = context.knobs.string(
    label: 'Initials',
    initialValue: 'JD',
    description: 'Text shown when no image is available (max 2 chars).',
  );

  return Center(
    child: StreamAvatar(
      imageUrl: (imageUrl?.isNotEmpty ?? false) ? imageUrl : null,
      size: size,
      showBorder: showBorder,
      placeholder: (context) => Text(
        initials.substring(0, initials.length.clamp(0, 2)).toUpperCase(),
      ),
    ),
  );
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamAvatar,
  path: '[Components]/Avatar',
)
Widget buildStreamAvatarShowcase(BuildContext context) {
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

          // Color palette
          const _PaletteSection(),
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
        ...StreamAvatarSize.values.map((size) => _SizeCard(size: size)),
      ],
    );
  }
}

class _SizeCard extends StatelessWidget {
  const _SizeCard({required this.size});

  final StreamAvatarSize size;

  String _getUsage(StreamAvatarSize size) {
    return switch (size) {
      StreamAvatarSize.xs => 'Compact lists, inline mentions',
      StreamAvatarSize.sm => 'Chat list items, notifications',
      StreamAvatarSize.md => 'Message bubbles, comments',
      StreamAvatarSize.lg => 'Profile headers, user cards',
      StreamAvatarSize.xl => 'Hero sections, large profile displays',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final boxShadow = context.streamBoxShadow;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

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
            // Avatar preview
            SizedBox(
              width: 80,
              height: 80,
              child: Center(
                child: StreamAvatar(
                  imageUrl: _sampleImageUrl,
                  size: size,
                  placeholder: (context) => const Text('AB'),
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
                        'StreamAvatarSize.${size.name}',
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
// Palette Section
// =============================================================================

class _PaletteSection extends StatelessWidget {
  const _PaletteSection();

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
        const _SectionLabel(label: 'COLOR PALETTE'),
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
                'Theme-defined color pairs for placeholder avatars',
                style: textTheme.captionDefault.copyWith(
                  color: colorScheme.textSecondary,
                ),
              ),
              SizedBox(height: spacing.md),
              Wrap(
                spacing: spacing.sm,
                runSpacing: spacing.sm,
                children: [
                  for (var i = 0; i < palette.length; i++) _PaletteItem(index: i, entry: palette[i]),
                ],
              ),
              SizedBox(height: spacing.md),
              Divider(color: colorScheme.borderSurfaceSubtle),
              SizedBox(height: spacing.sm),
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 14,
                    color: colorScheme.textTertiary,
                  ),
                  SizedBox(width: spacing.xs + spacing.xxs),
                  Expanded(
                    child: Text(
                      'Colors are automatically assigned based on user ID hash',
                      style: textTheme.metadataDefault.copyWith(
                        color: colorScheme.textTertiary,
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

class _PaletteItem extends StatelessWidget {
  const _PaletteItem({required this.index, required this.entry});

  final int index;
  final StreamAvatarColorPair entry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreamAvatar(
          size: StreamAvatarSize.lg,
          backgroundColor: entry.backgroundColor,
          foregroundColor: entry.foregroundColor,
          placeholder: (context) => Text(_getInitials(index)),
        ),
        SizedBox(height: spacing.xs + spacing.xxs),
        Text(
          'palette[$index]',
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

        // Profile header example
        _ExampleCard(
          title: 'Profile Header',
          description: 'Large avatar with user details',
          child: Row(
            children: [
              StreamAvatar(
                imageUrl: _sampleImageUrl,
                size: StreamAvatarSize.lg,
                placeholder: (context) => const Text('JD'),
              ),
              SizedBox(width: spacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Jane Doe',
                    style: textTheme.headingSm.copyWith(
                      color: colorScheme.textPrimary,
                    ),
                  ),
                  Text(
                    'Product Designer',
                    style: textTheme.bodyDefault.copyWith(
                      color: colorScheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: spacing.sm),

        // Message item example
        _ExampleCard(
          title: 'Message List Item',
          description: 'Medium avatar in conversation list',
          child: Row(
            children: [
              StreamAvatar(
                size: StreamAvatarSize.md,
                backgroundColor: palette[0].backgroundColor,
                foregroundColor: palette[0].foregroundColor,
                placeholder: (context) => const Text('JD'),
              ),
              SizedBox(width: spacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'John Doe',
                    style: textTheme.bodyEmphasis.copyWith(
                      color: colorScheme.textPrimary,
                    ),
                  ),
                  Text(
                    'Hey! Are you free for a call?',
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

        // Compact list example
        _ExampleCard(
          title: 'Compact List',
          description: 'Small avatars for dense layouts',
          child: Column(
            children: [
              for (var i = 0; i < 3; i++) ...[
                Row(
                  children: [
                    StreamAvatar(
                      size: StreamAvatarSize.sm,
                      backgroundColor: palette[i % palette.length].backgroundColor,
                      foregroundColor: palette[i % palette.length].foregroundColor,
                      placeholder: (context) => Text(_getInitials(i)),
                    ),
                    SizedBox(width: spacing.sm + spacing.xxs),
                    Text(
                      ['Alice Brown', 'Bob Smith', 'Carol White'][i],
                      style: textTheme.captionDefault.copyWith(
                        color: colorScheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                if (i < 2) SizedBox(height: spacing.sm),
              ],
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
