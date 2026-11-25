import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_tab_bar_theme.dart';
import '../../theme/primitives/stream_colors.dart';
import '../../theme/primitives/stream_spacing.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/semantics/stream_text_theme.dart';
import '../../theme/stream_theme_extensions.dart';

/// A row of equal-width tabs that underlines the selected one.
///
/// The bar carries no controller: [StreamTabBarProps.selectedIndex] comes from
/// the caller and [StreamTabBarProps.onTap] reports a tap.
///
/// Screen readers announce the bar as a tab bar and each tab as a tab with
/// its selected state. Every enabled tab is a keyboard focus stop, and Enter
/// or Space selects the focused tab.
///
/// The bar is a [PreferredSizeWidget], so it can be an [AppBar.bottom]. Its
/// [preferredSize] is the default height, so wrap it in a [PreferredSize]
/// when a theme changes [StreamTabBarThemeData.minHeight].
///
/// {@tool snippet}
///
/// Switch between two views of the same content:
///
/// ```dart
/// StreamTabBar(
///   selectedIndex: selectedIndex,
///   onTap: (index) => setState(() => selectedIndex = index),
///   tabs: [
///     StreamTabBarItem(label: 'Photos', icon: Icon(context.streamIcons.image)),
///     StreamTabBarItem(label: 'Files', icon: Icon(context.streamIcons.file)),
///   ],
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Drive a [TabBarView] from a [TabController] the parent owns, so a swipe
/// between pages moves the selection too:
///
/// ```dart
/// class _InboxState extends State<Inbox> with SingleTickerProviderStateMixin {
///   late final _controller = TabController(length: 2, vsync: this);
///
///   @override
///   void dispose() {
///     _controller.dispose();
///     super.dispose();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return Column(
///       children: [
///         ListenableBuilder(
///           listenable: _controller,
///           builder: (context, _) => StreamTabBar(
///             selectedIndex: _controller.index,
///             onTap: _controller.animateTo,
///             tabs: const [
///               StreamTabBarItem(label: 'Photos'),
///               StreamTabBarItem(label: 'Files'),
///             ],
///           ),
///         ),
///         Expanded(
///           child: TabBarView(
///             controller: _controller,
///             children: const [PhotoGrid(), FileList()],
///           ),
///         ),
///       ],
///     );
///   }
/// }
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamTabBarItem], which describes one tab.
///  * [StreamTabBarTheme], for customizing tab bar appearance.
@experimental
class StreamTabBar extends StatelessWidget implements PreferredSizeWidget {
  /// Creates a tab bar.
  ///
  /// [tabs] must not be empty, and [selectedIndex], when given, must be an
  /// index into [tabs].
  StreamTabBar({
    super.key,
    required List<StreamTabBarItem> tabs,
    int? selectedIndex,
    required ValueChanged<int> onTap,
  }) : props = .new(tabs: tabs, selectedIndex: selectedIndex, onTap: onTap);

  /// The props controlling the appearance and behavior of this tab bar.
  final StreamTabBarProps props;

  @override
  Size get preferredSize => const .fromHeight(kMinInteractiveDimension);

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
final class StreamTabBarItem {
  /// Creates a tab.
  const StreamTabBarItem({required this.label, this.icon, this.enabled = true});

  /// The tab's label, which is also what screen readers announce for it.
  final String label;

  /// An icon drawn before [label].
  ///
  /// It takes the tab's foreground color through [IconTheme].
  final Widget? icon;

  /// Whether the tab can be selected.
  ///
  /// A disabled tab ignores taps, is skipped by keyboard focus, and is drawn
  /// in the disabled colors. It can still be the selected tab.
  final bool enabled;
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
@immutable
@experimental
final class StreamTabBarProps {
  /// Creates properties for a tab bar.
  ///
  /// [tabs] must not be empty, and [selectedIndex], when given, must be an
  /// index into [tabs].
  const StreamTabBarProps({
    required this.tabs,
    this.selectedIndex,
    required this.onTap,
  }) : assert(tabs.length > 0, 'A tab bar needs at least one tab.'),
       assert(
         selectedIndex == null || (selectedIndex >= 0 && selectedIndex < tabs.length),
         'selectedIndex must be null or an index into tabs.',
       );

  /// The tabs to draw, in order.
  final List<StreamTabBarItem> tabs;

  /// The index into [tabs] of the selected tab, or null when no tab is
  /// selected.
  final int? selectedIndex;

  /// Called with the index of the tab the user activates, by tap or keyboard.
  ///
  /// Also called for the tab that is already selected, and never for a
  /// disabled tab.
  final ValueChanged<int> onTap;
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
    final effective = defaults.merge(theme);

    final style = _StreamTabStyle(
      indicatorWeight: effective.indicatorWeight!,
      indicatorColor: _withDefault(theme.indicatorColor, defaults.indicatorColor),
      labelStyle: effective.labelStyle!,
      foregroundColor: _withDefault(theme.foregroundColor, defaults.foregroundColor),
      overlayColor: _withDefault(theme.overlayColor, defaults.overlayColor),
      overlaySide: _withDefault(theme.overlaySide, defaults.overlaySide),
      overlayInsets: .symmetric(vertical: context.streamSpacing.xs),
      labelPadding: effective.labelPadding!,
      spacing: effective.spacing!,
    );

