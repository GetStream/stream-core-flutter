import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_button_theme.dart';
import '../../theme/components/stream_snackbar_theme.dart';
import '../../theme/primitives/stream_colors.dart';
import '../../theme/primitives/stream_radius.dart';
import '../../theme/primitives/stream_spacing.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/semantics/stream_text_theme.dart';
import '../../theme/stream_theme_extensions.dart';
import '../buttons/stream_button.dart';
import '../common/stream_loading_spinner.dart';

/// Variants of [StreamSnackbar].
///
/// Each variant maps to a leading visual and a default auto-dismiss
/// policy. See [StreamSnackbar.duration] for the dismissal rules.
///
/// See also:
///
///  * [StreamSnackbar.variant], which selects one of these variants.
enum StreamSnackbarVariant {
  /// Neutral feedback with no leading icon.
  neutral,

  /// Positive confirmation with a leading checkmark.
  success,

  /// Failure or destructive outcome with a leading exclamation icon.
  error,

  /// In-progress operation with a leading spinner.
  ///
  /// Defaults to a persistent display until explicitly dismissed.
  loading,
}

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
  /// [StreamSnackbarMessenger.close]. The exit animation
  /// played.
  dismiss,

  /// Removed without an exit animation. Fires when the messenger is
  /// disposed while a snackbar is still queued.
  remove,
}

/// An action button rendered at the trailing end of a [StreamSnackbar].
///
/// Pressing the action runs [onPressed] and dismisses the snackbar with
/// [StreamSnackbarClosedReason.action].
///
/// {@tool snippet}
///
/// An undo affordance after a destructive action:
///
/// ```dart
/// StreamSnackbarAction(
///   label: const Text('Undo'),
///   onPressed: () => restore(messageId),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamSnackbar.action], the field that holds this value.
@immutable
class StreamSnackbarAction {
  /// Creates an action with a label and a press handler.
  const StreamSnackbarAction({
    required this.label,
    required this.onPressed,
  });

  /// The action's label.
  ///
  /// Typically a [Text]; the snackbar wraps it in a [DefaultTextStyle]
  /// that inherits the foreground colour.
  final Widget label;

  /// Called when the user presses the action button.
  ///
  /// After this callback runs the snackbar is auto-dismissed with
  /// [StreamSnackbarClosedReason.action].
  final VoidCallback onPressed;
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
  StreamSnackbarController show(StreamSnackbar snackbar) {
    assert(!_disposed, 'show called after dispose');
    final hosted = _HostedSnackbar(snackbar: snackbar, host: this);
    _queue.add(hosted);
    if (_queue.length == 1) notifyListeners();
    return hosted.controller;
  }

  /// Dismisses the currently-displayed snackbar (if any) with [reason].
  /// No-op when the queue is empty.
  void close([StreamSnackbarClosedReason reason = .dismiss]) {
    if (_queue.isEmpty) return;
    _requestExit(_queue.first, reason);
  }

  /// Returns the nearest [StreamSnackbarMessenger] ancestor provided by a
  /// [StreamSnackbarHost], [StreamSnackbarPopup], or [StreamSnackbarScope].
  ///
  /// Throws a [FlutterError] if none is found; use [maybeOf] for a
  /// nullable lookup.
  static StreamSnackbarMessenger of(BuildContext context) {
    final messenger = maybeOf(context);
    if (messenger != null) return messenger;
    throw FlutterError(
      'StreamSnackbarMessenger.of() called without an enclosing snackbar surface.\n'
      'Wrap the relevant subtree with `StreamSnackbarScope(child: ...)` for '
      'app-wide snackbars, or `StreamSnackbarPopup(child: ...)` for an '
      'anchored popup.',
    );
  }

  /// Returns the nearest [StreamSnackbarMessenger] ancestor, or null if none
  /// is found.
  ///
  /// See [of] for a non-null variant that throws.
  static StreamSnackbarMessenger? maybeOf(BuildContext context) {
    final marker = context.dependOnInheritedWidgetOfExactType<_StreamSnackbarHostProvider>();
    return marker?.messenger;
  }

