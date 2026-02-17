import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';

part 'stream_context_menu_theme.g.theme.dart';

/// Applies a context menu theme to descendant context menu widgets.
///
/// Wrap a subtree with [StreamContextMenuTheme] to override context menu
/// styling. Access the merged theme using
/// [BuildContext.streamContextMenuTheme].
///
/// {@tool snippet}
///
/// Override context menu styling for a specific section:
///
/// ```dart
/// StreamContextMenuTheme(
///   data: StreamContextMenuThemeData(
///     style: StreamContextMenuStyle(
///       backgroundColor: Colors.grey.shade100,
///       shape: RoundedRectangleBorder(
///         borderRadius: BorderRadius.circular(16),
///       ),
///       side: BorderSide(color: Colors.grey.shade300),
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
///  * [StreamContextMenuThemeData], which describes the context menu theme.
///  * [StreamContextMenuStyle], for container-level styling.
///  * [StreamContextMenu], which uses this theme.
///  * [StreamContextMenuItemTheme], for customizing individual item appearance.
class StreamContextMenuTheme extends InheritedTheme {
  /// Creates a context menu theme that controls descendant context menus.
  const StreamContextMenuTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The context menu theme data for descendant widgets.
  final StreamContextMenuThemeData data;

  /// Returns the [StreamContextMenuThemeData] from the current theme context.
  ///
  /// This merges the local theme (if any) with the global theme from
  /// [StreamTheme].
  static StreamContextMenuThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamContextMenuTheme>();
    return StreamTheme.of(context).contextMenuTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamContextMenuTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamContextMenuTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing context menus.
///
/// Contains a [StreamContextMenuStyle] that defines the visual properties of
/// the menu container. This follows the same pattern as Flutter's
/// [MenuThemeData] which wraps [MenuStyle].
///
/// See also:
///
///  * [StreamContextMenuTheme], for overriding theme in a widget subtree.
///  * [StreamContextMenuStyle], for container-level styling.
///  * [StreamContextMenu], which uses these properties.
@themeGen
@immutable
class StreamContextMenuThemeData with _$StreamContextMenuThemeData {
  /// Creates context menu theme data with optional style overrides.
  const StreamContextMenuThemeData({this.style});

  /// The visual styling for the context menu container.
  ///
  /// Contains shape, border radius, surface color, and box shadow properties.
  final StreamContextMenuStyle? style;

  /// Linearly interpolate between two [StreamContextMenuThemeData] values.
  static StreamContextMenuThemeData? lerp(
    StreamContextMenuThemeData? a,
    StreamContextMenuThemeData? b,
    double t,
  ) => _$StreamContextMenuThemeData.lerp(a, b, t);
}

/// Visual styling properties for the context menu container.
///
/// Inspired by Flutter's [MenuStyle], this defines the appearance of the
/// menu container including its shape, border radius, surface color, and
/// shadow.
///
/// See also:
///
///  * [StreamContextMenuThemeData], which wraps this style for theming.
///  * [StreamContextMenu], which uses this styling.
@themeGen
@immutable
class StreamContextMenuStyle with _$StreamContextMenuStyle {
  /// Creates context menu style properties.
  const StreamContextMenuStyle({
    this.backgroundColor,
    this.shape,
    this.side,
    this.boxShadow,
    this.padding,
  });

  /// The background color of the context menu container.
  ///
  /// If null, defaults to [StreamColorScheme.backgroundElevation2].
  final Color? backgroundColor;

  /// The shape of the menu's underlying surface.
  ///
  /// This shape is combined with [side] to create a shape decorated with an
  /// outline.
  ///
  /// If null, defaults to a [RoundedRectangleBorder] with [StreamRadius.lg].
  final OutlinedBorder? shape;

  /// The color and weight of the menu's outline.
  ///
  /// This value is combined with [shape] to create a shape decorated with an
  /// outline.
  ///
  /// If null, defaults to a 1px [StreamColorScheme.borderDefault] border.
  final BorderSide? side;

  /// The box shadow of the context menu container.
  ///
  /// If null, defaults to [StreamBoxShadow.elevation2].
  final List<BoxShadow>? boxShadow;

  /// The padding between the menu's boundary and its children.
  ///
  /// If null, defaults to [StreamSpacing.xxs] on all sides.
  final EdgeInsetsGeometry? padding;

  /// Linearly interpolate between two [StreamContextMenuStyle] values.
  static StreamContextMenuStyle? lerp(
    StreamContextMenuStyle? a,
    StreamContextMenuStyle? b,
    double t,
  ) => _$StreamContextMenuStyle.lerp(a, b, t);
}
