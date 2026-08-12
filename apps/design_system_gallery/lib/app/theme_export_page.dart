import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_core_flutter/core.dart';

import '../config/component_theme_descriptors.dart';
import '../config/theme_color_slot.dart';
import '../config/theme_configuration.dart';
import '../config/theme_export_configuration.dart';
import '../config/theme_studio_sections.dart';
import '../widgets/theme_export/theme_export_widgets.dart';
import '../widgets/theme_studio/add_component_theme_button.dart';
import '../widgets/theme_studio/color_picker_tile.dart';

/// Each settings column's width in the side-by-side layout — slightly wider
/// than the theme studio panel (`kThemePanelWidth` in gallery_shell.dart,
/// 340) since a column here also carries its own copy of the row content
/// the studio doesn't need to fit (e.g. wider component property names).
const _kSettingsColumnWidth = 360.0;

const _kSettingsWidth = _kSettingsColumnWidth * 2 + kExportLinkColumnWidth;

/// The code pane's floor in the side-by-side layout — it's handed
/// everything left over after the (fixed-width) settings columns, down to
/// this minimum, not a fixed width of its own.
const _kCodePaneMinWidth = 440.0;

/// Below this width, the settings columns and a code pane wide enough to be
/// useful no longer fit side by side — collapse into two tabs instead.
const _kTabsBreakpoint = _kSettingsWidth + _kCodePaneMinWidth;

/// Full-screen theme export page: light settings, dark settings, and a live,
/// copy-pasteable Dart snippet, pushed from the toolbar's export button.
///
/// Seeds two independent [ThemeConfiguration]s (see
/// [ThemeExportConfiguration]) from the theme studio's current,
/// brightness-agnostic state. Edits here never write back to the studio —
/// export is one-way.
class ThemeExportPage extends StatefulWidget {
  const ThemeExportPage({super.key});

  @override
  State<ThemeExportPage> createState() => _ThemeExportPageState();
}

class _ThemeExportPageState extends State<ThemeExportPage> {
  late final ThemeExportConfiguration _export;

  @override
  void initState() {
    super.initState();
    _export = ThemeExportConfiguration(context.read<ThemeConfiguration>());
  }

  @override
  void dispose() {
    _export.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final useTabs = MediaQuery.sizeOf(context).width < _kTabsBreakpoint;

    return ChangeNotifierProvider<ThemeExportConfiguration>.value(
      value: _export,
      child: useTabs ? const _TabbedExportLayout() : const _SideBySideExportLayout(),
    );
  }
}

/// The settings columns at a fixed width, beside a code pane that absorbs
/// all remaining width (never less than [_kCodePaneMinWidth] — that's what
/// [_kTabsBreakpoint] guarantees by gating this layout in the first place).
class _SideBySideExportLayout extends StatelessWidget {
  const _SideBySideExportLayout();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export Theme')),
      body: const Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: _kSettingsWidth, child: _SettingsWithPreview()),
          Expanded(child: ThemeExportCodePane()),
        ],
      ),
    );
  }
}

/// Two tabs — Theme Settings / Dart Code — for windows too narrow to show
/// both at a useful width side by side.
class _TabbedExportLayout extends StatelessWidget {
  const _TabbedExportLayout();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Export Theme'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Theme Settings'),
              Tab(text: 'Dart Code'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _SettingsWithPreview(),
            ThemeExportCodePane(),
          ],
        ),
      ),
    );
  }
}

/// The scrollable settings columns with the message preview pinned below
/// them — full width, outside the scroll, on each column's own background.
/// Shared by both layouts.
class _SettingsWithPreview extends StatelessWidget {
  const _SettingsWithPreview();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Expanded(child: _SettingsColumns()),
        ThemeExportPreviewBar(),
      ],
    );
  }
}

