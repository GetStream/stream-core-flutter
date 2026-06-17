import 'package:flutter/material.dart';

import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/stream_app_style.dart';
import '../../theme/stream_theme_extensions.dart';

// ---------------------------------------------------------------------------
// InheritedWidget
// ---------------------------------------------------------------------------

/// Provides the effective top and bottom padding introduced by
/// [StreamScaffold] to its descendants.
///
/// When the scaffold's `appBar` is floating, [topPadding] equals the app-bar
/// height plus the system safe-area inset so that scrollable bodies can inset
/// their content below the bar without being clipped.  When the `bottom` slot
/// is floating, [bottomPadding] equals the measured height of that widget so
/// content clears it.
///
/// Read the values with [StreamScaffoldInsets.of] or
/// [StreamScaffoldInsets.maybeOf]:
///
/// ```dart
/// final insets = StreamScaffoldInsets.of(context);
/// StreamMessageListView(
///   topPadding: insets.topPadding,
///   bottomPadding: insets.bottomPadding,
/// )
/// ```
class StreamScaffoldInsets extends InheritedWidget {
  /// Creates an insets notification for the given [topPadding] and
  /// [bottomPadding].
  const StreamScaffoldInsets({
    super.key,
    required this.topPadding,
    required this.bottomPadding,
    required super.child,
  }) : assert(topPadding >= 0, 'topPadding must be non-negative'),
       assert(bottomPadding >= 0, 'bottomPadding must be non-negative');

  /// The vertical space (in logical pixels) occupied by the floating app bar
  /// at the top, including the system status-bar inset.
  ///
  /// `0.0` when the app bar is regular (not floating) or absent.
  final double topPadding;

  /// The vertical space (in logical pixels) occupied by the floating bottom
  /// widget, including any system home-indicator inset.
  ///
  /// `0.0` when the bottom widget is regular (not floating) or absent.
  final double bottomPadding;

  /// Returns the [StreamScaffoldInsets] from the closest ancestor, asserting
  /// that one exists.
  static StreamScaffoldInsets of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<StreamScaffoldInsets>();
    assert(result != null, 'No StreamScaffoldInsets found in widget tree');
    return result!;
  }

  /// Returns the [StreamScaffoldInsets] from the closest ancestor, or `null`
  /// when none is present.
  static StreamScaffoldInsets? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<StreamScaffoldInsets>();

  @override
  bool updateShouldNotify(StreamScaffoldInsets old) =>
      topPadding != old.topPadding || bottomPadding != old.bottomPadding;
}

// ---------------------------------------------------------------------------
// Main widget
// ---------------------------------------------------------------------------

