import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_avatar_theme.dart';
import '../../theme/primitives/stream_colors.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/semantics/stream_text_theme.dart';
import '../../theme/stream_theme_extensions.dart';

/// A circular avatar component for the Stream design system.
///
/// [StreamAvatar] displays a user's profile image or a placeholder (typically
/// initials or an icon) when no image is available. It supports multiple sizes,
/// customizable colors, and an optional border.
///
/// The avatar automatically handles:
/// - Loading states while fetching network images
/// - Error states when images fail to load
/// - Text scaling (disabled to prevent overflow)
/// - Theme-aware colors with light/dark mode support
///
/// {@tool snippet}
///
/// Basic usage with initials placeholder:
///
/// ```dart
/// StreamAvatar(
///   imageUrl: user.avatarUrl,
///   placeholder: (context) => Text(user.initials),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Custom size and colors:
///
/// ```dart
/// StreamAvatar(
///   imageUrl: user.avatarUrl,
///   size: StreamAvatarSize.sm,
///   backgroundColor: Colors.blue.shade100,
///   foregroundColor: Colors.blue.shade800,
///   placeholder: (context) => Text(user.initials),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// With icon placeholder:
///
/// ```dart
/// StreamAvatar(
///   size: StreamAvatarSize.md,
///   showBorder: false,
///   placeholder: (context) => Icon(Icons.person),
/// )
/// ```
/// {@end-tool}
///
/// ## Theming
///
/// [StreamAvatar] uses [StreamAvatarThemeData] for default styling. Colors
/// can be customized globally via the theme or per-instance via constructor
/// parameters. The color palette for deterministic user-based colors is
/// available in [StreamColorScheme.avatarPalette].
///
/// See also:
///
///  * [StreamAvatarSize], which defines the available size variants.
///  * [StreamAvatarThemeData], which provides theme-level customization.
///  * [StreamColorScheme.avatarPalette], which provides colors for user avatars.
class StreamAvatar extends StatelessWidget {
  /// Creates a Stream avatar.
  ///
  /// The [placeholder] is required and is shown when [imageUrl] is null,
  /// while the image is loading, or if the image fails to load.
  StreamAvatar({
    super.key,
    StreamAvatarSize? size,
    String? imageUrl,
    required WidgetBuilder placeholder,
    Color? backgroundColor,
    Color? foregroundColor,
    bool showBorder = true,
  }) : props = .new(
         size: size,
         imageUrl: imageUrl,
         placeholder: placeholder,
         backgroundColor: backgroundColor,
         foregroundColor: foregroundColor,
         showBorder: showBorder,
       );

  /// The properties that configure this avatar.
  final StreamAvatarProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.maybeOf(context)?.avatar;
    if (builder != null) return builder(context, props);
    return DefaultStreamAvatar(props: props);
  }
}

/// Properties for configuring a [StreamAvatar].
///
/// This class holds all the configuration options for an avatar,
/// allowing them to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamAvatar], which uses these properties.
///  * [DefaultStreamAvatar], the default implementation.
class StreamAvatarProps {
  /// Creates properties for an avatar.
  const StreamAvatarProps({
    this.size,
    this.imageUrl,
    required this.placeholder,
    this.backgroundColor,
    this.foregroundColor,
    this.showBorder = true,
  });

  /// The URL of the avatar image.
  ///
  /// When null, the [placeholder] is displayed. The image is loaded
  /// asynchronously with caching support.
  final String? imageUrl;

  /// The size of the avatar.
  ///
  /// If null, uses [StreamAvatarThemeData.size], or falls back to
  /// [StreamAvatarSize.lg] (40.0).
  final StreamAvatarSize? size;

  /// A builder for the placeholder content.
  ///
  /// This is displayed when [imageUrl] is null, while the image is loading,
  /// or if the image fails to load. Typically contains initials text or
  /// an icon.
  ///
  /// The placeholder inherits [DefaultTextStyle] and [IconTheme] from the
  /// avatar, so text and icons will automatically use [foregroundColor].
  final WidgetBuilder placeholder;

  /// The background color of the avatar.
  ///
  /// If null, uses [StreamAvatarThemeData.backgroundColor], or falls back
  /// to the first color in [StreamColorScheme.avatarPalette].
  final Color? backgroundColor;

  /// The foreground color for text and icons in the placeholder.
  ///
  /// If null, uses [StreamAvatarThemeData.foregroundColor], or falls back
  /// to the first color in [StreamColorScheme.avatarPalette].
  final Color? foregroundColor;