/// The two linked settings columns (brand/chrome seeds, then every
/// [ThemeColorSlot] grouped per [themeStudioSections]), lazily built via a
/// [SliverList] — with ~51 color rows this matters for scroll performance.
///
/// Every row (color tiles, section headers, group headings, and the spacing
/// between them) is an [ExportColumnRow], so each column paints one
/// continuous `backgroundApp` from top to bottom with no gaps — nothing
/// shows the page's own background as a seam between rows.
class _SettingsColumns extends StatelessWidget {
  const _SettingsColumns();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    // Measured once here, above ExportColumnRow's IntrinsicHeight (used to
    // align light/dark tiles) - ColorPickerTile can't measure this itself
    // via its own LayoutBuilder, since IntrinsicHeight can't compute
    // intrinsic dimensions through one. See isColorPickerTileCompact.
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnWidth = (constraints.maxWidth - spacing.md * 2 - kExportLinkColumnWidth) / 2;
        final compact = isColorPickerTileCompact(columnWidth, spacing);
        final rows = _buildRows(context, spacing, compact);

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.all(spacing.md),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) => rows[index], childCount: rows.length),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildRows(BuildContext context, StreamSpacing spacing, bool compact) {
    final export = context.watch<ThemeExportConfiguration>();
    Widget spacer(double height) => ExportColumnRow.spacer(
      lightMaterialTheme: export.lightMaterialTheme,
      darkMaterialTheme: export.darkMaterialTheme,
      height: height,
    );

    final rows = <Widget>[
      const _SectionHeader(title: 'Brand & Chrome', subtitle: 'brand, chrome'),
      spacer(spacing.sm),
      LinkedSeedRow(seed: ThemeSeedSlot.brand, label: 'brand', compact: compact),
      LinkedSeedRow(seed: ThemeSeedSlot.chrome, label: 'chrome', compact: compact),
      spacer(spacing.lg),
    ];

    for (final section in themeStudioSections) {
      rows.add(_SectionHeader(title: section.title, subtitle: section.subtitle));
      rows.add(spacer(spacing.sm));
      for (final group in section.groups) {
        if (group.heading case final heading?) {
          rows.add(_GroupHeading(heading));
        }
        rows.addAll(group.slots.map((slot) => LinkedColorRow(slot: slot, compact: compact)));
      }
      rows.add(spacer(spacing.lg));
    }

    for (final component in export.activeComponentThemes) {
      final descriptor = componentThemeDescriptorOrNull(component);
      if (descriptor == null) continue;
      rows.add(_SectionHeader(title: descriptor.name, subtitle: descriptor.themeParameterName));
      rows.add(spacer(spacing.sm));
      rows.addAll(
        descriptor.properties.map(
          (property) => LinkedComponentColorRow(component: component, property: property, compact: compact),
        ),
      );
      rows.add(spacer(spacing.sm));
      rows.add(
        Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.md),
          child: RemoveComponentThemeButton(onTap: () => export.removeComponentTheme(component)),
        ),
      );
      rows.add(spacer(spacing.lg));
    }

    final availableComponentThemes = componentThemeDescriptors
        .where((d) => !export.activeComponentThemes.contains(d.name))
        .toList();
    rows.add(
      Padding(
        padding: EdgeInsets.symmetric(horizontal: spacing.md),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: AddComponentThemeButton(available: availableComponentThemes, onSelected: export.addComponentTheme),
          ),
        ),
      ),
    );

    return rows;
  }
}

/// A section title + subtitle chip (e.g. "Accent Colors" / `accent*`),
/// rendered once per column so it picks up that column's own text colors —
/// a single full-width neutral header would show as a flat, wrong-colored
/// bar cutting across the dark column.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final export = context.watch<ThemeExportConfiguration>();

    return ExportColumnRow(
      lightMaterialTheme: export.lightMaterialTheme,
      darkMaterialTheme: export.darkMaterialTheme,
      lightBuilder: _content,
      darkBuilder: _content,
    );
  }

  Widget _content(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;
    final radius = context.streamRadius;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing.md, vertical: spacing.sm),
      child: Row(
        children: [
          // Expanded, not Flexible: two Flexible children split the free
          // space evenly, which capped the title at ~half the row and
          // ellipsized it while the chip beside it sat in unused space.
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.headingXs.copyWith(color: colorScheme.textPrimary),
            ),
          ),
          SizedBox(width: spacing.xs + spacing.xxs),
          // flex: 0 sizes the chip to its content instead of claiming a
          // share of the row, leaving the rest to the title.
          Flexible(
            flex: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: spacing.xs, vertical: 1),
              decoration: BoxDecoration(
                color: colorScheme.backgroundSurfaceSubtle,
                borderRadius: BorderRadius.all(radius.xs),
              ),
              child: Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.metadataDefault.copyWith(color: colorScheme.textTertiary, fontFamily: 'monospace'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A sub-heading within a section (e.g. "Surface"/"Elevation" inside
/// Background Colors), rendered once per column for the same reason as
/// [_SectionHeader].
class _GroupHeading extends StatelessWidget {
  const _GroupHeading(this.heading);

  final String heading;

  @override
  Widget build(BuildContext context) {
    final export = context.watch<ThemeExportConfiguration>();

    return ExportColumnRow(
      lightMaterialTheme: export.lightMaterialTheme,
      darkMaterialTheme: export.darkMaterialTheme,
      lightBuilder: _content,
      darkBuilder: _content,
    );
  }

  Widget _content(BuildContext context) {
    final spacing = context.streamSpacing;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing.md, vertical: spacing.xs),
      child: Text(
        heading,
        style: context.streamTextTheme.metadataEmphasis.copyWith(color: context.streamColorScheme.textSecondary),
      ),
    );
  }
}
