import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';
import '../widget_state_utils.dart';

part 'stream_toggle_switch_theme.g.theme.dart';

/// Applies a toggle switch theme to descendant [StreamToggleSwitch] widgets.
///
/// Wrap a subtree with [StreamToggleSwitchTheme] to override toggle switch
/// styling. Access the merged theme using
/// [BuildContext.streamToggleSwitchTheme].
///
/// {@tool snippet}
///
/// Override toggle switch styling for a specific section:
///
/// ```dart
/// StreamToggleSwitchTheme(
///   data: StreamToggleSwitchThemeData(
///     style: StreamToggleSwitchStyle(
///       trackColor: WidgetStateProperty.resolveWith((states) {
///         if (states.contains(WidgetState.selected)) {
///           return Colors.green;
///         }
///         return Colors.grey;
///       }),
///     ),
///   ),
///   child: StreamToggleSwitch(
///     value: true,
///     onChanged: (value) {},
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamToggleSwitchThemeData], which describes the toggle switch theme.
///  * [StreamToggleSwitch], the widget affected by this theme.
class StreamToggleSwitchTheme extends InheritedTheme {
  /// Creates a toggle switch theme that controls descendant toggle switches.
  const StreamToggleSwitchTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The toggle switch theme data for descendant widgets.
  final StreamToggleSwitchThemeData data;

  /// Returns the [StreamToggleSwitchThemeData] merged from local and global
  /// themes.
  ///
  /// Local values from the nearest [StreamToggleSwitchTheme] ancestor take
  /// precedence over global values from [StreamTheme.of].
  static StreamToggleSwitchThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamToggleSwitchTheme>();
    return StreamTheme.of(context).toggleSwitchTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamToggleSwitchTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamToggleSwitchTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing [StreamToggleSwitch] widgets.
///
/// {@tool snippet}
///
/// Customize toggle switch appearance globally via [StreamTheme]:
///
/// ```dart
/// StreamTheme(
///   toggleSwitchTheme: StreamToggleSwitchThemeData(
///     style: StreamToggleSwitchStyle.from(
///       trackColor: Colors.grey,
///       selectedTrackColor: Colors.green,
///       thumbColor: Colors.white,
///     ),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamToggleSwitchTheme], for overriding theme in a widget subtree.
@themeGen
@immutable
class StreamToggleSwitchThemeData with _$StreamToggleSwitchThemeData {
  /// Creates toggle switch theme data with optional style overrides.
  const StreamToggleSwitchThemeData({this.style});

  /// The visual styling for toggle switches.
  ///
  /// Contains track color, thumb color, overlay color, and track outline color.
  final StreamToggleSwitchStyle? style;

  /// Linearly interpolate between two [StreamToggleSwitchThemeData] objects.
  static StreamToggleSwitchThemeData? lerp(
    StreamToggleSwitchThemeData? a,
    StreamToggleSwitchThemeData? b,
    double t,
  ) => _$StreamToggleSwitchThemeData.lerp(a, b, t);
}

/// Visual styling properties for toggle switches.
///
/// Defines the appearance of toggle switches including track, thumb, overlay,
/// and outline colors. Color properties are [WidgetStateProperty]-based for
/// state-dependent styling (default, hover, pressed, disabled, selected).
///
/// See also:
///
///  * [StreamToggleSwitchThemeData], which wraps this style for theming.
///  * [StreamToggleSwitch], which uses this styling.
@themeGen
@immutable
class StreamToggleSwitchStyle with _$StreamToggleSwitchStyle {
  /// Creates toggle switch style properties.
  ///
  /// Color properties are [WidgetStateProperty]-based for full state-level
  /// control. For a simpler API that accepts plain values and builds state
  /// properties internally, use [StreamToggleSwitchStyle.from].
  const StreamToggleSwitchStyle({
    this.trackColor,
    this.thumbColor,
    this.trackOutlineColor,
    this.trackOutlineWidth,
    this.overlayColor,
  });

