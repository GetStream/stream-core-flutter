import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_surface_style.dart';
import '../stream_theme.dart';
import 'stream_button_theme.dart';

part 'stream_bottom_app_bar_theme.g.theme.dart';

/// Applies a bottom app bar theme to descendant [StreamBottomAppBar] widgets.
///
/// Wrap a subtree with [StreamBottomAppBarTheme] to override bottom app bar
/// styling. Access the merged theme using
/// [BuildContext.streamBottomAppBarTheme].
///
/// {@tool snippet}
///
/// Override bottom app bar background for a specific subtree:
///
/// ```dart
/// StreamBottomAppBarTheme(
///   data: StreamBottomAppBarThemeData(
///     style: StreamBottomAppBarStyle(backgroundColor: Color(0xFFF6F7F9)),
///   ),
///   child: Scaffold(
///     bottomNavigationBar: StreamBottomAppBar(title: Text('1 of 9')),
///     body: ...,
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamBottomAppBarThemeData], which describes the bottom app bar theme.
///  * [StreamBottomAppBarStyle], the reusable visual style embedded by the
///    theme.
///  * [StreamBottomAppBar], the widget affected by this theme.
class StreamBottomAppBarTheme extends InheritedTheme {
  /// Creates a bottom app bar theme that controls descendant bottom app bars.
  const StreamBottomAppBarTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The bottom app bar theme data for descendant widgets.
  final StreamBottomAppBarThemeData data;

  /// Returns the [StreamBottomAppBarThemeData] merged from local and global
  /// themes.
  ///
  /// Local values from the nearest [StreamBottomAppBarTheme] ancestor take
  /// precedence over global values from [StreamTheme.of].
  static StreamBottomAppBarThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamBottomAppBarTheme>();
    return StreamTheme.of(context).bottomAppBarTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamBottomAppBarTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamBottomAppBarTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing [StreamBottomAppBar] widgets.
///
/// Wraps a [StreamBottomAppBarStyle] so it can be served by
/// [StreamBottomAppBarTheme] and slotted into [StreamTheme] alongside other
/// component theme data classes.
///
/// {@tool snippet}
///
/// Customize bottom app bar appearance globally via [StreamTheme]:
///
/// ```dart
/// StreamTheme(
///   bottomAppBarTheme: StreamBottomAppBarThemeData(
///     style: StreamBottomAppBarStyle(
///       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
///     ),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamBottomAppBarStyle], the reusable visual style embedded here.
///  * [StreamBottomAppBarTheme], for overriding the theme in a widget subtree.
///  * [StreamBottomAppBar], the widget that uses this theme data.
@themeGen
@immutable
class StreamBottomAppBarThemeData with _$StreamBottomAppBarThemeData {
  /// Creates bottom app bar theme data.
  const StreamBottomAppBarThemeData({this.style});

  /// Visual styling for the bottom app bar.
  final StreamBottomAppBarStyle? style;

  /// Linearly interpolate between two [StreamBottomAppBarThemeData] objects.
  static StreamBottomAppBarThemeData? lerp(
    StreamBottomAppBarThemeData? a,
    StreamBottomAppBarThemeData? b,
    double t,
  ) => _$StreamBottomAppBarThemeData.lerp(a, b, t);
}

/// Visual styling properties for a [StreamBottomAppBar].
///
/// Defines the appearance of the bottom app bar — background color,
/// padding, inter-slot spacing, title and subtitle text styles, and
/// per-slot button style propagation.
///
/// Exposed separately from [StreamBottomAppBarThemeData] so other theme data
/// classes can embed a bottom-app-bar style via a typed field.
///
/// {@tool snippet}
///
/// Compose a style and hand it to a bottom app bar theme:
///
/// ```dart
/// StreamBottomAppBarStyle(
///   backgroundColor: Color(0xFFFFFFFF),
///   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
///   spacing: 8,
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamBottomAppBarThemeData], which wraps this style for theming.
///  * [StreamBottomAppBar], which uses this styling.
@themeGen
@immutable
class StreamBottomAppBarStyle with _$StreamBottomAppBarStyle {
  /// Creates a bottom app bar style with optional property overrides.
  const StreamBottomAppBarStyle({
    this.surfaceStyle,
    this.backgroundColor,
    this.floatingBackgroundColor,
    this.padding,
    this.spacing,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.leadingStyle,
    this.trailingStyle,
  });

  /// The floating or regular surface style for this bottom bar.
  ///
  /// When null the value falls back to the app-wide [StreamSurfaceStyle] set on
  /// [StreamTheme].
  final StreamSurfaceStyle? surfaceStyle;

  /// The background color of the bottom app bar.
  final Color? backgroundColor;

  /// The background color of the bottom app bar when floating.
  final Color? floatingBackgroundColor;

  /// The padding around the bar's content row.
  final EdgeInsetsGeometry? padding;

  /// The horizontal space between the leading, heading, and trailing slots.
  final double? spacing;

  /// The text style for [StreamBottomAppBar.title].
  final TextStyle? titleTextStyle;

  /// The text style for [StreamBottomAppBar.subtitle].
  final TextStyle? subtitleTextStyle;

  /// The button style for any [StreamButton] rendered in
  /// [StreamBottomAppBar.leading].
  ///
  /// Applied via a scoped [StreamButtonTheme] so any [StreamButton] dropped
  /// into the slot picks it up regardless of the button's configured `style`
  /// or `type`. Per-instance `themeStyle` overrides still win via merge.
  final StreamButtonThemeStyle? leadingStyle;

  /// The button style for any [StreamButton] rendered in
  /// [StreamBottomAppBar.trailing].
  ///
  /// Applied via a scoped [StreamButtonTheme] so any [StreamButton] dropped
  /// into the slot picks it up regardless of the button's configured `style`
  /// or `type`. Per-instance `themeStyle` overrides still win via merge.
  final StreamButtonThemeStyle? trailingStyle;

  /// Linearly interpolate between two [StreamBottomAppBarStyle] objects.
  static StreamBottomAppBarStyle? lerp(
    StreamBottomAppBarStyle? a,
    StreamBottomAppBarStyle? b,
    double t,
  ) => _$StreamBottomAppBarStyle.lerp(a, b, t);
}
