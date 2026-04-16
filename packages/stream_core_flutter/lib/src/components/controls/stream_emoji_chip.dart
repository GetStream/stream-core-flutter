import 'package:flutter/material.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_emoji_chip_theme.dart';
import '../../theme/primitives/stream_colors.dart';
import '../../theme/stream_theme_extensions.dart';
import '../accessories/stream_emoji.dart';

/// A pill-shaped chip for displaying emoji reactions with an optional count.
///
/// [StreamEmojiChip] renders one or more emojis alongside an optional reaction
/// count. Use the default constructor for a single-emoji chip, [StreamEmojiChip.cluster]
/// for a multi-emoji chip, and [StreamEmojiChip.addEmoji] for the add-reaction
/// button variant.
///
/// All variants share the same theming and support hover, press, selected,
/// and disabled interaction states.
///
/// {@tool snippet}
///
/// Display a single-emoji reaction chip:
///
/// ```dart
/// StreamEmojiChip(
///   emoji: StreamUnicodeEmoji('👍'),
///   count: 3,
///   isSelected: true,
///   onPressed: () => toggleReaction('👍'),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Display a clustered chip with multiple emojis and a total count:
///
/// ```dart
/// StreamEmojiChip.cluster(
///   emojis: [StreamUnicodeEmoji('👍'), StreamUnicodeEmoji('❤️'), StreamUnicodeEmoji('😂')],
///   count: 12,
///   onPressed: () => showReactionDetails(),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Display an add-reaction chip:
///
/// ```dart
/// StreamEmojiChip.addEmoji(
///   onPressed: () => showReactionPicker(),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamEmojiChipTheme], for customizing chip appearance.
///  * [StreamEmojiButton], for a circular emoji-only button.
class StreamEmojiChip extends StatelessWidget {
  /// Creates a single-emoji chip displaying [emoji] and an optional [count].
  ///
  /// When [count] is null the count label is hidden.
  /// When [onPressed] is null the chip is disabled.
  StreamEmojiChip({
    super.key,
    required StreamEmojiContent emoji,
    int? count,
    VoidCallback? onPressed,
    VoidCallback? onLongPress,
    bool isSelected = false,
  }) : props = .new(
         emojis: [emoji],
         count: count,
         onPressed: onPressed,
         onLongPress: onLongPress,
         isSelected: isSelected,
       );

  /// Creates a clustered chip displaying multiple [emojis] and an optional [count].
  ///
  /// Each emoji in [emojis] is rendered individually at the chip's icon size,
  /// so the full list is visible without overflow.
  ///
  /// When [count] is null the count label is hidden.
  /// When [onPressed] is null the chip is disabled.
  StreamEmojiChip.cluster({
    super.key,
    required List<StreamEmojiContent> emojis,
    int? count,
    VoidCallback? onPressed,
    VoidCallback? onLongPress,
    bool isSelected = false,
  }) : props = .new(
         emojis: emojis,
         count: count,
         onPressed: onPressed,
         onLongPress: onLongPress,
         isSelected: isSelected,
       );

  /// Creates an overflow chip displaying a `+N` count label.
  ///
  /// Unlike the default constructor, the `+` is rendered as text using the
  /// chip's text style rather than going through [StreamEmoji].
  static Widget overflow({
    Key? key,
    required int count,
    VoidCallback? onPressed,
    VoidCallback? onLongPress,
  }) {
    return _RawEmojiChip(
      key: key,
      onPressed: onPressed,
      onLongPress: onLongPress,
      child: Text('+$count'),
    );
  }

  /// Creates an add-emoji chip showing the add-reaction icon.
  ///
  /// This variant bypasses [StreamEmojiContent] because the add-reaction
  /// icon is a Material [Icon], not an emoji.
  ///
  /// When [onPressed] is null the chip is disabled.
  static Widget addEmoji({
    Key? key,
    VoidCallback? onPressed,
    VoidCallback? onLongPress,
  }) {
    return _RawEmojiChip(
      key: key,
      onPressed: onPressed,
      onLongPress: onLongPress,
      child: const _AddEmojiIcon(),
    );
  }

