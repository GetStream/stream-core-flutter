import 'package:flutter/widgets.dart';

import '../../theme/components/stream_toolbar_behavior.dart';

/// Publishes the resolved [StreamToolbarBehavior] of the enclosing toolbar to
/// its slots.
///
/// A [StreamAppBar] / [StreamBottomAppBar] resolves its behaviour once — from
/// its style, then the ambient [StreamAppStyle] — and wraps its slots in a
/// [StreamToolbarScope] so slot widgets ([StreamToolbarButton], header avatars,
/// ...) can match the bar they sit in via [of].
///
/// See also:
///
///  * [StreamToolbarBehavior], the value carried by this scope.
///  * [StreamToolbarButton], which reads it to style itself.
class StreamToolbarScope extends InheritedWidget {
  /// Creates a [StreamToolbarScope] for the given resolved [behavior].
  const StreamToolbarScope({
    super.key,
    required this.behavior,
    required super.child,
  });

  /// The enclosing toolbar's resolved behaviour.
  ///
  /// Always concrete — the bar resolves the style/app-style fallback before
  /// publishing.
  final StreamToolbarBehavior behavior;

  /// The [StreamToolbarBehavior] of the nearest enclosing toolbar.
  ///
  /// Asserts a [StreamToolbarScope] is in scope; call only from within a
  /// [StreamAppBar] / [StreamBottomAppBar] slot. Use [maybeOf] otherwise.
  static StreamToolbarBehavior of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<StreamToolbarScope>();
    assert(scope != null, 'StreamToolbarScope.of() called outside a Stream toolbar.');
    return scope!.behavior;
  }

  /// The [StreamToolbarBehavior] of the nearest enclosing toolbar, or null when
  /// there is none.
  static StreamToolbarBehavior? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<StreamToolbarScope>()?.behavior;
  }

  @override
  bool updateShouldNotify(StreamToolbarScope oldWidget) => behavior != oldWidget.behavior;
}
