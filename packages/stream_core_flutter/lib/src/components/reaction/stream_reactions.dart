import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:stream_core/stream_core.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_emoji_chip_theme.dart';
import '../../theme/components/stream_reactions_theme.dart';
import '../../theme/stream_theme_extensions.dart';
import '../accessories/stream_emoji.dart';
import '../controls/stream_emoji_chip.dart';

import '../message_layout/stream_message_alignment.dart';
import '../message_layout/stream_message_layout.dart';

/// Displays reactions as either individual chips or a single grouped chip.
///
/// Use [StreamReactions.segmented] to render each reaction type as its own
/// chip, and [StreamReactions.clustered] to group all reaction types into a
/// single chip.
///
/// Reactions can be displayed on their own or positioned relative to a
/// [child], such as a message bubble or container.
///
/// If a [StreamMessageLayout] is found in the ancestor tree,
/// [position], [alignment], [crossAxisAlignment], and [indent] are
/// automatically derived from the message alignment when not explicitly set.
///
/// {@tool snippet}
///
/// Display segmented reactions below a child:
///
/// ```dart
/// StreamReactions.segmented(
///   items: [
///     StreamReactionsItem(emoji: StreamEmoji(emoji: StreamUnicodeEmoji('👍')), count: 3),
///     StreamReactionsItem(emoji: StreamEmoji(emoji: StreamUnicodeEmoji('❤️')), count: 2),
///   ],
///   child: Container(
///     padding: EdgeInsets.all(12),
///     child: Text('Looks good to me'),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Display clustered reactions above a child:
///
/// ```dart
/// StreamReactions.clustered(
///   items: [
///     StreamReactionsItem(emoji: StreamEmoji(emoji: StreamUnicodeEmoji('👍')), count: 4),
///     StreamReactionsItem(emoji: StreamEmoji(emoji: StreamUnicodeEmoji('😂')), count: 2),
///     StreamReactionsItem(emoji: StreamEmoji(emoji: StreamUnicodeEmoji('🔥'))),
///   ],
///   position: StreamReactionsPosition.header,
///   child: Container(
///     padding: EdgeInsets.all(12),
///     child: Text('Let us ship this'),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamReactionsTheme], for customizing reaction layout.
///  * [StreamEmojiChipTheme], for customizing chip appearance.
class StreamReactions extends StatelessWidget {
  /// Creates a reaction display with the given [type] and [items].
  StreamReactions({
    super.key,
    StreamReactionsType type = .clustered,
    required List<StreamReactionsItem> items,
    Widget? child,
    StreamReactionsPosition? position,
    StreamReactionsAlignment? alignment,
    int? max,
    bool overlap = true,
    double? indent,
    CrossAxisAlignment? crossAxisAlignment,
    Clip clipBehavior = Clip.none,
    VoidCallback? onPressed,
  }) : props = .new(
         items: items,
         child: child,
         type: type,
         position: position,
         alignment: alignment,
         max: max,
         overlap: overlap,
         indent: indent,
         crossAxisAlignment: crossAxisAlignment,
         clipBehavior: clipBehavior,
         onPressed: onPressed,
       );

  /// Creates segmented reactions where each type is rendered as its own chip.
  StreamReactions.segmented({
    super.key,
    required List<StreamReactionsItem> items,
    Widget? child,
    StreamReactionsPosition? position,
    StreamReactionsAlignment? alignment,
    int? max,
    bool overlap = true,
    double? indent,
    CrossAxisAlignment? crossAxisAlignment,
    Clip clipBehavior = Clip.none,
    VoidCallback? onPressed,
  }) : props = .new(
         items: items,
         child: child,
         type: .segmented,
         position: position,
         alignment: alignment,
         max: max,
         overlap: overlap,
         indent: indent,
         crossAxisAlignment: crossAxisAlignment,
         clipBehavior: clipBehavior,
         onPressed: onPressed,
       );

