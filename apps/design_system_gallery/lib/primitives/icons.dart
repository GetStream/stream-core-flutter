import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(
  name: 'All Icons',
  type: StreamIcons,
  path: '[App Foundation]/Primitives/Icons',
)
Widget buildStreamIconsShowcase(BuildContext context) {
  final textTheme = context.streamTextTheme;
  final colorScheme = context.streamColorScheme;

  return DefaultTextStyle(
    style: textTheme.bodyDefault.copyWith(color: colorScheme.textPrimary),
    child: const _IconsPage(),
  );
}

class _IconsPage extends StatefulWidget {
  const _IconsPage();

  @override
  State<_IconsPage> createState() => _IconsPageState();
}

class _IconsPageState extends State<_IconsPage> {
  final _searchController = TextEditingController();
  var _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    final streamIcons = context.streamIcons;
    final allIcons = streamIcons.allIcons.entries.toList();
    final filteredIcons = allIcons.where((MapEntry<String, IconData> entry) {
      if (_searchQuery.isEmpty) return true;
      return entry.key.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search section
          const _SectionLabel(label: 'ICON LIBRARY'),
          SizedBox(height: spacing.md),

          // Search bar
          _SearchBar(
            controller: _searchController,
            iconCount: allIcons.length,
            hasQuery: _searchQuery.isNotEmpty,
            onChanged: (value) => setState(() => _searchQuery = value),
            onClear: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
          ),

          SizedBox(height: spacing.sm),

          // Results count
          Text(
            '${filteredIcons.length} icons${_searchQuery.isNotEmpty ? ' matching "$_searchQuery"' : ''}',
            style: textTheme.captionDefault.copyWith(
              color: colorScheme.textTertiary,
            ),
          ),

          SizedBox(height: spacing.md),

          // Icons grid
          _IconsGrid(icons: filteredIcons),

          SizedBox(height: spacing.xl),

          // Quick reference
          const _QuickReference(),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.iconCount,
    required this.hasQuery,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final int iconCount;
  final bool hasQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;
    final icons = context.streamIcons;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: colorScheme.backgroundSurfaceSubtle,
        borderRadius: BorderRadius.all(radius.lg),
        border: Border.all(color: colorScheme.borderSubtle),
      ),
      child: TextField(
        controller: controller,
        style: textTheme.bodyDefault.copyWith(color: colorScheme.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search $iconCount icons...',
          hintStyle: textTheme.bodyDefault.copyWith(color: colorScheme.textTertiary),
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: spacing.md, right: spacing.sm),
            child: Icon(
              icons.magnifyingGlassSearch,
              size: 20,
              color: colorScheme.textTertiary,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(),
          suffixIcon: hasQuery
              ? IconButton(
                  onPressed: onClear,
                  icon: Icon(
                    icons.crossSmall,
                    size: 18,
                    color: colorScheme.textTertiary,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: spacing.md),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class _IconsGrid extends StatelessWidget {
  const _IconsGrid({required this.icons});

  final List<MapEntry<String, IconData>> icons;

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    if (icons.isEmpty) {
      return _EmptyState();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate columns based on available width
        const minCardWidth = 140.0;
        final gapSize = spacing.sm;
        final columns = (constraints.maxWidth / minCardWidth).floor().clamp(2, 6);
        final cardWidth = (constraints.maxWidth - (gapSize * (columns - 1))) / columns;

        return Wrap(
          spacing: gapSize,
          runSpacing: gapSize,
          children: icons.map((entry) {
            return SizedBox(
              width: cardWidth,
              child: _IconCard(name: entry.key, icon: entry.value),
            );
          }).toList(),
        );
      },
    );
  }
}

class _IconCard extends StatelessWidget {
  const _IconCard({
    required this.name,
    required this.icon,
  });

  final String name;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final boxShadow = context.streamBoxShadow;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: 'StreamIconData.$name'));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Copied: StreamIconData.$name'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      borderRadius: BorderRadius.all(radius.lg),
      child: Container(
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
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon preview
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.backgroundSurfaceSubtle,
                borderRadius: BorderRadius.all(radius.md),
              ),
              child: Icon(
                icon,
                size: 24,
                color: colorScheme.textPrimary,
              ),
            ),
            SizedBox(height: spacing.sm),
            // Icon name
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    name,
                    style: textTheme.metadataEmphasis.copyWith(
                      color: colorScheme.accentPrimary,
                      fontFamily: 'monospace',
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: spacing.xxs),
                Icon(
                  Icons.copy,
                  size: 10,
                  color: colorScheme.textTertiary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final boxShadow = context.streamBoxShadow;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(spacing.xl),
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
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: colorScheme.textTertiary,
          ),
          SizedBox(height: spacing.md),
          Text(
            'No icons found',
            style: textTheme.bodyEmphasis.copyWith(
              color: colorScheme.textSecondary,
            ),
          ),
          SizedBox(height: spacing.xs),
          Text(
            'Try a different search term',
            style: textTheme.captionDefault.copyWith(
              color: colorScheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickReference extends StatelessWidget {
  const _QuickReference();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final boxShadow = context.streamBoxShadow;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: 'QUICK REFERENCE'),
        SizedBox(height: spacing.md),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(spacing.md),
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
              Text(
                'Usage Pattern',
                style: textTheme.captionEmphasis.copyWith(
                  color: colorScheme.textPrimary,
                ),
              ),
              SizedBox(height: spacing.sm),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(spacing.sm),
                decoration: BoxDecoration(
                  color: colorScheme.backgroundSurfaceSubtle,
                  borderRadius: BorderRadius.all(radius.md),
                ),
                child: Text(
                  'Icon(StreamIconData.settingsGear2)',
                  style: textTheme.captionDefault.copyWith(
                    color: colorScheme.accentPrimary,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              SizedBox(height: spacing.md),
              Divider(color: colorScheme.borderSubtle),
              SizedBox(height: spacing.md),
              Text(
                'Themed Icons',
                style: textTheme.captionEmphasis.copyWith(
                  color: colorScheme.textPrimary,
                ),
              ),
              SizedBox(height: spacing.sm),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(spacing.sm),
                decoration: BoxDecoration(
                  color: colorScheme.backgroundSurfaceSubtle,
                  borderRadius: BorderRadius.all(radius.md),
                ),
                child: Text(
                  'Icon(context.streamIcons.settingsGear2)',
                  style: textTheme.captionDefault.copyWith(
                    color: colorScheme.accentPrimary,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              SizedBox(height: spacing.md),
              Text(
                'Use themed icons when you want to allow icon customization via StreamTheme.',
                style: textTheme.captionDefault.copyWith(
                  color: colorScheme.textTertiary,
                ),
              ),
            ],
          ),
        ),
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
      padding: EdgeInsets.symmetric(horizontal: spacing.sm, vertical: spacing.xs),
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
