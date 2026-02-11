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
  type: StreamEmojiButton,
  path: '[Components]/Buttons',
)
Widget buildStreamEmojiButtonPlayground(BuildContext context) {
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
    final size = context.knobs.object.dropdown(
      label: 'Size',
      options: StreamEmojiButtonSize.values,
      initialOption: StreamEmojiButtonSize.lg,
      labelBuilder: (option) => '${option.name.toUpperCase()} (${option.value.toInt()}px)',
      description: 'Button size preset.',
    );

    final emoji = context.knobs.object.dropdown(
      label: 'Emoji',
      options: _sampleEmojis,
      initialOption: _sampleEmojis.first,
      labelBuilder: (option) => '${option.emoji}  ${option.name}',
      description: 'The emoji to display.',
    );

    final isDisabled = context.knobs.boolean(
      label: 'Disabled',
      description: 'Whether the button is disabled (non-interactive).',
    );

    return Center(
      child: StreamEmojiButton(
        size: size,
        emoji: Text(emoji.emoji),
        isSelected: _isSelected,
        onPressed: isDisabled
            ? null
            : () {
                setState(() => _isSelected = !_isSelected);
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text('${emoji.emoji}  ${emoji.name} ${_isSelected ? 'selected' : 'deselected'}'),
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
  type: StreamEmojiButton,
  path: '[Components]/Buttons',
)
Widget buildStreamEmojiButtonShowcase(BuildContext context) {
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
          const _StateVariantsSection(),
          SizedBox(height: spacing.xl),
          const _EmojiGridSection(),
          SizedBox(height: spacing.xl),
          const _WithIconsSection(),
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
                'Button sizes with embedded emoji scaling',
                style: textTheme.captionDefault.copyWith(
                  color: colorScheme.textSecondary,
                ),
              ),
              SizedBox(height: spacing.md),
              Row(
                children: [
                  for (final size in StreamEmojiButtonSize.values) ...[
                    _SizeDemo(size: size),
                    if (size != StreamEmojiButtonSize.values.last) SizedBox(width: spacing.xl),
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

  final StreamEmojiButtonSize size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Column(
      children: [
        StreamEmojiButton(
          size: size,
          emoji: const Text('👍'),
          onPressed: () {},
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
// State Variants Section
// =============================================================================

class _StateVariantsSection extends StatelessWidget {
  const _StateVariantsSection();

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
        const _SectionLabel(label: 'STATE VARIANTS'),
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
                'Interactive states: default, hover, pressed, disabled, selected',
                style: textTheme.captionDefault.copyWith(
                  color: colorScheme.textSecondary,
                ),
              ),
              SizedBox(height: spacing.xs),
              Text(
                'Focused state (blue border) appears during keyboard navigation',
                style: textTheme.metadataDefault.copyWith(
                  color: colorScheme.textTertiary,
                ),
              ),
              SizedBox(height: spacing.md),
              Wrap(
                spacing: spacing.lg,
                runSpacing: spacing.md,
                children: const [
                  _StateDemo(
                    label: 'Default',
                    enabled: true,
                    initialSelected: false,
                  ),
                  _StateDemo(
                    label: 'Disabled',
                    enabled: false,
                    initialSelected: false,
                  ),
                  _StateDemo(
                    label: 'Selected',
                    enabled: true,
                    initialSelected: true,
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

class _StateDemo extends StatefulWidget {
  const _StateDemo({
    required this.label,
    required this.enabled,
    required this.initialSelected,
  });

  final String label;
  final bool enabled;
  final bool initialSelected;

  @override
  State<_StateDemo> createState() => _StateDemoState();
}

class _StateDemoState extends State<_StateDemo> {
  late bool _isSelected;

  @override
  void initState() {
    super.initState();
    _isSelected = widget.initialSelected;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Column(
      children: [
        StreamEmojiButton(
          size: StreamEmojiButtonSize.lg,
          emoji: const Text('👍'),
          isSelected: _isSelected,
          onPressed: widget.enabled
              ? () {
                  if (widget.label != 'Disabled') {
                    setState(() => _isSelected = !_isSelected);
                  }
                }
              : null,
        ),
        SizedBox(height: spacing.sm),
        Text(
          widget.label,
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
// Emoji Grid Section
// =============================================================================

class _EmojiGridSection extends StatelessWidget {
  const _EmojiGridSection();

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
        const _SectionLabel(label: 'EMOJI GRID'),
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
                'Interactive emoji picker pattern',
                style: textTheme.captionDefault.copyWith(
                  color: colorScheme.textSecondary,
                ),
              ),
              SizedBox(height: spacing.md),
              Wrap(
                spacing: spacing.xs,
                runSpacing: spacing.xs,
                children: [
                  for (final emoji in _sampleEmojis)
                    StreamEmojiButton(
                      size: StreamEmojiButtonSize.lg,
                      emoji: Text(emoji.emoji),
                      onPressed: () {
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              content: Text('${emoji.emoji}  ${emoji.name}'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                      },
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
// With Icons Section
// =============================================================================

class _WithIconsSection extends StatelessWidget {
  const _WithIconsSection();

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
                'Using Material Icons instead of emoji',
                style: textTheme.captionDefault.copyWith(
                  color: colorScheme.textSecondary,
                ),
              ),
              SizedBox(height: spacing.md),
              Wrap(
                spacing: spacing.xs,
                runSpacing: spacing.xs,
                children: [
                  for (final iconData in _sampleIcons)
                    StreamEmojiButton(
                      size: StreamEmojiButtonSize.lg,
                      emoji: Icon(iconData, color: colorScheme.textPrimary),
                      onPressed: () {},
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
