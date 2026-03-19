import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamReactionPicker,
  path: '[Components]/Reactions',
)
Widget buildStreamReactionPickerPlayground(BuildContext context) {
  return const _PlaygroundDemo();
}

class _PlaygroundDemo extends StatefulWidget {
  const _PlaygroundDemo();

  @override
  State<_PlaygroundDemo> createState() => _PlaygroundDemoState();
}

class _PlaygroundDemoState extends State<_PlaygroundDemo> {
  final _selectedKeys = <String>{'love'};

  void _toggleReaction(StreamReactionPickerItem item) {
    setState(() {
      if (_selectedKeys.contains(item.key)) {
        _selectedKeys.remove(item.key);
      } else {
        _selectedKeys.add(item.key);
      }
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            _selectedKeys.contains(item.key) ? 'Added: ${item.key}' : 'Removed: ${item.key}',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final reactionCount = context.knobs.int.slider(
      label: 'Reaction Count',
      initialValue: 5,
      min: 1,
      max: _allEmojis.length,
      description: 'Number of emoji reactions to display.',
    );

    final enableAddButton = context.knobs.boolean(
      label: 'Enable Add Button',
      initialValue: true,
      description: 'Whether the add-reaction button is interactive.',
    );

    final enableReactionTap = context.knobs.boolean(
      label: 'Enable Reaction Tap',
      initialValue: true,
      description: 'Whether tapping a reaction triggers the callback.',
    );

    final items = _allEmojis
        .take(reactionCount)
        .map(
          (e) => StreamReactionPickerItem(
            key: e.key,
            emoji: Text(e.emoji),
            isSelected: _selectedKeys.contains(e.key),
          ),
        )
        .toList();

    return Center(
      child: StreamReactionPicker(
        items: items,
        onReactionPicked: enableReactionTap ? _toggleReaction : null,
        onAddReactionTap: enableAddButton ? () => _showSnack(context, 'Open emoji picker') : null,
      ),
    );
  }
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamReactionPicker,
  path: '[Components]/Reactions',
)
Widget buildStreamReactionPickerShowcase(BuildContext context) {
  final spacing = context.streamSpacing;

  return SingleChildScrollView(
    padding: EdgeInsets.all(spacing.lg),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: spacing.xl,
          children: const [
            _DefaultSection(),
            _SelectionStatesSection(),
            _FewReactionsSection(),
            _ManyReactionsSection(),
            _BackgroundColorSection(),
            _ShapeSection(),
            _BorderSection(),
            _ElevationSection(),
            _DisabledSection(),
          ],
        ),
      ),
    ),
  );
}

// =============================================================================
// Default Section
// =============================================================================

class _DefaultSection extends StatelessWidget {
  const _DefaultSection();

  @override
  Widget build(BuildContext context) {
    return _ShowcaseCard(
      label: 'DEFAULT',
      description:
          'Standard reaction picker with a scrollable list of emoji '
          'reactions and a fixed trailing add-reaction button.',
      child: StreamReactionPicker(
        items: _buildItems(_allEmojis.take(5)),
        onReactionPicked: (_) {},
        onAddReactionTap: () {},
      ),
    );
  }
}

// =============================================================================
// Selection States Section
// =============================================================================

