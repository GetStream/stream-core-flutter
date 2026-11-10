import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_context_menu_action_theme.dart';
import '../../theme/components/stream_context_menu_anchor_theme.dart';
import '../../theme/components/stream_context_menu_theme.dart';
import '../../theme/primitives/stream_spacing.dart';
import '../../theme/stream_theme_extensions.dart';
import 'stream_context_menu.dart';
import 'stream_context_menu_action.dart';

/// Anchors a [StreamContextMenu] to the widget built by [builder].
///
/// Wraps [MenuAnchor] with the plumbing every Stream-styled dropdown needs:
/// [MenuAnchor]'s own Material panel is neutralized (see [menuStyle]) so that
/// [StreamContextMenu] supplies the whole surface, the panel is bounded by
/// `constraints`, and descendant [StreamContextMenuAction]s are sized and
/// styled like the `Web / Menu Item` component in the design (see
/// [defaultActionStyle]).
///
/// [StreamContextMenu] sizes itself to its widest child, so labels that can be
/// arbitrarily long need [TextOverflow.ellipsis] to truncate rather than wrap.
///
/// {@tool snippet}
///
/// A button that opens a menu of sort orders below it:
///
/// ```dart
/// StreamContextMenuAnchor(
///   alignmentOffset: Offset(0, 8),
///   menuChildren: [
///     StreamContextMenuAction(label: Text('Newest first'), onTap: sortNewest),
///     StreamContextMenuAction(label: Text('Oldest first'), onTap: sortOldest),
///   ],
///   builder: (context, controller, child) => StreamButton(
///     onPressed: () => controller.isOpen ? controller.close() : controller.open(),
///     child: Text('Sort'),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamContextMenu], the menu surface this anchors.
///  * [StreamContextMenuAction], for the rows of the menu.
///  * [StreamContextMenuAnchorTheme], for customizing anchored menus.
///  * [StreamContextMenuTheme], for customizing the menu surface.
@experimental
class StreamContextMenuAnchor extends StatelessWidget {
  /// Creates a menu anchor hosting a [StreamContextMenu].
  StreamContextMenuAnchor({
    super.key,
    required List<Widget> menuChildren,
    required MenuAnchorChildBuilder builder,
    MenuController? controller,
    BoxConstraints? constraints,
    Offset? alignmentOffset,
    StreamContextMenuActionStyle? actionStyle,
    double? elevation,
    VoidCallback? onOpen,
    VoidCallback? onClose,
  }) : props = .new(
         menuChildren: menuChildren,
         builder: builder,
         controller: controller,
         constraints: constraints,
         alignmentOffset: alignmentOffset,
         actionStyle: actionStyle,
         elevation: elevation,
         onOpen: onOpen,
         onClose: onClose,
       );

  /// The default bounds of the menu panel.
  ///
  /// The minimum width comes from the menu items themselves, which carry the
  /// design's 200px minimum.
  static const defaultConstraints = BoxConstraints(
    maxWidth: 320,
    maxHeight: 360,
  );

  /// A [MenuStyle] that hides [MenuAnchor]'s own Material panel.
  ///
  /// Use it on a plain [MenuAnchor] when the menu content already draws its
  /// own surface, as [StreamContextMenu] does: background, border, radius and
  /// elevation all come from the content instead.
  static const menuStyle = MenuStyle(
    backgroundColor: WidgetStatePropertyAll(Colors.transparent),
    shadowColor: WidgetStatePropertyAll(Colors.transparent),
    surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
    elevation: WidgetStatePropertyAll(0),
    padding: WidgetStatePropertyAll(EdgeInsets.zero),
  );

  /// The row style every action in an anchored menu starts from.
  ///
  /// This is the design's `Web / Menu Item`: a 32px tall row with a 200px
  /// minimum width, a caption/emphasis label and 16px icons, where a plain
  /// [StreamContextMenu] uses a 40px tall row with a 242px minimum width, a
  /// body/emphasis label and 20px icons. The row is inset horizontally by
  /// [StreamSpacing.xs] on top of the menu's own padding, which puts the
  /// content 12px from the panel edge and leaves the row's rounded highlight
  /// 4px inside it.
  ///
  /// The [StreamContextMenuAnchorThemeData.actionStyle] in effect at [context]
  /// is merged over those metrics, so the result is what every row of a
  /// [StreamContextMenuAnchor] there gets before the anchor's own
  /// `actionStyle`.
  ///
  /// [StreamContextMenuActionTheme.of] reads only the nearest theme, so
  /// anything that varies a single row — wrapping it in its own
  /// [StreamContextMenuActionTheme] — has to merge its override over this
  /// style, or that row falls back to the plain context menu metrics while
  /// its siblings keep the design's.
  static StreamContextMenuActionStyle defaultActionStyle(BuildContext context) {
    final designStyle = _StreamContextMenuAnchorThemeDefaults(context).actionStyle;
    return designStyle.merge(context.streamContextMenuAnchorTheme.actionStyle);
  }

  /// The properties that configure this menu anchor.
  final StreamContextMenuAnchorProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).contextMenuAnchor;
    if (builder != null) return builder(context, props);
    return DefaultStreamContextMenuAnchor(props: props);
  }
}

/// Properties for configuring a [StreamContextMenuAnchor].
///
/// This class holds all the configuration options for a menu anchor,
/// allowing them to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamContextMenuAnchor], which uses these properties.
///  * [DefaultStreamContextMenuAnchor], the default implementation.
@experimental
class StreamContextMenuAnchorProps {
  /// Creates properties for a menu anchor.
  const StreamContextMenuAnchorProps({
    required this.menuChildren,
    required this.builder,
    this.controller,
    this.constraints,
    this.alignmentOffset,
    this.actionStyle,
    this.elevation,
    this.onOpen,
    this.onClose,
  });

