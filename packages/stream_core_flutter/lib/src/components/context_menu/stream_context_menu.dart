import 'package:flutter/material.dart';

import '../../theme/components/stream_context_menu_theme.dart';
import '../../theme/primitives/stream_radius.dart';
import '../../theme/primitives/stream_spacing.dart';
import '../../theme/semantics/stream_box_shadow.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/stream_theme_extensions.dart';

/// A contextual menu container that displays a list of menu items.
///
/// [StreamContextMenu] renders its [children] in a vertical list inside a
/// decorated container with a shape, border, and drop shadow. The container
/// is sized intrinsically to the width of its widest child.
///
/// Children are typically [StreamContextMenuItem] and
/// [StreamContextMenuSeparator] widgets. Use [StreamContextMenu.separated]
/// to automatically insert separators between each child.
///
/// The container's appearance can be customized via [StreamContextMenuTheme].
///
/// {@tool snippet}
///
/// Display a context menu with items:
///
/// ```dart
/// StreamContextMenu(
///   children: [
///     StreamContextMenuItem(
///       label: Text('Reply'),
///       leading: Icon(Icons.reply),
///       onPressed: () => handleReply(),
///     ),
///     StreamContextMenuItem(
///       label: Text('Copy Message'),
///       leading: Icon(Icons.copy),
///       onPressed: () => handleCopy(),
///     ),
///     StreamContextMenuSeparator(),
///     StreamContextMenuItem.destructive(
///       label: Text('Block User'),
///       leading: Icon(Icons.block),
///       onPressed: () => handleBlock(),
///     ),
///   ],
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamContextMenuItem], for individual menu items.
///  * [StreamContextMenuSeparator], for visual dividers between groups.
///  * [StreamContextMenuTheme], for customizing container appearance.
///  * [StreamContextMenuItemTheme], for customizing item appearance.
class StreamContextMenu extends StatelessWidget {
  /// Creates a context menu container.
  const StreamContextMenu({
    super.key,
    required this.children,
    this.clipBehavior = Clip.hardEdge,
  });

  /// Creates a context menu with [StreamContextMenuSeparator] widgets
  /// automatically inserted between each child.
  ///
  /// {@tool snippet}
  ///
  /// ```dart
  /// StreamContextMenu.separated(
  ///   children: [
  ///     StreamContextMenuItem(label: Text('Reply'), onPressed: () {}),
  ///     StreamContextMenuItem(label: Text('Copy'), onPressed: () {}),
  ///     StreamContextMenuItem(label: Text('Delete'), onPressed: () {}),
  ///   ],
  /// )
  /// ```
  /// {@end-tool}
  factory StreamContextMenu.separated({
    Key? key,
    required List<Widget> children,
    Clip clipBehavior = Clip.hardEdge,
  }) {
    return StreamContextMenu(
      key: key,
      clipBehavior: clipBehavior,
      children: [
        for (final (index, child) in children.indexed) ...[
          if (index > 0) const StreamContextMenuSeparator(),
          child,
        ],
      ],
    );
  }

  /// The menu items to display.
  ///
  /// Typically a list of [StreamContextMenuItem] and
  /// [StreamContextMenuSeparator] widgets.
  final List<Widget> children;

  /// The clip behavior for the menu container.
  ///
  /// Clips the menu content to the container's rounded shape.
  ///
  /// Defaults to [Clip.hardEdge].
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final themeStyle = context.streamContextMenuTheme.style;
    final defaults = _ContextMenuStyleDefaults(context);

    final effectiveBackgroundColor = themeStyle?.backgroundColor ?? defaults.backgroundColor;
    final effectiveBoxShadow = themeStyle?.boxShadow ?? defaults.boxShadow;
    final effectivePadding = themeStyle?.padding ?? defaults.padding;
    final effectiveSide = themeStyle?.side ?? defaults.side;
    final effectiveShape = (themeStyle?.shape ?? defaults.shape).copyWith(side: effectiveSide);

    return IntrinsicWidth(
      child: Container(
        clipBehavior: clipBehavior,
        padding: effectivePadding,
        decoration: ShapeDecoration(
          shape: effectiveShape,
          color: effectiveBackgroundColor,
          shadows: effectiveBoxShadow,
        ),
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .stretch,
          children: children,
        ),
      ),
    );
  }
}

/// A visual separator between groups of items in a [StreamContextMenu].
///
/// Displays a thin horizontal line with vertical padding. Use it to visually
/// separate groups of related context menu items, for example between regular
/// actions and destructive actions.
///
/// For automatic separator insertion between every child, use
/// [StreamContextMenu.separated] instead.
///
/// {@tool snippet}
///
/// Add a separator between item groups:
///
/// ```dart
/// StreamContextMenu(
///   children: [
///     StreamContextMenuItem(label: Text('Reply'), onPressed: () {}),
///     StreamContextMenuItem(label: Text('Copy'), onPressed: () {}),
///     StreamContextMenuSeparator(),
///     StreamContextMenuItem.destructive(
///       label: Text('Delete'),
///       onPressed: () {},
///     ),
///   ],
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamContextMenu], which contains this separator.
///  * [StreamContextMenu.separated], which auto-inserts separators.
///  * [StreamContextMenuItem], for menu items.
class StreamContextMenuSeparator extends StatelessWidget {
  /// Creates a context menu separator.
  const StreamContextMenuSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;
    final colorScheme = context.streamColorScheme;

    return Padding(
      padding: .symmetric(vertical: spacing.xxs),
      child: Divider(height: 1, thickness: 1, color: colorScheme.borderDefault),
    );
  }
}

/// Default values for [StreamContextMenuStyle].
///
/// Provides sensible defaults based on the current [StreamColorScheme],
/// [StreamRadius], [StreamSpacing], and [StreamBoxShadow].
class _ContextMenuStyleDefaults extends StreamContextMenuStyle {
  _ContextMenuStyleDefaults(this.context);

  final BuildContext context;

  late final StreamRadius _radius = context.streamRadius;
  late final StreamSpacing _spacing = context.streamSpacing;
  late final StreamBoxShadow _boxShadow = context.streamBoxShadow;
  late final StreamColorScheme _colorScheme = context.streamColorScheme;

  @override
  OutlinedBorder get shape => RoundedRectangleBorder(borderRadius: .all(_radius.lg));

  @override
  BorderSide get side => BorderSide(color: _colorScheme.borderDefault);

  @override
  Color get backgroundColor => _colorScheme.backgroundElevation2;

  @override
  List<BoxShadow> get boxShadow => _boxShadow.elevation2;

  @override
  EdgeInsetsGeometry get padding => EdgeInsets.all(_spacing.xxs);
}
