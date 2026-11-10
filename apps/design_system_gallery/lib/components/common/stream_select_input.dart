// ignore_for_file: experimental_member_use

import 'package:flutter/material.dart';
import 'package:stream_core_flutter/video.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const _languages = ['English', 'Dutch', 'German', 'Spanish', 'Japanese'];

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamSelectInput,
  path: '[Components]/Common',
)
Widget buildStreamSelectInputPlayground(BuildContext context) {
  final icons = context.streamIcons;
  final spacing = context.streamSpacing;

  final type = context.knobs.object.dropdown<StreamSelectInputType>(
    label: 'Type',
    options: StreamSelectInputType.values,
    initialOption: StreamSelectInputType.outline,
    labelBuilder: (option) => option.name,
    description: 'Whether the field is bordered.',
  );

  final labelText = context.knobs.stringOrNull(
    label: 'Label Text',
    initialValue: 'Language',
    description: 'Persistent label rendered above the field.',
  );

  final value = context.knobs.stringOrNull(
    label: 'Value',
    initialValue: 'English',
    description: 'The current selection. Clear it to show the hint.',
  );

  final hintText = context.knobs.string(
    label: 'Hint Text',
    initialValue: 'Choose a language',
    description: 'Shown while nothing is selected.',
  );

  final showLeading = context.knobs.boolean(
    label: 'Show Leading Icon',
    description: 'Whether to show an icon before the value.',
  );

  final expanded = context.knobs.boolean(
    label: 'Expanded',
    description: 'Whether the menu is open: active border and caret up.',
  );

  final helperText = context.knobs.stringOrNull(
    label: 'Helper Text',
    description: 'Message displayed below the field.',
  );

  final helperState = context.knobs.object.dropdown<StreamHelperState>(
    label: 'Helper State',
    options: StreamHelperState.values,
    labelBuilder: (option) => option.name,
    description: 'Error also draws the error border, with or without helper text.',
  );

  final isDisabled = context.knobs.boolean(
    label: 'Disabled',
    description: 'When true, onPressed is null and the field ignores input.',
  );

  return Center(
    child: Padding(
      padding: EdgeInsets.all(spacing.lg),
      child: SizedBox(
        width: 320,
        child: StreamSelectInput(
          type: type,
          labelText: labelText,
          value: value,
          hintText: hintText,
          leading: showLeading ? Icon(icons.language) : null,
          expanded: expanded,
          helperText: helperText,
          helperState: helperState,
          onPressed: isDisabled ? null : () {},
        ),
      ),
    ),
  );
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamSelectInput,
  path: '[Components]/Common',
)
Widget buildStreamSelectInputShowcase(BuildContext context) {
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
          for (final type in StreamSelectInputType.values) ...[
            _Section(
              label: type.name.toUpperCase(),
              caption: 'Every state of the ${type.name} type',
              children: [
                StreamSelectInput(type: type, hintText: 'Placeholder', onPressed: () {}),
                StreamSelectInput(type: type, value: 'English', onPressed: () {}),
                StreamSelectInput(type: type, value: 'English', expanded: true, onPressed: () {}),
                StreamSelectInput(
                  type: type,
                  value: 'English',
                  helperText: 'This language is no longer available',
                  helperState: StreamHelperState.error,
                  onPressed: () {},
                ),
                StreamSelectInput(type: type, value: 'English'),
              ],
            ),
            SizedBox(height: spacing.xl),
          ],
          const _Section(
            label: 'WITH A MENU',
            caption: 'The field opens a menu; expanded follows whether it is showing',
            children: [_MenuDemo()],
          ),
          SizedBox(height: spacing.xl),
          _Section(
            label: 'IN A FORM',
            caption: 'The density matches StreamTextInput, so the two line up',
            children: [
              StreamTextInput(labelText: 'Name', hintText: 'Your name'),
              StreamSelectInput(labelText: 'Language', hintText: 'Choose a language', onPressed: () {}),
            ],
          ),
        ],
      ),
    ),
  );
}

class _MenuDemo extends StatefulWidget {
  const _MenuDemo();

  @override
  State<_MenuDemo> createState() => _MenuDemoState();
}

class _MenuDemoState extends State<_MenuDemo> {
  String? _selected;
  var _open = false;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      onOpen: () => setState(() => _open = true),
      onClose: () => setState(() => _open = false),
      menuChildren: [
        for (final language in _languages)
          MenuItemButton(
            onPressed: () => setState(() => _selected = language),
            child: Text(language),
          ),
      ],
      builder: (context, controller, child) => StreamSelectInput(
        labelText: 'Language',
        hintText: 'Choose a language',
        value: _selected,
        expanded: _open,
        onPressed: () => controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }
}

// =============================================================================
// Shared Widgets
// =============================================================================

class _Section extends StatelessWidget {
  const _Section({required this.label, required this.caption, required this.children});

  final String label;
  final String caption;
  final List<Widget> children;

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
          constraints: const BoxConstraints(maxWidth: 400),
          padding: EdgeInsets.all(spacing.md),
          decoration: BoxDecoration(
            color: colorScheme.backgroundElevation1,
            borderRadius: BorderRadius.all(radius.lg),
            boxShadow: boxShadow.elevation1,
            border: Border.all(color: colorScheme.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: spacing.md,
            children: [
              Text(caption, style: textTheme.captionDefault.copyWith(color: colorScheme.textSecondary)),
              ...children,
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
