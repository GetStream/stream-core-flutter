import 'dart:math' as math;

import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:flutter/material.dart';

import '../../theme/components/stream_app_bar_theme.dart';
import '../../theme/components/stream_bottom_app_bar_theme.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/stream_surface_style.dart';
import '../../theme/stream_theme_extensions.dart';

/// A scaffold for full-page surfaces in the Stream design system.
///
/// [StreamScaffold] composes three slots — [appBar], [body], and [bottom] —
/// and enlarges the body's [MediaQuery] padding by the extent of any floating
/// bar so that standard scrollables ([ListView]/[GridView]) and [SafeArea]
/// inset their content automatically, without knowing about the layout.
///
/// ## Floating vs. regular
///
/// The behaviour of each slot is resolved via a three-step priority chain:
///
/// 1. Per-instance [appBarSurfaceStyle] / [bottomBarSurfaceStyle] on this widget.
/// 2. [StreamAppBarStyle.surfaceStyle] / [StreamBottomAppBarStyle.surfaceStyle]
///    from the ambient component theme.
/// 3. The ambient [StreamSurfaceStyle] enum value ([StreamSurfaceStyle.floating] or
///    [StreamSurfaceStyle.regular]).
///
/// * [StreamSurfaceStyle.floating] on the app bar — the body extends *behind*
///   the app bar; the body's `MediaQuery.padding.top` is set to the app-bar
///   height so content rests clear of the bar.
/// * [StreamSurfaceStyle.floating] on the bottom widget — the body extends *behind* the bottom
///   widget; the body's `MediaQuery.padding.bottom` is set to the measured height
///   of that widget.
/// * `regular` for either slot — no overlap; the slot occupies its own space
///   and the corresponding inset is `0.0`.
///
/// This resolution reads the ambient component theme and [StreamSurfaceStyle], not
/// a `style` set directly on the bar widget. A bar that pins its own `surfaceStyle`
/// (or a [StreamBottomNavBar], which resolves floating from its own theme) can
/// float while this scaffold keeps the slot docked and publishes no inset. To
/// keep the layout and chrome in sync, consider setting the matching
/// [appBarSurfaceStyle] / [bottomBarSurfaceStyle] here, or driving both from the
/// ambient [StreamSurfaceStyle].
///
/// ## Drawer support
///
/// Provide a [drawer] and/or [endDrawer] to add slide-in side panels; a widget
/// in [appBar] can open one via `Scaffold.of(context).openDrawer()` — for
/// example a chat SDK's channel-list header menu button.
///
/// ## Reading the insets
///
/// Standard scrollables auto-inset. Widgets that do not consume
/// `MediaQuery.padding` (e.g. a [CustomScrollView] or a `ScrollablePositionedList`)
/// can read it explicitly and apply it as scroll padding:
///
/// ```dart
/// final padding = MediaQuery.paddingOf(context);
/// // apply padding.top / padding.bottom as the scroll view's padding …
/// ```
///
/// {@tool snippet}
///
/// ```dart
/// StreamScaffold(
///   appBar: StreamAppBar(title: Text('Home')),
///   body: ListView(/* … */),
///   bottom: StreamBottomNavBar(/* … */),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamAppBar], the standard floating/regular app bar.
///  * [StreamBottomAppBar], the standard toolbar for the bottom slot.
class StreamScaffold extends StatelessWidget {
  /// Creates a Stream scaffold.
  const StreamScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottom,
    this.drawer,
    this.onDrawerChanged,
    this.endDrawer,
    this.onEndDrawerChanged,
    this.drawerScrimColor,
    this.drawerEdgeDragWidth,
    this.drawerEnableOpenDragGesture = true,
    this.endDrawerEnableOpenDragGesture = true,
    this.drawerDragStartBehavior = .start,
    this.drawerBarrierDismissible = true,
    this.appBarSurfaceStyle,
    this.bottomBarSurfaceStyle,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.restorationId,
  });

  /// An optional app bar displayed at the top of the scaffold.
  ///
  /// Must implement [PreferredSizeWidget]. Its measured height becomes the
  /// body's top inset when floating.
  final PreferredSizeWidget? appBar;

  /// The primary content of the scaffold.
  ///
  /// The body's [MediaQuery] padding is enlarged by the extent of any floating
  /// bar so standard scrollables inset their content automatically.
  final Widget body;

  /// An optional widget displayed at the bottom of the scaffold.
  ///
  /// When [bottomBarSurfaceStyle] is [StreamSurfaceStyle.floating] this widget
  /// overlaps the body; otherwise it sits below it.
  final Widget? bottom;

  /// A panel displayed to the side of the [body], often hidden on mobile
  /// devices. Swipes in from either [TextDirection.ltr] start side or
  /// [TextDirection.rtl] start side.
  final Widget? drawer;

  /// Called when the [drawer] changes to open or closed.
  final DrawerCallback? onDrawerChanged;

  /// A panel displayed to the opposite side of the [body] from the [drawer].
  final Widget? endDrawer;

  /// Called when the [endDrawer] changes to open or closed.
  final DrawerCallback? onEndDrawerChanged;

  /// The color of the scrim that darkens the [body] while a drawer is open.
  ///
  /// When null the ambient [DrawerThemeData.scrimColor] is used.
  final Color? drawerScrimColor;

  /// The width of the edge area within which a horizontal swipe opens the
  /// [drawer].
  ///
  /// When null a platform-dependent default is used.
  final double? drawerEdgeDragWidth;

  /// Whether the [drawer] can be opened with an edge-swipe gesture.
  ///
  /// Defaults to `true`.
  final bool drawerEnableOpenDragGesture;

  /// Whether the [endDrawer] can be opened with an edge-swipe gesture.
  ///
  /// Defaults to `true`.
  final bool endDrawerEnableOpenDragGesture;

  /// The way a drawer's open-drag gesture is handled.
  ///
  /// Defaults to [DragStartBehavior.start].
  final DragStartBehavior drawerDragStartBehavior;

  /// Whether tapping the scrim dismisses an open drawer.
  ///
  /// Defaults to `true`.
  final bool drawerBarrierDismissible;

  /// Per-instance override for the app bar's surface style.
  ///
  /// When null the value is resolved from [StreamAppBarStyle.surfaceStyle]
  /// in the ambient [StreamAppBarTheme], falling back to the ambient
  /// [StreamSurfaceStyle].
  final StreamSurfaceStyle? appBarSurfaceStyle;

  /// Per-instance override for the bottom bar's surface style.
  ///
  /// When null the value is resolved from
  /// [StreamBottomAppBarStyle.surfaceStyle] in the ambient
  /// [StreamBottomAppBarTheme], falling back to the ambient [StreamSurfaceStyle].
  final StreamSurfaceStyle? bottomBarSurfaceStyle;

  /// The background color of the scaffold.
  ///
  /// Defaults to [StreamColorScheme.backgroundApp].
  final Color? backgroundColor;

  /// Whether the scaffold should resize to avoid the on-screen keyboard.
  ///
  /// Defaults to `true`.
  final bool resizeToAvoidBottomInset;

  /// Restoration ID to save and restore the state of the scaffold.
  ///
  /// When null the scaffold's internal state (such as an open drawer) is not
  /// restored.
  final String? restorationId;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;

    final surfaceStyle = context.streamSurfaceStyle;
    final appBarStyle = context.streamAppBarTheme.style;
    final bottomAppBarStyle = context.streamBottomAppBarTheme.style;

    var effectiveAppBarSurfaceStyle = appBarSurfaceStyle ?? appBarStyle?.surfaceStyle;
    effectiveAppBarSurfaceStyle ??= surfaceStyle;

    var effectiveBottomBarSurfaceStyle = bottomBarSurfaceStyle ?? bottomAppBarStyle?.surfaceStyle;
    effectiveBottomBarSurfaceStyle ??= surfaceStyle;

    final effectiveBackgroundColor = backgroundColor ?? colorScheme.backgroundApp;

    final appBarFloating = effectiveAppBarSurfaceStyle == .floating;
    final bottomFloating = effectiveBottomBarSurfaceStyle == .floating && bottom != null;

    return Scaffold(
      backgroundColor: effectiveBackgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      restorationId: restorationId,
      // The appBar always occupies the Scaffold's standard slot;
      // extendBodyBehindAppBar controls whether the body overlaps it.
      appBar: appBar,
      drawer: drawer,
      onDrawerChanged: onDrawerChanged,
      endDrawer: endDrawer,
      onEndDrawerChanged: onEndDrawerChanged,
      drawerScrimColor: drawerScrimColor,
      drawerEdgeDragWidth: drawerEdgeDragWidth,
      drawerEnableOpenDragGesture: drawerEnableOpenDragGesture,
      endDrawerEnableOpenDragGesture: endDrawerEnableOpenDragGesture,
      drawerDragStartBehavior: drawerDragStartBehavior,
      drawerBarrierDismissible: drawerBarrierDismissible,
      extendBodyBehindAppBar: appBarFloating,
      body: _StreamScaffoldBody(
        floating: bottomFloating,
        bottom: bottom,
        child: body,
      ),
    );
  }
}

