import 'package:material_ui/material_ui.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_badge_notification_theme.dart';
import '../../theme/components/stream_bottom_nav_bar_theme.dart';
import '../../theme/stream_floating_fade.dart';
import '../../theme/stream_surface_style.dart';
import '../../theme/stream_theme_extensions.dart';
import '../common/stream_safe_area.dart';

/// Default height of [StreamBottomNavBar] per the Stream design system.
const double kStreamBottomNavBarHeight = 64;

/// A single item in a [StreamBottomNavBar].
///
/// Each item has an [icon] and a text [label]. An optional [selectedIcon]
/// replaces the icon while the item is active, and an optional [tooltip] is
/// shown on long-press or hover.
///
/// The icon widgets are fully generic — callers are free to wrap them in
/// badge overlays, unread indicators, or any other decorator.
class StreamBottomNavBarItem {
  /// Creates a bottom nav bar item.
  const StreamBottomNavBarItem({
    this.key,
    required this.icon,
    this.selectedIcon,
    required this.label,
    this.tooltip,
    this.semanticsLabel,
  });

  /// A key forwarded to the widget that renders this item.
  ///
  /// Give each item a stable key when the item list changes at runtime, so the
  /// tiles keep their identity across rebuilds.
  final Key? key;

  /// The icon displayed when this item is inactive — and while active when
  /// [selectedIcon] is null.
  final Widget icon;

  /// The icon displayed when this item is active.
  ///
  /// Falls back to [icon] when null.
  final Widget? selectedIcon;

  /// The text label shown below the icon.
  final String label;

  /// The text to display in a tooltip when the item is long-pressed (or
  /// hovered on desktop / web).
  ///
  /// When null or empty, no tooltip is shown.
  final String? tooltip;

  /// The label announced by accessibility tools, overriding [label].
  ///
  /// Use this when the visible [label] doesn't fully describe the destination.
  /// When null, [label] is announced.
  final String? semanticsLabel;
}

/// A bottom navigation bar for Stream surfaces.
///
/// ## Floating style
///
/// When [StreamSurfaceStyle.floating] is in effect, the bar renders as a
/// horizontally padded pill with a rounded background, a subtle shadow,
/// and a hairline border. It sits above the body content and is typically
/// used with [StreamScaffold]'s floating bottom slot.
///
/// ## Regular style
///
/// When [StreamSurfaceStyle.regular] is in effect, the bar renders as a
/// standard docked bar with Stream color and typography tokens. A hairline
/// `borderSubtle` top border separates it from the body.
///
/// ## Behaviour resolution
///
/// The effective behaviour is resolved in this priority order:
/// 1. [StreamBottomNavBarStyle.surfaceStyle] — set per-instance via `style` or the
///    ambient [StreamBottomNavBarTheme].
/// 2. The ambient [StreamSurfaceStyle] — floating maps to a floating pill, regular to
///    a docked bar.
///
/// In a [StreamScaffold] `bottom` slot, drive floating through the ambient
/// [StreamSurfaceStyle] (or the scaffold's `bottomSurfaceStyle`) so the
/// scaffold reserves the matching body inset. Floating set only through
/// [StreamBottomNavBarTheme] floats the pill without that inset, so content can
/// slide under it.
///
/// ## Theming
///
/// Item colors, icon size, label styles, border, and pill radius are resolved
/// from [StreamBottomNavBarStyle] — set per-instance via `style` or globally
/// via [StreamBottomNavBarTheme], falling back to token-backed defaults.
///
/// {@tool snippet}
///
/// Basic usage:
///
/// ```dart
/// StreamBottomNavBar(
///   currentIndex: _currentIndex,
///   onTap: (i) => setState(() => _currentIndex = i),
///   items: const [
///     StreamBottomNavBarItem(
///       icon: Icon(Icons.chat_bubble_outline),
///       selectedIcon: Icon(Icons.chat_bubble),
///       label: 'Chats',
///     ),
///     StreamBottomNavBarItem(
///       icon: Icon(Icons.bookmark_outline),
///       selectedIcon: Icon(Icons.bookmark),
///       label: 'Saved',
///     ),
///   ],
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamBottomNavBarItem], which configures each tab.
///  * [StreamBottomNavBarTheme], which styles this widget.
///  * [StreamScaffold], which accepts this widget in its `bottom` slot.
///  * [DefaultStreamBottomNavBar], the default visual implementation.
class StreamBottomNavBar extends StatelessWidget {
  /// Creates a Stream bottom navigation bar.
  StreamBottomNavBar({
    super.key,
    required List<StreamBottomNavBarItem> items,
    required int currentIndex,
    required ValueChanged<int> onTap,
    StreamBottomNavBarStyle? style,
  }) : assert(items.length >= 2, 'StreamBottomNavBar requires at least 2 items'),
       assert(
         currentIndex >= 0 && currentIndex < items.length,
         'currentIndex must be within the items range: '
         '0 <= $currentIndex < ${items.length}',
       ),
       props = .new(
         items: items,
         currentIndex: currentIndex,
         onTap: onTap,
         style: style,
       );

