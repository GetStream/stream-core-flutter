import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/component_theme_descriptors.dart';
import '../../config/theme_color_slot.dart';
import '../../config/theme_configuration.dart';
import '../../config/theme_export_configuration.dart';
import '../theme_studio/color_picker_tile.dart';
import 'export_column_row.dart';
import 'link_toggle_button.dart';

/// One [ThemeColorSlot], rendered as a light tile, a link toggle, and a dark
/// tile. Each tile is themed with the export config's cached light/dark
/// [ThemeData] so it renders — and opens its color picker — in that side's
/// actual colors, independent of the other column.
class LinkedColorRow extends StatelessWidget {
  const LinkedColorRow({super.key, required this.slot, this.compact = false});

  final ThemeColorSlot slot;

  /// Forwarded to both [ColorPickerTile]s — see [isColorPickerTileCompact].
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final export = context.watch<ThemeExportConfiguration>();

    return _LinkedTileRow(
      lightMaterialTheme: export.lightMaterialTheme,
      darkMaterialTheme: export.darkMaterialTheme,
      linked: export.isSlotLinked(slot),
      onToggleLink: () => export.toggleSlotLinked(slot),
      label: slot.parameterName,
      compact: compact,
      lightColor: export.light.resolve(slot),
      lightIsDefault: !export.light.isCustom(slot),
      onLightChanged: (color) => export.setColor(slot, color, from: Brightness.light),
      onLightReset: () => export.resetColor(slot, from: Brightness.light),
      darkColor: export.dark.resolve(slot),
      darkIsDefault: !export.dark.isCustom(slot),
      onDarkChanged: (color) => export.setColor(slot, color, from: Brightness.dark),
      onDarkReset: () => export.resetColor(slot, from: Brightness.dark),
    );
  }
}

/// The brand or chrome seed color, rendered the same way as [LinkedColorRow]
/// but backed by [ThemeExportConfiguration.setSeed]/`resetSeed` since brand
/// and chrome are [ThemeSeedSlot]s, not [ThemeColorSlot]s.
class LinkedSeedRow extends StatelessWidget {
  const LinkedSeedRow({super.key, required this.seed, required this.label, this.compact = false});

  final ThemeSeedSlot seed;
  final String label;

  /// Forwarded to both [ColorPickerTile]s — see [isColorPickerTileCompact].
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final export = context.watch<ThemeExportConfiguration>();

    Color seedColorOf(ThemeConfiguration config) =>
        seed == ThemeSeedSlot.brand ? config.brandPrimaryColor : config.chromePrimaryColor;
    bool isCustomOf(ThemeConfiguration config) =>
        seed == ThemeSeedSlot.brand ? config.brandIsCustom : config.chromeIsCustom;

    return _LinkedTileRow(
      lightMaterialTheme: export.lightMaterialTheme,
      darkMaterialTheme: export.darkMaterialTheme,
      linked: export.isSeedLinked(seed),
      onToggleLink: () => export.toggleSeedLinked(seed),
      label: label,
      compact: compact,
      lightColor: seedColorOf(export.light),
      lightIsDefault: !isCustomOf(export.light),
      onLightChanged: (color) => export.setSeed(seed, color, from: Brightness.light),
      onLightReset: () => export.resetSeed(seed, from: Brightness.light),
      darkColor: seedColorOf(export.dark),
      darkIsDefault: !isCustomOf(export.dark),
      onDarkChanged: (color) => export.setSeed(seed, color, from: Brightness.dark),
      onDarkReset: () => export.resetSeed(seed, from: Brightness.dark),
    );
  }
}

/// One `(component, property)` pair from an active component theme (see
/// [ComponentThemeDescriptor]), rendered the same way as [LinkedColorRow].
///
/// The resolved color is nullable here, unlike [ThemeColorSlot]s: a
/// component theme property has no SDK-computed default this page can
/// resolve (the real fallback lives inside the component's own widget), so
/// [ColorPickerTile] renders `null` as "default" rather than a fabricated
/// color.
class LinkedComponentColorRow extends StatelessWidget {
  const LinkedComponentColorRow({super.key, required this.component, required this.property, this.compact = false});

  final String component;
  final String property;

  /// Forwarded to both [ColorPickerTile]s — see [isColorPickerTileCompact].
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final export = context.watch<ThemeExportConfiguration>();

    return _LinkedTileRow(
      lightMaterialTheme: export.lightMaterialTheme,
      darkMaterialTheme: export.darkMaterialTheme,
      linked: export.isComponentColorLinked(component, property),
      onToggleLink: () => export.toggleComponentColorLinked(component, property),
      label: property,
      compact: compact,
      lightColor: export.light.resolveComponentColor(component, property),
      lightIsDefault: !export.light.isComponentColorCustom(component, property),
      onLightChanged: (color) => export.setComponentColor(component, property, color, from: Brightness.light),
      onLightReset: () => export.resetComponentColor(component, property, from: Brightness.light),
      darkColor: export.dark.resolveComponentColor(component, property),
      darkIsDefault: !export.dark.isComponentColorCustom(component, property),
      onDarkChanged: (color) => export.setComponentColor(component, property, color, from: Brightness.dark),
      onDarkReset: () => export.resetComponentColor(component, property, from: Brightness.dark),
    );
  }
}

/// Shared layout for [LinkedColorRow], [LinkedSeedRow] and
/// [LinkedComponentColorRow]: light tile, link toggle, dark tile — light and
/// dark align by construction since both tiles are the same [ColorPickerTile]
/// with a fixed layout.
class _LinkedTileRow extends StatelessWidget {
  const _LinkedTileRow({
    required this.lightMaterialTheme,
    required this.darkMaterialTheme,
    required this.linked,
    required this.onToggleLink,
    required this.label,
    required this.compact,
    required this.lightColor,
    required this.lightIsDefault,
    required this.onLightChanged,
    required this.onLightReset,
    required this.darkColor,
    required this.darkIsDefault,
    required this.onDarkChanged,
    required this.onDarkReset,
  });

  final ThemeData lightMaterialTheme;
  final ThemeData darkMaterialTheme;
  final bool linked;
  final VoidCallback onToggleLink;
  final String label;
  final bool compact;
  final Color? lightColor;
  final bool lightIsDefault;
  final ValueChanged<Color> onLightChanged;
  final VoidCallback onLightReset;
  final Color? darkColor;
  final bool darkIsDefault;
  final ValueChanged<Color> onDarkChanged;
  final VoidCallback onDarkReset;

  @override
  Widget build(BuildContext context) {
    return ExportColumnRow(
      lightMaterialTheme: lightMaterialTheme,
      darkMaterialTheme: darkMaterialTheme,
      middle: LinkToggleButton(linked: linked, onTap: onToggleLink),
      lightBuilder: (context) => ColorPickerTile(
        label: label,
        color: lightColor,
        isDefault: lightIsDefault,
        onColorChanged: onLightChanged,
        onReset: onLightReset,
        compact: compact,
      ),
      darkBuilder: (context) => ColorPickerTile(
        label: label,
        color: darkColor,
        isDefault: darkIsDefault,
        onColorChanged: onDarkChanged,
        onReset: onDarkReset,
        compact: compact,
      ),
    );
  }
}
