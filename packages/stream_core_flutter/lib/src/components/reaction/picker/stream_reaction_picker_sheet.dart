import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:unicode_emojis/unicode_emojis.dart';

import '../../../components.dart';
import '../../../theme/components/stream_emoji_button_theme.dart';
import '../../../theme/stream_theme_extensions.dart';

// Emojis grouped by their [Category], computed once and reused.
final _emojisByCategory = () {
  final map = <Category, List<Emoji>>{};
  for (final emoji in UnicodeEmojis.allEmojis) {
    map.putIfAbsent(emoji.category, () => []).add(emoji);
  }
  return map;
}();

/// Extension on [Category] to provide representative icons.
extension CategoryIcon on Category {
  /// Returns the representative icon for this category from [StreamIcons].
  IconData icon(BuildContext context) => switch (this) {
    .smileysAndEmotion => context.streamIcons.emojiSmile,
    .peopleAndBody => context.streamIcons.people,
    .animalsAndNature => context.streamIcons.cat,
    .foodAndDrink => context.streamIcons.apples,
    .travelAndPlaces => context.streamIcons.car1,
    .activities => context.streamIcons.tennis,
    .objects => context.streamIcons.lightBulbSimple,
    .symbols => context.streamIcons.heart2,
    .flags => context.streamIcons.flag2,
  };
}

/// A scrollable sheet that displays Unicode emojis organized by category.
///
/// [StreamReactionPickerSheet] provides a full reaction picker interface with
/// category tabs for quick navigation. Users can scroll through categories
/// or tap a category tab to jump to that section. The active category tab
/// updates automatically as the user scrolls.
///
/// The sheet automatically handles:
/// - Category-based organization of all Unicode emojis
/// - Smooth scrolling between categories
/// - Active tab highlighting during scroll
/// - Layout adaptation for different screen sizes
///
/// ## Usage
///
/// The recommended way to display the reaction picker is using the [show]
/// method, which presents it as a modal bottom sheet:
///
/// {@tool snippet}
///
/// Basic usage:
///
/// ```dart
/// final emoji = await StreamReactionPickerSheet.show(
///   context: context,
/// );
/// if (emoji != null) {
///   sendReaction(emoji);
/// }
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// With customization:
///
/// ```dart
/// final emoji = await StreamReactionPickerSheet.show(
///   context: context,
///   reactionButtonSize: StreamEmojiButtonSize.lg,
///   showDragHandle: false,
///   backgroundColor: Colors.white,
/// );
/// ```
/// {@end-tool}
///
/// ## Theming
///
/// The reaction buttons use [StreamEmojiButtonTheme] for styling. Category
/// tabs and headers respect the current [StreamColorScheme] and
/// [StreamTextTheme].
///
/// See also:
///
///  * [StreamEmojiButton], which displays individual reaction options.
///  * [StreamEmojiButtonSize], which defines button size variants.
///  * [Category], which defines the emoji categories from `unicode_emojis` package.
class StreamReactionPickerSheet extends StatefulWidget {
  /// Creates a reaction picker sheet.
  ///
  /// This constructor is private. Use [StreamReactionPickerSheet.show] to
  /// display the picker as a modal bottom sheet.
  const StreamReactionPickerSheet._({
    required this.scrollController,
    this.onReactionSelected,
    this.reactionButtonSize,
  });

  /// Called when a reaction is tapped.
  final ValueChanged<Emoji>? onReactionSelected;

  /// The size of each reaction button in the grid.
  ///
  /// Defaults to [StreamEmojiButtonSize.xl] (48px buttons).
  final StreamEmojiButtonSize? reactionButtonSize;

  /// Scroll controller for the emoji grid.
  ///
  /// This is required and provided by [DraggableScrollableSheet] when using
  /// the [show] method.
  final ScrollController scrollController;

