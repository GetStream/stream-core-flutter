// ignore_for_file: experimental_member_use

import 'package:flutter/material.dart';
import 'package:stream_core_flutter/video.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

final _sizeNames = {
  StreamRadioButtonSize.sm: 'sm',
  StreamRadioButtonSize.md: 'md',
  StreamRadioButtonSize.lg: 'lg',
};

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamRadioButton,
  path: '[Components]/Controls',
)
Widget buildStreamRadioButtonPlayground(BuildContext context) {
  final size = context.knobs.object.dropdown(
    label: 'Size',
    options: StreamRadioButtonSize.values,
    initialOption: StreamRadioButtonSize.lg,
    labelBuilder: (option) => '${_sizeNames[option]} (${option.diameter.toInt()}px)',
    description: 'Diameter of the radio button.',
  );

  final enabled = context.knobs.boolean(
    label: 'Enabled',
    initialValue: true,
    description: 'Passes enabled: false when off, which gives the disabled look.',
  );

  final toggleable = context.knobs.boolean(
    label: 'Toggleable',
    description: 'Tapping the selected radio button deselects it.',
  );

  return Center(
    child: _RadioGroupDemo(size: size, enabled: enabled, toggleable: toggleable),
  );
}

class _RadioGroupDemo extends StatefulWidget {
  const _RadioGroupDemo({required this.size, required this.enabled, required this.toggleable});

  final StreamRadioButtonSize size;
  final bool enabled;
  final bool toggleable;

  @override
  State<_RadioGroupDemo> createState() => _RadioGroupDemoState();
}

class _RadioGroupDemoState extends State<_RadioGroupDemo> {
  static const _options = ['Small', 'Medium', 'Large'];

  String? _selected = _options.first;

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return RadioGroup<String>(
      groupValue: _selected,
      onChanged: (option) => setState(() => _selected = option),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: spacing.lg,
        children: [
          for (final option in _options)
            Row(
              spacing: spacing.xs,
              children: [
                StreamRadioButton(
                  value: option,
                  size: widget.size,
                  enabled: widget.enabled,
                  toggleable: widget.toggleable,
                  semanticLabel: option,
                ),
                Text(option),
              ],
            ),
        ],
      ),
    );
  }
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamRadioButton,
  path: '[Components]/Controls',
)
Widget buildStreamRadioButtonShowcase(BuildContext context) {
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
          _SizesSection(),
          _StatesSection(),
          _IndicatorSection(),
          _ThemedSection(),
        ],
      ),
    ),
  );
}

class _SizesSection extends StatelessWidget {
  const _SizesSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return _ExampleCard(
      title: 'Sizes',
      description: 'sm 16px, md 20px and lg 24px. The lg indicator is 10px; the others share an 8px indicator.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.md,
        children: [
          for (final size in StreamRadioButtonSize.values)
            Row(
              spacing: spacing.md,
              children: [
                SizedBox(width: 40, child: Text(_sizeNames[size]!)),
                _StaticRadio(selected: true, size: size),
                _StaticRadio(selected: false, size: size),
              ],
            ),
        ],
      ),
    );
  }
}

class _StatesSection extends StatelessWidget {
  const _StatesSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return _ExampleCard(
      title: 'States',
      description: 'Hover, press or tab to a radio button to see its overlay and focus ring.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.md,
        children: [
          for (final enabled in [true, false])
            Row(
              spacing: spacing.md,
              children: [
                SizedBox(width: 72, child: Text(enabled ? 'enabled' : 'disabled')),
                _StaticRadio(selected: true, enabled: enabled),
                _StaticRadio(selected: false, enabled: enabled),
              ],
            ),
        ],
      ),
    );
  }
}

class _IndicatorSection extends StatefulWidget {
  const _IndicatorSection();

  @override
  State<_IndicatorSection> createState() => _IndicatorSectionState();
}

class _IndicatorSectionState extends State<_IndicatorSection> {
  static const _options = ['Built-in microphone', 'USB headset', 'Bluetooth earbuds'];

  var _selected = _options.first;

  @override
  Widget build(BuildContext context) {
    return _ExampleCard(
      title: 'Indicator',
      description:
          'StreamRadioIndicator inside a row: the row owns the tap target and the semantics, '
          'so screen readers announce each entry once.',
      child: Column(
        children: [
          for (final option in _options)
            StreamListTile(
              leading: StreamRadioIndicator(selected: option == _selected, size: StreamRadioButtonSize.sm),
              title: Text(option),
              selected: option == _selected,
              onTap: () => setState(() => _selected = option),
            ),
        ],
      ),
    );
  }
}

class _ThemedSection extends StatelessWidget {
  const _ThemedSection();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final spacing = context.streamSpacing;

    return _ExampleCard(
      title: 'Themed',
      description:
          'StreamRadioButtonStyle.from overrides the selected background and the unselected border. '
          'Tab onto them: the focus ring still shows.',
      child: StreamRadioButtonTheme(
        data: StreamRadioButtonThemeData(
          style: StreamRadioButtonStyle.from(
            selectedBackgroundColor: colorScheme.accentSuccess,
            side: BorderSide(color: colorScheme.accentSuccess, width: 2),
            selectedSide: BorderSide.none,
          ),
        ),
        child: Row(
          spacing: spacing.xl,
          children: const [
            _StaticRadio(selected: true),
            _StaticRadio(selected: false),
          ],
        ),
      ),
    );
  }
}

// A radio button shown selected or not, in a group of its own that ignores
// changes.
class _StaticRadio extends StatelessWidget {
  const _StaticRadio({required this.selected, this.enabled = true, this.size});

  final bool selected;
  final bool enabled;
  final StreamRadioButtonSize? size;

  @override
  Widget build(BuildContext context) {
    return RadioGroup<bool>(
      groupValue: true,
      onChanged: (_) {},
      child: StreamRadioButton(value: selected, enabled: enabled, size: size),
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
            padding: EdgeInsets.fromLTRB(spacing.md, spacing.sm, spacing.md, spacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.captionEmphasis.copyWith(color: colorScheme.textPrimary)),
                Text(description, style: textTheme.metadataDefault.copyWith(color: colorScheme.textTertiary)),
              ],
            ),
          ),
          Divider(height: 1, color: colorScheme.borderSubtle),
          Padding(padding: EdgeInsets.all(spacing.md), child: child),
        ],
      ),
    );
  }
}
