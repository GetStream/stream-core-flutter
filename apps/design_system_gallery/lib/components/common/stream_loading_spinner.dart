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
  final size = context.knobs.object.dropdown<StreamLoadingSpinnerSize>(
    label: 'Size',
    options: StreamLoadingSpinnerSize.values,
    initialOption: StreamLoadingSpinnerSize.sm,
    labelBuilder: (option) => '${option.name} (${option.value.toInt()}px)',
    description: 'The diameter of the spinner.',
  );

  return Center(
    child: StreamLoadingSpinner(
      size: size,
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
                  for (final (index, size) in StreamLoadingSpinnerSize.values.indexed) ...[
                    _SpinnerDemo(
                      label: '${size.name} (${size.value.toInt()}px)',
                      size: size,
                    ),
                    if (index < StreamLoadingSpinnerSize.values.length - 1)
                      SizedBox(width: spacing.xl),
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
                  const _ColorDemo(label: 'Default', size: StreamLoadingSpinnerSize.lg),
                  SizedBox(width: spacing.xl),
                  _ColorDemo(label: 'Success', size: StreamLoadingSpinnerSize.lg, color: colorScheme.accentSuccess),
                  SizedBox(width: spacing.xl),
                  _ColorDemo(label: 'Warning', size: StreamLoadingSpinnerSize.lg, color: colorScheme.accentWarning),
                  SizedBox(width: spacing.xl),
                  _ColorDemo(label: 'Error', size: StreamLoadingSpinnerSize.lg, color: colorScheme.accentError),
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
  const _SpinnerDemo({required this.label, required this.size});

  final String label;
  final StreamLoadingSpinnerSize size;

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
  final StreamLoadingSpinnerSize size;
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
