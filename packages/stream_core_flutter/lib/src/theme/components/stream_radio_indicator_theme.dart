import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';
import '../widget_state_utils.dart';

part 'stream_radio_indicator_theme.g.theme.dart';

/// Applies a radio indicator theme to descendant [StreamRadioIndicator]
/// widgets.
///
/// Wrap a subtree with [StreamRadioIndicatorTheme] to override radio
/// indicator styling. Access the merged theme using
/// [BuildContext.streamRadioIndicatorTheme].
///
/// {@tool snippet}
///
/// Use a green fill for the selected indicator in one section:
///
/// ```dart
/// StreamRadioIndicatorTheme(
///   data: StreamRadioIndicatorThemeData(
///     style: StreamRadioIndicatorStyle.from(selectedFillColor: Colors.green),
///   ),
///   child: StreamRadioIndicator(selected: true),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamRadioIndicatorThemeData], which describes the radio indicator
///    theme.
///  * [StreamRadioIndicator], the widget affected by this theme.
class StreamRadioIndicatorTheme extends InheritedTheme {
  /// Creates a radio indicator theme that controls descendant radio
  /// indicators.
  const StreamRadioIndicatorTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The radio indicator theme data for descendant widgets.
  final StreamRadioIndicatorThemeData data;

  /// Returns the [StreamRadioIndicatorThemeData] merged from local and global
  /// themes.
  ///
  /// Local values from the nearest [StreamRadioIndicatorTheme] ancestor take
  /// precedence over global values from [StreamTheme.of].
  static StreamRadioIndicatorThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamRadioIndicatorTheme>();
    return StreamTheme.of(context).radioIndicatorTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamRadioIndicatorTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamRadioIndicatorTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing [StreamRadioIndicator] widgets.
///
/// {@tool snippet}
///
/// Customize radio indicator appearance globally via [StreamTheme]:
///
/// ```dart
/// StreamTheme(
///   radioIndicatorTheme: StreamRadioIndicatorThemeData(
///     style: StreamRadioIndicatorStyle(
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
///  * [StreamRadioIndicatorTheme], for overriding theme in a widget subtree.
@themeGen
@immutable
class StreamRadioIndicatorThemeData with _$StreamRadioIndicatorThemeData {
  /// Creates radio indicator theme data with optional style overrides.
  const StreamRadioIndicatorThemeData({this.style});

  /// The visual styling for radio indicators.
  ///
  /// Contains the size, dot size, fill color, dot color and border.
  final StreamRadioIndicatorStyle? style;

  /// Linearly interpolate between two [StreamRadioIndicatorThemeData] objects.
  static StreamRadioIndicatorThemeData? lerp(
    StreamRadioIndicatorThemeData? a,
    StreamRadioIndicatorThemeData? b,
    double t,
  ) => _$StreamRadioIndicatorThemeData.lerp(a, b, t);
}

/// Visual styling properties for radio indicators.
///
/// Color and border properties are [WidgetStateProperty]-based and resolve
/// against [WidgetState.selected]: the indicator passes `{selected}` for the
/// selected entry and an empty set otherwise.
///
/// See also:
///
///  * [StreamRadioIndicatorThemeData], which wraps this style for theming.
///  * [StreamRadioIndicator], which uses this styling.
@themeGen
@immutable
class StreamRadioIndicatorStyle with _$StreamRadioIndicatorStyle {
  /// Creates radio indicator style properties.
  ///
  /// Color and border properties are [WidgetStateProperty]-based. For a
  /// simpler API that accepts plain values and builds state properties
  /// internally, use [StreamRadioIndicatorStyle.from].
  const StreamRadioIndicatorStyle({
    this.size,
    this.dotSize,
    this.fillColor,
    this.dotColor,
    WidgetStateProperty<BorderSide?>? side,
  }) : side = side as WidgetStateBorderSide?;

  /// Creates a [StreamRadioIndicatorStyle] from simple values.
  ///
  /// Parameters prefixed with `selected` apply to the selected indicator;
  /// unprefixed parameters apply to the unselected one.
  ///
  /// {@tool snippet}
  ///
  /// Create a style with a green fill when selected and a grey ring when not:
  ///
  /// ```dart
  /// StreamRadioIndicatorStyle.from(
  ///   selectedFillColor: Colors.green,
  ///   selectedDotColor: Colors.white,
  ///   side: BorderSide(color: Colors.grey),
  ///   selectedSide: BorderSide.none,
  /// )
  /// ```
  /// {@end-tool}
  factory StreamRadioIndicatorStyle.from({
    double? size,
    double? dotSize,
    Color? fillColor,
    Color? selectedFillColor,
    Color? dotColor,
    Color? selectedDotColor,
    BorderSide? side,
    BorderSide? selectedSide,
  }) {
    return StreamRadioIndicatorStyle(
      size: size,
      dotSize: dotSize,
      fillColor: WidgetStateUtils.resolveWith(fillColor, selectedFillColor, null),
      dotColor: WidgetStateUtils.resolveWith(dotColor, selectedDotColor, null),
      side: WidgetStateUtils.resolveSide(side, selectedSide, null),
    );
  }

  /// The diameter of the indicator.
  ///
  /// Falls back to 16.
  final double? size;

  /// The diameter of the dot drawn inside the selected indicator.
  ///
  /// Falls back to 8.
  final double? dotSize;

  /// The color that fills the indicator, resolved per [WidgetState].
  ///
  /// Falls back to the accent color when [WidgetState.selected], and
  /// transparent otherwise.
  final WidgetStateProperty<Color?>? fillColor;

  /// The color of the dot inside the indicator, resolved per [WidgetState].
  ///
  /// Falls back to a high-contrast color against the fill when
  /// [WidgetState.selected], and transparent otherwise, which hides the dot.
  final WidgetStateProperty<Color?>? dotColor;

  /// The border of the indicator, resolved per [WidgetState].
  ///
  /// Falls back to [BorderSide.none] when [WidgetState.selected], and the
  /// default border color otherwise.
  final WidgetStateBorderSide? side;

  /// Linearly interpolate between two [StreamRadioIndicatorStyle] objects.
  static StreamRadioIndicatorStyle? lerp(
    StreamRadioIndicatorStyle? a,
    StreamRadioIndicatorStyle? b,
    double t,
  ) => _$StreamRadioIndicatorStyle.lerp(a, b, t);
}
