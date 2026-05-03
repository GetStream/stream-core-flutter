import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../theme/components/stream_sheet_theme.dart';
import '../../theme/primitives/stream_colors.dart';
import '../../theme/primitives/stream_radius.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/stream_theme_extensions.dart';

// Minimum velocity (screen heights per second) for a downward fling
// to dismiss the sheet.
const _kMinFlingVelocity = 2.0;

// Settle duration when the user releases the sheet mid-swipe.
const _kSettleDuration = Duration(milliseconds: 300);

// Relax-back duration for the upward rubber-band stretch when the
// user releases after stretching.
const _kStretchSettleDuration = Duration(milliseconds: 180);

// Slide tween for a sheet entering the screen — fully below the
// bottom edge to its natural rest position.
final _kBottomUpTween = Tween<Offset>(
  begin: const Offset(0, 1),
  end: Offset.zero,
);

// Slide tween applied to a sheet that is becoming covered by another
// sheet. Shifts it up by half a percent of the screen height so the
// covered sheet feels like it's being tucked behind the foreground.
const _kStackedSheetMidUpRatio = 0.005;
final _kStackedSheetMidUpTween = Tween<Offset>(
  begin: Offset.zero,
  end: const Offset(0, -_kStackedSheetMidUpRatio),
);

// Scale tween applied to a sheet that is becoming covered by another
// sheet. Shrinks it slightly so the foreground reads as the active
// surface and the underlying sheet peeks at the lateral inset.
const _kStackedSheetScaleFactor = 0.0835;
final _kStackedSheetScaleTween = Tween<double>(
  begin: 1,
  end: 1 - _kStackedSheetScaleFactor,
);

/// Signature for a builder that takes a [BuildContext] and a [ScrollController]
/// to build a scrollable widget inside a [StreamSheetRoute].
typedef StreamSheetScrollableWidgetBuilder =
    Widget Function(
      BuildContext context,
      ScrollController scrollController,
    );

/// Called when the user begins dragging a [StreamSheetRoute].
typedef StreamSheetDragStartCallback = void Function(DragStartDetails details);

/// Called when the user stops dragging a [StreamSheetRoute].
///
/// The sheet may pop in response to the gesture (in which case
/// [isClosing] is `true`), or animate back to its open position.
typedef StreamSheetDragEndCallback = void Function(DragEndDetails details, {required bool isClosing});

/// Shows a Stream-styled modal sheet that slides up from the bottom of
/// the screen.
///
/// The [builder] receives a [ScrollController] that should be attached to
/// the topmost scrollable inside the sheet so dragging it past its top
/// edge dismisses the sheet (scroll-aware drag-to-dismiss). Non-
/// scrollable regions can also be dragged down to dismiss.
///
/// When [useNestedNavigation] is `true`, the sheet hosts its own
/// [Navigator]. Routes pushed from inside the sheet stay within it, and a
/// pop from the first nested route dismisses the entire sheet. The whole
/// sheet can also be popped at once via [StreamSheetRoute.popSheet].
///
/// Pushing a sheet from within another sheet stacks it: the underlying
/// sheet scales down slightly while the new one rests on top, and the
/// auto-implied [StreamSheetHeader] leading icon flips from cross to
/// back-chevron.
///
/// The sheet honours system insets — its top is clamped to a minimum of
/// [MediaQueryData.viewPadding] top so the header / drag handle clear
/// the status bar, and horizontal insets are honoured for landscape and
/// notched displays. The bottom inset is never applied, so the sheet
/// visually meets the bottom edge of the screen.
///
/// Style:
///
/// Each visual property follows the same resolution chain — the
/// per-call argument wins, then the ambient [StreamSheetThemeData]
/// (from [StreamTheme.sheetTheme] / [StreamSheetTheme]), then the
/// built-in fallback below.
///
///  * [shape] takes precedence over [borderRadius] when provided. When
///    both are null, the sheet's top corners are rounded with
///    [StreamRadius.xxxxl] and the bottom corners are square.
///  * [backgroundColor] defaults to
///    [StreamColorScheme.backgroundElevation1].
///  * [elevation] drives the shadow cast around the sheet. Defaults
///    to `1`.
///  * [clipBehavior] clips content against the border radius (defaults
///    to [Clip.none]).
///  * [constraints] caps the sheet's size — most useful on tablet /
///    desktop. The sheet is bottom-aligned within the constraints.
///    Defaults to `BoxConstraints(maxWidth: 640)`.
///
/// Dismissal:
///
///  * [enableDrag] (defaults to `true`) lets users pop the sheet by
///    dragging it down. The drag handle stays draggable even when
///    [enableDrag] is `false`, so the affordance never lies.
///  * [isDismissible] (defaults to `false`) lets users pop the sheet by
///    tapping the modal barrier. Pair with a non-null [barrierColor] to
///    give users a visible target.
///  * [showDragHandle] (defaults to `true`) reserves a drag handle at
///    the top of the sheet content.
///  * [onDragStart] / [onDragEnd] fire when the user starts / stops a
///    drag gesture; `isClosing` on [onDragEnd] indicates whether the
///    gesture will pop the sheet.
///
/// Routing:
///
///  * [useRootNavigator] (defaults to `false`) selects which [Navigator]
///    the sheet is pushed onto. Pass `true` to escape any nested
///    navigators and push to the root.
///  * [requestFocus] controls whether the sheet's first focusable
///    descendant requests focus when the route activates.
///  * [anchorPoint] is forwarded to a [DisplayFeatureSubScreen] so the
///    sheet avoids display features like foldable hinges.
///  * [settings] sets the [RouteSettings] of the underlying [PageRoute].
///
/// Returns a [Future] that resolves to the value (if any) passed to
/// [Navigator.pop] when the sheet is closed.
///
/// {@tool snippet}
///
/// A simple sheet with a title and a confirm action:
///
/// ```dart
/// final result = await showStreamSheet<String>(
///   context: context,
///   builder: (sheetContext, scrollController) => Column(
///     mainAxisSize: MainAxisSize.min,
///     children: [
///       StreamSheetHeader(
///         title: const Text('Edit profile'),
///         trailing: StreamButton.icon(
///           icon: Icon(context.streamIcons.checkmark),
///           onPressed: () => Navigator.of(sheetContext).pop('saved'),
///         ),
///       ),
///       // ... sheet contents
///     ],
///   ),
/// );
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamSheetRoute], the underlying route.
///  * [StreamSheetHeader], the auto-aware header component.
Future<T?> showStreamSheet<T>({
  required BuildContext context,
  required StreamSheetScrollableWidgetBuilder builder,
  Color? backgroundColor,
  Color? barrierColor,
  String? barrierLabel,
  ShapeBorder? shape,
  BorderRadiusGeometry? borderRadius,
  BoxConstraints? constraints,
  double? elevation,
  Clip? clipBehavior,
  bool enableDrag = true,
  bool isDismissible = false,
  bool? showDragHandle,
  bool useNestedNavigation = false,
  bool useRootNavigator = false,
  bool? requestFocus,
  Offset? anchorPoint,
  StreamSheetDragStartCallback? onDragStart,
  StreamSheetDragEndCallback? onDragEnd,
  RouteSettings? settings,
}) {
  assert(debugCheckHasMaterialLocalizations(context));

  final localizations = MaterialLocalizations.of(context);
  final sheetTheme = StreamSheetTheme.of(context);
  final defaults = _StreamSheetDefaults(context);
  final effectiveBuilder = useNestedNavigation ? _wrapWithNestedNavigator<T>(builder) : builder;

  // The nearest StreamSheetRoute above the current context, if any. We keep
  // the reference around so the new sheet can identify itself as a stacked
  // sheet (used by the auto-imply leading icon in [StreamSheetHeader] and
  // by [StreamSheetRoute.isStacked]).
  final parentSheet = _StreamSheetScope.maybeOf(context)?.route;

  final navigator = Navigator.of(context, rootNavigator: useRootNavigator);

  // Capture the calling context's [InheritedTheme]s (StreamTheme, Theme,
  // Directionality, MediaQuery overrides, etc.) and re-apply them inside
  // the route. The sheet is pushed onto the navigator's overlay, which
  // is typically *outside* any local theme overrides — without this
  // wrap, sheets pushed from a sub-tree with a custom theme would render
  // with the root theme.
  final capturedThemes = InheritedTheme.capture(from: context, to: navigator.context);

  return navigator.push<T>(
    StreamSheetRoute<T>(
      settings: settings,
      requestFocus: requestFocus,
      builder: effectiveBuilder,
      backgroundColor: backgroundColor,
      barrierColor: barrierColor ?? sheetTheme.barrierColor ?? defaults.barrierColor,
      barrierLabel: barrierLabel ?? localizations.scrimLabel,
      shape: shape,
      borderRadius: borderRadius,
      constraints: constraints,
      elevation: elevation,
      clipBehavior: clipBehavior,
      enableDrag: enableDrag,
      isDismissible: isDismissible,
      showDragHandle: showDragHandle,
      anchorPoint: anchorPoint,
      onDragStart: onDragStart,
      onDragEnd: onDragEnd,
      parentSheet: parentSheet,
      capturedThemes: capturedThemes,
    ),
  );
}

