import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_adaptive_menu_anchor_theme.dart';
import '../../theme/components/stream_list_tile_theme.dart';
import '../../theme/components/stream_modal_dialog_theme.dart';
import '../../theme/components/stream_modal_window_theme.dart';
import '../../theme/primitives/stream_spacing.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/stream_theme_extensions.dart';
import '../context_menu/stream_adaptive_menu_anchor.dart';
import '../list/stream_list_tile.dart';
import 'internal/stream_modal_parts.dart';
import 'stream_modal_dialog.dart';

/// A modal window with a sidebar of tabs, showing one tab at a time.
///
/// The sidebar at the start edge lists the tabs, and the rest of the window
/// shows the selected tab under a header with its label and a close button.
///
/// Pass it to [showStreamModalDialog], which supplies the scrim:
///
/// {@tool snippet}
///
/// ```dart
/// showStreamModalDialog<void>(
///   context: context,
///   builder: (context) => StreamModalWindow(
///     tabs: [
///       StreamModalWindowTab(
///         icon: Icon(context.streamIcons.settings),
///         label: const Text('General'),
///         builder: (context) => const GeneralSettings(),
///       ),
///       StreamModalWindowTab(
///         icon: Icon(context.streamIcons.bell),
///         label: const Text('Notifications'),
///         builder: (context) => const NotificationSettings(),
///       ),
///     ],
///   ),
/// );
/// ```
/// {@end-tool}
///
/// The window takes the whole of its `constraints`, so switching tabs never
/// changes its size. The selected tab is drawn in a scroll view.
///
/// The window shares its surface and header with [StreamModalDialog], so
/// [StreamModalDialogTheme] themes those. [StreamModalWindowTheme] themes the
/// sidebar and the content area.
///
/// A [StreamAdaptiveMenuAnchor] in a tab opens its anchored menu on every
/// platform rather than a bottom sheet. Wrap the tab's content in a
/// [StreamAdaptiveMenuAnchorTheme] that sets
/// [StreamAdaptiveMenuAnchorThemeData.useSheet] to change that.
///
/// When the window is narrower than 560, the sidebar shows only the tabs'
/// icons, each with its tab's [StreamModalWindowTab.tooltip].
///
/// See also:
///
///  * [showStreamModalDialog], which shows the window over a scrim.
///  * [StreamModalWindowTheme], for customizing the window's appearance.
///  * [StreamModalDialog], a modal with a single body instead of tabs.
@experimental
class StreamModalWindow extends StatelessWidget {
  /// Creates a modal window.
  StreamModalWindow({
    super.key,
    required List<StreamModalWindowTab> tabs,
    int initialIndex = 0,
    ValueChanged<int>? onTabChanged,
    bool showCloseButton = true,
    VoidCallback? onClose,
    BoxConstraints? constraints,
  }) : assert(tabs.isNotEmpty, 'A modal window needs at least one tab.'),
       assert(
         initialIndex >= 0 && initialIndex < tabs.length,
         'initialIndex must be the index of one of the tabs.',
       ),
       props = .new(
         tabs: tabs,
         initialIndex: initialIndex,
         onTabChanged: onTabChanged,
         showCloseButton: showCloseButton,
         onClose: onClose,
         constraints: constraints,
       );

  /// The properties that configure this modal window.
  final StreamModalWindowProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).modalWindow;
    if (builder != null) return builder(context, props);
    return DefaultStreamModalWindow(props: props);
  }
}

/// One tab of a [StreamModalWindow].
@experimental
@immutable
class StreamModalWindowTab {
  /// Creates a tab.
  const StreamModalWindowTab({
    required this.icon,
    required this.label,
    required this.builder,
    this.tooltip,
  });

  /// The icon drawn before [label] in the sidebar.
  ///
  /// A collapsed sidebar shows only the icon.
  final Widget icon;

  /// The tab's name: drawn in the sidebar and as the title of the header.
  ///
  /// Typically a [Text].
  final Widget label;

  /// The tooltip a collapsed sidebar shows on the tab's icon.
  ///
  /// Defaults to the text of [label] when it is a [Text]. Without either, the
  /// icon has no tooltip.
  final String? tooltip;

  /// Builds the tab's content.
  ///
  /// Runs inside the window, and only while the tab is selected: selecting
  /// the tab again builds it again. The content is placed in a scroll view,
  /// so it should size itself to what it shows.
  final WidgetBuilder builder;
}

