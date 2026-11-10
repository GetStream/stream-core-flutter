import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../../components/common/stream_select_input.dart';
import '../../components/common/stream_text_input.dart';
import '../primitives/stream_radius.dart';
import '../semantics/stream_color_scheme.dart';
import '../semantics/stream_text_theme.dart';
import '../stream_theme.dart';

part 'stream_select_input_theme.g.theme.dart';

/// Applies a select input theme to descendant [StreamSelectInput] widgets.
///
/// Wrap a subtree with [StreamSelectInputTheme] to override select input
/// styling. Access the merged theme using
/// [BuildContext.streamSelectInputTheme].
///
/// {@tool snippet}
///
/// Override select input styling for a specific section:
///
/// ```dart
/// StreamSelectInputTheme(
///   data: StreamSelectInputThemeData(
///     style: StreamSelectInputStyle(
///       borderRadius: BorderRadius.all(Radius.circular(8)),
///       contentPadding: EdgeInsets.all(12),
///     ),
///   ),
///   child: StreamSelectInput(
///     hintText: 'Choose a language',
///     onPressed: () {},
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamSelectInputThemeData], which describes the select input theme.
///  * [StreamSelectInput], the widget affected by this theme.
class StreamSelectInputTheme extends InheritedTheme {
  /// Creates a select input theme that controls descendant select inputs.
  const StreamSelectInputTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The select input theme data for descendant widgets.
  final StreamSelectInputThemeData data;

  /// Returns the [StreamSelectInputThemeData] merged from local and global
  /// themes.
  ///
  /// Local values from the nearest [StreamSelectInputTheme] ancestor take
  /// precedence over global values from [StreamTheme.of].
  static StreamSelectInputThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamSelectInputTheme>();
    return StreamTheme.of(context).selectInputTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamSelectInputTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamSelectInputTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing [StreamSelectInput] widgets.
///
/// {@tool snippet}
///
/// Customize select input appearance globally via [StreamTheme]:
///
/// ```dart
/// StreamTheme(
///   selectInputTheme: StreamSelectInputThemeData(
///     style: StreamSelectInputStyle(
///       border: BorderSide(color: Colors.grey),
///       activeBorder: BorderSide(color: Colors.blue),
///     ),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamSelectInputTheme], for overriding theme in a widget subtree.
///  * [StreamSelectInput], the widget that uses this theme data.
@themeGen
@immutable
class StreamSelectInputThemeData with _$StreamSelectInputThemeData {
  /// Creates select input theme data with optional style overrides.
  const StreamSelectInputThemeData({this.style});

  /// The visual styling for select inputs.
  final StreamSelectInputStyle? style;

  /// Linearly interpolate between two [StreamSelectInputThemeData] objects.
  static StreamSelectInputThemeData? lerp(
    StreamSelectInputThemeData? a,
    StreamSelectInputThemeData? b,
    double t,
  ) => _$StreamSelectInputThemeData.lerp(a, b, t);
}

/// Visual styling properties for [StreamSelectInput].
///
/// Controls the border, interaction rings, colors and text styles of the
/// field. The field names match [StreamTextInputStyle] where the two overlap,
/// so a select and a text input in the same form can be styled alike.
///
/// The base border carries the disabled, error and active (menu open) states.
/// Hover and focus do not change it; they draw a ring over the field instead,
/// centered on its outer edge.
///
/// Helper text is rendered by [StreamHelperText], which takes its styling from
/// [StreamTextInputStyle].
///
/// See also:
///
///  * [StreamSelectInputThemeData], which wraps this style for theming.
///  * [StreamSelectInput], which uses this styling.
@themeGen
@immutable
class StreamSelectInputStyle with _$StreamSelectInputStyle {
  /// Creates select input style properties.
  const StreamSelectInputStyle({
    this.textStyle,
    this.hintStyle,
    this.labelStyle,
    this.iconColor,
    this.iconSize,
    this.borderRadius,
    this.border,
    this.activeBorder,
    this.errorBorder,
    this.disabledBorder,
    this.hoverRing,
    this.focusRing,
    this.fillColor,
    this.contentPadding,
  });

