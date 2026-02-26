import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:unicode_emojis/unicode_emojis.dart';
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

  return _ReactionPickerPlayground(reactionButtonSize: reactionButtonSize);
}

class _ReactionPickerPlayground extends StatefulWidget {
  const _ReactionPickerPlayground({required this.reactionButtonSize});

  final StreamEmojiButtonSize reactionButtonSize;

  @override
  State<_ReactionPickerPlayground> createState() => _ReactionPickerPlaygroundState();
}

class _ReactionPickerPlaygroundState extends State<_ReactionPickerPlayground> {
  final _selectedReactions = <String, Emoji>{};

  void _toggle(Emoji emoji) {
    setState(() {
      if (_selectedReactions.containsKey(emoji.shortName)) {
        _selectedReactions.remove(emoji.shortName);
      } else {
        _selectedReactions[emoji.shortName] = emoji;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: spacing.md,
        children: [
          StreamButton(
            label: 'Show Reaction Picker',
            onTap: () async {
              final emoji = await StreamReactionPickerSheet.show(
                context: context,
                reactionButtonSize: widget.reactionButtonSize,
                selectedReactions: _selectedReactions.keys.toSet(),
              );
              if (emoji != null && context.mounted) _toggle(emoji);
            },
          ),
          if (_selectedReactions.isNotEmpty) ...[
            Text(
              'Selected Reactions',
              style: textTheme.headingXs.copyWith(
                color: colorScheme.textSecondary,
              ),
            ),
            Wrap(
              spacing: spacing.xs,
              runSpacing: spacing.xs,
              children: [
                for (final entry in _selectedReactions.entries)
                  StreamEmoji(
                    emoji: Text(entry.value.emoji),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