  /// Creates clustered reactions that group all reaction types into one chip.
  StreamReactions.clustered({
    super.key,
    required List<StreamReactionsItem> items,
    Widget? child,
    StreamReactionsPosition? position,
    StreamReactionsAlignment? alignment,
    int? max,
    bool overlap = true,
    double? indent,
    CrossAxisAlignment? crossAxisAlignment,
    Clip clipBehavior = Clip.none,
    VoidCallback? onPressed,
  }) : props = .new(
         items: items,
         child: child,
         type: .clustered,
         position: position,
         alignment: alignment,
         max: max,
         overlap: overlap,
         indent: indent,
         crossAxisAlignment: crossAxisAlignment,
         clipBehavior: clipBehavior,
         onPressed: onPressed,
       );

  /// The properties that configure this widget.
  final StreamReactionsProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).reactions;
    if (builder != null) return builder(context, props);

    final spacing = context.streamSpacing;
    final textTheme = context.streamTextTheme;

    return StreamEmojiChipTheme(
      data: StreamEmojiChipThemeData(
        style: StreamEmojiChipThemeStyle(
          // Reaction chips must shrink to their content width so that multiple
          // chips fit side-by-side within the bubble bounds. The global default
          // (64px minimum) is designed for stand-alone emoji chip bars and is
          // too wide for a segmented reaction row.
          minimumSize: const Size(32, 24),
          maximumSize: const Size.fromHeight(24),
          emojiSize: StreamEmojiSize.sm.value,
          elevation: .all(props.overlap ? 3 : 0),
          backgroundColor: .all(context.streamColorScheme.backgroundElevation2),
          textStyle: .all(textTheme.numericMd.copyWith(fontFeatures: const [.tabularFigures()])),
          padding: EdgeInsetsGeometry.symmetric(vertical: spacing.xxxs, horizontal: spacing.xs),
        ),
      ),
      child: DefaultStreamReactions(props: props),
    );
  }
}

/// Properties for configuring [StreamReactions].
///
/// See also:
///
///  * [StreamReactions], which uses these properties.
///  * [DefaultStreamReactions], the default implementation.
@immutable
class StreamReactionsProps {
  /// Creates reaction properties.
  const StreamReactionsProps({
    required this.type,
    required this.items,
    this.child,
    this.position,
    this.alignment,
    this.max,
    this.overlap = true,
    this.indent,
    this.crossAxisAlignment,
    this.clipBehavior = Clip.none,
    this.onPressed,
  });

  /// The reaction presentation style.
  final StreamReactionsType type;

  /// The reaction items to display.
  final List<StreamReactionsItem> items;

  /// Optional widget the reactions should be positioned relative to.
  ///
  /// Typically a message bubble or any container widget.
  ///
  /// When null, [StreamReactions] renders as a standalone reaction strip.
  final Widget? child;

  /// The vertical position of the reactions relative to the child.
  final StreamReactionsPosition? position;

  /// The horizontal alignment of the reactions relative to the child.
  final StreamReactionsAlignment? alignment;

  /// Maximum number of visible items.
  ///
  /// In segmented mode, items beyond this limit are collapsed into an overflow
  /// chip. In clustered mode, this limits how many emoji widgets are shown in
  /// the cluster.
  final int? max;

  /// Whether reactions overlap the child edge.
  ///
  /// When `false`, reactions are displayed with a gap from the child.
  final bool overlap;

  /// Horizontal offset applied to the reaction strip.
  final double? indent;

  /// Cross-axis alignment used when laying out the child and reactions.
  final CrossAxisAlignment? crossAxisAlignment;

  /// The clip behavior applied to the layout.
  final Clip clipBehavior;

  /// Called when any reaction chip is tapped.
  ///
  /// In segmented mode, this is used for each visible chip, including the
  /// overflow chip. In clustered mode, it is used for the grouped chip.
  final VoidCallback? onPressed;
}

/// A single reaction item with an emoji widget and optional count.
///
/// Used by [StreamReactions] to describe each distinct reaction type.
///
/// See also:
///
///  * [StreamReactionsProps], which holds a list of these items.
@immutable
class StreamReactionsItem {
  /// Creates a reaction item.
  const StreamReactionsItem({
    required this.emoji,
    this.count,
  });

  /// The content model describing what to render.
  ///
  /// Typically a [StreamUnicodeEmoji] (e.g. `StreamUnicodeEmoji('👍')`)
  /// or a [StreamImageEmoji] for custom server emoji.
  final StreamEmojiContent emoji;

