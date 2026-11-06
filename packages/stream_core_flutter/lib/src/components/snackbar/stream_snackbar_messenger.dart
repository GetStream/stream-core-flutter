part of 'stream_snackbar.dart';

/// The reason a [StreamSnackbar] was closed.
///
/// See also:
///
///  * [StreamSnackbarController.closed], which resolves with this value.
enum StreamSnackbarClosedReason {
  /// The user activated the action button.
  action,

  /// The user swiped the snackbar away.
  swipe,

  /// The auto-dismiss duration elapsed.
  timeout,

  /// Programmatically dismissed via [StreamSnackbarController.close] or
  /// [StreamSnackbarMessenger.hideCurrent]. The exit animation played.
  dismiss,

  /// Removed without an exit animation. Fires when the messenger is
  /// disposed, [StreamSnackbarMessenger.removeCurrent] is called, or
  /// [StreamSnackbarMessenger.clearSnackbars] is called.
  remove,
}

/// Handle to a snackbar that has been enqueued or is currently visible.
///
/// Returned from [StreamSnackbarMessenger.show]. Use [closed] to
/// await dismissal and [close] to dismiss programmatically.
///
/// {@tool snippet}
///
/// Awaiting the dismissal reason:
///
/// ```dart
/// final controller = StreamSnackbarMessenger.of(context).show(
///   const StreamSnackbar(
///     message: Text('Message deleted'),
///     action: StreamSnackbarAction(label: Text('Undo'), onPressed: undo),
///   ),
/// );
/// if (await controller.closed == StreamSnackbarClosedReason.timeout) {
///   commitDelete();
/// }
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamSnackbarMessenger.show], which returns a controller.
///  * [StreamSnackbarClosedReason], the value yielded by [closed].
class StreamSnackbarController {
  StreamSnackbarController._(this._hosted);

  final _HostedSnackbar _hosted;

  /// A future that resolves when this snackbar finishes.
  ///
  /// Completes with the [StreamSnackbarClosedReason] describing how the
  /// snackbar was dismissed — auto-timeout, swipe, action press, or
  /// programmatic close.
  Future<StreamSnackbarClosedReason> get closed => _hosted.completer.future;

  /// Programmatically dismisses this snackbar.
  ///
  /// Plays the exit animation and completes [closed] with [reason] (which
  /// defaults to [StreamSnackbarClosedReason.dismiss]).
  void close([StreamSnackbarClosedReason reason = StreamSnackbarClosedReason.dismiss]) {
    _hosted.host._requestExit(_hosted, reason);
  }
}

/// Imperative owner of a snackbar queue.
///
/// One [StreamSnackbarMessenger] backs one rendering surface: hand it to a
/// [StreamSnackbarHost] or [StreamSnackbarPopup] and call [show]
/// to enqueue. If another snackbar is already visible, the new call waits
/// its turn behind it.
///
/// Dispose when no longer needed.
///
/// {@tool snippet}
///
/// Manual ownership:
///
/// ```dart
/// final messenger = StreamSnackbarMessenger();
/// final controller = messenger.show(const StreamSnackbar(
///   message: Text('Message deleted'),
///   variant: StreamSnackbarVariant.success,
///   action: StreamSnackbarAction(label: Text('Undo'), onPressed: undo),
/// ));
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamSnackbarHost], renders snackbars from this state inline.
///  * [StreamSnackbarPopup], anchored variant for small surfaces.
///  * [StreamSnackbarScope], a convenience that owns a state and host.
class StreamSnackbarMessenger extends ChangeNotifier {
  /// Creates an empty messenger.
  StreamSnackbarMessenger();

  final _queue = ListQueue<_HostedSnackbar>();
  var _disposed = false;

  /// The [StreamSnackbar] currently being displayed, or null if none.
  StreamSnackbar? get currentSnackbar => _queue.isEmpty ? null : _queue.first.snackbar;

  /// The controller for the currently-displayed snackbar, or null if none.
  StreamSnackbarController? get currentController => _queue.isEmpty ? null : _queue.first.controller;

  /// Enqueues [snackbar] for display.
  ///
  /// Returns a [StreamSnackbarController]. If another snackbar is currently
  /// shown, [controller.closed] does not resolve until the queue advances to
  /// this snackbar and it is then dismissed.
  ///
  /// When [replace] is true, the currently-displayed snackbar (if any) is
  /// removed without an exit animation before enqueueing — equivalent to
  /// calling [removeCurrent] first. Useful for "snap to the freshest" UX
  /// (e.g. a hint that should reset on each retrigger).
  StreamSnackbarController show(
    StreamSnackbar snackbar, {
    bool replace = false,
  }) {
    assert(!_disposed, 'show called after dispose');
    if (replace) removeCurrent();
    final hosted = _HostedSnackbar(snackbar: snackbar, host: this);
    _queue.add(hosted);
    if (_queue.length != 1) return hosted.controller;
    try {
      notifyListeners();
    } catch (exception) {
      assert(() {
        if (exception is FlutterError) {
          final summary = exception.diagnostics.first.toDescription();
          if (summary == 'setState() or markNeedsBuild() called during build.') {
            final information = <DiagnosticsNode>[
              ErrorSummary('The show() method cannot be called during build.'),
              ErrorDescription(
                'The show() method was called during build, which is '
                'prohibited as showing snack bars requires updating state. Updating '
                'state is not possible during build.',
              ),
              ErrorHint(
                'Instead of calling show() during build, call it directly '
                'in your on tap (and related) callbacks. If you need to immediately '
                'show a snack bar, make the call in initState() or '
                'didChangeDependencies() instead. Otherwise, you can also schedule a '
                'post-frame callback using SchedulerBinding.addPostFrameCallback to '
                'show the snack bar after the current frame.',
              ),
            ];
            throw FlutterError.fromParts(information);
          }
        }
        return true;
      }());
      rethrow;
    }
    return hosted.controller;
  }

