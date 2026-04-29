import 'package:flutter/material.dart';

import '../../components.dart';

import '../../theme/components/stream_emoji_button_theme.dart';
import '../../theme/components/stream_sheet_theme.dart';
import '../../theme/stream_theme_extensions.dart';

const _kGridCrossAxisCount = 7;

/// A scrollable sheet that displays a curated set of emojis in a flat grid.
///
/// The recommended way to display the picker is via the [show] method,
/// which presents it as a modal bottom sheet and returns the selected emoji.
///
/// The emoji buttons are styled using [StreamEmojiButtonTheme].
///
/// {@tool snippet}
///
/// ```dart
/// final emoji = await StreamEmojiPickerSheet.show(
///   context: context,
/// );
/// if (emoji != null) {
///   sendReaction(emoji);
/// }
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamEmojiButton], which displays individual emoji options.
///  * [StreamEmojiButtonSize], which defines button size variants.
///  * [StreamEmojiData], the data model for each emoji entry.
///  * [streamSupportedEmojis], the default set of emojis shown.
class StreamEmojiPickerSheet extends StatelessWidget {
  /// Creates an emoji picker sheet.
  const StreamEmojiPickerSheet._({
    required this.scrollController,
    required this.emojis,
    this.emojiButtonSize,
    this.selectedReactions,
  });

  /// The size of each emoji button in the grid.
  ///
  /// Defaults to [StreamEmojiButtonSize.xl].
  final StreamEmojiButtonSize? emojiButtonSize;

  /// The set of emoji short names that are currently selected.
  ///
  /// When non-null, emojis whose [StreamEmojiData.shortName] is contained in
  /// this set are rendered in the selected state.
  final Set<String>? selectedReactions;

  /// The scroll controller for the emoji grid.
  final ScrollController scrollController;

  /// The emojis to display in the grid.
  final Iterable<StreamEmojiData> emojis;

  /// Shows the emoji picker as a modal bottom sheet.
  ///
  /// Returns the selected [StreamEmojiData], or `null` if dismissed.
  ///
  /// Visual defaults (background color, border radius) are pulled from
  /// the ambient [StreamSheetTheme] so the picker matches the look of
  /// other Stream-styled sheets.
  static Future<StreamEmojiData?> show({
    required BuildContext context,
    Iterable<StreamEmojiData>? emojis,
    StreamEmojiButtonSize? emojiButtonSize,
    Set<String>? selectedReactions,
    Color? backgroundColor,
  }) {
    final radius = context.streamRadius;
    final colorScheme = context.streamColorScheme;
    final sheetTheme = StreamSheetTheme.of(context);

    final effectiveEmojis = emojis ?? streamSupportedEmojis.values;
    final effectiveBackgroundColor = backgroundColor ?? sheetTheme.backgroundColor ?? colorScheme.backgroundElevation1;
    final effectiveBorderRadius = sheetTheme.borderRadius ?? BorderRadius.vertical(top: radius.xxxxl);

    return showModalBottomSheet<StreamEmojiData>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: effectiveBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: effectiveBorderRadius),
      builder: (context) => DraggableScrollableSheet(
        snap: true,
        expand: false,
        minChildSize: 0.5,
        snapSizes: const [0.5, 1],
        builder: (_, scrollController) => StreamEmojiPickerSheet._(
          scrollController: scrollController,
          emojis: effectiveEmojis,
          emojiButtonSize: emojiButtonSize,
          selectedReactions: selectedReactions,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    final effectiveButtonSize = emojiButtonSize ?? StreamEmojiButtonSize.xl;

    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: spacing.md),
          sliver: SliverGrid.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _kGridCrossAxisCount,
              mainAxisSpacing: spacing.xxxs,
              crossAxisSpacing: spacing.xxxs,
              mainAxisExtent: effectiveButtonSize.value,
            ),
            itemCount: emojis.length,
            itemBuilder: (context, index) {
              final emoji = emojis.elementAt(index);
              return StreamEmojiButton(
                size: effectiveButtonSize,
                emoji: StreamUnicodeEmoji(emoji.emoji),
                isSelected: selectedReactions?.contains(emoji.shortName),
                onPressed: () => Navigator.of(context).pop(emoji),
              );
            },
          ),
        ),
      ],
    );
  }
}
