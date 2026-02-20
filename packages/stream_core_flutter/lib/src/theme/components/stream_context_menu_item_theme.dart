import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';

part 'stream_context_menu_item_theme.g.theme.dart';

/// Applies a context menu item theme to descendant context menu item widgets.
///
/// Wrap a subtree with [StreamContextMenuItemTheme] to override context menu
/// item styling. Access the merged theme using
/// [BuildContext.streamContextMenuItemTheme].
///
/// {@tool snippet}
///
/// Override context menu item styling for a specific section:
///
/// ```dart
/// StreamContextMenuItemTheme(
///   data: StreamContextMenuItemThemeData(
///     style: StreamContextMenuItemStyle(
///       textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 16)),
///       iconSize: WidgetStatePropertyAll(18),
///     ),
///   ),
///   child: StreamContextMenu(
///     children: [
///       StreamContextMenuItem(label: Text('Reply'), onPressed: () {}),
///     ],
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamContextMenuItemThemeData], which describes the item theme.
///  * [StreamContextMenuItemStyle], for item-level styling.
///  * [StreamContextMenuItem], which uses this theme.
class StreamContextMenuItemTheme extends InheritedTheme {
  /// Creates a context menu item theme that controls descendant items.
  const StreamContextMenuItemTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The context menu item theme data for descendant widgets.
  final StreamContextMenuItemThemeData data;

  /// Returns the [StreamContextMenuItemThemeData] from the current theme
  /// context.
  ///
  /// This merges the local theme (if any) with the global theme from
  /// [StreamTheme].
  static StreamContextMenuItemThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamContextMenuItemTheme>();
    return StreamTheme.of(context).contextMenuItemTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamContextMenuItemTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamContextMenuItemTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing context menu items.
///
/// {@tool snippet}
///
/// Customize context menu item appearance globally:
///
/// ```dart
/// StreamTheme(
///   contextMenuItemTheme: StreamContextMenuItemThemeData(
///     style: StreamContextMenuItemStyle(
///       textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 14)),
///       iconSize: WidgetStatePropertyAll(20),
///       padding: WidgetStatePropertyAll(EdgeInsets.all(8)),
///     ),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamContextMenuItemTheme], for overriding theme in a widget subtree.
///  * [StreamContextMenuItemStyle], for item-level styling.
@themeGen
@immutable
class StreamContextMenuItemThemeData with _$StreamContextMenuItemThemeData {
  /// Creates a context menu item theme with optional style overrides.
  const StreamContextMenuItemThemeData({this.style});

  /// The visual styling for context menu items.
  ///
  /// Contains text style, icon size, padding, border radius, and
  /// state-based color properties.
  final StreamContextMenuItemStyle? style;

  /// Linearly interpolate between two [StreamContextMenuItemThemeData] values.
  static StreamContextMenuItemThemeData? lerp(
    StreamContextMenuItemThemeData? a,
    StreamContextMenuItemThemeData? b,
    double t,
  ) => _$StreamContextMenuItemThemeData.lerp(a, b, t);
}

/// Visual styling properties for context menu items.
///
/// Defines the appearance of menu items including layout, text style, and
/// state-based colors. All properties are [WidgetStateProperty] to support
/// interactive feedback (default, hover, pressed, disabled), consistent
/// with Flutter's [ButtonStyle] pattern.
///
/// See also:
///
///  * [StreamContextMenuItemThemeData], which contains this style.
///  * [StreamContextMenuItem], which uses this styling.
@themeGen
@immutable
class StreamContextMenuItemStyle with _$StreamContextMenuItemStyle {
  /// Creates context menu item style properties.
  const StreamContextMenuItemStyle({
    this.backgroundColor,
    this.foregroundColor,
    this.overlayColor,
    this.iconColor,
    this.textStyle,
    this.iconSize,
    this.minimumSize,
    this.maximumSize,
    this.padding,
    this.shape,
  });

  /// The background color of the item.
  ///
  /// If null, defaults to [StreamColors.transparent].
  final WidgetStateProperty<Color?>? backgroundColor;

  /// The foreground color for the item's text and icons.
  ///
  /// This is the default color for both text and icon descendants. To
  /// override the icon color independently, use [iconColor].
  ///
  /// Supports state-based colors for different interaction states
  /// (default, hover, pressed, disabled).
  final WidgetStateProperty<Color?>? foregroundColor;

  /// The overlay color for the item's interaction feedback.
  ///
  /// Supports state-based colors for hover and press states.
  final WidgetStateProperty<Color?>? overlayColor;

  /// The icon color inside the item.
  ///
  /// If null, the icon color falls back to [foregroundColor].
  final WidgetStateProperty<Color?>? iconColor;

  /// The text style for the item label.
  ///
  /// If null, defaults to [StreamTextTheme.bodyEmphasis].
  /// The text color is controlled by [foregroundColor].
  final WidgetStateProperty<TextStyle?>? textStyle;

  /// The size of icons in the item.
  ///
  /// If null, defaults to 20.
  final WidgetStateProperty<double?>? iconSize;

  /// The minimum size of the item.
  ///
  /// If null, defaults to `Size(242, 40)`.
  final WidgetStateProperty<Size?>? minimumSize;

  /// The maximum size of the item.
  ///
  /// If null, defaults to [Size.infinite] (no maximum constraint).
  final WidgetStateProperty<Size?>? maximumSize;

  /// The padding inside the item.
  ///
  /// If null, defaults are derived from [StreamSpacing].
  final WidgetStateProperty<EdgeInsetsGeometry?>? padding;

  /// The shape of the item's underlying surface.
  ///
  /// If null, defaults to a [RoundedRectangleBorder] with
  /// [StreamRadius.md] border radius.
  final WidgetStateProperty<OutlinedBorder?>? shape;

  /// Linearly interpolate between two [StreamContextMenuItemStyle] values.
  static StreamContextMenuItemStyle? lerp(
    StreamContextMenuItemStyle? a,
    StreamContextMenuItemStyle? b,
    double t,
  ) => _$StreamContextMenuItemStyle.lerp(a, b, t);
}
