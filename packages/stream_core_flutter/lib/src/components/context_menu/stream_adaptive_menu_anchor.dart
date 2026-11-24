import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_adaptive_menu_anchor_theme.dart';
import '../../theme/components/stream_context_menu_action_theme.dart';
import '../../theme/components/stream_context_menu_heading_theme.dart';
import '../../theme/components/stream_list_tile_theme.dart';
import '../../theme/components/stream_radio_button_theme.dart';
import '../../theme/stream_theme_extensions.dart';
import '../controls/stream_radio_button.dart';
import '../list/stream_list_tile.dart';
import '../sheet/stream_sheet.dart';
import '../toolbar/stream_sheet_header.dart';
import 'stream_context_menu.dart';
import 'stream_context_menu_action.dart';
import 'stream_context_menu_anchor.dart';
import 'stream_context_menu_heading.dart';

/// Which way a menu is expected to open from its anchor.
///
/// The anchored menu flips itself when there is no room, so this is about what
/// the anchor should *say* — which way its caret points — rather than where the
/// menu ends up. A toolbar along the bottom of the screen opens upwards; a
/// field in a form opens down.
enum StreamMenuDirection {
  /// Below the anchor. The default, and what a field in a form does.
  down,

  /// Above the anchor, as a toolbar along the bottom of the screen does.
  up,
}

/// One row inside a [StreamMenuSection].
///
/// A row is a choice when [selected] is set and pickable when [onSelected] is:
/// a device menu sets both, a list that only shows something — the members of
/// a group, say — sets neither.
@immutable
@experimental
class StreamMenuOption {
  /// Creates a menu option.
  const StreamMenuOption({
    required this.label,
    this.leading,
    this.trailing,
    this.selected,
    this.onSelected,
    this.closesMenu = true,
  });

  /// The text of the row.
  final String label;

  /// Drawn before the label.
  ///
  /// If null, defaults to a decorative [StreamRadioButton] when [selected] is set, and
  /// to nothing otherwise.
  final Widget? leading;

  /// Drawn after the label, at the far end of the row.
  ///
  /// The value a row reports rather than a second control — the `On` beside a
  /// toggle, the resolution beside a quality picker.
  final Widget? trailing;

  /// Whether this is the option currently in effect.
  ///
  /// Null where the section is not a choice, which also drops the radio
  /// indicator the rows would otherwise carry.
  final bool? selected;

  /// Called when the user picks this option.
  ///
  /// The menu closes itself first unless [closesMenu] says otherwise, so this
  /// does not have to. If null, the row is something to read rather than
  /// something to press.
  final VoidCallback? onSelected;

  /// Whether picking this option dismisses the menu.
  ///
  /// True for a choice, which is answered once the choice is made. False for a
  /// row that reports state the menu is showing — a toggle whose `On` the user
  /// has just pressed for, and should see change.
  final bool closesMenu;
}

/// Builds the body of a [StreamMenuSection] that is not a list of rows.
///
/// Handed the menu's handle so the content can dismiss the menu on its own: a
/// strip of reactions closes once one is sent, a strip of filters stays open
/// so several can be tried.
typedef StreamMenuContentBuilder = Widget Function(BuildContext context, StreamMenuHandle handle);

/// A group of [StreamMenuOption]s, optionally under a [heading].
///
/// A section normally draws [options] as rows. Give it [content] instead where
/// the group is not a list at all — a row of emoji, a strip of backgrounds —
/// and it draws that in their place.
@immutable
@experimental
class StreamMenuSection {
  /// Creates a menu section.
  const StreamMenuSection({
    this.options = const [],
    this.heading,
    this.content,
    this.collapsible = false,
    this.initiallyCollapsed = true,
  });

  /// The label above the group, such as "Microphone".
  ///
  /// If null, no heading is drawn, which is what a menu of one unlabelled
  /// group wants.
  final String? heading;

  /// The rows in the group.
  final List<StreamMenuOption> options;

