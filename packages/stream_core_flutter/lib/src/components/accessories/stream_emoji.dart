import 'package:flutter/material.dart';

import '../../../stream_core_flutter.dart';
import '../../factory/stream_component_factory.dart';

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
/// Default size (uses IconTheme or medium):
///
/// ```dart
/// StreamEmoji(emoji: Text('🔥'))
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Use with IconButton (size controlled via iconSize):
///
/// ```dart
/// IconButton(
///   iconSize: 32,  // Size applied to StreamEmoji via IconTheme
///   icon: StreamEmoji(emoji: Text('👍')),
///   onPressed: () {},
/// )
/// ```
/// {@end-tool}
///
/// **Best Practice:** When using `StreamEmoji` inside an `IconButton`, set the
/// size using `IconButton.iconSize` instead of `StreamEmoji.size`. The emoji
/// will automatically inherit the size from the button's `IconTheme`.
///
/// See also:
///
///  * [StreamEmojiSize], which defines the available size variants.
class StreamEmoji extends StatelessWidget {
  /// Creates an emoji display widget.
  StreamEmoji({
    super.key,
    StreamEmojiSize? size,
    required Widget emoji,
  }) : props = .new(size: size, emoji: emoji);

  /// The props controlling the appearance of this emoji.
  final StreamEmojiProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.maybeOf(context)?.emoji;
    if (builder != null) return builder(context, props);
    return DefaultStreamEmoji(props: props);
  }
}

/// Properties for configuring a [StreamEmoji].
///
/// This class holds all the configuration options for an emoji display,
/// allowing them to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamEmoji], which uses these properties.
@immutable
class StreamEmojiProps {
  /// Creates emoji properties.
  const StreamEmojiProps({
    required this.size,
    required this.emoji,
  });

  /// The size of the emoji container.
  ///
  /// If null, uses [IconTheme.of(context).size] if available,
  /// otherwise defaults to [StreamEmojiSize.md] (24px).
  final StreamEmojiSize? size;

  /// The emoji or icon widget to display.
  ///
  /// Typically a [Text] widget containing a Unicode emoji character,
  /// or an [Icon] widget for Material Design icons.
  final Widget emoji;
}

/// Default implementation of [StreamEmoji].
///
/// This is the standard emoji display widget used when no custom builder
/// is provided via [StreamComponentFactory].
///
/// See also:
///
///  * [StreamEmoji], which delegates to this widget by default.
///  * [StreamComponentFactory], for providing custom emoji builders.
class DefaultStreamEmoji extends StatelessWidget {
  /// Creates a default emoji display widget.
  const DefaultStreamEmoji({
    super.key,
    required this.props,
  });

  /// The props controlling the appearance of this emoji.
  final StreamEmojiProps props;

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final effectiveSize = props.size?.value ?? iconTheme.size ?? StreamEmojiSize.md.value;

    return SizedBox(
      width: effectiveSize,
      height: effectiveSize,
      child: Center(
        child: MediaQuery.withNoTextScaling(
          child: FittedBox(
            fit: .scaleDown,
            child: DefaultTextStyle.merge(
              textAlign: .center,
              style: TextStyle(
                height: 1,
                decoration: .none,
                fontSize: effectiveSize,
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
              child: props.emoji,
            ),
          ),
        ),
      ),
    );
  }
}
