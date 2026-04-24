import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A widget that enlarges the tap target around its [child] to at least
/// [minSize], without changing the child's own size, position, or visual
/// appearance.
///
/// The layout box expands to at least [minSize], the child is placed
/// inside that box according to [alignment], and any hit inside the
/// padded area is redirected to the child so tapping the "empty"
/// padding still triggers the child's gesture handlers.
///
/// This is useful for small controls whose visible footprint is below the
/// accessibility minimum tap target (for example, a 20x20 remove badge
/// overlaid on an attachment tile) but whose tap area should still meet
/// the recommended 48x48 dp minimum from Material Design and WCAG 2.5.5.
///
/// The child keeps its own size and paint bounds. Only the parent's
/// layout size and hit-test area grow. Ink splashes, borders, and
/// decorations drawn by the child are not affected.
///
/// {@tool snippet}
///
/// Expand a 20x20 badge's tap target to 48x48 while keeping the badge
/// visually anchored to the top-end corner:
///
/// ```dart
/// StreamTapTargetPadding(
///   minSize: const Size.square(kMinInteractiveDimension),
///   alignment: AlignmentDirectional.topEnd,
///   child: MyRemoveBadge(),
/// )
/// ```
/// {@end-tool}
class StreamTapTargetPadding extends SingleChildRenderObjectWidget {
  /// Creates a tap-target padding box.
  const StreamTapTargetPadding({
    super.key,
    required this.minSize,
    this.alignment = Alignment.center,
    super.child,
  });

  /// The minimum size this widget will occupy.
  ///
  /// If the child is smaller than [minSize] on either axis, the layout
  /// box is grown to [minSize] on that axis and the child is positioned
  /// inside it according to [alignment]. If the child is larger, the
  /// layout box matches the child's size on that axis.
  final Size minSize;

  /// Where the [child] should be positioned within the padded box when
  /// the box is larger than the child.
  ///
  /// Defaults to [Alignment.center].
  ///
  /// Directional alignments (such as [AlignmentDirectional.topEnd]) are
  /// resolved against the ambient [Directionality].
  final AlignmentGeometry alignment;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderTapTargetPadding(
      minSize: minSize,
      alignment: alignment,
      textDirection: Directionality.maybeOf(context),
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    // ignore: library_private_types_in_public_api
    _RenderTapTargetPadding renderObject,
  ) {
    renderObject
      ..minSize = minSize
      ..alignment = alignment
      ..textDirection = Directionality.maybeOf(context);
  }
}

class _RenderTapTargetPadding extends RenderShiftedBox {
  _RenderTapTargetPadding({
    required Size minSize,
    required AlignmentGeometry alignment,
    required TextDirection? textDirection,
    RenderBox? child,
  }) : _minSize = minSize,
       _alignment = alignment,
       _textDirection = textDirection,
       super(child);

  Size get minSize => _minSize;
  Size _minSize;
  set minSize(Size value) {
    if (_minSize == value) return;
    _minSize = value;
    markNeedsLayout();
  }

  AlignmentGeometry get alignment => _alignment;
  AlignmentGeometry _alignment;
  set alignment(AlignmentGeometry value) {
    if (_alignment == value) return;
    _alignment = value;
    markNeedsLayout();
  }

  TextDirection? get textDirection => _textDirection;
  TextDirection? _textDirection;
  set textDirection(TextDirection? value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsLayout();
  }

  Alignment get _resolvedAlignment => _alignment.resolve(_textDirection);

  @override
  double computeMinIntrinsicWidth(double height) {
    final child = this.child;
    if (child == null) return 0;
    return math.max(child.getMinIntrinsicWidth(height), _minSize.width);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    final child = this.child;
    if (child == null) return 0;
    return math.max(child.getMinIntrinsicHeight(width), _minSize.height);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    final child = this.child;
    if (child == null) return 0;
    return math.max(child.getMaxIntrinsicWidth(height), _minSize.width);
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    final child = this.child;
    if (child == null) return 0;
    return math.max(child.getMaxIntrinsicHeight(width), _minSize.height);
  }

  Size _computeSize({
    required BoxConstraints constraints,
    required ChildLayouter layoutChild,
  }) {
    final child = this.child;
    if (child == null) return Size.zero;
    final childSize = layoutChild(child, constraints);
    final width = math.max(childSize.width, _minSize.width);
    final height = math.max(childSize.height, _minSize.height);
    return constraints.constrain(Size(width, height));
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return _computeSize(
      constraints: constraints,
      layoutChild: ChildLayoutHelper.dryLayoutChild,
    );
  }

  @override
  double? computeDryBaseline(
    covariant BoxConstraints constraints,
    TextBaseline baseline,
  ) {
    final child = this.child;
    if (child == null) return null;
    final result = child.getDryBaseline(constraints, baseline);
    if (result == null) return null;
    final childSize = child.getDryLayout(constraints);
    final parentSize = getDryLayout(constraints);
    return result + _resolvedAlignment.alongOffset(parentSize - childSize as Offset).dy;
  }

  @override
  void performLayout() {
    size = _computeSize(
      constraints: constraints,
      layoutChild: ChildLayoutHelper.layoutChild,
    );
    final child = this.child;
    if (child != null) {
      final childParentData = child.parentData! as BoxParentData;
      childParentData.offset = _resolvedAlignment.alongOffset(size - child.size as Offset);
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    // Only accept hits that land within our own layout bounds. Without
    // this guard, the fallback below would accept hits even when the
    // parent delegates a position that is outside of our size (for
    // example, when we sit directly under a root that does not bounds-
    // check its children).
    if (!size.contains(position)) return false;
    if (super.hitTest(result, position: position)) return true;
    final child = this.child;
    if (child == null) return false;
    // The hit landed inside our padded region but outside the child.
    // Redirect it to the child's center so the child's gesture handlers
    // still fire.
    final center = child.size.center(Offset.zero);
    return result.addWithRawTransform(
      transform: MatrixUtils.forceToPoint(center),
      position: center,
      hitTest: (BoxHitTestResult result, Offset position) {
        assert(position == center, '$position != $center');
        return child.hitTest(result, position: center);
      },
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Size>('minSize', _minSize));
    properties.add(DiagnosticsProperty<AlignmentGeometry>('alignment', _alignment));
    properties.add(EnumProperty<TextDirection>('textDirection', _textDirection, defaultValue: null));
  }
}
