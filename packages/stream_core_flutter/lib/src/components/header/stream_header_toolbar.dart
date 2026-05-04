import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Default height of [StreamAppBar] and [StreamSheetHeader] per the Figma
/// design system.
const double kStreamHeaderHeight = 72;

/// Three-slot horizontal layout shared by [StreamAppBar] and
/// [StreamSheetHeader].
///
/// Lays out an optional [leading] / [trailing] flush against the bar's start
/// and end edges (after [padding]) and an optional [middle] centred in the
/// bar's full width — so an asymmetric leading and trailing don't shift the
/// title off-centre. The middle is constrained to the symmetric space
/// reserved between the side slots so it never overlaps either of them.
///
/// Each slot is vertically centred inside the available content height. The
/// toolbar takes its size from the parent's tight height constraint —
/// callers are responsible for sitting in a fixed-height slot (e.g. via
/// [PreferredSize] or a [SizedBox] using [kStreamHeaderHeight]).
///
/// [padding] is the bar-edge padding around all three slots; [spacing] is
/// the minimum gap reserved between the middle and either side slot.
class StreamHeaderToolbar extends StatelessWidget {
  /// Creates a header toolbar layout with the given slots.
  const StreamHeaderToolbar({
    super.key,
    this.leading,
    this.middle,
    this.trailing,
    this.padding = EdgeInsets.zero,
    this.spacing = 0,
  });

  /// The widget anchored at the start edge.
  final Widget? leading;

  /// The widget centred in the bar's full inner width.
  final Widget? middle;

  /// The widget anchored at the end edge.
  final Widget? trailing;

  /// Padding applied around all three slots.
  final EdgeInsetsGeometry padding;

  /// Minimum gap reserved between the middle slot and either side slot.
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final textDirection = Directionality.of(context);
    return CustomMultiChildLayout(
      delegate: _StreamHeaderToolbarLayout(
        spacing: spacing,
        textDirection: textDirection,
        padding: padding.resolve(textDirection),
      ),
      children: [
        if (leading != null) LayoutId(id: _Slot.leading, child: leading!),
        if (middle != null) LayoutId(id: _Slot.middle, child: middle!),
        if (trailing != null) LayoutId(id: _Slot.trailing, child: trailing!),
      ],
    );
  }
}

enum _Slot { leading, middle, trailing }

class _StreamHeaderToolbarLayout extends MultiChildLayoutDelegate {
  _StreamHeaderToolbarLayout({
    required this.padding,
    required this.spacing,
    required this.textDirection,
  });

  final EdgeInsets padding;
  final double spacing;
  final TextDirection textDirection;

  @override
  Size getSize(BoxConstraints constraints) => constraints.biggest;

  @override
  void performLayout(Size size) {
    final innerLeft = padding.left;
    final innerRight = size.width - padding.right;
    final innerWidth = math.max<double>(0, innerRight - innerLeft);
    final innerHeight = math.max<double>(0, size.height - padding.top - padding.bottom);
    final isLtr = textDirection == TextDirection.ltr;

    var leadingWidth = 0.0;
    var trailingWidth = 0.0;

    if (hasChild(_Slot.leading)) {
      final slotSize = layoutChild(_Slot.leading, .loose(Size(innerWidth, innerHeight)));
      leadingWidth = slotSize.width;
      final dx = isLtr ? innerLeft : innerRight - leadingWidth;
      final dy = padding.top + (innerHeight - slotSize.height) / 2;
      positionChild(_Slot.leading, Offset(dx, dy));
    }

    if (hasChild(_Slot.trailing)) {
      final slotSize = layoutChild(_Slot.trailing, .loose(Size(innerWidth, innerHeight)));
      trailingWidth = slotSize.width;
      final dx = isLtr ? innerRight - trailingWidth : innerLeft;
      final dy = padding.top + (innerHeight - slotSize.height) / 2;
      positionChild(_Slot.trailing, Offset(dx, dy));
    }

    if (hasChild(_Slot.middle)) {
      // Reserve symmetric space on both sides — based on the wider of the
      // two side slots — so the middle stays centred even when leading and
      // trailing differ in width. Trades a slightly tighter middle for
      // perfect centring.
      final reservedSide = math.max(leadingWidth, trailingWidth);
      final maxMiddleWidth = math.max<double>(0, innerWidth - 2 * reservedSide - 2 * spacing);
      final slotSize = layoutChild(_Slot.middle, .loose(Size(maxMiddleWidth, innerHeight)));
      final dx = (size.width - slotSize.width) / 2;
      final dy = padding.top + (innerHeight - slotSize.height) / 2;
      positionChild(_Slot.middle, Offset(dx, dy));
    }
  }

  @override
  bool shouldRelayout(covariant _StreamHeaderToolbarLayout oldDelegate) {
    return padding != oldDelegate.padding ||
        spacing != oldDelegate.spacing ||
        textDirection != oldDelegate.textDirection;
  }
}