  /// Shows the reaction picker sheet as a modal bottom sheet.
  ///
  /// The sheet appears as a draggable bottom sheet that can be expanded
  /// or collapsed.
  ///
  /// Parameters:
  /// - [context]: The build context for showing the modal.
  /// - [reactionButtonSize]: Size of each reaction button. Defaults to [StreamEmojiButtonSize.xl].
  /// - [backgroundColor]: Background color of the sheet. Defaults to `backgroundElevation2` from the current color scheme.
  ///
  /// Returns a [Future] that completes with the selected [Emoji] when a
  /// reaction is tapped, or `null` if the sheet is dismissed without selection.
  ///
  /// {@tool snippet}
  ///
  /// Basic example:
  ///
  /// ```dart
  /// final emoji = await StreamReactionPickerSheet.show(
  ///   context: context,
  /// );
  /// if (emoji != null) {
  ///   sendReaction(emoji);
  /// }
  /// ```
  /// {@end-tool}
  ///
  /// {@tool snippet}
  ///
  /// With customization:
  ///
  /// ```dart
  /// final emoji = await StreamReactionPickerSheet.show(
  ///   context: context,
  ///   reactionButtonSize: StreamEmojiButtonSize.lg,
  ///   backgroundColor: Colors.white,
  /// );
  /// ```
  /// {@end-tool}
  static Future<Emoji?> show({
    required BuildContext context,
    StreamEmojiButtonSize? reactionButtonSize,
    Color? backgroundColor,
  }) {
    final radius = context.streamRadius;
    final colorScheme = context.streamColorScheme;

    final effectiveBackgroundColor = backgroundColor ?? colorScheme.backgroundElevation2;

    return showModalBottomSheet<Emoji>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: effectiveBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: .directional(topStart: radius.xl, topEnd: radius.xl),
      ),
      builder: (context) => DraggableScrollableSheet(
        snap: true,
        expand: false,
        minChildSize: 0.5,
        snapSizes: const [0.5, 1],
        builder: (_, scrollController) => StreamReactionPickerSheet._(
          scrollController: scrollController,
          onReactionSelected: Navigator.of(context).pop,
          reactionButtonSize: reactionButtonSize,
        ),
      ),
    );
  }

  @override
  State<StreamReactionPickerSheet> createState() => _StreamReactionPickerSheetState();
}

class _StreamReactionPickerSheetState extends State<StreamReactionPickerSheet> with WidgetsBindingObserver {
  late final _scrollController = widget.scrollController;

  // Categories in stable order.
  late final List<Category> _categories;

  // Keys for each category header.
  late final Map<Category, GlobalKey> _categoryKeys;

  // Cached scroll offsets for each category header.
  final Map<Category, double> _categoryOffsets = {};

  late var _activeCategory = _emojisByCategory.keys.first;
  var _isProgrammaticScroll = false;
  var _offsetsScheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _scrollController.addListener(_handleScroll);

    _categories = _emojisByCategory.keys.toList();
    _categoryKeys = {for (final c in _categories) c: GlobalKey()};

    _activeCategory = _categories.isNotEmpty ? _categories.first : _emojisByCategory.keys.first;