class _SelectionStatesSection extends StatelessWidget {
  const _SelectionStatesSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return _ShowcaseCard(
      label: 'SELECTION STATES',
      description:
          'Reactions can be marked as selected to indicate the '
          'current user has already reacted. Selected reactions show a '
          'highlighted background.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.lg,
        children: [
          _ShowcaseRow(
            label: 'None selected',
            child: StreamReactionPicker(
              items: _buildItems(_allEmojis.take(5)),
              onReactionPicked: (_) {},
              onAddReactionTap: () {},
            ),
          ),
          _ShowcaseRow(
            label: 'Some selected',
            child: StreamReactionPicker(
              items: _buildItems(
                _allEmojis.take(5),
                selectedKeys: {'like', 'fire'},
              ),
              onReactionPicked: (_) {},
              onAddReactionTap: () {},
            ),
          ),
          _ShowcaseRow(
            label: 'All selected',
            child: StreamReactionPicker(
              items: _buildItems(
                _allEmojis.take(5),
                selectedKeys: _allEmojis.take(5).map((e) => e.key).toSet(),
              ),
              onReactionPicked: (_) {},
              onAddReactionTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Few Reactions Section
// =============================================================================

class _FewReactionsSection extends StatelessWidget {
  const _FewReactionsSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return _ShowcaseCard(
      label: 'FEW REACTIONS',
      description:
          'The picker adapts its width to the number of reactions. '
          'With fewer items, the container stays compact.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.lg,
        children: [
          _ShowcaseRow(
            label: '1 reaction',
            child: StreamReactionPicker(
              items: _buildItems(_allEmojis.take(1)),
              onReactionPicked: (_) {},
              onAddReactionTap: () {},
            ),
          ),
          _ShowcaseRow(
            label: '2 reactions',
            child: StreamReactionPicker(
              items: _buildItems(_allEmojis.take(2)),
              onReactionPicked: (_) {},
              onAddReactionTap: () {},
            ),
          ),
          _ShowcaseRow(
            label: '3 reactions',
            child: StreamReactionPicker(
              items: _buildItems(
                _allEmojis.take(3),
                selectedKeys: {'love'},
              ),
              onReactionPicked: (_) {},
              onAddReactionTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Many Reactions Section
// =============================================================================

class _ManyReactionsSection extends StatelessWidget {
  const _ManyReactionsSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return _ShowcaseCard(
      label: 'MANY REACTIONS',
      description:
          'When many reactions are available, the list becomes '
          'horizontally scrollable while the add button stays pinned at the '
          'trailing edge.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.lg,
        children: [
          _ShowcaseRow(
            label: '7 reactions',
            child: StreamReactionPicker(
              items: _buildItems(
                _allEmojis.take(7),
                selectedKeys: {'like', 'fire', 'rocket'},
              ),
              onReactionPicked: (_) {},
              onAddReactionTap: () {},
            ),
          ),
          _ShowcaseRow(
            label: 'All reactions',
            child: StreamReactionPicker(
              items: _buildItems(
                _allEmojis,
                selectedKeys: {'love', 'clap', 'party'},
              ),
              onReactionPicked: (_) {},
              onAddReactionTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Background Color Section
// =============================================================================

class _BackgroundColorSection extends StatelessWidget {
  const _BackgroundColorSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;
    final colorScheme = context.streamColorScheme;

    final items = _buildItems(
      _allEmojis.take(5),
      selectedKeys: {'like'},
    );

    return _ShowcaseCard(
      label: 'BACKGROUND COLOR',
      description:
          'The container background can be customised through '
          'StreamReactionPickerTheme.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.lg,
        children: [
          _ShowcaseRow(
            label: 'default (backgroundElevation2)',
            child: StreamReactionPicker(
              items: items,
              onReactionPicked: (_) {},
              onAddReactionTap: () {},
            ),
          ),
          _ShowcaseRow(
            label: 'backgroundSurface',
            child: StreamReactionPickerTheme(
              data: StreamReactionPickerThemeData(
                backgroundColor: colorScheme.backgroundSurface,
              ),
              child: StreamReactionPicker(
                items: items,
                onReactionPicked: (_) {},
                onAddReactionTap: () {},
              ),
            ),
          ),
          _ShowcaseRow(
            label: 'backgroundSurfaceSubtle',
            child: StreamReactionPickerTheme(
              data: StreamReactionPickerThemeData(
                backgroundColor: colorScheme.backgroundSurfaceSubtle,
              ),
              child: StreamReactionPicker(
                items: items,
                onReactionPicked: (_) {},
                onAddReactionTap: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Shape Section
// =============================================================================

class _ShapeSection extends StatelessWidget {
  const _ShapeSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;
    final radius = context.streamRadius;

    final items = _buildItems(
      _allEmojis.take(5),
      selectedKeys: {'love'},
    );

    return _ShowcaseCard(
      label: 'SHAPE',
      description:
          'The picker container shape can be overridden. Defaults '
          'to a RoundedSuperellipseBorder with xxxxl radius.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.lg,
        children: [
          _ShowcaseRow(
            label: 'default (superellipse xxxxl)',
            child: StreamReactionPicker(
              items: items,
              onReactionPicked: (_) {},
              onAddReactionTap: () {},
            ),
          ),
          _ShowcaseRow(
            label: 'rounded rectangle (lg)',
            child: StreamReactionPickerTheme(
              data: StreamReactionPickerThemeData(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(radius.lg),
                ),
              ),
              child: StreamReactionPicker(
                items: items,
                onReactionPicked: (_) {},
                onAddReactionTap: () {},
              ),
            ),
          ),
          _ShowcaseRow(
            label: 'stadium',
            child: StreamReactionPickerTheme(
              data: const StreamReactionPickerThemeData(
                shape: StadiumBorder(),
              ),
              child: StreamReactionPicker(
                items: items,
                onReactionPicked: (_) {},
                onAddReactionTap: () {},
              ),
            ),
          ),
          _ShowcaseRow(
            label: 'rounded rectangle (xs)',
            child: StreamReactionPickerTheme(
              data: StreamReactionPickerThemeData(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(radius.xs),
                ),
              ),
              child: StreamReactionPicker(
                items: items,
                onReactionPicked: (_) {},
                onAddReactionTap: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Border Section
// =============================================================================

class _BorderSection extends StatelessWidget {
  const _BorderSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;
    final colorScheme = context.streamColorScheme;

    final items = _buildItems(
      _allEmojis.take(5),
      selectedKeys: {'fire'},
    );

    return _ShowcaseCard(
      label: 'SIDE (BORDER)',
      description:
          'The border is controlled through StreamReactionPickerTheme. '
          'Accepts a regular BorderSide.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.lg,
        children: [
          _ShowcaseRow(
            label: 'default (borderDefault)',
            child: StreamReactionPicker(
              items: items,
              onReactionPicked: (_) {},
              onAddReactionTap: () {},
            ),
          ),
          _ShowcaseRow(
            label: 'accentPrimary border',
            child: StreamReactionPickerTheme(
              data: StreamReactionPickerThemeData(
                side: BorderSide(
                  color: colorScheme.accentPrimary,
                  width: 1.5,
                ),
              ),
              child: StreamReactionPicker(
                items: items,
                onReactionPicked: (_) {},
                onAddReactionTap: () {},
              ),
            ),
          ),
          _ShowcaseRow(
            label: 'thick border',
            child: StreamReactionPickerTheme(
              data: StreamReactionPickerThemeData(
                side: BorderSide(
                  color: colorScheme.borderDefault,
                  width: 2,
                ),
              ),
              child: StreamReactionPicker(
                items: items,
                onReactionPicked: (_) {},
                onAddReactionTap: () {},
              ),
            ),
          ),
          _ShowcaseRow(
            label: 'no border',
            child: StreamReactionPickerTheme(
              data: const StreamReactionPickerThemeData(
                side: BorderSide.none,
              ),
              child: StreamReactionPicker(
                items: items,
                onReactionPicked: (_) {},
                onAddReactionTap: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Elevation Section
// =============================================================================

class _ElevationSection extends StatelessWidget {
  const _ElevationSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    final items = _buildItems(
      _allEmojis.take(5),
      selectedKeys: {'laugh'},
    );

    return _ShowcaseCard(
      label: 'ELEVATION',
      description:
          'Controls the shadow depth of the picker container. '
          'Defaults to 3.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.lg,
        children: [
          _ShowcaseRow(
            label: 'elevation: 0',
            child: StreamReactionPickerTheme(
              data: const StreamReactionPickerThemeData(elevation: 0),
              child: StreamReactionPicker(
                items: items,
                onReactionPicked: (_) {},
                onAddReactionTap: () {},
              ),
            ),
          ),
          _ShowcaseRow(
            label: 'elevation: 3 (default)',
            child: StreamReactionPicker(
              items: items,
              onReactionPicked: (_) {},
              onAddReactionTap: () {},
            ),
          ),
          _ShowcaseRow(
            label: 'elevation: 6',
            child: StreamReactionPickerTheme(
              data: const StreamReactionPickerThemeData(elevation: 6),
              child: StreamReactionPicker(
                items: items,
                onReactionPicked: (_) {},
                onAddReactionTap: () {},
              ),
            ),
          ),
          _ShowcaseRow(
            label: 'elevation: 12',
            child: StreamReactionPickerTheme(
              data: const StreamReactionPickerThemeData(elevation: 12),
              child: StreamReactionPicker(
                items: items,
                onReactionPicked: (_) {},
                onAddReactionTap: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Disabled Section
// =============================================================================

class _DisabledSection extends StatelessWidget {
  const _DisabledSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return _ShowcaseCard(
      label: 'DISABLED STATES',
      description:
          'The add-reaction button is always visible. When '
          'onAddReactionTap is null, it renders in a disabled state. '
          'Reaction callbacks can also be omitted.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.lg,
        children: [
          _ShowcaseRow(
            label: 'Add button disabled',
            child: StreamReactionPicker(
              items: _buildItems(
                _allEmojis.take(5),
                selectedKeys: {'like'},
              ),
              onReactionPicked: (_) {},
            ),
          ),
          _ShowcaseRow(
            label: 'All disabled',
            child: StreamReactionPicker(
              items: _buildItems(
                _allEmojis.take(5),
                selectedKeys: {'like', 'love'},
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Showcase helpers
// =============================================================================

class _ShowcaseCard extends StatelessWidget {
  const _ShowcaseCard({
    required this.label,
    required this.description,
    required this.child,
  });

  final String label;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: [
        _SectionLabel(label: label),
        Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: colorScheme.backgroundApp,
            borderRadius: BorderRadius.all(radius.lg),
          ),
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.all(radius.lg),
            border: Border.all(color: colorScheme.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  spacing.md,
                  spacing.sm,
                  spacing.md,
                  spacing.xs,
                ),
                child: Text(
                  description,
                  style: textTheme.captionDefault.copyWith(
                    color: colorScheme.textSecondary,
                  ),
                ),
              ),
              Divider(height: 1, color: colorScheme.borderSubtle),
              Padding(
                padding: EdgeInsets.all(spacing.md),
                child: child,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ShowcaseRow extends StatelessWidget {
  const _ShowcaseRow({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.xs,
      children: [
        Text(
          label,
          style: textTheme.metadataEmphasis.copyWith(
            color: colorScheme.textTertiary,
            fontFamily: 'monospace',
            fontSize: 10,
          ),
        ),
        child,
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.sm,
        vertical: spacing.xs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.accentPrimary,
        borderRadius: BorderRadius.all(radius.xs),
      ),
      child: Text(
        label,
        style: textTheme.metadataEmphasis.copyWith(
          color: colorScheme.textOnAccent,
          letterSpacing: 1,
          fontSize: 9,
        ),
      ),
    );
  }
}

// =============================================================================
// Helpers
// =============================================================================

void _showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
}

List<StreamReactionPickerItem> _buildItems(
  Iterable<_EmojiEntry> entries, {
  Set<String> selectedKeys = const {},
}) {
  return [
    for (final e in entries)
      StreamReactionPickerItem(
        key: e.key,
        emoji: Text(e.emoji),
        isSelected: selectedKeys.contains(e.key),
      ),
  ];
}

@immutable
class _EmojiEntry {
  const _EmojiEntry(this.key, this.emoji);

  final String key;
  final String emoji;
}

const _allEmojis = <_EmojiEntry>[
  _EmojiEntry('like', '👍'),
  _EmojiEntry('love', '❤️'),
  _EmojiEntry('laugh', '😂'),
  _EmojiEntry('fire', '🔥'),
  _EmojiEntry('clap', '👏'),
  _EmojiEntry('party', '🎉'),
  _EmojiEntry('rocket', '🚀'),
  _EmojiEntry('think', '🤔'),
  _EmojiEntry('eyes', '👀'),
  _EmojiEntry('pray', '🙏'),
  _EmojiEntry('wave', '👋'),
  _EmojiEntry('star', '⭐'),
  _EmojiEntry('check', '✅'),
  _EmojiEntry('hundred', '💯'),
  _EmojiEntry('sparkles', '✨'),
  _EmojiEntry('heart_eyes', '😍'),
  _EmojiEntry('sob', '😭'),
  _EmojiEntry('angry', '😡'),
  _EmojiEntry('sunglasses', '😎'),
  _EmojiEntry('skull', '💀'),
  _EmojiEntry('muscle', '💪'),
  _EmojiEntry('raised_hands', '🙌'),
  _EmojiEntry('trophy', '🏆'),
  _EmojiEntry('lightning', '⚡'),
  _EmojiEntry('diamond', '💎'),
  _EmojiEntry('rainbow', '🌈'),
  _EmojiEntry('sun', '☀️'),
  _EmojiEntry('moon', '🌙'),
  _EmojiEntry('pizza', '🍕'),
  _EmojiEntry('coffee', '☕'),
];
