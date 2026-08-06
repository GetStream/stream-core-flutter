import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';

part 'stream_bottom_nav_bar_theme.g.theme.dart';

/// The floating or regular layout behaviour for a [StreamBottomNavBar].
///
/// When null on [StreamBottomNavBarStyle], the ambient [StreamAppStyle] is used
/// as a fallback — [StreamAppStyle.floating] maps to [floating] and
/// [StreamAppStyle.regular] maps to [regular].
///
/// See also:
///
///  * [StreamBottomNavBarStyle.behavior], which carries this value.
///  * [StreamAppStyle], the global app-wide style that acts as fallback.
enum StreamBottomNavBarBehavior {
  /// The navigation bar sits within the layout flow with a solid background.
  regular,

  /// The navigation bar floats above the body as a pill over a gradient fade.
  floating,
}

/// Applies a bottom navigation bar theme to descendant [StreamBottomNavBar]
/// widgets.
///
/// Wrap a subtree with [StreamBottomNavBarTheme] to override navigation bar
/// styling. Access the merged theme using
/// [BuildContext.streamBottomNavBarTheme].
///
/// {@tool snippet}
///
/// Override the selected item colour for a specific subtree:
///
/// ```dart
/// StreamBottomNavBarTheme(
///   data: StreamBottomNavBarThemeData(
///     style: StreamBottomNavBarStyle(selectedItemColor: Color(0xFF005FFF)),
///   ),
///   child: StreamBottomNavBar(...),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamBottomNavBarThemeData], which describes the navigation bar theme.
///  * [StreamBottomNavBarStyle], the reusable visual style embedded by the theme.
///  * [StreamBottomNavBar], the widget affected by this theme.
class StreamBottomNavBarTheme extends InheritedTheme {
  /// Creates a bottom navigation bar theme that controls descendant bars.
  const StreamBottomNavBarTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The bottom navigation bar theme data for descendant widgets.
  final StreamBottomNavBarThemeData data;

  /// Returns the [StreamBottomNavBarThemeData] merged from local and global
  /// themes.
  ///
  /// Local values from the nearest [StreamBottomNavBarTheme] ancestor take
  /// precedence over global values from [StreamTheme.of].
  static StreamBottomNavBarThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamBottomNavBarTheme>();
    return StreamTheme.of(context).bottomNavBarTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamBottomNavBarTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamBottomNavBarTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing [StreamBottomNavBar] widgets.
///
/// Wraps a [StreamBottomNavBarStyle] so it can be served by
/// [StreamBottomNavBarTheme] and slotted into [StreamTheme] alongside other
/// component theme data classes.
///
/// {@tool snippet}
///
/// Customize navigation bar appearance globally via [StreamTheme]:
///
/// ```dart
/// StreamTheme(
///   bottomNavBarTheme: StreamBottomNavBarThemeData(
///     style: StreamBottomNavBarStyle(iconSize: 24),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamBottomNavBarStyle], the reusable visual style embedded here.
///  * [StreamBottomNavBarTheme], for overriding the theme in a widget subtree.
///  * [StreamBottomNavBar], the widget that uses this theme data.
@themeGen
@immutable
class StreamBottomNavBarThemeData with _$StreamBottomNavBarThemeData {
  /// Creates bottom navigation bar theme data.
  const StreamBottomNavBarThemeData({this.style});

  /// Visual styling for the bottom navigation bar.
  final StreamBottomNavBarStyle? style;

  /// Linearly interpolate between two [StreamBottomNavBarThemeData] objects.
  static StreamBottomNavBarThemeData? lerp(
    StreamBottomNavBarThemeData? a,
    StreamBottomNavBarThemeData? b,
    double t,
  ) => _$StreamBottomNavBarThemeData.lerp(a, b, t);
}

/// Visual styling properties for a [StreamBottomNavBar].
///
/// Defines the appearance of the navigation bar — the docked/floating
/// behaviour, background colours, per-item selected and unselected colours,
/// icon size, item label styles, and the border and corner radius used by the
/// floating pill.
///
/// Exposed separately from [StreamBottomNavBarThemeData] so other theme data
/// classes can embed a navigation bar style via a typed field.
///
/// {@tool snippet}
///
/// Compose a style and hand it to a navigation bar theme:
///
/// ```dart
/// StreamBottomNavBarStyle(
///   selectedItemColor: Color(0xFF080707),
///   unselectedItemColor: Color(0xFF7A7A7A),
///   iconSize: 20,
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamBottomNavBarThemeData], which wraps this style for theming.
///  * [StreamBottomNavBar], which uses this styling.
@themeGen
@immutable
class StreamBottomNavBarStyle with _$StreamBottomNavBarStyle {
  /// Creates a bottom navigation bar style with optional property overrides.
  const StreamBottomNavBarStyle({
    this.behavior,
    this.floatingElevation,
    this.backgroundColor,
    this.floatingBackgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.iconSize,
    this.selectedLabelStyle,
    this.unselectedLabelStyle,
    this.borderColor,
    this.borderRadius,
  });

  /// The floating or regular layout behaviour for this navigation bar.
  ///
  /// When null the value falls back to the ambient [StreamAppStyle]:
  /// [StreamAppStyle.floating] → [StreamBottomNavBarBehavior.floating],
  /// [StreamAppStyle.regular] → [StreamBottomNavBarBehavior.regular].
  final StreamBottomNavBarBehavior? behavior;

  /// The elevation of the floating pill.
  final double? floatingElevation;

  /// The background colour of the docked bar and of the floating pill.
  final Color? backgroundColor;

  /// The base colour of the floating gradient fade behind the pill.
  final Color? floatingBackgroundColor;

  /// The colour of the icon and label of the selected item.
  final Color? selectedItemColor;

  /// The colour of the icon and label of unselected items.
  final Color? unselectedItemColor;

  /// The size of each item's icon.
  final double? iconSize;

  /// The text style for the label of the selected item.
  final TextStyle? selectedLabelStyle;

  /// The text style for the label of unselected items.
  final TextStyle? unselectedLabelStyle;

  /// The colour of the docked bar's top border and the floating pill's border.
  final Color? borderColor;

  /// The corner radius of the floating pill.
  final BorderRadiusGeometry? borderRadius;

  /// Linearly interpolate between two [StreamBottomNavBarStyle] objects.
  static StreamBottomNavBarStyle? lerp(
    StreamBottomNavBarStyle? a,
    StreamBottomNavBarStyle? b,
    double t,
  ) => _$StreamBottomNavBarStyle.lerp(a, b, t);
}
