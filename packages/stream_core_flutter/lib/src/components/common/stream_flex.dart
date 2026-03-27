import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A widget that displays its children in a one-dimensional array,
/// supporting negative [spacing] and collapsed (nullable) children.
///
/// [StreamFlex] allows you to control the axis along which the children are
/// placed (horizontal or vertical). The [spacing] parameter can be positive
/// (gap between children), zero (flush), or negative (children overlap).
///
/// If you know the main axis in advance, consider using [StreamRow]
/// (horizontal) or [StreamColumn] (vertical) instead, since that will be
/// less verbose.
///
/// ## Collapsed children
///
/// Children built with [NullableStatelessWidget], [NullableStatefulWidget],
/// or [NullableBuilder] can return `null` from their `nullableBuild` method.
/// When they do, they collapse to zero size **and no spacing is allocated
/// for them**.
///
/// In a regular [Row] or [Column], a zero-size child still occupies a
/// spacing slot. [StreamFlex] (and its subclasses) detect collapsed children
/// and exclude them from spacing calculations entirely.
///
/// {@tool snippet}
///
/// A column with 8px spacing where the subtitle conditionally collapses.
/// When `showSubtitle` is false, only one 8px gap remains between "Title"
/// and "Body" — the collapsed child does not add an extra spacing slot:
///
/// ```dart
/// StreamColumn(
///   spacing: 8,
///   children: [
///     Text('Title'),
///     NullableBuilder(builder: (context) {
///       if (!showSubtitle) return null;
///       return const Text('Subtitle');
///     }),
///     Text('Body'),
///   ],
/// )
/// ```
/// {@end-tool}
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
/// Collapsed children are excluded from all steps above.
///
/// With negative spacing, the total main-axis extent shrinks and children
/// are positioned closer together, producing overlap. Later children in the
/// list paint on top of earlier ones (natural z-order).
///
/// See also:
///
///  * [StreamRow], for a horizontal variant.
///  * [StreamColumn], for a vertical variant.
///  * [NullableBuilder], for inline nullable children.
///  * [NullableStatelessWidget], for reusable nullable widgets.
///  * [NullableStatefulWidget], for stateful nullable widgets.
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
/// supporting negative [spacing] and collapsed (nullable) children.
///
/// This is the horizontal specialization of [StreamFlex]. See [StreamFlex]
/// for details on collapsed children and the layout algorithm.
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
///  * [NullableBuilder], for inline nullable children.
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
/// supporting negative [spacing] and collapsed (nullable) children.
///
/// This is the vertical specialization of [StreamFlex]. See [StreamFlex]
/// for details on collapsed children and the layout algorithm.
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
///  * [NullableBuilder], for inline nullable children.
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

/// A [StatelessWidget] whose [nullableBuild] may return `null`.
///
/// When [nullableBuild] returns `null`, a collapsed placeholder is used that
/// occupies zero space. [StreamRow] and [StreamColumn] skip collapsed children
/// when calculating spacing, so a nullable widget that returns `null` is
/// effectively invisible — no spacing is allocated for it.
///
/// When [nullableBuild] returns a widget, this behaves like a normal
/// [StatelessWidget].
///
/// **Note:** The collapsed-child skipping only works inside [StreamRow] and
/// [StreamColumn]. In a regular [Row] or [Column], a collapsed child still
/// occupies a spacing slot.
///
/// For simple inline cases, consider [NullableBuilder] instead.
///
/// {@tool snippet}
///
/// A label that only renders when the message is pinned:
///
/// ```dart
/// class PinnedLabel extends NullableStatelessWidget {
///   const PinnedLabel({super.key, required this.isPinned});
///
///   final bool isPinned;
///
///   @override
///   Widget? nullableBuild(BuildContext context) {
///     if (!isPinned) return null;
///     return const Text('Pinned');
///   }
/// }
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [NullableBuilder], for inline nullable children without a subclass.
///  * [NullableStatefulWidget], for a stateful variant.
abstract class NullableStatelessWidget extends StatelessWidget {
  /// Creates a nullable stateless widget.
  const NullableStatelessWidget({super.key});

  /// Describes the part of the user interface represented by this widget.
  ///
  /// Return `null` to indicate this widget should be collapsed — it will
  /// occupy zero space and [StreamRow]/[StreamColumn] will not apply
  /// spacing for it.
  @protected
  Widget? nullableBuild(BuildContext context);

  @override
  @nonVirtual
  Widget build(BuildContext context) => nullableBuild(context) ?? const _CollapsedWidget();
}

/// A convenience [NullableStatelessWidget] that takes a builder function.
///
/// Use this for inline nullable children without creating a dedicated
/// widget subclass.
///
/// {@tool snippet}
///
/// Show a label only when the theme enables it:
///
/// ```dart
/// StreamColumn(
///   spacing: 8,
///   children: [
///     Text('Title'),
///     NullableBuilder(builder: (context) {
///       final showSubtitle = Theme.of(context).extension<MyTheme>()?.showSubtitle ?? false;
///       if (!showSubtitle) return null;
///       return const Text('Subtitle');
///     }),
///     Text('Body'),
///   ],
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [NullableStatelessWidget], for reusable nullable widgets.
class NullableBuilder extends NullableStatelessWidget {
  /// Creates a nullable builder widget.
  const NullableBuilder({super.key, required this.builder});

  /// Called to build the child, or return `null` to collapse.
  final Widget? Function(BuildContext context) builder;

