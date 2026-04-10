import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';
import '../widget_state_utils.dart';

part 'stream_switch_theme.g.theme.dart';

/// Applies a toggle switch theme to descendant [StreamSwitch] widgets.
///
/// Wrap a subtree with [StreamSwitchTheme] to override toggle switch
/// styling. Access the merged theme using
/// [BuildContext.streamToggleSwitchTheme].
///
/// {@tool snippet}
///
/// Override toggle switch styling for a specific section:
///
/// ```dart
/// StreamSwitchTheme(
///   data: StreamSwitchThemeData(
///     style: StreamSwitchStyle(
///       trackColor: WidgetStateProperty.resolveWith((states) {
///         if (states.contains(WidgetState.selected)) {
///           return Colors.green;
///         }
///         return Colors.grey;
///       }),
///     ),
///   ),
///   child: StreamSwitch(
///     value: true,
///     onChanged: (value) {},
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamSwitchThemeData], which describes the toggle switch theme.
///  * [StreamSwitch], the widget affected by this theme.
class StreamSwitchTheme extends InheritedTheme {
  /// Creates a toggle switch theme that controls descendant toggle switches.
  const StreamSwitchTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The toggle switch theme data for descendant widgets.
  final StreamSwitchThemeData data;

  /// Returns the [StreamSwitchThemeData] merged from local and global
  /// themes.
  ///
  /// Local values from the nearest [StreamSwitchTheme] ancestor take
  /// precedence over global values from [StreamTheme.of].
  static StreamSwitchThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamSwitchTheme>();
    return StreamTheme.of(context).switchTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamSwitchTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamSwitchTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing [StreamSwitch] widgets.
///
/// {@tool snippet}
///
/// Customize toggle switch appearance globally via [StreamTheme]:
///
/// ```dart
/// StreamTheme(
///   toggleSwitchTheme: StreamSwitchThemeData(
///     style: StreamSwitchStyle.from(
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
///  * [StreamSwitchTheme], for overriding theme in a widget subtree.
@themeGen
@immutable
class StreamSwitchThemeData with _$StreamSwitchThemeData {
  /// Creates toggle switch theme data with optional style overrides.
  const StreamSwitchThemeData({this.style});

  /// The visual styling for toggle switches.
  ///
  /// Contains track color, thumb color, overlay color, and track outline color.
  final StreamSwitchStyle? style;

  /// Linearly interpolate between two [StreamSwitchThemeData] objects.
  static StreamSwitchThemeData? lerp(
    StreamSwitchThemeData? a,
    StreamSwitchThemeData? b,
    double t,
  ) => _$StreamSwitchThemeData.lerp(a, b, t);
}

/// Visual styling properties for toggle switches.
///
/// Defines the appearance of toggle switches including track, thumb, overlay,
/// and outline colors. Color properties are [WidgetStateProperty]-based for
/// state-dependent styling (default, hover, pressed, disabled, selected).
///
/// See also:
///
///  * [StreamSwitchThemeData], which wraps this style for theming.
///  * [StreamSwitch], which uses this styling.
@themeGen
@immutable
class StreamSwitchStyle with _$StreamSwitchStyle {
  /// Creates toggle switch style properties.
  ///
  /// Color properties are [WidgetStateProperty]-based for full state-level
  /// control. For a simpler API that accepts plain values and builds state
  /// properties internally, use [StreamSwitchStyle.from].
  const StreamSwitchStyle({
    this.trackColor,
    this.thumbColor,
    this.trackOutlineColor,
    this.trackOutlineWidth,
    this.overlayColor,
  });

  /// Creates a [StreamSwitchStyle] from simple values.
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
  /// StreamSwitchStyle.from(
  ///   trackColor: Colors.grey,
  ///   selectedTrackColor: Colors.green,
  ///   disabledTrackColor: Colors.grey.shade200,
  ///   thumbColor: Colors.white,
  ///   hoveredOverlayColor: Colors.green.withOpacity(0.08),
  ///   pressedOverlayColor: Colors.green.withOpacity(0.1),
  /// )
  /// ```
  /// {@end-tool}
  factory StreamSwitchStyle.from({
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
    return StreamSwitchStyle(
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

  /// Linearly interpolate between two [StreamSwitchStyle] objects.
  static StreamSwitchStyle? lerp(
    StreamSwitchStyle? a,
    StreamSwitchStyle? b,
    double t,
  ) => _$StreamSwitchStyle.lerp(a, b, t);
}
