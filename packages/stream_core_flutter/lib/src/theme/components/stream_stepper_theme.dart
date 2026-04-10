import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';
import 'stream_button_theme.dart';
import 'stream_text_input_theme.dart';

part 'stream_stepper_theme.g.theme.dart';

/// Applies a stepper theme to descendant [StreamStepper] widgets.
///
/// Wrap a subtree with [StreamStepperTheme] to override stepper styling.
/// Access the merged theme using [BuildContext.streamStepperTheme].
///
/// {@tool snippet}
///
/// Override stepper styling for a specific section:
///
/// ```dart
/// StreamStepperTheme(
///   data: StreamStepperThemeData(
///     style: StreamStepperStyle(
///       inputStyle: StreamTextInputStyle.collapsed(
///         textStyle: TextStyle(fontSize: 18),
///         constraints: BoxConstraints.tightFor(width: 48),
///       ),
///     ),
///   ),
///   child: StreamStepper(
///     value: 1,
///     onChanged: (value) {},
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamStepperThemeData], which describes the stepper theme.
///  * [StreamStepper], the widget affected by this theme.
class StreamStepperTheme extends InheritedTheme {
  /// Creates a stepper theme that controls descendant steppers.
  const StreamStepperTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The stepper theme data for descendant widgets.
  final StreamStepperThemeData data;

  /// Returns the [StreamStepperThemeData] merged from local and global themes.
  ///
  /// Local values from the nearest [StreamStepperTheme] ancestor take
  /// precedence over global values from [StreamTheme.of].
  static StreamStepperThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamStepperTheme>();
    return StreamTheme.of(context).stepperTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamStepperTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamStepperTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing [StreamStepper] widgets.
///
/// {@tool snippet}
///
/// Customize stepper appearance globally via [StreamTheme]:
///
/// ```dart
/// StreamTheme(
///   stepperTheme: StreamStepperThemeData(
///     style: StreamStepperStyle(
///       inputStyle: StreamTextInputStyle(
///         textStyle: TextStyle(fontSize: 18),
///       ),
///       spacing: 8,
///     ),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamStepperTheme], for overriding theme in a widget subtree.
///  * [StreamStepper], the widget that uses this theme data.
@themeGen
@immutable
class StreamStepperThemeData with _$StreamStepperThemeData {
  /// Creates stepper theme data with optional style overrides.
  const StreamStepperThemeData({this.style});

  /// The visual styling for steppers.
  final StreamStepperStyle? style;

  /// Linearly interpolate between two [StreamStepperThemeData] objects.
  static StreamStepperThemeData? lerp(
    StreamStepperThemeData? a,
    StreamStepperThemeData? b,
    double t,
  ) => _$StreamStepperThemeData.lerp(a, b, t);
}

/// Visual styling properties for [StreamStepper].
///
/// Controls both the text input area and the +/- control buttons. The stepper
/// reuses [StreamButton.icon] for the control buttons — [buttonStyle] provides
/// per-instance overrides that take precedence over the inherited
/// [StreamButtonTheme].
///
/// See also:
///
///  * [StreamStepperThemeData], which wraps this style for theming.
///  * [StreamStepper], which uses this styling.
///  * [StreamButtonThemeStyle], for available button style properties.
///  * [StreamTextInputStyle], for available text input style properties.
@themeGen
@immutable
class StreamStepperStyle with _$StreamStepperStyle {
  /// Creates stepper style properties.
  const StreamStepperStyle({
    this.buttonStyle,
    this.inputStyle,
    this.spacing,
  });

  /// Per-instance style overrides for the +/- control buttons.
  ///
  /// These properties take precedence over the inherited [StreamButtonTheme]
  /// values for the stepper's buttons specifically, without affecting other
  /// [StreamButton] instances in the tree.
  ///
  /// The stepper uses `StreamButton.icon(style: .secondary, type: .outline)`
  /// by default, so these overrides are applied on top of the secondary
  /// outline button defaults.
  ///
  /// {@tool snippet}
  ///
  /// Make the stepper buttons larger with a custom border:
  ///
  /// ```dart
  /// StreamStepperStyle(
  ///   buttonStyle: StreamButtonThemeStyle.from(
  ///     fixedSize: Size.square(48),
  ///     borderColor: Colors.blue,
  ///   ),
  /// )
  /// ```
  /// {@end-tool}
  final StreamButtonThemeStyle? buttonStyle;

  /// Style overrides for the text input area.
  ///
  /// Uses [StreamTextInputStyle] to configure text style, border radius,
  /// and other visual properties of the stepper's input field.
  ///
  /// Consider using [StreamTextInputStyle.collapsed] as a base, since the
  /// stepper input typically needs no borders or padding.
  final StreamTextInputStyle? inputStyle;

  /// The gap between the decrement button, text input, and increment button.
  ///
  /// Defaults to [StreamSpacing.xxs] (4).
  final double? spacing;

  /// Linearly interpolate between two [StreamStepperStyle] objects.
  static StreamStepperStyle? lerp(
    StreamStepperStyle? a,
    StreamStepperStyle? b,
    double t,
  ) => _$StreamStepperStyle.lerp(a, b, t);
}