  /// Whether to show a border around the avatar.
  ///
  /// Defaults to true. The border style is determined by
  /// [StreamAvatarThemeData.border].
  final bool showBorder;
}

/// The default implementation of [StreamAvatar].
///
/// This widget renders the avatar with theming support.
/// It's used as the default factory implementation in [StreamComponentFactory].
///
/// See also:
///
///  * [StreamAvatar], the public API widget.
///  * [StreamAvatarProps], which configures this widget.
class DefaultStreamAvatar extends StatelessWidget {
  /// Creates a default avatar with the given [props].
  const DefaultStreamAvatar({super.key, required this.props});

  /// The properties that configure this avatar.
  final StreamAvatarProps props;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = context.streamTextTheme;
    final avatarTheme = context.streamAvatarTheme;
    final defaults = _StreamAvatarThemeDefaults(context);

    final effectiveSize = props.size ?? avatarTheme.size ?? defaults.size;
    final effectiveBackgroundColor = props.backgroundColor ?? avatarTheme.backgroundColor ?? defaults.backgroundColor;
    final effectiveForegroundColor = props.foregroundColor ?? avatarTheme.foregroundColor ?? defaults.foregroundColor;
    final effectiveBorder = avatarTheme.border ?? defaults.border;

    final border = props.showBorder ? effectiveBorder : null;
    final textStyle = _textStyleForSize(effectiveSize, textTheme).copyWith(color: effectiveForegroundColor);
    final iconTheme = theme.iconTheme.copyWith(
      color: effectiveForegroundColor,
      size: _iconSizeForSize(effectiveSize),
    );

    return AnimatedContainer(
      alignment: .center,
      clipBehavior: .antiAlias,
      width: effectiveSize.value,
      height: effectiveSize.value,
      duration: kThemeChangeDuration,
      foregroundDecoration: BoxDecoration(shape: .circle, border: border),
      decoration: BoxDecoration(shape: .circle, color: effectiveBackgroundColor),
      child: Center(
        // Need to disable text scaling here so that the text doesn't
        // escape the avatar when the textScaleFactor is large.
        child: MediaQuery.withNoTextScaling(
          child: IconTheme(
            data: iconTheme,
            child: DefaultTextStyle(
              style: textStyle,
              child: switch (props.imageUrl) {
                final imageUrl? => CachedNetworkImage(
                  fit: .cover,
                  imageUrl: imageUrl,
                  width: effectiveSize.value,
                  height: effectiveSize.value,
                  placeholder: (context, _) => Center(child: props.placeholder.call(context)),
                  errorWidget: (context, _, _) => Center(child: props.placeholder.call(context)),
                ),
                _ => props.placeholder.call(context),
              },
            ),
          ),
        ),
      ),
    );
  }

  // Returns the appropriate text style for the given avatar size.
  TextStyle _textStyleForSize(
    StreamAvatarSize size,
    StreamTextTheme textTheme,
  ) => switch (size) {
    .xs => textTheme.metadataEmphasis,
    .sm || .md => textTheme.captionEmphasis,
    .lg => textTheme.bodyEmphasis,
    .xl => textTheme.headingLg,
  };

  // Returns the appropriate icon size for the given avatar size.
  double _iconSizeForSize(
    StreamAvatarSize size,
  ) => switch (size) {
    .xs => 10,
    .sm => 12,
    .md => 16,
    .lg => 20,
    .xl => 32,
  };
}

// Default theme values for [StreamAvatar].
//
// These defaults are used when no explicit value is provided via
// constructor parameters or [StreamAvatarThemeData].
//
// The defaults are context-aware and use colors from
// [StreamColorScheme.avatarPalette].
class _StreamAvatarThemeDefaults extends StreamAvatarThemeData {
  _StreamAvatarThemeDefaults(
    this.context,
  ) : _colorScheme = context.streamColorScheme;

  final BuildContext context;
  final StreamColorScheme _colorScheme;

  @override
  StreamAvatarSize get size => StreamAvatarSize.lg;

  @override
  BoxBorder get border => Border.all(color: StreamColors.black10);

  @override
  Color get backgroundColor => _colorScheme.avatarPalette.first.backgroundColor;

  @override
  Color get foregroundColor => _colorScheme.avatarPalette.first.foregroundColor;
}
