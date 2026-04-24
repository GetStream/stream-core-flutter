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
///     padding: EdgeInsets.all(16),
///   ),
///   child: StreamSheetHeader(title: Text('Details')),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamSheetHeaderThemeData], which describes the sheet header theme.
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
/// Descendant widgets obtain their values from [StreamSheetHeaderTheme.of].
/// All properties are null by default, with fallback values applied by
/// [DefaultStreamSheetHeader].
///
/// {@tool snippet}
///
/// Customize sheet header appearance globally via [StreamTheme]:
///
/// ```dart
/// StreamTheme(
///   sheetHeaderTheme: StreamSheetHeaderThemeData(
///     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
///     spacing: 8,
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamSheetHeaderTheme], for overriding the theme in a widget subtree.
///  * [StreamSheetHeader], the widget that uses this theme data.
@themeGen
@immutable
class StreamSheetHeaderThemeData with _$StreamSheetHeaderThemeData {
  /// Creates a sheet header theme data with optional property overrides.
  const StreamSheetHeaderThemeData({
    this.padding,
    this.spacing,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.leadingStyle,
    this.trailingStyle,
  });

  /// The default padding around the header's content row.
  final EdgeInsetsGeometry? padding;

  /// The default horizontal space between the leading, heading, and trailing
  /// slots.
  final double? spacing;

  /// The default text style for [StreamSheetHeader.title].
  final TextStyle? titleTextStyle;

  /// The default text style for [StreamSheetHeader.subtitle].
  final TextStyle? subtitleTextStyle;

  /// The default button style for any [StreamButton] rendered in
  /// [StreamSheetHeader.leading].
  ///
  /// Scoped to the slot so any [StreamButton] dropped into it picks up this
  /// style regardless of the button's configured `style` or `type`.
  /// Per-instance `themeStyle` overrides still win via merge.
  final StreamButtonThemeStyle? leadingStyle;

  /// The default button style for any [StreamButton] rendered in
  /// [StreamSheetHeader.trailing].
  ///
  /// Scoped to the slot so any [StreamButton] dropped into it picks up this
  /// style regardless of the button's configured `style` or `type`.
  /// Per-instance `themeStyle` overrides still win via merge.
  final StreamButtonThemeStyle? trailingStyle;

  /// Linearly interpolate between two [StreamSheetHeaderThemeData] objects.
  static StreamSheetHeaderThemeData? lerp(
    StreamSheetHeaderThemeData? a,
    StreamSheetHeaderThemeData? b,
    double t,
  ) => _$StreamSheetHeaderThemeData.lerp(a, b, t);
}
