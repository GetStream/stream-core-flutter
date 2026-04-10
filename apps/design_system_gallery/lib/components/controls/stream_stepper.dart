import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamStepper,
  path: '[Components]/Controls',
)
Widget buildStreamStepperPlayground(BuildContext context) {
  return const _PlaygroundDemo();
}

class _PlaygroundDemo extends StatefulWidget {
  const _PlaygroundDemo();

  @override
  State<_PlaygroundDemo> createState() => _PlaygroundDemoState();
}

class _PlaygroundDemoState extends State<_PlaygroundDemo> {
  var _value = 0;

  @override
  Widget build(BuildContext context) {
    final isDisabled = context.knobs.boolean(
      label: 'Disabled',
      description: 'When true, the stepper does not respond to interaction.',
    );

    final min = context.knobs.int.input(
      label: 'Min',
      description: 'The minimum allowed value.',
    );

    final max = context.knobs.int.input(
      label: 'Max',
      initialValue: 99,
      description: 'The maximum allowed value.',
    );

    return Center(
      child: StreamStepper(
        value: _value.clamp(min, max),
        min: min,
        max: max,
        onChanged: isDisabled
            ? null
            : (value) {
                setState(() => _value = value);
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
  type: StreamStepper,
  path: '[Components]/Controls',
)
Widget buildStreamStepperShowcase(BuildContext context) {
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
          _StatesSection(),
          _InteractiveSection(),
          _BoundsSection(),
          _RealWorldSection(),
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
      spacing: spacing.md,
      children: [
        const _SectionLabel(label: 'STATES'),
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
              _StateDemo(
                label: 'Default',
                description: 'Value at zero, both buttons enabled',
                child: StreamStepper(value: 0, onChanged: (_) {}),
              ),
              Divider(height: 1, color: colorScheme.borderSubtle),
              _StateDemo(
                label: 'With Value',
                description: 'Non-zero value, both buttons enabled',
                child: StreamStepper(value: 5, onChanged: (_) {}),
              ),
              Divider(height: 1, color: colorScheme.borderSubtle),
              _StateDemo(
                label: 'At Minimum',
                description: 'Decrement button disabled at min bound',
                child: StreamStepper(value: 0, onChanged: (_) {}),
              ),
              Divider(height: 1, color: colorScheme.borderSubtle),
              _StateDemo(
                label: 'At Maximum',
                description: 'Increment button disabled at max bound',
                child: StreamStepper(value: 10, max: 10, onChanged: (_) {}),
              ),
              Divider(height: 1, color: colorScheme.borderSubtle),
              _StateDemo(
                label: 'Disabled',
                description: 'Non-interactive state',
                child: StreamStepper(value: 3, onChanged: null),
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

    return Row(
      spacing: spacing.md,
      children: [
        child,
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
    );
  }
}

// =============================================================================
// Interactive Section
// =============================================================================

class _InteractiveSection extends StatelessWidget {
  const _InteractiveSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: const [
        _SectionLabel(label: 'INTERACTIVE'),
        _ExampleCard(
          title: 'Counter Demo',
          description: 'Tap the buttons or edit the field to change the value',
          child: _CounterDemo(),
        ),
      ],
    );
  }
}

class _CounterDemo extends StatefulWidget {
  const _CounterDemo();

  @override
  State<_CounterDemo> createState() => _CounterDemoState();
}

class _CounterDemoState extends State<_CounterDemo> {
  var _value = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Row(
      spacing: spacing.lg,
      children: [
        StreamStepper(
          value: _value,
          onChanged: (v) => setState(() => _value = v),
        ),
        Text(
          'Value: $_value',
          style: textTheme.captionDefault.copyWith(
            color: colorScheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Bounds Section
// =============================================================================

class _BoundsSection extends StatelessWidget {
  const _BoundsSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: const [
        _SectionLabel(label: 'CUSTOM BOUNDS'),
        _ExampleCard(
          title: 'Range 1–5',
          description: 'Stepper clamped to a small range',
          child: _BoundsDemo(min: 1, max: 5, initial: 3),
        ),
      ],
    );
  }
}

class _BoundsDemo extends StatefulWidget {
  const _BoundsDemo({
    required this.min,
    required this.max,
    required this.initial,
  });

  final int min;
  final int max;
  final int initial;

  @override
  State<_BoundsDemo> createState() => _BoundsDemoState();
}

class _BoundsDemoState extends State<_BoundsDemo> {
  late int _value = widget.initial;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Row(
      spacing: spacing.lg,
      children: [
        StreamStepper(
          value: _value,
          min: widget.min,
          max: widget.max,
          onChanged: (v) => setState(() => _value = v),
        ),
        Text(
          '$_value (${widget.min}–${widget.max})',
          style: textTheme.captionDefault.copyWith(
            color: colorScheme.textSecondary,
          ),
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
          title: 'Poll Settings',
          description:
              'A stepper used to set the maximum number of votes per person '
              'in a poll — a typical usage pattern for this component.',
          child: _PollSettingsExample(),
        ),
      ],
    );
  }
}

class _PollSettingsExample extends StatefulWidget {
  const _PollSettingsExample();

  @override
  State<_PollSettingsExample> createState() => _PollSettingsExampleState();
}

class _PollSettingsExampleState extends State<_PollSettingsExample> {
  var _maxVotes = 1;
  var _maxOptions = 5;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final radius = context.streamRadius;

    return Container(
      constraints: const BoxConstraints(maxWidth: 360),
      decoration: BoxDecoration(
        color: colorScheme.backgroundSurface,
        borderRadius: BorderRadius.all(radius.lg),
        border: Border.all(color: colorScheme.borderSubtle),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PollSettingRow(
            label: 'Max votes per person',
            value: _maxVotes,
            min: 1,
            max: 10,
            onChanged: (v) => setState(() => _maxVotes = v),
          ),
          Divider(height: 1, color: colorScheme.borderSubtle),
          _PollSettingRow(
            label: 'Max options',
            value: _maxOptions,
            min: 2,
            max: 20,
            onChanged: (v) => setState(() => _maxOptions = v),
          ),
        ],
      ),
    );
  }
}

class _PollSettingRow extends StatelessWidget {
  const _PollSettingRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.md,
        vertical: spacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: textTheme.bodyDefault.copyWith(
                color: colorScheme.textPrimary,
              ),
            ),
          ),
          SizedBox(width: spacing.md),
          StreamStepper(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ],
      ),
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
            padding: EdgeInsets.symmetric(
              horizontal: spacing.md,
              vertical: spacing.sm,
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
