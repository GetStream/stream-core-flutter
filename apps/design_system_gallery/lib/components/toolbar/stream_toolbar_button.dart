import 'package:flutter/material.dart';
import 'package:stream_core_flutter/core.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamToolbarButton,
  path: '[Components]/Toolbar',
)
Widget buildStreamToolbarButtonPlayground(BuildContext context) {
  final surfaceStyle = context.knobs.object.dropdown(
    label: 'Toolbar surface style',
    options: StreamSurfaceStyle.values,
    labelBuilder: (value) => value.name,
    initialOption: StreamSurfaceStyle.floating,
    description:
        'The enclosing toolbar style, published via StreamToolbarScope. '
        'floating → outlined + elevated; regular → ghost.',
  );

  final label = context.knobs.stringOrNull(
    label: 'Label',
    initialValue: 'Edit',
    description: 'Text for a labelled button. Clear to show the icon-only variant.',
  );

  final enabled = context.knobs.boolean(
    label: 'Enabled',
    initialValue: true,
    description: 'When off, the button is rendered disabled (onPressed null).',
  );

  final onPressed = enabled ? () {} : null;

  final Widget button = (label != null && label.isNotEmpty)
      ? StreamToolbarButton(onPressed: onPressed, child: Text(label))
      : StreamToolbarButton.icon(
          icon: Icon(context.streamIcons.checkmark),
          tooltip: 'Confirm',
          onPressed: onPressed,
        );

  // The button resolves its look from the enclosing StreamToolbarScope — the
  // same scope an app bar / bottom app bar publishes to its slots.
  return StreamToolbarScope(
    surfaceStyle: surfaceStyle,
    child: Center(child: button),
  );
}

// =============================================================================
// Real-world Example
// =============================================================================

@widgetbook.UseCase(
  name: 'Real-world Example',
  type: StreamToolbarButton,
  path: '[Components]/Toolbar',
)
Widget buildStreamToolbarButtonRealWorld(BuildContext context) {
  final colorScheme = context.streamColorScheme;

  // A floating app bar with a trailing StreamToolbarButton — the button picks
  // up the bar's floating look automatically through the toolbar scope.
  return ColoredBox(
    color: colorScheme.backgroundApp,
    child: Align(
      alignment: Alignment.topCenter,
      child: StreamAppBar(
        style: const StreamAppBarStyle(surfaceStyle: StreamSurfaceStyle.floating),
        title: const Text('Profile'),
        trailing: StreamToolbarButton(
          onPressed: () {},
          child: const Text('Edit'),
        ),
      ),
    ),
  );
}