// Wraps [innerBuilder] in a nested [Navigator] so callers can push routes
// within the sheet. A [PopScope] on the initial route intercepts pops and
// dismisses the entire sheet via the root navigator.
StreamSheetScrollableWidgetBuilder _wrapWithNestedNavigator<T>(
  StreamSheetScrollableWidgetBuilder innerBuilder,
) {
  final nestedNavigatorKey = GlobalKey<NavigatorState>();
  return (context, scrollController) {
    return NavigatorPopHandler(
      onPopWithResult: (T? _) {
        nestedNavigatorKey.currentState!.maybePop();
      },
      child: Navigator(
        key: nestedNavigatorKey,
        initialRoute: '/',
        onGenerateInitialRoutes: (navigator, _) {
          return <Route<void>>[
            MaterialPageRoute<void>(
              builder: (context) {
                return PopScope(
                  canPop: false,
                  onPopInvokedWithResult: (didPop, _) {
                    if (didPop) return;
                    StreamSheetRoute.popSheet(context);
                  },
                  child: innerBuilder(context, scrollController),
                );
              },
            ),
          ];
        },
      ),
    );
  };
}

/// Slide-up transition used by [StreamSheetRoute].
///
/// Drives three animations:
///
///  * Primary — slides the sheet up from below the screen on push and
///    reverses on pop.
///  * Secondary — when another sheet is pushed on top, slides this sheet
///    slightly upward and scales it down so the foreground reads as the
///    active surface and the underlying sheet peeks at the lateral inset.
///  * Stretch — while the sheet is fully open, additional upward drag
///    extends the top edge a few pixels as a rubber-band effect that
///    relaxes back on release.
///
/// See also:
///
///  * [StreamSheetRoute], which uses this transition.
class StreamSheetTransition extends StatefulWidget {
  /// Creates a Stream-styled sheet transition.
  const StreamSheetTransition({
    super.key,
    required this.primaryRouteAnimation,
    required this.secondaryRouteAnimation,
    required this.child,
    required this.topPadding,
    this.linearTransition = false,
    this.isStacked = false,
  });

  /// Linear route animation from `0.0` to `1.0` when this sheet is being
  /// pushed (and the reverse when it is being popped).
  final Animation<double> primaryRouteAnimation;

  /// Linear route animation from `0.0` to `1.0` when another sheet is being
  /// pushed on top of this one (and the reverse when it is being popped).
  final Animation<double> secondaryRouteAnimation;

  /// The widget below this widget in the tree.
  final Widget child;

  /// The y-offset (in logical pixels) of this sheet's top edge,
  /// measured from the bottom of the system top inset (e.g. just below
  /// the status bar / notch — system insets are already consumed by
  /// the route's `SafeArea` wrap).
  ///
  /// Applied as a top padding wrapping the transforms — shrinks
  /// dynamically while the upward-stretch animation is active so the
  /// sheet's *bottom* stays at the screen edge while the top extends
  /// upward (rubber-band feel without leaving a gap at the bottom).
  final double topPadding;

  /// Whether to animate the sheet linearly. Set to `true` while a pop drag is
  /// in progress so the sheet tracks the finger.
  final bool linearTransition;

  /// Whether this sheet was pushed on top of another [StreamSheetRoute].
  ///
  /// Currently informational — both root and stacked sheets share the
  /// same primary slide-up tween (ending at rest, no bottom gap).
  /// Reserved for future per-depth transition tweaks if Stream's
  /// stacking design diverges from the root. Mirrors
  /// [StreamSheetRoute.isStacked].
  final bool isStacked;

  @override
  State<StreamSheetTransition> createState() => _StreamSheetTransitionState();
}

class _StreamSheetTransitionState extends State<StreamSheetTransition> with SingleTickerProviderStateMixin {
  // Drives the upward-stretch rubber band when the user keeps dragging up
  // past the sheet's open position. `0.0` is at rest, `1.0` is fully
  // stretched.
  late final AnimationController _stretchController;

  CurvedAnimation? _primaryCurve;
  CurvedAnimation? _secondaryCurve;

  late Animation<Offset> _primaryPositionAnimation;
  late Animation<Offset> _secondaryPositionAnimation;
  late Animation<double> _secondaryScaleAnimation;

  @override
  void initState() {
    super.initState();
    _stretchController = AnimationController(
      duration: const Duration(microseconds: 1),
      vsync: this,
    );
    _setupAnimations();
  }

