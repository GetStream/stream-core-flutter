import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:meta/meta.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_tab_bar_theme.dart';
import '../../theme/primitives/stream_colors.dart';
import '../../theme/primitives/stream_spacing.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/semantics/stream_text_theme.dart';
import '../../theme/stream_theme_extensions.dart';

/// A row of tabs, each taking an equal share of the width, marking the
/// selected one with an accent label over an accent underline.
///
/// Mirrors the `Web / Tab Bar` component from the design.
///
/// The bar carries no controller and no page view: [StreamTabBarProps.selectedIndex]
/// comes from the caller and [StreamTabBarProps.onSelected] reports a tap. A
/// tab switch is a plain state change, which suits a tab bar over
/// already-loaded content — there is nothing to animate between and nothing to
/// reload. For tabs that swipe between pages, consider Material's [TabBar].
///
/// Screen readers announce the bar as a tab bar and each tab as a tab with
/// its selected state. Every tab is a keyboard focus stop.
///
/// {@tool snippet}
///
/// Switch between two views of the same content:
///
/// ```dart
/// StreamTabBar(
///   selectedIndex: selectedIndex,
///   onSelected: (index) => setState(() => selectedIndex = index),
///   tabs: [
///     StreamTabBarItem(label: 'Photos', icon: Icon(context.streamIcons.image)),
///     StreamTabBarItem(label: 'Files', icon: Icon(context.streamIcons.file)),
///   ],
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamTabBarItem], which describes one tab.
///  * [StreamTabBarTheme], for customizing tab bar appearance.
@experimental
class StreamTabBar extends StatelessWidget {
  /// Creates a tab bar.
  ///
  /// [tabs] must not be empty.
  StreamTabBar({
    super.key,
    required List<StreamTabBarItem> tabs,
    required int selectedIndex,
    required ValueChanged<int> onSelected,
  }) : assert(tabs.isNotEmpty, 'A tab bar needs at least one tab.'),
       props = .new(tabs: tabs, selectedIndex: selectedIndex, onSelected: onSelected);

  /// The props controlling the appearance and behavior of this tab bar.
  final StreamTabBarProps props;

  /// The default height of the bar in logical pixels, underline included.
  ///
  /// [StreamTabBarThemeData.height] overrides it. The bar grows past its
  /// height when the text scale needs more room.
  static const height = 48.0;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).tabBar;
    if (builder != null) return builder(context, props);
    return DefaultStreamTabBar(props: props);
  }
}

/// One tab of a [StreamTabBar].
@immutable
@experimental
class StreamTabBarItem {
  /// Creates a tab.
  const StreamTabBarItem({required this.label, this.icon});

  /// The tab's label, which is also what screen readers announce for it.
  final String label;

  /// An icon drawn before [label].
  ///
  /// It takes the tab's foreground color through [IconTheme].
  final Widget? icon;
}

/// Properties for configuring a [StreamTabBar].
///
/// This class holds all the configuration options for a tab bar, allowing
/// them to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamTabBar], which uses these properties.
///  * [DefaultStreamTabBar], the default implementation.
@experimental
class StreamTabBarProps {
  /// Creates properties for a tab bar.
  const StreamTabBarProps({
    required this.tabs,
    required this.selectedIndex,
    required this.onSelected,
  });

  /// The tabs to draw, in order.
  final List<StreamTabBarItem> tabs;

  /// The index into [tabs] of the selected tab.
  ///
  /// An index outside [tabs] leaves every tab unselected.
  final int selectedIndex;

  /// Called with the index of the tapped tab.
  ///
  /// Also called for the tab that is already selected.
  final ValueChanged<int> onSelected;
}

/// The default implementation of [StreamTabBar].
///
/// It's used as the default factory implementation in
/// [StreamComponentFactory]. A replacement should keep the tab bar and tab
/// semantics roles and the selected state on each tab, so screen readers
/// still announce which tab is active.
///
/// See also:
///
///  * [StreamTabBar], the public API widget.
///  * [StreamTabBarProps], which configures this widget.
@experimental
class DefaultStreamTabBar extends StatelessWidget {
  /// Creates a default tab bar with the given [props].
  const DefaultStreamTabBar({super.key, required this.props});

  /// The properties that configure this tab bar.
  final StreamTabBarProps props;