    // Compute offsets after first layout
    _scheduleRecomputeOffsets();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.removeListener(_handleScroll);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    // Recompute on rotation, keyboard show/hide, etc.
    _scheduleRecomputeOffsets();
  }

  Future<void> _scrollToCategory(Category category) async {
    if (!_scrollController.hasClients) return;

    _isProgrammaticScroll = true;
    setState(() => _activeCategory = category);

    // Use cached offset if available, otherwise fallback to ensureVisible
    final cachedOffset = _categoryOffsets[category];
    if (cachedOffset != null && cachedOffset.isFinite) {
      await _scrollController.animateTo(
        cachedOffset,
        duration: const .new(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _isProgrammaticScroll = false;
      return;
    }

    final keyContext = _categoryKeys[category]?.currentContext;
    if (keyContext == null) {
      _isProgrammaticScroll = false;
      return;
    }

    await Scrollable.ensureVisible(
      keyContext,
      duration: const .new(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    _isProgrammaticScroll = false;
  }

  void _handleScroll() {
    if (_isProgrammaticScroll || !_scrollController.hasClients) return;
    if (_categories.isEmpty || _categoryOffsets.isEmpty) return;

    final position = _scrollController.position;

    // At bottom - activate last category
    if (_isAtBottom(position)) {
      _setActiveCategory(_categories.last);
      return;
    }

    // Find the category whose offset is closest to current scroll position
    final currentScroll = position.pixels + 1;
    Category? bestCategory;
    var bestOffset = double.negativeInfinity;

    for (final category in _categories) {
      final offset = _categoryOffsets[category];
      if (offset == null || !offset.isFinite) continue;

      // Find the last offset that is <= current scroll position
      if (offset <= currentScroll && offset > bestOffset) {
        bestOffset = offset;
        bestCategory = category;
      }
    }

    if (bestCategory != null) {
      _setActiveCategory(bestCategory);
    }
  }

  bool _isAtBottom(ScrollPosition position) {
    return position.pixels >= position.maxScrollExtent - 1;
  }

  void _setActiveCategory(Category category) {
    if (category == _activeCategory) return;
    setState(() => _activeCategory = category);
  }

  void _scheduleRecomputeOffsets() {
    if (_offsetsScheduled) return;
    _offsetsScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _offsetsScheduled = false;
      _recomputeOffsets();
    });
  }

  void _recomputeOffsets() {
    if (_categories.isEmpty || !_scrollController.hasClients) return;

    final position = _scrollController.position;
    _categoryOffsets.clear();

    for (final category in _categories) {
      final ctx = _categoryKeys[category]!.currentContext;
      if (ctx == null) {
        // Header not built yet, use infinity as placeholder
        _categoryOffsets[category] = double.infinity;
        continue;
      }

      final ro = ctx.findRenderObject();
      if (ro == null || !ro.attached) {
        _categoryOffsets[category] = double.infinity;
        continue;
      }

      final viewport = RenderAbstractViewport.of(ro);
      final offset = viewport.getOffsetToReveal(ro, 0).offset;

      _categoryOffsets[category] = offset.clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;
    final textTheme = context.streamTextTheme;
    final colorScheme = context.streamColorScheme;

    final effectiveButtonSize = widget.reactionButtonSize ?? .xl;

    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Expanded(
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              ..._categories
                  .map<Widget>(
                    (category) => SliverPadding(
                      padding: .symmetric(horizontal: spacing.md),
                      sliver: SliverMainAxisGroup(
                        slivers: [
                          SliverToBoxAdapter(
                            key: _categoryKeys[category],
                            child: Text(
                              category.description,
                              style: textTheme.headingXs.copyWith(
                                color: colorScheme.textTertiary,
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(child: SizedBox(height: spacing.xs)),
                          SliverGrid.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              mainAxisSpacing: spacing.xxxs,
                              crossAxisSpacing: spacing.xxxs,
                              mainAxisExtent: effectiveButtonSize.value,
                            ),
                            itemCount: _emojisByCategory[category]!.length,
                            itemBuilder: (context, index) {
                              final emoji = _emojisByCategory[category]![index];
                              return StreamEmojiButton(
                                size: effectiveButtonSize,
                                emoji: Text(emoji.emoji),
                                onPressed: () => widget.onReactionSelected?.call(emoji),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                  .insertBetween(
                    SliverToBoxAdapter(child: SizedBox(height: spacing.md)),
                  ),
            ],
          ),
        ),
        _CategoryTabBar(
          categories: _categories,
          activeCategory: _activeCategory,
          onCategorySelected: _scrollToCategory,
        ),
      ],
    );
  }
}

class _CategoryTabBar extends StatefulWidget {
  const _CategoryTabBar({
    required this.categories,
    required this.activeCategory,
    required this.onCategorySelected,
  });

  final List<Category> categories;
  final Category activeCategory;
  final ValueChanged<Category> onCategorySelected;

  @override
  State<_CategoryTabBar> createState() => _CategoryTabBarState();
}

class _CategoryTabBarState extends State<_CategoryTabBar> {
  late final Map<Category, GlobalKey> _tabKeys;

  @override
  void initState() {
    super.initState();
    _tabKeys = {for (final c in widget.categories) c: GlobalKey()};
  }

  @override
  void didUpdateWidget(_CategoryTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeCategory != oldWidget.activeCategory) {
      _scrollToActiveTab();
    }
  }

  void _scrollToActiveTab() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final keyContext = _tabKeys[widget.activeCategory]?.currentContext;
      if (keyContext == null) return;

      Scrollable.ensureVisible(
        keyContext,
        duration: const .new(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.5,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;
    final colorScheme = context.streamColorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: .new(color: colorScheme.borderDefault)),
      ),
      child: SingleChildScrollView(
        scrollDirection: .horizontal,
        padding: EdgeInsetsDirectional.symmetric(
          vertical: spacing.xs,
          horizontal: spacing.md,
        ),
        child: Row(
          spacing: spacing.xxxs,
          children: [
            for (final category in widget.categories)
              StreamButton.icon(
                key: _tabKeys[category],
                icon: category.icon(context),
                style: StreamButtonStyle.secondary,
                type: StreamButtonType.ghost,
                size: StreamButtonSize.large,
                isSelected: category == widget.activeCategory,
                onTap: () => widget.onCategorySelected(category),
              ),
          ],
        ),
      ),
    );
  }
}

// Insert any item<T> inBetween the iterable items.
extension _IterableExtension<T> on Iterable<T> {
  Iterable<T> insertBetween(T separator) {
    return expand((element) sync* {
      yield separator;
      yield element;
    }).skip(1);
  }
}
