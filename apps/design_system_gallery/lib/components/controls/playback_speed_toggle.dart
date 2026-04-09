import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamPlaybackSpeedToggle,
  path: '[Components]/Controls',
)
Widget buildStreamPlaybackSpeedTogglePlayground(BuildContext context) {
  return const _PlaygroundDemo();
}

class _PlaygroundDemo extends StatefulWidget {
  const _PlaygroundDemo();

  @override
  State<_PlaygroundDemo> createState() => _PlaygroundDemoState();
}

class _PlaygroundDemoState extends State<_PlaygroundDemo> {
  var _speed = StreamPlaybackSpeed.x1;

  @override
  Widget build(BuildContext context) {
    final isDisabled = context.knobs.boolean(
      label: 'Disabled',
      description: 'When true, the toggle does not respond to taps.',
    );

    return Center(
      child: StreamPlaybackSpeedToggle(
        value: _speed,
        onChanged: isDisabled
            ? null
            : (speed) {
                setState(() => _speed = speed);
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
  type: StreamPlaybackSpeedToggle,
  path: '[Components]/Controls',
)
Widget buildStreamPlaybackSpeedToggleShowcase(BuildContext context) {
  final colorScheme = context.streamColorScheme;
  final textTheme = context.streamTextTheme;
  final spacing = context.streamSpacing;

  return DefaultTextStyle(
    style: textTheme.bodyDefault.copyWith(color: colorScheme.textPrimary),
    child: SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.xl,
        children: const [
          _SpeedVariantsSection(),
          _StateMatrixSection(),
          _CycleSection(),
          _RealWorldSection(),
        ],
      ),
    ),
  );
}

// =============================================================================
// Speed Variants Section
// =============================================================================

class _SpeedVariantsSection extends StatelessWidget {
  const _SpeedVariantsSection();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final boxShadow = context.streamBoxShadow;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: [
        const _SectionLabel(label: 'SPEED VARIANTS'),
        Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          padding: EdgeInsets.all(spacing.md),
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
            spacing: spacing.md,
            children: [
              Text(
                'Each toggle displays a pill-shaped button with the current '
                'speed label. All three speed values are shown side by side.',
                style: textTheme.captionDefault.copyWith(color: colorScheme.textSecondary),
              ),
              Wrap(
                spacing: spacing.lg,
                runSpacing: spacing.md,
                children: [
                  for (final speed in StreamPlaybackSpeed.values)
                    _VariantDemo(
                      label: speed.label,
                      child: StreamPlaybackSpeedToggle(
                        value: speed,
                        onChanged: (_) {},
                      ),
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
// State Matrix Section
// =============================================================================

class _StateMatrixSection extends StatelessWidget {
  const _StateMatrixSection();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final boxShadow = context.streamBoxShadow;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: [
        const _SectionLabel(label: 'STATE MATRIX'),
        Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          padding: EdgeInsets.all(spacing.md),
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
            spacing: spacing.md,
            children: [
              Text(
                'Enabled toggles respond to taps and cycle to the next speed. '
                'Disabled toggles show muted styling and ignore input.',
                style: textTheme.captionDefault.copyWith(color: colorScheme.textSecondary),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  spacing: spacing.md,
                  children: [
                    _StateRow(
                      stateLabel: '',
                      cells: [
                        for (final speed in StreamPlaybackSpeed.values)
                          Text(
                            speed.label,
                            style: textTheme.metadataEmphasis.copyWith(
                              color: colorScheme.textTertiary,
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                    _StateRow(
                      stateLabel: 'enabled',
                      cells: [
                        for (final speed in StreamPlaybackSpeed.values)
                          StreamPlaybackSpeedToggle(
                            value: speed,
                            onChanged: (_) {},
                          ),
                      ],
                    ),
                    _StateRow(
                      stateLabel: 'disabled',
                      cells: [
                        for (final speed in StreamPlaybackSpeed.values) StreamPlaybackSpeedToggle(value: speed),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StateRow extends StatelessWidget {
  const _StateRow({required this.stateLabel, required this.cells});

  final String stateLabel;
  final List<Widget> cells;

  static const _cellWidth = 80.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;

    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            stateLabel,
            style: textTheme.metadataEmphasis.copyWith(
              color: colorScheme.textSecondary,
              fontSize: 10,
            ),
          ),
        ),
        for (final cell in cells)
          SizedBox(
            width: _cellWidth,
            child: Center(child: cell),
          ),
      ],
    );
  }
}

// =============================================================================
// Cycle Section
// =============================================================================

class _CycleSection extends StatelessWidget {
  const _CycleSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: const [
        _SectionLabel(label: 'INTERACTIVE CYCLE'),
        _ExampleCard(
          title: 'Tap to Cycle',
          description: 'Tap the toggle to cycle through speeds: x1 → x2 → x0.5 → x1.',
          child: _CycleDemoInteractive(),
        ),
      ],
    );
  }
}

class _CycleDemoInteractive extends StatefulWidget {
  const _CycleDemoInteractive();

  @override
  State<_CycleDemoInteractive> createState() => _CycleDemoInteractiveState();
}

class _CycleDemoInteractiveState extends State<_CycleDemoInteractive> {
  var _speed = StreamPlaybackSpeed.x1;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: spacing.md,
      children: [
        StreamPlaybackSpeedToggle(
          value: _speed,
          onChanged: (speed) => setState(() => _speed = speed),
        ),
        Text(
          'Current: ${_speed.label} (${_speed.speed}x)',
          style: textTheme.captionDefault.copyWith(color: colorScheme.textSecondary),
        ),
      ],
    );
  }
}

// =============================================================================
// Real-World Section
// =============================================================================

class _RealWorldSection extends StatelessWidget {
  const _RealWorldSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: const [
        _SectionLabel(label: 'REAL-WORLD EXAMPLE'),
        _ExampleCard(
          title: 'Voice Message Player',
          description:
              'A simulated voice message player with a waveform area and a '
              'playback speed toggle — typical placement for this component.',
          child: _VoiceMessageExample(),
        ),
      ],
    );
  }
}

class _VoiceMessageExample extends StatefulWidget {
  const _VoiceMessageExample();

  @override
  State<_VoiceMessageExample> createState() => _VoiceMessageExampleState();
}

class _VoiceMessageExampleState extends State<_VoiceMessageExample> {
  var _speed = StreamPlaybackSpeed.x1;
  var _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      padding: EdgeInsets.symmetric(horizontal: spacing.md, vertical: spacing.sm),
      decoration: BoxDecoration(
        color: colorScheme.backgroundSurface,
        borderRadius: BorderRadius.all(radius.lg),
        border: Border.all(color: colorScheme.borderSubtle),
      ),
      child: Row(
        spacing: spacing.sm,
        children: [
          GestureDetector(
            onTap: () => setState(() => _isPlaying = !_isPlaying),
            child: Icon(
              _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              size: 32,
              color: colorScheme.accentPrimary,
            ),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: spacing.xxs,
              children: [
                Container(
                  height: 24,
                  decoration: BoxDecoration(
                    color: colorScheme.backgroundSurfaceSubtle,
                    borderRadius: BorderRadius.all(radius.sm),
                  ),
                  child: CustomPaint(
                    painter: _WaveformPainter(color: colorScheme.accentPrimary),
                    size: const Size(double.infinity, 24),
                  ),
                ),
                Text(
                  '0:42',
                  style: textTheme.metadataDefault.copyWith(color: colorScheme.textTertiary),
                ),
              ],
            ),
          ),
          StreamPlaybackSpeedToggle(
            value: _speed,
            onChanged: (speed) => setState(() => _speed = speed),
          ),
        ],
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  _WaveformPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    const barCount = 30;
    final barSpacing = size.width / barCount;
    final maxHeight = size.height * 0.8;
    final centerY = size.height / 2;

    for (var i = 0; i < barCount; i++) {
      final x = i * barSpacing + barSpacing / 2;
      final normalized = (i / barCount * 3.14159 * 2).abs();
      final height = (maxHeight * 0.3) + (maxHeight * 0.7 * _pseudoRandom(i, normalized));
      canvas.drawLine(
        Offset(x, centerY - height / 2),
        Offset(x, centerY + height / 2),
        paint,
      );
    }
  }

  double _pseudoRandom(int index, double normalized) {
    final val = ((index * 7 + 13) % 17) / 17.0;
    return val * 0.6 + 0.2 * (normalized % 1.0);
  }

  @override
  bool shouldRepaint(_WaveformPainter oldDelegate) => color != oldDelegate.color;
}

// =============================================================================
// Shared Widgets
// =============================================================================

class _VariantDemo extends StatelessWidget {
  const _VariantDemo({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: spacing.xs,
      children: [
        child,
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
            padding: EdgeInsets.symmetric(horizontal: spacing.md, vertical: spacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.captionEmphasis.copyWith(color: colorScheme.textPrimary),
                ),
                Text(
                  description,
                  style: textTheme.metadataDefault.copyWith(color: colorScheme.textTertiary),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colorScheme.borderSubtle),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(spacing.md),
            color: colorScheme.backgroundSurfaceSubtle,
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