  /// Dismisses the currently-displayed snackbar with the exit animation.
  /// No-op when the queue is empty.
  void hideCurrent([StreamSnackbarClosedReason reason = .dismiss]) {
    if (_queue.isEmpty) return;
    _requestExit(_queue.first, reason);
  }

  /// Dismisses the currently-displayed snackbar **without** an exit
  /// animation and immediately advances to the next queued one.
  /// No-op when the queue is empty.
  ///
  /// Use for snap-replacement when a fresh snackbar should win immediately
  /// (e.g. a rapidly retriggered hint).
  void removeCurrent([StreamSnackbarClosedReason reason = .remove]) {
    if (_queue.isEmpty) return;
    final hosted = _queue.removeFirst();
    if (!hosted.completer.isCompleted) hosted.completer.complete(reason);
    notifyListeners();
  }

  /// Removes every snackbar — current and queued — without animation.
  void clearSnackbars() {
    if (_queue.isEmpty) return;
    while (_queue.isNotEmpty) {
      final hosted = _queue.removeFirst();
      if (!hosted.completer.isCompleted) {
        hosted.completer.complete(StreamSnackbarClosedReason.remove);
      }
    }
    notifyListeners();
  }

  /// Returns the nearest [StreamSnackbarMessenger] ancestor provided by a
  /// [StreamSnackbarHost], [StreamSnackbarPopup], or [StreamSnackbarScope].
  ///
  /// Throws a [FlutterError] if none is found; use [maybeOf] for a
  /// nullable lookup.
  static StreamSnackbarMessenger of(BuildContext context) {
    final messenger = maybeOf(context);
    if (messenger != null) return messenger;
    throw FlutterError.fromParts(<DiagnosticsNode>[
      ErrorSummary(
        'StreamSnackbarMessenger.of() called with a context that does not '
        'contain a StreamSnackbarMessenger.',
      ),
      ErrorDescription(
        'No StreamSnackbarMessenger ancestor could be found starting from '
        'the context that was passed to StreamSnackbarMessenger.of(). This '
        'usually happens when the context provided is from the same '
        'StatefulWidget as the one that creates the surface (the '
        'StreamSnackbarScope, StreamSnackbarPopup, or StreamSnackbarHost) '
        'being sought.',
      ),
      ErrorHint(
        'There are several ways to avoid this problem. The simplest is to '
        'use a Builder to get a context that is "under" the snackbar '
        'surface. Wrap the relevant subtree with `StreamSnackbarScope` for '
        'app-wide snackbars, or `StreamSnackbarPopup` for an anchored '
        'popup.',
      ),
      ErrorHint(
        'A more efficient solution is to split your build function into '
        'several widgets. This introduces a new context from which you '
        'can obtain the StreamSnackbarMessenger. In this solution, you '
        'would have an outer widget that creates the snackbar surface '
        'populated by instances of your new inner widgets, and then in '
        'these inner widgets you would use StreamSnackbarMessenger.of().',
      ),
      context.describeElement('The context used was'),
    ]);
  }

  /// Returns the nearest [StreamSnackbarMessenger] ancestor, or null if none
  /// is found.
  ///
  /// See [of] for a non-null variant that throws.
  static StreamSnackbarMessenger? maybeOf(BuildContext context) {
    final marker = context.dependOnInheritedWidgetOfExactType<_StreamSnackbarHostProvider>();
    return marker?.messenger;
  }

  // Requests exit for [hosted] with [reason]. When [hosted] is the head of
  // the queue, the host widget picks up the request, plays the exit
  // animation, then calls _finalize. When [hosted] is queued but not yet
  // shown, it is removed silently and its future is completed immediately
  // — no animation, since it never reached the screen.
  void _requestExit(_HostedSnackbar hosted, StreamSnackbarClosedReason reason) {
    if (_queue.isEmpty) return;
    if (hosted._requestedExit != null) return;

    if (identical(_queue.first, hosted)) {
      hosted._requestedExit = reason;
      notifyListeners();
      return;
    }

    if (_queue.remove(hosted)) {
      if (!hosted.completer.isCompleted) hosted.completer.complete(reason);
    }
  }

  // Pops the head of the queue and completes its future. Called by the
  // host widget after the exit animation completes (or after a swipe).
  void _finalize(_HostedSnackbar hosted, StreamSnackbarClosedReason reason) {
    if (_queue.isEmpty || _queue.first != hosted) return;
    _queue.removeFirst();
    if (!hosted.completer.isCompleted) hosted.completer.complete(reason);
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    for (final hosted in _queue) {
      if (!hosted.completer.isCompleted) {
        hosted.completer.complete(StreamSnackbarClosedReason.remove);
      }
    }
    _queue.clear();
    super.dispose();
  }
}

class _HostedSnackbar {
  _HostedSnackbar({required this.snackbar, required this.host});

