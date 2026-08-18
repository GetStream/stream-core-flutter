import 'package:flutter/material.dart';
import 'package:stream_core/stream_core.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_emoji_chip_theme.dart';
import '../../theme/components/stream_reactions_theme.dart';
import '../../theme/stream_theme_extensions.dart';
import '../accessories/stream_emoji.dart';
import '../common/stream_intrinsic_flex.dart';
import '../controls/stream_emoji_chip.dart';

import '../message_layout/stream_message_alignment.dart';
import '../message_layout/stream_message_layout.dart';

/// Callback when a reaction item is pressed.
typedef OnReactionItemPressed = ValueSetter<StreamReactionsItem?>;

/// Callback when a reaction item is long-pressed.
typedef OnReactionItemLongPressed = ValueSetter<StreamReactionsItem?>;

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
    @Deprecated('Use onReactionPressed instead. onReactionPressed reports the pressed StreamReactionsItem.')
    VoidCallback? onPressed,
    OnReactionItemPressed? onReactionPressed,
    OnReactionItemLongPressed? onReactionLongPressed,
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
         onReactionPressed: onReactionPressed,
         onReactionLongPressed: onReactionLongPressed,
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
    @Deprecated('Use onReactionPressed instead. onReactionPressed reports the pressed StreamReactionsItem.')
    VoidCallback? onPressed,
    OnReactionItemPressed? onReactionPressed,
    OnReactionItemLongPressed? onReactionLongPressed,
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
         onReactionPressed: onReactionPressed,
         onReactionLongPressed: onReactionLongPressed,
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
    @Deprecated('Use onReactionPressed instead. onReactionPressed reports the pressed StreamReactionsItem.')
    VoidCallback? onPressed,
    OnReactionItemPressed? onReactionPressed,
    OnReactionItemLongPressed? onReactionLongPressed,
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
         onReactionPressed: onReactionPressed,
         onReactionLongPressed: onReactionLongPressed,
       );

  /// The properties that configure this widget.
  final StreamReactionsProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).reactions;
    if (builder != null) return builder(context, props);
    return DefaultStreamReactions(props: props);
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
    this.onReactionPressed,
    this.onReactionLongPressed,
  }) : assert(
         onPressed == null || onReactionPressed == null,
         'Only one of onPressed or onReactionPressed can be provided. '
         'Prefer onReactionPressed; onPressed is deprecated.',
       );

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

  /// Called when any reaction chip is pressed.
  ///
  /// Prefer [onReactionPressed], which also reports the pressed
  /// [StreamReactionsItem].
  final VoidCallback? onPressed;

  /// Called when a reaction chip is pressed, with the pressed item.
  ///
  /// In segmented mode, the pressed [StreamReactionsItem] is provided for each
  /// visible chip; the overflow chip reports `null`. In clustered mode, the
  /// single grouped chip reports `null` since it represents no single item.
  final OnReactionItemPressed? onReactionPressed;

  /// Called when a reaction chip is long-pressed, with the pressed item.
  ///
  /// Reports the item the same way [onReactionPressed] does. When null, no
  /// long-press gesture is registered on the chips, leaving the gesture to an
  /// ancestor.
  ///
  /// Only fires on an enabled chip, so it also requires [onPressed] or
  /// [onReactionPressed] to be set.
  final OnReactionItemLongPressed? onReactionLongPressed;
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
    this.key,
    required this.emoji,
    this.count,
  });

  /// An optional identifier for this item.
  ///
  /// [StreamReactions.onReactionPressed] reports the pressed item, so callers
  /// can set [key] (e.g. a reaction type) to identify which item was pressed.
  final String? key;

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
    final defaults = _StreamReactionsThemeDefaults(context, overlap: props.overlap);

    final effectiveSpacing = reactionTheme.spacing ?? defaults.spacing;
    final effectiveGap = reactionTheme.gap ?? defaults.gap;
    final effectiveOverlapExtent = reactionTheme.overlapExtent ?? defaults.overlapExtent;
    // A composite style, so the theme override is merged over the default
    // rather than replacing it wholesale (unlike the scalar values above).
    final effectiveChipStyle = defaults.chipStyle.merge(reactionTheme.chipStyle);
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
    if (props.child == null) {
      return StreamEmojiChipTheme(
        data: .new(style: effectiveChipStyle),
        child: reactionStrip,
      );
    }

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
    //
    // The bubble is wrapped in StreamIntrinsicBoundedCrossAxis so descendants
    // like ListView(shrinkWrap: true) inside it receive a bounded width.
    // Resolution still treats it as a regular child — column width remains
    // max(bubble, strip).
    return StreamEmojiChipTheme(
      data: .new(style: effectiveChipStyle),
      child: StreamIntrinsicColumn(
        spacing: columnSpacing,
        crossAxisAlignment: effectiveCrossAxisAlignment,
        clipBehavior: props.clipBehavior,
        verticalDirection: switch (effectivePosition) {
          .header => VerticalDirection.up,
          .footer => VerticalDirection.down,
        },
        children: [
          StreamIntrinsicBoundedCrossAxis(child: props.child!),
          alignedStrip,
        ],
      ),
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
          onPressed: _chipCallback(item),
          onLongPress: _chipLongPressCallback(item),
        ),
      // The overflow chip aggregates hidden reactions, so it has no single item.
      if (overflow.isNotEmpty)
        StreamEmojiChip.overflow(
          count: overflowCount,
          onPressed: _chipCallback(null),
          onLongPress: _chipLongPressCallback(null),
        ),
    ];

    if (props.overlap) return Row(mainAxisSize: .min, spacing: itemSpacing, children: children);
    return Wrap(alignment: alignment, spacing: itemSpacing, runSpacing: itemSpacing, children: children);
  }

  Widget _buildClustered(int maxVisible) {
    final items = props.items;
    final visible = items.take(maxVisible).map((item) => item.emoji).toList();
    final totalCount = items.sumOf((item) => item.count ?? 1);

    // The cluster groups all reactions into one chip, so it has no single item.
    return StreamEmojiChip.cluster(
      emojis: visible,
      count: totalCount > 1 ? totalCount : null,
      onPressed: _chipCallback(null),
      onLongPress: _chipLongPressCallback(null),
    );
  }

  // Resolves a chip's tap callback, preferring the item-aware
  // [StreamReactions.onReactionPressed] and falling back to the deprecated
  // [StreamReactions.onPressed].
  VoidCallback? _chipCallback(StreamReactionsItem? item) {
    final onReactionPressed = props.onReactionPressed;
    if (onReactionPressed != null) return () => onReactionPressed(item);
    return props.onPressed;
  }

  // Resolves a chip's long-press callback, staying null when
  // [StreamReactions.onReactionLongPressed] is unset so the gesture falls
  // through to an ancestor.
  VoidCallback? _chipLongPressCallback(StreamReactionsItem? item) {
    final onReactionLongPressed = props.onReactionLongPressed;
    if (onReactionLongPressed == null) return null;
    return () => onReactionLongPressed(item);
  }
}

