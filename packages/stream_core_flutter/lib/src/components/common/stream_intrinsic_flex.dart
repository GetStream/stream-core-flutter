import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// A widget that displays its children in a one-dimensional array,
/// shrink-wrapping its cross-axis to the widest (or tallest) child.
///
/// [StreamIntrinsicFlex] allows you to control the axis along which the
/// children are placed (horizontal or vertical). Unlike [Row]/[Column], the
/// cross-axis extent is resolved from the children instead of expanding to
/// fill available space. The main axis behaves like a standard [Flex] —
/// supporting [Expanded], [Flexible], [mainAxisSize], and
/// [mainAxisAlignment].
///
/// The [spacing] parameter can be positive (gap between children), zero
/// (flush), or negative (children overlap).
///
/// If you know the main axis in advance, consider using
/// [StreamIntrinsicColumn] (vertical) or [StreamIntrinsicRow] (horizontal)
/// instead, since that will be less verbose.
///
/// ## Cross-axis candidates
///
/// By default the cross-axis extent is the largest child's natural extent,
/// clamped to the incoming constraint.
///
/// If one or more children are wrapped in [StreamIntrinsicSizeCandidate],
/// only those children determine the cross-axis extent. All other children
/// are laid out within that extent. If no candidates exist, every child
/// participates.
///
/// {@tool snippet}
///
/// A column that shrink-wraps to the widest child:
///
/// ```dart
/// StreamIntrinsicColumn(
///   spacing: 8.0,
///   children: [
///     MyHeader(),
///     MyContent(),
///     MyFooter(),
///   ],
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// If only specific children should determine the cross-axis extent, wrap
/// them in [StreamIntrinsicSizeCandidate]:
///
/// ```dart
/// StreamIntrinsicColumn(
///   spacing: 8.0,
///   children: [
///     StreamIntrinsicSizeCandidate(child: MyHeader()),
///     StreamIntrinsicSizeCandidate(child: MyContent()),
///     MyFooter(),  // conforms to width of candidates above
///   ],
/// )
/// ```
/// {@end-tool}
///
/// ## Layout algorithm
///
/// 1. Lay out non-flex children with unbounded cross-axis to measure their
///    natural sizes.
/// 2. Distribute remaining main-axis space to flexible children and lay
///    them out with unbounded cross-axis.
/// 3. Resolve the cross-axis extent:
///    - With candidates: `min(max(candidate extents), constraint)`.
///    - Without candidates: `min(max(all extents), constraint)`.
/// 4. Re-lay out each child with `maxCrossAxis = resolvedExtent` so that
///    [Align] and [Wrap] descendants resolve against the edge.
/// 5. Position children using [mainAxisAlignment], [crossAxisAlignment],
///    and direction settings.
/// 6. Final size: resolved cross-axis extent and main-axis extent from
///    [mainAxisSize].
///
/// With negative spacing, the total main-axis extent shrinks and children
/// are positioned closer together, producing overlap. Later children in the
/// list paint on top of earlier ones (natural z-order).
///
/// See also:
///
///  * [StreamIntrinsicColumn], for a vertical variant.
///  * [StreamIntrinsicRow], for a horizontal variant.
///  * [StreamIntrinsicSizeCandidate], to mark specific children as
///    cross-axis candidates.
class StreamIntrinsicFlex extends MultiChildRenderObjectWidget {
  /// Creates an intrinsic flex layout.
  ///
  /// The [direction] is required.
  ///
  /// The [spacing] parameter can be negative to produce overlapping children.
  /// When negative, later children in the list paint on top of earlier ones.
  ///
  /// The [textDirection] argument defaults to the ambient [Directionality], if
  /// any. If there is no ambient directionality, and a text direction is going
  /// to be necessary to disambiguate `start` or `end` values for the main or
  /// cross axis directions, the [textDirection] must not be null.
  const StreamIntrinsicFlex({
    super.key,
    required this.direction,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.min,
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
  ///
  /// [CrossAxisAlignment.stretch] is not supported.
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

  bool get _needTextDirection => switch (direction) {
    Axis.horizontal => true,
    Axis.vertical => crossAxisAlignment == CrossAxisAlignment.start || crossAxisAlignment == CrossAxisAlignment.end,
  };

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
  RenderObject createRenderObject(BuildContext context) {
    return _RenderStreamIntrinsicFlex(
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
    // ignore: library_private_types_in_public_api
    _RenderStreamIntrinsicFlex renderObject,
  ) {
    renderObject
      ..direction = direction
      ..mainAxisAlignment = mainAxisAlignment
      ..mainAxisSize = mainAxisSize
      ..spacing = spacing
      ..crossAxisAlignment = crossAxisAlignment
      ..textBaseline = textBaseline
      ..textDirection = textDirection ?? Directionality.maybeOf(context)
      ..verticalDirection = verticalDirection
      ..clipBehavior = clipBehavior;
  }
}

/// A widget that displays its children in a vertical array,
/// shrink-wrapping its width to the widest child.
///
/// This is the vertical specialization of [StreamIntrinsicFlex]. See
/// [StreamIntrinsicFlex] for details on cross-axis candidates and the
/// layout algorithm.
///
/// {@tool snippet}
///
/// A column that shrink-wraps to the widest child:
///
/// ```dart
/// StreamIntrinsicColumn(
///   spacing: 8.0,
///   children: [
///     MyHeader(),
///     MyContent(),
///     MyFooter(),
///   ],
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamIntrinsicRow], the horizontal variant.
///  * [StreamIntrinsicFlex], the direction-agnostic variant.
///  * [StreamIntrinsicSizeCandidate], to mark specific children as
///    width candidates.
class StreamIntrinsicColumn extends StreamIntrinsicFlex {
  /// Creates a vertical intrinsic flex layout that shrink-wraps its width.
  const StreamIntrinsicColumn({
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

/// A widget that displays its children in a horizontal array,
/// shrink-wrapping its height to the tallest child.
///
/// This is the horizontal specialization of [StreamIntrinsicFlex]. See
/// [StreamIntrinsicFlex] for details on cross-axis candidates and the
/// layout algorithm.
///
/// {@tool snippet}
///
/// A row that shrink-wraps to the tallest child:
///
/// ```dart
/// StreamIntrinsicRow(
///   spacing: 8.0,
///   children: [
///     MySidebar(),
///     MyContent(),
///     MyIcon(),
///   ],
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamIntrinsicColumn], the vertical variant.
///  * [StreamIntrinsicFlex], the direction-agnostic variant.
///  * [StreamIntrinsicSizeCandidate], to mark specific children as
///    height candidates.
class StreamIntrinsicRow extends StreamIntrinsicFlex {
  /// Creates a horizontal intrinsic flex layout that shrink-wraps its height.
  const StreamIntrinsicRow({
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

/// Marks a child of [StreamIntrinsicFlex] as a cross-axis size candidate.
///
/// Only candidates participate in determining the cross-axis extent. If no
/// child is wrapped in this widget, all children participate (default
/// behavior).
///
/// Multiple children can be candidates — the cross-axis extent will be the
/// largest among them.
///
/// This can be combined with [Flexible] or [Expanded] on the same child:
///
/// ```dart
/// StreamIntrinsicColumn(
///   children: [
///     Expanded(
///       child: StreamIntrinsicSizeCandidate(child: MyContent()),
///     ),
///   ],
/// )
/// ```
///
/// {@tool snippet}
///
/// A column where only WidgetA and WidgetB determine the width:
///
/// ```dart
/// StreamIntrinsicColumn(
///   children: [
///     StreamIntrinsicSizeCandidate(child: WidgetA()),  // candidate
///     StreamIntrinsicSizeCandidate(child: WidgetB()),  // candidate
///     WidgetC(),  // conforms to max(A, B) width
///   ],
/// )
/// ```
/// {@end-tool}
class StreamIntrinsicSizeCandidate extends ParentDataWidget<_IntrinsicFlexParentData> {
  /// Creates a widget that marks its child as a cross-axis size candidate.
  const StreamIntrinsicSizeCandidate({
    super.key,
    required super.child,
  });

  @override
  void applyParentData(RenderObject renderObject) {
    final parentData = renderObject.parentData;
    if (parentData is _IntrinsicFlexParentData && !parentData.isSizeCandidate) {
      parentData.isSizeCandidate = true;
      final renderParent = renderObject.parent;
      if (renderParent is RenderObject) {
        renderParent.markNeedsLayout();
      }
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => StreamIntrinsicFlex;
}

class _IntrinsicFlexParentData extends FlexParentData {
  // ignore: type_annotate_public_apis
  var isSizeCandidate = false;
}

// ─── Render object ───

class _RenderStreamIntrinsicFlex extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _IntrinsicFlexParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _IntrinsicFlexParentData> {
  _RenderStreamIntrinsicFlex({
    required Axis direction,
    required MainAxisAlignment mainAxisAlignment,
    required MainAxisSize mainAxisSize,
    required double spacing,
    required CrossAxisAlignment crossAxisAlignment,
    required TextBaseline? textBaseline,
    required TextDirection? textDirection,
    required VerticalDirection verticalDirection,
    required Clip clipBehavior,
  }) : assert(
         crossAxisAlignment != CrossAxisAlignment.stretch,
         'StreamIntrinsicFlex does not support $crossAxisAlignment.',
       ),
       _direction = direction,
       _mainAxisAlignment = mainAxisAlignment,
       _mainAxisSize = mainAxisSize,
       _spacing = spacing,
       _crossAxisAlignment = crossAxisAlignment,
       _textBaseline = textBaseline,
       _textDirection = textDirection,
       _verticalDirection = verticalDirection,
       _clipBehavior = clipBehavior;

  Axis get direction => _direction;
  Axis _direction;
  set direction(Axis value) {
    if (_direction == value) return;
    _direction = value;
    markNeedsLayout();
  }

  MainAxisAlignment get mainAxisAlignment => _mainAxisAlignment;
  MainAxisAlignment _mainAxisAlignment;
  set mainAxisAlignment(MainAxisAlignment value) {
    if (_mainAxisAlignment == value) return;
    _mainAxisAlignment = value;
    markNeedsLayout();
  }

  MainAxisSize get mainAxisSize => _mainAxisSize;
  MainAxisSize _mainAxisSize;
  set mainAxisSize(MainAxisSize value) {
    if (_mainAxisSize == value) return;
    _mainAxisSize = value;
    markNeedsLayout();
  }

  double get spacing => _spacing;
  double _spacing;
  set spacing(double value) {
    if (_spacing == value) return;
    _spacing = value;
    markNeedsLayout();
  }

  CrossAxisAlignment get crossAxisAlignment => _crossAxisAlignment;
  CrossAxisAlignment _crossAxisAlignment;
  set crossAxisAlignment(CrossAxisAlignment value) {
    assert(
      value != CrossAxisAlignment.stretch,
      'StreamIntrinsicFlex does not support $value.',
    );
    if (_crossAxisAlignment == value) return;
    _crossAxisAlignment = value;
    markNeedsLayout();
  }

  TextBaseline? get textBaseline => _textBaseline;
  TextBaseline? _textBaseline;
  set textBaseline(TextBaseline? value) {
    if (_textBaseline == value) return;
    _textBaseline = value;
    markNeedsLayout();
  }

  bool get _isBaselineAligned => switch (_crossAxisAlignment) {
    CrossAxisAlignment.baseline => switch (_direction) {
      Axis.horizontal => true,
      Axis.vertical => false,
    },
    _ => false,
  };

  TextDirection? get textDirection => _textDirection;
  TextDirection? _textDirection;
  set textDirection(TextDirection? value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsLayout();
  }

  VerticalDirection get verticalDirection => _verticalDirection;
  VerticalDirection _verticalDirection;
  set verticalDirection(VerticalDirection value) {
    if (_verticalDirection == value) return;
    _verticalDirection = value;
    markNeedsLayout();
  }

  Clip get clipBehavior => _clipBehavior;
  Clip _clipBehavior;
  set clipBehavior(Clip value) {
    if (_clipBehavior == value) return;
    _clipBehavior = value;
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  bool get _isVertical => _direction == Axis.vertical;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _IntrinsicFlexParentData) {
      child.parentData = _IntrinsicFlexParentData();
    }
  }

  // ── Flex helpers ──

  static int _getFlex(RenderBox child) {
    final data = child.parentData! as _IntrinsicFlexParentData;
    return data.flex ?? 0;
  }

  static FlexFit _getFit(RenderBox child) {
    final data = child.parentData! as _IntrinsicFlexParentData;
    return data.fit ?? FlexFit.tight;
  }

  // ── Axis helpers ──

  double _mainSize(Size s) => _isVertical ? s.height : s.width;
  double _crossSize(Size s) => _isVertical ? s.width : s.height;
  double _maxMain(BoxConstraints c) => _isVertical ? c.maxHeight : c.maxWidth;
  double _maxCross(BoxConstraints c) => _isVertical ? c.maxWidth : c.maxHeight;

  BoxConstraints _withCross(double cross) =>
      _isVertical ? BoxConstraints(maxWidth: cross) : BoxConstraints(maxHeight: cross);

  BoxConstraints _flexConstraints(double minMain, double maxMain, double maxCross) => _isVertical
      ? BoxConstraints(minHeight: minMain, maxHeight: maxMain, maxWidth: maxCross)
      : BoxConstraints(minWidth: minMain, maxWidth: maxMain, maxHeight: maxCross);

  Size _makeSize(double main, double cross) => _isVertical ? Size(cross, main) : Size(main, cross);

  Offset _makeOffset(double main, double cross) => _isVertical ? Offset(cross, main) : Offset(main, cross);

  bool get _flipMainAxis =>
      firstChild != null &&
      (_isVertical ? _verticalDirection == VerticalDirection.up : _textDirection == TextDirection.rtl);

  bool get _flipCrossAxis =>
      firstChild != null &&
      switch (_direction) {
        Axis.vertical => switch (_textDirection) {
          null || TextDirection.ltr => false,
          TextDirection.rtl => true,
        },
        Axis.horizontal => switch (_verticalDirection) {
          VerticalDirection.down => false,
          VerticalDirection.up => true,
        },
      };

  double _childCrossAxisOffset(double freeSpace, bool flipCrossAxis) => switch (_crossAxisAlignment) {
    CrossAxisAlignment.start => flipCrossAxis ? freeSpace : 0.0,
    CrossAxisAlignment.end => flipCrossAxis ? 0.0 : freeSpace,
    CrossAxisAlignment.center => freeSpace / 2.0,
    _ => 0.0,
  };

  bool get _debugHasNecessaryDirections {
    if (RenderObject.debugCheckingIntrinsics) return true;
    if (firstChild != null && lastChild != firstChild) {
      if (!_isVertical) {
        assert(
          _textDirection != null,
          'Horizontal $runtimeType with multiple children has a null textDirection, '
          'so the layout order is undefined.',
        );
      }
    }
    if (_mainAxisAlignment == MainAxisAlignment.start || _mainAxisAlignment == MainAxisAlignment.end) {
      if (!_isVertical) {
        assert(
          _textDirection != null,
          'Horizontal $runtimeType with $mainAxisAlignment has a null textDirection, '
          'so the alignment cannot be resolved.',
        );
      }
    }
    if (_crossAxisAlignment == CrossAxisAlignment.start || _crossAxisAlignment == CrossAxisAlignment.end) {
      if (_isVertical) {
        assert(
          _textDirection != null,
          'Vertical $runtimeType with $_crossAxisAlignment has a null textDirection, '
          'so the cross-axis alignment cannot be resolved.',
        );
      }
    }
    return true;
  }

  // ── Intrinsics ──

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) => switch (_direction) {
    Axis.horizontal => defaultComputeDistanceToHighestActualBaseline(baseline),
    Axis.vertical => defaultComputeDistanceToFirstActualBaseline(baseline),
  };

  @override
  double computeMinIntrinsicWidth(double height) {
    if (_isVertical) return _maxCrossIntrinsic((c) => c.getMinIntrinsicWidth(height));
    return _mainIntrinsicSize((c, e) => c.getMinIntrinsicWidth(e), height);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    if (_isVertical) return _maxCrossIntrinsic((c) => c.getMaxIntrinsicWidth(height));
    return _mainIntrinsicSize((c, e) => c.getMaxIntrinsicWidth(e), height);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    if (_isVertical) return _mainIntrinsicSize((c, e) => c.getMinIntrinsicHeight(e), width);
    return _maxCrossIntrinsic((c) => c.getMinIntrinsicHeight(width));
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    if (_isVertical) return _mainIntrinsicSize((c, e) => c.getMaxIntrinsicHeight(e), width);
    return _maxCrossIntrinsic((c) => c.getMaxIntrinsicHeight(width));
  }

  double _maxCrossIntrinsic(double Function(RenderBox) measure) {
    var candidateExtent = 0.0;
    var allExtent = 0.0;
    var hasCandidates = false;
    var child = firstChild;
    while (child != null) {
      final value = measure(child);
      allExtent = math.max(allExtent, value);
      final data = child.parentData! as _IntrinsicFlexParentData;
      if (data.isSizeCandidate) {
        candidateExtent = math.max(candidateExtent, value);
        hasCandidates = true;
      }
      child = childAfter(child);
    }
    return hasCandidates ? candidateExtent : allExtent;
  }

  /// Main-axis intrinsic size following RenderFlex's algorithm:
  /// inflexible children contribute their full size; flexible children
  /// contribute proportionally via their flex fraction.
  double _mainIntrinsicSize(double Function(RenderBox, double) childSize, double extent) {
    var totalFlex = 0;
    var inflexibleSpace = _spacing * (childCount - 1);
    var maxFlexFraction = 0.0;
    var child = firstChild;
    while (child != null) {
      final flex = _getFlex(child);
      totalFlex += flex;
      if (flex > 0) {
        maxFlexFraction = math.max(maxFlexFraction, childSize(child, extent) / flex);
      } else {
        inflexibleSpace += childSize(child, extent);
      }
      child = childAfter(child);
    }
    return math.max<double>(0, maxFlexFraction * totalFlex + inflexibleSpace);
  }

  // ── Shared sizing (used by both performLayout and computeDryLayout) ──

  _LayoutSizes _computeSizes({
    required BoxConstraints constraints,
    required ChildLayouter layoutChild,
    required ChildBaselineGetter getBaseline,
  }) {
    assert(_debugHasNecessaryDirections);

    final maxMainSize = _maxMain(constraints);
    final canFlex = maxMainSize.isFinite;
    final maxCross = _maxCross(constraints);

    final textBaseline = _isBaselineAligned
        ? (_textBaseline ??
              (throw FlutterError(
                'To use CrossAxisAlignment.baseline, you must also specify '
                'which baseline to use using the "textBaseline" argument.',
              )))
        : null;

    // Pass 1a: lay out non-flex children with unbounded cross-axis.
    var totalFlex = 0;
    var candidateExtent = 0.0;
    var allExtent = 0.0;
    var hasCandidates = false;
    var inflexibleMainTotal = 0.0;
    var maxAscent = 0.0;
    var maxDescent = 0.0;
    var hasBaseline = false;
    RenderBox? firstFlexChild;

    var child = firstChild;
    while (child != null) {
      final data = child.parentData! as _IntrinsicFlexParentData;
      final flex = _getFlex(child);
      if (canFlex && flex > 0) {
        totalFlex += flex;
        firstFlexChild ??= child;
      } else {
        const childConstraints = BoxConstraints();
        final s = layoutChild(child, childConstraints);
        final cross = _crossSize(s);
        inflexibleMainTotal += _mainSize(s);
        allExtent = math.max(allExtent, cross);
        if (data.isSizeCandidate) {
          candidateExtent = math.max(candidateExtent, cross);
          hasCandidates = true;
        }
        if (textBaseline != null) {
          final baselineOffset = getBaseline(child, childConstraints, textBaseline);
          if (baselineOffset != null) {
            maxAscent = math.max(maxAscent, baselineOffset);
            maxDescent = math.max(maxDescent, cross - baselineOffset);
            hasBaseline = true;
          }
        }
      }
      child = childAfter(child);
    }

    // Pass 1b: distribute free main-axis space to flex children.
    final totalSpacing = _spacing * (childCount - 1);
    final freeSpace = math.max<double>(0, maxMainSize - inflexibleMainTotal - totalSpacing);
    final spacePerFlex = totalFlex > 0 ? freeSpace / totalFlex : 0.0;

    // Pass 1c: lay out flex children with their allocation + unbounded cross.
    for (var fc = firstFlexChild; fc != null; fc = childAfter(fc)) {
      final data = fc.parentData! as _IntrinsicFlexParentData;
      final flex = _getFlex(fc);
      if (flex == 0) continue;
      final maxChildExtent = spacePerFlex * flex;
      final minChildExtent = switch (_getFit(fc)) {
        FlexFit.tight => maxChildExtent,
        FlexFit.loose => 0.0,
      };
      final childConstraints = _flexConstraints(minChildExtent, maxChildExtent, double.infinity);
      final s = layoutChild(fc, childConstraints);
      final cross = _crossSize(s);
      allExtent = math.max(allExtent, cross);
      if (data.isSizeCandidate) {
        candidateExtent = math.max(candidateExtent, cross);
        hasCandidates = true;
      }
      if (textBaseline != null) {
        final baselineOffset = getBaseline(fc, childConstraints, textBaseline);
        if (baselineOffset != null) {
          maxAscent = math.max(maxAscent, baselineOffset);
          maxDescent = math.max(maxDescent, cross - baselineOffset);
          hasBaseline = true;
        }
      }
    }

    // Resolve cross-axis extent from candidates (or all children).
    // Baseline-aligned children also contribute via maxAscent + maxDescent.
    var resolvedExtent = hasCandidates ? candidateExtent : allExtent;
    if (hasBaseline) {
      resolvedExtent = math.max(resolvedExtent, maxAscent + maxDescent);
    }
    final crossExtent = math.min(resolvedExtent, maxCross);

    // Pass 2: re-lay out every child with the resolved cross-axis constraint.
    var totalMain = 0.0;
    child = firstChild;
    while (child != null) {
      final flex = _getFlex(child);
      Size s;
      if (totalFlex > 0 && flex > 0) {
        final maxChildExtent = spacePerFlex * flex;
        final minChildExtent = switch (_getFit(child)) {
          FlexFit.tight => maxChildExtent,
          FlexFit.loose => 0.0,
        };
        s = layoutChild(child, _flexConstraints(minChildExtent, maxChildExtent, crossExtent));
      } else {
        s = layoutChild(child, _withCross(crossExtent));
      }
      totalMain += _mainSize(s);
      child = childAfter(child);
    }
    totalMain += totalSpacing;

    // Determine the ideal main-axis extent.
    final idealMain = switch (_mainAxisSize) {
      MainAxisSize.max when maxMainSize.isFinite => maxMainSize,
      MainAxisSize.max || MainAxisSize.min => math.max<double>(0, totalMain),
    };

    assert(spacePerFlex.isFinite);
    return _LayoutSizes(
      crossExtent: crossExtent,
      allocatedMain: math.max<double>(0, totalMain),
      mainAxisExtent: idealMain,
      baselineOffset: hasBaseline ? maxAscent : null,
      spacePerFlex: firstFlexChild == null ? null : spacePerFlex,
    );
  }

  // ── Dry layout ──

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    if (firstChild == null) return constraints.constrain(Size.zero);

    final sizes = _computeSizes(
      constraints: constraints,
      layoutChild: ChildLayoutHelper.dryLayoutChild,
      getBaseline: ChildLayoutHelper.getDryBaseline,
    );
    return constraints.constrain(
      _makeSize(sizes.mainAxisExtent, sizes.crossExtent),
    );
  }

  // ── Layout ──

  @override
  void performLayout() {
    if (firstChild == null) {
      size = constraints.constrain(Size.zero);
      return;
    }

    final sizes = _computeSizes(
      constraints: constraints,
      layoutChild: ChildLayoutHelper.layoutChild,
      getBaseline: ChildLayoutHelper.getBaseline,
    );

    size = constraints.constrain(
      _makeSize(sizes.mainAxisExtent, sizes.crossExtent),
    );

    // Distribute main-axis free space based on the actual constrained size.
    final actualMain = _mainSize(size);
    final remainingSpace = math.max<double>(0, actualMain - sizes.allocatedMain);
    final flipMain = _flipMainAxis;
    final flipCrossAxis = _flipCrossAxis;
    final (double leadingSpace, double betweenSpace) = _mainAxisAlignment._distributeSpace(
      remainingSpace,
      childCount,
      flipMain,
      _spacing,
    );

    final baselineOffset = sizes.baselineOffset;
    assert(
      baselineOffset == null || (_crossAxisAlignment == CrossAxisAlignment.baseline && _direction == Axis.horizontal),
    );

    // Position children in visual order.
    final (nextChild, topLeftChild) = flipMain ? (childBefore, lastChild) : (childAfter, firstChild);
    var mainOffset = leadingSpace;
    var child = topLeftChild;
    while (child != null) {
      final data = child.parentData! as _IntrinsicFlexParentData;

      final double childCrossPosition;
      final double? childBaselineOffset;
      if (baselineOffset != null &&
          (childBaselineOffset = child.getDistanceToBaseline(_textBaseline!, onlyReal: true)) != null) {
        childCrossPosition = baselineOffset - childBaselineOffset!;
      } else {
        final freeSpace = sizes.crossExtent - _crossSize(child.size);
        childCrossPosition = _childCrossAxisOffset(freeSpace, flipCrossAxis);
      }

      data.offset = _makeOffset(mainOffset, childCrossPosition);
      mainOffset += _mainSize(child.size) + betweenSpace;
      child = nextChild(child);
    }
  }

  // ── Paint & hit test ──

  final _clipRectLayer = LayerHandle<ClipRectLayer>();

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_clipBehavior == Clip.none) {
      _clipRectLayer.layer = null;
      defaultPaint(context, offset);
    } else {
      _clipRectLayer.layer = context.pushClipRect(
        needsCompositing,
        offset,
        Offset.zero & size,
        defaultPaint,
        clipBehavior: _clipBehavior,
        oldLayer: _clipRectLayer.layer,
      );
    }
  }

  @override
  Rect? describeApproximatePaintClip(RenderObject child) => switch (_clipBehavior) {
    Clip.none => null,
    Clip.hardEdge || Clip.antiAlias || Clip.antiAliasWithSaveLayer => Offset.zero & size,
  };

  @override
  void dispose() {
    _clipRectLayer.layer = null;
    super.dispose();
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<Axis>('direction', _direction));
    properties.add(EnumProperty<MainAxisAlignment>('mainAxisAlignment', _mainAxisAlignment));
    properties.add(EnumProperty<MainAxisSize>('mainAxisSize', _mainAxisSize));
    properties.add(DoubleProperty('spacing', _spacing));
    properties.add(EnumProperty<CrossAxisAlignment>('crossAxisAlignment', _crossAxisAlignment));
    properties.add(EnumProperty<TextBaseline>('textBaseline', _textBaseline, defaultValue: null));
    properties.add(EnumProperty<TextDirection>('textDirection', _textDirection, defaultValue: null));
    properties.add(
      EnumProperty<VerticalDirection>('verticalDirection', _verticalDirection, defaultValue: null),
    );
    properties.add(EnumProperty<Clip>('clipBehavior', _clipBehavior, defaultValue: Clip.none));
  }
}

class _LayoutSizes {
  const _LayoutSizes({
    required this.crossExtent,
    required this.allocatedMain,
    required this.mainAxisExtent,
    required this.baselineOffset,
    required this.spacePerFlex,
  });

  final double crossExtent;
  final double allocatedMain;
  final double mainAxisExtent;
  final double? baselineOffset;
  final double? spacePerFlex;
}

extension on MainAxisAlignment {
  (double leading, double between) _distributeSpace(
    double freeSpace,
    int itemCount,
    bool flipMain,
    double spacing,
  ) {
    assert(itemCount >= 0);
    return switch (this) {
      MainAxisAlignment.start => (flipMain ? freeSpace : 0.0, spacing),
      MainAxisAlignment.end => MainAxisAlignment.start._distributeSpace(freeSpace, itemCount, !flipMain, spacing),
      MainAxisAlignment.spaceBetween when itemCount < 2 => MainAxisAlignment.start._distributeSpace(
        freeSpace,
        itemCount,
        flipMain,
        spacing,
      ),
      MainAxisAlignment.spaceAround when itemCount == 0 => MainAxisAlignment.start._distributeSpace(
        freeSpace,
        itemCount,
        flipMain,
        spacing,
      ),
      MainAxisAlignment.center => (freeSpace / 2.0, spacing),
      MainAxisAlignment.spaceBetween => (0.0, freeSpace / (itemCount - 1) + spacing),
      MainAxisAlignment.spaceAround => (freeSpace / itemCount / 2, freeSpace / itemCount + spacing),
      MainAxisAlignment.spaceEvenly => (freeSpace / (itemCount + 1), freeSpace / (itemCount + 1) + spacing),
    };
  }
}