/// Properties for configuring a [StreamModalWindow].
///
/// This class holds all the configuration options for a modal window,
/// allowing them to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamModalWindow], which uses these properties.
///  * [DefaultStreamModalWindow], the default implementation.
@experimental
class StreamModalWindowProps {
  /// Creates properties for a modal window.
  const StreamModalWindowProps({
    required this.tabs,
    this.initialIndex = 0,
    this.onTabChanged,
    this.showCloseButton = true,
    this.onClose,
    this.constraints,
  });

  /// The tabs, in the order the sidebar lists them.
  ///
  /// Must not be empty.
  final List<StreamModalWindowTab> tabs;

  /// The index of the tab selected when the window opens.
  ///
  /// Must be the index of one of the [tabs].
  final int initialIndex;

  /// Called with the tab's index when the user selects a different tab.
  final ValueChanged<int>? onTabChanged;

  /// Whether the header draws a close button.
  final bool showCloseButton;

  /// Called when the close button is pressed.
  ///
  /// Defaults to popping the window with no value.
  final VoidCallback? onClose;

  /// The bounds of the window.
  ///
  /// The window fills them. Defaults to
  /// [StreamModalDialogThemeData.constraints], and then to
  /// [StreamModalDialog.defaultConstraints].
  final BoxConstraints? constraints;
}

/// The default implementation of [StreamModalWindow].
///
/// See also:
///
///  * [StreamModalWindow], the public API widget.
///  * [StreamModalWindowProps], which configures this widget.
@experimental
class DefaultStreamModalWindow extends StatefulWidget {
  /// Creates a default modal window with the given [props].
  const DefaultStreamModalWindow({super.key, required this.props});

  /// The properties that configure this modal window.
  final StreamModalWindowProps props;

  @override
  State<DefaultStreamModalWindow> createState() => _DefaultStreamModalWindowState();
}

// Below this window width, the sidebar shows only the tabs' icons.
const double _collapseBelowWidth = 560;

class _DefaultStreamModalWindowState extends State<DefaultStreamModalWindow> {
  late int _selectedIndex = _clamp(widget.props.initialIndex);

  int _clamp(int index) => index.clamp(0, widget.props.tabs.length - 1);

  @override
  void didUpdateWidget(DefaultStreamModalWindow oldWidget) {
    super.didUpdateWidget(oldWidget);
    _selectedIndex = _clamp(_selectedIndex);
  }