    final tabCount = props.tabs.length;

    return Semantics(
      role: SemanticsRole.tabBar,
      container: true,
      explicitChildNodes: true,
      child: Material(
        type: .transparency,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(width: effective.dividerHeight!, color: effective.dividerColor!),
            ),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: effective.minHeight!),
            child: _EqualTabsRow(
              textDirection: Directionality.of(context),
              children: [
                for (final (index, tab) in props.tabs.indexed)
                  _StreamTab(
                    item: tab,
                    index: index,
                    tabCount: tabCount,
                    selected: index == props.selectedIndex,
                    style: style,
                    onTap: () => props.onTap(index),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Resolves [theme] where it gives a value and [fallback] where it gives
  // null, so a theme can override some states and keep the rest.
  static WidgetStateProperty<T> _withDefault<T>(
    WidgetStateProperty<T?>? theme,
    WidgetStateProperty<T> fallback,
  ) {
    if (theme == null) return fallback;
    return .resolveWith((states) => theme.resolve(states) ?? fallback.resolve(states));
  }
}

// Lays its children out side by side at equal widths, then gives them all
// the height of the tallest, so every tab's underline sits on the bar's
// bottom edge.
//
// A Row of Expanded children in an IntrinsicHeight would do the same, but
// asks every tab for its intrinsic height, which throws for an icon built
// with a LayoutBuilder.
class _EqualTabsRow extends MultiChildRenderObjectWidget {
  const _EqualTabsRow({required this.textDirection, required super.children});

  final TextDirection textDirection;

  @override
  _RenderEqualTabsRow createRenderObject(BuildContext context) => _RenderEqualTabsRow(textDirection);

  @override
  void updateRenderObject(BuildContext context, _RenderEqualTabsRow renderObject) {
    renderObject.textDirection = textDirection;
  }
}

class _EqualTabsRowParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderEqualTabsRow extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _EqualTabsRowParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _EqualTabsRowParentData> {
  _RenderEqualTabsRow(this._textDirection);

  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _EqualTabsRowParentData) child.parentData = _EqualTabsRowParentData();
  }

  double _tabWidth(BoxConstraints constraints) {
    assert(constraints.hasBoundedWidth, 'A StreamTabBar needs a bounded width.');
    return constraints.maxWidth / childCount;
  }

  // The height every tab is given: the tallest tab's own height, within
  // [constraints].
  double _rowHeight(BoxConstraints constraints, Size Function(RenderBox child, BoxConstraints constraints) sizeOf) {
    final tabConstraints = BoxConstraints(
      minWidth: _tabWidth(constraints),
      maxWidth: _tabWidth(constraints),
      maxHeight: constraints.maxHeight,
    );
    var height = constraints.minHeight;
    for (var child = firstChild; child != null; child = childAfter(child)) {
      height = math.max(height, sizeOf(child, tabConstraints).height);
    }
    return constraints.constrainHeight(height);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    if (childCount == 0) return constraints.smallest;
    final height = _rowHeight(constraints, (child, constraints) => child.getDryLayout(constraints));
    return Size(constraints.maxWidth, height);
  }

  @override
  void performLayout() {
    if (childCount == 0) {
      size = constraints.smallest;
      return;
    }
    final tabWidth = _tabWidth(constraints);
    final height = _rowHeight(constraints, (child, constraints) {
      child.layout(constraints, parentUsesSize: true);
      return child.size;
    });

    var index = 0;
    for (var child = firstChild; child != null; child = childAfter(child), index += 1) {
      // Loose in height with parentUsesSize, so a resized tab relays the whole row out.
      child.layout(
        BoxConstraints(minWidth: tabWidth, maxWidth: tabWidth, minHeight: height, maxHeight: constraints.maxHeight),
        parentUsesSize: true,
      );
      final slot = textDirection == TextDirection.rtl ? childCount - 1 - index : index;
      (child.parentData! as _EqualTabsRowParentData).offset = Offset(slot * tabWidth, 0);
    }
    size = Size(constraints.maxWidth, height);
  }

  @override
  double computeMinIntrinsicWidth(double height) => _sumOfWidest((child) => child.getMinIntrinsicWidth(height));

  @override
  double computeMaxIntrinsicWidth(double height) => _sumOfWidest((child) => child.getMaxIntrinsicWidth(height));

  // Every tab is as wide as the widest, so the row needs that many times it.
  double _sumOfWidest(double Function(RenderBox child) widthOf) {
    var widest = 0.0;
    for (var child = firstChild; child != null; child = childAfter(child)) {
      widest = math.max(widest, widthOf(child));
    }
    return widest * childCount;
  }

  @override
  double computeMinIntrinsicHeight(double width) =>
      _tallest((child) => child.getMinIntrinsicHeight(_tabWidthFor(width)));

  @override
  double computeMaxIntrinsicHeight(double width) =>
      _tallest((child) => child.getMaxIntrinsicHeight(_tabWidthFor(width)));

  // The width each tab gets out of a row [width] wide, as in [performLayout].
  double _tabWidthFor(double width) => width.isFinite ? width / childCount : width;

  double _tallest(double Function(RenderBox child) heightOf) {
    var tallest = 0.0;
    for (var child = firstChild; child != null; child = childAfter(child)) {
      tallest = math.max(tallest, heightOf(child));
    }
    return tallest;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) => defaultPaint(context, offset);
}

// The resolved visual values every tab of one bar shares.
class _StreamTabStyle {
  const _StreamTabStyle({
    required this.indicatorWeight,
    required this.indicatorColor,
    required this.labelStyle,
    required this.foregroundColor,
    required this.overlayColor,
    required this.overlaySide,
    required this.overlayInsets,
    required this.labelPadding,
    required this.spacing,
  });

