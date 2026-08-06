import 'package:flutter/widgets.dart';

/// A [SafeArea] that additionally insets its [child] by a per-side [margin]
/// beyond the system insets.
///
/// Where [SafeArea] pads each edge to `max(systemInset, minimum)`, this composes
/// it and adds [margin] on top — the padding becomes `systemInset + margin`. A
/// surface pinned to an edge then keeps a consistent gap beyond the status bar,
/// navigation bar, notch, or home indicator instead of sitting flush against
/// it, and still gets at least [margin] on a device that reports no inset.
///
/// Unlike [SafeArea], [maintainBottomViewPadding] defaults to `true`, so the
/// bottom gap is measured from [MediaQueryData.viewPadding] and stays put when a
/// keyboard opens rather than collapsing — the sensible default for a floating
/// surface. Set it to `false` for [SafeArea]'s standard behaviour.
///
/// The applied insets are available without the widget via [resolveInsets] —
/// useful when the value also feeds something else, such as a gradient painted
/// behind [child].
///
/// See also:
///
///  * [SafeArea], which floors at the system inset rather than adding to it.
class StreamSafeArea extends StatelessWidget {
  /// Creates a safe area that insets [child] by [margin] beyond the system insets.
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

  /// Whether the bottom gap is measured from [MediaQueryData.viewPadding] rather
  /// than [MediaQueryData.padding], so it survives an open keyboard instead of
  /// collapsing.
  ///
  /// Defaults to `true` — unlike [SafeArea.maintainBottomViewPadding], which
  /// defaults to `false` — because a surface with a [margin] is typically
  /// floating and should keep a stable gap.
  final bool maintainBottomViewPadding;

  /// The widget below this one in the tree.
  final Widget child;

  /// The insets [StreamSafeArea] applies for [context] with the given options —
  /// the system inset on each enabled edge, plus [margin].
  ///
  /// Mirrors the composed [SafeArea]: the sides and top read
  /// [MediaQueryData.padding]; the bottom reads [MediaQueryData.viewPadding] when
  /// [maintainBottomViewPadding] is `true`, otherwise [MediaQueryData.padding].
  /// Use this when the value feeds something besides padding (e.g. a background
  /// gradient) as well.
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
