import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamProgressBar,
  path: '[Components]/Common',
)
Widget buildStreamProgressBarPlayground(BuildContext context) {
  final colorScheme = context.streamColorScheme;
  final textTheme = context.streamTextTheme;
  final spacing = context.streamSpacing;

  final indeterminate = context.knobs.boolean(
    label: 'Indeterminate',
    description: 'When enabled, shows a looping animation instead of a fixed fill.',
  );

  final value = context.knobs.double.slider(
    label: 'Value',
    max: 1,
    initialValue: 0.5,
    divisions: 20,
    description: 'Progress value from 0.0 to 1.0.',
  );

  final minHeight = context.knobs.double.slider(
    label: 'Min Height',
    min: 2,
    max: 24,
    initialValue: 8,
    divisions: 11,
    description: 'The minimum height of the progress bar.',
  );

  final borderRadius = context.knobs.double.slider(
    label: 'Border Radius',
    max: 16,
    initialValue: 8,
    divisions: 16,
    description: 'The border radius of the progress bar.',
  );

  final effectiveValue = indeterminate ? null : value;
  final percentage = (value * 100).round();

  return Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 264),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: spacing.sm,
        children: [
          StreamProgressBar(
            value: effectiveValue,
            minHeight: minHeight,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          Text(
            indeterminate ? 'Loading…' : '$percentage%',
            style: textTheme.captionEmphasis.copyWith(
              color: colorScheme.textSecondary,
            ),
          ),
        ],
      ),
    ),
  );
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamProgressBar,
  path: '[Components]/Common',
)
Widget buildStreamProgressBarShowcase(BuildContext context) {
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
          const _StatesSection(),
          SizedBox(height: spacing.xl),
          const _ValueScaleSection(),
          SizedBox(height: spacing.xl),
          const _HeightVariantsSection(),
          SizedBox(height: spacing.xl),
          const _UsagePatternsSection(),
        ],
      ),
    ),
  );
}

// =============================================================================
// States Section
// =============================================================================

class _StatesSection extends StatelessWidget {
  const _StatesSection();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final boxShadow = context.streamBoxShadow;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: 'STATES'),
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
            spacing: spacing.md,
            children: [
              _StateDemo(
                label: 'Determinate',
                description: 'Fixed value showing specific progress',
                child: StreamProgressBar(value: 0.6),
              ),
              Divider(height: 1, color: colorScheme.borderSubtle),
              _StateDemo(
                label: 'Indeterminate',
                description: 'Looping animation for unknown duration',
                child: StreamProgressBar(),
              ),
              Divider(height: 1, color: colorScheme.borderSubtle),
              _StateDemo(
                label: 'Empty',
                description: 'Zero progress',
                child: StreamProgressBar(value: 0),
              ),
              Divider(height: 1, color: colorScheme.borderSubtle),
              _StateDemo(
                label: 'Complete',
                description: 'Full progress',
                child: StreamProgressBar(value: 1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StateDemo extends StatelessWidget {
  const _StateDemo({
    required this.label,
    required this.description,
    required this.child,
  });

  final String label;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.sm,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
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
          ],
        ),
        child,
      ],
    );
  }
}

// =============================================================================
// Value Scale Section
// =============================================================================

class _ValueScaleSection extends StatelessWidget {
  const _ValueScaleSection();

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
        const _SectionLabel(label: 'VALUE SCALE'),
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
                'Fill width scales linearly with value',
                style: textTheme.captionDefault.copyWith(
                  color: colorScheme.textSecondary,
                ),
              ),
              SizedBox(height: spacing.md),
              for (final percent in List.generate(11, (i) => i * 10)) ...[
                _ValueDemo(percentage: percent),
                if (percent < 100) SizedBox(height: spacing.sm),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ValueDemo extends StatelessWidget {
  const _ValueDemo({required this.percentage});

  final int percentage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(
            '$percentage%',
            style: textTheme.metadataEmphasis.copyWith(
              color: colorScheme.accentPrimary,
              fontFamily: 'monospace',
            ),
          ),
        ),
        SizedBox(width: spacing.sm),
        Expanded(child: StreamProgressBar(value: percentage / 100)),
      ],
    );
  }
}