  /// The number of times this reaction was used.
  ///
  /// When null, the reaction is treated as having a count of 1.
  final int? count;
}

const _kMaxVisibleSegments = 4;
const _kDefaultStripIndent = 8.0;

/// Default implementation of [StreamReactions].
///
/// See also:
///
///  * [StreamReactions], the public API widget.
///  * [StreamReactionsProps], which configures this widget.
class DefaultStreamReactions extends StatelessWidget {
  /// Creates a default reaction widget with the given [props].
  const DefaultStreamReactions({super.key, required this.props});

  /// The properties that configure this widget.
  final StreamReactionsProps props;

  @override
  Widget build(BuildContext context) {
    if (props.items.isEmpty) return props.child ?? const SizedBox.shrink();

    final reactionTheme = context.streamReactionsTheme;
    final defaults = _StreamReactionsThemeDefaults(context);

    final effectiveSpacing = reactionTheme.spacing ?? defaults.spacing;
    final effectiveGap = reactionTheme.gap ?? defaults.gap;
    final effectiveOverlapExtent = reactionTheme.overlapExtent ?? defaults.overlapExtent;
    // Limit is only applied when reactions overlap the child; otherwise show all.
    final maxVisible = props.overlap ? (props.max ?? _kMaxVisibleSegments) : props.items.length;

    // Use the message alignment from the ancestor scope to derive sensible
    // defaults for position, alignment, cross-axis alignment, and indent.
    final messageAlignment = StreamMessageLayout.messageAlignmentOf(context);

    var effectiveCrossAxisAlignment = props.crossAxisAlignment;
    effectiveCrossAxisAlignment ??= switch (messageAlignment) {
      StreamMessageAlignment.start => CrossAxisAlignment.start,
      StreamMessageAlignment.end => CrossAxisAlignment.end,
    };

    final wrapAlignment = switch (effectiveCrossAxisAlignment) {
      CrossAxisAlignment.end => WrapAlignment.end,
      CrossAxisAlignment.center => WrapAlignment.center,
      _ => WrapAlignment.start,
    };

    final reactionStrip = switch (props.type) {
      .clustered => _buildClustered(maxVisible),
      .segmented => _buildSegmented(effectiveSpacing, maxVisible, wrapAlignment),
    };

    // Standalone mode — no child to position relative to.
    if (props.child == null) return reactionStrip;

    // Negative spacing when overlapping makes reactions overlap the child edge.
    final columnSpacing = props.overlap ? -effectiveOverlapExtent : effectiveGap;

    var effectiveAlignment = props.alignment;
    effectiveAlignment ??= switch ((messageAlignment, props.overlap)) {
      (StreamMessageAlignment.start, true) => StreamReactionsAlignment.end,
      (StreamMessageAlignment.start, false) => StreamReactionsAlignment.start,
      (StreamMessageAlignment.end, true) => StreamReactionsAlignment.start,
      (StreamMessageAlignment.end, false) => StreamReactionsAlignment.end,
    };

    var effectiveIndent = props.indent;
    effectiveIndent ??= switch ((effectiveAlignment, props.overlap)) {
      (StreamReactionsAlignment.start, true) => effectiveIndent ?? -_kDefaultStripIndent,
      (StreamReactionsAlignment.end, true) => effectiveIndent ?? _kDefaultStripIndent,
      _ => effectiveIndent ?? 0,
    };

    final effectiveIndentOffset = Offset(effectiveIndent, 0).directional(Directionality.maybeOf(context));
    final indentedStrip = Transform.translate(offset: effectiveIndentOffset, child: reactionStrip);

    final alignedStrip = switch (effectiveAlignment) {
      .start => Align(alignment: AlignmentDirectional.centerStart, child: indentedStrip),
      .end => Align(alignment: AlignmentDirectional.centerEnd, child: indentedStrip),
    };

    var effectivePosition = props.position;
    effectivePosition ??= props.overlap ? StreamReactionsPosition.header : StreamReactionsPosition.footer;

    // Reactions are always the LAST child so they paint on top of the child
    // when overlapping (later children have higher z-order). For
    // top-positioned reactions we flip verticalDirection so the column still
    // lays out bottom-to-top while keeping reactions last in the paint order.
    return _ShrinkWrapColumn(
      spacing: columnSpacing,
      crossAxisAlignment: effectiveCrossAxisAlignment,
      clipBehavior: props.clipBehavior,
      verticalDirection: switch (effectivePosition) {
        .header => VerticalDirection.up,
        .footer => VerticalDirection.down,
      },
      children: [props.child!, alignedStrip],
    );
  }