  /// Drawn in place of [options], for a group that is not a list of rows.
  ///
  /// It is laid out outside the menu's row widget, so it is not held to the
  /// row metrics and sizes itself.
  final StreamMenuContentBuilder? content;

  /// Whether the [heading] folds the section away.
  ///
  /// For the long tail of a menu — a list of devices, a set of resolutions —
  /// which would otherwise push everything after it out of reach. Ignored
  /// without a [heading], since there would be nothing to press.
  final bool collapsible;

  /// Whether a [collapsible] section starts folded away.
  final bool initiallyCollapsed;

  /// Whether this section would draw nothing.
  bool get isEmpty => content == null && options.isEmpty;
}

/// Whether a menu built from these sections has anything to offer.
///
/// A caret or a field with nothing to open is disabled rather than opening an
/// empty popup, so every caller needs this.
extension StreamMenuSectionsX on Iterable<StreamMenuSection> {
  /// True when no section has a row or any content in it.
  bool get hasNoOptions => every((section) => section.isEmpty);
}

/// Opens and closes the menu a [StreamAdaptiveMenuAnchor] hosts.
///
/// Handed to the anchor's builder so the same builder drives both
/// presentations without knowing which one it got.
abstract interface class StreamMenuHandle {
  /// Whether the menu is currently showing.
  bool get isOpen;

  /// Shows the menu.
  void open();

  /// Hides the menu.
  void close();

  /// Shows the menu if it is hidden, hides it if it is showing.
  void toggle();
}

/// Builds the widget a [StreamAdaptiveMenuAnchor] hangs its menu off.
typedef StreamAdaptiveMenuAnchorBuilder = Widget Function(BuildContext context, StreamMenuHandle handle);

/// Presents [StreamMenuSection]s as an anchored context menu on desktop and
/// web, and as a bottom sheet on Android and iOS.
///
/// A popup pinned to a 32px caret is awkward to hit with a thumb and out of
/// place next to the rest of a phone's chrome, so the presentation follows the
/// platform rather than the call site: nothing that uses this has to branch.
///
/// The anchored menu is a [StreamContextMenuAnchor] of
/// [StreamContextMenuAction]s under [StreamContextMenuHeading]s; the sheet is
/// a [showStreamSheet] of [StreamListTile]s under the same headings.
///
/// {@tool snippet}
///
/// A caret that opens a microphone picker:
///
/// ```dart
/// StreamAdaptiveMenuAnchor(
///   title: 'Microphone',
///   sections: [
///     StreamMenuSection(
///       heading: 'Microphone',
///       options: [
///         for (final device in devices)
///           StreamMenuOption(
///             label: device.label,
///             selected: device == selected,
///             onSelected: () => select(device),
///           ),
///       ],
///     ),
///   ],
///   builder: (context, handle) => StreamButton.icon(
///     icon: Icon(context.streamIcons.chevronDown),
///     onPressed: handle.toggle,
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamAdaptiveMenuAnchorTheme], for customizing the menus.
///  * [StreamContextMenuAnchor], the anchored presentation on its own.
///  * [showStreamSheet], the sheet presentation on its own.
@experimental
class StreamAdaptiveMenuAnchor extends StatelessWidget {
  /// Creates an adaptive menu anchor.
  StreamAdaptiveMenuAnchor({
    super.key,
    required List<StreamMenuSection> sections,
    required StreamAdaptiveMenuAnchorBuilder builder,
    String? title,
    bool? useSheet,
    bool matchAnchorWidth = false,
    StreamContextMenuActionStyle? menuItemStyle,
    double? menuElevation,
    StreamMenuDirection direction = StreamMenuDirection.down,
    Offset? alignmentOffset,
  }) : props = .new(
         sections: sections,
         builder: builder,
         title: title,
         useSheet: useSheet,
         matchAnchorWidth: matchAnchorWidth,
         menuItemStyle: menuItemStyle,
         menuElevation: menuElevation,
         direction: direction,
         alignmentOffset: alignmentOffset,
       );

