import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';
import 'stream_button_theme.dart';

part 'stream_sheet_header_theme.g.theme.dart';

/// Applies a sheet header theme to descendant [StreamSheetHeader] widgets.
///
/// Wrap a subtree with [StreamSheetHeaderTheme] to override sheet header
/// styling. Access the merged theme using [BuildContext.streamSheetHeaderTheme].
///
/// {@tool snippet}
///
/// Override sheet header padding for a specific subtree:
///
/// ```dart
/// StreamSheetHeaderTheme(
///   data: StreamSheetHeaderThemeData(
///     style: StreamSheetHeaderStyle(padding: EdgeInsets.all(16)),
///   ),
///   child: StreamSheetHeader(title: Text('Details')),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamSheetHeaderThemeData], which describes the sheet header theme.
///  * [StreamSheetHeaderStyle], the reusable visual style embedded by the
///    theme.
///  * [StreamSheetHeader], the widget affected by this theme.
class StreamSheetHeaderTheme extends InheritedTheme {
  /// Creates a sheet header theme that controls descendant sheet headers.
  const StreamSheetHeaderTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The sheet header theme data for descendant widgets.
  final StreamSheetHeaderThemeData data;

  /// Returns the [StreamSheetHeaderThemeData] merged from local and global
  /// themes.
  ///
  /// Local values from the nearest [StreamSheetHeaderTheme] ancestor take
  /// precedence over global values from [StreamTheme.of].
  static StreamSheetHeaderThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamSheetHeaderTheme>();
    return StreamTheme.of(context).sheetHeaderTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamSheetHeaderTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamSheetHeaderTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing [StreamSheetHeader] widgets.
///
/// Wraps a [StreamSheetHeaderStyle] so it can be served by
/// [StreamSheetHeaderTheme] and slotted into [StreamTheme] alongside other
/// component theme data classes.
///
/// {@tool snippet}
///
/// Customize sheet header appearance globally via [StreamTheme]:
///
/// ```dart
/// StreamTheme(
///   sheetHeaderTheme: StreamSheetHeaderThemeData(
///     style: StreamSheetHeaderStyle(
///       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
///       spacing: 8,
///     ),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamSheetHeaderStyle], the reusable visual style embedded here.
///  * [StreamSheetHeaderTheme], for overriding the theme in a widget subtree.
///  * [StreamSheetHeader], the widget that uses this theme data.
@themeGen
@immutable
class StreamSheetHeaderThemeData with _$StreamSheetHeaderThemeData {
  /// Creates sheet header theme data.
  const StreamSheetHeaderThemeData({this.style});

  /// Visual styling for the sheet header.
  final StreamSheetHeaderStyle? style;

  /// Linearly interpolate between two [StreamSheetHeaderThemeData] objects.
  static StreamSheetHeaderThemeData? lerp(
    StreamSheetHeaderThemeData? a,
    StreamSheetHeaderThemeData? b,
    double t,
  ) => _$StreamSheetHeaderThemeData.lerp(a, b, t);
}

/// Visual styling properties for a [StreamSheetHeader].
///
/// Defines the appearance of the header including padding, spacing, title
/// and subtitle text styles, and the default button style for the leading
/// and trailing slots.
///
/// Exposed separately from [StreamSheetHeaderThemeData] so other theme data
/// classes can embed a sheet-header style via a typed field.
///
/// {@tool snippet}
///
/// Compose a style and hand it to a sheet header theme:
///
/// ```dart
/// StreamSheetHeaderStyle(
///   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
///   spacing: 8,
///   leadingStyle: StreamButtonThemeStyle.from(
///     backgroundColor: colors.backgroundSurfaceSubtle,
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamSheetHeaderThemeData], which wraps this style for theming.
///  * [StreamSheetHeader], which uses this styling.
@themeGen
@immutable
class StreamSheetHeaderStyle with _$StreamSheetHeaderStyle {
  /// Creates a sheet header style with optional property overrides.
  const StreamSheetHeaderStyle({
    this.padding,
    this.spacing,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.leadingStyle,
    this.trailingStyle,
  });

  /// The padding around the header's content row.
  final EdgeInsetsGeometry? padding;

  /// The horizontal space between the leading, heading, and trailing slots.
  final double? spacing;

  /// The text style for [StreamSheetHeader.title].
  final TextStyle? titleTextStyle;

  /// The text style for [StreamSheetHeader.subtitle].
  final TextStyle? subtitleTextStyle;

  /// The button style for any [StreamButton] rendered in
  /// [StreamSheetHeader.leading].
  ///
  /// Applied via a scoped [StreamButtonTheme] so any [StreamButton] dropped
  /// into the slot picks it up regardless of the button's configured `style`
  /// or `type`. Per-instance `themeStyle` overrides still win via merge.
  final StreamButtonThemeStyle? leadingStyle;

  /// The button style for any [StreamButton] rendered in
  /// [StreamSheetHeader.trailing].
  ///
  /// Applied via a scoped [StreamButtonTheme] so any [StreamButton] dropped
  /// into the slot picks it up regardless of the button's configured `style`
  /// or `type`. Per-instance `themeStyle` overrides still win via merge.
  final StreamButtonThemeStyle? trailingStyle;

  /// Linearly interpolate between two [StreamSheetHeaderStyle] objects.
  static StreamSheetHeaderStyle? lerp(
    StreamSheetHeaderStyle? a,
    StreamSheetHeaderStyle? b,
    double t,
  ) => _$StreamSheetHeaderStyle.lerp(a, b, t);
}
