import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// A [SafeArea] that floats its [child] a fixed [margin] clear of the system
/// insets, instead of sitting flush against them.
///
/// [SafeArea] pads each edge to `max(systemInset, minimum)`. This instead
/// *adds* [margin] on top of the system inset, so a surface pinned to an edge
/// keeps a consistent gap beyond the status bar, navigation bar, or home
/// indicator — the behaviour a floating bar or pill wants. It reads
/// [MediaQueryData.viewPadding] rather than `padding`, so the gap is stable
/// while a keyboard is open; set [avoidKeyboard] to clear the keyboard too.
///
/// When the resolved insets are also needed as a value — e.g. to size a
/// gradient behind the [child] — read them directly with [resolveInsets].
///
/// See also:
///
///  * [SafeArea], which floors at the system inset rather than adding to it.
class StreamSafeArea extends StatelessWidget {
  /// Creates a safe area that floats [child] by [margin] beyond the system insets.
  const StreamSafeArea({
    super.key,
    this.top = true,
    this.bottom = true,
    this.left = true,
    this.right = true,
    this.margin = EdgeInsets.zero,
    this.avoidKeyboard = false,
    required this.child,
  });

  /// Whether to inset the top edge by the system top inset ([margin] applies regardless).
  final bool top;

  /// Whether to inset the bottom edge by the system bottom inset ([margin] applies regardless).
  final bool bottom;

  /// Whether to inset the left edge by the system left inset ([margin] applies regardless).
  final bool left;

  /// Whether to inset the right edge by the system right inset ([margin] applies regardless).
  final bool right;

  /// Breathing space added beyond the system inset on each edge.
  final EdgeInsets margin;

  /// Whether the bottom edge also clears the on-screen keyboard ([MediaQueryData.viewInsets]).
  final bool avoidKeyboard;

  /// The widget below this one in the tree.
  final Widget child;

  /// The insets [StreamSafeArea] resolves for [context] with the given options.
  ///
  /// Returns the padding it would apply — the system [MediaQueryData.viewPadding]
  /// on each enabled edge, plus [margin]. Use this when the value feeds
  /// something besides padding (e.g. a background gradient) as well.
  static EdgeInsets resolveInsets(
    BuildContext context, {
    bool top = true,
    bool bottom = true,
    bool left = true,
    bool right = true,
    EdgeInsets margin = EdgeInsets.zero,
    bool avoidKeyboard = false,
  }) {
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final bottomInset = bottom
        ? (avoidKeyboard ? math.max(viewPadding.bottom, MediaQuery.viewInsetsOf(context).bottom) : viewPadding.bottom)
        : 0.0;
    return EdgeInsets.only(
      top: (top ? viewPadding.top : 0.0) + margin.top,
      left: (left ? viewPadding.left : 0.0) + margin.left,
      right: (right ? viewPadding.right : 0.0) + margin.right,
      bottom: bottomInset + margin.bottom,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: resolveInsets(
        context,
        top: top,
        bottom: bottom,
        left: left,
        right: right,
        margin: margin,
        avoidKeyboard: avoidKeyboard,
      ),
      child: child,
    );
  }
}
