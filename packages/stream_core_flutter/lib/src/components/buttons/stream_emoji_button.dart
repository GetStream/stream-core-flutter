import 'package:flutter/material.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_emoji_button_theme.dart';
import '../../theme/primitives/stream_colors.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/stream_theme_extensions.dart';
import '../accessories/stream_emoji.dart';

/// A tappable circular button that displays an emoji or icon.
///
/// Used within reaction pickers and other emoji selectors to render
/// individual emoji options with consistent sizing and styling.
///
/// The button adapts its appearance based on interaction state (hover,
/// pressed, disabled, selected, focused). All states can be customized
/// via [StreamEmojiButtonTheme].
///
/// The button size can be controlled via [size] or globally through
/// the theme.
///
/// {@tool snippet}
///
/// Display an emoji button:
///
/// ```dart
/// StreamEmojiButton(
///   emoji: Text('👍'),
///   onPressed: () => print('thumbs up selected'),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Display a selected emoji button:
///
/// ```dart
/// StreamEmojiButton(
///   emoji: Text('❤️'),
///   isSelected: true,
///   onPressed: () => print('heart selected'),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// With long press for skin tone variants:
///
/// ```dart
/// StreamEmojiButton(
///   emoji: Text('👍'),
///   onPressed: () => addReaction('👍'),
///   onLongPress: () => showSkinTonePicker('👍'),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamEmojiButtonTheme], for customizing emoji button appearance.
///  * [StreamEmojiButtonSize], for available size variants.
///  * [StreamEmoji], the component used to render the emoji.
class StreamEmojiButton extends StatelessWidget {
  /// Creates an emoji button.
  StreamEmojiButton({
    super.key,
    StreamEmojiButtonSize? size,
    required Widget emoji,
    VoidCallback? onPressed,
    VoidCallback? onLongPress,
    bool? isSelected,
  }) : props = .new(
         size: size,
         emoji: emoji,
         onPressed: onPressed,
         onLongPress: onLongPress,
         isSelected: isSelected,
       );

  /// The props controlling the appearance and behavior of this emoji button.
  final StreamEmojiButtonProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.maybeOf(context)?.emojiButton;
    if (builder != null) return builder(context, props);
    return DefaultStreamEmojiButton(props: props);
  }
}

/// Properties for configuring a [StreamEmojiButton].
///
/// This class holds all the configuration options for an emoji button,
/// allowing them to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamEmojiButton], which uses these properties.
///  * [DefaultStreamEmojiButton], the default implementation.
class StreamEmojiButtonProps {
  /// Creates properties for an emoji button.
  const StreamEmojiButtonProps({
    this.size,
    required this.emoji,
    this.onPressed,
    this.onLongPress,
    this.isSelected,
  });

  /// The size of the emoji button.
  ///
  /// If null, falls back to [StreamEmojiButtonThemeStyle.size], then
  /// [StreamEmojiButtonSize.xl].
  final StreamEmojiButtonSize? size;

  /// The emoji or icon widget to display.
  final Widget emoji;

  /// Called when the emoji button is pressed.
  ///
  /// If null, the button will be disabled.
  final VoidCallback? onPressed;

  /// Called when the emoji button is long-pressed.
  ///
  /// Commonly used to show skin tone variants or emoji details.
  final VoidCallback? onLongPress;

  /// Whether the button is in a selected state.
  ///
  /// When true, the button displays selected styling.
  /// When false or null, the button is not selected.
  final bool? isSelected;
}

/// Default implementation of [StreamEmojiButton].
///
/// Renders the emoji using [StreamEmoji] with theme-aware styling and
/// state-based visual feedback.
class DefaultStreamEmojiButton extends StatelessWidget {
  /// Creates a default emoji button.
  const DefaultStreamEmojiButton({super.key, required this.props});

  /// The props controlling the appearance and behavior of this emoji button.
  final StreamEmojiButtonProps props;

  @override
  Widget build(BuildContext context) {
    final emojiButtonStyle = context.streamEmojiButtonTheme.style;
    final defaults = _StreamEmojiButtonThemeDefaults(context);

    final effectiveSize = props.size ?? emojiButtonStyle?.size ?? defaults.size;
    final effectiveBackgroundColor = emojiButtonStyle?.backgroundColor ?? defaults.backgroundColor;
    final effectiveForegroundColor = emojiButtonStyle?.foregroundColor ?? defaults.foregroundColor;
    final effectiveOverlayColor = emojiButtonStyle?.overlayColor ?? defaults.overlayColor;
    final effectiveSide = emojiButtonStyle?.side ?? defaults.side;

    final emojiSize = _emojiSizeForButtonSize(effectiveSize);

    return IconButton(
      onPressed: props.onPressed,
      onLongPress: props.onLongPress,
      isSelected: props.isSelected,
      iconSize: emojiSize.value,
      icon: StreamEmoji(emoji: props.emoji),
      style: ButtonStyle(
        fixedSize: .all(.square(effectiveSize.value)),
        minimumSize: .all(.square(effectiveSize.value)),
        maximumSize: .all(.square(effectiveSize.value)),
        padding: .all(EdgeInsets.zero),
        shape: .all(const CircleBorder()),
        backgroundColor: effectiveBackgroundColor,
        foregroundColor: effectiveForegroundColor,
        overlayColor: effectiveOverlayColor,
        side: effectiveSide,
      ),
    );
  }

  // Returns the appropriate emoji size for the given button size.
  StreamEmojiSize _emojiSizeForButtonSize(
    StreamEmojiButtonSize buttonSize,
  ) => switch (buttonSize) {
    .md => StreamEmojiSize.md,
    .lg => StreamEmojiSize.md,
    .xl => StreamEmojiSize.lg,
  };
}

// Provides default values for [StreamEmojiButtonThemeStyle] based on
// the current [StreamColorScheme].
class _StreamEmojiButtonThemeDefaults extends StreamEmojiButtonThemeStyle {
  _StreamEmojiButtonThemeDefaults(
    this.context,
  ) : _colorScheme = context.streamColorScheme;

  final BuildContext context;
  final StreamColorScheme _colorScheme;

  @override
  StreamEmojiButtonSize get size => StreamEmojiButtonSize.xl;

  @override
  WidgetStateProperty<Color?> get backgroundColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return StreamColors.transparent;
    if (states.contains(WidgetState.selected)) return _colorScheme.stateSelected;
    return StreamColors.transparent;
  });

  @override
  WidgetStateProperty<Color?> get foregroundColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return _colorScheme.stateDisabled;
    return null; // Let emoji/icon use its natural color
  });

  @override
  WidgetStateProperty<Color?> get overlayColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.pressed)) return _colorScheme.statePressed;
    if (states.contains(WidgetState.hovered)) return _colorScheme.stateHover;
    return StreamColors.transparent;
  });

  @override
  WidgetStateBorderSide? get side => WidgetStateBorderSide.resolveWith((states) {
    if (states.contains(WidgetState.focused)) {
      return BorderSide(
        width: 2,
        color: _colorScheme.borderFocus,
        strokeAlign: BorderSide.strokeAlignOutside,
      );
    }
    return BorderSide.none;
  });
}
