import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';
import '../widget_state_utils.dart';

part 'stream_radio_button_theme.g.theme.dart';

/// Predefined sizes for [StreamRadioButton].
///
/// Each size corresponds to a specific diameter in logical pixels.
///
/// See also:
///
///  * [StreamRadioButtonStyle.size], for setting a global default size.
enum StreamRadioButtonSize {
  /// Small radio button (16px).
  sm(16),

  /// Medium radio button (20px).
  md(20),

  /// Large radio button (24px).
  lg(24);

  /// Constructs a [StreamRadioButtonSize] with the given diameter.
  const StreamRadioButtonSize(this.value);

  /// The diameter of the radio button in logical pixels.
  final double value;
}

/// Applies a radio button theme to descendant [StreamRadioButton] widgets.
///
/// Wrap a subtree with [StreamRadioButtonTheme] to override radio button
/// styling. Access the merged theme using
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
///   child: StreamRadioButton(
///     selected: true,
///     onChanged: (_) {},
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamRadioButtonThemeData], which describes the radio button theme.
///  * [StreamRadioButton], the widget affected by this theme.
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

/// Theme data for customizing [StreamRadioButton] widgets.
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
///       fillColor: WidgetStateProperty.resolveWith((states) {
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
  ///
  /// Contains size, dot size, fill color, dot color, overlay color and border.
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
/// state-dependent styling (default, hover, pressed, focused, disabled,
/// selected). [WidgetState.selected] means the radio button is the selected
/// entry of its group.
///
/// See also:
///
///  * [StreamRadioButtonThemeData], which wraps this style for theming.
///  * [StreamRadioButton], which uses this styling.
@themeGen
@immutable
class StreamRadioButtonStyle with _$StreamRadioButtonStyle {
  /// Creates radio button style properties.
  ///
  /// Color and border properties are [WidgetStateProperty]-based for full
  /// state-level control. For a simpler API that accepts plain values and
  /// builds state properties internally, use [StreamRadioButtonStyle.from].
  const StreamRadioButtonStyle({
    this.size,
    this.dotSize,
    this.fillColor,
    this.dotColor,
    this.overlayColor,
    WidgetStateProperty<BorderSide?>? side,
  }) : side = side as WidgetStateBorderSide?;

  /// Creates a [StreamRadioButtonStyle] from simple values.
  ///
  /// Wraps plain colors and border sides into [WidgetStateProperty] values.
  ///
  /// State-specific parameters (prefixed with `selected`, `disabled`,
  /// `hovered` or `pressed`) take precedence for their respective states;
  /// unprefixed parameters are used as the default for all other states.
  ///
  /// {@tool snippet}
  ///
  /// Create a style with a green fill when selected and a grey ring when not:
  ///
  /// ```dart
  /// StreamRadioButtonStyle.from(
  ///   fillColor: Colors.transparent,
  ///   selectedFillColor: Colors.green,
  ///   dotColor: Colors.white,
  ///   side: BorderSide(color: Colors.grey),
  ///   selectedSide: BorderSide.none,
  /// )
  /// ```
  /// {@end-tool}
  factory StreamRadioButtonStyle.from({
    StreamRadioButtonSize? size,
    double? dotSize,
    Color? fillColor,
    Color? selectedFillColor,
    Color? disabledFillColor,
    Color? dotColor,
    Color? selectedDotColor,
    Color? disabledDotColor,
    Color? overlayColor,
    Color? hoveredOverlayColor,
    Color? pressedOverlayColor,
    BorderSide? side,
    BorderSide? selectedSide,
    BorderSide? disabledSide,
  }) {
    return StreamRadioButtonStyle(
      size: size,
      dotSize: dotSize,
      fillColor: WidgetStateUtils.resolveWith(fillColor, selectedFillColor, disabledFillColor),
      dotColor: WidgetStateUtils.resolveWith(dotColor, selectedDotColor, disabledDotColor),
      overlayColor: WidgetStateUtils.resolveOverlay(overlayColor, hoveredOverlayColor, pressedOverlayColor),
      side: WidgetStateUtils.resolveSide(side, selectedSide, disabledSide),
    );
  }

  /// The size of radio buttons.
  ///
  /// Falls back to [StreamRadioButtonSize.lg].
  final StreamRadioButtonSize? size;

  /// The diameter of the dot inside the radio button.
  ///
  /// If null, defaults to 10 for [StreamRadioButtonSize.lg] and 8 for the
  /// smaller sizes.
  final double? dotSize;

  /// The color that fills the radio button, resolved per [WidgetState].
  ///
  /// Resolves based on:
  ///  * [WidgetState.selected] -- accent color.
  ///  * [WidgetState.disabled] + [WidgetState.selected] -- disabled
  ///    background.
  ///
  /// Transparent when not selected, giving a border-only appearance.
  final WidgetStateProperty<Color?>? fillColor;

  /// The color of the dot inside the radio button, resolved per
  /// [WidgetState].
  ///
  /// Resolves based on:
  ///  * [WidgetState.selected] -- high-contrast color against the fill.
  ///  * [WidgetState.disabled] + [WidgetState.selected] -- muted color.
  ///
  /// Transparent when not selected so the dot is hidden.
  final WidgetStateProperty<Color?>? dotColor;

  /// The overlay color for interaction feedback, resolved per [WidgetState].
  ///
  /// Resolves based on:
  ///  * [WidgetState.hovered] -- hover overlay.
  ///  * [WidgetState.pressed] -- pressed overlay.
  final WidgetStateProperty<Color?>? overlayColor;

  /// The border of the radio button, resolved per [WidgetState].
  ///
  /// Visible when not selected, [BorderSide.none] when selected, a wider
  /// focus ring when focused, and uses the disabled border color when
  /// disabled.
  final WidgetStateBorderSide? side;

  /// Linearly interpolate between two [StreamRadioButtonStyle] objects.
  static StreamRadioButtonStyle? lerp(
    StreamRadioButtonStyle? a,
    StreamRadioButtonStyle? b,
    double t,
  ) => _$StreamRadioButtonStyle.lerp(a, b, t);
}
