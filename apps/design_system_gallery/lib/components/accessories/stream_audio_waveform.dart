import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamAudioWaveformSlider,
  path: '[Components]/Accessories',
)
Widget buildStreamAudioWaveformSliderPlayground(BuildContext context) {
  final isActive = context.knobs.boolean(
    label: 'Is Active',
    description: 'Whether the waveform is in the active (playing) state.',
  );

  final limit = context.knobs.double.slider(
    label: 'Bar Limit',
    min: 20,
    max: 150,
    initialValue: 100,
    divisions: 13,
    description: 'Maximum number of bars to display.',
  );

  final inverse = context.knobs.boolean(
    label: 'Inverse',
    initialValue: true,
    description: 'If true, bars grow from right to left.',
  );

  return _SliderPlayground(
    isActive: isActive,
    limit: limit.toInt(),
    inverse: inverse,
  );
}

class _SliderPlayground extends StatefulWidget {
  const _SliderPlayground({
    required this.isActive,
    required this.limit,
    required this.inverse,
  });

  final bool isActive;
  final int limit;
  final bool inverse;

  @override
  State<_SliderPlayground> createState() => _SliderPlaygroundState();
}

class _SliderPlaygroundState extends State<_SliderPlayground> {
  double _progress = 0.4;

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(spacing.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: SizedBox(
            height: 40,
            child: StreamAudioWaveformSlider(
              waveform: _sampleWaveform,
              progress: _progress,
              isActive: widget.isActive,
              limit: widget.limit,
              inverse: widget.inverse,
              onChanged: (value) => setState(() => _progress = value),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamAudioWaveformSlider,
  path: '[Components]/Accessories',
)
Widget buildStreamAudioWaveformSliderShowcase(BuildContext context) {
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
          const _ProgressSection(),
          SizedBox(height: spacing.xl),
          const _WaveformOnlySection(),
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
                label: 'Idle',
                description: 'Not playing, thumb uses idle color',
                child: SizedBox(
                  height: 36,
                  child: StreamAudioWaveformSlider(
                    waveform: _sampleWaveform,
                    progress: 0.3,
                    onChanged: (_) {},
                  ),
                ),
              ),
              Divider(height: 1, color: colorScheme.borderSubtle),
              _StateDemo(
                label: 'Active',
                description: 'Playing, thumb uses active color',
                child: SizedBox(
                  height: 36,
                  child: StreamAudioWaveformSlider(
                    waveform: _sampleWaveform,
                    progress: 0.5,
                    isActive: true,
                    onChanged: (_) {},
                  ),
                ),
              ),
              Divider(height: 1, color: colorScheme.borderSubtle),
              _StateDemo(
                label: 'Empty waveform',
                description: 'No waveform data, bars show at minimum height',
                child: SizedBox(
                  height: 36,
                  child: StreamAudioWaveformSlider(
                    waveform: const [],
                    progress: 0,
                    onChanged: (_) {},
                  ),
                ),
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
        Column(
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
        child,
      ],
    );
  }
}

// =============================================================================
// Progress Section
// =============================================================================

class _ProgressSection extends StatelessWidget {
  const _ProgressSection();

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
        const _SectionLabel(label: 'PROGRESS SCALE'),
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
                'Progress fills bars from the leading edge',
                style: textTheme.captionDefault.copyWith(
                  color: colorScheme.textSecondary,
                ),
              ),
              SizedBox(height: spacing.md),
              for (final percent in [0, 25, 50, 75, 100]) ...[
                _ProgressDemo(percentage: percent),
                if (percent < 100) SizedBox(height: spacing.sm),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ProgressDemo extends StatelessWidget {
  const _ProgressDemo({required this.percentage});

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
        Expanded(
          child: SizedBox(
            height: 32,
            child: StreamAudioWaveformSlider(
              waveform: _sampleWaveform,
              progress: percentage / 100,
              isActive: percentage > 0 && percentage < 100,
              onChanged: (_) {},
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Waveform Only Section
// =============================================================================

class _WaveformOnlySection extends StatelessWidget {
  const _WaveformOnlySection();

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
        const _SectionLabel(label: 'WAVEFORM ONLY'),
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
              Text(
                'StreamAudioWaveform without the slider thumb',
                style: textTheme.captionDefault.copyWith(
                  color: colorScheme.textSecondary,
                ),
              ),
              SizedBox(
                height: 32,
                width: double.infinity,
                child: StreamAudioWaveform(
                  waveform: _sampleWaveform,
                  progress: 0.6,
                ),
              ),
              SizedBox(
                height: 32,
                width: double.infinity,
                child: StreamAudioWaveform(
                  waveform: _sampleWaveform,
                  progress: 0,
                ),
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
// Sample Data
// =============================================================================

final List<double> _sampleWaveform = List.generate(
  120,
  (i) => (math.sin(i * 0.15) * 0.3 + 0.5 + math.sin(i * 0.4) * 0.2).clamp(0.0, 1.0),
);
