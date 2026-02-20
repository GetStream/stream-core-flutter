import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamCheckbox,
  path: '[Components]/Common',
)
Widget buildStreamCheckboxPlayground(BuildContext context) {
  final spacing = context.streamSpacing;

  final value = context.knobs.boolean(
    label: 'Checked',
    description: 'Whether the checkbox is checked.',
  );

  final enabled = context.knobs.boolean(
    label: 'Enabled',
    initialValue: true,
    description: 'Whether the checkbox responds to input.',
  );

  final size = context.knobs.object.dropdown(
    label: 'Size',
    initialOption: StreamCheckboxSize.md,
    options: StreamCheckboxSize.values,
    labelBuilder: (size) => switch (size) {
      StreamCheckboxSize.sm => 'Small (20px)',
      StreamCheckboxSize.md => 'Medium (24px)',
    },
    description: 'The size of the checkbox.',
  );

  final shape = context.knobs.object.dropdown(
    label: 'Shape',
    initialOption: 'Checkbox',
    options: ['Checkbox', 'Radio Check'],
    labelBuilder: (s) => s,
    description: 'The shape variant of the checkbox.',
  );

  final isRadioCheck = shape == 'Radio Check';

  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      spacing: spacing.md,
      children: [
        if (isRadioCheck)
          StreamCheckbox.circular(
            value: value,
            size: size,
            onChanged: enabled ? (_) {} : null,
          )
        else
          StreamCheckbox(
            value: value,
            size: size,
            onChanged: enabled ? (_) {} : null,
          ),
      ],
    ),
  );
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamCheckbox,
  path: '[Components]/Common',
)
Widget buildStreamCheckboxShowcase(BuildContext context) {
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
          const _SizesSection(),
          SizedBox(height: spacing.xl),
          const _CircleVariantSection(),
          SizedBox(height: spacing.xl),
          const _InteractiveSection(),
          SizedBox(height: spacing.xl),
          const _ThemeCustomizationSection(),
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
                label: 'Unchecked',
                description: 'Default unselected state',
                child: StreamCheckbox(value: false, onChanged: (_) {}),
              ),
              Divider(height: 1, color: colorScheme.borderSubtle),
              _StateDemo(
                label: 'Checked',
                description: 'Selected with checkmark',
                child: StreamCheckbox(value: true, onChanged: (_) {}),
              ),
              Divider(height: 1, color: colorScheme.borderSubtle),
              _StateDemo(
                label: 'Disabled Unchecked',
                description: 'Non-interactive unselected state',
                child: StreamCheckbox(value: false, onChanged: null),
              ),
              Divider(height: 1, color: colorScheme.borderSubtle),
              _StateDemo(
                label: 'Disabled Checked',
                description: 'Non-interactive selected state',
                child: StreamCheckbox(value: true, onChanged: null),
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
// Sizes Section
// =============================================================================

class _SizesSection extends StatelessWidget {
  const _SizesSection();

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
        const _SectionLabel(label: 'SIZES'),
        SizedBox(height: spacing.md),
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
            children: [
              Text(
                'Checkbox sizes: small (20px) and medium (24px)',
                style: textTheme.captionDefault.copyWith(
                  color: colorScheme.textSecondary,
                ),
              ),
              SizedBox(height: spacing.md),
              for (final size in StreamCheckboxSize.values) ...[
                _SizeDemo(size: size),
                if (size != StreamCheckboxSize.values.last) SizedBox(height: spacing.md),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SizeDemo extends StatelessWidget {
  const _SizeDemo({required this.size});

  final StreamCheckboxSize size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Row(
      spacing: spacing.md,
      children: [
        SizedBox(
          width: 56,
          child: Text(
            '${size.name} (${size.value.toInt()}px)',
            style: textTheme.metadataEmphasis.copyWith(
              color: colorScheme.accentPrimary,
              fontFamily: 'monospace',
            ),
          ),
        ),
        StreamCheckbox(value: false, size: size, onChanged: (_) {}),
        StreamCheckbox(value: true, size: size, onChanged: (_) {}),
        StreamCheckbox(value: false, size: size, onChanged: null),
        StreamCheckbox(value: true, size: size, onChanged: null),
      ],
    );
  }
}

// =============================================================================
// Circular Variant Section
// =============================================================================

class _CircleVariantSection extends StatelessWidget {
  const _CircleVariantSection();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final boxShadow = context.streamBoxShadow;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: 'CIRCULAR VARIANT'),
        SizedBox(height: spacing.md),
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
                label: 'Unselected',
                description: 'Circular unselected state',
                child: StreamCheckbox.circular(
                  value: false,
                  onChanged: (_) {},
                ),
              ),
              Divider(height: 1, color: colorScheme.borderSubtle),
              _StateDemo(
                label: 'Selected',
                description: 'Circular selected with checkmark',
                child: StreamCheckbox.circular(
                  value: true,
                  onChanged: (_) {},
                ),
              ),
              Divider(height: 1, color: colorScheme.borderSubtle),
              _StateDemo(
                label: 'Disabled Unselected',
                description: 'Non-interactive circular state',
                child: StreamCheckbox.circular(
                  value: false,
                  onChanged: null,
                ),
              ),
              Divider(height: 1, color: colorScheme.borderSubtle),
              _StateDemo(
                label: 'Disabled Selected',
                description: 'Non-interactive circular selected state',
                child: StreamCheckbox.circular(
                  value: true,
                  onChanged: null,
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
      children: [
        const _SectionLabel(label: 'INTERACTIVE'),
        SizedBox(height: spacing.md),
        const _ExampleCard(
          title: 'Toggle Demo',
          description: 'Tap the checkboxes to toggle them',
          child: _ToggleDemo(),
        ),
        SizedBox(height: spacing.sm),
        const _ExampleCard(
          title: 'Checklist',
          description: 'A common usage pattern for checkboxes',
          child: _ChecklistExample(),
        ),
        SizedBox(height: spacing.sm),
        const _ExampleCard(
          title: 'Single Selection',
          description: 'Circular variant for radio-like selection',
          child: _SingleSelectionExample(),
        ),
      ],
    );
  }
}

class _ToggleDemo extends StatefulWidget {
  const _ToggleDemo();

  @override
  State<_ToggleDemo> createState() => _ToggleDemoState();
}

class _ToggleDemoState extends State<_ToggleDemo> {
  var _value1 = false;
  var _value2 = true;

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Row(
      spacing: spacing.lg,
      children: [
        StreamCheckbox(
          value: _value1,
          onChanged: (v) => setState(() => _value1 = v),
        ),
        StreamCheckbox(
          value: _value2,
          onChanged: (v) => setState(() => _value2 = v),
        ),
        StreamCheckbox(
          value: _value1,
          size: StreamCheckboxSize.sm,
          onChanged: (v) => setState(() => _value1 = v),
        ),
        StreamCheckbox(
          value: _value2,
          size: StreamCheckboxSize.sm,
          onChanged: (v) => setState(() => _value2 = v),
        ),
      ],
    );
  }
}

