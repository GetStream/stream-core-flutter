import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';

part 'stream_sheet_theme.g.theme.dart';

/// Applies a sheet theme to descendant [StreamSheet] widgets and
/// [StreamSheetDragHandle]s.
///
/// Wrap a subtree with [StreamSheetTheme] to override the look of any
/// sheet rendered inside it (including modal sheets opened via
/// `showStreamSheet`). Access the merged theme using
/// [BuildContext.streamSheetTheme].
///
/// {@tool snippet}
///
/// Override the sheet background and elevation for a specific subtree:
///
/// ```dart
/// StreamSheetTheme(
///   data: StreamSheetThemeData(
///     backgroundColor: Colors.white,
///     elevation: 4,
///   ),
///   child: child,
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamSheetThemeData], which describes the sheet theme.
///  * [StreamSheet], the widget affected by this theme.
///  * [StreamSheetDragHandle], which reads its color and size from this
///    theme.
class StreamSheetTheme extends InheritedTheme {
  /// Creates a sheet theme that controls descendant sheets.
  const StreamSheetTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The sheet theme data for descendant widgets.
  final StreamSheetThemeData data;

  /// Returns the [StreamSheetThemeData] merged from local and global
  /// themes.
  ///
  /// Local values from the nearest [StreamSheetTheme] ancestor take
  /// precedence over global values from [StreamTheme.of].
  ///
  /// This allows partial overrides — for example, overriding only
  /// [StreamSheetThemeData.backgroundColor] while inheriting the rest
  /// from the global theme.
  static StreamSheetThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamSheetTheme>();
    return StreamTheme.of(context).sheetTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamSheetTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamSheetTheme oldWidget) => data != oldWidget.data;
}

/// Defines default property values for [StreamSheet] (and modal sheets
/// opened via `showStreamSheet`).
///
/// Every field is `null` by default; when null, the sheet falls back
/// to its built-in defaults (which themselves resolve from
/// [StreamColorScheme] / [StreamRadius] / [StreamSpacing]).
///
/// Per-instance constructor arguments on [StreamSheet] (and
/// [showStreamSheet]) take precedence over this theme.
///
/// {@tool snippet}
///
/// Customize sheet appearance globally via [StreamTheme]:
///
/// ```dart
/// StreamTheme(
///   sheetTheme: StreamSheetThemeData(
///     elevation: 4,
///     dragHandleSize: const Size(40, 4),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamSheetTheme], for overriding the theme in a widget subtree.
///  * [StreamSheet], the widget that uses this theme.
///  * [StreamSheetDragHandle], which reads its color and size from
///    this theme.
@themeGen
@immutable
class StreamSheetThemeData with _$StreamSheetThemeData {
  /// Creates sheet theme data.
  const StreamSheetThemeData({
    this.backgroundColor,
    this.surfaceTintColor,
    this.shadowColor,
    this.barrierColor,
    this.elevation,
    this.shape,
    this.borderRadius,
    this.clipBehavior,
    this.constraints,
    this.showDragHandle,
    this.dragHandleColor,
    this.dragHandleSize,
  });

  /// Overrides the default value of `StreamSheetRoute.backgroundColor`.
  ///
  /// If null, the sheet falls back to
  /// [StreamColorScheme.backgroundElevation1].
  final Color? backgroundColor;

  /// Overrides the default surface tint color used as an overlay on
  /// the sheet's background.
  ///
  /// If null, no overlay color is drawn.
  final Color? surfaceTintColor;

  /// Overrides the default shadow color cast around the sheet.
  ///
  /// If null, the platform default is used.
  final Color? shadowColor;

  /// Overrides the default value of `StreamSheetRoute.barrierColor`.
  ///
  /// If null, the sheet falls back to
  /// [StreamColorScheme.backgroundScrim].
  final Color? barrierColor;

  /// Overrides the default value of `StreamSheetRoute.elevation`.
  ///
  /// Drives the shadow cast around the sheet — most visible at the top
  /// edge, where the sheet meets the content behind it. If null, the
  /// sheet defaults to `1`.
  final double? elevation;

  /// Overrides the default value of `StreamSheetRoute.shape`.
  ///
  /// Takes precedence over [borderRadius] when non-null. Useful for
  /// non-rectangular sheets (e.g. with a clipped notch).
  final ShapeBorder? shape;

  /// Overrides the default value of `StreamSheetRoute.borderRadius`.
  ///
  /// Ignored when [shape] is non-null. If both are null, the sheet's
  /// top corners are rounded with [StreamRadius.xxxxl] and the bottom
  /// corners are square.
  final BorderRadiusGeometry? borderRadius;

  /// Overrides how the sheet's content is clipped against its [shape]
  /// / [borderRadius].
  ///
  /// If null, the sheet defaults to [Clip.none].
  final Clip? clipBehavior;

  /// Constrains the size of the sheet.
  ///
  /// Most useful on tablet/desktop to cap the sheet's width. If null,
  /// the sheet defaults to `BoxConstraints(maxWidth: 640)`.
  final BoxConstraints? constraints;

  /// Overrides the default value of `StreamSheetRoute.showDragHandle`.
  ///
  /// If null, the sheet defaults to `true` (a drag handle is shown).
  final bool? showDragHandle;

  /// Overrides the default color of the sheet's drag handle.
  ///
  /// If null, the handle falls back to
  /// [StreamColorScheme.accentNeutral].
  final Color? dragHandleColor;

  /// Overrides the default size of the sheet's drag handle.
  ///
  /// If null, the handle defaults to a `36 × 5` pill.
  final Size? dragHandleSize;

  /// Linearly interpolate between two [StreamSheetThemeData] objects.
  static StreamSheetThemeData? lerp(
    StreamSheetThemeData? a,
    StreamSheetThemeData? b,
    double t,
  ) => _$StreamSheetThemeData.lerp(a, b, t);
}