  Widget _buildSegmented(
    double itemSpacing,
    int maxVisible,
    WrapAlignment alignment,
  ) {
    final items = props.items;
    final showCounts = items.any((item) => (item.count ?? 1) > 1);

    final visible = items.take(maxVisible).toList();
    final overflow = items.skip(maxVisible).toList();
    final overflowCount = overflow.sumOf((item) => item.count ?? 1);

    final children = [
      for (final item in visible)
        StreamEmojiChip(
          emoji: item.emoji,
          count: showCounts ? item.count ?? 1 : null,
          onPressed: props.onPressed,
        ),
      if (overflow.isNotEmpty)
        StreamEmojiChip.overflow(
          count: overflowCount,
          onPressed: props.onPressed,
        ),
    ];

    if (props.overlap) return Row(mainAxisSize: .min, spacing: itemSpacing, children: children);
    return Wrap(alignment: alignment, spacing: itemSpacing, runSpacing: itemSpacing, children: children);
  }

  Widget _buildClustered(int maxVisible) {
    final items = props.items;
    final visible = items.take(maxVisible).map((item) => item.emoji).toList();
    final totalCount = items.sumOf((item) => item.count ?? 1);

    return StreamEmojiChip.cluster(
      emojis: visible,
      count: totalCount > 1 ? totalCount : null,
      onPressed: props.onPressed,
    );
  }
}

// Context-aware default values for [StreamReactionsThemeData].
//
// Used by [DefaultStreamReactions] as a fallback when a property is not
// explicitly set in the inherited theme.
class _StreamReactionsThemeDefaults extends StreamReactionsThemeData {
  _StreamReactionsThemeDefaults(this._context);

  final BuildContext _context;

  late final _spacing = _context.streamSpacing;

  @override
  double get spacing => _spacing.xxs;

  @override
  double get gap => _spacing.xxs;

  @override
  double get overlapExtent => _spacing.xs;
}

/// Adapts an [Offset] for the current [TextDirection].
extension on Offset {
  /// Flips [dx] for RTL so a positive offset always means "toward trailing."
  Offset directional([TextDirection? textDirection]) {
    if (textDirection == null || textDirection == .ltr) return this;
    return Offset(-dx, dy);
  }
}

// A vertical two-child layout that shrink-wraps its cross-axis (width) to
// the wider of its two children.
//
// Children narrower than the resolved column width are positioned according
// to [crossAxisAlignment]. The second child is laid out in two passes:
// first unconstrained to measure its natural width, then re-laid out with
// `maxWidth = columnWidth` so that [Align] widgets inside it position
// themselves relative to the resolved column edge rather than expanding to
// the full available width.
//
// ## Layout algorithm
//
// 1. Layout the primary (first) child with the incoming constraints.
// 2. Layout the secondary (second) child with unbounded width to measure
//    its natural extent.
// 3. Resolve `columnWidth = min(max(primary.width, secondary.width),
//    constraints.maxWidth)`. The clamp to `constraints.maxWidth` ensures
//    [Wrap] children wrap instead of extending into a single line.
// 4. Re-layout the secondary child with `maxWidth = columnWidth` so that
//    [Align] can position its content within the resolved width.
// 5. Position children horizontally according to [crossAxisAlignment] and
//    vertically according to [verticalDirection] and [spacing].
// 6. Size to `(columnWidth, primary.height + spacing + secondary.height)`.
//
// With negative [spacing], the secondary child overlaps the primary child
// edge. Later children in the list paint on top of earlier ones (natural
// z-order).
//
// This replaces the previous `IntrinsicWidth(child: Column(...))` pattern
// which broke when descendants used [LayoutBuilder], because
// [IntrinsicWidth] relies on intrinsic-dimension queries that
// [LayoutBuilder] cannot answer.
class _ShrinkWrapColumn extends MultiChildRenderObjectWidget {
  const _ShrinkWrapColumn({
    required super.children,
    this.spacing = 0.0,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.verticalDirection = VerticalDirection.down,
    this.clipBehavior = Clip.none,
  }) : assert(children.length == 2, 'Exactly two children required.');

