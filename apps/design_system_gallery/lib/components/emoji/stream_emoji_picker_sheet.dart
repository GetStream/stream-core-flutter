import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamEmojiPickerSheet,
  path: '[Components]/Emoji',
)
Widget buildStreamEmojiPickerSheetDefault(BuildContext context) {
  final emojiButtonSize = context.knobs.object.dropdown(
    label: 'Emoji Button Size',
    options: StreamEmojiButtonSize.values,
    initialOption: StreamEmojiButtonSize.xl,
    labelBuilder: (option) => option.name,
    description: 'The size of each emoji button in the grid.',
  );

  return _EmojiPickerPlayground(emojiButtonSize: emojiButtonSize);
}

class _EmojiPickerPlayground extends StatefulWidget {
  const _EmojiPickerPlayground({required this.emojiButtonSize});

  final StreamEmojiButtonSize emojiButtonSize;

  @override
  State<_EmojiPickerPlayground> createState() => _EmojiPickerPlaygroundState();
}

class _EmojiPickerPlaygroundState extends State<_EmojiPickerPlayground> {
  final _selectedEmojis = <String, StreamEmojiData>{};

  void _toggle(StreamEmojiData emoji) {
    setState(() {
      if (_selectedEmojis.containsKey(emoji.shortName)) {
        _selectedEmojis.remove(emoji.shortName);
      } else {
        _selectedEmojis[emoji.shortName] = emoji;
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
            label: 'Show Emoji Picker',
            onTap: () async {
              final emoji = await StreamEmojiPickerSheet.show(
                context: context,
                emojiButtonSize: widget.emojiButtonSize,
                selectedReactions: _selectedEmojis.keys.toSet(),
              );
              if (emoji != null && context.mounted) _toggle(emoji);
            },
          ),
          if (_selectedEmojis.isNotEmpty) ...[
            Text(
              'Selected Emojis',
              style: textTheme.headingXs.copyWith(
                color: colorScheme.textSecondary,
              ),
            ),
            Wrap(
              spacing: spacing.xs,
              runSpacing: spacing.xs,
              children: [
                for (final entry in _selectedEmojis.entries) StreamEmoji(emoji: Text(entry.value.emoji)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
