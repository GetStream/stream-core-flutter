import 'dart:math' show Random;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_core_flutter/core.dart';

import '../../config/component_theme_descriptors.dart';
import '../../config/theme_configuration.dart';
import '../../config/theme_studio_sections.dart';
import 'add_component_theme_button.dart';
import 'avatar_palette_section.dart';
import 'color_picker_tile.dart';
import 'mode_button.dart';
import 'section_card.dart';

final _random = Random();

/// Generates a random avatar color pair matching StreamColors shade patterns.
///
/// Light mode: background shade100 (~95% lightness), foreground shade800 (~35% lightness)
/// Dark mode: background shade800 (~35% lightness), foreground shade100 (~95% lightness)
StreamAvatarColorPair _generateRandomAvatarPair({required bool isDark}) {
  final hue = _random.nextDouble() * 360;
  const saturation = 0.7; // Vivid like StreamColors

  // Lightness values approximating StreamColors shade100 and shade800
  const lightShade = 0.92; // ~shade100
  const darkShade = 0.35; // ~shade800

  final lightColor = HSLColor.fromAHSL(1, hue, saturation, lightShade).toColor();
  final darkColor = HSLColor.fromAHSL(1, hue, saturation, darkShade).toColor();

  return StreamAvatarColorPair(
    backgroundColor: isDark ? darkColor : lightColor,
    foregroundColor: isDark ? lightColor : darkColor,
  );
}

/// A panel widget for customizing the Stream theme.
///
/// Color sections (accent/text/background/border/system) are rendered from
/// [themeStudioSections] so this panel, the export page, and the code
/// generator all stay in sync off a single list. Appearance, brand, chrome,
/// and the avatar palette aren't slot-driven (brightness is a single value,
/// brand/chrome are swatch seeds, and the palette is a list, not a color) so
/// they keep bespoke sections below.
class ThemeCustomizationPanel extends StatefulWidget {
  const ThemeCustomizationPanel({super.key});

  @override
  State<ThemeCustomizationPanel> createState() => _ThemeCustomizationPanelState();
}

