import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(
  name: 'All Values',
  type: StreamSpacing,
  path: '[App Foundation]/Primitives/Spacing',
)
Widget buildStreamSpacingShowcase(BuildContext context) {
  final textTheme = context.streamTextTheme;
  final colorScheme = context.streamColorScheme;
  final spacing = context.streamSpacing;

  return DefaultTextStyle(
    style: textTheme.bodyDefault.copyWith(color: colorScheme.textPrimary),
    child: SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // All spacing values
          const _SpacingCardsList(),
          SizedBox(height: spacing.xl),

          // Quick reference
          const _QuickReference(),
        ],
      ),
    ),
  );
}

/// Full-width spacing cards showing all values
class _SpacingCardsList extends StatelessWidget {
  const _SpacingCardsList();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    final allSpacing = [
      _SpacingData(name: 'none', value: spacing.none, usage: 'No spacing, tight joins'),
      _SpacingData(name: 'xxxs', value: spacing.xxxs, usage: 'Very tight gaps (tab icons)'),
      _SpacingData(name: 'xxs', value: spacing.xxs, usage: 'Minimal gaps (icon+text)'),
      _SpacingData(name: 'xs', value: spacing.xs, usage: 'Inline elements, small gaps'),
      _SpacingData(name: 'sm', value: spacing.sm, usage: 'Button padding, list gaps'),
      _SpacingData(name: 'md', value: spacing.md, usage: 'Default padding, sections'),
      _SpacingData(name: 'lg', value: spacing.lg, usage: 'Large padding, groups'),
      _SpacingData(name: 'xl', value: spacing.xl, usage: 'Section spacing'),
      _SpacingData(name: 'xxl', value: spacing.xxl, usage: 'Modal padding, gutters'),
      _SpacingData(name: 'xxxl', value: spacing.xxxl, usage: 'Page margins, hero gaps'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: 'SPACING SCALE'),
        SizedBox(height: spacing.md),
        ...allSpacing.map((data) => _SpacingCard(data: data)),
      ],
    );
  }
}

class _SpacingCard extends StatelessWidget {
  const _SpacingCard({required this.data});

  final _SpacingData data;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final boxShadow = context.streamBoxShadow;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.sm),
      child: InkWell(
        onTap: () {
          Clipboard.setData(ClipboardData(text: 'spacing.${data.name}'));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Copied: spacing.${data.name}'),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        borderRadius: BorderRadius.all(radius.lg),
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
            border: Border.all(color: colorScheme.borderSubtle),
          ),
          child: Row(
            children: [
              // Visual spacing demonstration - two boxes with the actual gap
              Container(
                width: 120,
                height: 64,
                padding: EdgeInsets.all(spacing.sm),
                decoration: BoxDecoration(
                  color: colorScheme.backgroundSurfaceSubtle,
                  borderRadius: BorderRadius.all(radius.md),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 24,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colorScheme.accentPrimary,
                        borderRadius: BorderRadius.all(radius.xs),
                      ),
                    ),
                    // The actual spacing
                    SizedBox(width: data.value.clamp(0, 40)),
                    Container(
                      width: 24,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colorScheme.accentPrimary,
                        borderRadius: BorderRadius.all(radius.xs),
                      ),
                    ),
                  ],
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
                          'spacing.${data.name}',
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
                            '${data.value.toInt()}px',
                            style: textTheme.metadataEmphasis.copyWith(
                              color: colorScheme.textSecondary,
                              fontFamily: 'monospace',
                              fontSize: 10,
                            ),
                          ),
                        ),
                        SizedBox(width: spacing.xs + spacing.xxs),
                        Icon(
                          Icons.copy,
                          size: 12,
                          color: colorScheme.textTertiary,
                        ),
                      ],
                    ),
                    SizedBox(height: spacing.xs + spacing.xxs),
                    Text(
                      data.usage,
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
      ),
    );
  }
}

/// Quick reference for spacing usage
class _QuickReference extends StatelessWidget {
  const _QuickReference();

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
                'Usage Patterns',
                style: textTheme.captionEmphasis.copyWith(
                  color: colorScheme.textPrimary,
                ),
              ),
              SizedBox(height: spacing.sm),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(spacing.sm),
                decoration: BoxDecoration(
                  color: colorScheme.backgroundSurfaceSubtle,
                  borderRadius: BorderRadius.all(radius.md),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'padding: EdgeInsets.all(context.streamSpacing.md)',
                      style: textTheme.metadataDefault.copyWith(
                        color: colorScheme.accentPrimary,
                        fontFamily: 'monospace',
                      ),
                    ),
                    SizedBox(height: spacing.xs),
                    Text(
                      'SizedBox(height: context.streamSpacing.lg)',
                      style: textTheme.metadataDefault.copyWith(
                        color: colorScheme.accentPrimary,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: spacing.md),
              Divider(color: colorScheme.borderSubtle),
              SizedBox(height: spacing.md),
              Text(
                'Spacing Scale',
                style: textTheme.captionEmphasis.copyWith(
                  color: colorScheme.textPrimary,
                ),
              ),
              SizedBox(height: spacing.sm),
              Text(
                'Spacing values follow a consistent scale (2, 4, 8, 12, 16...) for visual hierarchy.',
                style: textTheme.captionDefault.copyWith(
                  color: colorScheme.textSecondary,
                ),
              ),
              SizedBox(height: spacing.sm),
              const _UsageHint(
                token: 'xxxs-xs',
                description: 'Fine adjustments (2-8px)',
              ),
              SizedBox(height: spacing.sm),
              const _UsageHint(
                token: 'sm-md',
                description: 'Component internals (8-16px)',
              ),
              SizedBox(height: spacing.sm),
              const _UsageHint(
                token: 'lg-xl',
                description: 'Section gaps (24-32px)',
              ),
              SizedBox(height: spacing.sm),
              const _UsageHint(
                token: 'xxl-xxxl',
                description: 'Page-level spacing (48-64px)',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UsageHint extends StatelessWidget {
  const _UsageHint({
    required this.token,
    required this.description,
  });

  final String token;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Row(
      children: [
        Container(
          width: 56,
          padding: EdgeInsets.symmetric(vertical: spacing.xxs),
          decoration: BoxDecoration(
            color: colorScheme.backgroundSurfaceSubtle,
            borderRadius: BorderRadius.all(radius.xs),
          ),
          child: Center(
            child: Text(
              token,
              style: textTheme.metadataEmphasis.copyWith(
                color: colorScheme.accentPrimary,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
        SizedBox(width: spacing.sm),
        Expanded(
          child: Text(
            description,
            style: textTheme.captionDefault.copyWith(
              color: colorScheme.textSecondary,
            ),
          ),
        ),
      ],
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

class _SpacingData {
  const _SpacingData({
    required this.name,
    required this.value,
    required this.usage,
  });

  final String name;
  final double value;
  final String usage;
}
