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

  final determinate = context.knobs.boolean(
    label: 'Determinate',
    description: 'When enabled, shows a fixed progress arc instead of a rotating spinner.',
  );

  final animate =
      determinate &&
      context.knobs.boolean(
        label: 'Animate',
        description:
            'Continuously animate the value from 0.0 to 1.0 to preview the '
            'progress -> checkmark transition.',
      );

  final value = determinate && !animate
      ? context.knobs.double.slider(
          label: 'Value',
          initialValue: 0.6,
          max: 1,
          description: 'The progress value from 0.0 to 1.0.',
        )
      : null;

  return Center(
    child: switch (animate) {
      true => _AnimatedSpinner(size: size),
      false => StreamLoadingSpinner(size: size, value: value),
    },
  );
}

/// Cycles the spinner value from 0.0 to 1.0, holds at 1.0, then restarts.
class _AnimatedSpinner extends StatefulWidget {
  const _AnimatedSpinner({required this.size});

  final StreamLoadingSpinnerSize size;

  @override
  State<_AnimatedSpinner> createState() => _AnimatedSpinnerState();
}

class _AnimatedSpinnerState extends State<_AnimatedSpinner> with SingleTickerProviderStateMixin {
  static const _fillDuration = Duration(seconds: 3);
  static const _holdDuration = Duration(milliseconds: 800);

  late final _controller = AnimationController(
    vsync: this,
    duration: _fillDuration,
  )..addStatusListener(_handleStatusChange);

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  Future<void> _handleStatusChange(AnimationStatus status) async {
    if (status != AnimationStatus.completed) return;
    await Future<void>.delayed(_holdDuration);
    if (!mounted) return;

    _controller.reset();
    return _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => StreamLoadingSpinner(
        size: widget.size,
        value: _controller.value,
      ),
    );
  }
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
          const _ProgressVariantsSection(),
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
                    if (index < StreamLoadingSpinnerSize.values.length - 1) SizedBox(width: spacing.xl),
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
// Progress Variants Section
// =============================================================================

class _ProgressVariantsSection extends StatelessWidget {
  const _ProgressVariantsSection();

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
        const _SectionLabel(label: 'PROGRESS VARIANTS'),
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
                'Determinate progress at different values (100% shows a checkmark)',
                style: textTheme.captionDefault.copyWith(
                  color: colorScheme.textSecondary,
                ),
              ),
              SizedBox(height: spacing.md),
              Row(
                children: [
                  for (final (index, entry) in [
                    ('0%', 0.0),
                    ('25%', 0.25),
                    ('50%', 0.5),
                    ('75%', 0.75),
                    ('100%', 1.0),
                  ].indexed) ...[
                    _ProgressDemo(
                      label: entry.$1,
                      value: entry.$2,
                      size: StreamLoadingSpinnerSize.lg,
                    ),
                    if (index < 4) SizedBox(width: spacing.xl),
                  ],
                ],
              ),
              SizedBox(height: spacing.lg),
              Text(
                'Indeterminate vs determinate comparison',
                style: textTheme.captionDefault.copyWith(
                  color: colorScheme.textSecondary,
                ),
              ),
              SizedBox(height: spacing.md),
              Row(
                children: [
                  const _SpinnerDemo(
                    label: 'Indeterminate',
                    size: StreamLoadingSpinnerSize.lg,
                  ),
                  SizedBox(width: spacing.xl),
                  const _ProgressDemo(
                    label: 'Determinate',
                    value: 0.6,
                    size: StreamLoadingSpinnerSize.lg,
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

class _ProgressDemo extends StatelessWidget {
  const _ProgressDemo({required this.label, required this.value, required this.size});

  final String label;
  final double value;
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
              value: value,
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