  /// The properties that configure this adaptive menu anchor.
  final StreamAdaptiveMenuAnchorProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).adaptiveMenuAnchor;
    if (builder != null) return builder(context, props);
    return DefaultStreamAdaptiveMenuAnchor(props: props);
  }
}

/// Properties for configuring a [StreamAdaptiveMenuAnchor].
///
/// This class holds all the configuration options for an adaptive menu
/// anchor, allowing them to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamAdaptiveMenuAnchor], which uses these properties.
///  * [DefaultStreamAdaptiveMenuAnchor], the default implementation.
@immutable
@experimental
class StreamAdaptiveMenuAnchorProps {
  /// Creates properties for an adaptive menu anchor.
  const StreamAdaptiveMenuAnchorProps({
    required this.sections,
    required this.builder,
    this.title,
    this.useSheet,
    this.matchAnchorWidth = false,
    this.menuItemStyle,
    this.menuElevation,
    this.direction = StreamMenuDirection.down,
    this.alignmentOffset,
  });

  /// The groups of choices the menu offers.
  final List<StreamMenuSection> sections;

  /// Builds the widget the menu is anchored to.
  final StreamAdaptiveMenuAnchorBuilder builder;

  /// The sheet header's title.
  ///
  /// Only the sheet presentation shows it; the anchored menu relies on its
  /// section headings instead.
  final String? title;

  /// Forces one presentation instead of following the platform.
  ///
  /// If null, resolves from [StreamAdaptiveMenuAnchorThemeData.useSheet], then
  /// falls back to the sheet on Android and iOS and the anchored menu
  /// everywhere else. The platform is read from [ThemeData.platform], so an
  /// app emulating another platform gets that platform's presentation.
  final bool? useSheet;

  /// Whether the anchored menu should be exactly as wide as its anchor.
  ///
  /// Off by default, because a menu is normally as wide as its content: a
  /// popup hanging off a 32px caret should not be 32px wide. Turn it on where
  /// the anchor is a full-width field and a narrower menu would look detached
  /// from it.
  ///
  /// Only has an effect when the anchor is given a bounded width, and nothing
  /// to do with the sheet presentation, which is always full width.
  final bool matchAnchorWidth;

  /// Overrides for the anchored menu's rows.
  ///
  /// The design's menu row is sized for a 16px icon beside a caption; a menu
  /// whose rows carry something bigger needs a taller one. The sheet's rows
  /// are [StreamListTile]s and are already sized for it, so this does not
  /// apply to them. The section headings follow the rows' minimum size and
  /// padding.
  ///
  /// Merged over [StreamAdaptiveMenuAnchorStyle.menuItemStyle], so a value set
  /// here wins.
  final StreamContextMenuActionStyle? menuItemStyle;

  /// How high the anchored menu floats above the page.
  ///
  /// If null, resolves from the [StreamContextMenu] theme. Pass 0 for a menu
  /// separated from the page by its border alone. The sheet presentation has
  /// its own surface and ignores this.
  final double? menuElevation;

  /// Which way the menu is expected to open.
  ///
  /// Sets which side of the anchor the menu clears by default, and is what an
  /// anchor asks to point its caret the right way. The sheet presentation
  /// always comes up from the bottom and ignores it.
  final StreamMenuDirection direction;

  /// The offset of the anchored menu relative to its anchor.
  ///
  /// If null, the menu clears the anchor by
  /// [StreamAdaptiveMenuAnchorStyle.menuGap] on whichever side [direction]
  /// names. Ignored by the sheet presentation.
  final Offset? alignmentOffset;
}