class _ChecklistExample extends StatefulWidget {
  const _ChecklistExample();

  @override
  State<_ChecklistExample> createState() => _ChecklistExampleState();
}

class _ChecklistExampleState extends State<_ChecklistExample> {
  final _items = [
    (label: 'Design review', checked: true),
    (label: 'Update documentation', checked: false),
    (label: 'Write unit tests', checked: false),
    (label: 'Deploy to staging', checked: false),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < _items.length; i++) ...[
          Row(
            spacing: spacing.sm,
            children: [
              StreamCheckbox(
                value: _items[i].checked,
                onChanged: (v) {
                  setState(() {
                    _items[i] = (label: _items[i].label, checked: v);
                  });
                },
              ),
              Expanded(
                child: Text(
                  _items[i].label,
                  style: textTheme.bodyDefault.copyWith(
                    color: _items[i].checked ? colorScheme.textTertiary : colorScheme.textPrimary,
                    decoration: _items[i].checked ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            ],
          ),
          if (i < _items.length - 1) SizedBox(height: spacing.sm),
        ],
      ],
    );
  }
}

class _SingleSelectionExample extends StatefulWidget {
  const _SingleSelectionExample();

  @override
  State<_SingleSelectionExample> createState() => _SingleSelectionExampleState();
}

class _SingleSelectionExampleState extends State<_SingleSelectionExample> {
  var _selectedIndex = 0;