// Layout slot identifiers used by the body delegate.
enum _Slot { body, bottom }

// Custom BoxConstraints that carries the measured bottomHeight so a
// LayoutBuilder inside the body can read it synchronously within the same
// layout pass.
//
// == and hashCode are overridden to trigger a child re-layout whenever
// bottomHeight changes, even when the outer size constraints are unchanged.
class _BodyBoxConstraints extends BoxConstraints {
  const _BodyBoxConstraints({
    super.minWidth,
    super.maxWidth,
    super.minHeight,
    super.maxHeight,
    required this.bottomHeight,
  }) : assert(bottomHeight >= 0, 'bottomHeight must be non-negative');

  // The measured height of the floating bottom slot.
  final double bottomHeight;

  @override
  bool operator ==(Object other) {
    if (super != other) return false;
    return other is _BodyBoxConstraints && other.bottomHeight == bottomHeight;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, bottomHeight);
}

// Measures the floating bottom, then lays the body out at full size annotated
// with the bottom's height via _BodyBoxConstraints, in a single pass.
class _StreamScaffoldBodyDelegate extends MultiChildLayoutDelegate {
  @override
  void performLayout(Size size) {
    final bottomSize = layoutChild(_Slot.bottom, BoxConstraints.loose(size));
    final bottomHeight = bottomSize.height;
    positionChild(_Slot.bottom, Offset(0, size.height - bottomHeight));

    // Tight constraints so a shrink-wrapping body fills the area instead of
    // sizing to its intrinsic extent.
    layoutChild(
      _Slot.body,
      _BodyBoxConstraints(
        minWidth: size.width,
        maxWidth: size.width,
        minHeight: size.height,
        maxHeight: size.height,
        bottomHeight: bottomHeight,
      ),
    );
    positionChild(_Slot.body, Offset.zero);
  }