  // Requests the head of the queue to exit with [reason]. The host widget
  // picks up the request, plays the exit animation, then calls _finalize
  // to pop the queue.
  void _requestExit(_HostedSnackbar hosted, StreamSnackbarClosedReason reason) {
    if (_queue.isEmpty || _queue.first != hosted) return;
    if (hosted._requestedExit != null) return;
    hosted._requestedExit = reason;
    notifyListeners();
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
  State<StreamSnackbarHost> createState() => _StreamSnackbarMessenger();
}

class _StreamSnackbarMessenger extends State<StreamSnackbarHost> {
  @override
  Widget build(BuildContext context) {
    return _StreamSnackbarHostProvider(
      messenger: widget.messenger,
      child: _SnackbarStage(
        messenger: widget.messenger,
        builder: (context, animation, child) {
          final style = context.streamSnackbarTheme.style;
          final defaults = _StreamSnackbarDefaults(context);
          final effectiveMargin = (style?.margin ?? defaults.margin).resolve(Directionality.of(context));

          return Padding(
            padding: effectiveMargin,
            child: Center(
              child: _SnackbarTransition(animation: animation, child: child),
            ),
          );
        },
      ),
    );
  }
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

/// An anchored render slot that floats snackbars above a [child].
///
/// Renders into the surrounding [Overlay], with the snackbar's bottom edge
/// aligned to [child]'s top edge. Use this for small surfaces (composer,
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
  }) : externalMessenger = null;

  /// Creates a popup that delegates to an externally-owned [messenger].
  /// The caller is responsible for disposing [messenger].
  const StreamSnackbarPopup.withState({
    super.key,
    required StreamSnackbarMessenger messenger,
    required this.child,
  }) : externalMessenger = messenger;

  /// The anchor widget. The snackbar's bottom edge aligns to this widget's
  /// top edge, centered horizontally over its width.
  final Widget child;

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

                  return Positioned(
                    left: 0,
                    top: 0,
                    child: CompositedTransformFollower(
                      link: _link,
                      targetAnchor: Alignment.topCenter,
                      followerAnchor: Alignment.bottomCenter,
                      offset: Offset(0, -effectiveMargin.bottom),
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

// Internal staging widget — owns the enter/exit animation, the timeout
// timer, the Dismissible swipe, and the currently-showing _HostedSnackbar.
// Shared between Host and Popup via the [builder] callback that wraps the
// snackbar with positioning.
class _SnackbarStage extends StatefulWidget {
  const _SnackbarStage({
    required this.messenger,
    required this.builder,
  });

  final StreamSnackbarMessenger messenger;
  final Widget Function(BuildContext context, Animation<double> animation, Widget child) builder;

  @override
  State<_SnackbarStage> createState() => _SnackbarStageState();
}

class _SnackbarStageState extends State<_SnackbarStage> with SingleTickerProviderStateMixin {
  late final AnimationController _animation;
  Timer? _timer;
  _HostedSnackbar? _showing;
  var _exiting = false;

  @override
  void initState() {
    super.initState();
    _animation = AnimationController(
      vsync: this,
      duration: _enterDuration,
      reverseDuration: _exitDuration,
    );
    widget.messenger.addListener(_onControllerChanged);
    _syncWithController();
  }

  @override
  void didUpdateWidget(_SnackbarStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.messenger != widget.messenger) {
      oldWidget.messenger.removeListener(_onControllerChanged);
      widget.messenger.addListener(_onControllerChanged);
      _timer?.cancel();
      _timer = null;
      _exiting = false;
      _showing = null;
      _animation.value = 0;
      _syncWithController();
    }
  }

  @override
  void dispose() {
    widget.messenger.removeListener(_onControllerChanged);
    _timer?.cancel();
    _animation.dispose();
    super.dispose();
  }

  void _onControllerChanged() => _syncWithController();

  void _syncWithController() {
    final next = widget.messenger._queue.isEmpty ? null : widget.messenger._queue.first;

    if (identical(next, _showing)) {
      final hosted = _showing;
      if (hosted != null && hosted._requestedExit != null && !_exiting) {
        _startExit(hosted, hosted._requestedExit!);
      }
      return;
    }

    if (_showing != null) return;

    if (next != null) {
      _showing = next;
      _exiting = false;
      setState(() {});
      _animation.forward(from: 0).whenComplete(_startTimer);
    }
  }

  void _startTimer() {
    if (!mounted) return;
    final hosted = _showing;
    if (hosted == null) return;
    final duration = _resolveDuration(hosted.snackbar.props);
    if (duration == _persistentDuration) return;
    _timer = Timer(duration, () {
      final current = _showing;
      if (current == null) return;
      _startExit(current, StreamSnackbarClosedReason.timeout);
    });
  }

  Future<void> _startExit(_HostedSnackbar hosted, StreamSnackbarClosedReason reason) async {
    if (_exiting || !mounted) return;
    _exiting = true;
    _timer?.cancel();
    await _animation.reverse();
    if (!mounted) return;
    _showing = null;
    _exiting = false;
    _animation.value = 0;
    setState(() {});
    widget.messenger._finalize(hosted, reason);
  }

  void _handleSwipeDismissed() {
    if (_exiting || !mounted) return;
    final hosted = _showing;
    if (hosted == null) return;
    _exiting = true;
    _timer?.cancel();
    _showing = null;
    _animation.value = 0;
    setState(() {});
    widget.messenger._finalize(hosted, StreamSnackbarClosedReason.swipe);
    _exiting = false;
  }

  @override
  Widget build(BuildContext context) {
    final hosted = _showing;
    if (hosted == null) return const SizedBox.shrink();
    final dismissible = Dismissible(
      key: ObjectKey(hosted),
      direction: DismissDirection.down,
      onDismissed: (_) => _handleSwipeDismissed(),
      child: hosted.snackbar,
    );
    return widget.builder(context, _animation, dismissible);
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

/// Wraps a subtree with a managed [StreamSnackbarMessenger] and renders the
/// current snackbar at the bottom of itself.
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

  /// The subtree that can show snackbars via [StreamSnackbar.show].
  final Widget child;

  /// External messenger used when constructed via [withState].
  final StreamSnackbarMessenger? externalMessenger;

  @override
  State<StreamSnackbarScope> createState() => _StreamSnackbarScopeState();
}

class _StreamSnackbarScopeState extends State<StreamSnackbarScope> {
  StreamSnackbarMessenger? _ownedMessenger;

  StreamSnackbarMessenger get _effectiveMessenger {
    return widget.externalMessenger ?? (_ownedMessenger ??= StreamSnackbarMessenger());
  }

  @override
  void dispose() {
    _ownedMessenger?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _StreamSnackbarHostProvider(
      messenger: _effectiveMessenger,
      child: Stack(
        children: [
          widget.child,
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: StreamSnackbarHost(messenger: _effectiveMessenger),
            ),
          ),
        ],
      ),
    );
  }
}

