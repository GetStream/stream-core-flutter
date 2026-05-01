import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../stream_core_flutter.dart';

/// The content model for an emoji rendered by [StreamEmoji].
///
/// [StreamEmojiContent] is a sealed type with two variants:
///
/// - [StreamUnicodeEmoji] — a native Unicode character (e.g. '👍').
/// - [StreamImageEmoji] — a custom image loaded from a URL.
///
/// The content model is size-independent — sizing is controlled by the
/// [StreamEmoji] widget.
///
/// {@tool snippet}
///
/// Create a Unicode emoji:
///
/// ```dart
/// const emoji = StreamUnicodeEmoji('👍');
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Create a custom image emoji:
///
/// ```dart
/// final emoji = StreamImageEmoji(
///   url: Uri.parse('https://cdn.example.com/emoji/custom.png'),
/// );
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamEmoji], which renders a [StreamEmojiContent] at a given size.
///  * [StreamEmojiData], the catalog model describing emoji metadata.
@immutable
sealed class StreamEmojiContent {
  const StreamEmojiContent._();
}

/// A native Unicode emoji character (e.g. '👍').
///
/// See also:
///
///  * [StreamEmojiContent], the sealed parent type.
@immutable
class StreamUnicodeEmoji extends StreamEmojiContent {
  /// Creates a Unicode emoji display.
  const StreamUnicodeEmoji(this.emoji) : super._();

  /// The Unicode emoji character (e.g. '👍', '❤️', '🔥').
  final String emoji;
}

/// A custom image emoji loaded from a URL.
///
/// Covers custom emoji such as Twitch, Discord, or Reddit emotes, as well
/// as cross-platform image sets like Twemoji.
///
/// See also:
///
///  * [StreamEmojiContent], the sealed parent type.
@immutable
class StreamImageEmoji extends StreamEmojiContent {
  /// Creates an image emoji display.
  const StreamImageEmoji({
    required this.url,
    this.stillUrl,
  }) : super._();

  /// The URL of the emoji image.
  final Uri url;

  /// An optional URL for the still (non-animated) version of the emoji.
  ///
  /// When provided, the widget will show this URL instead of [url] when
  /// the device has animations disabled in accessibility settings.
  /// If null, [url] is used in all cases.
  final Uri? stillUrl;
}

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

/// An emoji component for the Stream design system.
///
/// [StreamEmoji] displays an emoji at a consistent size using
/// platform-appropriate rendering based on the [StreamEmojiContent] variant:
///
/// - [StreamUnicodeEmoji] — native text with platform-specific corrections.
/// - [StreamImageEmoji] — cached network image.
///
/// {@tool snippet}
///
/// Display a Unicode emoji:
///
/// ```dart
/// StreamEmoji(
///   size: StreamEmojiSize.lg,
///   emoji: StreamUnicodeEmoji('👍'),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Display a custom image emoji:
///
/// ```dart
/// StreamEmoji(
///   size: StreamEmojiSize.md,
///   emoji: StreamImageEmoji(
///     url: Uri.parse('https://cdn.example.com/emoji/parrot.gif'),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Default size from [IconTheme]:
///
/// ```dart
/// StreamEmoji(emoji: StreamUnicodeEmoji('🔥'))
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Use with [IconButton] (size controlled via [IconButton.iconSize]):
///
/// ```dart
/// IconButton(
///   iconSize: 32,
///   icon: StreamEmoji(emoji: StreamUnicodeEmoji('👍')),
///   onPressed: () {},
/// )
/// ```
/// {@end-tool}
///
/// **Best Practice:** When using [StreamEmoji] inside an [IconButton], set the
/// size using [IconButton.iconSize] instead of [StreamEmoji.size]. The emoji
/// inherits the size automatically from the ambient [IconTheme].
///
/// See also:
///
///  * [StreamEmojiSize], which defines the available size variants.
///  * [StreamEmojiContent], which describes the emoji content model.
class StreamEmoji extends StatelessWidget {
  /// Creates an emoji display widget.
  StreamEmoji({
    super.key,
    StreamEmojiSize? size,
    required StreamEmojiContent emoji,
    TextScaler? textScaler,
  }) : props = .new(size: size, emoji: emoji, textScaler: textScaler);

