import 'package:flutter/material.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/stream_theme_extensions.dart';
import 'stream_emoji_chip.dart';

/// A horizontally scrollable bar of [StreamEmojiChip]s for filtering by
/// reaction type.
///
/// [StreamEmojiChipBar] renders a row of emoji chips where each
/// [StreamEmojiChipItem] represents a reaction type with its count.
/// Selection is value-based using [T] and supports toggle behavior: tapping
/// the already-selected item deselects it.
///
/// The generic type [T] represents the value associated with each item
/// (e.g. a reaction type string, an enum, or even a [Widget]). Selection
/// comparison uses [T.==], so ensure [T] has meaningful equality semantics.
///
/// An optional [leading] widget (typically [StreamEmojiChip.addEmoji]) is
/// rendered before the items inside the same scrollable row.
///
/// To customize the appearance of chips inside the bar, wrap it with a
/// [StreamEmojiChipTheme].
///
/// {@tool snippet}
///
/// Basic usage with `String` values:
///
/// ```dart
/// StreamEmojiChipBar<String>(
///   leading: StreamEmojiChip.addEmoji(
///     onPressed: () => showReactionPicker(),
///   ),
///   items: [
///     StreamEmojiChipItem(value: '👍', emoji: Text('👍'), count: 7),
///     StreamEmojiChipItem(value: '❤️', emoji: Text('❤️'), count: 5),
///   ],
///   selected: _selectedReaction,
///   onSelected: (value) => setState(() => _selectedReaction = value),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamEmojiChipTheme], for customizing chip appearance inside the bar.
///  * [StreamEmojiChip], which renders each individual chip.
///  * [StreamEmojiChipItem], which describes a single filter item.
class StreamEmojiChipBar<T> extends StatelessWidget {
  /// Creates an emoji chip bar.
  StreamEmojiChipBar({
    super.key,
    Widget? leading,
    required List<StreamEmojiChipItem<T>> items,
    T? selected,
    ValueChanged<T?>? onSelected,
    EdgeInsetsGeometry? padding,
    double? spacing,
  }) : props = .new(
         leading: leading,
         items: items,
         selected: selected,
         onSelected: onSelected,
         padding: padding,
         spacing: spacing,
       );

  /// The props controlling the appearance and behavior of this bar.
  final StreamEmojiChipBarProps<T> props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).emojiChipBar;
    if (builder != null) return builder(context, props);
    return DefaultStreamEmojiChipBar<T>(props: props);
  }
}

/// Properties for configuring a [StreamEmojiChipBar].
///
/// This class holds all the configuration options for an emoji chip bar,
/// allowing them to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamEmojiChipBar], which uses these properties.
///  * [DefaultStreamEmojiChipBar], the default implementation.
class StreamEmojiChipBarProps<T extends Object?> {
  /// Creates properties for an emoji chip bar.
  const StreamEmojiChipBarProps({
    this.leading,
    required this.items,
    this.selected,
    this.onSelected,
    this.padding,
    this.spacing,
  });

  /// An optional widget rendered before the filter items.
  ///
  /// Typically a [StreamEmojiChip.addEmoji] for adding new reactions.
  /// Rendered inside the same scrollable row as the items.
  final Widget? leading;

  /// The filter items to display.
  ///
  /// Each item renders as a [StreamEmojiChip] using [StreamEmojiChipItem.emoji]
  /// and [StreamEmojiChipItem.count]. The bar manages [isSelected] and
  /// [onPressed] internally.
  final List<StreamEmojiChipItem<T>> items;

  /// The currently selected value, or `null` if no filter is active.
  ///
  /// Compared against each [StreamEmojiChipItem.value] using [==].
  /// When `null`, no chip is highlighted (all reactions are shown).
  final T? selected;

  /// Called when an item is tapped.
  ///
  /// Receives the tapped item's [value], or `null` when the already-selected
  /// item is tapped again (toggle-off / deselect). When `null`, the bar is
  /// non-interactive.
  final ValueChanged<T?>? onSelected;