  // The amount of space between the two children along the vertical axis.
  //
  // Positive values add a gap. Negative values cause the secondary child
  // to overlap the primary child edge.
  final double spacing;

  // How children should be placed along the horizontal axis.
  //
  // Controls the x-offset of children that are narrower than the resolved
  // column width. Text direction is resolved from the ambient
  // [Directionality] for [CrossAxisAlignment.start] and
  // [CrossAxisAlignment.end].
  //
  // [CrossAxisAlignment.stretch] is not supported.
  final CrossAxisAlignment crossAxisAlignment;

  // Determines the order in which children are laid out vertically.
  //
  // [VerticalDirection.down] places the primary child on top.
  // [VerticalDirection.up] places the secondary child on top.
  final VerticalDirection verticalDirection;

  // How to clip children that extend beyond the widget's bounds.
  final Clip clipBehavior;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderShrinkWrapColumn(
      spacing: spacing,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: Directionality.maybeOf(context),
      verticalDirection: verticalDirection,
      clipBehavior: clipBehavior,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderShrinkWrapColumn renderObject,
  ) {
    renderObject
      ..spacing = spacing
      ..crossAxisAlignment = crossAxisAlignment
      ..textDirection = Directionality.maybeOf(context)
      ..verticalDirection = verticalDirection
      ..clipBehavior = clipBehavior;
  }
}

class _ShrinkWrapColumnParentData extends ContainerBoxParentData<RenderBox> {}

