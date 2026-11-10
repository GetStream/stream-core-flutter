// ignore_for_file: experimental_member_use

import 'package:flutter/material.dart';
import 'package:stream_core_flutter/video.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamAdaptiveMenuAnchor,
  path: '[Components]/Context Menu',
)
Widget buildStreamAdaptiveMenuAnchorPlayground(BuildContext context) {
  final presentation = context.knobs.object.dropdown(
    label: 'Presentation',
    options: _Presentation.values,
    initialOption: _Presentation.platform,
    labelBuilder: (option) => option.label,
    description: 'Follow the platform (a sheet on Android and iOS), or force one presentation through useSheet.',
  );

  final anchor = context.knobs.object.dropdown(
    label: 'Anchor',
    options: _AnchorKind.values,
    initialOption: _AnchorKind.caret,
    labelBuilder: (option) => option.label,
    description: 'A caret button sizes the menu to its content; a field uses matchAnchorWidth.',
  );

  final direction = context.knobs.object.dropdown(
    label: 'Direction',
    options: StreamMenuDirection.values,
    initialOption: StreamMenuDirection.down,
    labelBuilder: (option) => option.name,
    description: 'Which side of the anchor the menu clears, and which way the caret points.',
  );

  final showHeadings = context.knobs.boolean(
    label: 'Section Headings',
    initialValue: true,
    description: 'Label each section with a StreamContextMenuHeading.',
  );

  final collapsible = context.knobs.boolean(
    label: 'Collapsible Section',
    initialValue: true,
    description: 'Fold the speaker section behind its heading. Needs headings.',
  );

  final showContent = context.knobs.boolean(
    label: 'Content Section',
    initialValue: true,
    description: 'Add a section drawn by its content builder rather than as rows.',
  );

  final showToggle = context.knobs.boolean(
    label: 'Toggle Row',
    initialValue: true,
    description: 'Add a row with a trailing value that keeps the menu open (closesMenu: false).',
  );

  final elevation = context.knobs.double.slider(
    label: 'Menu Elevation',
    initialValue: 3,
    max: 12,
    divisions: 12,
    description: 'How high the anchored menu floats. The sheet ignores it.',
  );

  return Align(
    alignment: direction == StreamMenuDirection.up ? Alignment.bottomCenter : Alignment.topCenter,
    child: Padding(
      padding: EdgeInsets.all(context.streamSpacing.xl),
      child: _DeviceMenu(
        useSheet: presentation.useSheet,
        anchor: anchor,
        direction: direction,
        showHeadings: showHeadings,
        collapsible: collapsible,
        showContent: showContent,
        showToggle: showToggle,
        menuElevation: elevation,
      ),
    ),
  );
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamAdaptiveMenuAnchor,
  path: '[Components]/Context Menu',
)
Widget buildStreamAdaptiveMenuAnchorShowcase(BuildContext context) {
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
          _ExampleCard(
            title: 'Anchored menu',
            description: 'The desktop and web presentation: dense rows, headings lined up with them.',
            child: _DeviceMenu(useSheet: false, anchor: _AnchorKind.caret),
          ),
          _ExampleCard(
            title: 'Sheet',
            description: 'The Android and iOS presentation: the same sections as list tiles in a bottom sheet.',
            child: _DeviceMenu(useSheet: true, anchor: _AnchorKind.caret),
          ),
          _ExampleCard(
            title: 'Full-width field',
            description: 'matchAnchorWidth makes the anchored menu exactly as wide as the field it hangs off.',
            child: _DeviceMenu(useSheet: false, anchor: _AnchorKind.field),
          ),
          _ExampleCard(
            title: 'Opening upwards',
            description: 'StreamMenuDirection.up, as a toolbar along the bottom of the screen does.',
            child: _DeviceMenu(useSheet: false, anchor: _AnchorKind.caret, direction: StreamMenuDirection.up),
          ),
        ],
      ),
    ),
  );
}

// =============================================================================
// Shared
// =============================================================================

enum _Presentation {
  platform('Follow platform'),
  sheet('Sheet', useSheet: true),
  anchored('Anchored menu', useSheet: false);

  const _Presentation(this.label, {this.useSheet});

  final String label;
  final bool? useSheet;
}

enum _AnchorKind {
  caret('Caret button'),
  field('Full-width field');

  const _AnchorKind(this.label);

  final String label;
}

const _microphones = ['Built-in microphone', 'External microphone', 'Headset microphone'];
const _speakers = ['Built-in speakers', 'Headphones'];
const _reactions = ['👍', '🎉', '❤️', '😂'];

class _DeviceMenu extends StatefulWidget {
  const _DeviceMenu({
    required this.useSheet,
    required this.anchor,
    this.direction = StreamMenuDirection.down,
    this.showHeadings = true,
    this.collapsible = true,
    this.showContent = true,
    this.showToggle = true,
    this.menuElevation,
  });