  /// The properties that configure this navigation bar.
  final StreamBottomNavBarProps props;

  /// The surface style this nav bar renders with in [context].
  ///
  /// Precedence: the per-instance [style], then the ambient
  /// [StreamBottomNavBarTheme] style, then the ambient [StreamSurfaceStyle].
  ///
  /// Matches what the bar resolves for itself, so a page dropping one into a
  /// [StreamScaffold] can pass the result as
  /// [StreamScaffold.bottomSurfaceStyle] to lay out the slot to match.
  static StreamSurfaceStyle resolveSurfaceStyle(
    BuildContext context, {
    StreamBottomNavBarStyle? style,
  }) {
    final themeStyle = context.streamBottomNavBarTheme.style;
    final effective = themeStyle?.merge(style) ?? style;
    return effective?.surfaceStyle ?? context.streamSurfaceStyle;
  }

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).bottomNavBar;
    if (builder != null) return builder(context, props);
    return DefaultStreamBottomNavBar(props: props);
  }
}

/// Properties for configuring a [StreamBottomNavBar].
///
/// This class holds all configuration options for a navigation bar, allowing
/// them to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamBottomNavBar], which uses these properties.
///  * [DefaultStreamBottomNavBar], the default implementation.
class StreamBottomNavBarProps {
  /// Creates properties for a bottom navigation bar.
  const StreamBottomNavBarProps({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.style,
  }) : assert(
         currentIndex >= 0 && currentIndex < items.length,
         'currentIndex must be within the items range',
       );

  /// The list of items to display in the navigation bar.
  ///
  /// Must contain at least 2 items.
  final List<StreamBottomNavBarItem> items;

  /// The index of the currently selected item.
  ///
  /// Must be a valid index into [items].
  final int currentIndex;

  /// Called when the user taps a navigation item.
  final ValueChanged<int> onTap;

  /// The visual style applied to this navigation bar.
  ///
  /// Resolution order per field: this [style] → ambient
  /// [StreamBottomNavBarTheme] → token-backed defaults.
  final StreamBottomNavBarStyle? style;
}

/// The default implementation of [StreamBottomNavBar].
///
/// Renders the navigation bar with theming from [StreamBottomNavBarTheme] and
/// serves as the default factory implementation in [StreamComponentFactory].
///
/// Depending on the resolved [StreamSurfaceStyle], the bar is either a
/// docked bar (a solid surface with a hairline top border) or a floating pill
/// (a rounded surface over a gradient fade). Both share the same tiles, each of
/// which animates its icon and label color between the unselected and selected
/// states on tap.
///
/// See also:
///
///  * [StreamBottomNavBar], the public API widget.
///  * [StreamBottomNavBarProps], which configures this widget.
class DefaultStreamBottomNavBar extends StatefulWidget {
  /// Creates a default bottom navigation bar with the given [props].
  const DefaultStreamBottomNavBar({super.key, required this.props});

