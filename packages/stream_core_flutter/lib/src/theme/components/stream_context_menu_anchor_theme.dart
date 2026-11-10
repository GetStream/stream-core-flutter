import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../../components/context_menu/stream_context_menu.dart';
import '../../components/context_menu/stream_context_menu_anchor.dart';
import '../stream_theme.dart';
import 'stream_context_menu_action_theme.dart';
import 'stream_context_menu_theme.dart';

part 'stream_context_menu_anchor_theme.g.theme.dart';

/// Applies a context menu anchor theme to descendant [StreamContextMenuAnchor]
/// widgets.
///
/// Wrap a subtree with [StreamContextMenuAnchorTheme] to override how anchored
/// menus are placed, bounded and how their rows are sized. Access the merged
/// theme using [BuildContext.streamContextMenuAnchorTheme].
///
/// The menu surface itself — background, border, radius and elevation — is
/// themed through [StreamContextMenuTheme], which applies to anchored and
/// inline menus alike.
///
/// {@tool snippet}
///
/// Open every menu in a section 8px below its anchor, with taller rows:
///
/// ```dart
/// StreamContextMenuAnchorTheme(
///   data: StreamContextMenuAnchorThemeData(
///     alignmentOffset: Offset(0, 8),
///     actionStyle: StreamContextMenuActionStyle(
///       minimumSize: WidgetStatePropertyAll(Size(200, 40)),
///     ),
///   ),
///   child: toolbar,
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamContextMenuAnchorThemeData], which describes the anchor theme.
///  * [StreamContextMenuAnchor], the widget affected by this theme.
@experimental
class StreamContextMenuAnchorTheme extends InheritedTheme {
  /// Creates a context menu anchor theme that controls descendant anchors.
  const StreamContextMenuAnchorTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The context menu anchor theme data for descendant widgets.
  final StreamContextMenuAnchorThemeData data;

  /// Returns the [StreamContextMenuAnchorThemeData] merged from local and
  /// global themes.
  ///
  /// Local values from the nearest [StreamContextMenuAnchorTheme] ancestor take
  /// precedence over global values from [StreamTheme.of].
  static StreamContextMenuAnchorThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamContextMenuAnchorTheme>();
    return StreamTheme.of(context).contextMenuAnchorTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamContextMenuAnchorTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamContextMenuAnchorTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing [StreamContextMenuAnchor] widgets.
///
/// Holds only what the anchor adds on top of a [StreamContextMenu]: where the
/// menu opens, how large it may grow, and how its rows are sized. The menu
/// surface is themed through [StreamContextMenuThemeData].
///
/// {@tool snippet}
///
/// Let anchored menus grow taller app-wide:
///
/// ```dart
/// StreamTheme(
///   contextMenuAnchorTheme: StreamContextMenuAnchorThemeData(
///     constraints: BoxConstraints(maxWidth: 320, maxHeight: 480),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamContextMenuAnchorTheme], for overriding the theme in a subtree.
///  * [StreamContextMenuAnchor], the widget that uses this theme data.
@themeGen
@immutable
@experimental
class StreamContextMenuAnchorThemeData with _$StreamContextMenuAnchorThemeData {
  /// Creates context menu anchor theme data with optional overrides.
  const StreamContextMenuAnchorThemeData({
    this.constraints,
    this.alignmentOffset,
    this.actionStyle,
  });

  /// The bounds of the menu panel.
  ///
  /// The menu sizes itself to its widest row within these bounds and scrolls
  /// once its rows outgrow the maximum height.
  ///
  /// If null, defaults to [StreamContextMenuAnchor.defaultConstraints].
  final BoxConstraints? constraints;

  /// The offset of the menu relative to the anchor.
  ///
  /// If null, defaults to [Offset.zero], which opens the menu flush against
  /// the anchor.
  final Offset? alignmentOffset;

  /// Overrides for the rows inside the menu.
  ///
  /// Merged over the design's `Web / Menu Item` metrics, so only the
  /// properties set here change. See
  /// [StreamContextMenuAnchor.defaultActionStyle] for those metrics.
  final StreamContextMenuActionStyle? actionStyle;

  /// Linearly interpolate between two [StreamContextMenuAnchorThemeData]
  /// objects.
  static StreamContextMenuAnchorThemeData? lerp(
    StreamContextMenuAnchorThemeData? a,
    StreamContextMenuAnchorThemeData? b,
    double t,
  ) => _$StreamContextMenuAnchorThemeData.lerp(a, b, t);
}