  final StreamSnackbar snackbar;
  final StreamSnackbarMessenger host;
  final completer = Completer<StreamSnackbarClosedReason>();

  late final controller = StreamSnackbarController._(this);

  // Signals the host widget to start the exit animation with this result.
  StreamSnackbarClosedReason? _requestedExit;
}

/// An inline render slot for snackbars from a [StreamSnackbarMessenger].
///
/// A leaf widget that renders the currently-active snackbar at its own
/// location. The consumer is responsible for placing it via standard
/// layout (Stack / Positioned / etc.).
///
/// For snackbars that should appear above a small surface (composer,
/// attachment picker), use [StreamSnackbarPopup] instead — it renders into
/// the surrounding [Overlay] so the snackbar escapes the anchor's bounds.
///
/// {@tool snippet}
///
/// Place the host at the bottom of a screen-level surface:
///
/// ```dart
/// Scaffold(
///   body: Stack(
///     children: [
///       const ChannelBody(),
///       Positioned(
///         bottom: 0, left: 0, right: 0,
///         child: SafeArea(child: StreamSnackbarHost(messenger: _state)),
///       ),
///     ],
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamSnackbarPopup], the anchored variant for small surfaces.
///  * [StreamSnackbarScope], which bundles state, host, and lookup.
class StreamSnackbarHost extends StatefulWidget {
  /// Creates a snackbar host that renders snackbars from [messenger].
  const StreamSnackbarHost({super.key, required this.messenger});

  /// The state holder providing snackbar data.
  final StreamSnackbarMessenger messenger;

  @override
  State<StreamSnackbarHost> createState() => _StreamSnackbarHostState();
}

class _StreamSnackbarHostState extends State<StreamSnackbarHost> {
  @override
  Widget build(BuildContext context) {
    return _StreamSnackbarHostProvider(
      messenger: widget.messenger,
      child: _SnackbarStage(
        messenger: widget.messenger,
        builder: _buildInlineSnackbar,
      ),
    );
  }
}

// Lays out a snackbar inline: centered horizontally inside the theme margin.
Widget _buildInlineSnackbar(
  BuildContext context,
  Animation<double> animation,
  Widget child,
) {
  final style = context.streamSnackbarTheme.style;
  final defaults = _StreamSnackbarDefaults(context);
  final margin = style?.margin ?? defaults.margin;

  return Padding(
    padding: margin.resolve(Directionality.of(context)),
    child: Center(
      child: _SnackbarTransition(animation: animation, child: child),
    ),
  );
}

/// Where the snackbar is positioned relative to its [StreamSnackbarPopup]
/// anchor.
///
/// See also:
///
///  * [StreamSnackbarPopup.placement], which selects one of these values.
enum StreamSnackbarPopupPlacement {
  /// Snackbar's bottom edge aligns to the anchor's top edge.
  ///
  /// The default. Suitable for anchors at the bottom of the screen — e.g.
  /// a message composer.
  over,

  /// Snackbar's top edge aligns to the anchor's bottom edge.
  ///
  /// Suitable for anchors at the top of the screen — e.g. a top-pinned
  /// header or composer.
  under,
}

/// An anchored render slot that floats snackbars next to a [child].
///
/// Renders into the surrounding [Overlay], anchored above or below [child]
/// according to [placement]. Use this for small surfaces (composer,
/// attachment picker) where the snackbar would otherwise be obscured by —
/// or clipped to — the surface's bounds. For full-screen surfaces, prefer
/// [StreamSnackbarHost].
///
/// Descendants of [child] can fire snackbars via
/// `StreamSnackbarMessenger.of(context).show(...)`. For fire-from-outside
/// usage, construct with [withState] and hold a reference yourself.
///
/// {@tool snippet}
///
/// Auto-managed state — descendants fire via context:
///
/// ```dart
/// StreamSnackbarPopup(
///   child: ComposerInputRow(...),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// External state — caller fires from anywhere:
///
/// ```dart
/// StreamSnackbarPopup.withState(
///   messenger: _composerMessenger,
///   child: ComposerInputRow(...),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamSnackbarHost], the inline variant for full-screen surfaces.
class StreamSnackbarPopup extends StatefulWidget {
  /// Creates a popup with an auto-managed [StreamSnackbarMessenger].
  /// Disposed when the popup is removed from the tree.
  const StreamSnackbarPopup({
    super.key,
    required this.child,
    this.placement = StreamSnackbarPopupPlacement.over,
  }) : externalMessenger = null;

  /// Creates a popup that delegates to an externally-owned [messenger].
  /// The caller is responsible for disposing [messenger].
  const StreamSnackbarPopup.withState({
    super.key,
    required StreamSnackbarMessenger messenger,
    required this.child,
    this.placement = StreamSnackbarPopupPlacement.over,
  }) : externalMessenger = messenger;

  /// The anchor widget. The snackbar's edge is aligned to this widget's
  /// opposite edge, centered horizontally over its width, according to
  /// [placement].
  final Widget child;

  /// Where the snackbar is positioned relative to [child].
  ///
  /// Defaults to [StreamSnackbarPopupPlacement.over].
  final StreamSnackbarPopupPlacement placement;

  /// External messenger used when constructed via [withState].
  final StreamSnackbarMessenger? externalMessenger;

  @override
  State<StreamSnackbarPopup> createState() => _StreamSnackbarPopupState();
}