  /// The props controlling the appearance and behavior of this chip.
  final StreamEmojiChipProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).emojiChip;
    if (builder != null) return builder(context, props);
    return DefaultStreamEmojiChip(props: props);
  }
}

/// Properties for configuring a [StreamEmojiChip].
///
/// This class holds all the configuration options for an emoji chip,
/// allowing them to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamEmojiChip], which uses these properties.
///  * [DefaultStreamEmojiChip], the default implementation.
class StreamEmojiChipProps {
  /// Creates properties for an emoji chip.
  const StreamEmojiChipProps({
    required this.emojis,
    this.count,
    this.onPressed,
    this.onLongPress,
    this.isSelected = false,
  }) : assert(emojis.length > 0, 'emojis must not be empty');

  /// The content models describing what to render inside the chip.
  ///
  /// Each item is typically a [StreamUnicodeEmoji] for Unicode reactions or
  /// a [StreamImageEmoji] for custom server emoji. For a standard
  /// single-emoji chip this is a one-element list; for a clustered chip it
  /// contains multiple items.
  ///
  /// Each item is individually wrapped in a [StreamEmoji] to ensure
  /// consistent sizing and platform-specific rendering.
  final List<StreamEmojiContent> emojis;

  /// The reaction count to display next to the emojis.
  ///
  /// When null the count label is hidden.
  final int? count;

  /// Called when the chip is pressed.
  ///
  /// When null the chip is disabled.
  final VoidCallback? onPressed;

  /// Called when the chip is long-pressed.
  ///
  /// Commonly used to open a skin-tone picker.
  final VoidCallback? onLongPress;

  /// Whether the chip is in a selected state.
  ///
  /// When true the chip shows a selected background overlay.
  final bool isSelected;
}

/// Default implementation of [StreamEmojiChip].
class DefaultStreamEmojiChip extends StatelessWidget {
  /// Creates a default emoji chip.
  const DefaultStreamEmojiChip({super.key, required this.props});

  /// The props controlling the appearance and behavior of this chip.
  final StreamEmojiChipProps props;

  @override
  Widget build(BuildContext context) {
    return _RawEmojiChip(
      onPressed: props.onPressed,
      onLongPress: props.onLongPress,
      isSelected: props.isSelected,
      child: Row(
        mainAxisSize: .min,
        spacing: context.streamSpacing.xxs,
        children: [
          for (final emoji in props.emojis) StreamEmoji(emoji: emoji),
          if (props.count case final count?) Text('$count'),
        ],
      ),
    );
  }
}

// Renders the add-reaction icon using the current theme's icon set.
class _AddEmojiIcon extends StatelessWidget {
  const _AddEmojiIcon();

  @override
  Widget build(BuildContext context) => Icon(context.streamIcons.emojiAdd);
}