class _ThemeCustomizationPanelState extends State<ThemeCustomizationPanel> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final spacing = context.streamSpacing;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.backgroundSurfaceSubtle,
      ),
      foregroundDecoration: BoxDecoration(
        border: .symmetric(
          vertical: .new(color: colorScheme.borderDefault),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.all(spacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildAppearanceSection(context),
                    SizedBox(height: spacing.md),
                    _buildBrandSection(context),
                    SizedBox(height: spacing.md),
                    _buildChromeSection(context),
                    SizedBox(height: spacing.md),
                    for (final section in themeStudioSections) ...[
                      _buildSlotSection(context, section),
                      SizedBox(height: spacing.md),
                    ],
                    _buildAvatarPaletteSection(context),
                    SizedBox(height: spacing.md),
                    for (final component in context.watch<ThemeConfiguration>().activeComponentThemes)
                      if (componentThemeDescriptorOrNull(component) case final descriptor?) ...[
                        _buildComponentThemeSection(context, descriptor),
                        SizedBox(height: spacing.md),
                      ],
                    _buildAddComponentThemeButton(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final config = context.read<ThemeConfiguration>();
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Container(
      padding: EdgeInsets.all(spacing.md),
      decoration: BoxDecoration(
        color: colorScheme.backgroundSurface,
        border: Border(bottom: .new(color: colorScheme.borderDefault)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(spacing.sm),
            decoration: BoxDecoration(
              color: colorScheme.accentPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.all(radius.md),
            ),
            child: Icon(Icons.tune, color: colorScheme.accentPrimary, size: 20),
          ),
          SizedBox(width: spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Theme Studio',
                  style: textTheme.headingXs.copyWith(
                    color: colorScheme.textPrimary,
                  ),
                ),
                Text(
                  'StreamColorScheme',
                  style: textTheme.metadataDefault.copyWith(
                    color: colorScheme.textTertiary,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          // Reset button
          Tooltip(
            message: 'Reset to defaults',
            child: Material(
              color: StreamColors.transparent,
              borderRadius: BorderRadius.all(radius.sm),
              child: InkWell(
                onTap: config.resetToDefaults,
                borderRadius: BorderRadius.all(radius.sm),
                child: Padding(
                  padding: EdgeInsets.all(spacing.sm),
                  child: Icon(
                    Icons.restart_alt,
                    color: colorScheme.textTertiary,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context) {
    final config = context.watch<ThemeConfiguration>();
    final spacing = context.streamSpacing;

    return SectionCard(
      title: 'Appearance',
      subtitle: 'brightness',
      icon: Icons.brightness_6,
      child: Row(
        children: [
          Expanded(
            child: ThemeStudioModeButton(
              label: 'Light',
              icon: Icons.light_mode,
              isSelected: config.brightness == Brightness.light,
              onTap: () => config.setBrightness(Brightness.light),
            ),
          ),
          SizedBox(width: spacing.sm),
          Expanded(
            child: ThemeStudioModeButton(
              label: 'Dark',
              icon: Icons.dark_mode,
              isSelected: config.brightness == Brightness.dark,
              onTap: () => config.setBrightness(Brightness.dark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandSection(BuildContext context) {
    final config = context.watch<ThemeConfiguration>();
    return SectionCard(
      title: 'Brand Color',
      subtitle: 'brand',
      icon: Icons.branding_watermark,
      child: ColorPickerTile(
        label: 'brandPrimary',
        color: config.brandPrimaryColor,
        isDefault: !config.brandIsCustom,
        onColorChanged: config.setBrandPrimaryColor,
        onReset: config.resetBrand,
      ),
    );
  }

  Widget _buildChromeSection(BuildContext context) {
    final config = context.watch<ThemeConfiguration>();
    return SectionCard(
      title: 'Chrome Color',
      subtitle: 'chrome',
      icon: Icons.circle_outlined,
      child: ColorPickerTile(
        label: 'chromePrimary',
        color: config.chromePrimaryColor,
        isDefault: !config.chromeIsCustom,
        onColorChanged: config.setChromePrimaryColor,
        onReset: config.resetChrome,
      ),
    );
  }

  /// Renders one [ThemeStudioSection] as a [SectionCard] of [ColorPickerTile]s,
  /// grouped and sub-headed per [ThemeStudioSlotGroup].
  Widget _buildSlotSection(BuildContext context, ThemeStudioSection section) {
    final config = context.watch<ThemeConfiguration>();
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return SectionCard(
      title: section.title,
      subtitle: section.subtitle,
      icon: section.icon,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final group in section.groups) ...[
            if (group.heading case final heading?) ...[
              if (group != section.groups.first) SizedBox(height: spacing.xs),
              Text(
                heading,
                style: textTheme.metadataEmphasis.copyWith(color: colorScheme.textSecondary),
              ),
              SizedBox(height: spacing.xs),
            ],
            for (final slot in group.slots)
              ColorPickerTile(
                label: slot.parameterName,
                color: config.resolve(slot),
                isDefault: !config.isCustom(slot),
                onColorChanged: (color) => config.setOverride(slot, color),
                onReset: () => config.resetOverride(slot),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatarPaletteSection(BuildContext context) {
    final config = context.watch<ThemeConfiguration>();
    final palette = config.avatarPalette;
    final isDefault = !config.avatarPaletteIsCustom;
    final spacing = context.streamSpacing;
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;

    return SectionCard(
      title: 'Avatar Palette',
      subtitle: 'avatarPalette',
      icon: Icons.palette,
      child: Column(
        children: [
          ...List.generate(palette.length, (index) {
            final pair = palette[index];
            return AvatarColorPairTile(
              index: index,
              pair: pair,
              onBackgroundChanged: (color) {
                config.updateAvatarPaletteAt(
                  index,
                  StreamAvatarColorPair(
                    backgroundColor: color,
                    foregroundColor: pair.foregroundColor,
                  ),
                );
              },
              onForegroundChanged: (color) {
                config.updateAvatarPaletteAt(
                  index,
                  StreamAvatarColorPair(
                    backgroundColor: pair.backgroundColor,
                    foregroundColor: color,
                  ),
                );
              },
              onRemove: palette.length > 1 ? () => config.removeAvatarPaletteAt(index) : null,
            );
          }),
          SizedBox(height: spacing.sm),
          AddPaletteButton(
            onTap: () {
              final isDark = config.brightness == Brightness.dark;
              config.addAvatarPaletteEntry(_generateRandomAvatarPair(isDark: isDark));
            },
          ),
          if (!isDefault) ...[
            SizedBox(height: spacing.sm),
            InkWell(
              onTap: config.resetAvatarPalette,
              borderRadius: BorderRadius.all(context.streamRadius.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restart_alt, color: colorScheme.textTertiary, size: 14),
                  SizedBox(width: spacing.xs),
                  Text(
                    'Reset to default palette',
                    style: textTheme.captionDefault.copyWith(
                      color: colorScheme.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Renders one added component theme (see [ComponentThemeDescriptor]) as a
  /// [SectionCard] of [ColorPickerTile]s, one per editable property, with a
  /// control to remove the whole section.
  Widget _buildComponentThemeSection(BuildContext context, ComponentThemeDescriptor descriptor) {
    final config = context.watch<ThemeConfiguration>();
    final spacing = context.streamSpacing;

    return SectionCard(
      title: descriptor.name,
      subtitle: descriptor.themeParameterName,
      icon: Icons.widgets_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final property in descriptor.properties)
            ColorPickerTile(
              label: property,
              // Component theme properties have no SDK-computed default value
              // available here (unlike StreamColorScheme slots) - the real
              // fallback lives inside each component's own widget. Passing
              // null (rather than guessing a color) renders as "default"
              // instead of a fabricated hex value.
              color: config.resolveComponentColor(descriptor.name, property),
              isDefault: !config.isComponentColorCustom(descriptor.name, property),
              onColorChanged: (color) => config.setComponentColor(descriptor.name, property, color),
              onReset: () => config.resetComponentColor(descriptor.name, property),
            ),
          SizedBox(height: spacing.sm),
          RemoveComponentThemeButton(onTap: () => config.removeComponentTheme(descriptor.name)),
        ],
      ),
    );
  }

  Widget _buildAddComponentThemeButton(BuildContext context) {
    final config = context.watch<ThemeConfiguration>();
    final available = componentThemeDescriptors.where((d) => !config.activeComponentThemes.contains(d.name)).toList();
    return AddComponentThemeButton(available: available, onSelected: config.addComponentTheme);
  }
}
