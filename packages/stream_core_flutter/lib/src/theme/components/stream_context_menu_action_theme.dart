import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';

part 'stream_context_menu_action_theme.g.theme.dart';

/// Applies a context menu action theme to descendant context menu action
/// widgets.
///
/// Wrap a subtree with [StreamContextMenuActionTheme] to override context menu
/// action styling. Access the merged theme using
/// [BuildContext.streamContextMenuActionTheme].
///
/// {@tool snippet}
///
/// Override context menu action styling for a specific section:
///
/// ```dart
/// StreamContextMenuActionTheme(
///   data: StreamContextMenuActionThemeData(
///     style: StreamContextMenuActionStyle(
///       textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 16)),
///       iconSize: WidgetStatePropertyAll(18),
///     ),
///   ),
///   child: StreamContextMenu(
///     children: [
///       StreamContextMenuAction(label: Text('Reply')),
///     ],
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamContextMenuActionThemeData], which describes the action theme.
///  * [StreamContextMenuActionStyle], for action-level styling.
///  * [StreamContextMenuAction], which uses this theme.
class StreamContextMenuActionTheme extends InheritedTheme {
  /// Creates a context menu action theme that controls descendant actions.
  const StreamContextMenuActionTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The context menu action theme data for descendant widgets.
  final StreamContextMenuActionThemeData data;

  /// Returns the [StreamContextMenuActionThemeData] from the current theme
  /// context.
  ///
  /// This merges the local theme (if any) with the global theme from
  /// [StreamTheme].
  static StreamContextMenuActionThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamContextMenuActionTheme>();
    return StreamTheme.of(context).contextMenuActionTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamContextMenuActionTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamContextMenuActionTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing context menu actions.
///
/// {@tool snippet}
///
/// Customize context menu action appearance globally:
///
/// ```dart
/// StreamTheme(
///   contextMenuActionTheme: StreamContextMenuActionThemeData(
///     style: StreamContextMenuActionStyle(
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
///  * [StreamContextMenuActionTheme], for overriding theme in a widget subtree.
///  * [StreamContextMenuActionStyle], for action-level styling.
@themeGen
@immutable
class StreamContextMenuActionThemeData with _$StreamContextMenuActionThemeData {
  /// Creates a context menu action theme with optional style overrides.
  const StreamContextMenuActionThemeData({this.style});

  /// The visual styling for context menu actions.
  ///
  /// Contains text style, icon size, padding, border radius, and
  /// state-based color properties.
  final StreamContextMenuActionStyle? style;

  /// Linearly interpolate between two [StreamContextMenuActionThemeData]
  /// values.
  static StreamContextMenuActionThemeData? lerp(
    StreamContextMenuActionThemeData? a,
    StreamContextMenuActionThemeData? b,
    double t,
  ) => _$StreamContextMenuActionThemeData.lerp(a, b, t);
}

/// Visual styling properties for context menu actions.
///
/// Defines the appearance of menu actions including layout, text style, and
/// state-based colors. All properties are [WidgetStateProperty] to support
/// interactive feedback (default, hover, pressed, disabled), consistent
/// with Flutter's [ButtonStyle] pattern.
///
/// See also:
///
///  * [StreamContextMenuActionThemeData], which contains this style.
///  * [StreamContextMenuAction], which uses this styling.
@themeGen
@immutable
class StreamContextMenuActionStyle with _$StreamContextMenuActionStyle {
  /// Creates context menu action style properties.
  const StreamContextMenuActionStyle({
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

  /// The background color of the action.
  ///
  /// If null, defaults to [StreamColors.transparent].
  final WidgetStateProperty<Color?>? backgroundColor;

  /// The foreground color for the action's text and icons.
  ///
  /// This is the default color for both text and icon descendants. To
  /// override the icon color independently, use [iconColor].
  ///
  /// Supports state-based colors for different interaction states
  /// (default, hover, pressed, disabled).
  final WidgetStateProperty<Color?>? foregroundColor;

  /// The overlay color for the action's interaction feedback.
  ///
  /// Supports state-based colors for hover and press states.
  final WidgetStateProperty<Color?>? overlayColor;

  /// The icon color inside the action.
  ///
  /// If null, the icon color falls back to [foregroundColor].
  final WidgetStateProperty<Color?>? iconColor;

  /// The text style for the action label.
  ///
  /// If null, defaults to [StreamTextTheme.bodyEmphasis].
  /// The text color is controlled by [foregroundColor].
  final WidgetStateProperty<TextStyle?>? textStyle;

  /// The size of icons in the action.
  ///
  /// If null, defaults to 20.
  final WidgetStateProperty<double?>? iconSize;

  /// The minimum size of the action.
  ///
  /// If null, defaults to `Size(242, 40)`.
  final WidgetStateProperty<Size?>? minimumSize;

  /// The maximum size of the action.
  ///
  /// If null, defaults to [Size.infinite] (no maximum constraint).
  final WidgetStateProperty<Size?>? maximumSize;

  /// The padding inside the action.
  ///
  /// If null, defaults are derived from [StreamSpacing].
  final WidgetStateProperty<EdgeInsetsGeometry?>? padding;

  /// The shape of the action's underlying surface.
  ///
  /// If null, defaults to a [RoundedRectangleBorder] with
  /// [StreamRadius.md] border radius.
  final WidgetStateProperty<OutlinedBorder?>? shape;

  /// Linearly interpolate between two [StreamContextMenuActionStyle] values.
  static StreamContextMenuActionStyle? lerp(
    StreamContextMenuActionStyle? a,
    StreamContextMenuActionStyle? b,
    double t,
  ) => _$StreamContextMenuActionStyle.lerp(a, b, t);
}