/// A transient, pill-shaped feedback container.
///
/// Pass an instance to [StreamSnackbarMessenger.show] (looked up
/// via [StreamSnackbarMessenger.of] in the convenience path, or held directly
/// for explicit ownership). The call returns a [StreamSnackbarController]
/// for awaiting dismissal and closing programmatically.
///
/// Visual styling is themable via [StreamSnackbarStyle]; per-app rendering
/// is overridable via [StreamComponentBuilders.snackbar].
///
/// {@tool snippet}
///
/// Show a brief confirmation via the scope convenience:
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
/// Pair a variant with an action and await the result:
///
/// ```dart
/// final controller = StreamSnackbarMessenger.of(context).show(
///   StreamSnackbar(
///     message: const Text('Message deleted'),
///     variant: StreamSnackbarVariant.success,
///     action: StreamSnackbarAction(label: const Text('Undo'), onPressed: undo),
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
///  * [StreamSnackbarController], the handle returned from `show`.
///  * [StreamSnackbarMessenger], the queue owner.
///  * [StreamSnackbarStyle], for visual customization.
///  * [StreamSnackbarVariant], which drives the leading icon and default
///    duration.
class StreamSnackbar extends StatelessWidget {
  /// Creates a snackbar.
  StreamSnackbar({
    super.key,
    required Widget message,
    StreamSnackbarVariant variant = StreamSnackbarVariant.neutral,
    StreamSnackbarAction? action,
    Duration? duration,
  }) : props = StreamSnackbarProps(
         message: message,
         variant: variant,
         action: action,
         duration: duration,
       );

  /// The properties that configure this snackbar.
  final StreamSnackbarProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).snackbar;
    if (builder != null) return builder(context, props);
    return DefaultStreamSnackbar(props: props);
  }
}

/// Properties for configuring a [StreamSnackbar].
///
/// See also:
///
///  * [StreamSnackbar], which uses these properties.
class StreamSnackbarProps {
  /// Creates properties for a snackbar.
  const StreamSnackbarProps({
    required this.message,
    this.variant = StreamSnackbarVariant.neutral,
    this.action,
    this.duration,
  });

  /// The message displayed inside the snackbar.
  ///
  /// Typically a [Text]; the snackbar wraps it in a [DefaultTextStyle]
  /// that resolves the foreground colour and clips to a single line.
  final Widget message;

  /// The visual variant.
  ///
  /// Drives the leading icon and, for [StreamSnackbarVariant.loading], the
  /// default persistent duration.
  final StreamSnackbarVariant variant;

  /// An optional trailing action button.
  final StreamSnackbarAction? action;

  /// How long the snackbar remains on screen before auto-dismissing.
  ///
  /// When null, follows the design system's auto-dismiss rules:
  ///  * [StreamSnackbarVariant.loading] is persistent.
  ///  * [StreamSnackbarVariant.error] with an action is persistent.
  ///  * Otherwise, a snackbar with an [action] lingers 10 s; a snackbar
  ///    without an action auto-dismisses after 5 s.
  final Duration? duration;
}

