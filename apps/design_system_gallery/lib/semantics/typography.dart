import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(
  name: 'All Styles',
  type: StreamTextTheme,
  path: '[App Foundation]/Semantics/Typography',
)
Widget buildStreamTextThemeShowcase(BuildContext context) {
  final spacing = context.streamSpacing;

  return DefaultTextStyle(
    style: context.streamTextTheme.bodyDefault.copyWith(
      color: context.streamColorScheme.textPrimary,
    ),
    child: SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Visual Type Scale
          const _TypeScale(),
          SizedBox(height: spacing.xl),

          // Complete Reference
          const _CompleteReference(),
        ],
      ),
    ),
  );
}

/// Visual type scale showing hierarchy at a glance
class _TypeScale extends StatelessWidget {
  const _TypeScale();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final boxShadow = context.streamBoxShadow;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    final categories = [
      (
        'HEADINGS',
        'Page and section titles',
        [
          ('headingLg', textTheme.headingLg, 'Screen titles, channel titles'),
          ('headingMd', textTheme.headingMd, 'Section headers inside screens'),
          ('headingSm', textTheme.headingSm, 'Sub-section headers'),
          ('headingXs', textTheme.headingXs, 'Minor labels, grouped sections'),
        ],
      ),
      (
        'BODY',
        'Main content text',
        [
          ('bodyDefault', textTheme.bodyDefault, 'Message text, primary content'),
          ('bodyEmphasis', textTheme.bodyEmphasis, 'Strong inline emphasis'),
          ('bodyLink', textTheme.bodyLink, 'Inline links'),
          ('bodyLinkEmphasis', textTheme.bodyLinkEmphasis, 'Prominent inline links'),
        ],
      ),
      (
        'CAPTION',
        'Secondary supporting text',
        [
          ('captionDefault', textTheme.captionDefault, 'Secondary supporting text'),
          ('captionEmphasis', textTheme.captionEmphasis, 'Strong supporting text'),
          ('captionLink', textTheme.captionLink, 'Links in caption'),
          ('captionLinkEmphasis', textTheme.captionLinkEmphasis, 'Prominent links in caption'),
        ],
      ),
      (
        'METADATA',
        'Smallest text for auxiliary info',
        [
          ('metadataDefault', textTheme.metadataDefault, 'Timestamps, delivery status'),
          ('metadataEmphasis', textTheme.metadataEmphasis, 'Highlighted metadata'),
          ('metadataLink', textTheme.metadataLink, 'Metadata links'),
          ('metadataLinkEmphasis', textTheme.metadataLinkEmphasis, 'Prominent metadata links'),
        ],
      ),
      (
        'NUMERIC',
        'Numbers and counters',
        [
          ('numericXl', textTheme.numericXl, 'Timestamps, delivery status'),
          ('numericLg', textTheme.numericLg, 'Badges, avatar initials'),
          ('numericMd', textTheme.numericMd, 'Small badge counts'),
          ('numericSm', textTheme.numericSm, 'Micro indicators only'),
        ],
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: 'TYPE SCALE'),
        SizedBox(height: spacing.md),
        ...categories.map((category) {
          final (title, description, styles) = category;
          return Padding(
            padding: EdgeInsets.only(bottom: spacing.md),
            child: Container(
              clipBehavior: Clip.antiAlias,
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
                  // Category header
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.md,
                      vertical: spacing.sm + spacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.backgroundSurfaceSubtle,
                    ),
                    child: Row(
                      children: [
                        Text(
                          title,
                          style: textTheme.metadataEmphasis.copyWith(
                            color: colorScheme.textPrimary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(width: spacing.sm),
                        Text(
                          '— $description',
                          style: textTheme.metadataDefault.copyWith(
                            color: colorScheme.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Styles list
                  ...styles.asMap().entries.map((entry) {
                    final (name, style, usage) = entry.value;
                    final isLast = entry.key == styles.length - 1;
                    return _TypeStyleCard(
                      name: name,
                      style: style,
                      usage: usage,
                      showBorder: !isLast,
                    );
                  }),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

/// Individual type style card
class _TypeStyleCard extends StatelessWidget {
  const _TypeStyleCard({
    required this.name,
    required this.style,
    required this.usage,
    required this.showBorder,
  });

  final String name;
  final TextStyle style;
  final String usage;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    final size = style.fontSize?.toInt() ?? 0;
    final weight = _weightName(style.fontWeight);
    final lineHeight = style.height ?? 1.0;

    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: 'textTheme.$name'));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Copied: textTheme.$name'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(spacing.md),
        decoration: BoxDecoration(
          border: showBorder
              ? Border(
                  bottom: BorderSide(color: colorScheme.borderSubtle),
                )
              : null,
        ),
        child: Row(
          children: [
            // Size indicator bar
            Container(
              width: 3,
              height: size.toDouble().clamp(12, 32),
              margin: EdgeInsets.only(right: spacing.sm),
              decoration: BoxDecoration(
                color: colorScheme.accentPrimary,
                borderRadius: BorderRadius.all(radius.xxs),
              ),
            ),
            // Preview text
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.contains('numeric') ? '1,234,567' : 'The quick brown fox',
                    style: style.copyWith(color: colorScheme.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: spacing.xs),
                  Row(
                    children: [
                      Text(
                        name,
                        style: textTheme.metadataDefault.copyWith(
                          color: colorScheme.accentPrimary,
                          fontFamily: 'monospace',
                        ),
                      ),
                      SizedBox(width: spacing.xs),
                      Icon(
                        Icons.copy,
                        size: 10,
                        color: colorScheme.textTertiary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Specs
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _SpecChip(label: '${size}px'),
                      SizedBox(width: spacing.xs + spacing.xxs),
                      _SpecChip(label: weight),
                      SizedBox(width: spacing.xs + spacing.xxs),
                      _SpecChip(label: '${lineHeight.toStringAsFixed(1)}×'),
                    ],
                  ),
                  SizedBox(height: spacing.xs),
                  Text(
                    usage,
                    style: textTheme.metadataDefault.copyWith(
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

  String _weightName(FontWeight? weight) {
    return switch (weight) {
      FontWeight.w100 => 'Thin',
      FontWeight.w200 => 'ExtraLight',
      FontWeight.w300 => 'Light',
      FontWeight.w400 => 'Regular',
      FontWeight.w500 => 'Medium',
      FontWeight.w600 => 'SemiBold',
      FontWeight.w700 => 'Bold',
      FontWeight.w800 => 'ExtraBold',
      FontWeight.w900 => 'Black',
      _ => '${weight?.value ?? "?"}',
    };
  }
}

/// Small spec chip for displaying typography specs
class _SpecChip extends StatelessWidget {
  const _SpecChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: spacing.xs + spacing.xxs, vertical: spacing.xxs),
      decoration: BoxDecoration(
        color: colorScheme.backgroundSurfaceSubtle,
        borderRadius: BorderRadius.all(radius.xs),
      ),
      child: Text(
        label,
        style: textTheme.metadataDefault.copyWith(
          color: colorScheme.textSecondary,
          fontFamily: 'monospace',
          fontSize: 9,
        ),
      ),
    );
  }
}

/// Quick reference summary
class _CompleteReference extends StatelessWidget {
  const _CompleteReference();

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
        const _SectionLabel(label: 'QUICK REFERENCE'),
        SizedBox(height: spacing.md),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(spacing.md),
          clipBehavior: Clip.antiAlias,
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
                'Style Naming Convention',
                style: textTheme.captionEmphasis.copyWith(
                  color: colorScheme.textPrimary,
                ),
              ),
              SizedBox(height: spacing.sm),
              const _ConventionRow(
                pattern: '{category}Default',
                example: 'bodyDefault',
                description: 'Regular weight, base style',
              ),
              SizedBox(height: spacing.sm),
              const _ConventionRow(
                pattern: '{category}Emphasis',
                example: 'bodyEmphasis',
                description: 'SemiBold weight, emphasis',
              ),
              SizedBox(height: spacing.sm),
              const _ConventionRow(
                pattern: '{category}Link',
                example: 'bodyLink',
                description: 'Regular weight, underlined',
              ),
              SizedBox(height: spacing.sm),
              const _ConventionRow(
                pattern: '{category}LinkEmphasis',
                example: 'bodyLinkEmphasis',
                description: 'SemiBold weight, underlined',
              ),
              SizedBox(height: spacing.md),
              Divider(color: colorScheme.borderSubtle),
              SizedBox(height: spacing.md),
              Text(
                'Size Scale',
                style: textTheme.captionEmphasis.copyWith(
                  color: colorScheme.textPrimary,
                ),
              ),
              SizedBox(height: spacing.sm),
              Wrap(
                spacing: spacing.sm,
                runSpacing: spacing.sm,
                children: [
                  _SizeTag(
                    label: 'heading',
                    sizes: _sizesOf([textTheme.headingLg, textTheme.headingMd, textTheme.headingSm, textTheme.headingXs]),
                  ),
                  _SizeTag(
                    label: 'body',
                    sizes: _sizesOf([textTheme.bodyDefault]),
                  ),
                  _SizeTag(
                    label: 'caption',
                    sizes: _sizesOf([textTheme.captionDefault]),
                  ),
                  _SizeTag(
                    label: 'metadata',
                    sizes: _sizesOf([textTheme.metadataDefault]),
                  ),
                  _SizeTag(
                    label: 'numeric',
                    sizes: _sizesOf([textTheme.numericXl, textTheme.numericLg, textTheme.numericMd, textTheme.numericSm]),
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

class _ConventionRow extends StatelessWidget {
  const _ConventionRow({
    required this.pattern,
    required this.example,
    required this.description,
  });

  final String pattern;
  final String example;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Row(
      children: [
        SizedBox(
          width: 160,
          child: Text(
            pattern,
            style: textTheme.metadataDefault.copyWith(
              color: colorScheme.accentPrimary,
              fontFamily: 'monospace',
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: spacing.xs + spacing.xxs, vertical: spacing.xxs),
          decoration: BoxDecoration(
            color: colorScheme.backgroundSurfaceSubtle,
            borderRadius: BorderRadius.all(radius.xs),
          ),
          child: Text(
            example,
            style: textTheme.metadataDefault.copyWith(
              color: colorScheme.textSecondary,
              fontFamily: 'monospace',
              fontSize: 10,
            ),
          ),
        ),
        SizedBox(width: spacing.sm),
        Expanded(
          child: Text(
            description,
            style: textTheme.metadataDefault.copyWith(
              color: colorScheme.textTertiary,
            ),
          ),
        ),
      ],
    );
  }
}

class _SizeTag extends StatelessWidget {
  const _SizeTag({
    required this.label,
    required this.sizes,
  });

  final String label;
  final String sizes;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: spacing.sm + spacing.xxs, vertical: spacing.xs + spacing.xxs),
      decoration: BoxDecoration(
        color: colorScheme.backgroundSurfaceSubtle,
        borderRadius: BorderRadius.all(radius.sm),
        border: Border.all(color: colorScheme.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: textTheme.metadataEmphasis.copyWith(
              color: colorScheme.textPrimary,
            ),
          ),
          SizedBox(width: spacing.sm),
          Text(
            sizes,
            style: textTheme.metadataDefault.copyWith(
              color: colorScheme.textTertiary,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

String _sizesOf(List<TextStyle> styles) {
  return styles.map((s) => s.fontSize?.toInt().toString() ?? '?').join(' / ');
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