  @override
  void didUpdateWidget(covariant StreamSheetTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.primaryRouteAnimation != widget.primaryRouteAnimation ||
        oldWidget.secondaryRouteAnimation != widget.secondaryRouteAnimation ||
        oldWidget.linearTransition != widget.linearTransition ||
        oldWidget.isStacked != widget.isStacked) {
      _disposeCurves();
      _setupAnimations();
    }
  }

  @override
  void dispose() {
    _stretchController.dispose();
    _disposeCurves();
    super.dispose();
  }

  void _setupAnimations() {
    _primaryCurve = CurvedAnimation(
      parent: widget.primaryRouteAnimation,
      curve: widget.linearTransition ? Curves.linear : Curves.fastEaseInToSlowEaseOut,
      reverseCurve: widget.linearTransition ? Curves.linear : Curves.fastEaseInToSlowEaseOut.flipped,
    );
    _primaryPositionAnimation = _primaryCurve!.drive(_kBottomUpTween);

    // Secondary transition (scale + slide-up) applies to every covered
    // sheet — produces the deck-of-cards effect when sheets stack. The
    // covered sheet scales down by 0.0835 around its top center and
    // slides up by 0.005 of its slot height.
    _secondaryCurve = CurvedAnimation(
      parent: widget.secondaryRouteAnimation,
      curve: Curves.linearToEaseOut,
      reverseCurve: Curves.easeInToLinear,
    );
    _secondaryPositionAnimation = _secondaryCurve!.drive(_kStackedSheetMidUpTween);
    _secondaryScaleAnimation = _secondaryCurve!.drive(_kStackedSheetScaleTween);
  }

  void _disposeCurves() {
    _primaryCurve?.dispose();
    _secondaryCurve?.dispose();
    _primaryCurve = null;
    _secondaryCurve = null;
  }

  @override
  Widget build(BuildContext context) {
    return _StreamSheetTransitionScope(
      stretchController: _stretchController,
      child: AnimatedBuilder(
        animation: _stretchController,
        builder: (context, child) {
          // Effective top padding wrapping the transforms — shrinks
          // when the user stretches up, growing the sheet's slot
          // height. The Padding sits *outside* the ScaleTransition so
          // the gap stays constant when the sheet is covered.
          //
          // The system top inset is already consumed by the route's
          // `SafeArea(bottom: false)` wrap (see `buildPage`), so this
          // padding is purely the design-system peek (`topPadding`)
          // minus the active rubber-band stretch.
          final stretchAmount = context.streamSpacing.xs;
          final stretchedTop = widget.topPadding - _stretchController.value * stretchAmount;
          return Padding(
            padding: EdgeInsets.only(top: math.max(0, stretchedTop)),
            child: child,
          );
        },
        child: SlideTransition(
          position: _secondaryPositionAnimation,
          transformHitTests: false,
          child: ScaleTransition(
            scale: _secondaryScaleAnimation,
            filterQuality: FilterQuality.medium,
            alignment: Alignment.topCenter,
            child: SlideTransition(
              position: _primaryPositionAnimation,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

// InheritedWidget hosting the transition's per-instance state (stretch
// controller + drag handle WidgetState notifier) so descendants — drag
// gesture detectors, scroll position — can reach it without threading
// the reference through every widget.
class _StreamSheetTransitionScope extends InheritedWidget {
  const _StreamSheetTransitionScope({
    required this.stretchController,
    required super.child,
  });

  final AnimationController stretchController;

  static _StreamSheetTransitionScope? maybeOf(BuildContext context) {
    return context.getInheritedWidgetOfExactType<_StreamSheetTransitionScope>();
  }

  @override
  bool updateShouldNotify(_StreamSheetTransitionScope oldWidget) {
    return stretchController != oldWidget.stretchController;
  }
}

/// The visual chrome of a Stream-styled sheet.
///
/// Renders [child] on the design system's sheet surface — rounded top
/// corners, [StreamColorScheme.backgroundElevation1] background,
/// elevation `1`, and anti-aliased clipping. Each visual property
/// follows the same resolution chain — the per-instance argument wins,
/// then [StreamSheetThemeData] (from [StreamTheme.sheetTheme] or a
/// nearer [StreamSheetTheme]), then the built-in fallback.
///
/// Used by [StreamSheetRoute] to render the sheet's surface; can also
/// be used standalone when a sheet-like surface is needed outside a
/// modal route. The widget is purely visual — it does *not* implement
/// drag-to-dismiss (that's the route's job) and does *not* render a
/// drag handle (compose [StreamSheetDragHandle] over [child] when
/// needed).
///
/// {@tool snippet}
///
/// A standalone sheet surface:
///
/// ```dart
/// StreamSheet(
///   constraints: BoxConstraints(maxWidth: 480),
///   child: Column(
///     mainAxisSize: MainAxisSize.min,
///     children: [
///       StreamSheetHeader(title: Text('Details')),
///       // ... contents
///     ],
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamSheetThemeData], which describes the configurable properties
///    and their defaults.
///  * [StreamSheetRoute] / [showStreamSheet], the modal route that uses
///    this widget.
///  * [StreamSheetDragHandle], the visual handle drawn at the top of a
///    modal sheet.
class StreamSheet extends StatelessWidget {
  /// Creates a Stream-styled sheet surface.
  const StreamSheet({
    super.key,
    required this.child,
    this.backgroundColor,
    this.surfaceTintColor,
    this.shadowColor,
    this.elevation,
    this.shape,
    this.borderRadius,
    this.clipBehavior,
    this.constraints,
  });

  /// The widget below this widget in the tree — typically the body of
  /// the sheet.
  final Widget child;

  /// The background color of the sheet.
  ///
  /// When `null`, falls back to [StreamSheetThemeData.backgroundColor]
  /// and finally to [StreamColorScheme.backgroundElevation1].
  final Color? backgroundColor;

  /// The surface tint color used as an overlay on the sheet's
  /// background.
  ///
  /// When `null`, falls back to [StreamSheetThemeData.surfaceTintColor].
  /// If still `null`, no overlay color is drawn.
  final Color? surfaceTintColor;

  /// The shadow color cast around the sheet.
  ///
  /// When `null`, falls back to [StreamSheetThemeData.shadowColor].
  final Color? shadowColor;

  /// The elevation of the sheet.
  ///
  /// When `null`, falls back to [StreamSheetThemeData.elevation] and
  /// finally to `1`.
  final double? elevation;

  /// The shape applied to the sheet.
  ///
  /// Takes precedence over [borderRadius] when non-null. When `null`,
  /// falls back to [StreamSheetThemeData.shape].
  final ShapeBorder? shape;

  /// The border radius applied to the sheet.
  ///
  /// Ignored when an effective [shape] is in effect. When `null`, falls
  /// back to [StreamSheetThemeData.borderRadius] and finally to a
  /// top-corner [StreamRadius.xxxxl] radius and square bottom corners.
  final BorderRadiusGeometry? borderRadius;

  /// How to clip the sheet's content against its [shape] / [borderRadius].
  ///
  /// When `null`, falls back to [StreamSheetThemeData.clipBehavior] and
  /// finally to [Clip.none].
  final Clip? clipBehavior;

  /// Optional [BoxConstraints] applied around the sheet.
  ///
  /// Most useful on tablet/desktop to cap the sheet's width. The sheet
  /// is bottom-aligned within the constraints. When `null`, falls back
  /// to [StreamSheetThemeData.constraints] and finally to
  /// `BoxConstraints(maxWidth: 640)`.
  final BoxConstraints? constraints;

  @override
  Widget build(BuildContext context) {
    final sheetTheme = StreamSheetTheme.of(context);
    final defaults = _StreamSheetDefaults(context);

    final effectiveElevation = elevation ?? sheetTheme.elevation ?? defaults.elevation;
    final effectiveBackgroundColor = backgroundColor ?? sheetTheme.backgroundColor ?? defaults.backgroundColor;
    final effectiveSurfaceTintColor = surfaceTintColor ?? sheetTheme.surfaceTintColor ?? defaults.surfaceTintColor;
    final effectiveShadowColor = shadowColor ?? sheetTheme.shadowColor ?? defaults.shadowColor;
    final effectiveShape = shape ?? sheetTheme.shape ?? defaults.shape;
    // [borderRadius] is ignored when an explicit shape is in effect.
    final effectiveBorderRadius = borderRadius ?? sheetTheme.borderRadius ?? defaults.borderRadius;
    final effectiveClipBehavior = clipBehavior ?? sheetTheme.clipBehavior ?? defaults.clipBehavior;
    final effectiveConstraints = constraints ?? sheetTheme.constraints ?? defaults.constraints;

    return Align(
      heightFactor: 1,
      alignment: .bottomCenter,
      child: ConstrainedBox(
        constraints: effectiveConstraints,
        child: Material(
          shape: effectiveShape,
          clipBehavior: effectiveClipBehavior,
          elevation: effectiveElevation,
          color: effectiveBackgroundColor,
          surfaceTintColor: effectiveSurfaceTintColor,
          shadowColor: effectiveShadowColor,
          borderRadius: effectiveBorderRadius,
          child: child,
        ),
      ),
    );
  }
}

/// Modal route for a Stream-styled sheet.
///
/// The sheet slides up from the bottom of the screen and rests just
/// below the top with a small fixed peek of [StreamSpacing.sm]. Users
/// can dismiss it by dragging downwards or via [popSheet].
///
/// Typically created by [showStreamSheet].
///
/// See also:
///
///  * [showStreamSheet], the convenience entry point.
///  * [StreamSheet], the widget rendering the sheet's visual chrome.
///  * [StreamSheetTransition], the slide-up transition the route uses.
///  * [StreamSheetHeader], the auto-aware header component.
class StreamSheetRoute<T> extends PageRoute<T> {
  /// Creates a [StreamSheetRoute].
  StreamSheetRoute({
    super.settings,
    super.requestFocus,
    required this.builder,
    this.backgroundColor,
    Color? barrierColor,
    this.barrierLabel,
    this.shape,
    this.borderRadius,
    this.constraints,
    this.elevation,
    this.clipBehavior,
    this.enableDrag = true,
    this.isDismissible = false,
    this.showDragHandle,
    this.anchorPoint,
    this.onDragStart,
    this.onDragEnd,
    this.parentSheet,
    this.capturedThemes,
  }) : _barrierColor = barrierColor;

  /// Builds the primary contents of the sheet. The provided [ScrollController]
  /// should be attached to the topmost scrollable widget inside the sheet.
  final StreamSheetScrollableWidgetBuilder builder;

  /// The background color of the sheet.
  ///
  /// When `null`, defaults to [StreamColorScheme.backgroundElevation1].
  final Color? backgroundColor;

  // Private storage so we can override [ModalRoute.barrierColor] while still
  // accepting a constructor argument with the same name.
  final Color? _barrierColor;

  /// The shape applied to the sheet.
  ///
  /// Takes precedence over [borderRadius] when non-null. Useful for
  /// non-rectangular sheets (e.g. with a clipped notch) where a plain
  /// [BorderRadiusGeometry] isn't expressive enough.
  final ShapeBorder? shape;

  /// The border radius applied to the sheet.
  ///
  /// Ignored when [shape] is non-null. When both are `null`, defaults to
  /// a top-corner [StreamRadius.xxxxl] radius and square bottom corners.
  final BorderRadiusGeometry? borderRadius;

  /// Optional [BoxConstraints] applied around the sheet.
  ///
  /// Most useful on tablet/desktop to cap the sheet's width. The sheet is
  /// bottom-aligned within the constraints.
  final BoxConstraints? constraints;

  /// The elevation of the sheet.
  ///
  /// Drives the shadow cast around the sheet — most visible at the top
  /// edge, where the sheet meets the content behind it.
  final double? elevation;

  /// How to clip the sheet's content against its [shape] / [borderRadius].
  ///
  /// When `null`, falls back to [StreamSheetThemeData.clipBehavior] and
  /// finally to [Clip.antiAlias] for smooth rounded corners.
  final Clip? clipBehavior;

  /// Whether the sheet body can be dismissed by dragging it down.
  ///
  /// Even when this is `false`, the drag handle (if [showDragHandle] is
  /// `true`) remains draggable so the visible affordance never lies.
  final bool enableDrag;

  /// Whether tapping the modal barrier dismisses the sheet.
  ///
  /// Defaults to `false`. Pair with a non-`null` [barrierColor] to give
  /// users a visible target to tap.
  final bool isDismissible;

  /// Whether to display a drag handle at the top of the sheet content.
  ///
  /// When `true`, the handle is overlaid at the top of the sheet's body
  /// just under the rounded top corners. The body should leave space
  /// for it (e.g. by starting with [StreamSheetHeader]) — the handle
  /// itself doesn't reserve layout room.
  ///
  /// When `null`, falls back to [StreamSheetThemeData.showDragHandle]
  /// and finally to `true`.
  final bool? showDragHandle;

  /// {@macro flutter.widgets.DisplayFeatureSubScreen.anchorPoint}
  final Offset? anchorPoint;

  /// Called when the user begins dragging the sheet vertically.
  final StreamSheetDragStartCallback? onDragStart;

  /// Called when the user stops dragging the sheet vertically.
  ///
  /// The `isClosing` flag indicates whether the sheet will pop in
  /// response to the gesture (either because of a downward fling or
  /// because the drag passed the close threshold).
  final StreamSheetDragEndCallback? onDragEnd;

  /// The [StreamSheetRoute] this sheet was pushed on top of, if any.
  ///
  /// Used to compute the foreground sheet's top padding so it sits exactly
  /// `spacing.sm` below the parent sheet's transformed top edge — and to
  /// drive the auto-imply leading icon in [StreamSheetHeader] (a stacked
  /// sheet shows a back chevron instead of a close icon).
  ///
  /// Set automatically by [showStreamSheet] using the nearest enclosing
  /// [StreamSheetRoute].
  final StreamSheetRoute<dynamic>? parentSheet;

  /// [InheritedTheme]s captured from the calling context, re-applied
  /// inside the sheet via [CapturedThemes.wrap] in [buildPage].
  ///
  /// The sheet is pushed onto the navigator's overlay, which is
  /// typically *outside* any local theme overrides (a `StreamTheme`
  /// or `Theme` set in a sub-tree, a `Directionality.rtl`, etc.).
  /// Capturing the calling context's inherited widgets and re-wrapping
  /// the sheet ensures it renders with the same theme as the caller.
  ///
  /// Set automatically by [showStreamSheet]. Pass `null` to disable.
  final CapturedThemes? capturedThemes;

  /// Whether this sheet was pushed on top of another [StreamSheetRoute].
  ///
  /// Stacked sheets render a back-chevron in their auto-implied
  /// [StreamSheetHeader] leading slot (popping reveals the parent
  /// sheet); root sheets render a close-cross (popping dismisses the
  /// sheet entirely).
  bool get isStacked => parentSheet != null;

  /// The y-offset (in logical pixels) of this sheet's top edge at
  /// rest, measured from the bottom of the system top inset.
  ///
  /// Resolves to a fixed [StreamSpacing.sm] for both root and stacked
  /// sheets — the design-system peek between the sheet and the system
  /// top inset (status bar / notch). The system inset itself is
  /// consumed by the route's `SafeArea` wrap, so the sheet visually
  /// rests at `viewPadding.top + topPaddingFor(context)`.
  double topPaddingFor(BuildContext context) {
    return context.streamSpacing.sm;
  }

  /// Falls back to the standard modal-sheet [Colors.black54] scrim
  /// when no `barrierColor` is provided. [showStreamSheet] instead
  /// resolves [StreamSheetThemeData.barrierColor] (defaulting to
  /// [StreamColorScheme.backgroundScrim]) from the calling context.
  @override
  Color? get barrierColor => _barrierColor ?? Colors.black54;

  @override
  bool get barrierDismissible => isDismissible;

  @override
  final String? barrierLabel;

  @override
  bool get maintainState => true;

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 500);

  // We only forward the secondaryAnimation (and therefore animate the
  // stacked-sheet scale + slide on the previous sheet) when another
  // [StreamSheetRoute] is being pushed on top of this one. Pushing a
  // regular [PageRoute] over a sheet leaves the sheet untouched.
  //
  // For non-sheet previous routes, [delegatedTransition] takes over and
  // animates them out of the way as this sheet rises.
  // Sheet-over-sheet stacking goes through the previous sheet's
  // `buildTransitions` (via `secondaryAnimation`) rather than the
  // delegated transition — that's how the deck-of-cards effect lands on
  // every covered sheet. The non-sheet route below the first sheet
  // intentionally stays still: we don't override `delegatedTransition`,
  // so a regular page underneath isn't transformed when the sheet rises
  // over it.
  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) {
    return nextRoute is StreamSheetRoute;
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final content = _StreamDraggableScrollableSheet(
      enableDrag: () => enableDrag,
      popDragController: controller!,
      navigator: navigator!,
      getIsCurrent: () => isCurrent,
      getIsActive: () => isActive,
      builder: _buildBodyWithDragHandle,
    );

    Widget sheet = StreamSheet(
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      borderRadius: borderRadius,
      clipBehavior: clipBehavior,
      constraints: constraints,
      child: _StreamSheetScope(route: this, child: content),
    );

    // System-inset handling. A single `SafeArea(bottom: false)`
    // consumes the top, left, and right system insets *and* strips
    // them from `MediaQuery` for descendants — so any inner
    // `SafeArea` / `StreamSheetHeader` inside the sheet does not
    // re-pad the status bar / notch.
    //
    // Bottom is intentionally retained so descendants can opt-in to
    // the home-indicator / keyboard inset via their own
    // `SafeArea(bottom: true)`.
    //
    // On top of this, the transition's animated `Padding` adds the
    // design-system peek (`topPadding`) plus the rubber-band stretch.
    sheet = SafeArea(bottom: false, child: sheet);

    sheet = DisplayFeatureSubScreen(
      anchorPoint: anchorPoint,
      child: sheet,
    );

    // Re-apply captured InheritedThemes (StreamTheme, Theme,
    // Directionality, etc.) so the sheet renders with the same
    // ambient theme as the calling context, even though it's pushed
    // onto the navigator's overlay above any local theme overrides.
    return capturedThemes?.wrap(sheet) ?? sheet;
  }

  /// The nearest enclosing [StreamSheetRoute] for [context], or `null`
  /// if [context] isn't inside any sheet.
  ///
  /// Walks the widget tree via the InheritedWidget set up in
  /// [buildPage]. Use this from anything inside a sheet that needs to
  /// react to the sheet's identity (auto-implied headers, drag
  /// handles, body content, etc.) — e.g.:
  ///
  /// ```dart
  /// final sheet = StreamSheetRoute.maybeOf(context);
  /// if (sheet != null && sheet.isStacked) {
  ///   // Render a back chevron etc.
  /// }
  /// ```
  ///
  /// Continues to find the enclosing sheet even when [context] is
  /// inside a sheet's nested navigator (see `useNestedNavigation` on
  /// [showStreamSheet]).
  static StreamSheetRoute<dynamic>? maybeOf(BuildContext context) {
    return _StreamSheetScope.maybeOf(context)?.route;
  }

  /// Whether [context] is currently inside a [StreamSheetRoute].
  ///
  /// Convenience wrapper over [maybeOf]. Equivalent to
  /// `maybeOf(context) != null`.
  static bool hasParentSheet(BuildContext context) {
    return maybeOf(context) != null;
  }

  /// Whether the enclosing [StreamSheetRoute] for [context] is itself
  /// stacked over another sheet.
  ///
  /// Convenience wrapper over [maybeOf]. Equivalent to
  /// `maybeOf(context)?.isStacked ?? false`.
  static bool inStackedSheet(BuildContext context) {
    return maybeOf(context)?.isStacked ?? false;
  }

  /// Pops the entire enclosing [StreamSheetRoute], if one is in the stack.
  ///
  /// Useful when the sheet uses nested navigation (see the
  /// `useNestedNavigation` parameter on [showStreamSheet]) and you want to
  /// dismiss the whole sheet at once instead of just the current nested
  /// route.
  static void popSheet(BuildContext context) {
    final scope = _StreamSheetScope.maybeOf(context);
    final route = scope?.route;
    if (route == null) return;
    final navigator = route.navigator;
    if (navigator == null) return;
    if (navigator.canPop()) navigator.pop();
  }

  Widget _buildBodyWithDragHandle(
    BuildContext context,
    ScrollController scrollController,
  ) {
    final body = builder(context, scrollController);
    final sheetTheme = StreamSheetTheme.of(context);
    final defaults = _StreamSheetDefaults(context);
    final effectiveShowDragHandle = showDragHandle ?? sheetTheme.showDragHandle ?? defaults.showDragHandle;
    if (!effectiveShowDragHandle) return body;

    final spacing = context.streamSpacing;

    Widget handle = Padding(
      padding: EdgeInsets.only(top: spacing.xxs),
      child: const StreamSheetDragHandle(),
    );

    // When the body isn't draggable, the visible drag handle still must
    // be — otherwise the affordance lies. Wrap just the handle in its
    // own gesture detector so it pops the sheet via the route's drag
    // controller.
    if (!enableDrag) {
      handle = _StreamDragGestureDetector(
        enabledCallback: () => true,
        onStartPopGesture: _startPopGesture,
        onDragStart: onDragStart,
        onDragEnd: onDragEnd,
        child: handle,
      );
    }

    // The drag handle floats over the top of the body with a tiny
    // offset. Stream's chrome (sheet header, etc.) is expected to leave
    // space at the top for the handle.
    //
    // The Stack uses the default [StackFit.loose] (and *not*
    // [StackFit.expand]) so the body's intrinsic height is preserved —
    // a body that uses [MainAxisSize.min] correctly shrink-wraps the
    // sheet, while a body that wants to fill the screen still does so
    // via [Expanded] / [MainAxisSize.max] from inside.
    //
    // The handle is placed via the Stack's [alignment] (rather than a
    // child [Align]) so it doesn't expand to fill loose constraints —
    // its natural 36×9 size is used and positioned at top-center of the
    // Stack, which makes the body's size determine the Stack's size.
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[body, handle],
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return StreamSheetTransition(
      primaryRouteAnimation: animation,
      secondaryRouteAnimation: secondaryAnimation,
      linearTransition: popGestureInProgress,
      isStacked: isStacked,
      topPadding: topPaddingFor(context),
      child: _StreamDragGestureDetector(
        enabledCallback: () => enableDrag,
        onStartPopGesture: _startPopGesture,
        onDragStart: onDragStart,
        onDragEnd: onDragEnd,
        child: child,
      ),
    );
  }

  _StreamDragGestureController _startPopGesture() {
    return _StreamDragGestureController(
      navigator: navigator!,
      popDragController: controller!,
      getIsCurrent: () => isCurrent,
      getIsActive: () => isActive,
    );
  }
}

/// The visual drag handle drawn at the top of a Stream-styled sheet.
///
/// A small pill-shaped indicator that signals the sheet can be
/// dismissed by dragging. Wrapped in a [Semantics] node so assistive
/// technology can dismiss the enclosing sheet by tapping the handle —
/// the tap targets the enclosing [StreamSheetRoute] (via
/// [StreamSheetRoute.maybeOf]) so a nested navigator inside the sheet
/// can't intercept it, and falls back to the nearest [Navigator] when
/// the handle is composed outside a [StreamSheetRoute].
///
/// The handle's color and size resolve from
/// [StreamSheetThemeData.dragHandleColor] /
/// [StreamSheetThemeData.dragHandleSize], with built-in fallbacks of
/// [StreamColorScheme.accentNeutral] and a `36 × 5` pill.
///
/// Used by [StreamSheetRoute] internally; can also be composed by
/// callers when building custom sheet content.
class StreamSheetDragHandle extends StatelessWidget {
  /// Creates a Stream-styled sheet drag handle.
  const StreamSheetDragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final radius = context.streamRadius;
    final sheetTheme = StreamSheetTheme.of(context);
    final defaults = _StreamSheetDefaults(context);
    final localizations = MaterialLocalizations.of(context);

    final size = sheetTheme.dragHandleSize ?? defaults.dragHandleSize;
    final color = sheetTheme.dragHandleColor ?? defaults.dragHandleColor;

    return Semantics(
      label: localizations.modalBarrierDismissLabel,
      container: true,
      button: true,
      onTap: () {
        // Prefer dismissing the enclosing sheet route directly so a
        // nested navigator inside the sheet (see `useNestedNavigation`
        // on [showStreamSheet]) can't swallow the dismiss. Fall back to
        // the nearest [Navigator] when the handle is composed outside
        // a [StreamSheetRoute].
        final route = StreamSheetRoute.maybeOf(context);
        final navigator = route?.navigator ?? Navigator.maybeOf(context);
        navigator?.maybePop();
      },
      child: Container(
        height: size.height,
        width: size.width,
        decoration: ShapeDecoration(
          color: color,
          shape: RoundedSuperellipseBorder(
            borderRadius: .all(radius.max),
          ),
        ),
      ),
    );
  }
}

class _StreamDragGestureDetector extends StatefulWidget {
  const _StreamDragGestureDetector({
    required this.enabledCallback,
    required this.onStartPopGesture,
    required this.child,
    this.onDragStart,
    this.onDragEnd,
  });

  final Widget child;
  final ValueGetter<bool> enabledCallback;
  final ValueGetter<_StreamDragGestureController> onStartPopGesture;
  final StreamSheetDragStartCallback? onDragStart;
  final StreamSheetDragEndCallback? onDragEnd;

  @override
  State<_StreamDragGestureDetector> createState() => _StreamDragGestureDetectorState();
}

class _StreamDragGestureDetectorState extends State<_StreamDragGestureDetector> {
  _StreamDragGestureController? _dragGestureController;
  late final VerticalDragGestureRecognizer _recognizer;

  _StreamSheetTransitionScope? _transitionScope;

  @override
  void initState() {
    super.initState();
    _recognizer = VerticalDragGestureRecognizer(debugOwner: this)
      // Use the fling-aware velocity tracker so end-of-drag velocities
      // are weighted toward the most recent samples, matching the feel
      // of a flick gesture closing the sheet.
      ..velocityTrackerBuilder = _flingVelocityBuilder
      ..onStart = _handleDragStart
      ..onUpdate = _handleDragUpdate
      ..onEnd = _handleDragEnd
      ..onCancel = _handleDragCancel;
  }

  static VelocityTracker _flingVelocityBuilder(PointerEvent event) => IOSScrollViewFlingVelocityTracker(event.kind);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _transitionScope = _StreamSheetTransitionScope.maybeOf(context);
  }

  @override
  void dispose() {
    _recognizer.dispose();
    if (_dragGestureController != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_dragGestureController?.navigator.mounted ?? false) {
          _dragGestureController?.navigator.didStopUserGesture();
        }
        _dragGestureController = null;
      });
    }
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    assert(mounted);
    assert(_dragGestureController == null);
    _dragGestureController = widget.onStartPopGesture();
    widget.onDragStart?.call(details);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    assert(mounted);
    assert(_dragGestureController != null);
    final size = context.size;
    if (size == null || size.height <= 0) return;
    _dragGestureController?.dragUpdate(
      details.primaryDelta!,
      sheetHeight: size.height,
      stretchPixels: context.streamSpacing.xs,
      stretchController: _transitionScope?.stretchController,
    );
  }

  void _handleDragEnd(DragEndDetails details) {
    assert(mounted);
    assert(_dragGestureController != null);
    final size = context.size;
    final velocity = size != null && size.height > 0 ? details.velocity.pixelsPerSecond.dy / size.height : 0.0;
    final isClosing =
        _dragGestureController?.dragEnd(
          velocity,
          _transitionScope?.stretchController,
        ) ??
        false;
    _dragGestureController = null;
    widget.onDragEnd?.call(details, isClosing: isClosing);
  }

  void _handleDragCancel() {
    assert(mounted);
    // [VerticalDragGestureRecognizer] can fire `onCancel` even when no
    // `onStart` preceded it (paired with the initial "down" event); the
    // null-aware call below tolerates that case.
    _dragGestureController?.dragEnd(0, _transitionScope?.stretchController);
    _dragGestureController = null;
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (widget.enabledCallback()) {
      _recognizer.addPointer(event);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _handlePointerDown,
      behavior: HitTestBehavior.translucent,
      child: widget.child,
    );
  }
}