  final bool? useSheet;
  final _AnchorKind anchor;
  final StreamMenuDirection direction;
  final bool showHeadings;
  final bool collapsible;
  final bool showContent;
  final bool showToggle;
  final double? menuElevation;

  @override
  State<_DeviceMenu> createState() => _DeviceMenuState();
}

class _DeviceMenuState extends State<_DeviceMenu> {
  var _microphone = _microphones.first;
  var _speaker = _speakers.first;
  var _noiseCancellation = true;
  String? _reaction;

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    final sections = [
      StreamMenuSection(
        heading: widget.showHeadings ? 'Microphone' : null,
        options: [
          for (final microphone in _microphones)
            StreamMenuOption(
              label: microphone,
              selected: microphone == _microphone,
              onSelected: () => setState(() => _microphone = microphone),
            ),
        ],
      ),
      StreamMenuSection(
        heading: widget.showHeadings ? 'Speaker' : null,
        collapsible: widget.collapsible,
        options: [
          for (final speaker in _speakers)
            StreamMenuOption(
              label: speaker,
              selected: speaker == _speaker,
              onSelected: () => setState(() => _speaker = speaker),
            ),
        ],
      ),
      if (widget.showToggle)
        StreamMenuSection(
          options: [
            StreamMenuOption(
              label: 'Noise cancellation',
              trailing: Text(_noiseCancellation ? 'On' : 'Off'),
              closesMenu: false,
              onSelected: () => setState(() => _noiseCancellation = !_noiseCancellation),
            ),
          ],
        ),
      if (widget.showContent)
        StreamMenuSection(
          heading: widget.showHeadings ? 'Reactions' : null,
          content: (context, handle) => Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.xs, vertical: spacing.xxs),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: spacing.xxs,
              children: [
                for (final reaction in _reactions)
                  StreamButton.icon(
                    icon: Text(reaction),
                    type: StreamButtonType.ghost,
                    style: StreamButtonStyle.secondary,
                    size: StreamButtonSize.small,
                    onPressed: () {
                      setState(() => _reaction = reaction);
                      handle.close();
                    },
                  ),
              ],
            ),
          ),
        ),
    ];

    return StreamAdaptiveMenuAnchor(
      title: 'Devices',
      useSheet: widget.useSheet,
      direction: widget.direction,
      matchAnchorWidth: widget.anchor == _AnchorKind.field,
      menuElevation: widget.menuElevation,
      sections: sections,
      builder: (context, handle) => switch (widget.anchor) {
        _AnchorKind.caret => _CaretButton(
          handle: handle,
          direction: widget.direction,
          label: _reaction == null ? 'Devices' : 'Devices $_reaction',
          enabled: !sections.hasNoOptions,
        ),
        _AnchorKind.field => _Field(handle: handle, direction: widget.direction, value: _microphone),
      },
    );
  }
}

// Points the caret the way the menu opens, and flips it while the menu is up.
IconData _caret(BuildContext context, StreamMenuHandle handle, StreamMenuDirection direction) {
  final icons = context.streamIcons;
  final pointsUp = (direction == StreamMenuDirection.up) != handle.isOpen;
  return pointsUp ? icons.chevronUp : icons.chevronDown;
}

class _CaretButton extends StatelessWidget {
  const _CaretButton({required this.handle, required this.direction, required this.label, required this.enabled});

  final StreamMenuHandle handle;
  final StreamMenuDirection direction;
  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return StreamButton(
      type: StreamButtonType.outline,
      style: StreamButtonStyle.secondary,
      iconRight: Icon(_caret(context, handle, direction)),
      onPressed: enabled ? handle.toggle : null,
      child: Text(label),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.handle, required this.direction, required this.value});

  final StreamMenuHandle handle;
  final StreamMenuDirection direction;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(radius.md),
      side: BorderSide(color: handle.isOpen ? colorScheme.borderFocus : colorScheme.borderDefault),
    );

    return SizedBox(
      width: 360,
      child: Material(
        shape: shape,
        color: colorScheme.backgroundElevation1,
        child: InkWell(
          customBorder: shape,
          onTap: handle.toggle,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.sm, vertical: spacing.xs),
            child: Row(
              spacing: spacing.xs,
              children: [
                Expanded(
                  child: Text(value, style: textTheme.bodyDefault.copyWith(color: colorScheme.textPrimary)),
                ),
                Icon(_caret(context, handle, direction), size: 20, color: colorScheme.textSecondary),
              ],
            ),
          ),
        ),
      ),
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
          Padding(
            padding: EdgeInsets.all(spacing.md),
            child: Align(alignment: AlignmentDirectional.centerStart, child: child),
          ),
        ],
      ),
    );
  }
}