// Context-aware default values for [StreamReactionsThemeData].
//
// Used by [DefaultStreamReactions] as a fallback when a property is not
// explicitly set in the inherited theme.
class _StreamReactionsThemeDefaults extends StreamReactionsThemeData {
  _StreamReactionsThemeDefaults(this._context, {required this.overlap});

  final BuildContext _context;

  final bool overlap;

  late final _spacing = _context.streamSpacing;
  late final _textTheme = _context.streamTextTheme;
  late final _colorScheme = _context.streamColorScheme;

  @override
  double get spacing => _spacing.xxs;

  @override
  double get gap => _spacing.xxs;

  @override
  double get overlapExtent => _spacing.xs;

  @override
  StreamEmojiChipThemeStyle get chipStyle => StreamEmojiChipThemeStyle(
    // Reaction chips must shrink to their content width so that multiple
    // chips fit side-by-side within the bubble bounds. The global default
    // (64px minimum) is designed for stand-alone emoji chip bars and is
    // too wide for a segmented reaction row.
    minimumSize: const Size(32, 24),
    maximumSize: const Size.fromHeight(24),
    emojiSize: StreamEmojiSize.sm.value,
    elevation: .all(overlap ? 3 : 0),
    backgroundColor: .all(_colorScheme.backgroundElevation2),
    textStyle: .all(_textTheme.numericMd.copyWith(fontFeatures: const [.tabularFigures()])),
    padding: .symmetric(vertical: _spacing.xxxs, horizontal: _spacing.xs),
  );
}

/// Adapts an [Offset] for the current [TextDirection].
extension on Offset {
  /// Flips [dx] for RTL so a positive offset always means "toward trailing."
  Offset directional([TextDirection? textDirection]) {
    if (textDirection == null || textDirection == .ltr) return this;
    return Offset(-dx, dy);
  }
}
