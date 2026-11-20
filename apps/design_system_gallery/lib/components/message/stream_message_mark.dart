import 'package:flutter/material.dart';
import 'package:stream_core_flutter/chat.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamMessageMark,
  path: '[Components]/Message',
)
Widget buildStreamMessageMarkPlayground(BuildContext context) {
  final label = context.knobs.string(
    label: 'Label',
    initialValue: 'Played by 3',
    description: 'The mark text.',
  );

  final highlighted = context.knobs.boolean(
    label: 'Highlighted',
    initialValue: true,
    description: 'Whether the label uses the accent color.',
  );

  final showSeparator = context.knobs.boolean(
    label: 'Show Separator',
    initialValue: true,
    description: 'Whether a middle dot follows the label.',
  );

  final tappable = context.knobs.boolean(
    label: 'Tappable',
    initialValue: true,
    description: 'Whether the label can be tapped.',
  );

  final mark = StreamMessageMark(
    label: Text(label),
    highlighted: highlighted,
    separator: showSeparator ? StreamMessageMark.separator : null,
    onTap: tappable ? () {} : null,
  );

  return Center(
    child: StreamMessageLayout(
      data: const StreamMessageLayoutData(alignment: StreamMessageAlignment.end),
      child: StreamMessageMetadata(
        timestamp: const Text('09:41'),
        mark: mark,
      ),
    ),
  );
}