  /// The properties that configure this navigation bar.
  final StreamBottomNavBarProps props;

  @override
  State<DefaultStreamBottomNavBar> createState() => _DefaultStreamBottomNavBarState();
}

class _DefaultStreamBottomNavBarState extends State<DefaultStreamBottomNavBar> with TickerProviderStateMixin {
  var _controllers = <AnimationController>[];
  var _animations = <CurvedAnimation>[];

  List<StreamBottomNavBarItem> get _items => widget.props.items;

  void _resetState() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final animation in _animations) {
      animation.dispose();
    }

    _controllers = List<AnimationController>.generate(_items.length, (index) {
      return AnimationController(duration: kThemeAnimationDuration, vsync: this)..addListener(_rebuild);
    });
    _animations = List<CurvedAnimation>.generate(_items.length, (index) {
      return CurvedAnimation(
        parent: _controllers[index],
        curve: Curves.fastOutSlowIn,
        reverseCurve: Curves.fastOutSlowIn.flipped,
      );
    });
    _controllers[widget.props.currentIndex].value = 1;
  }

  @override
  void initState() {
    super.initState();
    _resetState();
  }

  void _rebuild() {
    setState(() {
      // Rebuild when any controller ticks so the tiles animate.
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final animation in _animations) {
      animation.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(DefaultStreamBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // No animated segue if the number of items changes.
    if (_items.length != oldWidget.props.items.length) {
      _resetState();
      return;
    }

    if (widget.props.currentIndex != oldWidget.props.currentIndex) {
      _controllers[oldWidget.props.currentIndex].reverse();
      _controllers[widget.props.currentIndex].forward();
    }
  }

  List<Widget> _createTiles({
    required double iconSize,
    required Color selectedItemColor,
    required Color unselectedItemColor,
    required TextStyle selectedLabelStyle,
    required TextStyle unselectedLabelStyle,
  }) {
    final localizations = MaterialLocalizations.of(context);

    // Selected and unselected tiles share the animated color tween; only the
    // label style is chosen per selection state.
    final colorTween = ColorTween(begin: unselectedItemColor, end: selectedItemColor);

    return <Widget>[
      for (var i = 0; i < _items.length; i++)
        _StreamNavTile(
          key: _items[i].key,
          item: _items[i],
          animation: _animations[i],
          iconSize: iconSize,
          selected: i == widget.props.currentIndex,
          onTap: () => widget.props.onTap(i),
          colorTween: colorTween,
          labelStyle: i == widget.props.currentIndex ? selectedLabelStyle : unselectedLabelStyle,
          indexLabel: localizations.tabLabel(tabIndex: i + 1, tabCount: _items.length),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasDirectionality(context), 'A Directionality ancestor is required.');
    assert(debugCheckHasMaterialLocalizations(context), 'MaterialLocalizations are required.');
    assert(debugCheckHasMediaQuery(context), 'A MediaQuery ancestor is required.');

    final style = context.streamBottomNavBarTheme.style?.merge(widget.props.style) ?? widget.props.style;
    final defaults = _StreamBottomNavBarStyleDefaults(context);

    final effectiveSurfaceStyle = StreamBottomNavBar.resolveSurfaceStyle(context, style: widget.props.style);

    final effectiveBackgroundColor = style?.backgroundColor ?? defaults.backgroundColor;
    final effectiveFloatingBackgroundColor = style?.floatingBackgroundColor ?? defaults.floatingBackgroundColor;
    final effectiveSelectedItemColor = style?.selectedItemColor ?? defaults.selectedItemColor;
    final effectiveUnselectedItemColor = style?.unselectedItemColor ?? defaults.unselectedItemColor;
    final effectiveIconSize = style?.iconSize ?? defaults.iconSize;
    final effectiveSelectedLabelStyle = style?.selectedLabelStyle ?? defaults.selectedLabelStyle;
    final effectiveUnselectedLabelStyle = style?.unselectedLabelStyle ?? defaults.unselectedLabelStyle;
    final effectiveBorderColor = style?.borderColor ?? defaults.borderColor;
    final effectiveBorderRadius = style?.borderRadius ?? defaults.borderRadius;
    final effectiveElevation = style?.floatingElevation ?? defaults.floatingElevation;

    final tiles = StreamBadgeNotificationTheme(
      data: const StreamBadgeNotificationThemeData(size: StreamBadgeNotificationSize.xs),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: kStreamBottomNavBarHeight),
        child: DefaultTextStyle.merge(
          overflow: TextOverflow.ellipsis,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _createTiles(
              iconSize: effectiveIconSize,
              selectedItemColor: effectiveSelectedItemColor,
              unselectedItemColor: effectiveUnselectedItemColor,
              selectedLabelStyle: effectiveSelectedLabelStyle,
              unselectedLabelStyle: effectiveUnselectedLabelStyle,
            ),
          ),
        ),
      ),
    );

    return Semantics(
      explicitChildNodes: true,
      child: switch (effectiveSurfaceStyle) {
        StreamSurfaceStyle.regular => _RegularChrome(
          backgroundColor: effectiveBackgroundColor,
          borderColor: effectiveBorderColor,
          child: tiles,
        ),
        StreamSurfaceStyle.floating => _FloatingChrome(
          pillColor: effectiveBackgroundColor,
          gradientColor: effectiveFloatingBackgroundColor,
          borderColor: effectiveBorderColor,
          borderRadius: effectiveBorderRadius,
          elevation: effectiveElevation,
          child: tiles,
        ),
      },
    );
  }
}

