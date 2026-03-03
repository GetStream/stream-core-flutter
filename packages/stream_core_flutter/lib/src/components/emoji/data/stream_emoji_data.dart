import 'package:flutter/foundation.dart';

/// A data class representing a single emoji entry.
///
/// Used by the emoji picker and reaction system to provide a curated,
/// self-contained set of emojis without relying on external packages.
///
/// {@tool snippet}
///
/// ```dart
/// const emoji = StreamEmojiData(
///   name: 'grinning face',
///   emoji: '😀',
///   shortName: 'grinning',
///   shortNames: ['grinning'],
///   sortOrder: 1,
/// );
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [streamSupportedEmojis], a curated map of commonly used emojis.
///  * [StreamEmojiPickerSheet], which displays emojis in a picker grid.
@immutable
class StreamEmojiData {
  /// Creates an emoji data entry.
  const StreamEmojiData({
    required this.name,
    required this.emoji,
    required this.shortName,
    required this.shortNames,
    required this.sortOrder,
  });

  /// The human-readable name of the emoji (e.g., "Grinning Face").
  final String name;

  /// The emoji character itself (e.g., "😀").
  final String emoji;

  /// The canonical short name used as a reaction type identifier
  /// (e.g., "grinning").
  final String shortName;

  /// All known short name aliases for this emoji, including [shortName].
  final List<String> shortNames;

  /// The sort order for display purposes, matching the Unicode CLDR ordering.
  final int sortOrder;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StreamEmojiData && runtimeType == other.runtimeType && shortName == other.shortName;

  @override
  int get hashCode => shortName.hashCode;

  @override
  String toString() => 'StreamEmojiData($shortName, $emoji)';
}