// Shared themed button shell used by both [DefaultStreamEmojiChip] and
// [_OverflowEmojiChip]. Resolves all chip theme properties and renders
// an [IconButton] with the given [child].
class _RawEmojiChip extends StatelessWidget {
  const _RawEmojiChip({
    super.key,
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.isSelected = false,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final chipThemeStyle = context.streamEmojiChipTheme.style;
    final defaults = _StreamEmojiChipThemeDefaults(context);

    final effectiveBackgroundColor = chipThemeStyle?.backgroundColor ?? defaults.backgroundColor;
    final effectiveForegroundColor = chipThemeStyle?.foregroundColor ?? defaults.foregroundColor;
    final effectiveOverlayColor = chipThemeStyle?.overlayColor ?? defaults.overlayColor;
    final effectiveTextStyle = chipThemeStyle?.textStyle ?? defaults.textStyle;
    final effectiveElevation = chipThemeStyle?.elevation ?? defaults.elevation;
    final effectiveShadowColor = chipThemeStyle?.shadowColor ?? defaults.shadowColor;
    final effectiveEmojiSize = chipThemeStyle?.emojiSize ?? defaults.emojiSize;
    final effectiveMinimumSize = chipThemeStyle?.minimumSize ?? defaults.minimumSize;
    final effectiveMaximumSize = chipThemeStyle?.maximumSize ?? defaults.maximumSize;
    final effectivePadding = chipThemeStyle?.padding ?? defaults.padding;
    final effectiveShape = chipThemeStyle?.shape ?? defaults.shape;
    final effectiveSide = chipThemeStyle?.side ?? defaults.side;

    return IconButton(
      onPressed: onPressed,
      onLongPress: onLongPress,
      isSelected: isSelected,
      iconSize: effectiveEmojiSize,
      // Need to disable text scaling here so that the text doesn't
      // escape the chip when the textScaleFactor is large.
      icon: MediaQuery.withNoTextScaling(child: child),
      style: ButtonStyle(
        tapTargetSize: .shrinkWrap,
        visualDensity: .standard,
        textStyle: effectiveTextStyle,
        elevation: effectiveElevation,
        shadowColor: effectiveShadowColor,
        backgroundColor: effectiveBackgroundColor,
        foregroundColor: effectiveForegroundColor,
        overlayColor: effectiveOverlayColor,
        minimumSize: .all(effectiveMinimumSize),
        maximumSize: .all(effectiveMaximumSize),
        padding: .all(effectivePadding),
        shape: .all(effectiveShape),
        side: effectiveSide,
      ),
    );
  }
}

// Provides default values for [StreamEmojiChipThemeStyle] based on
// the current [StreamColorScheme].
class _StreamEmojiChipThemeDefaults extends StreamEmojiChipThemeStyle {
  _StreamEmojiChipThemeDefaults(this._context);

  final BuildContext _context;

  late final _colorScheme = _context.streamColorScheme;
  late final _textTheme = _context.streamTextTheme;
  late final _radius = _context.streamRadius;
  late final _spacing = _context.streamSpacing;
  late final _materialColors = Theme.of(_context).colorScheme;

  @override
  double get emojiSize => 20;

  @override
  WidgetStateProperty<double?> get elevation => .all(0);

  @override
  WidgetStateProperty<Color?> get shadowColor => .all(_materialColors.shadow);

  @override
  Size get minimumSize => const Size(64, 32);

  @override
  Size get maximumSize => const Size.fromHeight(32);

  @override
  WidgetStateProperty<Color?> get backgroundColor => .resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return StreamColors.transparent;
    if (states.contains(WidgetState.selected)) {
      return Color.alphaBlend(_colorScheme.backgroundSelected, StreamColors.transparent);
    }
    return StreamColors.transparent;
  });

  @override
  WidgetStateProperty<Color?> get foregroundColor => .resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return _colorScheme.textDisabled;
    return _colorScheme.textPrimary;
  });

  @override
  WidgetStateProperty<Color?> get overlayColor => .resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return StreamColors.transparent;
    if (states.contains(WidgetState.pressed)) return _colorScheme.backgroundPressed;
    if (states.contains(WidgetState.hovered)) return _colorScheme.backgroundHover;
    return StreamColors.transparent;
  });

  @override
  WidgetStateProperty<TextStyle?> get textStyle => .all(
    _textTheme.bodyEmphasis.copyWith(fontFeatures: const [.tabularFigures()]),
  );

  @override
  EdgeInsetsGeometry get padding => .symmetric(horizontal: _spacing.sm, vertical: _spacing.xxs + _spacing.xxxs);

  @override
  OutlinedBorder get shape => RoundedRectangleBorder(borderRadius: .all(_radius.max));

  @override
  WidgetStateBorderSide get side => .resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return BorderSide(color: _colorScheme.borderDisabled);
    return BorderSide(color: _colorScheme.borderDefault);
  });
}
