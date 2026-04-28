import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../../../stream_core_flutter.dart';

part 'stream_text_input_theme.g.theme.dart';

/// Applies a text input theme to descendant [StreamTextInput] widgets.
///
/// Wrap a subtree with [StreamTextInputTheme] to override text input styling.
/// Access the merged theme using [BuildContext.streamTextInputTheme].
///
/// {@tool snippet}
///
/// Override input styling for a specific section:
///
/// ```dart
/// StreamTextInputTheme(
///   data: StreamTextInputThemeData(
///     style: StreamTextInputStyle(
///       borderRadius: BorderRadius.all(Radius.circular(8)),
///       contentPadding: EdgeInsets.all(12),
///     ),
///   ),
///   child: StreamTextInput(
///     hintText: 'Search...',
///     onChanged: (value) {},
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamTextInputThemeData], which describes the text input theme.
///  * [StreamTextInput], the widget affected by this theme.
class StreamTextInputTheme extends InheritedTheme {
  /// Creates a text input theme that controls descendant text inputs.
  const StreamTextInputTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The text input theme data for descendant widgets.
  final StreamTextInputThemeData data;

  /// Returns the [StreamTextInputThemeData] merged from local and global
  /// themes.
  ///
  /// Local values from the nearest [StreamTextInputTheme] ancestor take
  /// precedence over global values from [StreamTheme.of].
  static StreamTextInputThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamTextInputTheme>();
    return StreamTheme.of(context).textInputTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamTextInputTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamTextInputTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing [StreamTextInput] widgets.
///
/// {@tool snippet}
///
/// Customize text input appearance globally via [StreamTheme]:
///
/// ```dart
/// StreamTheme(
///   textInputTheme: StreamTextInputThemeData(
///     style: StreamTextInputStyle(
///       border: BorderSide(color: Colors.grey),
///       focusBorder: BorderSide(color: Colors.blue),
///     ),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamTextInputTheme], for overriding theme in a widget subtree.
///  * [StreamTextInput], the widget that uses this theme data.
@themeGen
@immutable
class StreamTextInputThemeData with _$StreamTextInputThemeData {
  /// Creates text input theme data with optional style overrides.
  const StreamTextInputThemeData({this.style});

  /// The visual styling for text inputs.
  final StreamTextInputStyle? style;

  /// Linearly interpolate between two [StreamTextInputThemeData] objects.
  static StreamTextInputThemeData? lerp(
    StreamTextInputThemeData? a,
    StreamTextInputThemeData? b,
    double t,
  ) => _$StreamTextInputThemeData.lerp(a, b, t);
}

/// Visual styling properties for [StreamTextInput].
///
/// Controls the border, colors, text styles, and helper text appearance.
/// All border properties use outline-only borders (rounded rectangle) —
/// the design system does not support underline or other border styles.
///
/// Helper text follows a unified state model with three variants:
/// [StreamHelperState.info], [StreamHelperState.error], and
/// [StreamHelperState.success]. Each state resolves to a default icon and
/// text color from the design tokens.
///
/// See also:
///
///  * [StreamTextInputThemeData], which wraps this style for theming.
///  * [StreamTextInput], which uses this styling.
@themeGen
@immutable
class StreamTextInputStyle with _$StreamTextInputStyle {
  /// Creates text input style properties.
  const StreamTextInputStyle({
    this.textStyle,
    this.hintStyle,
    this.iconColor,
    this.iconSize,
    this.cursorColor,
    this.cursorErrorColor,
    this.cursorWidth,
    this.cursorHeight,
    this.cursorRadius,
    this.helperInfoStyle,
    this.helperErrorStyle,
    this.helperSuccessStyle,
    this.borderRadius,
    this.border,
    this.focusBorder,
    this.errorBorder,
    this.fillColor,
    this.contentPadding,
    this.constraints,
    this.helperIconSize,
    this.helperMaxLines,
  });

  /// Creates a minimal style with no borders and no padding.
  ///
  /// Removes all visual decoration — borders (default, focus, and error) are
  /// fixed to [BorderSide.none] and content padding is fixed to
  /// [EdgeInsets.zero].
  ///
  /// Useful for embedding a [StreamTextInput] inside another component
  /// where the outer widget provides its own decoration.
  const StreamTextInputStyle.collapsed({
    this.textStyle,
    this.hintStyle,
    this.iconColor,
    this.iconSize,
    this.cursorColor,
    this.cursorErrorColor,
    this.cursorWidth,
    this.cursorHeight,
    this.cursorRadius,
    this.helperInfoStyle,
    this.helperErrorStyle,
    this.helperSuccessStyle,
    this.borderRadius,
    this.fillColor,
    this.constraints,
    this.helperIconSize,
    this.helperMaxLines,
  }) : border = .none,
       focusBorder = .none,
       errorBorder = .none,
       contentPadding = .zero;