  @override
  bool shouldRelayout(_StreamScaffoldBodyDelegate oldDelegate) => false;
}

// Composes the scaffold body with its optional bottom slot.
//
//  * No bottom -> the body fills the region.
//  * Regular bottom -> the body sits above it in a Column, never in the
//    Scaffold's bottomNavigationBar slot: that slot is not lifted above the
//    on-screen keyboard on Android and would hide a text-input composer behind
//    the IME.
//  * Floating bottom -> the bottom overlaps the body via a CustomMultiChildLayout
//    that measures its height and enlarges the body's MediaQuery padding so
//    scrollables clear it, in a single layout pass.
class _StreamScaffoldBody extends StatelessWidget {
  const _StreamScaffoldBody({
    required this.floating,
    required this.bottom,
    required this.child,
  }) : assert(!floating || bottom != null, 'A floating body requires a bottom widget.');

  final bool floating;
  final Widget? bottom;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!floating) {
      final bottom = this.bottom;
      if (bottom == null) return child;

      // The docked bottom sits below the body and owns the bottom safe-area
      // inset (it draws over the home indicator). Strip that inset from the body
      // so its scrollables rest on the bottom widget instead of reserving space
      // for the home indicator a second time.
      return Column(
        children: [
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeBottom: true,
              child: child,
            ),
          ),
          bottom,
        ],
      );
    }

    return CustomMultiChildLayout(
      delegate: _StreamScaffoldBodyDelegate(),
      children: [
        LayoutId(
          id: _Slot.body,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bottomHeight = constraints is _BodyBoxConstraints ? constraints.bottomHeight : 0.0;

              // Publish the floating bottom bar's height through
              // MediaQuery.padding.bottom so standard scrollables (ListView /
              // GridView) and SafeArea inset their content automatically. The top
              // inset already arrives through MediaQuery.padding.top when the app
              // bar floats, so only the bottom is added here. math.max never
              // shrinks an existing system inset.
              final mediaQuery = MediaQuery.of(context);
              final effectivePadding = mediaQuery.padding.copyWith(
                bottom: math.max(mediaQuery.padding.bottom, bottomHeight),
              );

              return MediaQuery(
                data: mediaQuery.copyWith(padding: effectivePadding),
                child: child,
              );
            },
          ),
        ),
        LayoutId(id: _Slot.bottom, child: bottom!),
      ],
    );
  }
}
