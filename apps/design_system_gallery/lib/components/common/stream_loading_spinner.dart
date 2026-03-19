import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamLoadingSpinner,
  path: '[Components]/Common',
)
Widget buildStreamLoadingSpinnerPlayground(BuildContext context) {
  final size = context.knobs.double.slider(
    label: 'Size',
    initialValue: 20,
    min: 12,
    max: 64,
    description: 'The diameter of the spinner.',
  );

  final strokeWidth = context.knobs.double.slider(
    label: 'Stroke Width',
    initialValue: 2,
    min: 1,
    max: 8,
    description: 'The width of the track and arc.',
  );

  return Center(
    child: StreamLoadingSpinner(
      size: size,
      strokeWidth: strokeWidth,
    ),
  );
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamLoadingSpinner,
  path: '[Components]/Common',
)
Widget buildStreamLoadingSpinnerShowcase(BuildContext context) {
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
          const _StrokeVariantsSection(),
          SizedBox(height: spacing.xl),
          const _ColorVariantsSection(),
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
                'Spinners at different sizes',
                style: textTheme.captionDefault.copyWith(
                  color: colorScheme.textSecondary,
                ),
              ),
              SizedBox(height: spacing.md),
              Row(
                children: [
                  for (final (label, size) in [
                    ('16px', 16.0),
                    ('20px', 20.0),
                    ('32px', 32.0),
                    ('48px', 48.0),
                  ]) ...[
                    _SpinnerDemo(label: label, size: size),
                    if (size != 48.0) SizedBox(width: spacing.xl),
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

// =============================================================================
// Stroke Width Variants Section
// =============================================================================

class _StrokeVariantsSection extends StatelessWidget {
  const _StrokeVariantsSection();

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
        const _SectionLabel(label: 'STROKE WIDTH VARIANTS'),
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
                'Different stroke widths at 32px size',
                style: textTheme.captionDefault.copyWith(
                  color: colorScheme.textSecondary,
                ),
              ),
              SizedBox(height: spacing.md),
              Row(
                children: [
                  for (final (label, strokeWidth) in [
                    ('1px', 1.0),
                    ('2px', 2.0),
                    ('4px', 4.0),
                    ('6px', 6.0),
                  ]) ...[
                    _SpinnerDemo(label: label, size: 32, strokeWidth: strokeWidth),
                    if (strokeWidth != 6.0) SizedBox(width: spacing.xl),
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

// =============================================================================
// Color Variants Section
// =============================================================================

class _ColorVariantsSection extends StatelessWidget {
  const _ColorVariantsSection();

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
        const _SectionLabel(label: 'COLOR VARIANTS'),
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
                'Custom arc and track colors',
                style: textTheme.captionDefault.copyWith(
                  color: colorScheme.textSecondary,
                ),
              ),
              SizedBox(height: spacing.md),
              Row(
                children: [
                  const _ColorDemo(label: 'Default', size: 32),
                  SizedBox(width: spacing.xl),
                  _ColorDemo(label: 'Success', size: 32, color: colorScheme.accentSuccess),
                  SizedBox(width: spacing.xl),
                  _ColorDemo(label: 'Warning', size: 32, color: colorScheme.accentWarning),
                  SizedBox(width: spacing.xl),
                  _ColorDemo(label: 'Error', size: 32, color: colorScheme.accentError),
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

class _SpinnerDemo extends StatelessWidget {
  const _SpinnerDemo({required this.label, required this.size, this.strokeWidth});

  final String label;
  final double size;
  final double? strokeWidth;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Column(
      children: [
        SizedBox(
          width: 56,
          height: 56,
          child: Center(
            child: StreamLoadingSpinner(
              size: size,
              strokeWidth: strokeWidth,
            ),
          ),
        ),
        SizedBox(height: spacing.sm),
        Text(
          label,
          style: textTheme.metadataEmphasis.copyWith(
            color: colorScheme.accentPrimary,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

class _ColorDemo extends StatelessWidget {
  const _ColorDemo({required this.label, required this.size, this.color});

  final String label;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Column(
      children: [
        SizedBox(
          width: 56,
          height: 56,
          child: Center(
            child: StreamLoadingSpinner(
              size: size,
              color: color,
            ),
          ),
        ),
        SizedBox(height: spacing.sm),
        Text(
          label,
          style: textTheme.metadataEmphasis.copyWith(
            color: colorScheme.accentPrimary,
            fontFamily: 'monospace',
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
