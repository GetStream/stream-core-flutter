import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamReactionPickerSheet,
  path: '[Components]/Reaction',
)
Widget buildStreamReactionPickerSheetDefault(BuildContext context) {
  final reactionButtonSize = context.knobs.object.dropdown(
    label: 'Reaction Button Size',
    options: StreamEmojiButtonSize.values,
    initialOption: StreamEmojiButtonSize.xl,
    labelBuilder: (option) => option.name,
    description: 'The size of each reaction button in the grid.',
  );

  return Center(
    child: StreamButton(
      label: 'Show Reaction Picker',
      onTap: () async {
        final emoji = await StreamReactionPickerSheet.show(
          context: context,
          reactionButtonSize: reactionButtonSize,
        );
        if (emoji != null && context.mounted) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text('Selected ${emoji.emoji}  ${emoji.name}'),
                duration: const Duration(seconds: 2),
              ),
            );
        }
      },
    ),
  );
}
