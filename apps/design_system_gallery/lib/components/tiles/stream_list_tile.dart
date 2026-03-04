import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamListTile,
  path: '[Components]/Tiles',
)
Widget buildStreamListTilePlayground(BuildContext context) {
  return const _PlaygroundDemo();
}

class _PlaygroundDemo extends StatefulWidget {
  const _PlaygroundDemo();

  @override
  State<_PlaygroundDemo> createState() => _PlaygroundDemoState();
}

class _PlaygroundDemoState extends State<_PlaygroundDemo> {
  @override
  Widget build(BuildContext context) {
    final title = context.knobs.string(
      label: 'Title',
      initialValue: 'Alice Johnson',
      description: 'Primary label shown in the tile.',
    );

    final subtitleText = context.knobs.stringOrNull(
      label: 'Subtitle',
      initialValue: 'Online now',
      description: 'Optional secondary text shown below title.',
    );

    final descriptionText = context.knobs.stringOrNull(
      label: 'Description',
      initialValue: '2m',
      description: 'Optional right-side metadata text (e.g. timestamp).',
    );

    final enabled = context.knobs.boolean(
      label: 'Enabled',
      initialValue: true,
      description: 'Whether the tile is interactive.',
    );

    final selected = context.knobs.boolean(
      label: 'Selected',
      description: 'Applies selected colors and selected background.',
    );

    final showLeading = context.knobs.boolean(
      label: 'Leading',
      initialValue: true,
      description: 'Show a leading avatar.',
    );

    final showTrailing = context.knobs.boolean(
      label: 'Trailing',
      initialValue: true,
      description: 'Show a trailing chevron icon.',
    );

    void onTap() {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Tapped'),
            duration: Duration(seconds: 1),
          ),
        );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Material(
          type: MaterialType.transparency,
          child: StreamListTile(
            leading: showLeading ? _avatar('AJ') : null,
            title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: (subtitleText?.isNotEmpty ?? false)
                ? Text(subtitleText!, maxLines: 1, overflow: TextOverflow.ellipsis)
                : null,
            description: (descriptionText?.isNotEmpty ?? false)
                ? Text(descriptionText!, maxLines: 1, overflow: TextOverflow.ellipsis)
                : null,
            trailing: showTrailing ? const Icon(Icons.chevron_right_rounded) : null,
            selected: selected,
            enabled: enabled,
            onTap: enabled ? onTap : null,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamListTile,
  path: '[Components]/Tiles',
)
Widget buildStreamListTileShowcase(BuildContext context) {
  final colorScheme = context.streamColorScheme;
  final textTheme = context.streamTextTheme;
  final spacing = context.streamSpacing;

  return DefaultTextStyle(
    style: textTheme.bodyDefault.copyWith(color: colorScheme.textPrimary),
    child: SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.xl,
        children: const [
          _StatesSection(),
          _LayoutPatternsSection(),
          _RealWorldSection(),
        ],
      ),
    ),
  );
}

// =============================================================================
// States Section
// =============================================================================