/// The default implementation of [StreamSnackbar].
///
/// See also:
///
///  * [StreamSnackbar], the public API widget.
///  * [StreamSnackbarProps], which configures this widget.
class DefaultStreamSnackbar extends StatelessWidget {
  /// Creates a default snackbar with the given [props].
  const DefaultStreamSnackbar({super.key, required this.props});

  /// The properties that configure this snackbar.
  final StreamSnackbarProps props;

  void _handleActionPressed(BuildContext context) {
    props.action?.onPressed.call();
    StreamSnackbarMessenger.maybeOf(context)?.close(StreamSnackbarClosedReason.action);
  }

  @override
  Widget build(BuildContext context) {
    final style = context.streamSnackbarTheme.style;
    final defaults = _StreamSnackbarDefaults(context);
    final spacing = context.streamSpacing;

    final effectiveBackgroundColor = style?.backgroundColor ?? defaults.backgroundColor;
    final effectiveForegroundColor = style?.foregroundColor ?? defaults.foregroundColor;
    final effectiveElevation = style?.elevation ?? defaults.elevation;

    final effectiveSide = style?.side ?? defaults.side;
    final effectiveShape = (style?.shape ?? defaults.shape).copyWith(side: effectiveSide);

    final effectivePadding = style?.padding ?? defaults.padding;
    final effectiveConstraints = style?.constraints ?? defaults.constraints;
    final effectiveTextStyle = (style?.textStyle ?? defaults.textStyle).copyWith(color: effectiveForegroundColor);
    final effectiveActionStyle = style?.actionStyle ?? defaults.actionStyle;

    final variant = props.variant;
    final hasLeading = variant != StreamSnackbarVariant.neutral;

    return ConstrainedBox(
      constraints: effectiveConstraints,
      child: Material(
        shape: effectiveShape,
        elevation: effectiveElevation,
        color: effectiveBackgroundColor,
        child: Padding(
          padding: effectivePadding,
          child: Row(
            mainAxisSize: .min,
            spacing: spacing.xxs,
            children: [
              Flexible(
                child: Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: hasLeading ? spacing.xxs : spacing.xs,
                    end: spacing.xs,
                  ),
                  child: Row(
                    mainAxisSize: .min,
                    spacing: spacing.xs,
                    children: [
                      ?_buildLeading(context, variant, effectiveForegroundColor),
                      Flexible(
                        child: DefaultTextStyle(
                          maxLines: 1,
                          style: effectiveTextStyle,
                          overflow: TextOverflow.ellipsis,
                          child: props.message,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (props.action case final action?)
                StreamButton(
                  onPressed: () => _handleActionPressed(context),
                  size: StreamButtonSize.small,
                  type: StreamButtonType.outline,
                  themeStyle: effectiveActionStyle,
                  child: action.label,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildLeading(BuildContext context, StreamSnackbarVariant variant, Color iconColor) {
    final icons = context.streamIcons;
    return switch (variant) {
      .neutral => null,
      .success => Icon(icons.checkmark, size: 20, color: iconColor),
      .error => Icon(icons.exclamationCircleFill, size: 20, color: iconColor),
      .loading => StreamLoadingSpinner(
        size: .sm,
        color: iconColor,
        backgroundColor: StreamColors.transparent,
        trackColor: iconColor.withValues(alpha: 0.32),
      ),
    };
  }
}

class _StreamSnackbarDefaults extends StreamSnackbarStyle {
  _StreamSnackbarDefaults(this._context);

  final BuildContext _context;

  late final StreamColorScheme _colorScheme = _context.streamColorScheme;
  late final StreamTextTheme _textTheme = _context.streamTextTheme;
  late final StreamRadius _radius = _context.streamRadius;
  late final StreamSpacing _spacing = _context.streamSpacing;

  @override
  double get elevation => 3;

  @override
  TextStyle get textStyle => _textTheme.captionDefault;

  @override
  Color get backgroundColor => _colorScheme.backgroundInverse;

  @override
  Color get foregroundColor => _colorScheme.textOnInverse;

  @override
  BoxConstraints get constraints => const BoxConstraints(maxWidth: 370, minHeight: 48);

  @override
  OutlinedBorder get shape => RoundedSuperellipseBorder(borderRadius: .all(_radius.xxxl));

  @override
  EdgeInsetsGeometry get padding => EdgeInsets.symmetric(horizontal: _spacing.xs);

  @override
  EdgeInsetsGeometry get margin => EdgeInsets.symmetric(horizontal: _spacing.md, vertical: _spacing.sm);

  @override
  StreamButtonThemeStyle get actionStyle => StreamButtonThemeStyle.from(
    foregroundColor: foregroundColor,
    borderColor: foregroundColor,
    hoveredOverlayColor: foregroundColor.withValues(alpha: 0.08),
    pressedOverlayColor: foregroundColor.withValues(alpha: 0.16),
  );
}