  /// The padding around the scrollable chip row.
  ///
  /// Falls back to horizontal `StreamSpacing.md`.
  final EdgeInsetsGeometry? padding;

  /// The gap between chips in the row.
  ///
  /// Falls back to `StreamSpacing.xs` (8px).
  final double? spacing;
}

/// A single item in a [StreamEmojiChipBar].
///
/// Pairs a [value] of type [T] (used for selection identity) with visual
/// properties ([emoji] and optional [count]) rendered inside a
/// [StreamEmojiChip].
///
/// This follows the same pattern as [ButtonSegment] in Flutter's
/// [SegmentedButton], where the generic value drives selection and widget
/// fields drive rendering.
class StreamEmojiChipItem<T> {
  /// Creates a filter bar item.
  const StreamEmojiChipItem({
    required this.value,
    required this.emoji,
    this.count,
  });

  /// The value this item represents.
  ///
  /// Used to match against [StreamEmojiChipBarProps.selected] via [==].
  /// For reaction filtering, this is typically a reaction type identifier.
  final T value;

  /// The emoji content to display inside the chip.
  ///
  /// Typically a reaction icon builder result or a [Text] widget containing
  /// a Unicode emoji character.
  final Widget emoji;

  /// The reaction count to display next to [emoji].
  ///
  /// When `null` the count label is hidden.
  final int? count;
}

/// Default implementation of [StreamEmojiChipBar].
///
/// Renders a horizontally scrollable [SingleChildScrollView] containing the
/// optional [StreamEmojiChipBarProps.leading] widget followed by a
/// [StreamEmojiChip] for each item. Handles toggle selection and
/// auto-scrolls to keep the selected item visible.
class DefaultStreamEmojiChipBar<T> extends StatefulWidget {
  /// Creates a default emoji chip bar.
  const DefaultStreamEmojiChipBar({super.key, required this.props});

  /// The props controlling the appearance and behavior of this bar.
  final StreamEmojiChipBarProps<T> props;

  @override
  State<DefaultStreamEmojiChipBar<T>> createState() => _DefaultStreamEmojiChipBarState<T>();
}

class _DefaultStreamEmojiChipBarState<T> extends State<DefaultStreamEmojiChipBar<T>> {
  late Map<T, GlobalKey> _valueKeys;

  StreamEmojiChipBarProps<T> get props => widget.props;

  @override
  void initState() {
    super.initState();
    _valueKeys = {for (final item in props.items) item.value: GlobalKey()};
  }

  @override
  void didUpdateWidget(DefaultStreamEmojiChipBar<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.props.items, props.items)) {
      _valueKeys = {for (final item in props.items) item.value: GlobalKey()};
    }
    if (widget.props.selected != oldWidget.props.selected) {
      _scrollToSelected();
    }
  }

  void _scrollToSelected() {
    final selected = props.selected;
    if (selected == null) return;

    final key = _valueKeys[selected];
    if (key == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final keyContext = key.currentContext;
      if (keyContext == null) return;

      Scrollable.ensureVisible(
        keyContext,
        curve: Curves.easeInOut,
        alignment: 0.5, // Center the item (0.0 is start, 1.0 is end)
        duration: const Duration(milliseconds: 300),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    final effectiveSpacing = props.spacing ?? spacing.xs;
    final effectivePadding = props.padding ?? .symmetric(horizontal: spacing.md);

    return SingleChildScrollView(
      padding: effectivePadding,
      scrollDirection: .horizontal,
      child: Row(
        spacing: effectiveSpacing,
        children: [
          ?props.leading,
          for (final item in props.items)
            StreamEmojiChip(
              key: _valueKeys[item.value],
              emoji: item.emoji,
              count: item.count,
              isSelected: item.value == props.selected,
              onPressed: switch (props.onSelected) {
                final onSelected? => () => onSelected(
                  item.value == props.selected ? null : item.value,
                ),
                _ => null,
              },
            ),
        ],
      ),
    );
  }
}