  static const _options = [
    'Light mode',
    'Dark mode',
    'System default',
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < _options.length; i++) ...[
          Row(
            spacing: spacing.sm,
            children: [
              StreamCheckbox.circular(
                value: _selectedIndex == i,
                onChanged: (_) => setState(() => _selectedIndex = i),
              ),
              Expanded(
                child: Text(
                  _options[i],
                  style: textTheme.bodyDefault.copyWith(
                    color: colorScheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          if (i < _options.length - 1) SizedBox(height: spacing.sm),
        ],
      ],
    );
  }
}

// =============================================================================
// Theme Customization Section
// =============================================================================

class _ThemeCustomizationSection extends StatelessWidget {
  const _ThemeCustomizationSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: 'THEME CUSTOMIZATION'),
        SizedBox(height: spacing.md),
        const _ExampleCard(
          title: 'Custom Colors',
          description: 'Overriding fill and check colors via theme',
          child: _CustomColorsDemo(),
        ),
        SizedBox(height: spacing.sm),
        const _ExampleCard(
          title: 'Custom Shape',
          description: 'Default vs circular variant side by side',
          child: _CustomShapeDemo(),
        ),
      ],
    );
  }
}

class _CustomColorsDemo extends StatefulWidget {
  const _CustomColorsDemo();

  @override
  State<_CustomColorsDemo> createState() => _CustomColorsDemoState();
}

class _CustomColorsDemoState extends State<_CustomColorsDemo> {
  var _value = true;

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Row(
      spacing: spacing.lg,
      children: [
        StreamCheckboxTheme(
          data: StreamCheckboxThemeData(
            style: StreamCheckboxStyle(
              fillColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.green;
                }
                return Colors.transparent;
              }),
            ),
          ),
          child: StreamCheckbox(
            value: _value,
            onChanged: (v) => setState(() => _value = v),
          ),
        ),
        StreamCheckboxTheme(
          data: StreamCheckboxThemeData(
            style: StreamCheckboxStyle(
              fillColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.deepOrange;
                }
                return Colors.transparent;
              }),
            ),
          ),
          child: StreamCheckbox(
            value: _value,
            onChanged: (v) => setState(() => _value = v),
          ),
        ),
        StreamCheckboxTheme(
          data: StreamCheckboxThemeData(
            style: StreamCheckboxStyle(
              fillColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.purple;
                }
                return Colors.transparent;
              }),
            ),
          ),
          child: StreamCheckbox(
            value: _value,
            onChanged: (v) => setState(() => _value = v),
          ),
        ),
      ],
    );
  }
}

class _CustomShapeDemo extends StatefulWidget {
  const _CustomShapeDemo();

  @override
  State<_CustomShapeDemo> createState() => _CustomShapeDemoState();
}

class _CustomShapeDemoState extends State<_CustomShapeDemo> {
  var _rounded = true;
  var _circle = false;

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Row(
      spacing: spacing.lg,
      children: [
        StreamCheckbox(
          value: _rounded,
          onChanged: (v) => setState(() => _rounded = v),
        ),
        StreamCheckbox.circular(
          value: _circle,
          onChanged: (v) => setState(() => _circle = v),
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