  /// The props controlling the appearance of this emoji.
  final StreamEmojiProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).emoji;
    if (builder != null) return builder(context, props);
    return DefaultStreamEmoji(props: props);
  }
}

/// Properties for configuring a [StreamEmoji].
///
/// This class holds all the configuration options for an emoji,
/// allowing them to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamEmoji], which uses these properties.
///  * [DefaultStreamEmoji], the default implementation.
@immutable
class StreamEmojiProps {
  /// Creates emoji properties.
  const StreamEmojiProps({
    this.size,
    required this.emoji,
    this.textScaler,
  });

  /// The display size of the emoji.
  ///
  /// If null, the size is resolved from the ambient [IconTheme] size. If that
  /// is also null, [StreamEmojiSize.md] (24px) is used.
  final StreamEmojiSize? size;

  /// The content model describing what to render.
  ///
  /// See [StreamEmojiContent] for the available variants.
  final StreamEmojiContent emoji;

  /// A [TextScaler] to apply to the emoji dimensions.
  ///
  /// When null, defaults to [TextScaler.noScaling] — the emoji renders at
  /// exactly the size specified by [size] and ignores the system text scale
  /// factor.
  ///
  /// Pass [MediaQuery.textScalerOf] to opt-in to accessibility text scaling.
  final TextScaler? textScaler;
}

/// The default implementation of [StreamEmoji].
///
/// Dispatches rendering to a dedicated sub-widget based on the
/// [StreamEmojiContent] variant. It is used as the default factory
/// implementation in [StreamComponentFactory].
///
/// See also:
///
///  * [StreamEmoji], the public API widget.
///  * [StreamEmojiProps], which configures this widget.
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
    final effectiveScaler = props.textScaler ?? TextScaler.noScaling;

    final emoji = props.emoji;
    return switch (emoji) {
      StreamUnicodeEmoji() => _UnicodeEmojiWidget(
        emoji: emoji.emoji,
        size: effectiveSize,
        textScaler: effectiveScaler,
      ),
      StreamImageEmoji() => _ImageEmojiWidget(
        url: emoji.url,
        stillUrl: emoji.stillUrl,
        size: effectiveSize,
        textScaler: effectiveScaler,
      ),
    };
  }
}

// Noto Color Emoji font-size-to-visual-size correction factor.
//
// With Noto Color Emoji, a font size of 14.5 px produces a glyph that visually occupies
// ~17 px square in the layout. So to get an emoji that fits a target [size], we set
// fontSize = size × (14.5 / 17).
//
// Determined experimentally. See also:
//   <https://github.com/flutter/flutter/issues/28894>
const double _kNotoEmojiScale = 14.5 / 17;

// Renders a native Unicode emoji with platform-specific font corrections.
class _UnicodeEmojiWidget extends StatelessWidget {
  const _UnicodeEmojiWidget({
    required this.emoji,
    required this.size,
    this.textScaler = TextScaler.noScaling,
  });

  final String emoji;
  final double size;
  final TextScaler textScaler;

