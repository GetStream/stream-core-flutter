import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../../components/common/stream_select_input.dart';
import '../../components/common/stream_text_input.dart';
import '../primitives/internal/tokens/stream_tokens_dimensions.dart' as tokens;
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

  /// Returns the [StreamSelectInputThemeData] merged from local and global themes.
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
///       border: WidgetStateBorderSide.resolveWith(
///         (states) => BorderSide(
///           color: states.contains(WidgetState.selected) ? Colors.blue : Colors.grey,
///         ),
///       ),
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
/// Every text style, color and border side is resolved against the field's
/// [WidgetState]s, so each accepts a [WidgetStateTextStyle], [WidgetStateColor]
/// or [WidgetStateBorderSide]. The states are [WidgetState.disabled],
/// [WidgetState.error], [WidgetState.hovered], [WidgetState.focused] and, while
/// the field's menu is open, [WidgetState.selected].
///
/// Helper text is rendered by [StreamHelperText], which is styled by the
/// ambient [StreamTextInputTheme], not by this style.
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
    this.hoverRing,
    this.focusRing,
    this.fillColor,
    this.contentPadding,
    this.labelPadding,
    this.helperPadding,
  });

  /// Creates a style for a borderless field.
  ///
  /// Fixes [border] to a transparent 1px side in every state, so only the
  /// interaction rings show, and insets [labelPadding] and [helperPadding]
  /// horizontally by the field's default horizontal content padding, so the
  /// label and helper text line up with the selected value.
  ///
  /// Useful where the surrounding surface already frames the field, such as a
  /// toolbar or a settings row.
  const StreamSelectInputStyle.ghost({
    this.textStyle,
    this.hintStyle,
    this.labelStyle,
    this.iconColor,
    this.iconSize,
    this.borderRadius,
    this.hoverRing,
    this.focusRing,
    this.fillColor,
    this.contentPadding,
  }) : border = const BorderSide(color: Color(0x00000000)),
       labelPadding = const EdgeInsetsDirectional.symmetric(horizontal: tokens.StreamTokensDimensions.spacingMd),
       helperPadding = const EdgeInsetsDirectional.symmetric(horizontal: tokens.StreamTokensDimensions.spacingMd);

  /// The text style for the selected value.
  ///
  /// When the field is disabled, the default resolves to
  /// [StreamColorScheme.textDisabled].
  ///
  /// Defaults to [StreamTextTheme.bodyDefault] with
  /// [StreamColorScheme.textPrimary].
  final TextStyle? textStyle;

  /// The text style for the hint shown while nothing is selected.
  ///
  /// When the field is disabled, the default resolves to
  /// [StreamColorScheme.textDisabled].
  ///
  /// Defaults to [StreamTextTheme.bodyDefault] with
  /// [StreamColorScheme.textTertiary].
  final TextStyle? hintStyle;

  /// The text style for the persistent label rendered above the field.
  ///
  /// The default does not change with the field's state, so a disabled field
  /// keeps a readable label.
  ///
  /// Defaults to [StreamTextTheme.headingSm] with
  /// [StreamColorScheme.textPrimary].
  final TextStyle? labelStyle;

  /// The color for an [Icon] leading widget and the caret.
  ///
  /// Applied through an [IconTheme], so a leading widget that does not read
  /// the icon theme keeps its own color.
  ///
  /// Defaults to [StreamColorScheme.textTertiary], resolving to
  /// [StreamColorScheme.textPrimary] while the menu is open and to
  /// [StreamColorScheme.textDisabled] while the field is disabled.
  final Color? iconColor;

  /// The size for an [Icon] leading widget and the caret.
  ///
  /// Defaults to `20`.
  final double? iconSize;

  /// The border radius of the field, also used for the interaction rings.
  ///
  /// Defaults to [StreamRadius.xl].
  final BorderRadiusGeometry? borderRadius;

  /// The border side of the field.
  ///
  /// Drawn inside the field without adding to its size. Pass a
  /// [WidgetStateBorderSide] to vary it with the field's state; a side that
  /// resolves to null draws no border.
  ///
  /// The default resolves to [StreamColorScheme.borderDisabled] while
  /// disabled, else [StreamColorScheme.borderError] on error, else
  /// [StreamColorScheme.borderActive] while the menu is open
  /// ([WidgetState.selected]), and [StreamColorScheme.borderDefault]
  /// otherwise. Hover and focus do not change it; they draw [hoverRing] and
  /// [focusRing] over it.
  ///
  /// [StreamSelectInputStyle.ghost] fixes this to a transparent side.
  final BorderSide? border;

  /// The ring drawn over the field's border while a pointer hovers it.
  ///
  /// Painted on the field's edge with its own [BorderSide.strokeAlign].
  ///
  /// Defaults to a 1px inside `BorderSide(color: StreamColorScheme.borderHover)`,
  /// which tints the border under it.
  final BorderSide? hoverRing;

  /// The ring drawn over the field while it shows a keyboard focus highlight.
  ///
  /// Takes precedence over [hoverRing]. Painted on the field's edge with its
  /// own [BorderSide.strokeAlign], so a centered ring paints half its width
  /// outside the field, where a clipping ancestor cuts it off.
  ///
  /// Defaults to a 2px centered `BorderSide(color: StreamColorScheme.borderFocus)`.
  final BorderSide? focusRing;

  /// The fill color of the field.
  ///
  /// If null, the field is not filled.
  final Color? fillColor;

  /// The padding inside the field, between its edge and its content.
  ///
  /// Defaults to `EdgeInsets.symmetric(vertical: spacing.sm + spacing.xxxs, horizontal: spacing.md)`,
  /// which makes the field 48px tall.
  final EdgeInsetsGeometry? contentPadding;

  /// The padding around the label rendered above the field.
  ///
  /// Defaults to [EdgeInsets.zero]. [StreamSelectInputStyle.ghost] insets it
  /// to line up with the field's content.
  final EdgeInsetsGeometry? labelPadding;

  /// The padding around the helper text rendered below the field.
  ///
  /// Defaults to [EdgeInsets.zero]. [StreamSelectInputStyle.ghost] insets it
  /// to line up with the field's content.
  final EdgeInsetsGeometry? helperPadding;

  /// Linearly interpolate between two [StreamSelectInputStyle] objects.
  static StreamSelectInputStyle? lerp(
    StreamSelectInputStyle? a,
    StreamSelectInputStyle? b,
    double t,
  ) => _$StreamSelectInputStyle.lerp(a, b, t);
}
