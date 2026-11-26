import 'dart:ui' show lerpDouble;

import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';
import '../widget_state_utils.dart';

part 'stream_radio_button_theme.g.theme.dart';

/// The size of a [StreamRadioButton] or [StreamRadioIndicator].
///
/// Each size pairs the diameter of the radio button with the diameter of the
/// indicator it shows when selected. Use one of the presets, or create a size
/// for a diameter the presets don't cover.
///
/// See also:
///
///  * [StreamRadioButtonStyle.size], for setting a default size in a theme.
@immutable
class StreamRadioButtonSize {
  /// Creates a radio button size with the given [diameter] and
  /// [indicatorDiameter].
  const StreamRadioButtonSize({required this.diameter, required this.indicatorDiameter});

  /// Small radio button: 16px with an 8px indicator.
  static const sm = StreamRadioButtonSize(diameter: 16, indicatorDiameter: 8);

  /// Medium radio button: 20px with an 8px indicator.
  static const md = StreamRadioButtonSize(diameter: 20, indicatorDiameter: 8);

  /// Large radio button: 24px with a 10px indicator.
  static const lg = StreamRadioButtonSize(diameter: 24, indicatorDiameter: 10);

  /// The predefined sizes, from small to large.
  static const List<StreamRadioButtonSize> values = [sm, md, lg];

  /// The diameter of the radio button in logical pixels.
  final double diameter;

  /// The diameter of the indicator shown when selected, in logical pixels.
  final double indicatorDiameter;

