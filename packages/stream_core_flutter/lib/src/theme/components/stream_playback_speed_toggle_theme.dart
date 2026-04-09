import 'package:flutter/material.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';
import '../widget_state_utils.dart';

part 'stream_playback_speed_toggle_theme.g.theme.dart';

/// Applies a playback speed toggle theme to descendant widgets.
///
/// Wrap a subtree with [StreamPlaybackSpeedToggleTheme] to override
/// playback speed toggle styling. Access the merged theme using
/// [BuildContext.streamPlaybackSpeedToggleTheme].
///
/// See also:
///
///  * [StreamPlaybackSpeedToggleThemeData], which describes the theme.
class StreamPlaybackSpeedToggleTheme extends InheritedTheme {
  /// Creates a playback speed toggle theme.
  const StreamPlaybackSpeedToggleTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The playback speed toggle theme data for descendant widgets.
  final StreamPlaybackSpeedToggleThemeData data;

  /// Returns the [StreamPlaybackSpeedToggleThemeData] from the current context.
  ///
  /// Merges the local theme (if any) with the global theme from [StreamTheme].
  static StreamPlaybackSpeedToggleThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamPlaybackSpeedToggleTheme>();
    return StreamTheme.of(context).playbackSpeedToggleTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamPlaybackSpeedToggleTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamPlaybackSpeedToggleTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing playback speed toggle widgets.
///
/// See also:
///
///  * [StreamPlaybackSpeedToggleTheme], for overriding theme in a widget subtree.
///  * [StreamPlaybackSpeedToggleStyle], for the individual style properties.
@themeGen
@immutable
class StreamPlaybackSpeedToggleThemeData with _$StreamPlaybackSpeedToggleThemeData {
  /// Creates playback speed toggle theme data with optional style overrides.
  const StreamPlaybackSpeedToggleThemeData({this.style});

  /// The visual style for playback speed toggles.
  final StreamPlaybackSpeedToggleStyle? style;

  /// Linearly interpolate between two [StreamPlaybackSpeedToggleThemeData].
  static StreamPlaybackSpeedToggleThemeData? lerp(
    StreamPlaybackSpeedToggleThemeData? a,
    StreamPlaybackSpeedToggleThemeData? b,
    double t,
  ) => _$StreamPlaybackSpeedToggleThemeData.lerp(a, b, t);
}

/// Visual styling properties for a [StreamPlaybackSpeedToggle].
///
/// All color properties support state-based styling for interactive feedback
/// (default, hover, pressed, disabled).
///
/// See also:
///
///  * [StreamPlaybackSpeedToggleThemeData], which wraps this style.
///  * [StreamPlaybackSpeedToggle], which uses this styling.
@themeGen
@immutable
class StreamPlaybackSpeedToggleStyle with _$StreamPlaybackSpeedToggleStyle {
  /// Creates playback speed toggle style properties.
  ///
  /// All color properties are [WidgetStateProperty]-based for full
  /// state-level control. For a simpler API that accepts plain values,
  /// use [StreamPlaybackSpeedToggleStyle.from].
  const StreamPlaybackSpeedToggleStyle({
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.overlayColor,
    this.elevation,
    this.textStyle,
    this.shape,
    this.padding,
    this.minimumSize,
    this.maximumSize,
    this.tapTargetSize,
  });

  /// Creates a [StreamPlaybackSpeedToggleStyle] from simple values.
  ///
  /// State-specific parameters (prefixed with `disabled`, `hovered`, or
  /// `pressed`) take precedence for their respective states; unprefixed
  /// parameters are used as the default for all other states.
  factory StreamPlaybackSpeedToggleStyle.from({
    Color? backgroundColor,
    Color? disabledBackgroundColor,
    Color? foregroundColor,
    Color? disabledForegroundColor,
    Color? borderColor,
    Color? disabledBorderColor,
    Color? overlayColor,
    Color? hoveredOverlayColor,
    Color? pressedOverlayColor,
    double? elevation,
    TextStyle? textStyle,
    OutlinedBorder? shape,
    EdgeInsetsGeometry? padding,
    Size? minimumSize,
    Size? maximumSize,
    MaterialTapTargetSize? tapTargetSize,
  }) {
    return StreamPlaybackSpeedToggleStyle(
      backgroundColor: WidgetStateUtils.resolveWith(backgroundColor, null, disabledBackgroundColor),
      foregroundColor: WidgetStateUtils.resolveWith(foregroundColor, null, disabledForegroundColor),
      borderColor: WidgetStateUtils.resolveWith(borderColor, null, disabledBorderColor),
      overlayColor: WidgetStateUtils.resolveOverlay(overlayColor, hoveredOverlayColor, pressedOverlayColor),
      elevation: WidgetStateUtils.allOrNull(elevation),
      textStyle: WidgetStateUtils.allOrNull(textStyle),
      shape: shape,
      padding: padding,
      minimumSize: minimumSize,
      maximumSize: maximumSize,
      tapTargetSize: tapTargetSize,
    );
  }

  /// The background color of the toggle.
  ///
  /// Supports state-based colors for different interaction states.
  final WidgetStateProperty<Color?>? backgroundColor;

  /// The foreground color for the text.
  ///
  /// Supports state-based colors for different interaction states.
  final WidgetStateProperty<Color?>? foregroundColor;

  /// The border color.
  ///
  /// Supports state-based colors for different interaction states.
  final WidgetStateProperty<Color?>? borderColor;

  /// The overlay color for interaction feedback.
  ///
  /// Supports state-based colors for hover and press states.
  final WidgetStateProperty<Color?>? overlayColor;

  /// The elevation of the toggle.
  ///
  /// Controls the shadow depth. Typically zero for this component.
  final WidgetStateProperty<double?>? elevation;

  /// The text style for the speed label.
  final WidgetStateProperty<TextStyle?>? textStyle;

  /// The shape of the toggle button.
  final OutlinedBorder? shape;

  /// The padding inside the toggle button.
  final EdgeInsetsGeometry? padding;

  /// The minimum size of the toggle button.
  final Size? minimumSize;

  /// The maximum size of the toggle button.
  ///
  /// Use to fix the width while allowing height to wrap content
  /// (e.g. `Size(40, double.infinity)`).
  final Size? maximumSize;

  /// The minimum tap target size of the toggle.
  ///
  /// If null, defaults to [MaterialTapTargetSize.padded].
  final MaterialTapTargetSize? tapTargetSize;

  /// Linearly interpolate between two [StreamPlaybackSpeedToggleStyle] objects.
  static StreamPlaybackSpeedToggleStyle? lerp(
    StreamPlaybackSpeedToggleStyle? a,
    StreamPlaybackSpeedToggleStyle? b,
    double t,
  ) => _$StreamPlaybackSpeedToggleStyle.lerp(a, b, t);
}