// A single navigation tile: an icon above a label, both sharing a color that
// animates between the unselected and selected states.
class _StreamNavTile extends StatelessWidget {
  const _StreamNavTile({
    super.key,
    required this.item,
    required this.animation,
    required this.iconSize,
    required this.selected,
    required this.onTap,
    required this.colorTween,
    required this.labelStyle,
    required this.indexLabel,
  });

  final StreamBottomNavBarItem item;
  final Animation<double> animation;
  final double iconSize;
  final bool selected;
  final VoidCallback onTap;
  final ColorTween colorTween;
  final TextStyle labelStyle;
  final String indexLabel;

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;
    final color = colorTween.evaluate(animation);

    Widget tile = Semantics(
      selected: selected,
      button: true,
      container: true,
      child: Stack(
        children: <Widget>[
          InkResponse(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: spacing.xs),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: spacing.xxxs,
                children: <Widget>[
                  Align(
                    alignment: Alignment.topCenter,
                    heightFactor: 1,
                    child: IconTheme(
                      data: IconThemeData(color: color, size: iconSize),
                      child: selected ? (item.selectedIcon ?? item.icon) : item.icon,
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    heightFactor: 1,
                    child: MediaQuery.withClampedTextScaling(
                      maxScaleFactor: 1,
                      child: Text(
                        item.label,
                        semanticsLabel: item.semanticsLabel,
                        style: labelStyle.copyWith(color: color),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Semantics(label: indexLabel),
        ],
      ),
    );

    if (item.tooltip case final tooltip? when tooltip.isNotEmpty) {
      tile = Tooltip(
        message: tooltip,
        preferBelow: false,
        verticalOffset: iconSize + (labelStyle.fontSize ?? 0),
        excludeFromSemantics: true,
        child: tile,
      );
    }

    return Expanded(child: tile);
  }
}

// Docked chrome: a solid surface with a hairline top border, inset above the
// system bottom inset.
class _RegularChrome extends StatelessWidget {
  const _RegularChrome({
    required this.backgroundColor,
    required this.borderColor,
    required this.child,
  });

  final Color backgroundColor;
  final Color borderColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: StreamSafeArea(top: false, child: child),
      ),
    );
  }
}

// Floating chrome: a rounded pill with a shadow and hairline border, sitting
// above a gradient that fades the bar into the content behind it.
class _FloatingChrome extends StatelessWidget {
  const _FloatingChrome({
    required this.pillColor,
    required this.gradientColor,
    required this.borderColor,
    required this.borderRadius,
    required this.elevation,
    required this.child,
  });

