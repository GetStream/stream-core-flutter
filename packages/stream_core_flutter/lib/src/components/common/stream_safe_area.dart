import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// A widget that insets its child to avoid intrusions by the operating system,
/// with a [minimum] floor and an added [margin], so the child keeps a
/// controlled gap from them rather than sitting flush.
///
/// Each edge is inset by `max(systemInset, minimum) + margin`. Like
/// [SafeArea.minimum], [minimum] raises an edge to at least that much (a larger
/// system inset absorbs it); [margin] is then added on top of every edge. With
/// both at their defaults the widget behaves like a plain [SafeArea].
///
/// {@tool snippet}
///
/// This example keeps a bar at least `32` clear of the bottom of the screen,
/// and more on devices that reserve more:
///
/// ```dart
/// StreamSafeArea(
///   top: false,
///   minimum: const EdgeInsets.only(bottom: 32),
///   child: myBar,
/// )
/// ```
/// {@end-tool}
///
/// ### [MediaQuery] impact
///
/// The padding on the [MediaQuery] for the [child] is adjusted to zero out any
/// sides that were avoided by this widget. The [minimum] and [margin] are not
/// removed.
///
/// See also:
///
///  * [SafeArea], which insets only to the safe area (with an optional minimum
///    floor) and cannot add a margin beyond it.
///  * [Padding], for insetting widgets in general.
///  * [MediaQuery], from which the safe area is obtained.
class StreamSafeArea extends StatelessWidget {
  /// Creates a widget that avoids operating system intrusions by at least
  /// [minimum], plus [margin].
  const StreamSafeArea({
    super.key,
    this.left = true,
    this.top = true,
    this.right = true,
    this.bottom = true,
    this.minimum = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.maintainBottomViewPadding = true,
    required this.child,
  });

  /// Whether to avoid system intrusions on the left ([minimum] and [margin] apply either way).
  final bool left;

  /// Whether to avoid system intrusions at the top of the screen, typically the
  /// system status bar ([minimum] and [margin] apply either way).
  final bool top;

  /// Whether to avoid system intrusions on the right ([minimum] and [margin] apply either way).
  final bool right;

  /// Whether to avoid system intrusions on the bottom of the screen, typically
  /// the navigation bar or home indicator ([minimum] and [margin] apply either way).
  final bool bottom;

  /// The minimum inset to apply on each edge.
  ///
  /// The greater of this and the system inset is used, before [margin] is added.
  final EdgeInsets minimum;

  /// The margin to apply beyond the safe area.
  ///
  /// Added to every edge on top of the system inset (or [minimum], whichever is
  /// greater).
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

  /// The insets this widget applies for [context] with the given options —
  /// `max(systemInset, minimum) + margin` on each edge.
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
    EdgeInsets minimum = EdgeInsets.zero,
    EdgeInsets margin = EdgeInsets.zero,
    bool maintainBottomViewPadding = true,
  }) {
    final padding = MediaQuery.paddingOf(context);
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final bottomSystem = maintainBottomViewPadding ? viewPadding.bottom : padding.bottom;
    return EdgeInsets.only(
      top: math.max(top ? padding.top : 0.0, minimum.top) + margin.top,
      left: math.max(left ? padding.left : 0.0, minimum.left) + margin.left,
      right: math.max(right ? padding.right : 0.0, minimum.right) + margin.right,
      bottom: math.max(bottom ? bottomSystem : 0.0, minimum.bottom) + margin.bottom,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      minimum: minimum,
      maintainBottomViewPadding: maintainBottomViewPadding,
      child: Padding(padding: margin, child: child),
    );
  }
}
