import 'package:flutter/widgets.dart';

import '../../theme/stream_surface_style.dart';

/// Publishes the resolved [StreamSurfaceStyle] of the enclosing toolbar to
/// its slots.
///
/// A [StreamAppBar] / [StreamBottomAppBar] wraps its slots in a
/// [StreamToolbarScope] so slot widgets ([StreamToolbarButton], header avatars,
/// ...) can match the bar they sit in via [of].
///
/// See also:
///
///  * [StreamSurfaceStyle], the value carried by this scope.
///  * [StreamToolbarButton], which reads it to style itself.
class StreamToolbarScope extends InheritedWidget {
  /// Creates a [StreamToolbarScope] for the given resolved [behavior].
  const StreamToolbarScope({
    super.key,
    required this.behavior,
    required super.child,
  });

  /// The enclosing toolbar's resolved behaviour.
  final StreamSurfaceStyle behavior;

  /// The [StreamSurfaceStyle] of the nearest enclosing toolbar.
  ///
  /// Throws a [FlutterError] when called outside a [StreamAppBar] /
  /// [StreamBottomAppBar] slot. Use [maybeOf] to get null instead.
  static StreamSurfaceStyle of(BuildContext context) {
    final result = maybeOf(context);
    if (result != null) return result;

    throw FlutterError.fromParts(<DiagnosticsNode>[
      ErrorSummary(
        'StreamToolbarScope.of() called with a context that does not contain a '
        'StreamToolbarScope.',
      ),
      ErrorDescription(
        'No StreamToolbarScope ancestor could be found starting from the '
        'context that was passed to StreamToolbarScope.of(). A '
        'StreamToolbarScope is published to its slots by a StreamAppBar / '
        'StreamBottomAppBar.',
      ),
      ErrorHint(
        'To fix this, ensure this widget sits inside a Stream toolbar slot '
        '(leading / title / trailing).',
      ),
      context.describeElement('The context used was'),
    ]);
  }

  /// The [StreamSurfaceStyle] of the nearest enclosing toolbar, or null when
  /// there is none.
  static StreamSurfaceStyle? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<StreamToolbarScope>()?.behavior;
  }

  @override
  bool updateShouldNotify(StreamToolbarScope oldWidget) => behavior != oldWidget.behavior;
}