  /// The text style for the selected value.
  ///
  /// Supports [WidgetStateTextStyle] for per-state styling (e.g. disabled).
  /// When the field is disabled, the default resolves to
  /// [StreamColorScheme.textDisabled].
  ///
  /// Defaults to [StreamTextTheme.bodyDefault] with
  /// [StreamColorScheme.textPrimary].
  final TextStyle? textStyle;

  /// The text style for the hint shown while nothing is selected.
  ///
  /// Supports [WidgetStateTextStyle] for per-state styling (e.g. disabled).
  /// When the field is disabled, the default resolves to
  /// [StreamColorScheme.textDisabled].
  ///
  /// Defaults to [StreamTextTheme.bodyDefault] with
  /// [StreamColorScheme.textTertiary].
  final TextStyle? hintStyle;

  /// The text style for the persistent label rendered above the field.
  ///
  /// Supports [WidgetStateTextStyle] for per-state styling (e.g. disabled).
  /// When the field is disabled, the default resolves to
  /// [StreamColorScheme.textDisabled].
  ///
  /// Defaults to [StreamTextTheme.headingXs] with
  /// [StreamColorScheme.textPrimary].
  final TextStyle? labelStyle;

  /// The color for the leading widget and the caret.
  ///
  /// Supports [WidgetStateColor] for per-state styling (e.g. disabled).
  ///
  /// Defaults to the color of the text the field currently shows: the
  /// [textStyle] color when a value is selected, the [hintStyle] color
  /// otherwise.
  final Color? iconColor;

  /// The size for the leading widget and the caret.
  ///
  /// Defaults to `20`.
  final double? iconSize;

  /// The border radius of the field, also used for the interaction rings.
  ///
  /// Defaults to [StreamRadius.lg].
  final BorderRadiusGeometry? borderRadius;

  /// The border side while no other state applies.
  ///
  /// [StreamSelectInputType.ghost] draws this side transparent, so only the
  /// other states show a border.
  ///
  /// Defaults to `BorderSide(color: StreamColorScheme.borderDefault)`.
  final BorderSide? border;

  /// The border side while the field's menu is open.
  ///
  /// Defaults to `BorderSide(color: StreamColorScheme.borderActive)`.
  final BorderSide? activeBorder;

  /// The border side when [StreamHelperState.error] is active.
  ///
  /// Takes precedence over [activeBorder].
  ///
  /// Defaults to `BorderSide(color: StreamColorScheme.borderError)`.
  final BorderSide? errorBorder;

  /// The border side when the field is disabled.
  ///
  /// Takes precedence over every other border.
  ///
  /// Defaults to `BorderSide(color: StreamColorScheme.borderDisabled)`.
  final BorderSide? disabledBorder;

  /// The ring drawn over the field while a pointer hovers it.
  ///
  /// The ring is centered on the field's outer edge, so half of its width
  /// paints outside the field.
  ///
  /// Defaults to `BorderSide(color: StreamColorScheme.borderHover, width: 2)`.
  final BorderSide? hoverRing;

  /// The ring drawn over the field while it has keyboard focus.
  ///
  /// Takes precedence over [hoverRing]. The ring is centered on the field's
  /// outer edge, so half of its width paints outside the field.
  ///
  /// Defaults to `BorderSide(color: StreamColorScheme.borderFocus, width: 2)`.
  final BorderSide? focusRing;

  /// The fill color of the field.
  ///
  /// If null, the field is not filled.
  final Color? fillColor;

  /// The padding inside the field.
  ///
  /// Defaults to `EdgeInsets.symmetric(vertical: spacing.sm, horizontal: spacing.md)`,
  /// the same as [StreamTextInputStyle.contentPadding].
  final EdgeInsetsGeometry? contentPadding;

  /// Linearly interpolate between two [StreamSelectInputStyle] objects.
  static StreamSelectInputStyle? lerp(
    StreamSelectInputStyle? a,
    StreamSelectInputStyle? b,
    double t,
  ) => _$StreamSelectInputStyle.lerp(a, b, t);
}
