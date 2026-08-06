import 'package:flutter/widgets.dart';

/// Keeps a fixed [margin] between its [child] and the system insets, so the
/// child never sits flush against them.
///
/// Each enabled edge is inset by the system inset there *plus* [margin]. A
/// surface pinned to an edge therefore floats a consistent gap clear of the
/// status bar, navigation bar, notch, or home indicator, and still gets at
/// least [margin] on an edge that reports no inset. Where a [SafeArea] stops at
/// the system inset, this adds [margin] beyond it.
///
/// The bottom gap holds steady while an on-screen keyboard is open rather than
/// collapsing; set [maintainBottomViewPadding] to `false` to opt out.
///
/// Read the same insets as a value with [resolveInsets] — for example to size a
/// decoration painted behind [child].
///
/// {@tool snippet}
///
/// Float a bar a uniform 16dp clear of the bottom edge:
///
/// ```dart
/// StreamSafeArea(
///   top: false,
///   margin: const EdgeInsets.all(16),
///   child: myBar,
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [SafeArea], which insets only as far as the system inset, without a margin.
class StreamSafeArea extends StatelessWidget {
  /// Creates a safe area that keeps [margin] between [child] and the system insets.
  const StreamSafeArea({
    super.key,
    this.top = true,
    this.bottom = true,
    this.left = true,
    this.right = true,
    this.margin = EdgeInsets.zero,
    this.maintainBottomViewPadding = true,
    required this.child,
  });

  /// Whether the top edge is inset by the system top inset ([margin] applies either way).
  final bool top;

  /// Whether the bottom edge is inset by the system bottom inset ([margin] applies either way).
  final bool bottom;

  /// Whether the left edge is inset by the system left inset ([margin] applies either way).
  final bool left;

  /// Whether the right edge is inset by the system right inset ([margin] applies either way).
  final bool right;

  /// The gap kept between [child] and each edge, added beyond the system inset.
  final EdgeInsets margin;

  /// Whether the bottom gap holds steady while a keyboard is open instead of
  /// collapsing.
  ///
  /// Defaults to `true`, unlike [SafeArea.maintainBottomViewPadding], because a
  /// surface with a [margin] is usually floating and wants a stable gap.
  final bool maintainBottomViewPadding;

  /// The widget below this widget in the tree.
  final Widget child;

  /// The insets this widget applies for [context] with the given options — the
  /// system inset on each enabled edge, plus [margin].
  ///
  /// Use this when the value is also needed directly, such as to size a
  /// decoration painted behind the child. [maintainBottomViewPadding] governs
  /// the bottom edge exactly as it does on the widget.
  static EdgeInsets resolveInsets(
    BuildContext context, {
    bool top = true,
    bool bottom = true,
    bool left = true,
    bool right = true,
    EdgeInsets margin = EdgeInsets.zero,
    bool maintainBottomViewPadding = true,
  }) {
    final padding = MediaQuery.paddingOf(context);
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final bottomInset = maintainBottomViewPadding ? viewPadding.bottom : padding.bottom;
    return EdgeInsets.only(
      top: (top ? padding.top : 0.0) + margin.top,
      left: (left ? padding.left : 0.0) + margin.left,
      right: (right ? padding.right : 0.0) + margin.right,
      bottom: (bottom ? bottomInset : 0.0) + margin.bottom,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      maintainBottomViewPadding: maintainBottomViewPadding,
      child: Padding(padding: margin, child: child),
    );
  }
}