class _StreamDragGestureController {
  _StreamDragGestureController({
    required this.navigator,
    required this.popDragController,
    required this.getIsCurrent,
    required this.getIsActive,
  }) {
    navigator.didStartUserGesture();
  }

  final NavigatorState navigator;
  final AnimationController popDragController;
  final ValueGetter<bool> getIsCurrent;
  final ValueGetter<bool> getIsActive;

  /// Applies a vertical pixel drag delta (`+y` is downward).
  /// [sheetHeight] is the sheet content's rendered height (used to
  /// normalise the pop animation), and [stretchPixels] is the rubber-
  /// band's full-stretch range (typically `spacing.sm`).
  ///
  /// When the sheet is fully open and the finger keeps moving up,
  /// drives [stretchController] (if provided) to produce the rubber-band
  /// stretch effect. Otherwise updates the sheet's pop animation as
  /// usual.
  void dragUpdate(
    double pixelsDelta, {
    required double sheetHeight,
    required double stretchPixels,
    AnimationController? stretchController,
  }) {
    if (sheetHeight <= 0) return;
    var remaining = pixelsDelta;

    // Rubber-band: only kicks in once the sheet is fully open and the
    // user is still dragging up.
    if (popDragController.value >= 1.0 && remaining < 0 && stretchController != null) {
      if (stretchPixels > 0) {
        stretchController.value = (stretchController.value - remaining / stretchPixels).clamp(0.0, 1.0);
      }
      return;
    }

    // If the user is now dragging back down out of a stretched state,
    // unwind the stretch first before touching the pop controller.
    if (stretchController != null && stretchController.value > 0 && remaining > 0 && stretchPixels > 0) {
      final prev = stretchController.value;
      final next = (prev - remaining / stretchPixels).clamp(0.0, 1.0);
      stretchController.value = next;
      if (next > 0) return;
      // Carry over any leftover delta after unwinding the stretch.
      remaining -= prev * stretchPixels;
    }

    popDragController.value -= remaining / sheetHeight;
  }

