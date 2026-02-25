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
/// Children are typically [StreamContextMenuAction] and
/// [StreamContextMenuSeparator] widgets. For automatic separator insertion,
/// use [StreamContextMenuAction.separated] to divide every item, or
/// [StreamContextMenuAction.sectioned] to divide logical groups.
///
/// The container's appearance can be customized via [StreamContextMenuTheme].
///
/// {@tool snippet}
///
/// A basic context menu with a manual separator:
///
/// ```dart
/// StreamContextMenu(
///   children: [
///     StreamContextMenuAction(
///       value: 'reply',
///       label: Text('Reply'),
///       leading: Icon(Icons.reply),
///     ),
///     StreamContextMenuAction(
///       value: 'copy',
///       label: Text('Copy Message'),
///       leading: Icon(Icons.copy),
///     ),
///     StreamContextMenuSeparator(),
///     StreamContextMenuAction.destructive(
///       value: 'block',
///       label: Text('Block User'),
///       leading: Icon(Icons.block),
///     ),
///   ],
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamContextMenuAction], for individual menu items.
///  * [StreamContextMenuAction.separated], for auto-inserting separators between
///    every item.
///  * [StreamContextMenuAction.sectioned], for auto-inserting separators between
///    logical groups of items.
///  * [StreamContextMenuSeparator], for manual visual dividers.
///  * [StreamContextMenuTheme], for customizing container appearance.
///  * [StreamContextMenuActionTheme], for customizing item appearance.
class StreamContextMenu extends StatelessWidget {
  /// Creates a context menu container.
  const StreamContextMenu({
    super.key,
    required this.children,
    this.clipBehavior = Clip.hardEdge,
  });

  /// The menu items to display.
  ///
  /// Typically a list of [StreamContextMenuAction] and
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .stretch,
            children: children,
          ),
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
/// For automatic separator insertion, use [StreamContextMenuAction.separated]
/// (between every item) or [StreamContextMenuAction.sectioned] (between logical
/// groups) instead of placing separators manually.
///
/// {@tool snippet}
///
/// Add a separator between item groups:
///
/// ```dart
/// StreamContextMenu(
///   children: [
///     StreamContextMenuAction(label: Text('Reply')),
///     StreamContextMenuAction(label: Text('Copy')),
///     StreamContextMenuSeparator(),
///     StreamContextMenuAction.destructive(
///       label: Text('Delete'),
///     ),
///   ],
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamContextMenu], which contains this separator.
///  * [StreamContextMenuAction.separated], which auto-inserts separators
///    between every item.
///  * [StreamContextMenuAction.sectioned], which auto-inserts separators
///    between logical groups of items.
///  * [StreamContextMenuAction], for menu items.
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
