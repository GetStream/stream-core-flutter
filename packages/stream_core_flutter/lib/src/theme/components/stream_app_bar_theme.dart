import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';
import 'stream_button_theme.dart';

part 'stream_app_bar_theme.g.theme.dart';

/// Applies an app bar theme to descendant [StreamAppBar] widgets.
///
/// Wrap a subtree with [StreamAppBarTheme] to override app bar styling.
/// Access the merged theme using [BuildContext.streamAppBarTheme].
///
/// {@tool snippet}
///
/// Override app bar background for a specific subtree:
///
/// ```dart
/// StreamAppBarTheme(
///   data: StreamAppBarThemeData(
///     style: StreamAppBarStyle(backgroundColor: Color(0xFFF6F7F9)),
///   ),
///   child: Scaffold(
///     appBar: StreamAppBar(title: Text('Details')),
///     body: ...,
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamAppBarThemeData], which describes the app bar theme.
///  * [StreamAppBarStyle], the reusable visual style embedded by the theme.
///  * [StreamAppBar], the widget affected by this theme.
class StreamAppBarTheme extends InheritedTheme {
  /// Creates an app bar theme that controls descendant app bars.
  const StreamAppBarTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The app bar theme data for descendant widgets.
  final StreamAppBarThemeData data;

  /// Returns the [StreamAppBarThemeData] merged from local and global themes.
  ///
  /// Local values from the nearest [StreamAppBarTheme] ancestor take
  /// precedence over global values from [StreamTheme.of].
  static StreamAppBarThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamAppBarTheme>();
    return StreamTheme.of(context).appBarTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamAppBarTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamAppBarTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing [StreamAppBar] widgets.
///
/// Wraps a [StreamAppBarStyle] so it can be served by [StreamAppBarTheme]
/// and slotted into [StreamTheme] alongside other component theme data
/// classes.
///
/// {@tool snippet}
///
/// Customize app bar appearance globally via [StreamTheme]:
///
/// ```dart
/// StreamTheme(
///   appBarTheme: StreamAppBarThemeData(
///     style: StreamAppBarStyle(
///       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
///     ),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamAppBarStyle], the reusable visual style embedded here.
///  * [StreamAppBarTheme], for overriding the theme in a widget subtree.
///  * [StreamAppBar], the widget that uses this theme data.
@themeGen
@immutable
class StreamAppBarThemeData with _$StreamAppBarThemeData {
  /// Creates app bar theme data.
  const StreamAppBarThemeData({this.style});

  /// Visual styling for the app bar.
  final StreamAppBarStyle? style;

  /// Linearly interpolate between two [StreamAppBarThemeData] objects.
  static StreamAppBarThemeData? lerp(
    StreamAppBarThemeData? a,
    StreamAppBarThemeData? b,
    double t,
  ) => _$StreamAppBarThemeData.lerp(a, b, t);
}

/// Visual styling properties for a [StreamAppBar].
///
/// Defines the appearance of the app bar — background colour, padding,
/// inter-slot spacing, title and subtitle text styles, and per-slot button
/// style propagation.
///
/// Exposed separately from [StreamAppBarThemeData] so other theme data classes
/// can embed an app-bar style via a typed field.
///
/// {@tool snippet}
///
/// Compose a style and hand it to an app bar theme:
///
/// ```dart
/// StreamAppBarStyle(
///   backgroundColor: Color(0xFFFFFFFF),
///   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
///   spacing: 8,
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamAppBarThemeData], which wraps this style for theming.
///  * [StreamAppBar], which uses this styling.
@themeGen
@immutable
class StreamAppBarStyle with _$StreamAppBarStyle {
  /// Creates an app bar style with optional property overrides.
  const StreamAppBarStyle({
    this.backgroundColor,
    this.padding,
    this.spacing,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.leadingStyle,
    this.trailingStyle,
  });

  /// The background colour of the app bar.
  final Color? backgroundColor;

  /// The padding around the header's content row.
  final EdgeInsetsGeometry? padding;

  /// The horizontal space between the leading, heading, and trailing slots.
  final double? spacing;

  /// The text style for [StreamAppBar.title].
  final TextStyle? titleTextStyle;

  /// The text style for [StreamAppBar.subtitle].
  final TextStyle? subtitleTextStyle;

  /// The button style for any [StreamButton] rendered in
  /// [StreamAppBar.leading].
  ///
  /// Applied via a scoped [StreamButtonTheme] so any [StreamButton] dropped
  /// into the slot picks it up regardless of the button's configured `style`
  /// or `type`. Per-instance `themeStyle` overrides still win via merge.
  final StreamButtonThemeStyle? leadingStyle;

  /// The button style for any [StreamButton] rendered in
  /// [StreamAppBar.trailing].
  ///
  /// Applied via a scoped [StreamButtonTheme] so any [StreamButton] dropped
  /// into the slot picks it up regardless of the button's configured `style`
  /// or `type`. Per-instance `themeStyle` overrides still win via merge.
  final StreamButtonThemeStyle? trailingStyle;

  /// Linearly interpolate between two [StreamAppBarStyle] objects.
  static StreamAppBarStyle? lerp(
    StreamAppBarStyle? a,
    StreamAppBarStyle? b,
    double t,
  ) => _$StreamAppBarStyle.lerp(a, b, t);
}