  @override
  Widget build(BuildContext context) {
    final theme = context.streamTabBarTheme;
    final defaults = _StreamTabBarThemeDefaults(context);

    final style = _StreamTabStyle(
      indicatorWeight: theme.indicatorWeight ?? defaults.indicatorWeight,
      indicatorColor: theme.indicatorColor ?? defaults.indicatorColor,
      labelStyle: theme.labelStyle ?? defaults.labelStyle,
      foregroundColor: theme.foregroundColor ?? defaults.foregroundColor,
      overlayColor: theme.overlayColor ?? defaults.overlayColor,
      tabPadding: theme.tabPadding ?? defaults.tabPadding,
      spacing: theme.spacing ?? defaults.spacing,
    );

    final tabCount = props.tabs.length;

    return Semantics(
      role: SemanticsRole.tabBar,
      container: true,
      explicitChildNodes: true,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: theme.height ?? defaults.height),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: .stretch,
            children: [
              for (final (index, tab) in props.tabs.indexed)
                Expanded(
                  child: _StreamTab(
                    item: tab,
                    index: index,
                    tabCount: tabCount,
                    selected: index == props.selectedIndex,
                    style: style,
                    onPressed: () => props.onSelected(index),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// The resolved visual values every tab of one bar shares.
class _StreamTabStyle {
  const _StreamTabStyle({
    required this.indicatorWeight,
    required this.indicatorColor,
    required this.labelStyle,
    required this.foregroundColor,
    required this.overlayColor,
    required this.tabPadding,
    required this.spacing,
  });

  final double indicatorWeight;
  final WidgetStateProperty<Color?> indicatorColor;
  final TextStyle labelStyle;
  final WidgetStateProperty<Color?> foregroundColor;
  final WidgetStateProperty<Color?> overlayColor;
  final EdgeInsetsGeometry tabPadding;
  final double spacing;
}

class _StreamTab extends StatelessWidget {
  const _StreamTab({
    required this.item,
    required this.index,
    required this.tabCount,
    required this.selected,
    required this.style,
    required this.onPressed,
  });

  final StreamTabBarItem item;
  final int index;
  final int tabCount;
  final bool selected;
  final _StreamTabStyle style;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final states = <WidgetState>{if (selected) WidgetState.selected};
    final foregroundColor = style.foregroundColor.resolve(states);
    final indicatorColor = style.indicatorColor.resolve(states) ?? StreamColors.transparent;

    // The position is spelled out for native screen readers, which do not
    // announce it from the tab role alone. The web maps the role to ARIA,
    // which carries the position itself.
    final positionLabel = kIsWeb
        ? null
        : Localizations.of<MaterialLocalizations>(
            context,
            MaterialLocalizations,
          )?.tabLabel(tabIndex: index + 1, tabCount: tabCount);

    return MergeSemantics(
      child: InkWell(
        onTap: onPressed,
        overlayColor: _withSelected(style.overlayColor),
        child: Semantics(
          role: SemanticsRole.tab,
          child: Stack(
            fit: .expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: style.indicatorWeight, color: indicatorColor),
                  ),
                ),
                child: Padding(
                  padding: style.tabPadding,
                  child: Row(
                    mainAxisAlignment: .center,
                    spacing: style.spacing,
                    children: [
                      if (item.icon case final icon?)
                        IconTheme.merge(
                          data: IconThemeData(color: foregroundColor),
                          child: icon,
                        ),
                      Flexible(
                        child: Text(
                          item.label,
                          maxLines: 1,
                          overflow: .ellipsis,
                          style: style.labelStyle.copyWith(color: foregroundColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Semantics(selected: selected, label: positionLabel),
            ],
          ),
        ),
      ),
    );
  }

  // The ink well only reports interaction states, so the selected state is
  // added before resolving the theme's overlay.
  WidgetStateProperty<Color?> _withSelected(WidgetStateProperty<Color?> overlayColor) {
    if (!selected) return overlayColor;
    return .resolveWith((states) => overlayColor.resolve({...states, WidgetState.selected}));
  }
}

// Default values for [StreamTabBarThemeData], resolved from the ambient
// [StreamColorScheme], [StreamTextTheme] and [StreamSpacing].
class _StreamTabBarThemeDefaults extends StreamTabBarThemeData {
  _StreamTabBarThemeDefaults(this._context);

  final BuildContext _context;

  late final StreamColorScheme _colorScheme = _context.streamColorScheme;
  late final StreamTextTheme _textTheme = _context.streamTextTheme;
  late final StreamSpacing _spacing = _context.streamSpacing;

  @override
  double get height => StreamTabBar.height;

  @override
  double get indicatorWeight => 2;

  @override
  WidgetStateProperty<Color> get indicatorColor => .resolveWith((states) {
    if (states.contains(WidgetState.selected)) return _colorScheme.accentPrimary;
    return _colorScheme.borderDefault;
  });

  @override
  TextStyle get labelStyle => _textTheme.captionEmphasis;

  @override
  WidgetStateProperty<Color> get foregroundColor => .resolveWith((states) {
    if (states.contains(WidgetState.selected)) return _colorScheme.accentPrimary;
    return _colorScheme.textSecondary;
  });

  @override
  WidgetStateProperty<Color> get overlayColor => .resolveWith((states) {
    if (states.contains(WidgetState.pressed)) return _colorScheme.backgroundPressed;
    if (states.contains(WidgetState.hovered)) return _colorScheme.backgroundHover;
    if (states.contains(WidgetState.focused)) return _colorScheme.backgroundHover;
    return StreamColors.transparent;
  });

  @override
  EdgeInsetsGeometry get tabPadding => .all(_spacing.sm);

  @override
  double get spacing => _spacing.xs;
}