  /// Linearly interpolates between two [StreamRadioButtonSize]s.
  static StreamRadioButtonSize? lerp(StreamRadioButtonSize? a, StreamRadioButtonSize? b, double t) {
    if (identical(a, b)) return a;
    if (a == null || b == null) return t < 0.5 ? a : b;
    return StreamRadioButtonSize(
      diameter: lerpDouble(a.diameter, b.diameter, t)!,
      indicatorDiameter: lerpDouble(a.indicatorDiameter, b.indicatorDiameter, t)!,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is StreamRadioButtonSize && other.diameter == diameter && other.indicatorDiameter == indicatorDiameter;

  @override
  int get hashCode => Object.hash(diameter, indicatorDiameter);

  @override
  String toString() => 'StreamRadioButtonSize(diameter: $diameter, indicatorDiameter: $indicatorDiameter)';
}

/// Applies a radio button theme to descendant [StreamRadioButton] and
/// [StreamRadioIndicator] widgets.
///
/// A [StreamRadioButtonTheme] overrides the radio button styling of its
/// subtree. Access the merged theme using
/// [BuildContext.streamRadioButtonTheme].
///
/// {@tool snippet}
///
/// Use small radio buttons for a specific section:
///
/// ```dart
/// StreamRadioButtonTheme(
///   data: StreamRadioButtonThemeData(
///     style: StreamRadioButtonStyle(size: StreamRadioButtonSize.sm),
///   ),
///   child: StreamRadioButton(value: option),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamRadioButtonThemeData], which describes the radio button theme.
///  * [StreamRadioButton] and [StreamRadioIndicator], the widgets affected by
///    this theme.
class StreamRadioButtonTheme extends InheritedTheme {
  /// Creates a radio button theme that controls descendant radio buttons.
  const StreamRadioButtonTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The radio button theme data for descendant widgets.
  final StreamRadioButtonThemeData data;

  /// Returns the [StreamRadioButtonThemeData] merged from local and global
  /// themes.
  ///
  /// Local values from the nearest [StreamRadioButtonTheme] ancestor take
  /// precedence over global values from [StreamTheme.of].
  static StreamRadioButtonThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamRadioButtonTheme>();
    return StreamTheme.of(context).radioButtonTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamRadioButtonTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamRadioButtonTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing [StreamRadioButton] and [StreamRadioIndicator]
/// widgets.
///
/// {@tool snippet}
///
/// Customize radio button appearance globally via [StreamTheme]:
///
/// ```dart
/// StreamTheme(
///   radioButtonTheme: StreamRadioButtonThemeData(
///     style: StreamRadioButtonStyle(
///       size: StreamRadioButtonSize.sm,
///       backgroundColor: WidgetStateProperty.resolveWith((states) {
///         if (states.contains(WidgetState.selected)) return Colors.green;
///         return Colors.transparent;
///       }),
///     ),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamRadioButtonTheme], for overriding theme in a widget subtree.
@themeGen
@immutable
class StreamRadioButtonThemeData with _$StreamRadioButtonThemeData {
  /// Creates radio button theme data with optional style overrides.
  const StreamRadioButtonThemeData({this.style});

  /// The visual styling for radio buttons.
  final StreamRadioButtonStyle? style;

  /// Linearly interpolate between two [StreamRadioButtonThemeData] objects.
  static StreamRadioButtonThemeData? lerp(
    StreamRadioButtonThemeData? a,
    StreamRadioButtonThemeData? b,
    double t,
  ) => _$StreamRadioButtonThemeData.lerp(a, b, t);
}

/// Visual styling properties for radio buttons.
///
/// Defines the appearance of radio buttons including size, colors and border.
/// Color and border properties are [WidgetStateProperty]-based for
/// state-dependent styling (default, hover, pressed, disabled, selected).
/// [WidgetState.selected] means the radio button is the selected entry of its
/// group.
///
/// A property that is null, or that resolves to null for a state, uses the
/// built-in default for that state.
///
/// See also:
///
///  * [StreamRadioButtonThemeData], which wraps this style for theming.
///  * [StreamRadioButton] and [StreamRadioIndicator], which use this styling.
@themeGen
@immutable
class StreamRadioButtonStyle with _$StreamRadioButtonStyle {
  /// Creates radio button style properties.
  ///
  /// Color and border properties are [WidgetStateProperty]-based for full
  /// state-level control. [StreamRadioButtonStyle.from] builds them from plain
  /// values instead.
  const StreamRadioButtonStyle({
    this.size,
    this.backgroundColor,
    this.indicatorColor,
    this.overlayColor,
    this.side,
  });

  /// Creates a [StreamRadioButtonStyle] from simple values.
  ///
  /// State-specific parameters take precedence for their states, and
  /// unprefixed parameters are the default for all other states:
  ///
  ///  * `selected` parameters apply to an enabled, selected radio button.
  ///  * `disabled` parameters apply to a disabled radio button, selected or
  ///    not.
  ///  * `hovered` and `pressed` parameters apply to the overlay in those
  ///    states; pressed wins over hovered.
  ///
  /// So `StreamRadioButtonStyle.from(backgroundColor: Colors.red)` fills a
  /// selected and a disabled radio button red too, unless
  /// `selectedBackgroundColor` or `disabledBackgroundColor` is also given.
  /// A property whose parameters are all null keeps the built-in default, and
  /// a disabled radio button keeps its default side unless `disabledSide` is
  /// given. The side parameters also apply while focused, so they replace the
  /// default focus ring.
  ///
  /// {@tool snippet}
  ///
  /// Create a style with a green background when selected and a grey ring
  /// when not:
  ///
  /// ```dart
  /// StreamRadioButtonStyle.from(
  ///   selectedBackgroundColor: Colors.green,
  ///   selectedIndicatorColor: Colors.white,
  ///   side: BorderSide(color: Colors.grey),
  ///   selectedSide: BorderSide.none,
  /// )
  /// ```
  /// {@end-tool}
  factory StreamRadioButtonStyle.from({
    StreamRadioButtonSize? size,
    Color? backgroundColor,
    Color? selectedBackgroundColor,
    Color? disabledBackgroundColor,
    Color? indicatorColor,
    Color? selectedIndicatorColor,
    Color? disabledIndicatorColor,
    Color? overlayColor,
    Color? hoveredOverlayColor,
    Color? pressedOverlayColor,
    BorderSide? side,
    BorderSide? selectedSide,
    BorderSide? disabledSide,
  }) {
    return StreamRadioButtonStyle(
      size: size,
      backgroundColor: WidgetStateUtils.resolveWith(backgroundColor, selectedBackgroundColor, disabledBackgroundColor),
      indicatorColor: WidgetStateUtils.resolveWith(indicatorColor, selectedIndicatorColor, disabledIndicatorColor),
      overlayColor: WidgetStateUtils.resolveOverlay(overlayColor, hoveredOverlayColor, pressedOverlayColor),
      side: WidgetStateUtils.resolveSide(side, selectedSide, disabledSide),
    );
  }

  /// The size of radio buttons.
  ///
  /// If null, defaults to [StreamRadioButtonSize.lg].
  final StreamRadioButtonSize? size;

  /// The color that fills the radio button, resolved per [WidgetState].
  ///
  /// If null, defaults to the accent color when selected, the disabled
  /// background when selected and disabled, and transparent when not
  /// selected.
  final WidgetStateProperty<Color?>? backgroundColor;

  /// The color of the indicator inside the radio button, resolved per
  /// [WidgetState].
  ///
  /// If null, defaults to a color that contrasts with the accent background
  /// when selected, a muted color when selected and disabled, and transparent
  /// when not selected, which hides the indicator.
  final WidgetStateProperty<Color?>? indicatorColor;

  /// The overlay color for interaction feedback, resolved per [WidgetState].
  ///
  /// If null, defaults to the hover overlay when hovered, the pressed overlay
  /// when pressed, and transparent otherwise.
  final WidgetStateProperty<Color?>? overlayColor;

  /// The border of the radio button, resolved per [WidgetState].
  ///
  /// If null, defaults to the default border color when not selected, the
  /// disabled border color when disabled and not selected, and
  /// [BorderSide.none] when selected, and a focus ring when focused.
  final WidgetStateBorderSide? side;

  /// Linearly interpolate between two [StreamRadioButtonStyle] objects.
  static StreamRadioButtonStyle? lerp(
    StreamRadioButtonStyle? a,
    StreamRadioButtonStyle? b,
    double t,
  ) => _$StreamRadioButtonStyle.lerp(a, b, t);
}