  /// The default text style for the input text.
  ///
  /// Supports [WidgetStateTextStyle] for per-state styling (e.g. disabled).
  /// When the input is disabled, the default resolves to
  /// [StreamColorScheme.textDisabled].
  ///
  /// Defaults to [StreamTextTheme.bodyDefault] with
  /// [StreamColorScheme.textPrimary].
  final TextStyle? textStyle;

  /// The text style for hint text.
  ///
  /// Supports [WidgetStateTextStyle] for per-state styling (e.g. disabled).
  /// When the input is disabled, the default resolves to
  /// [StreamColorScheme.textDisabled].
  ///
  /// Defaults to [StreamTextTheme.bodyDefault] with
  /// [StreamColorScheme.textTertiary].
  final TextStyle? hintStyle;

  /// The color for leading and trailing icons.
  ///
  /// Supports [WidgetStateColor] for per-state styling (e.g. disabled).
  /// When the input is disabled, the default resolves to
  /// [StreamColorScheme.textDisabled].
  ///
  /// Defaults to [StreamColorScheme.textTertiary].
  final Color? iconColor;

  /// The size for leading and trailing icons.
  ///
  /// Defaults to `20`.
  final double? iconSize;

  /// The color of the text input cursor.
  ///
  /// Defaults to [StreamColorScheme.accentPrimary].
  final Color? cursorColor;

  /// The color of the text input cursor when [StreamHelperState.error] is
  /// active.
  ///
  /// Defaults to [StreamColorScheme.accentError].
  final Color? cursorErrorColor;

  /// The width of the text input cursor.
  ///
  /// Defaults to `2`.
  final double? cursorWidth;

  /// The height of the text input cursor.
  ///
  /// If null, defaults to the preferred line height of the input text style.
  final double? cursorHeight;

  /// The radius of the text input cursor.
  ///
  /// If null, the cursor is rendered without rounded corners.
  final Radius? cursorRadius;

  /// The text style for helper text in [StreamHelperState.info] state.
  ///
  /// Defaults to [StreamTextTheme.captionDefault] with
  /// [StreamColorScheme.textTertiary].
  final TextStyle? helperInfoStyle;

  /// The text style for helper text in [StreamHelperState.error] state.
  ///
  /// Defaults to [StreamTextTheme.captionDefault] with
  /// [StreamColorScheme.accentError].
  final TextStyle? helperErrorStyle;

  /// The text style for helper text in [StreamHelperState.success] state.
  ///
  /// Defaults to [StreamTextTheme.captionDefault] with
  /// [StreamColorScheme.accentSuccess].
  final TextStyle? helperSuccessStyle;

  /// The border radius of the text input.
  ///
  /// Defaults to [StreamRadius.lg].
  final BorderRadiusGeometry? borderRadius;

  /// The border side in the default/enabled state.
  ///
  /// Defaults to `BorderSide(color: StreamColorScheme.borderDefault)`.
  final BorderSide? border;

  /// The border side when the text input has focus.
  ///
  /// Defaults to `BorderSide(color: StreamColorScheme.borderActive)`.
  final BorderSide? focusBorder;

  /// The border side when [StreamHelperState.error] is active.
  ///
  /// Defaults to `BorderSide(color: StreamColorScheme.borderError)`.
  final BorderSide? errorBorder;

  /// The fill color of the text input container.
  ///
  /// If null, the container is not filled.
  final Color? fillColor;

  /// The padding inside the text input container.
  ///
  /// Defaults to `EdgeInsets.symmetric(vertical: spacing.sm, horizontal: spacing.md)`.
  final EdgeInsetsGeometry? contentPadding;

  /// Additional size constraints for the text input.
  ///
  /// Allows setting min/max width and height on the text input container.
  final BoxConstraints? constraints;

  /// The icon size for helper text icons.
  ///
  /// Defaults to `20`.
  final double? helperIconSize;

  /// The maximum number of lines for helper text.
  ///
  /// Defaults to `1`.
  final int? helperMaxLines;

  /// Linearly interpolate between two [StreamTextInputStyle] objects.
  static StreamTextInputStyle? lerp(
    StreamTextInputStyle? a,
    StreamTextInputStyle? b,
    double t,
  ) => _$StreamTextInputStyle.lerp(a, b, t);
}