  /// Whether the sheet is currently dragged below its fully-open position
  /// (i.e. partially dismissed).
  bool isDragged() => popDragController.value != 1.0;

  /// Ends the drag with a vertical velocity (in fractions of screen height
  /// per second). Either pops the route or animates it back to fully open.
  ///
  /// Returns whether the gesture caused the sheet to close.
  bool dragEnd(double velocity, [AnimationController? stretchController]) {
    // Relax the rubber-band stretch back to 0 before deciding pop/keep.
    if (stretchController != null && stretchController.value > 0) {
      stretchController.animateTo(
        0,
        duration: _kStretchSettleDuration,
        curve: Curves.easeOut,
      );
      navigator.didStopUserGesture();
      return false;
    }

    const animationCurve = Curves.easeOut;
    final isCurrent = getIsCurrent();
    final bool animateForward;

    if (!isCurrent) {
      animateForward = getIsActive();
    } else if (velocity.abs() >= _kMinFlingVelocity) {
      animateForward = velocity <= 0;
    } else {
      animateForward = popDragController.value > 0.52;
    }

    if (animateForward) {
      popDragController.animateTo(
        1,
        duration: _kSettleDuration,
        curve: animationCurve,
      );
    } else {
      if (isCurrent) navigator.pop();
      if (popDragController.isAnimating) {
        popDragController.animateBack(
          0,
          duration: _kSettleDuration,
          curve: animationCurve,
        );
      }
    }

    if (popDragController.isAnimating) {
      void animationStatusCallback(AnimationStatus status) {
        navigator.didStopUserGesture();
        popDragController.removeStatusListener(animationStatusCallback);
      }

      popDragController.addStatusListener(animationStatusCallback);
    } else {
      navigator.didStopUserGesture();
    }

    return !animateForward;
  }
}