  final double indicatorWeight;
  final WidgetStateProperty<Color> indicatorColor;
  final TextStyle labelStyle;
  final WidgetStateProperty<Color> foregroundColor;
  final WidgetStateProperty<Color> overlayColor;
  final WidgetStateProperty<BorderSide> overlaySide;
  final EdgeInsetsGeometry overlayInsets;
  final EdgeInsetsGeometry labelPadding;
  final double spacing;
}

class _StreamTab extends StatefulWidget {
  const _StreamTab({
    required this.item,
    required this.index,
    required this.tabCount,
    required this.selected,
    required this.style,
    required this.onTap,
  });

  final StreamTabBarItem item;
  final int index;
  final int tabCount;
  final bool selected;
  final _StreamTabStyle style;
  final VoidCallback onTap;

  @override
  State<_StreamTab> createState() => _StreamTabState();
}

class _StreamTabState extends State<_StreamTab> {
  final _interactionStates = WidgetStatesController();

  @override
  void dispose() {
    _interactionStates.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final style = widget.style;
    final states = <WidgetState>{
      if (widget.selected) WidgetState.selected,
      if (!item.enabled) WidgetState.disabled,
    };
    final foregroundColor = style.foregroundColor.resolve(states);

    // Native screen readers do not announce the position from the tab role; ARIA on the web does.
    final positionLabel = kIsWeb
        ? null
        : Localizations.of<MaterialLocalizations>(
            context,
            MaterialLocalizations,
          )?.tabLabel(tabIndex: widget.index + 1, tabCount: widget.tabCount);

    return MergeSemantics(
      child: InkWell(
        onTap: item.enabled ? widget.onTap : null,
        statesController: _interactionStates,
        overlayColor: const WidgetStatePropertyAll(StreamColors.transparent),
        splashFactory: NoSplash.splashFactory,
        child: Semantics(
          role: SemanticsRole.tab,
          child: Stack(
            fit: .passthrough,
            children: [
              Padding(
                padding: style.labelPadding,
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
              if (widget.selected)
                PositionedDirectional(
                  start: 0,
                  end: 0,
                  bottom: 0,
                  height: style.indicatorWeight,
                  child: ColoredBox(color: style.indicatorColor.resolve(states)),
                ),
              Positioned.fill(
                child: IgnorePointer(
                  child: Padding(
                    padding: style.overlayInsets,
                    child: ValueListenableBuilder(
                      valueListenable: _interactionStates,
                      builder: (context, interaction, _) {
                        final overlayStates = {...interaction, ...states};
                        return DecoratedBox(
                          decoration: ShapeDecoration(
                            color: style.overlayColor.resolve(overlayStates),
                            shape: StadiumBorder(side: style.overlaySide.resolve(overlayStates)),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Semantics(selected: widget.selected, enabled: item.enabled, label: positionLabel),
            ],
          ),
        ),
      ),
    );
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
  double get minHeight => kMinInteractiveDimension;

  @override
  double get indicatorWeight => 2;

  @override
  WidgetStateProperty<Color> get indicatorColor => .resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return _colorScheme.borderDisabled;
    return _colorScheme.accentPrimary;
  });

  @override
  double get dividerHeight => 1;

  @override
  Color get dividerColor => _colorScheme.borderDefault;

  @override
  TextStyle get labelStyle => _textTheme.captionEmphasis;

  @override
  WidgetStateProperty<Color> get foregroundColor => .resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return _colorScheme.textDisabled;
    if (states.contains(WidgetState.selected)) return _colorScheme.accentPrimary;
    return _colorScheme.textSecondary;
  });

  @override
  WidgetStateProperty<Color> get overlayColor => .resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return StreamColors.transparent;
    if (states.contains(WidgetState.pressed)) return _colorScheme.backgroundPressed;
    if (states.contains(WidgetState.hovered)) return _colorScheme.backgroundHover;
    return StreamColors.transparent;
  });

  @override
  WidgetStateProperty<BorderSide> get overlaySide => .resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return BorderSide.none;
    if (states.contains(WidgetState.focused)) return BorderSide(width: 2, color: _colorScheme.borderFocus);
    return BorderSide.none;
  });

  @override
  EdgeInsetsGeometry get labelPadding => .symmetric(horizontal: _spacing.sm, vertical: _spacing.sm + _spacing.xxxs);

  @override
  double get spacing => _spacing.xs;
}
