import 'package:flutter/material.dart';

/// Predefined sizes for emoji display.
///
/// Each size corresponds to a specific dimension in logical pixels,
/// optimized for rendering emoji at common scales.
///
/// See also:
///
///  * [StreamEmoji], which uses these size variants.
enum StreamEmojiSize {
  /// Small emoji (16px).
  sm(16),

  /// Medium emoji (24px).
  md(24),

  /// Large emoji (32px).
  lg(32),

  /// Extra large emoji (48px).
  xl(48),

  /// Extra extra large emoji (64px).
  xxl(64)
  ;

  /// Constructs a [StreamEmojiSize] with the given dimension.
  const StreamEmojiSize(this.value);

  /// The dimension of the emoji in logical pixels.
  final double value;
}

/// A widget that displays an emoji or icon at a consistent size.
///
/// [StreamEmoji] renders emoji characters or icon widgets within a fixed
/// square container. It handles platform-specific emoji font fallbacks,
/// prevents text scaling, and ensures emoji render without clipping.
///
/// The widget accepts any [Widget] as the [emoji] parameter, making it
/// suitable for both Unicode emoji text and Material Icons.
///
/// {@tool snippet}
///
/// Display a Unicode emoji:
///
/// ```dart
/// StreamEmoji(
///   size: StreamEmojiSize.lg,
///   emoji: Text('👍'),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Display a Material Icon:
///
/// ```dart
/// StreamEmoji(
///   size: StreamEmojiSize.md,
///   emoji: Icon(Icons.favorite),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Default size (medium):
///
/// ```dart
/// StreamEmoji(emoji: Text('🔥'))
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamEmojiSize], which defines the available size variants.
class StreamEmoji extends StatelessWidget {
  /// Creates an emoji display widget.
  ///
  /// The [emoji] parameter is required and can be any widget (typically
  /// [Text] for emoji characters or [Icon] for Material icons).
  ///
  /// If [size] is not provided, defaults to [StreamEmojiSize.md].
  const StreamEmoji({
    super.key,
    this.size = .md,
    required this.emoji,
  });

  /// The size of the emoji container.
  ///
  /// Determines the width and height of the square container.
  /// Defaults to [StreamEmojiSize.md] (24px).
  final StreamEmojiSize size;

  /// The emoji or icon widget to display.
  ///
  /// Typically a [Text] widget containing a Unicode emoji character,
  /// or an [Icon] widget for Material Design icons.
  final Widget emoji;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.value,
      height: size.value,
      child: Center(
        child: MediaQuery.withNoTextScaling(
          child: FittedBox(
            fit: .scaleDown,
            child: DefaultTextStyle.merge(
              textAlign: .center,
              style: TextStyle(
                fontSize: size.value,
                height: 1,
                // Commonly available fallback fonts for emoji rendering.
                fontFamilyFallback: const [
                  'Apple Color Emoji', // iOS and macOS.
                  'Noto Color Emoji', // Android, ChromeOS, Ubuntu, Linux.
                  'Segoe UI Emoji', // Windows.
                ],
              ),
              textHeightBehavior: const TextHeightBehavior(
                applyHeightToFirstAscent: false,
                applyHeightToLastDescent: false,
              ),
              child: emoji,
            ),
          ),
        ),
      ),
    );
  }
}