// Wires the [ScrollController] forwarded to the sheet's body to the
// route's drag-to-dismiss controller, so dragging a scroll view past
// its top edge dismisses the sheet. Owns the lifecycle of a
// [_StreamDragGestureController] for the scroll-driven path; the
// gesture-detector path on the sheet's chrome owns its own.
class _StreamDraggableScrollableSheet extends StatefulWidget {
  const _StreamDraggableScrollableSheet({
    required this.enableDrag,
    required this.popDragController,
    required this.navigator,
    required this.getIsCurrent,
    required this.getIsActive,
    required this.builder,
  });

  final ValueGetter<bool> enableDrag;
  final AnimationController popDragController;
  final NavigatorState navigator;
  final ValueGetter<bool> getIsCurrent;
  final ValueGetter<bool> getIsActive;
  final StreamSheetScrollableWidgetBuilder builder;

  @override
  State<_StreamDraggableScrollableSheet> createState() => _StreamDraggableScrollableSheetState();
}

class _StreamDraggableScrollableSheetState extends State<_StreamDraggableScrollableSheet> {
  late final _StreamSheetScrollController _scrollController;
  _StreamDragGestureController? _dragGestureController;

  @override
  void initState() {
    super.initState();
    _scrollController = _StreamSheetScrollController(
      onDragStart: _handleDragStart,
      onDragUpdate: _handleDragUpdate,
      onDragEnd: _handleDragEnd,
      sheetIsDraggedDown: () => _dragGestureController?.isDragged() ?? false,
    );
  }