  @override
  Widget? nullableBuild(BuildContext context) => builder(context);
}

/// A widget that has mutable state and whose [NullableState.nullableBuild]
/// may return `null`.
///
/// When [NullableState.nullableBuild] returns `null`, a collapsed placeholder
/// is used that occupies zero space. [StreamRow] and [StreamColumn] skip
/// collapsed children when calculating spacing, so the widget is effectively
/// invisible.
///
/// {@tool snippet}
///
/// A counter badge that hides itself when the count is zero:
///
/// ```dart
/// class CountBadge extends NullableStatefulWidget {
///   const CountBadge({super.key});
///
///   @override
///   NullableState<CountBadge> createState() => _CountBadgeState();
/// }
///
/// class _CountBadgeState extends NullableState<CountBadge> {
///   int _count = 0;
///
///   @override
///   Widget? nullableBuild(BuildContext context) {
///     if (_count == 0) return null;
///     return Text('$_count');
///   }
/// }
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [NullableStatelessWidget], for a stateless variant.
///  * [NullableBuilder], for inline nullable children without a subclass.
///  * [NullableState], the [State] subclass to use with this widget.
abstract class NullableStatefulWidget extends StatefulWidget {
  /// Creates a nullable stateful widget.
  const NullableStatefulWidget({super.key});

  @override
  NullableState createState();
}

/// The [State] for a [NullableStatefulWidget].
///
/// Subclasses should override [nullableBuild] instead of [build].
/// Returning `null` from [nullableBuild] causes the widget to be collapsed.
abstract class NullableState<T extends NullableStatefulWidget> extends State<T> {
  /// Describes the part of the user interface represented by this widget.
  ///
  /// Return `null` to indicate this widget should be collapsed — it will
  /// occupy zero space and [StreamRow]/[StreamColumn] will not apply
  /// spacing for it.
  Widget? nullableBuild(BuildContext context);

  @override
  @nonVirtual
  Widget build(BuildContext context) => nullableBuild(context) ?? const _CollapsedWidget();
}

// ─── Collapsed internals ───

class _CollapsedWidget extends LeafRenderObjectWidget {
  const _CollapsedWidget();

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderCollapsed();
}

// A zero-size [RenderBox] used as a placeholder when a
// [NullableStatelessWidget], [NullableStatefulWidget], or
// [NullableBuilder] returns `null` from its build method.
//
// [StreamRow] and [StreamColumn] skip children backed by this render
// object when calculating spacing.
class _RenderCollapsed extends RenderBox {
  @override
  void performLayout() => size = constraints.smallest;

  @override
  double computeMinIntrinsicWidth(double height) => 0;

  @override
  double computeMaxIntrinsicWidth(double height) => 0;

  @override
  double computeMinIntrinsicHeight(double width) => 0;

  @override
  double computeMaxIntrinsicHeight(double width) => 0;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.smallest;
}

// Render object for [StreamFlex] that supports negative [spacing] and
// automatically skips [RenderCollapsed] children for spacing calculations.
//
// When [spacing] is negative, children overlap along the main axis.
// Later children in the child list paint on top of earlier ones.
//
// When a child is a [RenderCollapsed] (produced by [NullableStatelessWidget],
// [NullableStatefulWidget], or [NullableBuilder] returning null), it is laid
// out at zero size and excluded from layout iteration — so no spacing is
// allocated for it.
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

  // ── Collapsed-child filtering ──
  //
  // The public iteration getters (firstChild, lastChild, childAfter,
  // childBefore, childCount) are used by RenderFlex's layout, paint, and
  // hit-test algorithms. By overriding them to skip RenderCollapsed
  // instances, those algorithms naturally ignore collapsed children.
  //
  // Lifecycle methods (visitChildren, attach, detach, redepthChildren) use
  // the private _firstChild / parentData.nextSibling linked list directly,
  // so they continue to reach ALL children — keeping the framework happy.

  // Advances [start] via [next] until a non-collapsed child is found.
  RenderBox? _skipCollapsed(
    RenderBox? start,
    RenderBox? Function(RenderBox) next,
  ) {
    var current = start;
    while (current is _RenderCollapsed) {
      current = next(current);
    }
    return current;
  }

  // Unfiltered accessors for internal use.
  RenderBox? get _realFirstChild => super.firstChild;
  RenderBox? _realChildAfter(RenderBox child) => super.childAfter(child);
  RenderBox? _realChildBefore(RenderBox child) => super.childBefore(child);

  @override
  int get childCount {
    var count = 0;
    for (var child = _realFirstChild; child != null; child = _realChildAfter(child)) {
      if (child is! _RenderCollapsed) count++;
    }
    return count;
  }

  @override
  RenderBox? get firstChild => _skipCollapsed(_realFirstChild, _realChildAfter);

  @override
  RenderBox? get lastChild => _skipCollapsed(super.lastChild, _realChildBefore);

  @override
  RenderBox? childAfter(RenderBox child) => _skipCollapsed(_realChildAfter(child), _realChildAfter);

  @override
  RenderBox? childBefore(RenderBox child) => _skipCollapsed(_realChildBefore(child), _realChildBefore);

  @override
  void performLayout() {
    // Layout collapsed children at zero size — they are invisible to super's
    // iteration because we override firstChild/childAfter to skip them.
    for (var child = _realFirstChild; child != null; child = _realChildAfter(child)) {
      if (child is _RenderCollapsed) {
        child.layout(BoxConstraints.tight(Size.zero));
      }
    }

    super.performLayout();
  }
}
