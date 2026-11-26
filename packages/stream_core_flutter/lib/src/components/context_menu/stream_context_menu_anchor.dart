import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_context_menu_action_theme.dart';
import '../../theme/components/stream_context_menu_anchor_theme.dart';
import '../../theme/components/stream_context_menu_theme.dart';
import '../../theme/stream_theme_extensions.dart';
import 'stream_context_menu.dart';
import 'stream_context_menu_action.dart';

/// Opens a [StreamContextMenu] from the widget built by [builder].
///
/// Works like [MenuAnchor]: open and close it through the [MenuController]
/// passed to [builder].
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
/// {@tool snippet}
///
/// A long press that opens the menu where the finger is:
///
/// ```dart
/// StreamContextMenuAnchor(
///   menuChildren: [
///     StreamContextMenuAction(label: Text('Copy'), onTap: copy),
///     StreamContextMenuAction(label: Text('Delete'), onTap: delete),
///   ],
///   child: messageBubble,
///   builder: (context, controller, child) => GestureDetector(
///     onLongPressStart: (details) => controller.open(position: details.localPosition),
///     child: child,
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
    Widget? child,
    MenuController? controller,
    FocusNode? childFocusNode,
    BoxConstraints? constraints,
    Offset? alignmentOffset,
    EdgeInsetsGeometry? reservedPadding,
    bool consumeOutsideTap = false,
    bool useRootOverlay = false,
    StreamContextMenuActionStyle? actionStyle,
    double? elevation,
    VoidCallback? onOpen,
    VoidCallback? onClose,
  }) : props = .new(
         menuChildren: menuChildren,
         builder: builder,
         child: child,
         controller: controller,
         childFocusNode: childFocusNode,
         constraints: constraints,
         alignmentOffset: alignmentOffset,
         reservedPadding: reservedPadding,
         consumeOutsideTap: consumeOutsideTap,
         useRootOverlay: useRootOverlay,
         actionStyle: actionStyle,
         elevation: elevation,
         onOpen: onOpen,
         onClose: onClose,
       );

  /// The default bounds of the menu panel.
  ///
  /// The minimum width comes from the menu items themselves.
  static const defaultConstraints = BoxConstraints(
    maxWidth: 320,
    maxHeight: 360,
  );

  /// A [MenuStyle] that hides [MenuAnchor]'s own Material panel.
  ///
  /// Use it on a plain [MenuAnchor] when the menu content already draws its
  /// own surface, as [StreamContextMenu] does: background, border, radius,
  /// elevation and size all come from the content instead, whatever the
  /// enclosing [MenuTheme] sets.
  static const transparentPanelStyle = MenuStyle(
    backgroundColor: WidgetStatePropertyAll(Colors.transparent),
    shadowColor: WidgetStatePropertyAll(Colors.transparent),
    surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
    elevation: WidgetStatePropertyAll(0),
    padding: WidgetStatePropertyAll(EdgeInsets.zero),
    side: WidgetStatePropertyAll(BorderSide.none),
    shape: WidgetStatePropertyAll(RoundedRectangleBorder()),
    minimumSize: WidgetStatePropertyAll(Size.zero),
    maximumSize: WidgetStatePropertyAll(Size.infinite),
    visualDensity: VisualDensity.standard,
  );

  /// The row style every action in an anchored menu at [context] starts from.
  ///
  /// Anchored rows are denser than those of a plain [StreamContextMenu]. The
  /// [StreamContextMenuActionTheme] and then the
  /// [StreamContextMenuAnchorThemeData.actionStyle] in effect at [context] are
  /// merged over those metrics.
  static StreamContextMenuActionStyle defaultActionStyle(BuildContext context) {
    final designStyle = _StreamContextMenuAnchorThemeDefaults(context).actionStyle;
    return designStyle
        .merge(context.streamContextMenuActionTheme.style)
        .merge(context.streamContextMenuAnchorTheme.actionStyle);
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
    this.child,
    this.controller,
    this.childFocusNode,
    this.constraints,
    this.alignmentOffset,
    this.reservedPadding,
    this.consumeOutsideTap = false,
    this.useRootOverlay = false,
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
  /// menu, whether or not [controller] is given, and [child].
  final MenuAnchorChildBuilder builder;

  /// A widget passed to [builder] unchanged.
  ///
  /// Use it for the part of the anchor that does not depend on the menu being
  /// open, so it is not rebuilt when the menu opens or closes.
  final Widget? child;

  /// The controller opening and closing the menu.
  ///
  /// If null, the anchor creates its own, which is handed to [builder].
  final MenuController? controller;

  /// The focus node of the focusable widget built by [builder].
  ///
  /// It takes focus when the menu opens, so keyboard traversal out of the
  /// menu and Escape lead back to it.
  ///
  /// If null, focus moves to the anchor as a whole when the menu opens rather
  /// than to the widget built by [builder].
  final FocusNode? childFocusNode;

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

  /// The space the menu keeps from the edges of the safe area.
  ///
  /// The menu is never taller than the screen minus this padding, whatever
  /// [constraints] allows, so it scrolls its own rows on short screens.
  ///
  /// If null, uses the default of [MenuAnchor.reservedPadding].
  final EdgeInsetsGeometry? reservedPadding;

  /// Whether a tap outside the open menu only closes it.
  ///
  /// If false, the tap closes the menu and also reaches the widget under it.
  ///
  /// Defaults to false.
  final bool consumeOutsideTap;

  /// Whether the menu is shown in the root [Overlay] rather than the nearest
  /// one.
  ///
  /// Defaults to false.
  final bool useRootOverlay;

  /// Overrides for the rows inside the menu.
  ///
  /// Merged over [StreamContextMenuAnchor.defaultActionStyle]. A menu whose
  /// rows carry something bigger than an icon, such as an avatar, needs a
  /// taller row here.
  final StreamContextMenuActionStyle? actionStyle;

  /// How high the menu floats above the page.
  ///
  /// If null, resolves from [StreamContextMenuStyle.elevation]. Pass 0 for a
  /// menu that sits flat on the page, separated from it by its border alone.
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
class DefaultStreamContextMenuAnchor extends StatefulWidget {
  /// Creates a default menu anchor with the given [props].
  const DefaultStreamContextMenuAnchor({super.key, required this.props});

  /// The properties that configure this menu anchor.
  final StreamContextMenuAnchorProps props;

  @override
  State<DefaultStreamContextMenuAnchor> createState() => _DefaultStreamContextMenuAnchorState();
}

class _DefaultStreamContextMenuAnchorState extends State<DefaultStreamContextMenuAnchor> {
  // The space MenuAnchor keeps around its panel when no reservedPadding is given.
  static const _defaultReservedPadding = EdgeInsets.all(8);

  // Focused on open when no childFocusNode is given, so Escape closes the menu before an enclosing route.
  // Always in the tree, so switching childFocusNode does not remount the anchor.
  late final _fallbackFocusNode = FocusNode(debugLabel: 'StreamContextMenuAnchor', skipTraversal: true);

  StreamContextMenuAnchorProps get props => widget.props;

  @override
  void dispose() {
    _fallbackFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final anchorTheme = context.streamContextMenuAnchorTheme;
    final defaults = _StreamContextMenuAnchorThemeDefaults(context);

    final effectiveConstraints = props.constraints ?? anchorTheme.constraints ?? defaults.constraints;
    final effectiveAlignmentOffset = props.alignmentOffset ?? anchorTheme.alignmentOffset ?? defaults.alignmentOffset;
    final effectiveActionStyle = StreamContextMenuAnchor.defaultActionStyle(context).merge(props.actionStyle);

    // MenuAnchor's panel is the screen minus the reserved padding, and scrolls as a whole once the menu outgrows it.
    final reservedPadding = props.reservedPadding ?? _defaultReservedPadding;
    final availableHeight = math.max<double>(0, MediaQuery.sizeOf(context).height - reservedPadding.vertical);
    final menuConstraints = effectiveConstraints.enforce(BoxConstraints(maxHeight: availableHeight));

    final childFocusNode = props.childFocusNode;

    return MenuAnchor(
      controller: props.controller,
      childFocusNode: childFocusNode ?? _fallbackFocusNode,
      alignmentOffset: effectiveAlignmentOffset,
      reservedPadding: reservedPadding,
      consumeOutsideTap: props.consumeOutsideTap,
      useRootOverlay: props.useRootOverlay,
      // The menu draws its own shadow outside its bounds.
      clipBehavior: Clip.none,
      onOpen: props.onOpen,
      onClose: props.onClose,
      style: StreamContextMenuAnchor.transparentPanelStyle,
      builder: (context, controller, child) {
        return Focus(
          focusNode: _fallbackFocusNode,
          canRequestFocus: childFocusNode == null,
          child: props.builder(context, controller, child),
        );
      },
      menuChildren: [
        // The menu scrolls itself, so it must not share the panel's primary scroll controller.
        PrimaryScrollController.none(
          child: ConstrainedBox(
            constraints: menuConstraints,
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
      child: props.child,
    );
  }
}

// Default values for [StreamContextMenuAnchorThemeData], resolved from the
// current spacing, radius, color scheme and text theme.
class _StreamContextMenuAnchorThemeDefaults extends StreamContextMenuAnchorThemeData {
  const _StreamContextMenuAnchorThemeDefaults(this.context);

  final BuildContext context;

  @override
  BoxConstraints get constraints => StreamContextMenuAnchor.defaultConstraints;

  @override
  Offset get alignmentOffset => Offset.zero;

  @override
  StreamContextMenuActionStyle get actionStyle {
    return StreamContextMenuActionStyle(
      textStyle: WidgetStatePropertyAll(context.streamTextTheme.captionEmphasis),
      iconSize: const WidgetStatePropertyAll(16),
      minimumSize: const WidgetStatePropertyAll(Size(200, 32)),
      padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: context.streamSpacing.xs)),
      shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: .all(context.streamRadius.md))),
    );
  }
}