class _StreamSnackbarPopupState extends State<StreamSnackbarPopup> {
  final _link = LayerLink();
  final _portalController = OverlayPortalController();

  StreamSnackbarMessenger? _ownedMessenger;

  StreamSnackbarMessenger get _effectiveMessenger {
    return widget.externalMessenger ?? (_ownedMessenger ??= StreamSnackbarMessenger());
  }

  @override
  void initState() {
    super.initState();
    _portalController.show();
  }

  @override
  void dispose() {
    _ownedMessenger?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messenger = _effectiveMessenger;
    return _StreamSnackbarHostProvider(
      messenger: messenger,
      child: CompositedTransformTarget(
        link: _link,
        child: OverlayPortal(
          controller: _portalController,
          overlayChildBuilder: (overlayContext) {
            return _StreamSnackbarHostProvider(
              messenger: messenger,
              child: _SnackbarStage(
                messenger: messenger,
                builder: (context, animation, child) {
                  final style = context.streamSnackbarTheme.style;
                  final defaults = _StreamSnackbarDefaults(context);
                  final effectiveMargin = (style?.margin ?? defaults.margin).resolve(Directionality.of(context));
                  final (targetAnchor, followerAnchor, offset) = switch (widget.placement) {
                    StreamSnackbarPopupPlacement.over => (
                      Alignment.topCenter,
                      Alignment.bottomCenter,
                      Offset(0, -effectiveMargin.bottom),
                    ),
                    StreamSnackbarPopupPlacement.under => (
                      Alignment.bottomCenter,
                      Alignment.topCenter,
                      Offset(0, effectiveMargin.top),
                    ),
                  };

                  return Positioned(
                    left: 0,
                    top: 0,
                    child: CompositedTransformFollower(
                      link: _link,
                      targetAnchor: targetAnchor,
                      followerAnchor: followerAnchor,
                      offset: offset,
                      showWhenUnlinked: false,
                      child: _SnackbarTransition(animation: animation, child: child),
                    ),
                  );
                },
              ),
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}

/// A widget that provides a [StreamSnackbarMessenger] to its subtree and shows
/// its snackbars.
///
/// Every `StreamScaffold` whose nearest scope is this one, and that is not
/// nested in another such `StreamScaffold`, shows the current snackbar above
/// whatever it docks at its bottom, including one inside a dialog. While the
/// scope has no such `StreamScaffold`, it shows the snackbar at its own bottom
/// edge instead.
///
/// Scaffolds side by side, such as a master and a detail pane, each show the
/// snackbar. To show it once, put them in one outer `StreamScaffold` or give
/// one of them its own scope.
///
/// A page that shows snackbars therefore needs its own `StreamScaffold`.
/// Otherwise its snackbars show on the `StreamScaffold` beneath it: behind a
/// dialog's barrier, or hidden under an opaque page.
///
/// A snackbar can be built in more than one place at once, so its content
/// must not use a [GlobalKey].
///
/// Descendants show snackbars from anywhere via
/// `StreamSnackbarMessenger.of(context).show(...)`. Nested scopes own
/// independent queues — a scope wrapping a chat surface is separate from
/// the app-wide one.
///
/// {@tool snippet}
///
/// App-level scope inside `MaterialApp.builder`:
///
/// ```dart
/// MaterialApp(
///   builder: (context, child) => StreamSnackbarScope(child: child!),
///   home: HomeScreen(),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Show a snackbar from a descendant of the scope:
///
/// ```dart
/// StreamSnackbarMessenger.of(context).show(
///   const StreamSnackbar(message: Text('Message sent')),
/// );
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Per-surface scope sharing an externally-owned state:
///
/// ```dart
/// StreamSnackbarScope.withState(
///   messenger: _myMessenger,
///   child: ChannelBody(),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamSnackbarHost], for rendering without the scope wrapper.
///  * [StreamSnackbarMessenger], the underlying queue owner.
class StreamSnackbarScope extends StatefulWidget {
  /// Creates a scope with an auto-managed [StreamSnackbarMessenger].
  /// Disposed when the scope is removed from the tree.
  const StreamSnackbarScope({
    super.key,
    required this.child,
  }) : externalMessenger = null;

  /// Creates a scope that delegates to an externally-owned [messenger].
  /// The caller is responsible for disposing [messenger].
  const StreamSnackbarScope.withState({
    super.key,
    required StreamSnackbarMessenger messenger,
    required this.child,
  }) : externalMessenger = messenger;

  /// The subtree that can show snackbars via [StreamSnackbarMessenger.show].
  final Widget child;

  /// External messenger used when constructed via [withState].
  final StreamSnackbarMessenger? externalMessenger;

  @override
  State<StreamSnackbarScope> createState() => _StreamSnackbarScopeState();
}

class _StreamSnackbarScopeState extends State<StreamSnackbarScope> with SingleTickerProviderStateMixin {
  StreamSnackbarMessenger? _ownedMessenger;
  late final _SnackbarPresenter _presenter;
  final _surfaces = _SurfaceRegistry();

  StreamSnackbarMessenger get _effectiveMessenger {
    return widget.externalMessenger ?? (_ownedMessenger ??= StreamSnackbarMessenger());
  }

  @override
  void initState() {
    super.initState();
    _presenter = _SnackbarPresenter(
      vsync: this,
      messenger: _effectiveMessenger,
      accessibleNavigation: () => _accessibleNavigationOf(context),
    );
  }

  @override
  void didUpdateWidget(StreamSnackbarScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    _presenter.updateMessenger(_effectiveMessenger);
  }

  @override
  void dispose() {
    _surfaces.dispose();
    _presenter.dispose();
    _ownedMessenger?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Push the snackbar above the keyboard when one is open. `SafeArea`
    // covers static insets (home indicator, side notches) but ignores the
    // soft keyboard's `viewInsets`.
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    return _SnackbarScopeMarker(
      scope: this,
      child: _StreamSnackbarHostProvider(
        messenger: _effectiveMessenger,
        child: Stack(
          children: [
            widget.child,
            Positioned(
              bottom: keyboardInset,
              left: 0,
              right: 0,
              child: SafeArea(
                top: false,
                child: _HiddenWhileSurfaced(
                  surfaces: _surfaces,
                  child: _InactiveWhileSurfaced(
                    surfaces: _surfaces,
                    child: _SnackbarView(
                      presenter: _presenter,
                      builder: _buildInlineSnackbar,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// The surfaces showing a scope's snackbars. Surfaces join and leave while the
// tree builds, which is before the frame paints.
class _SurfaceRegistry extends ChangeNotifier {
  final _surfaces = <_StreamSnackbarSurfaceState>{};

  bool get isEmpty => _surfaces.isEmpty;

  void add(_StreamSnackbarSurfaceState surface) {
    final added = _surfaces.add(surface);
    assert(added, 'A surface registered twice.');
    notifyListeners();
  }

  void remove(_StreamSnackbarSurfaceState surface) {
    final removed = _surfaces.remove(surface);
    assert(removed, 'A surface unregistered twice.');
    notifyListeners();
  }

  // Tells the surfaces that one of them may now be collected by other page
  // transitions.
  void collectionChanged() => notifyListeners();
}

// Skips painting, hit testing and semantics for [child] while any surface is
// registered. The decision is made at paint time, so a surface that joins or
// leaves during this frame's build is already accounted for.
class _HiddenWhileSurfaced extends SingleChildRenderObjectWidget {
  const _HiddenWhileSurfaced({required this.surfaces, required super.child});

  final _SurfaceRegistry surfaces;

  @override
  _RenderHiddenWhileSurfaced createRenderObject(BuildContext context) {
    return _RenderHiddenWhileSurfaced(surfaces);
  }

  @override
  void updateRenderObject(BuildContext context, _RenderHiddenWhileSurfaced renderObject) {
    renderObject.surfaces = surfaces;
  }
}

class _RenderHiddenWhileSurfaced extends RenderProxyBox {
  _RenderHiddenWhileSurfaced(this._surfaces);

  _SurfaceRegistry get surfaces => _surfaces;
  _SurfaceRegistry _surfaces;
  set surfaces(_SurfaceRegistry value) {
    if (identical(value, _surfaces)) return;
    if (attached) _surfaces.removeListener(_handleSurfacesChanged);
    _surfaces = value;
    if (attached) _surfaces.addListener(_handleSurfacesChanged);
    _handleSurfacesChanged();
  }

  bool get _hidden => !_surfaces.isEmpty;

  void _handleSurfacesChanged() {
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _surfaces.addListener(_handleSurfacesChanged);
  }

  @override
  void detach() {
    _surfaces.removeListener(_handleSurfacesChanged);
    super.detach();
  }

  @override
  bool paintsChild(RenderBox child) => !_hidden;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_hidden) return;
    super.paint(context, offset);
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (_hidden) return false;
    return super.hitTest(result, position: position);
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    if (_hidden) return;
    super.visitChildrenForSemantics(visitor);
  }
}

// Stops tickers and keeps focus out of [child] while any surface is
// registered. Neither is visible, so this follows the registry a frame late:
// surfaces join and leave during build, when this widget can't rebuild.
class _InactiveWhileSurfaced extends StatefulWidget {
  const _InactiveWhileSurfaced({required this.surfaces, required this.child});

  final _SurfaceRegistry surfaces;
  final Widget child;

  @override
  State<_InactiveWhileSurfaced> createState() => _InactiveWhileSurfacedState();
}

class _InactiveWhileSurfacedState extends State<_InactiveWhileSurfaced> {
  var _updateScheduled = false;

  @override
  void initState() {
    super.initState();
    widget.surfaces.addListener(_scheduleUpdate);
  }

  @override
  void didUpdateWidget(_InactiveWhileSurfaced oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (identical(oldWidget.surfaces, widget.surfaces)) return;
    oldWidget.surfaces.removeListener(_scheduleUpdate);
    widget.surfaces.addListener(_scheduleUpdate);
  }

  @override
  void dispose() {
    widget.surfaces.removeListener(_scheduleUpdate);
    super.dispose();
  }

  void _scheduleUpdate() {
    if (_updateScheduled) return;
    _updateScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _updateScheduled = false;
      if (!mounted) return;
      setState(() {
        // The registry changed; build reads it again.
      });
    });
    SchedulerBinding.instance.ensureVisualUpdate();
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.surfaces.isEmpty;
    return TickerMode(
      enabled: active,
      child: ExcludeFocus(excluding: !active, child: widget.child),
    );
  }
}

// Lets a StreamSnackbarSurface find the scope it shows snackbars for.
class _SnackbarScopeMarker extends InheritedWidget {
  const _SnackbarScopeMarker({required this.scope, required super.child});

  final _StreamSnackbarScopeState scope;

  // The nearest scope above [context], or null if there is none.
  static _StreamSnackbarScopeState? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_SnackbarScopeMarker>()?.scope;
  }

  @override
  bool updateShouldNotify(_SnackbarScopeMarker oldWidget) => scope != oldWidget.scope;
}

/// A page region that shows the snackbars of the enclosing
/// [StreamSnackbarScope] in place of the scope.
///
/// [builder] receives the snackbar to place, or null when this surface does
/// not show the scope's snackbars. Every surface not nested in another surface
/// of the same scope shows the scope's current snackbar. The scope shows it at
/// its own bottom edge only while it has no surface under it.
@internal
class StreamSnackbarSurface extends StatefulWidget {
  /// Creates a surface that places the scope's snackbar through [builder].
  const StreamSnackbarSurface({super.key, required this.builder});

  /// The builder for the region, given the snackbar to place or null when this
  /// surface does not show the scope's snackbars.
  final Widget Function(BuildContext context, Widget? snackbar) builder;

  @override
  State<StreamSnackbarSurface> createState() => _StreamSnackbarSurfaceState();
}

class _StreamSnackbarSurfaceState extends State<StreamSnackbarSurface> {
  _StreamSnackbarScopeState? _scope;
  ModalRoute<Object?>? _route;
  // The overlay entries of the routes this surface sits in, innermost first.
  var _routeEntries = const <Element>[];
  var _isRoot = false;
  var _flies = false;
  var _updateScheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = _SnackbarScopeMarker.maybeOf(context);
    if (scope != _scope) {
      _scope?._surfaces
        ?..remove(this)
        ..removeListener(_scheduleUpdate);
      _scope = scope;
      scope?._surfaces
        ?..add(this)
        ..addListener(_scheduleUpdate);
    }
    _route = ModalRoute.of(context);
    _routeEntries = _routeEntriesOf(context);
    _isRoot = scope != null && _SnackbarSurfaceMarker.maybeOf(context) != scope;
    scope?._surfaces.collectionChanged();
  }

  @override
  void dispose() {
    _scope?._surfaces.removeListener(_scheduleUpdate);
    super.dispose();
  }

  // The routes whose page transitions collect this surface's hero, as their
  // overlay entries. A transition collects the heroes of its own page, and of
  // the current page of every navigator nested in it.
  Iterable<Element> get _collectedBy {
    if (!_isRoot || _routeEntries.isEmpty) return const [];
    final route = _route;
    final current = route is PageRoute && route.isCurrent;
    return current ? _routeEntries : _routeEntries.take(1);
  }

  bool _collectedWith(_StreamSnackbarSurfaceState other) {
    final collectedBy = _collectedBy.toSet();
    return other._collectedBy.any(collectedBy.contains);
  }

  // Whether this surface carries the snackbar's hero: only while no other
  // surface is collected by the same page transitions. Every hero one
  // transition collects needs its own tag, so surfaces collected together all
  // leave the hero out and cross-fade instead. If they come to be collected
  // together mid-flight, the flight ends rather than reversing.
  bool _carriesHero() {
    if (!_isRoot) return false;
    return !_scope!._surfaces._surfaces.any((other) => other != this && other._collectedWith(this));
  }

  // Which surface carries the hero changes while the tree builds, when this
  // surface can't rebuild. It only matters to the next page transition, so
  // this follows a frame late.
  void _scheduleUpdate() {
    if (_updateScheduled) return;
    _updateScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _updateScheduled = false;
      if (!mounted || _scope == null) return;
      if (_carriesHero() == _flies) return;
      setState(() {
        // The hero moved to or from this surface; build reads it again.
      });
    });
    SchedulerBinding.instance.ensureVisualUpdate();
  }

  // Leaving in deactivate rather than dispose: deactivation happens while the
  // tree builds, before the frame paints, while dispose comes after it. A
  // deactivated state is either activated again or disposed.
  @override
  void deactivate() {
    _scope?._surfaces.remove(this);
    super.deactivate();
  }

  @override
  void activate() {
    super.activate();
    _scope?._surfaces.add(this);
  }

  @override
  Widget build(BuildContext context) {
    final scope = _scope;
    if (scope == null) return widget.builder(context, null);

    _flies = _carriesHero();
    final snackbar = _isRoot
        ? _SnackbarView(presenter: scope._presenter, builder: _buildInlineSnackbar, flies: _flies)
        : null;

    return _SnackbarSurfaceMarker(
      scope: scope,
      child: Builder(builder: (context) => widget.builder(context, snackbar)),
    );
  }
}

// The overlay entries of the navigator routes [context] sits in, innermost
// first. Reads each entry as the element two levels below its overlay; if
// overlays ever wrap their entries in more layers, surfaces share an entry
// and fewer of them fly, but two still never carry the hero at once.
List<Element> _routeEntriesOf(BuildContext context) {
  final entries = <Element>[];
  Element? child;
  Element? grandchild;
  OverlayState? overlay;
  Element? entry;
  context.visitAncestorElements((element) {
    if (element case StatefulElement(:final state)) {
      if (state is OverlayState) {
        // An overlay builds its entries under a single child.
        overlay = state;
        entry = grandchild;
      } else if (state is NavigatorState && overlay != null && state.overlay == overlay) {
        entries.add(entry!);
        overlay = null;
      }
    }
    grandchild = child;
    child = element;
    return true;
  });
  return entries;
}

// Marks a subtree covered by a StreamSnackbarSurface of [scope].
class _SnackbarSurfaceMarker extends InheritedWidget {
  const _SnackbarSurfaceMarker({required this.scope, required super.child});

  final _StreamSnackbarScopeState scope;

  // The scope of the nearest surface above [context], or null outside any
  // surface.
  static _StreamSnackbarScopeState? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_SnackbarSurfaceMarker>()?.scope;
  }

  @override
  bool updateShouldNotify(_SnackbarSurfaceMarker oldWidget) => scope != oldWidget.scope;
}

// Exposes the messenger to the rendered snackbar so the action button
// (and any custom widget) can dismiss without a back-reference.
class _StreamSnackbarHostProvider extends InheritedWidget {
  const _StreamSnackbarHostProvider({
    required this.messenger,
    required super.child,
  });

  final StreamSnackbarMessenger messenger;

  @override
  bool updateShouldNotify(_StreamSnackbarHostProvider oldWidget) => messenger != oldWidget.messenger;
}

typedef _SnackbarLayoutBuilder = Widget Function(BuildContext context, Animation<double> animation, Widget child);

// No dependency on MediaQuery: the first read can come from initState.
bool _accessibleNavigationOf(BuildContext context) {
  final mediaQuery = context.getInheritedWidgetOfExactType<MediaQuery>();
  return mediaQuery?.data.accessibleNavigation ?? false;
}

// Plays one messenger's queue: owns the enter/exit animation, the timeout
// timer and the currently-showing _HostedSnackbar. Kept out of the widget
// tree so the snackbar it plays can move between surfaces mid-animation.
class _SnackbarPresenter extends ChangeNotifier {
  _SnackbarPresenter({
    required TickerProvider vsync,
    required this._messenger,
    required this._accessibleNavigation,
  }) : animation = AnimationController(
         vsync: vsync,
         duration: _enterDuration,
         reverseDuration: _exitDuration,
       ) {
    animation.addStatusListener(_handleAnimationStatus);
    _messenger.addListener(_sync);
    _sync();
  }

  final AnimationController animation;
  final bool Function() _accessibleNavigation;
  StreamSnackbarMessenger _messenger;
  Timer? _timer;
  _HostedSnackbar? _showing;
  StreamSnackbarClosedReason? _exitReason;
  var _exiting = false;
  var _disposed = false;

  StreamSnackbarMessenger get messenger => _messenger;

  _HostedSnackbar? get showing => _showing;

  // Switches to playing [messenger]'s queue, dropping whatever was showing
  // from the previous one. A snackbar that was already leaving is finished on
  // its own messenger; any other stays queued there.
  void updateMessenger(StreamSnackbarMessenger messenger) {
    if (identical(messenger, _messenger)) return;
    _messenger.removeListener(_sync);
    _finishPendingExit();
    _messenger = messenger..addListener(_sync);
    _timer?.cancel();
    _timer = null;
    _exiting = false;
    _exitReason = null;
    _showing = null;
    animation.value = 0;
    // Views drop the previous snackbar even when the new queue is empty.
    notifyListeners();
    _sync();
  }

  // Completes an exit the animation will no longer finish, because the
  // messenger is being swapped out or the presenter disposed.
  void _finishPendingExit() {
    final hosted = _showing;
    final reason = _exitReason;
    if (!_exiting || hosted == null || reason == null) return;
    final messenger = _messenger;
    // Deferred: disposal runs while the widget tree is locked, and finalizing
    // notifies the messenger's other listeners.
    scheduleMicrotask(() => messenger._finalize(hosted, reason));
  }

  // Drives the auto-dismiss timer off the enter-animation status instead
  // of chaining whenComplete onto the forward future.
  void _handleAnimationStatus(AnimationStatus status) {
    if (_disposed) return;
    if (status == AnimationStatus.completed) {
      _startTimer();
      _showing?.snackbar.props.onVisible?.call();
    }
  }

  void _sync() {
    if (_disposed) return;
    final queue = _messenger._queue;
    final next = queue.isEmpty ? null : queue.first;

    if (identical(next, _showing)) {
      final hosted = _showing;
      final reason = hosted?._requestedExit;
      if (hosted != null && reason != null && !_exiting) _startExit(hosted, reason);
      return;
    }

    // The head changed under us — either we're already exiting (in which
    // case the exit completion will trigger another sync) or _showing was
    // removed externally (e.g. messenger.dispose). In both cases, drop
    // local state and pick up the new head fresh.
    if (_exiting) return;

    _timer?.cancel();
    _showing = next;
    animation.value = 0;
    notifyListeners();
    if (next == null) return;
    if (_accessibleNavigation()) {
      animation.value = 1;
    } else {
      animation.forward(from: 0);
    }
  }

  void _startTimer() {
    final hosted = _showing;
    if (hosted == null) return;
    final duration = _resolveDuration(hosted.snackbar.props);
    if (duration == _persistentDuration) return;
    _timer?.cancel();
    _timer = Timer(duration, () {
      final current = _showing;
      if (current == null) return;
      _startExit(current, StreamSnackbarClosedReason.timeout);
    });
  }

  Future<void> _startExit(_HostedSnackbar hosted, StreamSnackbarClosedReason reason) async {
    if (_exiting || _disposed) return;
    // Capture before the await — the messenger may swap while the exit
    // animation plays, and `hosted` belongs to whichever messenger owned it
    // at the start of the exit.
    final messenger = _messenger;
    _exiting = true;
    _exitReason = reason;
    _timer?.cancel();
    if (_accessibleNavigation()) {
      animation.value = 0;
    } else {
      try {
        await animation.reverse().orCancel;
      } on TickerCanceled {
        // Swapped or disposed mid-exit; _finishPendingExit finalized it.
        return;
      }
    }
    if (_disposed) return;
    _showing = null;
    _exiting = false;
    _exitReason = null;
    notifyListeners();
    messenger._finalize(hosted, reason);
    if (identical(messenger, _messenger)) _sync();
  }

  void handleSwipeDismissed() {
    if (_exiting || _disposed) return;
    // Delegate to the public API; _sync picks up the new head after
    // notifyListeners and resets the local state.
    _messenger.removeCurrent(StreamSnackbarClosedReason.swipe);
  }

  @override
  void dispose() {
    _disposed = true;
    _messenger.removeListener(_sync);
    _finishPendingExit();
    _timer?.cancel();
    animation.dispose();
    super.dispose();
  }
}

// Renders the snackbar a presenter is playing, wrapped by [builder] for
// positioning.
//
// When [flies] is true, the snackbar flies to the copy on the next page
// during a page transition, rather than one copy fading out as another fades
// in.
class _SnackbarView extends StatelessWidget {
  const _SnackbarView({required this.presenter, required this.builder, this.flies = false});

  final _SnackbarPresenter presenter;
  final _SnackbarLayoutBuilder builder;
  final bool flies;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: presenter,
      builder: (context, _) {
        final hosted = presenter.showing;
        if (hosted == null) return const SizedBox.shrink();
        final style = context.streamSnackbarTheme.style;
        final direction = hosted.snackbar.props.dismissDirection ?? style?.dismissDirection ?? DismissDirection.down;
        final dismissible = Dismissible(
          key: ObjectKey(hosted),
          direction: direction,
          onDismissed: (_) => presenter.handleSwipeDismissed(),
          child: hosted.snackbar,
        );
        final child = flies
            ? Hero(
                tag: ObjectKey(hosted),
                transitionOnUserGestures: true,
                // Fades with the copies it flies between, so a snackbar that
                // enters or leaves mid-flight still fades.
                flightShuttleBuilder: (_, _, _, _, _) => _SnackbarTransition(
                  animation: presenter.animation,
                  child: dismissible,
                ),
                child: dismissible,
              )
            : dismissible;
        return _StreamSnackbarHostProvider(
          messenger: presenter.messenger,
          child: builder(context, presenter.animation, child),
        );
      },
    );
  }
}

// Plays a messenger's queue in place, for Host and Popup. The [builder]
// callback wraps the snackbar with positioning.
class _SnackbarStage extends StatefulWidget {
  const _SnackbarStage({
    required this.messenger,
    required this.builder,
  });

  final StreamSnackbarMessenger messenger;
  final _SnackbarLayoutBuilder builder;

  @override
  State<_SnackbarStage> createState() => _SnackbarStageState();
}

class _SnackbarStageState extends State<_SnackbarStage> with SingleTickerProviderStateMixin {
  late final _SnackbarPresenter _presenter;

  @override
  void initState() {
    super.initState();
    _presenter = _SnackbarPresenter(
      vsync: this,
      messenger: widget.messenger,
      accessibleNavigation: () => _accessibleNavigationOf(context),
    );
  }

  @override
  void didUpdateWidget(_SnackbarStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _presenter.updateMessenger(widget.messenger);
  }

  @override
  void dispose() {
    _presenter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SnackbarView(presenter: _presenter, builder: widget.builder);
  }
}

const _defaultDuration = Duration(seconds: 5);
const _withActionDuration = Duration(seconds: 10);
const _persistentDuration = Duration(days: 365);

const _enterDuration = Duration(milliseconds: 250);
const _exitDuration = Duration(milliseconds: 250);

const _fadeCurve = Interval(0.4, 0.6, curve: Curves.easeInCirc);

Duration _resolveDuration(StreamSnackbarProps props) {
  final explicit = props.duration;
  if (explicit != null) return explicit;
  if (props.variant == StreamSnackbarVariant.loading) return _persistentDuration;
  if (props.variant == StreamSnackbarVariant.error && props.action != null) {
    return _persistentDuration;
  }
  if (props.action != null) return _withActionDuration;
  return _defaultDuration;
}

// Entry/exit animation: fade in/out only.
class _SnackbarTransition extends StatefulWidget {
  const _SnackbarTransition({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  State<_SnackbarTransition> createState() => _SnackbarTransitionState();
}

class _SnackbarTransitionState extends State<_SnackbarTransition> {
  late CurvedAnimation _fade;

  @override
  void initState() {
    super.initState();
    _fade = CurvedAnimation(parent: widget.animation, curve: _fadeCurve);
  }

  @override
  void didUpdateWidget(_SnackbarTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation != widget.animation) {
      _fade.dispose();
      _fade = CurvedAnimation(parent: widget.animation, curve: _fadeCurve);
    }
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _fade, child: widget.child);
  }
}
