import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_badge_notification_theme.dart';
import '../../theme/components/stream_bottom_nav_bar_theme.dart';
import '../../theme/stream_floating_fade.dart';
import '../../theme/stream_theme_extensions.dart';

/// Default height of [StreamBottomNavBar] per the Stream design system.
const double kStreamBottomNavBarHeight = 72;

/// A single item in a [StreamBottomNavBar].
///
/// Each item has an [icon] and [selectedIcon] widget (the latter is shown
/// when the item is active) and a text [label].
///
/// The icon widgets are fully generic — callers are free to wrap them in
/// badge overlays, unread indicators, or any other decorator.
class StreamBottomNavBarItem {
  /// Creates a bottom nav bar item.
  const StreamBottomNavBarItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  /// The icon displayed when this item is inactive.
  final Widget icon;

  /// The icon displayed when this item is active.
  final Widget selectedIcon;

  /// The text label shown below the icon.
  final String label;
}

/// A bottom navigation bar for Stream surfaces that automatically adapts
/// between a floating pill style and a regular docked style based on the
/// ambient [StreamBottomNavBarBehavior].
///
/// ## Floating style
///
/// When [StreamBottomNavBarBehavior.floating] is in effect, the bar renders as a
/// horizontally padded pill with a rounded background, a subtle shadow,
/// and a hairline border. It sits above the body content and is typically
/// used with [StreamScaffold]'s floating bottom slot.
///
/// ## Regular style
///
/// When [StreamBottomNavBarBehavior.regular] is in effect, the bar renders as a
/// standard docked bar with Stream colour and typography tokens. A hairline
/// `borderSubtle` top border separates it from the body.
///
/// ## Behaviour resolution
///
/// The effective behaviour is resolved in this priority order:
/// 1. [StreamBottomNavBarStyle.behavior] — set per-instance via `style` or the
///    ambient [StreamBottomNavBarTheme].
/// 2. The ambient [StreamAppStyle] — floating maps to a floating pill, regular to
///    a docked bar.
///
/// ## Theming
///
/// Item colours, icon size, label styles, border, and pill radius are resolved
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
/// Depending on the resolved [StreamBottomNavBarBehavior], the bar is either a
/// docked bar (a solid surface with a hairline top border) or a floating pill
/// (a rounded surface over a gradient fade). Both share the same tiles, each of
/// which animates its icon and label colour between the unselected and selected
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

    // Selected and unselected tiles share the animated colour tween; only the
    // label style is chosen per selection state.
    final colorTween = ColorTween(begin: unselectedItemColor, end: selectedItemColor);

    return <Widget>[
      for (var i = 0; i < _items.length; i++)
        _StreamNavTile(
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

    final effectiveBehavior = style?.behavior ?? defaults.behavior;

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
        // A transparent surface above the bar background so each tile can paint
        // its tap ripple.
        child: Material(
          type: MaterialType.transparency,
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
      ),
    );

    return Semantics(
      explicitChildNodes: true,
      child: switch (effectiveBehavior) {
        StreamBottomNavBarBehavior.regular => _RegularChrome(
          backgroundColor: effectiveBackgroundColor,
          borderColor: effectiveBorderColor,
          child: tiles,
        ),
        StreamBottomNavBarBehavior.floating => _FloatingChrome(
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

// A single navigation tile: an icon above a label, both sharing a colour that
// animates between the unselected and selected states.
class _StreamNavTile extends StatelessWidget {
  const _StreamNavTile({
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

    final Widget result = Semantics(
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
                      child: selected ? item.selectedIcon : item.icon,
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    heightFactor: 1,
                    child: MediaQuery.withClampedTextScaling(
                      maxScaleFactor: 1,
                      child: Text(item.label, style: labelStyle.copyWith(color: color)),
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

    return Expanded(child: result);
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
      child: SafeArea(top: false, child: child),
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
    final margin = context.streamSpacing.xl;
    // Matches the SafeArea below: at least `margin`, growing with the device's
    // bottom inset so the pill never sits flush against the edge.
    final bottomInset = math.max(MediaQuery.paddingOf(context).bottom, margin);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: _buildGradient(topInset: margin, bottomInset: bottomInset),
      ),
      child: SafeArea(
        top: false,
        minimum: .all(margin),
        child: Material(
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
            side: BorderSide(color: borderColor),
          ),
          color: pillColor,
          elevation: elevation,
          clipBehavior: Clip.antiAlias,
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
  late final _appStyle = _context.streamTheme.appStyle;
  late final _elevation = _context.streamElevation;

  @override
  StreamBottomNavBarBehavior get behavior => _appStyle.isFloating ? .floating : .regular;

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