/// The default implementation of [StreamAdaptiveMenuAnchor].
///
/// See also:
///
///  * [StreamAdaptiveMenuAnchor], the public API widget.
///  * [StreamAdaptiveMenuAnchorProps], which configures this widget.
@experimental
class DefaultStreamAdaptiveMenuAnchor extends StatefulWidget {
  /// Creates a default adaptive menu anchor with the given [props].
  const DefaultStreamAdaptiveMenuAnchor({super.key, required this.props});

  /// The properties that configure this adaptive menu anchor.
  final StreamAdaptiveMenuAnchorProps props;

  @override
  State<DefaultStreamAdaptiveMenuAnchor> createState() => _DefaultStreamAdaptiveMenuAnchorState();
}

class _DefaultStreamAdaptiveMenuAnchorState extends State<DefaultStreamAdaptiveMenuAnchor> implements StreamMenuHandle {
  StreamAdaptiveMenuAnchorProps get _props => widget.props;

  final _menuController = MenuController();
  var _isOpen = false;

  // What the user has folded and unfolded by hand, by heading.
  //
  // Only their choices: a section they have not touched falls back to its own
  // [StreamMenuSection.initiallyCollapsed] on every build. Holding it this way
  // keeps [_isCollapsed] a pure read — nothing is registered while building —
  // so the fold cannot come out differently because the sections were built a
  // different number of times, or in a different order.
  //
  // Keyed by heading rather than by section, because the sections are rebuilt
  // from scratch whenever the anchor's parent rebuilds — which a menu holding
  // live state does constantly — and the fold has to survive that.
  final _toggled = <String, bool>{};

  // Bumped whenever what the menu draws changes.
  //
  // The sheet presentation is a route, built once, so it has to be told to
  // rebuild — both for a fold and for a row whose value moved under it.
  final _revision = ValueNotifier(0);