  /// The items of the menu, passed to [StreamContextMenu.children].
  ///
  /// Typically [StreamContextMenuAction]s, [StreamContextMenuSeparator]s and
  /// section headings.
  ///
  /// Tapping a [StreamContextMenuAction] closes the menu, unless its
  /// `closeOnActivate` is false.
  final List<Widget> menuChildren;

  /// Builds the widget the menu is anchored to.
  ///
  /// The builder receives the [MenuController] that opens and closes the
  /// menu, whether or not [controller] is given.
  final MenuAnchorChildBuilder builder;

  /// The controller opening and closing the menu.
  ///
  /// If null, the anchor creates its own, which is handed to [builder].
  final MenuController? controller;

  /// The bounds of the menu panel.
  ///
  /// The menu sizes itself to its widest row within these bounds and scrolls
  /// once its rows outgrow the maximum height. A tight width makes the menu
  /// exactly that wide, overriding the rows' own minimum width.
  ///
  /// If null, resolves from [StreamContextMenuAnchorThemeData.constraints],
  /// then falls back to [StreamContextMenuAnchor.defaultConstraints].
  final BoxConstraints? constraints;

  /// The offset of the menu relative to the anchor.
  ///
  /// If null, resolves from [StreamContextMenuAnchorThemeData.alignmentOffset],
  /// then falls back to [Offset.zero].
  final Offset? alignmentOffset;

  /// Overrides for the rows inside the menu.
  ///
  /// Merged over [StreamContextMenuAnchor.defaultActionStyle], which already
  /// carries [StreamContextMenuAnchorThemeData.actionStyle]. That style is
  /// sized for a 16px icon beside a caption; a menu whose rows carry something
  /// bigger — an avatar, a thumbnail — needs a taller row and a wider inset, or
  /// its content fills the row edge to edge.
  final StreamContextMenuActionStyle? actionStyle;

  /// How high the menu floats above the page.
  ///
  /// If null, resolves from [StreamContextMenuStyle.elevation], then falls
  /// back to `3`. Pass 0 for a menu that sits flat on the page and is
  /// separated from it by its border alone.
  final double? elevation;

  /// Called when the menu opens.
  final VoidCallback? onOpen;

  /// Called when the menu closes.
  final VoidCallback? onClose;
}

/// The default implementation of [StreamContextMenuAnchor].
///
/// See also:
///
///  * [StreamContextMenuAnchor], the public API widget.
///  * [StreamContextMenuAnchorProps], which configures this widget.
@experimental
class DefaultStreamContextMenuAnchor extends StatelessWidget {
  /// Creates a default menu anchor with the given [props].
  const DefaultStreamContextMenuAnchor({super.key, required this.props});

  /// The properties that configure this menu anchor.
  final StreamContextMenuAnchorProps props;

  @override
  Widget build(BuildContext context) {
    final anchorTheme = context.streamContextMenuAnchorTheme;
    final defaults = _StreamContextMenuAnchorThemeDefaults(context);

    final effectiveConstraints = props.constraints ?? anchorTheme.constraints ?? defaults.constraints;
    final effectiveAlignmentOffset = props.alignmentOffset ?? anchorTheme.alignmentOffset ?? defaults.alignmentOffset;
    final effectiveActionStyle = StreamContextMenuAnchor.defaultActionStyle(context).merge(props.actionStyle);

    return MenuAnchor(
      controller: props.controller,
      alignmentOffset: effectiveAlignmentOffset,
      // The panel's default clip cuts off the shadow the menu draws outside
      // its own bounds, most visibly along the bottom edge. The menu draws its
      // own surface and clips its own content, so the panel needs no clip.
      clipBehavior: Clip.none,
      onOpen: props.onOpen,
      onClose: props.onClose,
      style: StreamContextMenuAnchor.menuStyle,
      builder: props.builder,
      menuChildren: [
        // The panel and the menu both scroll vertically, and on mobile both
        // would attach to the PrimaryScrollController, which trips the
        // panel's Scrollbar assertion. The panel keeps the primary controller.
        PrimaryScrollController.none(
          child: ConstrainedBox(
            constraints: effectiveConstraints,
            child: StreamContextMenuActionTheme(
              data: StreamContextMenuActionThemeData(style: effectiveActionStyle),
              child: StreamContextMenu(
                elevation: props.elevation,
                children: props.menuChildren,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Default values for [StreamContextMenuAnchorThemeData], resolved from the
// design's `Web / Menu Item` and the current spacing and text theme.
class _StreamContextMenuAnchorThemeDefaults extends StreamContextMenuAnchorThemeData {
  const _StreamContextMenuAnchorThemeDefaults(this.context);

  final BuildContext context;

  @override
  BoxConstraints get constraints => StreamContextMenuAnchor.defaultConstraints;

  @override
  Offset get alignmentOffset => Offset.zero;

  @override
  StreamContextMenuActionStyle get actionStyle => StreamContextMenuActionStyle(
    textStyle: WidgetStatePropertyAll(context.streamTextTheme.captionEmphasis),
    iconSize: const WidgetStatePropertyAll(16),
    minimumSize: const WidgetStatePropertyAll(Size(200, 32)),
    padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: context.streamSpacing.xs)),
  );
}