class _StatesSection extends StatelessWidget {
  const _StatesSection();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final boxShadow = context.streamBoxShadow;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: [
        const _SectionLabel(label: 'STATES'),
        Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          padding: EdgeInsets.all(spacing.md),
          decoration: BoxDecoration(
            color: colorScheme.backgroundSurface,
            borderRadius: BorderRadius.all(radius.lg),
            boxShadow: boxShadow.elevation1,
          ),
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.all(radius.lg),
            border: Border.all(color: colorScheme.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: spacing.md,
            children: [
              Text(
                'Tap any tile to see the pressed overlay. '
                'Disabled tiles block all interaction.',
                style: textTheme.captionDefault.copyWith(
                  color: colorScheme.textSecondary,
                ),
              ),
              Column(
                spacing: spacing.xs,
                children: const [
                  _StateRow(
                    label: 'Default',
                    subtitle: 'Enabled, not selected',
                    tile: _DemoTile(),
                  ),
                  _StateRow(
                    label: 'Selected',
                    subtitle: 'Selected foreground and background',
                    tile: _DemoTile(selected: true),
                  ),
                  _StateRow(
                    label: 'Disabled',
                    subtitle: 'Non-interactive, muted colors',
                    tile: _DemoTile(enabled: false),
                  ),
                  _StateRow(
                    label: 'Disabled + Selected',
                    subtitle: 'Selected layout with disabled interaction',
                    tile: _DemoTile(enabled: false, selected: true),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Layout Patterns Section
// =============================================================================

class _LayoutPatternsSection extends StatelessWidget {
  const _LayoutPatternsSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: const [
        _SectionLabel(label: 'LAYOUT PATTERNS'),
        Column(
          spacing: 8,
          children: [
            _PatternCard(
              title: 'Title Only',
              tile: _DemoTile(subtitle: null, description: null),
            ),
            _PatternCard(
              title: 'Title + Subtitle',
              tile: _DemoTile(description: null),
            ),
            _PatternCard(
              title: 'Title + Description',
              tile: _DemoTile(subtitle: null),
            ),
            _PatternCard(
              title: 'Full Composition',
              tile: _DemoTile(),
            ),
          ],
        ),
      ],
    );
  }
}

// =============================================================================
// Real-World Section
// =============================================================================

class _RealWorldSection extends StatelessWidget {
  const _RealWorldSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: const [
        _SectionLabel(label: 'REAL-WORLD EXAMPLE'),
        _ExampleCard(
          title: 'Conversation List',
          description:
              'Tap a row to toggle its selected state, mimicking a real '
              'conversation list where the active channel is highlighted.',
          child: _ConversationListExample(),
        ),
      ],
    );
  }
}

class _ConversationListExample extends StatefulWidget {
  const _ConversationListExample();

  @override
  State<_ConversationListExample> createState() => _ConversationListExampleState();
}

class _ConversationListExampleState extends State<_ConversationListExample> {
  static const _items = [
    ('Alice Johnson', 'See you in 10?', '2m'),
    ('Mobile Team', 'Design review starts in 5m', '5m'),
    ('Product Updates', 'Quarterly roadmap posted', '45m'),
    ('Support', 'Ticket #8452 has been resolved', '1h'),
  ];

  var _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;

    return Column(
      children: [
        for (var i = 0; i < _items.length; i++) ...[
          Material(
            type: MaterialType.transparency,
            child: StreamListTile(
              leading: _avatar(_items[i].$1.substring(0, 2).toUpperCase()),
              title: Text(_items[i].$1, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(_items[i].$2, maxLines: 1, overflow: TextOverflow.ellipsis),
              description: Text(_items[i].$3),
              trailing: const Icon(Icons.chevron_right_rounded),
              selected: i == _selectedIndex,
              onTap: () => setState(() => _selectedIndex = i),
            ),
          ),
          if (i < _items.length - 1) Divider(height: 1, color: colorScheme.borderSubtle),
        ],
      ],
    );
  }
}

// =============================================================================
// Shared Widgets
// =============================================================================

class _StateRow extends StatelessWidget {
  const _StateRow({
    required this.label,
    required this.subtitle,
    required this.tile,
  });

  final String label;
  final String subtitle;
  final Widget tile;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.captionEmphasis.copyWith(color: colorScheme.textPrimary),
        ),
        Text(
          subtitle,
          style: textTheme.metadataDefault.copyWith(color: colorScheme.textTertiary),
        ),
        SizedBox(height: spacing.xs),
        tile,
      ],
    );
  }
}

class _PatternCard extends StatelessWidget {
  const _PatternCard({required this.title, required this.tile});

  final String title;
  final Widget tile;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.all(spacing.sm),
      decoration: BoxDecoration(
        color: colorScheme.backgroundSurfaceSubtle,
        borderRadius: BorderRadius.all(radius.md),
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.all(radius.md),
        border: Border.all(color: colorScheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.captionEmphasis.copyWith(color: colorScheme.textSecondary),
          ),
          SizedBox(height: spacing.xs),
          tile,
        ],
      ),
    );
  }
}

class _ExampleCard extends StatelessWidget {
  const _ExampleCard({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final boxShadow = context.streamBoxShadow;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colorScheme.backgroundSurface,
        borderRadius: BorderRadius.all(radius.lg),
        boxShadow: boxShadow.elevation1,
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.all(radius.lg),
        border: Border.all(color: colorScheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.md,
              vertical: spacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.captionEmphasis.copyWith(
                    color: colorScheme.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: textTheme.metadataDefault.copyWith(
                    color: colorScheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colorScheme.borderSubtle),
          child,
        ],
      ),
    );
  }
}

class _DemoTile extends StatelessWidget {
  const _DemoTile({
    this.enabled = true,
    this.selected = false,
    this.subtitle = 'Online now',
    this.description = '2m',
  });

  final bool enabled;
  final bool selected;
  final String? subtitle;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: StreamListTile(
        leading: _avatar('AJ'),
        title: const Text('Alice Johnson', maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: subtitle == null ? null : Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis),
        description: description == null ? null : Text(description!, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.chevron_right_rounded),
        enabled: enabled,
        selected: selected,
        onTap: enabled ? () {} : null,
      ),
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

Widget _avatar(String initials) {
  return StreamAvatar(
    placeholder: (_) => Text(initials),
  );
}
