import 'package:flutter/widgets.dart';

/// A widget that insets its child to avoid intrusions by the operating system,
/// keeping an additional [margin] beyond them so the child never sits flush.
///
/// When a [margin] is specified, it is added to the safe area padding on every
/// edge — so the child clears the status bar, navigation bar, notch, or home
/// indicator by [margin], and is inset by [margin] even on an edge with no
/// intrusion. This is the difference from [SafeArea], which insets only as far
/// as the safe area.
///
/// {@tool snippet}
///
/// This example floats a bar a uniform 16dp above the bottom of the screen,
/// clear of the navigation bar or home indicator.
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
/// ### [MediaQuery] impact
///
/// The padding on the [MediaQuery] for the [child] is adjusted to zero out any
/// sides that were avoided by this widget, so a nested safe area does not inset
/// the same intrusion twice. The [margin] is not removed.
///
/// See also:
///
///  * [SafeArea], which insets only as far as the safe area, without a margin.
///  * [Padding], for insetting widgets in general.
///  * [MediaQuery], from which the safe area is obtained.
class StreamSafeArea extends StatelessWidget {
  /// Creates a widget that avoids operating system intrusions by the safe area
  /// plus [margin].
  const StreamSafeArea({
    super.key,
    this.left = true,
    this.top = true,
    this.right = true,
    this.bottom = true,
    this.margin = EdgeInsets.zero,
    this.maintainBottomViewPadding = true,
    required this.child,
  });

  /// Whether to avoid system intrusions on the left ([margin] applies either way).
  final bool left;

  /// Whether to avoid system intrusions at the top of the screen, typically the
  /// system status bar ([margin] applies either way).
  final bool top;

  /// Whether to avoid system intrusions on the right ([margin] applies either way).
  final bool right;

  /// Whether to avoid system intrusions on the bottom of the screen, typically
  /// the navigation bar or home indicator ([margin] applies either way).
  final bool bottom;

  /// The margin to apply beyond the safe area.
  ///
  /// Added to the safe area padding on every edge.
  final EdgeInsets margin;

  /// Specifies whether this widget should maintain the bottom
  /// [MediaQueryData.viewPadding] instead of the bottom [MediaQueryData.padding],
  /// defaults to true.
  ///
  /// For example, if there is an onscreen keyboard displayed above this widget,
  /// the bottom gap is maintained above the obstruction rather than being
  /// consumed. This keeps a floating surface from visibly moving when the
  /// keyboard opens due to the change in the padding value.
  final bool maintainBottomViewPadding;

  /// The widget below this widget in the tree.
  ///
  /// The padding on the [MediaQuery] for the [child] is adjusted to zero out any
  /// sides that were avoided by this widget.
  final Widget child;

  /// The insets this widget applies for [context] with the given options — the
  /// safe area on each avoided edge, plus [margin].
  ///
  /// Use this when the value is also needed directly, such as to size a
  /// decoration painted behind the child. [maintainBottomViewPadding] governs
  /// the bottom edge exactly as it does on the widget.
  static EdgeInsets resolveInsets(
    BuildContext context, {
    bool left = true,
    bool top = true,
    bool right = true,
    bool bottom = true,
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
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      maintainBottomViewPadding: maintainBottomViewPadding,
      child: Padding(padding: margin, child: child),
    );
  }
}
