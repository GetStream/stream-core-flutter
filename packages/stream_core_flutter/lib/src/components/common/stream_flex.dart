import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A widget that displays its children in a one-dimensional array,
/// supporting negative [spacing] for overlapping layouts.
///
/// [StreamFlex] allows you to control the axis along which the children are
/// placed (horizontal or vertical). The [spacing] parameter can be positive
/// (gap between children), zero (flush), or negative (children overlap).
///
/// If you know the main axis in advance, consider using [StreamRow]
/// (horizontal) or [StreamColumn] (vertical) instead, since that will be
/// less verbose.
///
/// {@tool snippet}
///
/// Overlapping avatars with -8px spacing:
///
/// ```dart
/// StreamRow(
///   spacing: -8,
///   children: [
///     CircleAvatar(child: Text('A')),
///     CircleAvatar(child: Text('B')),
///     CircleAvatar(child: Text('C')),
///   ],
/// )
/// ```
/// {@end-tool}
///
/// ## Layout algorithm
///
/// 1. Layout inflexible children with unbounded main-axis constraints.
/// 2. Distribute remaining main-axis space to flexible children.
/// 3. Layout flexible children with allocated space.
/// 4. Cross-axis extent = maximum child cross extent.
/// 5. Main-axis extent determined by [mainAxisSize] and constraints.
/// 6. Position children according to [mainAxisAlignment] and
///    [crossAxisAlignment], applying [spacing] between each pair.
///
/// With negative spacing, the total main-axis extent shrinks and children
/// are positioned closer together, producing overlap. Later children in the
/// list paint on top of earlier ones (natural z-order).
///
/// See also:
///
///  * [StreamRow], for a horizontal variant.
///  * [StreamColumn], for a vertical variant.
class StreamFlex extends MultiChildRenderObjectWidget {
  /// Creates a flex layout that supports negative spacing.
  ///
  /// The [direction] is required.
  ///
  /// The [spacing] parameter can be negative to produce overlapping children.
  /// When negative, later children in the list paint on top of earlier ones.
  ///
  /// If [crossAxisAlignment] is [CrossAxisAlignment.baseline], then
  /// [textBaseline] must not be null.
  ///
  /// The [textDirection] argument defaults to the ambient [Directionality], if
  /// any. If there is no ambient directionality, and a text direction is going
  /// to be necessary to decide which direction to lay the children in or to
  /// disambiguate `start` or `end` values for the main or cross axis
  /// directions, the [textDirection] must not be null.
  const StreamFlex({
    super.key,
    required this.direction,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.textBaseline, // NO DEFAULT: we don't know what the text's baseline should be
    this.clipBehavior = Clip.none,
    this.spacing = 0.0,
    super.children,
  }) : assert(
         !identical(crossAxisAlignment, CrossAxisAlignment.baseline) || textBaseline != null,
         'textBaseline is required if you specify the crossAxisAlignment with CrossAxisAlignment.baseline',
       );
  // Cannot use == in the assert above instead of identical because of https://github.com/dart-lang/language/issues/1811.

  /// The direction to use as the main axis.
  ///
  /// If you know the axis in advance, then consider using a [StreamRow]
  /// (if it's horizontal) or [StreamColumn] (if it's vertical) instead,
  /// since that will be less verbose.
  final Axis direction;

  /// How the children should be placed along the main axis.
  ///
  /// For example, [MainAxisAlignment.start], the default, places the children
  /// at the start (i.e., the left for a [StreamRow] or the top for a
  /// [StreamColumn]) of the main axis.
  final MainAxisAlignment mainAxisAlignment;

  /// How much space should be occupied in the main axis.
  ///
  /// After allocating space to children, there might be some remaining free
  /// space. This value controls whether to maximize or minimize the amount of
  /// free space, subject to the incoming layout constraints.
  final MainAxisSize mainAxisSize;

  /// How the children should be placed along the cross axis.
  ///
  /// For example, [CrossAxisAlignment.center], the default, centers the
  /// children in the cross axis.
  final CrossAxisAlignment crossAxisAlignment;

  /// Determines the order to lay children out horizontally and how to interpret
  /// `start` and `end` in the horizontal direction.
  ///
  /// Defaults to the ambient [Directionality].
  final TextDirection? textDirection;

  /// Determines the order to lay children out vertically and how to interpret
  /// `start` and `end` in the vertical direction.
  ///
  /// Defaults to [VerticalDirection.down].
  final VerticalDirection verticalDirection;

  /// If aligning items according to their baseline, which baseline to use.
  ///
  /// This must be set if using baseline alignment. There is no default because
  /// there is no way for the framework to know the correct baseline _a priori_.
  final TextBaseline? textBaseline;

