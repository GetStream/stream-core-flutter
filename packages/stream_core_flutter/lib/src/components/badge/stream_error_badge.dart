import 'package:flutter/material.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_error_badge_theme.dart';
import '../../theme/primitives/stream_colors.dart';
import '../../theme/primitives/stream_icons.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/stream_theme_extensions.dart';

/// A circular badge that displays an exclamation mark icon.
///
/// [StreamErrorBadge] is used to indicate a failed operation, such as a
/// message that could not be sent. It renders as a fixed-size circle with
/// a background colored by [StreamErrorBadgeStyle] and an exclamation mark
/// icon.
///
/// {@tool snippet}
///
/// Basic usage:
///
/// ```dart
/// StreamErrorBadge()
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Medium variant:
///
/// ```dart
/// StreamErrorBadge(size: StreamErrorBadgeSize.md)
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Warning variant without a border, as a call control button uses it:
///
/// ```dart
/// StreamErrorBadge(
///   style: StreamErrorBadgeStyle.warning,
///   showBorder: false,
/// )
/// ```
/// {@end-tool}
///
/// ## Theming
///
/// [StreamErrorBadge] uses [StreamErrorBadgeThemeData] for default styling.
/// Colors are determined by the current [StreamColorScheme].
///
/// See also:
///
///  * [StreamErrorBadgeSize], the available size variants.
///  * [StreamErrorBadgeStyle], the available style variants.
///  * [StreamErrorBadgeThemeData], for customizing appearance.
///  * [StreamErrorBadgeTheme], for overriding theme in a subtree.
///  * [StreamRetryBadge], a badge for indicating retryable actions.
///  * [StreamBadgeNotification], a badge for displaying notification counts.
class StreamErrorBadge extends StatelessWidget {
  /// Creates an error badge.
  StreamErrorBadge({
    super.key,
    StreamErrorBadgeSize? size,
    StreamErrorBadgeStyle? style,
    bool showBorder = true,
  }) : props = .new(size: size, style: style, showBorder: showBorder);

  /// The properties that configure this error badge.
  final StreamErrorBadgeProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).errorBadge;
    if (builder != null) return builder(context, props);
    return DefaultStreamErrorBadge(props: props);
  }
}

/// Properties for configuring a [StreamErrorBadge].
///
/// This class holds all the configuration options for an error badge,
/// allowing them to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamErrorBadge], which uses these properties.
///  * [DefaultStreamErrorBadge], the default implementation.
class StreamErrorBadgeProps {
  /// Creates properties for an error badge.
  const StreamErrorBadgeProps({
    this.size,
    this.style,
    this.showBorder = true,
  });

  /// The size of the badge.
  ///
  /// If null, uses [StreamErrorBadgeThemeData.size], or falls back to
  /// [StreamErrorBadgeSize.sm].
  final StreamErrorBadgeSize? size;

  /// The severity the badge conveys.
  ///
  /// If null, defaults to [StreamErrorBadgeStyle.error].
  final StreamErrorBadgeStyle? style;

  /// Whether a border is drawn around the badge.
  ///
  /// The border style is determined by [StreamErrorBadgeThemeData.border]. It
  /// is drawn outside the badge's [size], so it separates the badge from
  /// whatever it overlaps without changing the badge's layout size. Defaults
  /// to true.
  final bool showBorder;
}

/// The default implementation of [StreamErrorBadge].
///
/// Renders a circular badge with an exclamation mark icon. Styling is
/// resolved from [StreamErrorBadgeThemeData], falling back to the current
/// [StreamColorScheme] and [StreamIcons].
///
/// See also:
///
///  * [StreamErrorBadge], the public API widget.
///  * [StreamErrorBadgeProps], which configures this widget.
class DefaultStreamErrorBadge extends StatelessWidget {
  /// Creates a default error badge with the given [props].
  const DefaultStreamErrorBadge({super.key, required this.props});

  /// The properties that configure this error badge.
  final StreamErrorBadgeProps props;

  @override
  Widget build(BuildContext context) {
    final icons = context.streamIcons;

    final theme = context.streamErrorBadgeTheme;
    final defaults = _StreamErrorBadgeThemeDefaults(context);

    final effectiveSize = props.size ?? theme.size ?? defaults.size;
    final effectiveStyle = props.style ?? StreamErrorBadgeStyle.error;
    final effectiveBorder = props.showBorder ? theme.border ?? defaults.border : null;

    final effectiveBackgroundColor = _resolveBackgroundColor(effectiveStyle, theme, defaults);
    final effectiveForegroundColor = _resolveForegroundColor(effectiveStyle, theme, defaults);

    return AnimatedContainer(
      width: effectiveSize.value,
      height: effectiveSize.value,
      clipBehavior: Clip.antiAlias,
      duration: kThemeChangeDuration,
      decoration: BoxDecoration(shape: BoxShape.circle, color: effectiveBackgroundColor),
      foregroundDecoration: BoxDecoration(shape: BoxShape.circle, border: effectiveBorder),
      child: IconTheme(
        data: .new(size: effectiveSize.iconSize, color: effectiveForegroundColor),
        child: Center(child: Icon(icons.exclamationMarkFill)),
      ),
    );
  }

  Color _resolveBackgroundColor(
    StreamErrorBadgeStyle style,
    StreamErrorBadgeThemeData theme,
    _StreamErrorBadgeThemeDefaults defaults,
  ) => switch (style) {
    .error => theme.errorBackgroundColor ?? defaults.errorBackgroundColor,
    .warning => theme.warningBackgroundColor ?? defaults.warningBackgroundColor,
  };

  Color _resolveForegroundColor(
    StreamErrorBadgeStyle style,
    StreamErrorBadgeThemeData theme,
    _StreamErrorBadgeThemeDefaults defaults,
  ) => switch (style) {
    .error => theme.errorForegroundColor ?? defaults.errorForegroundColor,
    .warning => theme.warningForegroundColor ?? defaults.warningForegroundColor,
  };
}

class _StreamErrorBadgeThemeDefaults extends StreamErrorBadgeThemeData {
  _StreamErrorBadgeThemeDefaults(this._context);

  final BuildContext _context;

  late final _colorScheme = _context.streamColorScheme;

  @override
  StreamErrorBadgeSize get size => .sm;

  @override
  Color get errorBackgroundColor => _colorScheme.accentError;

  @override
  Color get errorForegroundColor => _colorScheme.textOnAccent;

  @override
  Color get warningBackgroundColor => _colorScheme.accentWarning;

  @override
  Color get warningForegroundColor => StreamColors.black;

  @override
  BoxBorder get border => Border.all(
    width: 2,
    color: _colorScheme.borderOnInverse,
    strokeAlign: BorderSide.strokeAlignOutside,
  );
}
