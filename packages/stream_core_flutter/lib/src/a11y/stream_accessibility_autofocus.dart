import 'dart:async';

import 'package:flutter/semantics.dart';
import 'package:material_ui/material_ui.dart';

/// A behavior-only wrapper that requests screen-reader focus on [child]
/// shortly after mount.
///
/// Use this when the platform's automatic focus decision on route entry
/// (typically the first interactive element in the toolbar) is not the
/// element the user needs to interact with — for example, landing focus
/// on a message input rather than the back button when a chat screen
/// opens.
///
/// Only the screen-reader reading cursor is moved; input focus is not
/// requested, so the soft keyboard stays closed.
///
/// The wrapper is a passthrough when [MediaQueryData.accessibleNavigation]
/// is false, so it has no effect for sighted users. It also responds to the
/// screen reader being turned on or off at runtime.
///
/// Only one [StreamAccessibilityAutofocus] should be active per route.
/// When two instances compete for screen-reader focus, the reading cursor
/// visibly bounces between their targets.
///
/// {@tool snippet}
///
/// Land SR focus on the composer input when the message screen opens:
///
/// ```dart
/// StreamAccessibilityAutofocus(
///   child: StreamMessageComposerInputField(...),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [FocusSemanticEvent], which this widget dispatches to move the SR
///    reading cursor.
class StreamAccessibilityAutofocus extends StatefulWidget {
  /// Creates a screen-reader autofocus wrapper.
  const StreamAccessibilityAutofocus({
    super.key,
    required this.child,
    this.retryInterval = const Duration(milliseconds: 300),
    this.window = const Duration(milliseconds: 1500),
    this.enabled = true,
  });

  /// The widget whose semantic node should receive SR focus.
  final Widget child;

  /// How often the wrapper reattempts focus during [window].
  final Duration retryInterval;

  /// How long to keep reattempting focus after mount.
  ///
  /// The wrapper stops trying once the window elapses.
  final Duration window;

  /// Whether the wrapper should attempt to move SR focus at all.
  ///
  /// When `false`, the widget is a simple passthrough. Callers can use
  /// this to conditionally opt into autofocus (e.g., only on the first
  /// time a route is entered).
  final bool enabled;

  @override
  State<StreamAccessibilityAutofocus> createState() => _StreamAccessibilityAutofocusState();
}

class _StreamAccessibilityAutofocusState extends State<StreamAccessibilityAutofocus> {
  // Debug-only registry of currently-mounted instances, keyed by the
  // enclosing route. Two widgets sharing a route would compete for the
  // same SR cursor; widgets on different routes don't, because only the
  // top-most route is SR-active at any time. Populated regardless of SR
  // state so misuse surfaces in ordinary dev sessions. Empty in release
  // builds — mutated only from within `assert` blocks.
  static final Map<Route<dynamic>, _StreamAccessibilityAutofocusState> _debugMounted = {};

  final _targetKey = GlobalKey();

  Timer? _retryTimer;
  Timer? _windowTimer;

  // Tracked so we can distinguish an SR-off session from a session where SR
  // was flipped on after mount; the latter starts a fresh attempt window.
  var _accessibleNavigation = false;

  // Route captured at first `didChangeDependencies` — kept so `dispose`
  // can remove the exact entry we registered, even if the widget is
  // rebuilt into a different subtree.
  Route<dynamic>? _debugRegisteredRoute;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.enabled) {
      assert(_debugScheduleRouteCheck());
    }

    final wasOn = _accessibleNavigation;
    _accessibleNavigation = MediaQuery.accessibleNavigationOf(context);

    if (!widget.enabled) return;

    // Start (or restart) the attempt window on any off→on transition —
    // including the first read after mount when SR is already on. Cancel
    // eagerly on on→off so a stale window doesn't keep ticking after SR
    // is turned off.
    if (_accessibleNavigation && !wasOn) {
      _startAttemptWindow();
    } else if (!_accessibleNavigation && wasOn) {
      _stopAttemptWindow();
    }
  }

  // Deferred to a postFrame callback so the per-route uniqueness check
  // runs after the widget tree has settled. Throwing directly from
  // didChangeDependencies would cascade into framework focus-tracking
  // invariants ('_FocusInheritedScope._dependents.isEmpty').
  bool _debugScheduleRouteCheck() {
    if (_debugRegisteredRoute != null) return true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _debugCheckOnlyOneMountedPerRoute();
    });
    return true;
  }

  @override
  void dispose() {
    assert(() {
      if (_debugRegisteredRoute case final route?) {
        if (identical(_debugMounted[route], this)) {
          _debugMounted.remove(route);
        }
      }
      return true;
    }());
    _stopAttemptWindow();
    super.dispose();
  }

  void _startAttemptWindow() {
    _stopAttemptWindow();
    WidgetsBinding.instance.addPostFrameCallback((_) => _requestFocus());
    _retryTimer = Timer.periodic(widget.retryInterval, (_) => _requestFocus());
    _windowTimer = Timer(widget.window, _stopAttemptWindow);
  }

  void _stopAttemptWindow() {
    _retryTimer?.cancel();
    _retryTimer = null;
    _windowTimer?.cancel();
    _windowTimer = null;
  }

  bool _debugCheckOnlyOneMountedPerRoute() {
    // Already registered — this call is from a later didChangeDependencies
    // (e.g., MediaQuery change), not a fresh mount. Nothing to check.
    if (_debugRegisteredRoute != null) return true;

    // Widgets not enclosed by any route (e.g., in a test harness or
    // widget-book style preview) skip the check — there's no "route
    // scope" to enforce single-ownership within.
    final route = ModalRoute.of(context);
    if (route == null) return true;

    if (_debugMounted[route] != null) {
      throw FlutterError.fromParts([
        ErrorSummary(
          'Multiple StreamAccessibilityAutofocus widgets are mounted on the '
          'same route at the same time.',
        ),
        ErrorDescription(
          'Only one instance should attempt to claim screen-reader focus per '
          'route. When multiple instances compete on the same route, the SR '
          'reading cursor visibly bounces between their targets during their '
          'overlapping attempt windows.',
        ),
        ErrorHint(
          'Wrap only the primary focus target (typically the main input) in '
          'StreamAccessibilityAutofocus. Instances on different routes (e.g., '
          'a composer on the underlying page and a text field inside a bottom '
          'sheet) are fine — the check is per-route.',
        ),
      ]);
    }

    _debugMounted[route] = this;
    _debugRegisteredRoute = route;
    return true;
  }

  void _requestFocus() {
    if (!mounted) return;
    if (!widget.enabled) return;
    if (!MediaQuery.accessibleNavigationOf(context)) return;
    final target = _targetKey.currentContext?.findRenderObject();
    if (target == null) return;
    // Guard against a scheduled callback firing on a subtree that never
    // fully mounted (e.g., a sibling widget threw during first build).
    if (!target.attached) return;

    return target.sendSemanticsEvent(const FocusSemanticEvent());
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: _targetKey, child: widget.child);
  }
}
