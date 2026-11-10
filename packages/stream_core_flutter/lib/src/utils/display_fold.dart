import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

/// The anchor point that puts a modal with no source of its own in the
/// trailing half of a folded window: the top-right corner, or the top-left in
/// a right-to-left locale.
///
/// Without one, a route falls back to the leading half.
@internal
Offset trailingTopAnchorOf(BuildContext context) => switch (Directionality.of(context)) {
  TextDirection.ltr => const Offset(double.maxFinite, 0),
  TextDirection.rtl => Offset.zero,
};
