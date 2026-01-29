import 'dart:math' show Random;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';

import '../../config/theme_configuration.dart';
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
/// Organized into sections matching [StreamColorScheme] structure.
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
        color: colorScheme.backgroundApp,
      ),
      foregroundDecoration: BoxDecoration(
        border: .symmetric(
          vertical: .new(color: colorScheme.borderSurfaceSubtle),
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
                    _buildAccentColorsSection(context),
                    SizedBox(height: spacing.md),
                    _buildTextColorsSection(context),
                    SizedBox(height: spacing.md),
                    _buildBackgroundColorsSection(context),
                    SizedBox(height: spacing.md),
                    _buildBorderCoreSection(context),
                    SizedBox(height: spacing.md),
                    _buildBorderUtilitySection(context),
                    SizedBox(height: spacing.md),
                    _buildStateColorsSection(context),
                    SizedBox(height: spacing.md),
                    _buildSystemColorsSection(context),
                    SizedBox(height: spacing.md),
                    _buildAvatarPaletteSection(context),
                    SizedBox(height: spacing.md),
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
        border: Border(bottom: .new(color: colorScheme.borderSurfaceSubtle)),
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
                  style: textTheme.bodyEmphasis.copyWith(
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
              color: Colors.transparent,
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
    final config = context.read<ThemeConfiguration>();
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
    final config = context.read<ThemeConfiguration>();
    return SectionCard(
      title: 'Brand Color',
      subtitle: 'brand',
      icon: Icons.branding_watermark,
      child: ColorPickerTile(
        label: 'brandPrimary',
        color: config.brandPrimaryColor,
        onColorChanged: config.setBrandPrimaryColor,
      ),
    );
  }

  Widget _buildAccentColorsSection(BuildContext context) {
    final config = context.read<ThemeConfiguration>();
    return SectionCard(
      title: 'Accent Colors',
      subtitle: 'accent*',
      icon: Icons.color_lens,
      child: Column(
        children: [
          ColorPickerTile(
            label: 'accentPrimary',
            color: config.accentPrimary,
            onColorChanged: config.setAccentPrimary,
          ),
          ColorPickerTile(
            label: 'accentSuccess',
            color: config.accentSuccess,
            onColorChanged: config.setAccentSuccess,
          ),
          ColorPickerTile(
            label: 'accentWarning',
            color: config.accentWarning,
            onColorChanged: config.setAccentWarning,
          ),
          ColorPickerTile(
            label: 'accentError',
            color: config.accentError,
            onColorChanged: config.setAccentError,
          ),
          ColorPickerTile(
            label: 'accentNeutral',
            color: config.accentNeutral,
            onColorChanged: config.setAccentNeutral,
          ),
        ],
      ),
    );
  }

  Widget _buildTextColorsSection(BuildContext context) {
    final config = context.read<ThemeConfiguration>();
    return SectionCard(
      title: 'Text Colors',
      subtitle: 'text*',
      icon: Icons.format_color_text,
      child: Column(
        children: [
          ColorPickerTile(
            label: 'textPrimary',
            color: config.textPrimary,
            onColorChanged: config.setTextPrimary,
          ),
          ColorPickerTile(
            label: 'textSecondary',
            color: config.textSecondary,
            onColorChanged: config.setTextSecondary,
          ),
          ColorPickerTile(
            label: 'textTertiary',
            color: config.textTertiary,
            onColorChanged: config.setTextTertiary,
          ),
          ColorPickerTile(
            label: 'textDisabled',
            color: config.textDisabled,
            onColorChanged: config.setTextDisabled,
          ),
          ColorPickerTile(
            label: 'textInverse',
            color: config.textInverse,
            onColorChanged: config.setTextInverse,
          ),
          ColorPickerTile(
            label: 'textLink',
            color: config.textLink,
            onColorChanged: config.setTextLink,
          ),
          ColorPickerTile(
            label: 'textOnAccent',
            color: config.textOnAccent,
            onColorChanged: config.setTextOnAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundColorsSection(BuildContext context) {
    final config = context.read<ThemeConfiguration>();
    return SectionCard(
      title: 'Background Colors',
      subtitle: 'background*',
      icon: Icons.format_paint,
      child: Column(
        children: [
          ColorPickerTile(
            label: 'backgroundApp',
            color: config.backgroundApp,
            onColorChanged: config.setBackgroundApp,
          ),
          ColorPickerTile(
            label: 'backgroundSurface',
            color: config.backgroundSurface,
            onColorChanged: config.setBackgroundSurface,
          ),
          ColorPickerTile(
            label: 'backgroundSurfaceSubtle',
            color: config.backgroundSurfaceSubtle,
            onColorChanged: config.setBackgroundSurfaceSubtle,
          ),
          ColorPickerTile(
            label: 'backgroundSurfaceStrong',
            color: config.backgroundSurfaceStrong,
            onColorChanged: config.setBackgroundSurfaceStrong,
          ),
          ColorPickerTile(
            label: 'backgroundOverlay',
            color: config.backgroundOverlay,
            onColorChanged: config.setBackgroundOverlay,
          ),
        ],
      ),
    );
  }

  Widget _buildBorderCoreSection(BuildContext context) {
    final config = context.read<ThemeConfiguration>();
    return SectionCard(
      title: 'Border Colors - Core',
      subtitle: 'border*',
      icon: Icons.border_all,
      child: Column(
        children: [
          ColorPickerTile(
            label: 'borderSurface',
            color: config.borderSurface,
            onColorChanged: config.setBorderSurface,
          ),
          ColorPickerTile(
            label: 'borderSurfaceSubtle',
            color: config.borderSurfaceSubtle,
            onColorChanged: config.setBorderSurfaceSubtle,
          ),
          ColorPickerTile(
            label: 'borderSurfaceStrong',
            color: config.borderSurfaceStrong,
            onColorChanged: config.setBorderSurfaceStrong,
          ),
          ColorPickerTile(
            label: 'borderOnDark',
            color: config.borderOnDark,
            onColorChanged: config.setBorderOnDark,
          ),
          ColorPickerTile(
            label: 'borderOnAccent',
            color: config.borderOnAccent,
            onColorChanged: config.setBorderOnAccent,
          ),
          ColorPickerTile(
            label: 'borderSubtle',
            color: config.borderSubtle,
            onColorChanged: config.setBorderSubtle,
          ),
          ColorPickerTile(
            label: 'borderImage',
            color: config.borderImage,
            onColorChanged: config.setBorderImage,
          ),
        ],
      ),
    );
  }

  Widget _buildBorderUtilitySection(BuildContext context) {
    final config = context.read<ThemeConfiguration>();
    return SectionCard(
      title: 'Border Colors - Utility',
      subtitle: 'border*',
      icon: Icons.border_style,
      child: Column(
        children: [
          ColorPickerTile(
            label: 'borderFocus',
            color: config.borderFocus,
            onColorChanged: config.setBorderFocus,
          ),
          ColorPickerTile(
            label: 'borderDisabled',
            color: config.borderDisabled,
            onColorChanged: config.setBorderDisabled,
          ),
          ColorPickerTile(
            label: 'borderError',
            color: config.borderError,
            onColorChanged: config.setBorderError,
          ),
          ColorPickerTile(
            label: 'borderWarning',
            color: config.borderWarning,
            onColorChanged: config.setBorderWarning,
          ),
          ColorPickerTile(
            label: 'borderSuccess',
            color: config.borderSuccess,
            onColorChanged: config.setBorderSuccess,
          ),
          ColorPickerTile(
            label: 'borderSelected',
            color: config.borderSelected,
            onColorChanged: config.setBorderSelected,
          ),
        ],
      ),
    );
  }

  Widget _buildStateColorsSection(BuildContext context) {
    final config = context.read<ThemeConfiguration>();
    return SectionCard(
      title: 'State Colors',
      subtitle: 'state*',
      icon: Icons.touch_app,
      child: Column(
        children: [
          ColorPickerTile(
            label: 'stateHover',
            color: config.stateHover,
            onColorChanged: config.setStateHover,
          ),
          ColorPickerTile(
            label: 'statePressed',
            color: config.statePressed,
            onColorChanged: config.setStatePressed,
          ),
          ColorPickerTile(
            label: 'stateSelected',
            color: config.stateSelected,
            onColorChanged: config.setStateSelected,
          ),
          ColorPickerTile(
            label: 'stateFocused',
            color: config.stateFocused,
            onColorChanged: config.setStateFocused,
          ),
          ColorPickerTile(
            label: 'stateDisabled',
            color: config.stateDisabled,
            onColorChanged: config.setStateDisabled,
          ),
        ],
      ),
    );
  }

  Widget _buildSystemColorsSection(BuildContext context) {
    final config = context.read<ThemeConfiguration>();
    return SectionCard(
      title: 'System Colors',
      subtitle: 'system*',
      icon: Icons.settings_system_daydream,
      child: Column(
        children: [
          ColorPickerTile(
            label: 'systemText',
            color: config.systemText,
            onColorChanged: config.setSystemText,
          ),
          ColorPickerTile(
            label: 'systemScrollbar',
            color: config.systemScrollbar,
            onColorChanged: config.setSystemScrollbar,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPaletteSection(BuildContext context) {
    final config = context.read<ThemeConfiguration>();
    final palette = config.avatarPalette;
    final spacing = context.streamSpacing;

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
        ],
      ),
    );
  }
}