// Render object for [_ShrinkWrapColumn].
//
// The primary (first) child is laid out with the incoming constraints. The
// secondary (second) child is measured unconstrained, then re-laid out with
// maxWidth = max(primary.width, secondary.naturalWidth) so that [Align]
// widgets inside it work relative to the resolved column edge.
//
// Children narrower than the column width are offset horizontally according
// to [crossAxisAlignment] and [textDirection].
//
// Width intrinsics return the max of both children. Height intrinsics sum
// both children plus [spacing].
class _RenderShrinkWrapColumn extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _ShrinkWrapColumnParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _ShrinkWrapColumnParentData> {
  _RenderShrinkWrapColumn({
    required double spacing,
    required CrossAxisAlignment crossAxisAlignment,
    required TextDirection? textDirection,
    required VerticalDirection verticalDirection,
    required Clip clipBehavior,
  }) : _spacing = spacing,
       _crossAxisAlignment = crossAxisAlignment,
       _textDirection = textDirection,
       _verticalDirection = verticalDirection,
       _clipBehavior = clipBehavior;

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
    if (_crossAxisAlignment == value) return;
    _crossAxisAlignment = value;
    markNeedsLayout();
  }

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
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _ShrinkWrapColumnParentData) {
      child.parentData = _ShrinkWrapColumnParentData();
    }
  }

  // Returns the horizontal offset for a child of [childWidth] within a
  // column of [columnWidth], based on [crossAxisAlignment].
  double _crossAxisOffset(double childWidth, double columnWidth) {
    final freeSpace = columnWidth - childWidth;
    return switch (_crossAxisAlignment) {
      CrossAxisAlignment.start => switch (_textDirection) {
        TextDirection.rtl => freeSpace,
        _ => 0.0,
      },
      CrossAxisAlignment.end => switch (_textDirection) {
        TextDirection.rtl => 0.0,
        _ => freeSpace,
      },
      CrossAxisAlignment.center => freeSpace / 2.0,
      // Stretch and baseline are not applicable here.
      _ => 0.0,
    };
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    final primary = firstChild;
    final secondary = primary != null ? childAfter(primary) : null;
    final pW = primary?.getMinIntrinsicWidth(height) ?? 0.0;
    final sW = secondary?.getMinIntrinsicWidth(height) ?? 0.0;
    return math.max(pW, sW);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    final primary = firstChild;
    final secondary = primary != null ? childAfter(primary) : null;
    final pW = primary?.getMaxIntrinsicWidth(height) ?? 0.0;
    final sW = secondary?.getMaxIntrinsicWidth(height) ?? 0.0;
    return math.max(pW, sW);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    final primary = firstChild;
    final secondary = primary != null ? childAfter(primary) : null;
    final pH = primary?.getMinIntrinsicHeight(width) ?? 0.0;
    final sH = secondary?.getMinIntrinsicHeight(width) ?? 0.0;
    return pH + _spacing + sH;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    final primary = firstChild;
    final secondary = primary != null ? childAfter(primary) : null;
    final pH = primary?.getMaxIntrinsicHeight(width) ?? 0.0;
    final sH = secondary?.getMaxIntrinsicHeight(width) ?? 0.0;
    return pH + _spacing + sH;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final primary = firstChild;
    if (primary == null) return constraints.constrain(Size.zero);

    final secondary = childAfter(primary);

    final primarySize = primary.getDryLayout(constraints);

    // Measure the secondary child unconstrained to find its natural width.
    final naturalSecondary = secondary?.getDryLayout(BoxConstraints(maxHeight: constraints.maxHeight)) ?? Size.zero;

    // Clamp to incoming maxWidth so that Wrap children can wrap properly
    // instead of extending into a single unbounded line.
    final columnWidth = math.min(
      math.max(primarySize.width, naturalSecondary.width),
      constraints.maxWidth,
    );

    // Re-measure with the resolved column width for final height.
    final secondarySize = secondary?.getDryLayout(BoxConstraints(maxWidth: columnWidth)) ?? Size.zero;

    final totalHeight = math.max(
      primarySize.height,
      primarySize.height + _spacing + secondarySize.height,
    );

    return constraints.constrain(Size(columnWidth, totalHeight));
  }

  @override
  void performLayout() {
    final primary = firstChild!;
    final secondary = childAfter(primary)!;

    // Layout primary with the incoming constraints.
    primary.layout(constraints, parentUsesSize: true);

    // First pass: measure the secondary child unconstrained to find its
    // natural width (Align shrink-wraps when maxWidth is unbounded).
    secondary.layout(
      BoxConstraints(maxHeight: constraints.maxHeight),
      parentUsesSize: true,
    );

    // Clamp to incoming maxWidth so that Wrap children can wrap properly
    // instead of extending into a single unbounded line.
    final columnWidth = math.min(
      math.max(primary.size.width, secondary.size.width),
      constraints.maxWidth,
    );

    // Second pass: re-layout the secondary child with the resolved column
    // width so that Align and Wrap work within the resolved bounds.
    if (secondary.size.width != columnWidth) {
      secondary.layout(
        BoxConstraints(maxWidth: columnWidth),
        parentUsesSize: true,
      );
    }

    final totalHeight = math.max(
      primary.size.height,
      primary.size.height + _spacing + secondary.size.height,
    );

    final primaryData = primary.parentData! as _ShrinkWrapColumnParentData;
    final secondaryData = secondary.parentData! as _ShrinkWrapColumnParentData;

    // Horizontal offsets based on cross-axis alignment.
    final primaryDx = _crossAxisOffset(primary.size.width, columnWidth);
    final secondaryDx = _crossAxisOffset(secondary.size.width, columnWidth);

    switch (_verticalDirection) {
      case VerticalDirection.down:
        primaryData.offset = Offset(primaryDx, 0);
        secondaryData.offset = Offset(
          secondaryDx,
          primary.size.height + _spacing,
        );
      case VerticalDirection.up:
        secondaryData.offset = Offset(secondaryDx, 0);
        primaryData.offset = Offset(
          primaryDx,
          secondary.size.height + _spacing,
        );
    }

    size = constraints.constrain(Size(columnWidth, totalHeight));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_clipBehavior == Clip.none) {
      defaultPaint(context, offset);
    } else {
      context.pushClipRect(
        needsCompositing,
        offset,
        Offset.zero & size,
        defaultPaint,
        clipBehavior: _clipBehavior,
      );
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('spacing', _spacing));
    properties.add(EnumProperty('crossAxisAlignment', _crossAxisAlignment));
    properties.add(EnumProperty('textDirection', _textDirection));
    properties.add(EnumProperty('verticalDirection', _verticalDirection));
    properties.add(EnumProperty('clipBehavior', _clipBehavior));
  }
}
