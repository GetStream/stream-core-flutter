import 'package:flutter/material.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_banner_theme.dart';
import '../../theme/primitives/stream_colors.dart';
import '../../theme/primitives/stream_spacing.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/semantics/stream_text_theme.dart';
import '../../theme/stream_theme_extensions.dart';
import '../common/stream_loading_spinner.dart';

/// A full-width strip that reports a system-level state.
///
/// Banners are for states that block the experience until they are resolved,
/// such as a lost connection or content that failed to load. The banner shows
/// its `title` centered, with a leading icon for its `type`. Takes the full
/// width of its parent.
///
/// Screen readers announce changes to the title, but not the `type`, so the
/// title should say what kind of state it is.
///
/// {@tool snippet}
///
/// Report a lost connection:
///
/// ```dart
/// StreamBanner(
///   type: StreamBannerType.loading,
///   title: const Text('Waiting for network…'),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Report content that failed to load:
///
/// ```dart
/// StreamBanner(
///   type: StreamBannerType.error,
///   title: const Text("Couldn't load content"),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamBannerType], which defines the available types.
///  * [StreamBannerTheme], for customizing the appearance.
///  * [StreamInlineNotification], for messages tied to a part of a screen.
class StreamBanner extends StatelessWidget {
  /// Creates a banner.
  StreamBanner({
    super.key,
    required Widget title,
    StreamBannerType type = .neutral,
    Widget? icon,
    bool showIcon = true,
  }) : props = .new(
         title: title,
         type: type,
         icon: icon,
         showIcon: showIcon,
       );

  /// The properties that configure this banner.
  final StreamBannerProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).banner;
    if (builder != null) return builder(context, props);
    return DefaultStreamBanner(props: props);
  }
}

/// Properties for configuring a [StreamBanner].
///
/// This class holds all the configuration options for a banner, allowing them
/// to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamBanner], which uses these properties.
///  * [DefaultStreamBanner], the default implementation.
class StreamBannerProps {
  /// Creates properties for a banner.
  const StreamBannerProps({
    required this.title,
    this.type = .neutral,
    this.icon,
    this.showIcon = true,
  });

  /// The message describing the state.
  ///
  /// Typically a [Text]; the banner provides its text style and lets it wrap.
  final Widget title;

  /// The kind of state, which picks the leading icon and the style.
  final StreamBannerType type;

  /// A leading icon that replaces the default one for [type].
  ///
  /// Typically an [Icon]; the banner provides its size and color. For
  /// [StreamBannerType.loading] it replaces the spinner, so pass something
  /// that still shows progress.
  final Widget? icon;

  /// Whether to show the leading icon.
  ///
  /// When false, [icon] is ignored.
  final bool showIcon;
}

/// The default implementation of [StreamBanner].
///
/// See also:
///
///  * [StreamBanner], the public API widget.
///  * [StreamBannerProps], which configures this widget.
class DefaultStreamBanner extends StatelessWidget {
  /// Creates a default banner with the given [props].
  const DefaultStreamBanner({super.key, required this.props});

  /// The properties that configure this banner.
  final StreamBannerProps props;

  @override
  Widget build(BuildContext context) {
    final theme = context.streamBannerTheme;
    final defaults = _StreamBannerThemeDefaults(context);
    final (style, defaultStyle) = switch (props.type) {
      .neutral => (theme.neutral, defaults.neutral),
      .loading => (theme.loading, defaults.loading),
      .error => (theme.error, defaults.error),
    };

    final effectiveBackgroundColor = style?.backgroundColor ?? defaultStyle.backgroundColor;
    final effectiveIconColor = style?.iconColor ?? defaultStyle.iconColor;
    final effectiveTitleTextStyle = style?.titleTextStyle ?? defaultStyle.titleTextStyle;
    final effectiveShape = theme.shape ?? defaults.shape;
    final effectivePadding = theme.padding ?? defaults.padding;
    final effectiveSpacing = theme.spacing ?? defaults.spacing;
    final effectiveConstraints = theme.constraints ?? defaults.constraints;

    return Semantics(
      container: true,
      liveRegion: true,
      child: ConstrainedBox(
        constraints: effectiveConstraints,
        child: Material(
          shape: effectiveShape,
          color: effectiveBackgroundColor,
          child: Padding(
            padding: effectivePadding,
            child: Row(
              mainAxisAlignment: .center,
              spacing: effectiveSpacing,
              children: [
                if (props.showIcon)
                  IconTheme.merge(
                    data: IconThemeData(size: 20, color: effectiveIconColor),
                    child: props.icon ?? _buildDefaultIcon(context, effectiveIconColor),
                  ),
                Flexible(
                  child: DefaultTextStyle(
                    style: effectiveTitleTextStyle,
                    textAlign: .start,
                    textWidthBasis: .longestLine,
                    child: props.title,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultIcon(BuildContext context, Color iconColor) {
    final icons = context.streamIcons;
    return switch (props.type) {
      .neutral => Icon(icons.refresh),
      .loading => StreamLoadingSpinner(
        size: .sm,
        color: iconColor,
        backgroundColor: StreamColors.transparent,
        trackColor: iconColor.withValues(alpha: 0.32),
      ),
      .error => Icon(icons.exclamationCircle),
    };
  }
}

// Default theme values for [StreamBanner].
class _StreamBannerThemeDefaults extends StreamBannerThemeData {
  _StreamBannerThemeDefaults(this._context);

  final BuildContext _context;

  late final StreamSpacing _spacing = _context.streamSpacing;

  @override
  _StreamBannerStyleDefaults get neutral => .new(_context, .neutral);

  @override
  _StreamBannerStyleDefaults get loading => .new(_context, .loading);

  @override
  _StreamBannerStyleDefaults get error => .new(_context, .error);

  @override
  EdgeInsetsGeometry get padding => EdgeInsets.symmetric(
    horizontal: _spacing.xs,
    vertical: _spacing.sm,
  );

  @override
  double get spacing => _spacing.xs;

  @override
  BoxConstraints get constraints => const BoxConstraints();
}

// Default colors and text style for one [StreamBannerType].
class _StreamBannerStyleDefaults extends StreamBannerThemeStyle {
  _StreamBannerStyleDefaults(this._context, this._type);

  final BuildContext _context;
  final StreamBannerType _type;

  late final StreamColorScheme _colorScheme = _context.streamColorScheme;
  late final StreamTextTheme _textTheme = _context.streamTextTheme;

  @override
  Color get backgroundColor => _colorScheme.backgroundSurface;

  @override
  Color get iconColor => switch (_type) {
    .neutral || .loading => _colorScheme.textSecondary,
    .error => _colorScheme.textTertiary,
  };

  @override
  TextStyle get titleTextStyle => _textTheme.metadataEmphasis.copyWith(
    color: _colorScheme.textSecondary,
  );
}