  /// Creates a [StreamToggleSwitchStyle] from simple values.
  ///
  /// Wraps plain colors into [WidgetStateProperty] values.
  ///
  /// State-specific parameters (prefixed with `selected` or `disabled`) take
  /// precedence for their respective states; unprefixed parameters are used
  /// as the default for all other states.
  ///
  /// {@tool snippet}
  ///
  /// Create a style with a green track when selected:
  ///
  /// ```dart
  /// StreamToggleSwitchStyle.from(
  ///   trackColor: Colors.grey,
  ///   selectedTrackColor: Colors.green,
  ///   disabledTrackColor: Colors.grey.shade200,
  ///   thumbColor: Colors.white,
  ///   hoveredOverlayColor: Colors.green.withOpacity(0.08),
  ///   pressedOverlayColor: Colors.green.withOpacity(0.1),
  /// )
  /// ```
  /// {@end-tool}
  factory StreamToggleSwitchStyle.from({
    Color? trackColor,
    Color? selectedTrackColor,
    Color? disabledTrackColor,
    Color? thumbColor,
    Color? selectedThumbColor,
    Color? disabledThumbColor,
    Color? trackOutlineColor,
    Color? selectedTrackOutlineColor,
    Color? disabledTrackOutlineColor,
    double? trackOutlineWidth,
    double? selectedTrackOutlineWidth,
    double? disabledTrackOutlineWidth,
    Color? overlayColor,
    Color? hoveredOverlayColor,
    Color? pressedOverlayColor,
  }) {
    return StreamToggleSwitchStyle(
      trackColor: WidgetStateUtils.resolveWith(trackColor, selectedTrackColor, disabledTrackColor),
      thumbColor: WidgetStateUtils.resolveWith(thumbColor, selectedThumbColor, disabledThumbColor),
      trackOutlineColor: WidgetStateUtils.resolveWith(
        trackOutlineColor,
        selectedTrackOutlineColor,
        disabledTrackOutlineColor,
      ),
      trackOutlineWidth: WidgetStateUtils.resolveWith(
        trackOutlineWidth,
        selectedTrackOutlineWidth,
        disabledTrackOutlineWidth,
      ),
      overlayColor: WidgetStateUtils.resolveOverlay(overlayColor, hoveredOverlayColor, pressedOverlayColor),
    );
  }

  /// The color of the switch track, resolved per [WidgetState].
  ///
  /// Resolves based on:
  ///  * [WidgetState.selected] -- accent color when on.
  ///  * [WidgetState.disabled] -- muted color.
  ///
  /// Falls back to neutral color when unselected.
  final WidgetStateProperty<Color?>? trackColor;

  /// The color of the switch thumb (knob), resolved per [WidgetState].
  ///
  /// Typically white across all states.
  final WidgetStateProperty<Color?>? thumbColor;

  /// The outline color of the switch track, resolved per [WidgetState].
  ///
  /// On Material switches, this controls the track border. On Cupertino
  /// switches, this property has no visible effect.
  final WidgetStateProperty<Color?>? trackOutlineColor;

  /// The outline width of the switch track, resolved per [WidgetState].
  ///
  /// On Material switches, this controls the track border width. Defaults
  /// to 2.0 when unselected and 0.0 when selected. On Cupertino switches,
  /// this property has no visible effect.
  final WidgetStateProperty<double?>? trackOutlineWidth;

  /// The overlay color for interaction feedback, resolved per [WidgetState].
  ///
  /// Resolves based on:
  ///  * [WidgetState.hovered] -- hover overlay.
  ///  * [WidgetState.pressed] -- pressed overlay.
  final WidgetStateProperty<Color?>? overlayColor;

  /// Linearly interpolate between two [StreamToggleSwitchStyle] objects.
  static StreamToggleSwitchStyle? lerp(
    StreamToggleSwitchStyle? a,
    StreamToggleSwitchStyle? b,
    double t,
  ) => _$StreamToggleSwitchStyle.lerp(a, b, t);
}
