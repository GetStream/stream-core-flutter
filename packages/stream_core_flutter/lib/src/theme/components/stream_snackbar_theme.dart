import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';
import 'stream_button_theme.dart';

part 'stream_snackbar_theme.g.theme.dart';

/// Applies a snackbar theme to descendant [StreamSnackbar] widgets.
///
/// Wrap a subtree with [StreamSnackbarTheme] to override snackbar styling.
/// Access the merged theme using [BuildContext.streamSnackbarTheme].
///
/// {@tool snippet}
///
/// Override snackbar styling for a specific subtree:
///
/// ```dart
/// StreamSnackbarTheme(
///   data: StreamSnackbarThemeData(
///     style: StreamSnackbarStyle(
///       margin: EdgeInsets.all(24),
///     ),
///   ),
///   child: child,
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamSnackbarThemeData], which describes the snackbar theme.
///  * [StreamSnackbarStyle], the reusable visual style embedded by the theme.
class StreamSnackbarTheme extends InheritedTheme {
  /// Creates a snackbar theme that controls descendant snackbars.
  const StreamSnackbarTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The snackbar theme data for descendant widgets.
  final StreamSnackbarThemeData data;

  /// Returns the [StreamSnackbarThemeData] merged from local and global themes.
  ///
  /// Local values from the nearest [StreamSnackbarTheme] ancestor take
  /// precedence over global values from [StreamTheme.of].
  static StreamSnackbarThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamSnackbarTheme>();
    return StreamTheme.of(context).snackbarTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamSnackbarTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamSnackbarTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing [StreamSnackbar] widgets.
///
/// Wraps a [StreamSnackbarStyle] so it can be served by [StreamSnackbarTheme]
/// and slotted into [StreamTheme] alongside other component theme data classes.
@themeGen
@immutable
class StreamSnackbarThemeData with _$StreamSnackbarThemeData {
  /// Creates snackbar theme data.
  const StreamSnackbarThemeData({this.style});

  /// Visual styling for the snackbar.
  final StreamSnackbarStyle? style;

  /// Linearly interpolate between two [StreamSnackbarThemeData] objects.
  static StreamSnackbarThemeData? lerp(
    StreamSnackbarThemeData? a,
    StreamSnackbarThemeData? b,
    double t,
  ) => _$StreamSnackbarThemeData.lerp(a, b, t);
}

/// Visual styling properties for a [StreamSnackbar].
///
/// Defines the snackbar's container appearance, text style, icon style, and
/// the outer margin used when positioning above the safe area / keyboard.
@themeGen
@immutable
class StreamSnackbarStyle with _$StreamSnackbarStyle {
  /// Creates a snackbar style with optional property overrides.
  const StreamSnackbarStyle({
    this.backgroundColor,
    this.foregroundColor,
    this.shape,
    this.side,
    this.elevation,
    this.padding,
    this.margin,
    this.constraints,
    this.textStyle,
    this.actionStyle,
  });

  /// Pill background colour.
  final Color? backgroundColor;

  /// Text and leading-icon colour. The icon adopts this colour automatically.
  final Color? foregroundColor;

  /// The shape of the pill container.
  ///
  /// This shape is combined with [side] to create a shape decorated with an
  /// outline.
  final OutlinedBorder? shape;

  /// The colour and weight of the pill's outline.
  ///
  /// This value is combined with [shape] to create a shape decorated with an
  /// outline.
  final BorderSide? side;

  /// The z-coordinate at which to place the snackbar's [Material].
  ///
  /// Higher values increase the size and intensity of the snackbar's drop
  /// shadow.
  final double? elevation;

  /// Padding between the pill border and the inner content.
  final EdgeInsetsGeometry? padding;

  /// Outer margin between the snackbar and the screen edges / safe area /
  /// keyboard inset.
  final EdgeInsetsGeometry? margin;

  /// Size constraints for the pill container.
  ///
  /// Typically used to set a minimum height and a maximum width so the pill
  /// hugs its content vertically but caps its width on wide surfaces.
  final BoxConstraints? constraints;

  /// Text style applied to the message.
  final TextStyle? textStyle;

  /// Button styling for the trailing action.
  ///
  /// Applied as the `themeStyle` of the inner [StreamButton]. By default the
  /// snackbar tints the action's foreground and border to match the pill's
  /// [foregroundColor]; override to fully restyle the action button.
  final StreamButtonThemeStyle? actionStyle;

  /// Linearly interpolate between two [StreamSnackbarStyle] objects.
  static StreamSnackbarStyle? lerp(
    StreamSnackbarStyle? a,
    StreamSnackbarStyle? b,
    double t,
  ) => _$StreamSnackbarStyle.lerp(a, b, t);
}