/// A full-page scaffold for Stream surfaces that supports both regular and
/// floating app-bar / bottom-bar layouts.
///
/// [StreamScaffold] composes three slots — [appBar], [body], and [bottom] —
/// and injects an [StreamScaffoldInsets] into the widget tree so that scrollable
/// bodies can respect the visual extents of floating bars without knowing about
/// the layout directly.
///
/// ## Floating vs. regular
///
/// The behaviour of each slot is controlled by [StreamAppStyle]:
///
/// * `AppBarBehavior.floating` — the body extends *behind* the app bar;
///   [StreamScaffoldInsets.topPadding] is set to the bar height plus the
///   system status-bar inset so the body can add its own inset.
/// * `BottomBarBehavior.floating` — the body extends *behind* the bottom
///   widget; [StreamScaffoldInsets.bottomPadding] equals the measured height of
///   that widget.
/// * `regular` for either slot — no overlap; the slot occupies its own space
///   and the corresponding inset is `0.0`.
///
/// Per-instance [appBarBehavior] / [bottomBarBehavior] override the ambient
/// [StreamAppStyle] for this scaffold only.
///
/// ## Drawer support
///
/// [drawer] is forwarded to the underlying [Scaffold] so that widgets in
/// [appBar] (e.g. `StreamChannelListHeader`) can find the drawer via
/// `Scaffold.maybeOf(context)?.openDrawer()`.
///
/// ## InheritedWidget access
///
/// ```dart
/// // Inside body:
/// final insets = StreamScaffoldInsets.of(context);
/// StreamMessageListView(
///   topPadding: insets.topPadding,
///   bottomPadding: insets.bottomPadding,
/// );
/// ```
///
/// See also:
///
///  * [StreamScaffoldInsets], the inherited widget that carries the inset
///    values.
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
    this.endDrawer,
    this.appBarBehavior,
    this.bottomBarBehavior,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
  });

  /// An optional app bar displayed at the top of the scaffold.
  ///
  /// Must implement [PreferredSizeWidget] so the scaffold can read the height
  /// for inset calculations.
  final PreferredSizeWidget? appBar;

  /// The primary content of the scaffold.
  ///
  /// [StreamScaffoldInsets] is injected into this subtree so descendants can
  /// read the effective top and bottom insets.
  final Widget body;

  /// An optional widget displayed at the bottom of the scaffold.
  ///
  /// When [bottomBarBehavior] is [BottomBarBehavior.floating] this widget
  /// overlaps the body; otherwise it sits below it (equivalent to
  /// [Scaffold.bottomNavigationBar]).
  final Widget? bottom;

  /// A panel displayed to the side of the [body], often hidden on mobile
  /// devices. Swipes in from either [TextDirection.ltr] start side or
  /// [TextDirection.rtl] start side.
  ///
  /// Forwarded directly to the underlying [Scaffold].
  final Widget? drawer;

  /// A panel displayed to the opposite side of the body from the [drawer].
  ///
  /// Forwarded directly to the underlying [Scaffold].
  final Widget? endDrawer;

  /// Per-instance override for the app-bar floating behaviour.
  ///
  /// When null the value is read from the ambient [StreamAppStyle].
  final AppBarBehavior? appBarBehavior;

  /// Per-instance override for the bottom-bar floating behaviour.
  ///
  /// When null the value is read from the ambient [StreamAppStyle].
  final BottomBarBehavior? bottomBarBehavior;

  /// Background color of the scaffold.
  ///
  /// Defaults to [StreamColorScheme.backgroundApp].
  final Color? backgroundColor;

  /// Whether the scaffold should resize to avoid the on-screen keyboard.
  ///
  /// Defaults to `true`.
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    final appStyle = context.streamTheme.appStyle;
    final effectiveAppBarBehavior = appBarBehavior ?? appStyle.appBarBehavior;
    final effectiveBottomBarBehavior = bottomBarBehavior ?? appStyle.bottomBarBehavior;
    final effectiveBackgroundColor = backgroundColor ?? context.streamColorScheme.backgroundApp;

    final appBarFloating = effectiveAppBarBehavior == AppBarBehavior.floating;
    final bottomFloating = effectiveBottomBarBehavior == BottomBarBehavior.floating && bottom != null;

    final topInset = appBarFloating ? (appBar?.preferredSize.height ?? 0) + MediaQuery.paddingOf(context).top : 0.0;

    // When neither slot is floating, use a plain Scaffold for maximum
    // compatibility (e.g. keyboard avoidance, Scaffold.of, etc.).
    // The bottom widget lives inside the body Column (not bottomNavigationBar)
    // because bottomNavigationBar is not repositioned above the keyboard on
    // Android, which causes text-input composers to be hidden behind the IME.
    if (!appBarFloating && !bottomFloating) {
      return Scaffold(
        backgroundColor: effectiveBackgroundColor,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        appBar: appBar,
        drawer: drawer,
        endDrawer: endDrawer,
        body: Column(
          children: [
            Expanded(
              child: StreamScaffoldInsets(
                topPadding: 0,
                bottomPadding: 0,
                child: body,
              ),
            ),
            ?bottom,
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: effectiveBackgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      // The appBar always goes in the Scaffold's standard slot.
      // extendBodyBehindAppBar controls whether the body overlaps it (floating)
      // or sits below it (regular). Never drop it from the slot.
      appBar: appBar,
      drawer: drawer,
      endDrawer: endDrawer,
      extendBodyBehindAppBar: appBarFloating,
      extendBody: bottomFloating,
      // In regular-bottom mode, slot the bottom into the Scaffold normally.
      bottomNavigationBar: bottomFloating ? null : bottom,
      body: _StreamScaffoldBody(
        topInset: topInset,
        bottom: bottomFloating ? bottom : null,
        child: body,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Custom layout
// ---------------------------------------------------------------------------

/// Layout slot identifiers used by [_StreamScaffoldBodyDelegate].
enum _Slot { body, bottom }

/// Custom [BoxConstraints] that carries the measured [bottomHeight] so a
/// [LayoutBuilder] inside the body can read it synchronously within the same
/// layout pass.
///
/// [==] and [hashCode] are overridden to trigger a child re-layout whenever
/// [bottomHeight] changes, even when the outer size constraints are unchanged.
class _BodyBoxConstraints extends BoxConstraints {
  const _BodyBoxConstraints({
    super.maxWidth,
    super.maxHeight,
    required this.bottomHeight,
  }) : assert(bottomHeight >= 0, 'bottomHeight must be non-negative');

  /// The measured height of the floating bottom slot.
  final double bottomHeight;

  @override
  bool operator ==(Object other) {
    if (super != other) return false;
    return other is _BodyBoxConstraints && other.bottomHeight == bottomHeight;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, bottomHeight);
}

/// Measures the [bottom] slot first, then gives the [body] the full available
/// size annotated with the bottom height via [_BodyBoxConstraints].
class _StreamScaffoldBodyDelegate extends MultiChildLayoutDelegate {
  _StreamScaffoldBodyDelegate({required this.hasBottom});

  final bool hasBottom;

  @override
  void performLayout(Size size) {
    double bottomHeight = 0;
    if (hasBottom) {
      final bottomSize = layoutChild(_Slot.bottom, BoxConstraints.loose(size));
      bottomHeight = bottomSize.height;
      positionChild(_Slot.bottom, Offset(0, size.height - bottomHeight));
    }

    layoutChild(
      _Slot.body,
      _BodyBoxConstraints(
        maxWidth: size.width,
        maxHeight: size.height,
        bottomHeight: bottomHeight,
      ),
    );
    positionChild(_Slot.body, Offset.zero);
  }

  @override
  bool shouldRelayout(_StreamScaffoldBodyDelegate oldDelegate) => hasBottom != oldDelegate.hasBottom;
}

/// Wraps the user-supplied [body] and an optional floating [bottom] inside a
/// [CustomMultiChildLayout] that publishes the measured bottom height into
/// [StreamScaffoldInsets] in a single layout pass.
class _StreamScaffoldBody extends StatelessWidget {
  const _StreamScaffoldBody({
    required this.topInset,
    required this.bottom,
    required this.child,
  });

  final double topInset;
  final Widget? bottom;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final hasBottom = bottom != null;

    return CustomMultiChildLayout(
      delegate: _StreamScaffoldBodyDelegate(hasBottom: hasBottom),
      children: [
        LayoutId(
          id: _Slot.body,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bottomHeight = constraints is _BodyBoxConstraints ? constraints.bottomHeight : 0.0;
              return StreamScaffoldInsets(
                topPadding: topInset,
                bottomPadding: bottomHeight,
                child: child,
              );
            },
          ),
        ),
        if (hasBottom) LayoutId(id: _Slot.bottom, child: bottom!),
      ],
    );
  }
}
