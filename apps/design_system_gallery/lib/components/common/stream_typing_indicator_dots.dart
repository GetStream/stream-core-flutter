import 'package:flutter/material.dart';
import 'package:stream_core_flutter/core.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamTypingIndicatorDots,
  path: '[Components]/Common',
)
Widget buildStreamTypingIndicatorDotsPlayground(BuildContext context) {
  final dotSize = context.knobs.double.slider(
    label: 'Dot Size',
    initialValue: 5,
    min: 2,
    max: 16,
    description: 'The diameter of each dot.',
  );
  final spacing = context.knobs.double.slider(
    label: 'Spacing',
    initialValue: 4,
    max: 16,
    description: 'The gap between adjacent dots.',
  );
  final period = context.knobs.double.slider(
    label: 'Period (ms)',
    initialValue: 1500,
    min: 500,
    max: 4000,
    description: 'The duration of one full cycle of the animation.',
  );
  final reduceMotion = context.knobs.boolean(
    label: 'Reduce Motion',
    description: 'Simulates the platform asking for reduced motion.',
  );

  return MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
    child: Center(
      child: StreamTypingIndicatorDots(
        dotSize: dotSize,
        spacing: spacing,
        period: Duration(milliseconds: period.round()),
        semanticsLabel: 'Someone is typing',
      ),
    ),
  );
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamTypingIndicatorDots,
  path: '[Components]/Common',
)
Widget buildStreamTypingIndicatorDotsShowcase(BuildContext context) {
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
          _Section(
            label: 'ANIMATED',
            description: 'A highlight travels across the dots in reading order',
            child: StreamTypingIndicatorDots(),
          ),
          SizedBox(height: spacing.xl),
          _Section(
            label: 'REDUCED MOTION',
            description: 'Holds a static frame when the platform asks for reduced motion',
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: StreamTypingIndicatorDots(),
            ),
          ),
          SizedBox(height: spacing.xl),
          _Section(
            label: 'RIGHT TO LEFT',
            description: 'Leads from the right in right-to-left layouts',
            child: Directionality(
              textDirection: .rtl,
              child: StreamTypingIndicatorDots(),
            ),
          ),
        ],
      ),
    ),
  );
}

class _Section extends StatelessWidget {
  const _Section({
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
    final boxShadow = context.streamBoxShadow;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: label),
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
                description,
                style: textTheme.captionDefault.copyWith(color: colorScheme.textSecondary),
              ),
              SizedBox(height: spacing.md),
              child,
            ],
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
