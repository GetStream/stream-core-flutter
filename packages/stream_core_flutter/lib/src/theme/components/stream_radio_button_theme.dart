import 'dart:ui' show lerpDouble;

import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';

part 'stream_radio_button_theme.g.theme.dart';

/// The size of a [StreamRadioButton].
///
/// Each size pairs the diameter of the radio button with the diameter of the
/// dot it shows when selected. Use one of the presets, or create a size for a
/// diameter the presets don't cover.
///
/// See also:
///
///  * [StreamRadioButtonStyle.size], for setting a default size in a theme.
@immutable
class StreamRadioButtonSize {
  /// Creates a radio button size with the given [diameter] and [dotDiameter].
  const StreamRadioButtonSize({required this.diameter, required this.dotDiameter});

  /// Small radio button: 16px with an 8px dot.
  static const sm = StreamRadioButtonSize(diameter: 16, dotDiameter: 8);

  /// Medium radio button: 20px with an 8px dot.
  static const md = StreamRadioButtonSize(diameter: 20, dotDiameter: 8);

  /// Large radio button: 24px with a 10px dot.
  static const lg = StreamRadioButtonSize(diameter: 24, dotDiameter: 10);

  /// The predefined sizes, from small to large.
  static const List<StreamRadioButtonSize> values = [sm, md, lg];

  /// The diameter of the radio button in logical pixels.
  final double diameter;

  /// The diameter of the dot shown when selected, in logical pixels.
  final double dotDiameter;

  /// Linearly interpolates between two [StreamRadioButtonSize]s.
  static StreamRadioButtonSize? lerp(StreamRadioButtonSize? a, StreamRadioButtonSize? b, double t) {
    if (identical(a, b)) return a;
    if (a == null || b == null) return t < 0.5 ? a : b;
    return StreamRadioButtonSize(
      diameter: lerpDouble(a.diameter, b.diameter, t)!,
      dotDiameter: lerpDouble(a.dotDiameter, b.dotDiameter, t)!,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is StreamRadioButtonSize && other.diameter == diameter && other.dotDiameter == dotDiameter;

  @override
  int get hashCode => Object.hash(diameter, dotDiameter);

  @override
  String toString() => 'StreamRadioButtonSize(diameter: $diameter, dotDiameter: $dotDiameter)';
}

/// Applies a radio button theme to descendant [StreamRadioButton] widgets.
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
/// built-in default for that state. The keyboard focus ring is drawn on top of
/// [side] and is not part of this style.
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
  /// state-level control. [StreamRadioButtonStyle.from] builds them from plain
  /// values instead.
  const StreamRadioButtonStyle({
    this.size,
    this.fillColor,
    this.dotColor,
    this.overlayColor,
    this.side,
  });

  /// Creates a [StreamRadioButtonStyle] from simple values.
  ///
  /// Each parameter sets the value for one state:
  ///
  ///  * Unprefixed parameters apply to an enabled, unselected radio button
  ///    (and, for [overlayColor], one that is neither hovered nor pressed).
  ///  * `selected` parameters apply to an enabled, selected radio button.
  ///  * `disabled` parameters apply to a disabled radio button, selected or
  ///    not.
  ///  * `hovered` and `pressed` parameters apply to the overlay in those
  ///    states; pressed wins over hovered.
  ///
  /// A state whose parameter is null keeps the built-in default, so
  /// `StreamRadioButtonStyle.from(selectedFillColor: Colors.green)` changes
  /// only the fill of an enabled, selected radio button.
  ///
  /// {@tool snippet}
  ///
  /// Create a style with a green fill when selected and a grey ring when not:
  ///
  /// ```dart
  /// StreamRadioButtonStyle.from(
  ///   selectedFillColor: Colors.green,
  ///   selectedDotColor: Colors.white,
  ///   side: BorderSide(color: Colors.grey),
  /// )
  /// ```
  /// {@end-tool}
  factory StreamRadioButtonStyle.from({
    StreamRadioButtonSize? size,
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
      fillColor: _byState(fillColor, selectedFillColor, disabledFillColor),
      dotColor: _byState(dotColor, selectedDotColor, disabledDotColor),
      overlayColor: switch ((overlayColor, hoveredOverlayColor, pressedOverlayColor)) {
        (null, null, null) => null,
        _ => WidgetStateProperty<Color?>.fromMap({
          WidgetState.pressed: pressedOverlayColor,
          WidgetState.hovered: hoveredOverlayColor,
          WidgetState.any: overlayColor,
        }),
      },
      side: switch (_byState(side, selectedSide, disabledSide)) {
        final byState? => WidgetStateBorderSide.resolveWith(byState.resolve),
        null => null,
      },
    );
  }

  // Maps each value to its own state only, leaving null (the default) for
  // every state whose value is not given. Disabled wins over selected.
  static WidgetStateProperty<T?>? _byState<T>(T? value, T? selected, T? disabled) {
    if (value == null && selected == null && disabled == null) return null;
    return WidgetStateProperty<T?>.fromMap({
      WidgetState.disabled: disabled,
      WidgetState.selected: selected,
      WidgetState.any: value,
    });
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
  final WidgetStateProperty<Color?>? fillColor;

  /// The color of the dot inside the radio button, resolved per
  /// [WidgetState].
  ///
  /// If null, defaults to a color that contrasts with the accent fill when
  /// selected, a muted color when selected and disabled, and transparent when
  /// not selected, which hides the dot.
  final WidgetStateProperty<Color?>? dotColor;

  /// The overlay color for interaction feedback, resolved per [WidgetState].
  ///
  /// If null, defaults to the hover overlay when hovered, the pressed overlay
  /// when pressed, and transparent otherwise.
  final WidgetStateProperty<Color?>? overlayColor;

  /// The border of the radio button, resolved per [WidgetState].
  ///
  /// If null, defaults to the default border color when not selected, the
  /// disabled border color when disabled and not selected, and
  /// [BorderSide.none] when selected.
  final WidgetStateBorderSide? side;

  /// Linearly interpolate between two [StreamRadioButtonStyle] objects.
  static StreamRadioButtonStyle? lerp(
    StreamRadioButtonStyle? a,
    StreamRadioButtonStyle? b,
    double t,
  ) => _$StreamRadioButtonStyle.lerp(a, b, t);
}
