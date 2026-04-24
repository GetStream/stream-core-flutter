import 'package:flutter/material.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_reaction_picker_theme.dart';
import '../../theme/primitives/stream_radius.dart';
import '../../theme/primitives/stream_spacing.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/stream_theme_extensions.dart';
import '../accessories/stream_emoji.dart';
import '../buttons/stream_button.dart';
import '../buttons/stream_emoji_button.dart';

/// A single pickable reaction item.
///
/// Represents one emoji option within a [StreamReactionPicker].
///
/// {@tool snippet}
///
/// Create a reaction item:
///
/// ```dart
/// StreamReactionPickerItem(
///   key: 'like',
///   emoji: StreamUnicodeEmoji('👍'),
///   isSelected: true,
/// )
/// ```
/// {@end-tool}
@immutable
class StreamReactionPickerItem {
  /// Creates a reaction picker item.
  const StreamReactionPickerItem({
    required this.key,
    required this.emoji,
    this.isSelected = false,
  });

  /// A unique identifier for this reaction (e.g. 'like', 'love').
  final String key;

  /// The content model describing what to render.
  ///
  /// Typically a [StreamUnicodeEmoji] (e.g. `StreamUnicodeEmoji('👍')`)
  /// or a [StreamImageEmoji] for custom server emoji.
  final StreamEmojiContent emoji;

  /// Whether the user has already selected this reaction.
  final bool isSelected;
}

/// Callback when a reaction item is picked.
typedef OnReactionItemPicked = ValueSetter<StreamReactionPickerItem>;

/// A horizontal bar of tappable emoji reactions.
///
/// Displays a list of [StreamReactionPickerItem]s as tappable emoji buttons
/// with a built-in "add reaction" button. The reaction items are horizontally
/// scrollable while the add button remains fixed at the trailing edge.
///
/// The add button is always visible — when [onAddReactionTap] is null, it is
/// rendered in a disabled state.
///
/// This is a domain-agnostic component — it has no knowledge of chat models.
/// For chat-specific usage, see [StreamMessageReactionPicker] in
/// `stream_chat_flutter`.
///
/// {@tool snippet}
///
/// Display a reaction picker:
///
/// ```dart
/// StreamReactionPicker(
///   items: [
///     StreamReactionPickerItem(key: 'like', emoji: StreamUnicodeEmoji('👍')),
///     StreamReactionPickerItem(key: 'love', emoji: StreamUnicodeEmoji('❤️'), isSelected: true),
///   ],
///   onReactionPicked: (item) => print('Picked: ${item.key}'),
///   onAddReactionTap: () => print('Open emoji picker'),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamReactionPickerTheme], for customizing the picker appearance.
///  * [StreamReactionPickerItem], which represents a single reaction option.
class StreamReactionPicker extends StatelessWidget {
  /// Creates a reaction picker with the given items.
  StreamReactionPicker({
    super.key,
    required List<StreamReactionPickerItem> items,
    OnReactionItemPicked? onReactionPicked,
    VoidCallback? onAddReactionTap,
  }) : props = .new(
         items: items,
         onReactionPicked: onReactionPicked,
         onAddReactionTap: onAddReactionTap,
       );

  /// The properties that configure this reaction picker.
  final StreamReactionPickerProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).reactionPicker;
    if (builder != null) return builder(context, props);
    return DefaultStreamReactionPicker(props: props);
  }
}

/// Properties for configuring a [StreamReactionPicker].
///
/// See also:
///
///  * [StreamReactionPicker], which uses these properties.
///  * [DefaultStreamReactionPicker], the default implementation.
@immutable
class StreamReactionPickerProps {
  /// Creates properties for a reaction picker.
  const StreamReactionPickerProps({
    required this.items,
    this.onReactionPicked,
    this.onAddReactionTap,
  });

  /// The reaction items to display.
  final List<StreamReactionPickerItem> items;

  /// Called when a reaction item is tapped.
  final OnReactionItemPicked? onReactionPicked;

  /// Called when the "add reaction" button is tapped.
  ///
  /// The add button is always visible. When null, it is rendered in a
  /// disabled state.
  final VoidCallback? onAddReactionTap;
}

/// The default implementation of [StreamReactionPicker].
///
/// Resolves [StreamReactionPickerProps] into a horizontally scrollable row of
/// [StreamEmojiButton]s with a fixed trailing add button, inside a [Material]
/// container.
///
/// The reaction buttons scroll horizontally while the add button stays pinned
/// at the trailing edge.
///
/// Style resolution order: theme → built-in defaults.
///
/// See also:
///
///  * [StreamReactionPicker], the public API widget.
///  * [StreamReactionPickerTheme], for customizing appearance.
class DefaultStreamReactionPicker extends StatelessWidget {
  /// Creates a default reaction picker with the given [props].
  const DefaultStreamReactionPicker({super.key, required this.props});

  /// The properties that configure this widget.
  final StreamReactionPickerProps props;

  @override
  Widget build(BuildContext context) {
    final icons = context.streamIcons;
    final theme = context.streamReactionPickerTheme;
    final defaults = _StreamReactionPickerThemeDefaults(context);

    final effectivePadding = theme.padding ?? defaults.padding;
    final effectiveSide = theme.side ?? defaults.side;
    final effectiveShape = theme.shape ?? defaults.shape;
    final effectiveElevation = theme.elevation ?? defaults.elevation;
    final effectiveSpacing = theme.spacing ?? defaults.spacing;
    final effectiveBackgroundColor = theme.backgroundColor ?? defaults.backgroundColor;

    final shape = effectiveShape.copyWith(side: effectiveSide);

    final reactionButtons = props.items.map(
      (item) => StreamEmojiButton(
        key: Key(item.key),
        size: .lg,
        emoji: item.emoji,
        isSelected: item.isSelected,
        onPressed: switch (props.onReactionPicked) {
          final onPicked? => () => onPicked(item),
          _ => null,
        },
      ),
    );

    final scrollableReactions = SingleChildScrollView(
      padding: effectivePadding,
      scrollDirection: .horizontal,
      child: Row(
        mainAxisSize: .min,
        spacing: effectiveSpacing,
        children: [...reactionButtons],
      ),
    );

    return Material(
      shape: shape,
      elevation: effectiveElevation,
      clipBehavior: .antiAlias,
      color: effectiveBackgroundColor,
      child: Row(
        mainAxisSize: .min,
        children: [
          Flexible(child: scrollableReactions),
          StreamButton.icon(
            key: const Key('add_reaction'),
            size: .small,
            type: .outline,
            style: .secondary,
            icon: icons.plus,
            onTap: props.onAddReactionTap,
          ),
        ],
      ),
    );
  }
}

// Provides default values for the reaction picker theme based on the current
// [StreamTheme] context.
class _StreamReactionPickerThemeDefaults extends StreamReactionPickerThemeData {
  _StreamReactionPickerThemeDefaults(this._context);

  final BuildContext _context;

  late final StreamColorScheme _colorScheme = _context.streamColorScheme;
  late final StreamRadius _radius = _context.streamRadius;
  late final StreamSpacing _spacing = _context.streamSpacing;

  @override
  double get elevation => 3;

  @override
  double get spacing => _spacing.xxxs;

  @override
  Color get backgroundColor => _colorScheme.backgroundElevation2;

  @override
  EdgeInsetsGeometry get padding => EdgeInsetsDirectional.only(start: _spacing.xxs);

  @override
  OutlinedBorder get shape => RoundedSuperellipseBorder(borderRadius: .all(_radius.xxxxl));

  @override
  BorderSide get side => BorderSide(color: _colorScheme.borderDefault);
}