  void _select(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    widget.props.onTabChanged?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    final props = widget.props;
    final style = context.streamModalWindowTheme.style;
    final defaults = _StreamModalWindowStyleDefaults(context);
    final tab = props.tabs[_selectedIndex];

    // The window's own color wins over the modal dialog theme's, which wins
    // over the default.
    final backgroundColor = style?.backgroundColor ?? resolveStreamModalDialogTheme(context).backgroundColor!;

    return StreamModalSurface(
      constraints: props.constraints,
      backgroundColor: backgroundColor,
      child: SizedBox.expand(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final collapsed = constraints.maxWidth < _collapseBelowWidth;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Sidebar(
                  tabs: props.tabs,
                  selectedIndex: _selectedIndex,
                  collapsed: collapsed,
                  backgroundColor: style?.sidebarBackgroundColor ?? backgroundColor,
                  style: style,
                  defaults: defaults,
                  onSelected: _select,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      StreamModalHeader(
                        title: tab.label,
                        actions: [
                          if (props.showCloseButton) StreamModalCloseButton(onPressed: props.onClose),
                        ],
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          // A new tab starts at its top.
                          key: ValueKey(_selectedIndex),
                          padding: style?.contentPadding ?? defaults.contentPadding,
                          child: StreamAdaptiveMenuAnchorTheme(
                            data: StreamAdaptiveMenuAnchorTheme.of(context).merge(
                              const StreamAdaptiveMenuAnchorThemeData(useSheet: false),
                            ),
                            child: Builder(builder: tab.builder),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.tabs,
    required this.selectedIndex,
    required this.collapsed,
    required this.backgroundColor,
    required this.style,
    required this.defaults,
    required this.onSelected,
  });

  final List<StreamModalWindowTab> tabs;
  final int selectedIndex;
  final bool collapsed;
  final Color backgroundColor;
  final StreamModalWindowStyle? style;
  final _StreamModalWindowStyleDefaults defaults;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      // In front, so the Material below doesn't paint over it.
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        border: BorderDirectional(
          end: BorderSide(color: style?.sidebarBorderColor ?? defaults.sidebarBorderColor),
        ),
      ),
      // A Material rather than a colored box: the rows draw their selected
      // fill as ink, which paints on the nearest Material and would be
      // covered by a box painted above it.
      child: Material(
        color: backgroundColor,
        child: SizedBox(
          width: collapsed ? null : style?.sidebarWidth ?? defaults.sidebarWidth,
          child: StreamListTileTheme(
            data: defaults.navItemStyle.merge(style?.navItemStyle),
            child: FocusTraversalGroup(
              child: SingleChildScrollView(
                padding: style?.sidebarPadding ?? defaults.sidebarPadding,
                child: Column(
                  crossAxisAlignment: collapsed ? CrossAxisAlignment.center : CrossAxisAlignment.stretch,
                  children: [
                    for (final (index, tab) in tabs.indexed)
                      _NavItem(
                        tab: tab,
                        selected: index == selectedIndex,
                        collapsed: collapsed,
                        minHeight: style?.navItemMinHeight ?? defaults.navItemMinHeight,
                        iconSize: style?.navItemIconSize ?? defaults.navItemIconSize,
                        spacing: style?.navItemSpacing ?? defaults.navItemSpacing,
                        onTap: () => onSelected(index),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.selected,
    required this.collapsed,
    required this.minHeight,
    required this.iconSize,
    required this.spacing,
    required this.onTap,
  });

  final StreamModalWindowTab tab;
  final bool selected;
  final bool collapsed;
  final double minHeight;
  final double iconSize;
  final double spacing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final listTileTheme = context.streamListTileTheme;

    final states = {if (selected) WidgetState.selected};
    final iconColor = listTileTheme.iconColor?.resolve(states) ?? colorScheme.textSecondary;
    final labelColor = listTileTheme.titleColor?.resolve(states) ?? colorScheme.textPrimary;
    final labelStyle = listTileTheme.titleTextStyle ?? context.streamTextTheme.bodyDefault;

    final icon = IconTheme.merge(
      data: IconThemeData(size: iconSize, color: iconColor),
      child: tab.icon,
    );

    Widget item = StreamListTileContainer(
      selected: selected,
      onTap: onTap,
      child: collapsed
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                // Not drawn, but still read out, so the row keeps its name.
                SizedBox.shrink(
                  child: Visibility.maintain(visible: false, child: tab.label),
                ),
              ],
            )
          : Row(
              spacing: spacing,
              children: [
                icon,
                Expanded(
                  child: DefaultTextStyle.merge(
                    style: labelStyle.copyWith(color: labelColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    child: tab.label,
                  ),
                ),
              ],
            ),
    );

    final tooltip = switch (tab) {
      StreamModalWindowTab(:final tooltip?) => tooltip,
      StreamModalWindowTab(label: Text(:final data?)) => data,
      _ => null,
    };
    if (collapsed && tooltip != null) {
      item = Tooltip(
        message: tooltip,
        // The hidden label above already names the row.
        excludeFromSemantics: true,
        child: item,
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Align(widthFactor: collapsed ? 1 : null, child: item),
    );
  }
}

// Default theme values for [StreamModalWindow].
//
// The surface color is not here: it falls back to the modal dialog theme, so
// the window and the dialog share one surface.
class _StreamModalWindowStyleDefaults extends StreamModalWindowStyle {
  _StreamModalWindowStyleDefaults(this._context);

  final BuildContext _context;

  late final StreamColorScheme _colorScheme = _context.streamColorScheme;
  late final StreamSpacing _spacing = _context.streamSpacing;

  @override
  double get sidebarWidth => 200;

  @override
  Color get sidebarBorderColor => _colorScheme.borderSubtle;

  @override
  EdgeInsetsGeometry get sidebarPadding => EdgeInsets.symmetric(
    horizontal: _spacing.xs,
    vertical: _spacing.xxs + _spacing.xxxs,
  );

  @override
  StreamListTileThemeData get navItemStyle => StreamListTileThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(_context.streamRadius.md)),
    contentPadding: EdgeInsets.symmetric(horizontal: _spacing.sm, vertical: _spacing.xs),
  );

  @override
  double get navItemMinHeight => 40;

  @override
  double get navItemIconSize => 16;

  @override
  double get navItemSpacing => _spacing.sm;

  @override
  EdgeInsetsGeometry get contentPadding => EdgeInsetsDirectional.only(
    start: _spacing.xl,
    end: _spacing.xl,
    bottom: _spacing.xxl,
  );
}
