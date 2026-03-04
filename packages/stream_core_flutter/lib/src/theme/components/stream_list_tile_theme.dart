import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';

part 'stream_list_tile_theme.g.theme.dart';

/// Applies a list tile theme to descendant [StreamListTile] widgets.
///
/// Wrap a subtree with [StreamListTileTheme] to override list tile styling.
/// Access the merged theme using [BuildContext.streamListTileTheme].
///
/// {@tool snippet}
///
/// Override list tile styling for a specific section:
///
/// ```dart
/// StreamListTileTheme(
///   data: StreamListTileThemeData(
///     shape: RoundedRectangleBorder(
///       borderRadius: BorderRadius.circular(8),
///     ),
///   ),
///   child: StreamListTile(
///     title: Text('Hello'),
///     onTap: () {},
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamListTileThemeData], which describes the list tile theme.
///  * [StreamListTile], the widget affected by this theme.
class StreamListTileTheme extends InheritedTheme {
  /// Creates a list tile theme that controls descendant list tiles.
  const StreamListTileTheme({super.key, required this.data, required super.child});

  /// The list tile theme data for descendant widgets.
  final StreamListTileThemeData data;

  /// Returns the [StreamListTileThemeData] merged from local and global themes.
  ///
  /// Local values from the nearest [StreamListTileTheme] ancestor take
  /// precedence over global values from [StreamTheme.of].
  ///
  /// This allows partial overrides — for example, overriding only
  /// [StreamListTileThemeData.contentPadding] while inheriting colors from
  /// the global theme.
  static StreamListTileThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamListTileTheme>();
    return StreamTheme.of(context).listTileTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamListTileTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamListTileTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing [StreamListTile] widgets.
///
/// Descendant widgets obtain their values from [StreamListTileTheme.of].
/// All properties are null by default, with fallback values applied by
/// [DefaultStreamListTile].
///
/// {@tool snippet}
///
/// Customize list tile appearance globally via [StreamTheme]:
///
/// ```dart
/// StreamTheme(
///   data: StreamThemeData(
///     listTileTheme: StreamListTileThemeData(
///       contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
///       shape: RoundedRectangleBorder(
///         borderRadius: BorderRadius.circular(8),
///       ),
///     ),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamListTileTheme], for overriding the theme in a widget subtree.
///  * [StreamListTile], the widget that uses this theme data.
@themeGen
@immutable
class StreamListTileThemeData with _$StreamListTileThemeData {
  /// Creates a list tile theme data with optional property overrides.
  const StreamListTileThemeData({
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.descriptionTextStyle,
    this.titleColor,
    this.subtitleColor,
    this.descriptionColor,
    this.iconColor,
    this.backgroundColor,
    this.shape,
    this.contentPadding,
    this.minTileHeight,
    this.overlayColor,
  });

  /// Defines the default text style for [StreamListTile.title].
  ///
  /// This only controls typography. Color comes from [titleColor].
  final TextStyle? titleTextStyle;

  /// Defines the default text style for [StreamListTile.subtitle].
  ///
  /// This only controls typography. Color comes from [subtitleColor].
  final TextStyle? subtitleTextStyle;

  /// Defines the default text style for [StreamListTile.description].
  ///
  /// This only controls typography. Color comes from [descriptionColor].
  final TextStyle? descriptionTextStyle;

  /// Defines the default color for [StreamListTile.title].
  ///
  /// This color is resolved from [WidgetState]s.
  final WidgetStateProperty<Color?>? titleColor;

  /// Defines the default color for [StreamListTile.subtitle].
  ///
  /// This color is resolved from [WidgetState]s.
  final WidgetStateProperty<Color?>? subtitleColor;

  /// Defines the default color for [StreamListTile.description].
  ///
  /// This color is resolved from [WidgetState]s.
  final WidgetStateProperty<Color?>? descriptionColor;

  /// Defines the default color for [StreamListTile.leading] and
  /// [StreamListTile.trailing].
  ///
  /// This color is resolved from [WidgetState]s.
  final WidgetStateProperty<Color?>? iconColor;

  /// Defines the default background color of the tile.
  ///
  /// This color is resolved from [WidgetState]s.
  final WidgetStateProperty<Color?>? backgroundColor;

  /// Defines the default shape for the tile.
  final ShapeBorder? shape;

  /// Defines the default internal padding of the tile's content.
  final EdgeInsetsGeometry? contentPadding;

  /// Defines the default minimum height of the tile.
  final double? minTileHeight;

  /// Defines the default overlay color for tile interactions.
  ///
  /// This color is resolved from [WidgetState]s.
  final WidgetStateProperty<Color?>? overlayColor;

  /// Linearly interpolate between two [StreamListTileThemeData] objects.
  static StreamListTileThemeData? lerp(
    StreamListTileThemeData? a,
    StreamListTileThemeData? b,
    double t,
  ) => _$StreamListTileThemeData.lerp(a, b, t);
}