  final Color pillColor;
  final Color gradientColor;
  final Color borderColor;
  final BorderRadiusGeometry borderRadius;
  final double elevation;
  final Widget child;

  LinearGradient _buildGradient({
    required double topInset,
    required double bottomInset,
  }) {
    // The gradient spans the whole chrome — top margin, pill, and bottom inset.
    // Keep it solid across the bottom inset and fade up through the pill into
    // the content behind the bar.
    //
    // Approximate: kStreamBottomNavBarHeight is the tiles' minHeight, not the
    // rendered height, so a taller wrapped label drifts the fade boundary
    // slightly off the pill edge — fine in practice.
    final totalHeight = topInset + kStreamBottomNavBarHeight + bottomInset;
    final solidFraction = totalHeight > 0 ? bottomInset / totalHeight : 0.0;

    return streamFloatingFadeLinearGradient(
      color: gradientColor,
      solidFraction: solidFraction,
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;
    final minimum = EdgeInsets.only(left: spacing.xl, top: spacing.xl, right: spacing.xl);

    final platform = Theme.of(context).platform;
    final hasBottomInset = MediaQuery.paddingOf(context).bottom > 0;

    // Apple platforms rest on the bottom inset; elsewhere a margin clears it,
    // and stands in when there is none.
    final bottomSafeAreaMargin = switch (platform) {
      .iOS || .macOS when hasBottomInset => spacing.none,
      _ => spacing.md,
    };

    final margin = EdgeInsets.only(bottom: bottomSafeAreaMargin);
    final insets = StreamSafeArea.resolveInsets(context, top: false, minimum: minimum, margin: margin);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: _buildGradient(
          topInset: insets.top,
          bottomInset: insets.bottom,
        ),
      ),
      child: StreamSafeArea(
        top: false,
        minimum: minimum,
        margin: margin,
        child: Material(
          color: pillColor,
          elevation: elevation,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
            side: BorderSide(color: borderColor),
          ),
          child: child,
        ),
      ),
    );
  }
}

// Default style values for [StreamBottomNavBar].
//
// These defaults are used when no explicit value is provided via
// [StreamBottomNavBarStyle]. They are context-aware and use values from
// [StreamColorScheme], [StreamTextTheme], and [StreamRadius].
class _StreamBottomNavBarStyleDefaults extends StreamBottomNavBarStyle {
  _StreamBottomNavBarStyleDefaults(this._context);

  final BuildContext _context;

  late final _colorScheme = _context.streamColorScheme;
  late final _textTheme = _context.streamTextTheme;
  late final _radius = _context.streamRadius;
  late final _elevation = _context.streamElevation;

  @override
  double get floatingElevation => _elevation.level3;

  @override
  Color get backgroundColor => _colorScheme.backgroundElevation1;

  @override
  Color get floatingBackgroundColor => _colorScheme.backgroundElevation0;

  @override
  Color get selectedItemColor => _colorScheme.textPrimary;

  @override
  Color get unselectedItemColor => _colorScheme.textTertiary;

  @override
  double get iconSize => 20;

  @override
  TextStyle get selectedLabelStyle => _textTheme.metadataEmphasis;

  @override
  TextStyle get unselectedLabelStyle => _textTheme.metadataEmphasis;

  @override
  Color get borderColor => _colorScheme.borderSubtle;

  @override
  BorderRadiusGeometry get borderRadius => .all(_radius.max);
}
