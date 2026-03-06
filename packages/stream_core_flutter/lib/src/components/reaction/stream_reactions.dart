import 'package:flutter/material.dart';
import 'package:stream_core/stream_core.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_emoji_chip_theme.dart';
import '../../theme/components/stream_reaction_theme.dart';
import '../../theme/stream_theme_extensions.dart';
import '../accessories/stream_emoji.dart';
import '../common/stream_flex.dart';
import '../controls/stream_emoji_chip.dart';

/// Use [StreamReactions.segmented] to render each reaction as its own pill,
/// and [StreamReactions.clustered] to group all reactions into a single chip.
///
/// Reactions can be positioned [StreamReactionsPosition.header] or
/// [StreamReactionsPosition.footer] relative to the [child]. When [child]
/// is provided, the reaction strip is anchored to the child's bounds and uses
/// [StreamReactionsAlignment] + [StreamReactionsPosition] to place itself.
///
/// When [StreamReactionsProps.overlap] is `true`, the reaction strip visually
/// overlaps the child edge by [StreamReactionsThemeData.overlapExtent] and
/// chips are constrained to a single row.
///
/// When [StreamReactionsProps.overlap] is `false`, reactions flow across
/// multiple lines with a fixed gap separating them from the child.
///
/// To customise the chip appearance (colors, borders, shadows) wrap with
/// [StreamEmojiChipTheme].
class StreamReactions extends StatelessWidget {
  /// Creates a segmented reaction widget where each type gets its own chip.
  ///
  /// Counts are shown on all chips when any reaction has `count > 1`.
  /// When every reaction has a count of 1 (or null), all chips render
  /// emoji-only without counts.
  /// Items beyond [max] are collapsed into a `+N` overflow chip whose count
  /// is the sum of all hidden reactions' counts. The [max] limit only applies
  /// when [overlap] is `true`; otherwise all items are shown.
  StreamReactions.segmented({
    super.key,
    required List<StreamReactionsItem> items,
    Widget? child,
    StreamReactionsPosition position = .footer,
    StreamReactionsAlignment alignment = .start,
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

  /// Creates a clustered reaction widget that groups all reactions into one chip.
  ///
  /// Shows up to [max] emoji icons side by side. The total reaction count is
  /// displayed when it exceeds 1.
  StreamReactions.clustered({
    super.key,
    required List<StreamReactionsItem> items,
    Widget? child,
    StreamReactionsPosition position = .header,
    StreamReactionsAlignment alignment = .end,
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
    final builder = StreamComponentFactory.maybeOf(context)?.reactions;
    if (builder != null) return builder(context, props);

    final spacing = context.streamSpacing;
    final textTheme = context.streamTextTheme;

    return StreamEmojiChipTheme(
      data: StreamEmojiChipThemeData(
        style: StreamEmojiChipThemeStyle(
          backgroundColor: .all(context.streamColorScheme.backgroundElevation2),
          // Reaction chips must shrink to their content width so that multiple
          // chips fit side-by-side within the bubble bounds. The global default
          // (64px minimum) is designed for stand-alone emoji chip bars and is
          // too wide for a segmented reaction row.
          minimumSize: const Size(32, 24),
          maximumSize: const Size.fromHeight(28),
          emojiSize: StreamEmojiSize.sm.value,
          textStyle: .all(textTheme.numericMd.copyWith(fontFeatures: const [.tabularFigures()])),
          padding: EdgeInsetsGeometry.symmetric(vertical: spacing.xxxs, horizontal: spacing.xs),
        ),
      ),
      child: DefaultStreamReactions(props: props),
    );
  }
}

/// Properties for configuring [StreamReactions].
@immutable
class StreamReactionsProps {
  /// Creates reaction properties.
  const StreamReactionsProps({
    required this.type,
    required this.items,
    this.child,
    required this.position,
    required this.alignment,
    this.max,
    this.overlap = true,
    this.indent,
    this.crossAxisAlignment,
    this.clipBehavior = Clip.none,
    this.onPressed,
  });

  /// The visual type of the reaction row.
  final StreamReactionsType type;

  /// The list of reaction items to display.
  final List<StreamReactionsItem> items;

  /// Optional child widget the reactions should be positioned relative to.
  ///
  /// Typically a message bubble or any container widget. When provided, the
  /// child is rendered as the base and reactions are overlaid around its top
  /// or bottom edge. When null, [StreamReactions] renders as a standalone
  /// reaction strip.
  final Widget? child;

  /// Vertical position of reactions relative to the child.
  final StreamReactionsPosition position;

  /// Horizontal alignment of reactions within the available width.
  final StreamReactionsAlignment alignment;

  /// Maximum number of visible items.
  ///
  /// For segmented, items beyond this limit are collapsed into a `+N` overflow
  /// chip. For clustered, only this many emoji icons are shown.
  ///
  /// Defaults to 4. Only applies when [overlap] is `true`; when `false`, all
  /// items are shown.
  final int? max;

  /// Controls whether reactions overlap the child edge.
  ///
  /// When `true`, reactions are laid out with negative spacing so they
  /// visually overlap the child by [StreamReactionsThemeData.overlapExtent].
  ///
  /// When `false`, reactions are detached with a fixed spacing gap instead.
  final bool overlap;

  /// Horizontal distance by which the reaction strip is shifted along the
  /// x-axis relative to the child.
  ///
  /// When null, falls back to [StreamReactionsThemeData.indent], then to
  /// the theme default (`0`).
  final double? indent;

  /// Cross-axis alignment of the column that stacks the child and reactions.
  ///
  /// Controls how the child is positioned horizontally
  /// within the layout. Defaults to [CrossAxisAlignment.start] when null.
  final CrossAxisAlignment? crossAxisAlignment;

  /// Clip behavior for the underlying layout column.
  ///
  /// Defaults to [Clip.none].
  final Clip clipBehavior;

  /// Called when any reaction chip is tapped.
  ///
  /// For segmented reactions this fires on individual emoji chips as well as
  /// the `+N` overflow chip. For clustered reactions it fires on the single
  /// cluster chip.
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

  /// The widget representing this reaction's emoji.
  ///
  /// Typically a [Text] widget containing an emoji character
  /// (e.g. `Text('👍')`).
  final Widget emoji;

  /// The number of times this reaction was used.
  ///
  /// When null, the reaction is treated as having a count of 1.
  final int? count;
}

const _kMaxVisibleSegments = 4;

/// The default implementation of [StreamReactions].
///
/// Renders reactions as either individual segmented chips or a single clustered
/// chip. When [StreamReactionsProps.child] is provided, positions the reaction
/// strip relative to the child with optional overlap.
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

    final reactionStrip = switch (props.type) {
      .clustered => _buildClustered(maxVisible),
      .segmented => _buildSegmented(effectiveSpacing, maxVisible),
    };

    // Standalone mode — no child to position relative to.
    if (props.child == null) return reactionStrip;

    // Negative spacing when overlapping makes reactions overlap the child edge.
    final columnSpacing = props.overlap ? -effectiveOverlapExtent : effectiveGap;

    final effectiveCrossAxisAlignment = props.crossAxisAlignment ?? CrossAxisAlignment.start;

    final effectiveIndent = props.indent ?? reactionTheme.indent ?? defaults.indent;
    final indentedStrip = Transform.translate(offset: .new(effectiveIndent, 0), child: reactionStrip);

    final alignedStrip = switch (props.alignment) {
      .start => Align(alignment: AlignmentDirectional.centerStart, child: indentedStrip),
      .end => Align(alignment: AlignmentDirectional.centerEnd, child: indentedStrip),
    };

    // Reactions are always the LAST child so they paint on top of the child
    // when overlapping (later children have higher z-order in Flex layout).
    // For top-positioned reactions we flip verticalDirection so the column
    // still lays out bottom-to-top while keeping reactions last in the
    // paint order.
    final column = StreamColumn(
      mainAxisSize: .min,
      spacing: columnSpacing,
      crossAxisAlignment: effectiveCrossAxisAlignment,
      clipBehavior: props.clipBehavior,
      verticalDirection: switch (props.position) {
        .header => VerticalDirection.up,
        .footer => VerticalDirection.down,
      },
      children: [props.child!, alignedStrip],
    );

    if (props.overlap) return IntrinsicWidth(child: column);
    return column;
  }

  Widget _buildSegmented(double itemSpacing, int maxVisible) {
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
    return Wrap(spacing: itemSpacing, runSpacing: itemSpacing, children: children);
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

  @override
  double get indent => 0;
}
