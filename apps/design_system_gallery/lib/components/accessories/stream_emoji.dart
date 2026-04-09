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

  final contentType = context.knobs.object.dropdown(
    label: 'Content Type',
    options: _ContentType.values,
    initialOption: _ContentType.unicode,
    labelBuilder: (option) => option.label,
    description: 'The type of emoji content to display.',
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

  final content = switch (contentType) {
    _ContentType.unicode => StreamUnicodeEmoji(emoji.emoji),
    _ContentType.image => StreamImageEmoji(url: _twemojiUrl(emoji.emoji)),
  };

  final emojiWidget = StreamEmoji(size: size, emoji: content);

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
          const _ContentVariantsSection(),
          SizedBox(height: spacing.xl),
          const _EmojiSamplerSection(),
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
      spacing: spacing.md,
      children: [
        const _SectionLabel(label: 'SIZE VARIANTS'),
        _Card(
          title: 'Predefined Sizes',
          subtitle: 'Emoji scales across predefined size presets',
          child: Wrap(
            spacing: spacing.xl,
            runSpacing: spacing.xl,
            children: [
              for (final size in StreamEmojiSize.values) _SizeDemo(size: size),
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
              emoji: const StreamUnicodeEmoji('🔥'),
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
// Content Variants Section
// =============================================================================

class _ContentVariantsSection extends StatelessWidget {
  const _ContentVariantsSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: [
        const _SectionLabel(label: 'CONTENT VARIANTS'),

        // Unicode vs Image comparison
        _Card(
          title: 'Unicode vs Image',
          subtitle: 'Same emoji rendered via native Unicode and Twemoji image',
          child: Wrap(
            spacing: spacing.xl,
            runSpacing: spacing.lg,
            children: [
              const _ContentDemo(
                label: 'Unicode (native)',
                emoji: StreamUnicodeEmoji('🎉'),
              ),
              _ContentDemo(
                label: 'Image (Twemoji)',
                emoji: StreamImageEmoji(url: _twemojiUrl('🎉')),
              ),
              _ContentDemo(
                label: 'Error fallback',
                emoji: StreamImageEmoji(
                  url: Uri.parse('https://invalid.example/404.png'),
                ),
              ),
            ],
          ),
        ),

        // Animated emoji with still fallback
        _Card(
          title: 'Animated Emoji',
          subtitle: 'Animated GIF with a still fallback when "Reduce Motion" is enabled',
          child: Wrap(
            spacing: spacing.xl,
            runSpacing: spacing.lg,
            children: [
              _ContentDemo(
                label: 'Animated (GIF)',
                emoji: StreamImageEmoji(
                  url: Uri.parse(
                    'https://cultofthepartyparrot.com/parrots/hd/parrot.gif',
                  ),
                  stillUrl: _twemojiUrl('🦜'),
                ),
              ),
              _ContentDemo(
                label: 'Still fallback',
                emoji: StreamImageEmoji(url: _twemojiUrl('🦜')),
              ),
            ],
          ),
        ),

        // Custom emoji showcase from various platforms
        _Card(
          title: 'Custom Image Emoji',
          subtitle: 'Examples of platform-specific custom emoji',
          child: Wrap(
            spacing: spacing.xl,
            runSpacing: spacing.lg,
            children: [
              for (final item in _customEmojiSamples) _ContentDemo(label: item.label, emoji: item.emoji),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContentDemo extends StatelessWidget {
  const _ContentDemo({required this.label, required this.emoji});

  final String label;
  final StreamEmojiContent emoji;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Column(
      children: [
        StreamEmoji(size: StreamEmojiSize.xl, emoji: emoji),
        SizedBox(height: spacing.xs),
        Text(
          label,
          style: textTheme.metadataDefault.copyWith(
            color: colorScheme.textTertiary,
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
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: [
        const _SectionLabel(label: 'EMOJI SAMPLER'),
        _Card(
          title: 'Unicode Emoji Gallery',
          subtitle: 'Various emojis rendered at consistent sizing',
          child: Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: [
              for (final emoji in _sampleEmojis)
                StreamEmoji(
                  size: StreamEmojiSize.lg,
                  emoji: StreamUnicodeEmoji(emoji.emoji),
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

class _Card extends StatelessWidget {
  const _Card({required this.title, this.subtitle, required this.child});

  final String title;
  final String? subtitle;
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
        spacing: spacing.sm,
        children: [
          Text(
            title,
            style: textTheme.bodyEmphasis.copyWith(
              color: colorScheme.textPrimary,
            ),
          ),
          if (subtitle case final subtitle?)
            Text(
              subtitle,
              style: textTheme.captionDefault.copyWith(
                color: colorScheme.textSecondary,
              ),
            ),
          SizedBox(height: spacing.xxs),
          child,
        ],
      ),
    );
  }
}

// =============================================================================
// Helpers
// =============================================================================

enum _ContentType {
  unicode('Unicode'),
  image('Image (Twemoji)')
  ;

  const _ContentType(this.label);
  final String label;
}

Uri _twemojiUrl(String emoji) {
  final codePoints = emoji.runes.map((r) => r.toRadixString(16)).join('-');
  return Uri.parse(
    'https://cdn.jsdelivr.net/gh/twitter/twemoji@latest/assets/72x72/$codePoints.png',
  );
}

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

// Custom emoji samples from various platforms.
// All samples use the same emoji (🔥 U+1F525) for a direct visual comparison.
final _customEmojiSamples = [
  (label: 'Twemoji', emoji: StreamImageEmoji(url: _twemojiUrl('🔥'))),
  (
    label: 'Noto Emoji',
    emoji: StreamImageEmoji(
      url: Uri.parse(
        'https://fonts.gstatic.com/s/e/notoemoji/latest/1f525/512.png',
      ),
    ),
  ),
  (
    label: 'OpenMoji',
    emoji: StreamImageEmoji(
      url: Uri.parse(
        'https://cdn.jsdelivr.net/gh/hfg-gmuend/openmoji/color/72x72/1F525.png',
      ),
    ),
  ),
  (
    label: 'Fluent Emoji',
    emoji: StreamImageEmoji(
      url: Uri.parse(
        'https://cdn.jsdelivr.net/gh/shuding/fluentui-emoji-unicode/assets/1f525_3d.png',
      ),
    ),
  ),
];