// =============================================================================
// Height Variants Section
// =============================================================================

class _HeightVariantsSection extends StatelessWidget {
  const _HeightVariantsSection();

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
        const _SectionLabel(label: 'HEIGHT VARIANTS'),
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
                'Adjustable height via minHeight',
                style: textTheme.captionDefault.copyWith(
                  color: colorScheme.textSecondary,
                ),
              ),
              SizedBox(height: spacing.md),
              for (final height in [4.0, 8.0, 12.0, 16.0]) ...[
                _HeightDemo(height: height),
                if (height < 16) SizedBox(height: spacing.md),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _HeightDemo extends StatelessWidget {
  const _HeightDemo({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(
            '${height.toInt()}px',
            style: textTheme.metadataEmphasis.copyWith(
              color: colorScheme.accentPrimary,
              fontFamily: 'monospace',
            ),
          ),
        ),
        SizedBox(width: spacing.sm),
        Expanded(
          child: StreamProgressBar(value: 0.6, minHeight: height),
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
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: 'USAGE PATTERNS'),
        SizedBox(height: spacing.md),
        const _ExampleCard(
          title: 'Poll Results',
          description: 'Progress bars showing vote distribution',
          child: _PollResultsExample(),
        ),
        SizedBox(height: spacing.sm),
        const _ExampleCard(
          title: 'File Upload',
          description: 'Progress bar indicating upload status',
          child: _FileUploadExample(),
        ),
      ],
    );
  }
}

class _PollResultsExample extends StatelessWidget {
  const _PollResultsExample();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What should we have for lunch?',
          style: textTheme.bodyEmphasis.copyWith(
            color: colorScheme.textPrimary,
          ),
        ),
        SizedBox(height: spacing.md),
        const _PollOption(label: 'Pizza', percentage: 45, votes: 9),
        SizedBox(height: spacing.sm),
        const _PollOption(label: 'Sushi', percentage: 30, votes: 6),
        SizedBox(height: spacing.sm),
        const _PollOption(label: 'Tacos', percentage: 20, votes: 4),
        SizedBox(height: spacing.sm),
        const _PollOption(label: 'Salad', percentage: 5, votes: 1),
        SizedBox(height: spacing.md),
        Text(
          '20 votes',
          style: textTheme.captionDefault.copyWith(
            color: colorScheme.textTertiary,
          ),
        ),
      ],
    );
  }
}

class _PollOption extends StatelessWidget {
  const _PollOption({
    required this.label,
    required this.percentage,
    required this.votes,
  });

  final String label;
  final int percentage;
  final int votes;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.xs,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: textTheme.captionDefault.copyWith(
                  color: colorScheme.textPrimary,
                ),
              ),
            ),
            Text(
              '$percentage%',
              style: textTheme.captionEmphasis.copyWith(
                color: colorScheme.textSecondary,
              ),
            ),
          ],
        ),
        StreamProgressBar(value: percentage / 100),
      ],
    );
  }
}

class _FileUploadExample extends StatelessWidget {
  const _FileUploadExample();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.sm,
      children: [
        Row(
          children: [
            Icon(
              Icons.insert_drive_file_outlined,
              size: 20,
              color: colorScheme.textSecondary,
            ),
            SizedBox(width: spacing.sm),
            Expanded(
              child: Text(
                'presentation.pdf',
                style: textTheme.captionDefault.copyWith(
                  color: colorScheme.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '73%',
              style: textTheme.captionEmphasis.copyWith(
                color: colorScheme.textSecondary,
              ),
            ),
          ],
        ),
        StreamProgressBar(value: 0.73),
        Text(
          '2.4 MB of 3.3 MB',
          style: textTheme.metadataDefault.copyWith(
            color: colorScheme.textTertiary,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Shared Widgets
// =============================================================================

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
        border: Border.all(color: colorScheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              spacing.md,
              spacing.sm,
              spacing.md,
              spacing.sm,
            ),
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
          Divider(height: 1, color: colorScheme.borderSubtle),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(spacing.md),
            color: colorScheme.backgroundSurface,
            child: child,
          ),
        ],
      ),
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
