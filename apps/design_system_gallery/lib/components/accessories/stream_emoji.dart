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
  type: StreamEmoji,
  path: '[Components]/Accessories',
)
Widget buildStreamEmojiPlayground(BuildContext context) {
  final size = context.knobs.object.dropdown(
    label: 'Size',
    options: StreamEmojiSize.values,
    initialOption: StreamEmojiSize.md,
    labelBuilder: (option) => '${option.name.toUpperCase()} (${option.value.toInt()}px)',
    description: 'Emoji size preset.',
  );

  final emoji = context.knobs.object.dropdown(
    label: 'Emoji',
    options: _sampleEmojis,
    initialOption: _sampleEmojis.first,
    labelBuilder: (option) => '${option.emoji}  ${option.name}',
    description: 'The emoji to display.',
  );

  final showBounds = context.knobs.boolean(
    label: 'Show Bounds',
    description: 'Show a border around the emoji bounding box.',
  );

  final emojiWidget = StreamEmoji(
    size: size,
    emoji: Text(emoji.emoji),
  );

  return Center(
    child: switch (showBounds) {
      true => DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(context.streamRadius.xs),
          border: Border.all(color: context.streamColorScheme.borderDefault),
        ),
        child: emojiWidget,
      ),
      false => emojiWidget,
    },
  );
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamEmoji,
  path: '[Components]/Accessories',
)
Widget buildStreamEmojiShowcase(BuildContext context) {
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
          const _SizeVariantsSection(),
          SizedBox(height: spacing.xl),
          const _EmojiSamplerSection(),
          SizedBox(height: spacing.xl),
          const _IconUsageSection(),
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
            border: Border.all(color: colorScheme.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Emoji scales across predefined sizes',
                style: textTheme.captionDefault.copyWith(
                  color: colorScheme.textSecondary,
                ),
              ),
              SizedBox(height: spacing.md),
              Row(
                children: [
                  for (final size in StreamEmojiSize.values) ...[
                    _SizeDemo(size: size),
                    if (size != StreamEmojiSize.values.last) SizedBox(width: spacing.xl),
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

  final StreamEmojiSize size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Column(
      children: [
        SizedBox(
          width: 64,
          height: 64,
          child: Center(
            child: StreamEmoji(
              size: size,
              emoji: const Text('🔥'),
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
          '${size.value.toInt()}px',
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
// Emoji Sampler Section
// =============================================================================

class _EmojiSamplerSection extends StatelessWidget {
  const _EmojiSamplerSection();

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
        const _SectionLabel(label: 'EMOJI SAMPLER'),
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
            border: Border.all(color: colorScheme.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Various emojis rendered at consistent sizing',
                style: textTheme.captionDefault.copyWith(
                  color: colorScheme.textSecondary,
                ),
              ),
              SizedBox(height: spacing.md),
              Wrap(
                spacing: spacing.sm,
                runSpacing: spacing.sm,
                children: [
                  for (final emoji in _sampleEmojis)
                    StreamEmoji(
                      size: StreamEmojiSize.lg,
                      emoji: Text(emoji.emoji),
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
// Icon Usage Section
// =============================================================================

class _IconUsageSection extends StatelessWidget {
  const _IconUsageSection();

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
        const _SectionLabel(label: 'WITH ICONS'),
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
            border: Border.all(color: colorScheme.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'StreamEmoji can display any widget, not just emoji',
                style: textTheme.captionDefault.copyWith(
                  color: colorScheme.textSecondary,
                ),
              ),
              SizedBox(height: spacing.md),
              Wrap(
                spacing: spacing.sm,
                runSpacing: spacing.sm,
                children: [
                  for (final iconData in _sampleIcons)
                    StreamEmoji(
                      size: StreamEmojiSize.lg,
                      emoji: Icon(iconData, color: colorScheme.textPrimary),
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

Emoji _byName(String name) => UnicodeEmojis.allEmojis.firstWhere((e) => e.name == name);

final _sampleEmojis = [
  _byName('thumbs up sign'),
  _byName('heavy black heart'),
  _byName('face with tears of joy'),
  _byName('fire'),
  _byName('clapping hands sign'),
  _byName('thinking face'),
  _byName('eyes'),
  _byName('rocket'),
  _byName('party popper'),
  _byName('waving hand sign'),
  _byName('white medium star'),
  _byName('white heavy check mark'),
];

const _sampleIcons = [
  Icons.thumb_up,
  Icons.favorite,
  Icons.sentiment_very_satisfied,
  Icons.local_fire_department,
  Icons.celebration,
  Icons.lightbulb,
  Icons.visibility,
  Icons.rocket_launch,
  Icons.star,
  Icons.check_circle,
  Icons.emoji_emotions,
  Icons.cake,
];