  /// How to clip children that extend beyond the widget's bounds.
  ///
  /// Defaults to [Clip.none].
  final Clip clipBehavior;

  /// The amount of space between children along the main axis.
  ///
  /// Positive values add gaps between children. Zero makes children flush.
  /// Negative values cause children to overlap — later children in the list
  /// paint on top of earlier ones.
  ///
  /// Defaults to 0.0.
  final double spacing;

  bool get _needTextDirection {
    switch (direction) {
      case Axis.horizontal:
        return true;
      case Axis.vertical:
        return crossAxisAlignment == CrossAxisAlignment.start || crossAxisAlignment == CrossAxisAlignment.end;
    }
  }

  /// The resolved text direction for layout.
  ///
  /// This value is derived from the [textDirection] property and the ambient
  /// [Directionality]. Returns null when text direction is not needed for
  /// the current layout configuration.
  ///
  /// This method exists so that subclasses of [StreamFlex] that create their
  /// own render objects can reuse the text direction resolution logic.
  @protected
  TextDirection? getEffectiveTextDirection(BuildContext context) {
    return textDirection ?? (_needTextDirection ? Directionality.maybeOf(context) : null);
  }

  @override
  RenderFlex createRenderObject(BuildContext context) {
    return _RenderStreamFlex(
      direction: direction,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: getEffectiveTextDirection(context),
      verticalDirection: verticalDirection,
      textBaseline: textBaseline,
      clipBehavior: clipBehavior,
      spacing: spacing,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderFlex renderObject,
  ) {
    renderObject
      ..direction = direction
      ..mainAxisAlignment = mainAxisAlignment
      ..mainAxisSize = mainAxisSize
      ..crossAxisAlignment = crossAxisAlignment
      ..textDirection = getEffectiveTextDirection(context)
      ..verticalDirection = verticalDirection
      ..textBaseline = textBaseline
      ..clipBehavior = clipBehavior
      ..spacing = spacing;
  }
}

/// A widget that displays its children in a horizontal array,
/// supporting negative [spacing] for overlapping layouts.
///
/// This is the horizontal specialization of [StreamFlex].
///
/// {@tool snippet}
///
/// Overlapping chips with -4px horizontal spacing:
///
/// ```dart
/// StreamRow(
///   spacing: -4,
///   children: [
///     Chip(label: Text('One')),
///     Chip(label: Text('Two')),
///     Chip(label: Text('Three')),
///   ],
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamColumn], the vertical variant.
///  * [StreamFlex], the direction-agnostic variant.
class StreamRow extends StreamFlex {
  /// Creates a horizontal flex layout that supports negative spacing.
  const StreamRow({
    super.key,
    super.mainAxisAlignment,
    super.mainAxisSize,
    super.crossAxisAlignment,
    super.textDirection,
    super.verticalDirection,
    super.textBaseline,
    super.clipBehavior,
    super.spacing,
    super.children,
  }) : super(direction: Axis.horizontal);
}

/// A widget that displays its children in a vertical array,
/// supporting negative [spacing] for overlapping layouts.
///
/// This is the vertical specialization of [StreamFlex].
///
/// {@tool snippet}
///
/// Stacked cards with -12px vertical overlap:
///
/// ```dart
/// StreamColumn(
///   spacing: -12,
///   children: [
///     Card(child: Text('Top')),
///     Card(child: Text('Middle')),
///     Card(child: Text('Bottom')),
///   ],
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamRow], the horizontal variant.
///  * [StreamFlex], the direction-agnostic variant.
class StreamColumn extends StreamFlex {
  /// Creates a vertical flex layout that supports negative spacing.
  const StreamColumn({
    super.key,
    super.mainAxisAlignment,
    super.mainAxisSize,
    super.crossAxisAlignment,
    super.textDirection,
    super.verticalDirection,
    super.textBaseline,
    super.clipBehavior,
    super.spacing,
    super.children,
  }) : super(direction: Axis.vertical);
}

// Render object for [StreamFlex] that supports negative [spacing].
//
// When [spacing] is negative, children overlap along the main axis.
// Later children in the child list paint on top of earlier ones.
class _RenderStreamFlex extends RenderFlex {
  _RenderStreamFlex({
    super.direction,
    super.mainAxisAlignment,
    super.mainAxisSize,
    super.crossAxisAlignment,
    super.textDirection,
    super.verticalDirection,
    super.textBaseline,
    super.clipBehavior,
    double spacing = 0.0,
  }) {
    // RenderFlex asserts spacing >= 0 in its constructor. The setter has no
    // such assertion, so we set the value here to support negative spacing.
    this.spacing = spacing;
  }
}
