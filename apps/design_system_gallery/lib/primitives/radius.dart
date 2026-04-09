import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(
  name: 'All Values',
  type: StreamRadius,
  path: '[App Foundation]/Primitives/Radius',
)
Widget buildStreamRadiusShowcase(BuildContext context) {
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
          // All radius values
          const _RadiusCardsList(),
          SizedBox(height: spacing.xl),

          // Quick reference
          const _QuickReference(),
        ],
      ),
    ),
  );
}

/// Full-width radius cards showing all values
class _RadiusCardsList extends StatelessWidget {
  const _RadiusCardsList();

  @override
  Widget build(BuildContext context) {
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    final allRadii = [
      _RadiusData(name: 'none', radius: radius.none, usage: 'Sharp corners, dividers'),
      _RadiusData(name: 'xxs', radius: radius.xxs, usage: 'Minimal softening'),
      _RadiusData(name: 'xs', radius: radius.xs, usage: 'Badges, tags'),
      _RadiusData(name: 'sm', radius: radius.sm, usage: 'Small buttons, chips'),
      _RadiusData(name: 'md', radius: radius.md, usage: 'Default buttons, inputs'),
      _RadiusData(name: 'lg', radius: radius.lg, usage: 'Cards, containers'),
      _RadiusData(name: 'xl', radius: radius.xl, usage: 'Modals, large cards'),
      _RadiusData(name: 'xxl', radius: radius.xxl, usage: 'Sheets, dialogs'),
      _RadiusData(name: 'xxxl', radius: radius.xxxl, usage: 'Large containers'),
      _RadiusData(name: 'xxxxl', radius: radius.xxxxl, usage: 'Hero sections'),
      _RadiusData(name: 'max', radius: radius.max, usage: 'Pills, avatars, FABs'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: 'RADIUS SCALE'),
        SizedBox(height: spacing.md),
        ...allRadii.map((data) => _RadiusCard(data: data)),
      ],
    );
  }
}

class _RadiusCard extends StatelessWidget {
  const _RadiusCard({required this.data});

  final _RadiusData data;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final boxShadow = context.streamBoxShadow;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    final value = data.radius.x;
    final displayValue = value == 9999 ? 'max' : '${value.toStringAsFixed(0)}px';

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.sm),
      child: InkWell(
        onTap: () {
          Clipboard.setData(ClipboardData(text: 'radius.${data.name}'));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Copied: radius.${data.name}'),
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
              // Large preview box - rectangle to show radius clearly
              Container(
                width: 120,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.accentPrimary,
                      colorScheme.accentPrimary.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.all(data.radius),
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
                          'radius.${data.name}',
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
                            displayValue,
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

/// Quick reference for radius usage
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
                'Usage Pattern',
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
                child: Text(
                  'borderRadius: BorderRadius.all(context.streamRadius.md)',
                  style: textTheme.captionDefault.copyWith(
                    color: colorScheme.accentPrimary,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              SizedBox(height: spacing.md),
              Divider(color: colorScheme.borderSubtle),
              SizedBox(height: spacing.md),
              Text(
                'Common Choices',
                style: textTheme.captionEmphasis.copyWith(
                  color: colorScheme.textPrimary,
                ),
              ),
              SizedBox(height: spacing.sm),
              const _UsageHint(
                token: 'sm',
                description: 'Interactive elements (buttons, inputs)',
              ),
              SizedBox(height: spacing.sm),
              const _UsageHint(
                token: 'md',
                description: 'Medium containers (cards, dropdowns)',
              ),
              SizedBox(height: spacing.sm),
              const _UsageHint(
                token: 'lg',
                description: 'Large containers (modals, sheets)',
              ),
              SizedBox(height: spacing.sm),
              const _UsageHint(
                token: 'max',
                description: 'Circular elements (avatars, pills)',
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
          width: 48,
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

class _RadiusData {
  const _RadiusData({
    required this.name,
    required this.radius,
    required this.usage,
  });

  final String name;
  final Radius radius;
  final String usage;
}