  @override
  void dispose() {
    // If we're still mid-drag, balance the navigator's user-gesture
    // counter post-frame so we don't leave it dangling.
    if (_dragGestureController != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.navigator.mounted) widget.navigator.didStopUserGesture();
        _dragGestureController = null;
      });
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _handleDragStart() {
    assert(mounted);
    if (!widget.enableDrag()) return;
    _dragGestureController ??= _StreamDragGestureController(
      navigator: widget.navigator,
      popDragController: widget.popDragController,
      getIsCurrent: widget.getIsCurrent,
      getIsActive: widget.getIsActive,
    );
  }

  void _handleDragUpdate(double delta) {
    assert(mounted);
    final dragController = _dragGestureController;
    if (dragController == null) return;
    final size = context.size;
    if (size == null || size.height <= 0) return;
    dragController.dragUpdate(
      delta,
      sheetHeight: size.height,
      stretchPixels: context.streamSpacing.xs,
    );
  }

  void _handleDragEnd(double velocity) {
    assert(mounted);
    final dragController = _dragGestureController;
    if (dragController == null) return;
    _dragGestureController = null;
    final size = context.size;
    final sheetHeight = size != null && size.height > 0 ? size.height : 1.0;
    // Convert scroll-position velocity (negative = finger moved down,
    // pixels/sec) to the sheet-fraction finger-down velocity that
    // [_StreamDragGestureController.dragEnd] expects.
    dragController.dragEnd(-velocity / sheetHeight);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _scrollController);
  }
}

/// A [ScrollController] used by [StreamSheetRoute]'s body that bridges
/// the scrollable's gestures to the enclosing route's pop-drag
/// controller. The actual drag controller lives on the parent
/// [_StreamDraggableScrollableSheetState]; this controller forwards
/// drag lifecycle events via callbacks.
class _StreamSheetScrollController extends ScrollController {
  _StreamSheetScrollController({
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.sheetIsDraggedDown,
  });

