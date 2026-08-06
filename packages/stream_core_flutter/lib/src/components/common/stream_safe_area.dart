import 'package:flutter/widgets.dart';

/// A [SafeArea] that floats its [child] a fixed [margin] clear of the system
/// insets, instead of sitting flush against them.
///
/// [SafeArea] pads each edge to `max(systemInset, minimum)`. This composes it
/// and adds [margin] on top, turning the padding into `systemInset + margin` —
/// so a surface pinned to an edge keeps a consistent gap beyond the status bar,
/// navigation bar, or home indicator rather than sitting flush against it.
///
/// Like [SafeArea] with [SafeArea.maintainBottomViewPadding], the bottom gap is
/// measured from [MediaQueryData.viewPadding], so it stays put when a keyboard
/// covers it rather than collapsing.
///
/// When the resolved insets are also needed as a value — e.g. to size a
/// gradient behind the [child] — read them with [resolveInsets].
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

  /// The widget below this one in the tree.
  final Widget child;

  /// The insets [StreamSafeArea] applies for [context] with the given options —
  /// the system inset on each enabled edge, plus [margin].
  ///
  /// Mirrors the composed [SafeArea]: the sides and top read
  /// [MediaQueryData.padding] while the bottom reads
  /// [MediaQueryData.viewPadding], so it survives a keyboard. Use this when the
  /// value feeds something besides padding (e.g. a background gradient) as well.
  static EdgeInsets resolveInsets(
    BuildContext context, {
    bool top = true,
    bool bottom = true,
    bool left = true,
    bool right = true,
    EdgeInsets margin = EdgeInsets.zero,
  }) {
    final padding = MediaQuery.paddingOf(context);
    final viewPadding = MediaQuery.viewPaddingOf(context);
    return EdgeInsets.only(
      top: (top ? padding.top : 0.0) + margin.top,
      left: (left ? padding.left : 0.0) + margin.left,
      right: (right ? padding.right : 0.0) + margin.right,
      bottom: (bottom ? viewPadding.bottom : 0.0) + margin.bottom,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      maintainBottomViewPadding: true,
      child: Padding(padding: margin, child: child),
    );
  }
}
