import 'dart:math' as math;

import 'package:flutter/foundation.dart';
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
/// Use the default constructor for a constant inset. Use [StreamSafeArea.driven]
/// when the inset should interpolate toward a target driven by a
/// `ValueListenable<double>` — for a floating surface that hands its space to a
/// panel sliding in beneath it (e.g. a composer whose bottom inset gives way as
/// an attachment picker opens full-bleed).
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
/// Both constructors remove the avoided system insets from the [child]'s
/// [MediaQuery], so a nested safe area doesn't inset the same intrusion twice;
/// [minimum] and [margin] are not removed. For [StreamSafeArea.driven] the
/// removal is independent of the interpolation — the avoided edges are marked
/// handled even as the visible inset collapses toward `to`.
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
    this.maintainBottomViewPadding = false,
    required this.child,
  }) : _listenable = null,
       _to = EdgeInsets.zero;

  /// Creates a safe area whose inset interpolates toward [to] as [listenable]
  /// goes from `0` to `1`.
  ///
  /// At `0` the full `max(systemInset, minimum) + margin` is applied; at `1`
  /// the applied inset is [to] — `EdgeInsets.zero` by default, i.e. the [child]
  /// extends edge-to-edge. Drive it with any `ValueListenable<double>` (an
  /// [Animation], a `ValueNotifier`, …), typically the one that reveals
  /// whatever takes over the space, so the inset gives way in step. Values are
  /// clamped to `[0, 1]`.
  const StreamSafeArea.driven({
    super.key,
    required ValueListenable<double> this._listenable,
    this._to = EdgeInsets.zero,
    this.left = true,
    this.top = true,
    this.right = true,
    this.bottom = true,
    this.minimum = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.maintainBottomViewPadding = false,
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
  /// defaults to false.
  ///
  /// For example, if there is an onscreen keyboard displayed above this widget,
  /// the bottom gap can be maintained above the obstruction rather than being
  /// consumed. This is helpful when the layout contains flexible widgets that
  /// would otherwise visibly move when the keyboard opens due to the change in
  /// the padding value. Setting this to true avoids that shift.
  final bool maintainBottomViewPadding;

  /// The widget below this widget in the tree.
  ///
  /// The padding on the [MediaQuery] for the [child] is adjusted to zero out any
  /// sides that were avoided by this widget.
  final Widget child;

  // Drives the interpolation for [StreamSafeArea.driven]; null for the default.
  final ValueListenable<double>? _listenable;

  // The inset [StreamSafeArea.driven] interpolates toward at `1`.
  final EdgeInsets _to;

  /// The insets this widget applies for [context] with the given options.
  ///
  /// `max(systemInset, minimum) + margin` on each edge. This is the full value;
  /// [StreamSafeArea.driven] interpolates it toward its target.
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
    bool maintainBottomViewPadding = false,
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

  EdgeInsets _resolve(BuildContext context) => resolveInsets(
    context,
    left: left,
    top: top,
    right: right,
    bottom: bottom,
    minimum: minimum,
    margin: margin,
    maintainBottomViewPadding: maintainBottomViewPadding,
  );

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));

    final consumed = MediaQuery.removePadding(
      context: context,
      removeLeft: left,
      removeTop: top,
      removeRight: right,
      removeBottom: bottom,
      child: child,
    );

    final listenable = _listenable;
    if (listenable == null) {
      return Padding(padding: _resolve(context), child: consumed);
    }

    return ValueListenableBuilder<double>(
      valueListenable: listenable,
      child: consumed,
      builder: (context, t, child) {
        final applied = EdgeInsets.lerp(_resolve(context), _to, t.clamp(0.0, 1.0))!;
        return Padding(padding: applied, child: child);
      },
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(FlagProperty('left', value: left, ifTrue: 'avoid left padding'))
      ..add(FlagProperty('top', value: top, ifTrue: 'avoid top padding'))
      ..add(FlagProperty('right', value: right, ifTrue: 'avoid right padding'))
      ..add(FlagProperty('bottom', value: bottom, ifTrue: 'avoid bottom padding'))
      ..add(DiagnosticsProperty<EdgeInsets>('minimum', minimum, defaultValue: EdgeInsets.zero))
      ..add(DiagnosticsProperty<EdgeInsets>('margin', margin, defaultValue: EdgeInsets.zero))
      ..add(DiagnosticsProperty<bool>('maintainBottomViewPadding', maintainBottomViewPadding, defaultValue: false))
      ..add(DiagnosticsProperty<ValueListenable<double>>('listenable', _listenable, defaultValue: null))
      ..add(DiagnosticsProperty<EdgeInsets>('to', _to, defaultValue: EdgeInsets.zero));
  }
}
