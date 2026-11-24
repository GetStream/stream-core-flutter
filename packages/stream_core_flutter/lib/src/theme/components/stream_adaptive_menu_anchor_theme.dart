import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../../components/context_menu/stream_adaptive_menu_anchor.dart';
import '../../components/context_menu/stream_context_menu_anchor.dart';
import '../../components/list/stream_list_tile.dart';
import '../stream_theme.dart';
import 'stream_context_menu_action_theme.dart';
import 'stream_context_menu_heading_theme.dart';
import 'stream_list_tile_theme.dart';

part 'stream_adaptive_menu_anchor_theme.g.theme.dart';

/// Applies an adaptive menu anchor theme to descendant
/// [StreamAdaptiveMenuAnchor] widgets.
///
/// Wrap a subtree with [StreamAdaptiveMenuAnchorTheme] to override how its
/// menus are presented and how their rows are styled. Access the merged theme
/// using [BuildContext.streamAdaptiveMenuAnchorTheme].
///
/// {@tool snippet}
///
/// Keep the menus inside a panel anchored, even on a phone, while inheriting
/// everything else:
///
/// ```dart
/// StreamAdaptiveMenuAnchorTheme(
///   data: StreamAdaptiveMenuAnchorTheme.of(context).merge(
///     const StreamAdaptiveMenuAnchorThemeData(useSheet: false),
///   ),
///   child: panel,
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamAdaptiveMenuAnchorThemeData], which describes the theme.
///  * [StreamAdaptiveMenuAnchor], the widget affected by this theme.
@experimental
class StreamAdaptiveMenuAnchorTheme extends InheritedTheme {
  /// Creates an adaptive menu anchor theme that controls descendant anchors.
  const StreamAdaptiveMenuAnchorTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The adaptive menu anchor theme data for descendant widgets.
  final StreamAdaptiveMenuAnchorThemeData data;

  /// Returns the [StreamAdaptiveMenuAnchorThemeData] merged from local and
  /// global themes.
  ///
  /// Local values from the nearest [StreamAdaptiveMenuAnchorTheme] ancestor
  /// take precedence over global values from [StreamTheme.of].
  static StreamAdaptiveMenuAnchorThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamAdaptiveMenuAnchorTheme>();
    return StreamTheme.of(context).adaptiveMenuAnchorTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamAdaptiveMenuAnchorTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamAdaptiveMenuAnchorTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing [StreamAdaptiveMenuAnchor] widgets.
///
/// {@tool snippet}
///
/// Present every menu as an anchored menu, whatever the platform:
///
/// ```dart
/// StreamTheme(
///   adaptiveMenuAnchorTheme: StreamAdaptiveMenuAnchorThemeData(
///     useSheet: false,
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamAdaptiveMenuAnchorTheme], for overriding the theme in a subtree.
///  * [StreamAdaptiveMenuAnchor], the widget that uses this theme data.
@themeGen
@immutable
@experimental
class StreamAdaptiveMenuAnchorThemeData with _$StreamAdaptiveMenuAnchorThemeData {
  /// Creates adaptive menu anchor theme data with optional overrides.
  const StreamAdaptiveMenuAnchorThemeData({this.style, this.useSheet});

  /// The visual style of the menu in each of its two presentations.
  final StreamAdaptiveMenuAnchorStyle? style;

  /// Whether the menus present a bottom sheet instead of an anchored menu.
  ///
  /// If null, follows the platform: a sheet on Android and iOS, the anchored
  /// menu everywhere else. [StreamAdaptiveMenuAnchor.useSheet] wins over this.
  final bool? useSheet;

  /// Linearly interpolate between two [StreamAdaptiveMenuAnchorThemeData]
  /// objects.
  static StreamAdaptiveMenuAnchorThemeData? lerp(
    StreamAdaptiveMenuAnchorThemeData? a,
    StreamAdaptiveMenuAnchorThemeData? b,
    double t,
  ) => _$StreamAdaptiveMenuAnchorThemeData.lerp(a, b, t);
}

/// The visual style of a [StreamAdaptiveMenuAnchor], in each of its two
/// presentations.
///
/// The `menu` fields style the anchored menu shown on desktop and web, and the
/// `sheet` fields style the bottom sheet shown on Android and iOS.
@themeGen
@immutable
@experimental
class StreamAdaptiveMenuAnchorStyle with _$StreamAdaptiveMenuAnchorStyle {
  /// Creates a style for [StreamAdaptiveMenuAnchor].
  const StreamAdaptiveMenuAnchorStyle({
    this.menuItemStyle,
    this.menuSelectedItemColor,
    this.menuHeadingStyle,
    this.menuGap,
    this.sheetTileStyle,
    this.sheetHeadingStyle,
    this.sheetPadding,
  });

  /// Overrides for the rows of the anchored menu.
  ///
  /// Merged over [StreamContextMenuAnchor.defaultActionStyle], the design's
  /// `Web / Menu Item`. [StreamAdaptiveMenuAnchor.menuItemStyle] wins over
  /// this.
  final StreamContextMenuActionStyle? menuItemStyle;

  /// The fill behind the anchored menu's row for the option currently in
  /// effect.
  ///
  /// If null, defaults to [StreamColorScheme.backgroundSelected].
  final Color? menuSelectedItemColor;

  /// Overrides for the section headings of the anchored menu.
  ///
  /// If null, a heading takes the minimum size, padding, shape and icon size
  /// of the menu's rows, so it lines up with them.
  final StreamContextMenuHeadingThemeData? menuHeadingStyle;

  /// How far the anchored menu opens from its anchor, on the side
  /// [StreamAdaptiveMenuAnchor.direction] names.
  ///
  /// Ignored when [StreamAdaptiveMenuAnchor.alignmentOffset] is given. If
  /// null, defaults to [StreamSpacing.xs].
  final double? menuGap;

  /// The rows of the bottom sheet.
  ///
  /// Applies on top of the app's list tile theme, so a row keeps its colors
  /// and text styles. Its padding comes from here rather than from the app's
  /// list tile theme: defaults to [StreamSpacing.sm] across and
  /// [StreamSpacing.xxs] down, which makes a row 48 tall.
  final StreamListTileThemeData? sheetTileStyle;

  /// Overrides for the section headings of the bottom sheet.
  ///
  /// If null, a heading is inset horizontally by the same amount as the
  /// [StreamListTile]s under it, so the two line up.
  final StreamContextMenuHeadingThemeData? sheetHeadingStyle;

  /// The inset around every row, heading and content of the bottom sheet.
  ///
  /// Keeps a selected row's rounded fill clear of the sheet's edges. If null,
  /// defaults to [StreamSpacing.xxs] on either side.
  final EdgeInsetsGeometry? sheetPadding;

  /// Linearly interpolate between two [StreamAdaptiveMenuAnchorStyle] objects.
  static StreamAdaptiveMenuAnchorStyle? lerp(
    StreamAdaptiveMenuAnchorStyle? a,
    StreamAdaptiveMenuAnchorStyle? b,
    double t,
  ) => _$StreamAdaptiveMenuAnchorStyle.lerp(a, b, t);
}