  @override
  Widget build(BuildContext context) {
    final scaledSize = textScaler.scale(size);
    final platform = Theme.of(context).platform;

    // There are two emoji fonts to handle, each with quirks:
    //
    // Apple Color Emoji (iOS / macOS native):
    // - A font size of N px visually appears ~N px square. No correction is needed.
    //   See: <https://github.com/flutter/flutter/issues/28894>
    //
    // Noto Color Emoji (Android, Linux, Windows, and web via CanvasKit):
    // - A font size of 14.5 px visually appears ~17 px square, so we apply [_kNotoEmojiScale]
    //   to compensate. See: <https://github.com/flutter/flutter/issues/28894>
    // - On web, CanvasKit always bundles Noto Color Emoji regardless of the host OS, so we use
    //   the Noto scaling for all web platforms.
    final fontSize = switch (platform) {
      .iOS || .macOS when !kIsWeb => size,
      _ => size * _kNotoEmojiScale,
    };

    // Pin the primary [fontFamily] to the platform's native emoji font so the
    // [fontSize] correction above lines up with the font that actually renders
    // the glyph. [fontFamilyFallback] still covers cases where the primary
    // font is unavailable.
    final fontFamily = switch (platform) {
      .iOS || .macOS when !kIsWeb => 'Apple Color Emoji',
      .windows => 'Segoe UI Emoji',
      _ => 'Noto Color Emoji',
    };

    // Both fonts produce a [Text] whose layout is larger than the visible glyph — Apple Color
    // Emoji adds whitespace above, below, and to the right; Noto has similar extra metrics.
    // See: <https://github.com/flutter/flutter/issues/119623>
    //
    // We use a [Stack] with [Clip.none] so the [Text] renders at its natural (oversized) metrics
    // without inflating the visible bounding box:
    // - [SizedBox.square] defines the intended layout footprint.
    // - [Positioned(left: 0)] pins the glyph to the physical left edge.
    // - [textDirection: .ltr] ensures pinning works regardless of ambient text direction (RTL).
    // - [StrutStyle(forceStrutHeight: true)] locks line height so ambient [DefaultTextStyle] cannot inflate it.
    return Stack(
      alignment: .center,
      clipBehavior: .none,
      children: [
        SizedBox.square(dimension: scaledSize),
        Positioned(
          left: 0,
          child: Text(
            emoji,
            textDirection: .ltr,
            textScaler: textScaler,
            strutStyle: StrutStyle(
              fontSize: fontSize,
              forceStrutHeight: true,
            ),
            style: TextStyle(
              fontSize: fontSize,
              fontFamily: fontFamily,
              decoration: .none,
              // Commonly available fallback fonts for emoji rendering.
              fontFamilyFallback: const [
                'Apple Color Emoji', // iOS and macOS.
                'Noto Color Emoji', // Android, ChromeOS, Ubuntu, Linux.
                'Segoe UI Emoji', // Windows.
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Renders a custom image emoji as a cached network image.
class _ImageEmojiWidget extends StatelessWidget {
  const _ImageEmojiWidget({
    required this.url,
    this.stillUrl,
    required this.size,
    this.textScaler = TextScaler.noScaling,
  });

  final Uri url;
  final Uri? stillUrl;
  final double size;
  final TextScaler textScaler;

  @override
  Widget build(BuildContext context) {
    final scaledSize = textScaler.scale(size);

    // If a [stillUrl] is available and the device has animations disabled, prefer the still
    // version. See [_shouldDisableAnimations] for platform-specific details.
    final resolvedUrl = (_shouldDisableAnimations(context) ? stillUrl : url) ?? url;

    // Decode at the physical pixel size so the image stays crisp on high-DPI screens without
    // wasting memory on oversized source images (e.g. a 512 px Noto PNG displayed at 24 px).
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final cacheExtent = (scaledSize * devicePixelRatio).ceil();

    // On load failure we fall back to a '❓' Unicode emoji so the layout always reserves the
    // correct space.
    return StreamNetworkImage(
      resolvedUrl.toString(),
      width: scaledSize,
      height: scaledSize,
      cacheWidth: cacheExtent,
      cacheHeight: cacheExtent,
      placeholderBuilder: (_) => const SizedBox.shrink(),
      errorBuilder: (_, _, _) => _UnicodeEmojiWidget(emoji: '❓', size: size, textScaler: textScaler),
    );
  }
}

// Whether animations should be disabled based on device accessibility settings.
bool _shouldDisableAnimations(BuildContext context) {
  // The preferred widget-layer API — only triggers rebuilds when this specific property
  // changes. Set on Android ("Remove animations" developer option) but not on iOS.
  if (MediaQuery.disableAnimationsOf(context)) return true;

  // iOS-only: maps to the "Reduce Motion" accessibility toggle.
  //
  // TODO: When the minimum Flutter SDK is >= 3.40, replace this with
  // [AccessibilityFeatures.autoPlayAnimatedImages], which maps to iOS 17's more specific
  // "Auto-Play Animated Images" toggle.
  // See: <https://github.com/flutter/flutter/pull/178102>
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    return View.of(context).platformDispatcher.accessibilityFeatures.reduceMotion;
  }

  return false;
}