  final VoidCallback onDragStart;
  final ValueChanged<double> onDragUpdate;
  final ValueChanged<double> onDragEnd;
  final ValueGetter<bool> sheetIsDraggedDown;

  @override
  _StreamSheetScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) {
    return _StreamSheetScrollPosition(
      // Wrap with [AlwaysScrollableScrollPhysics] so the drag-to-dismiss
      // gesture works even when the scrollable's content fits inside
      // the viewport (e.g. a short body inside a tall sheet) — without
      // this, the scrollable would reject the gesture before it reaches
      // [applyUserOffset].
      physics: physics.applyTo(const AlwaysScrollableScrollPhysics()),
      context: context,
      oldPosition: oldPosition,
      onDragStart: onDragStart,
      onDragUpdate: onDragUpdate,
      onDragEnd: onDragEnd,
      sheetIsDraggedDown: sheetIsDraggedDown,
    );
  }

  @override
  _StreamSheetScrollPosition get position => super.position as _StreamSheetScrollPosition;
}

/// A [ScrollPosition] that decides — based on the *release state*
/// (current [pixels] and current [velocity]) — whether each gesture
/// belongs to the list or to the enclosing sheet's drag-to-dismiss.
///
/// It emits [onDragStart] / [onDragUpdate] / [onDragEnd] callbacks; the
/// drag controller itself lives on the parent state, keeping this
/// class free of any animation logic.
class _StreamSheetScrollPosition extends ScrollPositionWithSingleContext {
  _StreamSheetScrollPosition({
    required super.physics,
    required super.context,
    super.oldPosition,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.sheetIsDraggedDown,
  });

  final VoidCallback onDragStart;
  final ValueChanged<double> onDragUpdate;
  final ValueChanged<double> onDragEnd;
  final ValueGetter<bool> sheetIsDraggedDown;

  // Captured from [drag] so we can call it before stealing the
  // ballistic. Tells the parent [Scrollable] that we've taken over the
  // gesture and that it should release any drag book-keeping it was
  // holding (held pointer, current [DragScrollActivity], etc.).
  VoidCallback? _dragCancelCallback;

  bool get listShouldScroll => pixels > 0.0;

  @override
  void applyUserOffset(double delta) {
    onDragStart();
    // While the sheet is partially dismissed, every delta belongs to
    // the sheet (so reversing direction undoes the dismiss). At rest
    // (sheet fully open + list at top), only downward deltas redirect;
    // upward deltas start scrolling the list normally.
    if (!listShouldScroll && (delta > 0 || sheetIsDraggedDown())) {
      onDragUpdate(delta);
    } else {
      super.applyUserOffset(delta);
    }
  }

  @override
  void goBallistic(double velocity) {
    // [ScrollDragController.end] forwards `-finger.primaryVelocity`
    // here, so:
    //   negative velocity = finger moved down (dismiss direction)
    //   positive velocity = finger moved up   (scroll-forward direction)
    //
    // The list owns this fling — settle the sheet by its position
    // threshold (no fling on the sheet) and run the normal scroll
    // ballistic. Covers:
    //   * no velocity at all
    //   * finger down but the list isn't at the top (it scrolls back up)
    //   * finger up but the list isn't at its bottom (it keeps scrolling)
    if (velocity == 0.0 || (velocity < 0.0 && listShouldScroll) || (velocity > 0.0 && pixels != maxScrollExtent)) {
      onDragEnd(0);
      super.goBallistic(velocity);
      return;
    }

    // Tell the parent [Scrollable] we're handling the rest of the
    // gesture so it doesn't keep tracking the drag underneath us.
    _dragCancelCallback?.call();
    _dragCancelCallback = null;

    // Finger flung down at the top of the list — dismiss the sheet
    // (the parent state converts velocity to a sheet-fraction).
    if (velocity < 0.0 && !listShouldScroll) {
      onDragEnd(velocity);
      super.goBallistic(0);
      return;
    }

    // Else: finger flung up at the bottom of the list — sheet settles
    // by position; list runs its ballistic with the fling velocity.
    onDragEnd(0);
    super.goBallistic(velocity);
  }

  @override
  Drag drag(DragStartDetails details, VoidCallback dragCancelCallback) {
    _dragCancelCallback = dragCancelCallback;
    return super.drag(details, dragCancelCallback);
  }

  @override
  void absorb(ScrollPosition other) {
    super.absorb(other);
    // Migrate the cancel callback across position swaps (viewport
    // metric changes, scroll physics swaps, etc.) so an in-flight
    // gesture isn't dropped on the floor.
    assert(_dragCancelCallback == null);
    if (other is! _StreamSheetScrollPosition) return;
    if (other._dragCancelCallback != null) {
      _dragCancelCallback = other._dragCancelCallback;
      other._dragCancelCallback = null;
    }
  }

  @override
  void dispose() {
    _dragCancelCallback = null;
    super.dispose();
  }
}

// Inherited widget injected into every [StreamSheetRoute]'s content.
// Lets descendants — including widgets pushed onto a nested [Navigator]
// inside the sheet — discover that they are inside a sheet and pop the
// whole sheet via the navigator the route was pushed onto (which may not
// be the root navigator).
class _StreamSheetScope extends InheritedWidget {
  const _StreamSheetScope({required this.route, required super.child});

  final StreamSheetRoute<dynamic> route;

  static _StreamSheetScope? maybeOf(BuildContext context) {
    return context.getInheritedWidgetOfExactType<_StreamSheetScope>();
  }

  @override
  bool updateShouldNotify(_StreamSheetScope oldWidget) => route != oldWidget.route;
}

// Built-in defaults for [StreamSheet] (and modal sheets opened via
// [showStreamSheet] / [StreamSheetRoute]).
//
// Used as the last step of the resolution chain — per-instance argument
// → ambient [StreamSheetThemeData] → these defaults — so every visual
// property has a concrete value at build time.
//
// Resolves context-aware values (colors, radii) from the surrounding
// [StreamTheme]; constants come from the design system spec.
class _StreamSheetDefaults extends StreamSheetThemeData {
  _StreamSheetDefaults(this.context) : _colorScheme = context.streamColorScheme, _radius = context.streamRadius;

  final BuildContext context;
  final StreamColorScheme _colorScheme;
  final StreamRadius _radius;

  @override
  double get elevation => 1;

  @override
  Color get backgroundColor => _colorScheme.backgroundElevation1;

  @override
  Color get barrierColor => _colorScheme.backgroundScrim;

  @override
  BorderRadiusGeometry get borderRadius => .vertical(top: _radius.xxxxl);

  @override
  Clip get clipBehavior => Clip.none;

  @override
  bool get showDragHandle => true;

  @override
  Color get dragHandleColor => _colorScheme.accentNeutral;

  @override
  Size get dragHandleSize => const Size(36, 5);

  @override
  Color get surfaceTintColor => StreamColors.transparent;

  @override
  Color get shadowColor => StreamColors.transparent;

  @override
  BoxConstraints get constraints => const BoxConstraints(maxWidth: 640);
}