  @override
  void didUpdateWidget(DefaultStreamAdaptiveMenuAnchor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (identical(oldWidget.props.sections, _props.sections)) return;

    // After the frame, not now: an open sheet is a route elsewhere in the
    // tree, and notifying it mid-build rebuilds a subtree that has already
    // been built. It only listens while it is up, so this costs nothing when
    // it is not.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _revision.value++;
    });
  }

  @override
  void dispose() {
    _revision.dispose();
    super.dispose();
  }

  // Whether [section] is folded away: what the user last chose for it, or its
  // own default until they choose.
  bool _isCollapsed(StreamMenuSection section) {
    final heading = section.heading;
    if (!section.collapsible || heading == null) return false;

    return _toggled[heading] ?? section.initiallyCollapsed;
  }

  void _toggleCollapsed(StreamMenuSection section) {
    final heading = section.heading;
    if (heading == null) return;

    final collapsed = _isCollapsed(section);
    setState(() => _toggled[heading] = !collapsed);
    _revision.value++;
  }

  @override
  bool get isOpen => _isOpen;

  @override
  void toggle() => _isOpen ? close() : open();

  @override
  void open() {
    // Guarded like [close]: the sheet branch opens by pushing a route, and a
    // second push would stack a sheet that the handle can no longer reach —
    // the first one to be popped clears [isOpen] for both.
    if (_isOpen || !mounted) return;

    if (_useSheet) {
      unawaited(_openSheet());
    } else {
      _menuController.open();
    }
  }

  @override
  void close() {
    // Guarded because the sheet branch closes by popping a route: called while
    // nothing is open it would pop whatever screen the anchor sits on.
    if (!_isOpen || !mounted) return;

    if (_useSheet) {
      Navigator.of(context).pop();
    } else {
      _menuController.close();
    }
  }

  // Whether this build should present a sheet.
  //
  // Read off the ambient theme rather than off a platform detector, so that a
  // test — and an app deliberately emulating another platform — gets the
  // presentation it asked for. It also does the right thing for a mobile
  // browser, which reports a mobile target platform.
  bool get _useSheet =>
      _props.useSheet ??
      context.streamAdaptiveMenuAnchorTheme.useSheet ??
      switch (Theme.of(context).platform) {
        TargetPlatform.android || TargetPlatform.iOS => true,
        _ => false,
      };

  void _select(StreamMenuOption option) {
    if (option.closesMenu) close();
    option.onSelected?.call();
  }

  Future<void> _openSheet() async {
    setState(() => _isOpen = true);
    // On a folded window, the sheet goes to the half the anchor is in.
    final box = context.findRenderObject() as RenderBox?;
    await showStreamSheet<void>(
      context: context,
      isDismissible: true,
      anchorPoint: box?.localToGlobal(box.size.center(Offset.zero)),
      builder: (context, scrollController) => ListenableBuilder(
        listenable: _revision,
        builder: (context, _) => _MenuSheet(
          title: _props.title,
          sections: _props.sections,
          scrollController: scrollController,
          handle: this,
          isCollapsed: _isCollapsed,
          onToggleCollapsed: _toggleCollapsed,
          onSelected: _select,
        ),
      ),
    );
    if (mounted) setState(() => _isOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_useSheet) return _props.builder(context, this);
    if (!_props.matchAnchorWidth) return _anchored(context);

    // The anchor's own incoming constraints are the field's width. Measured
    // here rather than inside the MenuAnchor's builder because the panel's
    // constraints are a property of the anchor widget, fixed before that
    // builder runs.
    return LayoutBuilder(
      builder: (context, constraints) => _anchored(
        context,
        width: constraints.hasBoundedWidth ? constraints.maxWidth : null,
      ),
    );
  }

  Widget _anchored(BuildContext context, {double? width}) {
    final style = context.streamAdaptiveMenuAnchorTheme.style;
    final defaults = _StreamAdaptiveMenuAnchorStyleDefaults(context);

    final effectiveMenuItemStyle = style?.menuItemStyle?.merge(_props.menuItemStyle) ?? _props.menuItemStyle;
    final effectiveSelectedItemColor = style?.menuSelectedItemColor ?? defaults.menuSelectedItemColor;
    final effectiveMenuGap = style?.menuGap ?? defaults.menuGap;

    // What every row of the menu resolves to: the anchor's own row style with
    // this menu's overrides on top.
    final rowStyle = StreamContextMenuAnchor.defaultActionStyle(context).merge(effectiveMenuItemStyle);

    // The headings line up with the rows: the same minimum size, padding,
    // highlight shape and icon size.
    final headingTheme = context.streamContextMenuHeadingTheme
        .merge(
          StreamContextMenuHeadingThemeData(
            minimumSize: rowStyle.minimumSize?.resolve(const {}),
            padding: rowStyle.padding?.resolve(const {}),
            shape: rowStyle.shape?.resolve(const {}),
            iconSize: rowStyle.iconSize?.resolve(const {}),
          ),
        )
        .merge(style?.menuHeadingStyle);

    // [StreamContextMenuActionTheme.of] reads the nearest theme only, so the
    // selected row's fill is layered over the full row style rather than set
    // on its own, which would drop the design's row metrics and leave the
    // selected row taller and wider than its siblings.
    final selectedRowStyle = rowStyle.merge(
      StreamContextMenuActionStyle(backgroundColor: WidgetStatePropertyAll(effectiveSelectedItemColor)),
    );

    return StreamContextMenuAnchor(
      controller: _menuController,
      alignmentOffset:
          _props.alignmentOffset ??
          switch (_props.direction) {
            StreamMenuDirection.down => Offset(0, effectiveMenuGap),
            StreamMenuDirection.up => Offset(0, -effectiveMenuGap),
          },
      actionStyle: effectiveMenuItemStyle,
      elevation: _props.menuElevation,
      // StreamContextMenu is an IntrinsicWidth, so a tight width overrides
      // what its content would otherwise ask for — including the minimum
      // width a menu row carries, which would otherwise overflow a field
      // narrower than that.
      constraints: switch (width) {
        final width? =>
          (context.streamContextMenuAnchorTheme.constraints ?? StreamContextMenuAnchor.defaultConstraints).copyWith(
            minWidth: width,
            maxWidth: width,
          ),
        null => null,
      },
      onOpen: () => setState(() => _isOpen = true),
      onClose: () {
        if (mounted) setState(() => _isOpen = false);
      },
      menuChildren: StreamContextMenuAction.sectioned(
        sections: [
          for (final section in _props.sections)
            [
              // A heading with nothing under it would label nothing.
              if (!section.isEmpty)
                if (section.heading case final heading?)
                  StreamContextMenuHeadingTheme(
                    data: headingTheme,
                    child: _sectionHeading(
                      context,
                      label: heading,
                      collapsible: section.collapsible,
                      collapsed: _isCollapsed(section),
                      onToggle: () => _toggleCollapsed(section),
                    ),
                  ),
              // Outside StreamContextMenuAction, so the content sizes itself
              // rather than being held to the design's row.
              if (!_isCollapsed(section))
                if (section.content case final content?) content(context, this),
              if (!_isCollapsed(section))
                for (final option in section.options)
                  if (option.selected ?? false)
                    StreamContextMenuActionTheme(
                      data: StreamContextMenuActionThemeData(style: selectedRowStyle),
                      child: _anchoredOption(option),
                    )
                  else
                    _anchoredOption(option),
            ],
        ],
      ),
      builder: (context, _, _) => _props.builder(context, this),
    );
  }

  // One row of the anchored menu.
  //
  // The row for the option in effect is filled, as the sheet's
  // [StreamListTile] fills its own selected row: [StreamContextMenuAction] has
  // no selected state, and the radio indicator that would otherwise mark the
  // choice is suppressed by an explicit [StreamMenuOption.leading].
  Widget _anchoredOption(StreamMenuOption option) {
    final onSelected = option.onSelected;

    // The radio button is decorative, so the row announces the choice itself,
    // as the sheet's [StreamListTile] does through its selected state.
    return MergeSemantics(
      child: Semantics(
        selected: option.selected,
        child: _anchoredAction(option, onSelected),
      ),
    );
  }

  Widget _anchoredAction(StreamMenuOption option, VoidCallback? onSelected) {
    return StreamContextMenuAction<void>(
      // A row with nothing to press leaves the menu up.
      closeOnActivate: onSelected != null && option.closesMenu,
      onTap: onSelected == null ? null : () => _select(option),
      // Deliberately left enabled for a row with nothing to press.
      // `enabled: false` is the design system's *unavailable* look — it paints
      // the label in `textDisabled` — and a list that only shows something,
      // like the members of a group, would render every name as though that
      // person were unavailable.
      leading: _leadingOf(option),
      trailing: option.trailing,
      label: Text(option.label, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }
}

// What a row draws before its label: whatever it was given, or the radio
// button a choice implies.
Widget? _leadingOf(StreamMenuOption option) {
  if (option.leading case final leading?) return leading;
  if (option.selected case final selected?) {
    return StreamRadioButton.decorative(selected: selected, size: StreamRadioButtonSize.sm);
  }
  return null;
}

// A section's heading, carrying a chevron and a press when the section folds
// away.
Widget _sectionHeading(
  BuildContext context, {
  required String label,
  required bool collapsible,
  required bool collapsed,
  required VoidCallback onToggle,
}) {
  if (!collapsible) return StreamContextMenuHeading(label: Text(label));

  final icons = context.streamIcons;

  return StreamContextMenuHeading(
    label: Text(label),
    trailing: Icon(collapsed ? icons.chevronDown : icons.chevronUp),
    expanded: !collapsed,
    onTap: onToggle,
  );
}

// The sheet presentation of a [StreamAdaptiveMenuAnchor].
class _MenuSheet extends StatelessWidget {
  const _MenuSheet({
    required this.title,
    required this.sections,
    required this.scrollController,
    required this.handle,
    required this.isCollapsed,
    required this.onToggleCollapsed,
    required this.onSelected,
  });

  final String? title;
  final List<StreamMenuSection> sections;
  final ScrollController scrollController;
  final StreamMenuHandle handle;
  final bool Function(StreamMenuSection) isCollapsed;
  final ValueChanged<StreamMenuSection> onToggleCollapsed;
  final ValueChanged<StreamMenuOption> onSelected;

  @override
  Widget build(BuildContext context) {
    final title = this.title;
    final style = context.streamAdaptiveMenuAnchorTheme.style;
    final defaults = _StreamAdaptiveMenuAnchorStyleDefaults(context);

    // The tile padding is set here rather than left to the app's list tile
    // theme, which sizes list tiles in general.
    final tileTheme = defaults.sheetTileStyle.merge(style?.sheetTileStyle);
    final effectivePadding = style?.sheetPadding ?? defaults.sheetPadding;

    // A heading is inset by as much as the list tiles under it, so the two
    // line up.
    final tilePadding = tileTheme.contentPadding?.resolve(Directionality.of(context));
    final headingTheme = context.streamContextMenuHeadingTheme
        .merge(
          StreamContextMenuHeadingThemeData(
            padding: switch (tilePadding) {
              final padding? => EdgeInsets.only(left: padding.left, right: padding.right),
              null => null,
            },
          ),
        )
        .merge(style?.sheetHeadingStyle);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null) StreamSheetHeader(title: Text(title)),
        Flexible(
          child: StreamListTileTheme(
            data: tileTheme,
            child: StreamContextMenuHeadingTheme(
              data: headingTheme,
              child: ListView(
                // The sheet hands this down so that dragging the list past its
                // top drags the sheet instead of overscrolling.
                controller: scrollController,
                shrinkWrap: true,
                children: [
                  for (final section in sections) ...[
                    // See the anchored rows: a heading needs something under it.
                    if (!section.isEmpty)
                      if (section.heading case final heading?)
                        Padding(
                          padding: effectivePadding,
                          child: _sectionHeading(
                            context,
                            label: heading,
                            collapsible: section.collapsible,
                            collapsed: isCollapsed(section),
                            onToggle: () => onToggleCollapsed(section),
                          ),
                        ),
                    if (!isCollapsed(section))
                      if (section.content case final content?)
                        Padding(padding: effectivePadding, child: content(context, handle)),
                    if (!isCollapsed(section))
                      for (final option in section.options)
                        Padding(
                          padding: effectivePadding,
                          child: StreamListTile(
                            leading: _leadingOf(option),
                            title: Text(option.label, maxLines: 1, overflow: TextOverflow.ellipsis),
                            trailing: option.trailing,
                            selected: option.selected ?? false,
                            // See the anchored rows: enabled is the look, not
                            // the interactivity. A null onTap already makes the
                            // row inert and gives it a non-interactive cursor.
                            onTap: option.onSelected == null ? null : () => onSelected(option),
                          ),
                        ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Default values for [StreamAdaptiveMenuAnchorStyle], resolved from the
// current color scheme and spacing.
class _StreamAdaptiveMenuAnchorStyleDefaults extends StreamAdaptiveMenuAnchorStyle {
  _StreamAdaptiveMenuAnchorStyleDefaults(this.context);

  final BuildContext context;

  late final _spacing = context.streamSpacing;

  @override
  Color get menuSelectedItemColor => context.streamColorScheme.backgroundSelected;

  @override
  double get menuGap => _spacing.xs;

  // The design's mobile list item is 48 tall: the tile's 40 minimum plus
  // spacing.xxs above and below.
  @override
  StreamListTileThemeData get sheetTileStyle => StreamListTileThemeData(
    contentPadding: EdgeInsets.symmetric(horizontal: _spacing.sm, vertical: _spacing.xxs),
  );

  @override
  EdgeInsetsGeometry get sheetPadding => EdgeInsets.symmetric(horizontal: _spacing.xxs);
}
