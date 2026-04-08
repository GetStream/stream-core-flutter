import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamToggleSwitch,
  path: '[Components]/Controls',
)
Widget buildStreamToggleSwitchPlayground(BuildContext context) {
  return const _PlaygroundDemo();
}

class _PlaygroundDemo extends StatefulWidget {
  const _PlaygroundDemo();

  @override
  State<_PlaygroundDemo> createState() => _PlaygroundDemoState();
}

class _PlaygroundDemoState extends State<_PlaygroundDemo> {
  var _value = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = context.knobs.boolean(
      label: 'Disabled',
      description: 'When true, the toggle switch does not respond to taps.',
    );

    return Center(
      child: StreamToggleSwitch(
        value: _value,
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
  type: StreamToggleSwitch,
  path: '[Components]/Controls',
)
Widget buildStreamToggleSwitchShowcase(BuildContext context) {
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
          _ThemeCustomizationSection(),
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
                label: 'Off',
                description: 'Default unselected state',
                child: StreamToggleSwitch(value: false, onChanged: (_) {}),
              ),
              Divider(height: 1, color: colorScheme.borderSubtle),
              _StateDemo(
                label: 'On',
                description: 'Selected (active) state',
                child: StreamToggleSwitch(value: true, onChanged: (_) {}),
              ),
              Divider(height: 1, color: colorScheme.borderSubtle),
              _StateDemo(
                label: 'Disabled Off',
                description: 'Non-interactive unselected state',
                child: StreamToggleSwitch(value: false, onChanged: null),
              ),
              Divider(height: 1, color: colorScheme.borderSubtle),
              _StateDemo(
                label: 'Disabled On',
                description: 'Non-interactive selected state',
                child: StreamToggleSwitch(value: true, onChanged: null),
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
          title: 'Toggle Demo',
          description: 'Tap the switches to toggle them',
          child: _ToggleDemo(),
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
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: [
        Row(
          spacing: spacing.md,
          children: [
            StreamToggleSwitch(
              value: _value1,
              onChanged: (v) => setState(() => _value1 = v),
            ),
            Text(
              _value1 ? 'On' : 'Off',
              style: textTheme.captionDefault.copyWith(
                color: colorScheme.textSecondary,
              ),
            ),
          ],
        ),
        Row(
          spacing: spacing.md,
          children: [
            StreamToggleSwitch(
              value: _value2,
              onChanged: (v) => setState(() => _value2 = v),
            ),
            Text(
              _value2 ? 'On' : 'Off',
              style: textTheme.captionDefault.copyWith(
                color: colorScheme.textSecondary,
              ),
            ),
          ],
        ),
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
      spacing: spacing.md,
      children: const [
        _SectionLabel(label: 'THEME CUSTOMIZATION'),
        _ExampleCard(
          title: 'Custom Track Colors',
          description: 'Overriding track colors via StreamToggleSwitchTheme',
          child: _CustomColorsDemo(),
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
  var _green = true;
  var _orange = false;
  var _purple = true;

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Row(
      spacing: spacing.lg,
      children: [
        _themedSwitch(
          color: Colors.green,
          value: _green,
          onChanged: (v) => setState(() => _green = v),
        ),
        _themedSwitch(
          color: Colors.deepOrange,
          value: _orange,
          onChanged: (v) => setState(() => _orange = v),
        ),
        _themedSwitch(
          color: Colors.purple,
          value: _purple,
          onChanged: (v) => setState(() => _purple = v),
        ),
      ],
    );
  }

  Widget _themedSwitch({
    required Color color,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return StreamToggleSwitchTheme(
      data: StreamToggleSwitchThemeData(
        style: StreamToggleSwitchStyle(
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return color;
            return null;
          }),
        ),
      ),
      child: StreamToggleSwitch(
        value: value,
        onChanged: onChanged,
      ),
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
          title: 'Settings List',
          description:
              'Toggle switches used in a settings list — a typical usage '
              'pattern for this component.',
          child: _SettingsExample(),
        ),
      ],
    );
  }
}

class _SettingsExample extends StatefulWidget {
  const _SettingsExample();

  @override
  State<_SettingsExample> createState() => _SettingsExampleState();
}

class _SettingsExampleState extends State<_SettingsExample> {
  var _notifications = true;
  var _darkMode = false;
  var _sounds = true;

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
          _SettingsRow(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            value: _notifications,
            onChanged: (v) => setState(() => _notifications = v),
          ),
          Divider(height: 1, color: colorScheme.borderSubtle),
          _SettingsRow(
            icon: Icons.dark_mode_outlined,
            label: 'Dark Mode',
            value: _darkMode,
            onChanged: (v) => setState(() => _darkMode = v),
          ),
          Divider(height: 1, color: colorScheme.borderSubtle),
          _SettingsRow(
            icon: Icons.volume_up_outlined,
            label: 'Sounds',
            value: _sounds,
            onChanged: (v) => setState(() => _sounds = v),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

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
        spacing: spacing.sm,
        children: [
          Icon(icon, size: 20, color: colorScheme.textSecondary),
          Expanded(
            child: Text(
              label,
              style: textTheme.bodyDefault.copyWith(
                color: colorScheme.textPrimary,
              ),
            ),
          ),
          StreamToggleSwitch(
            value: value,
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
