import 'dart:math' show Random;

import 'package:flutter/material.dart';
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
  const ThemeCustomizationPanel({
    super.key,
    required this.configuration,
  });

  final ThemeConfiguration configuration;

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
    return ListenableBuilder(
      listenable: widget.configuration,
      builder: (context, _) {
        final streamTheme = widget.configuration.themeData;
        final colorScheme = streamTheme.colorScheme;
        final textTheme = streamTheme.textTheme;
        final boxShadow = streamTheme.boxShadow;
        final materialTheme = widget.configuration.buildMaterialTheme();

        // Wrap with Theme to apply Stream theming to all widgets
        return Theme(
          data: materialTheme,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.backgroundApp,
              border: Border(
                left: BorderSide(color: colorScheme.borderSurfaceSubtle),
              ),
            ),
            child: Column(
              children: [
                _buildHeader(colorScheme, textTheme),
                Expanded(
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildAppearanceSection(colorScheme, textTheme),
                          const SizedBox(height: 16),
                          _buildBrandSection(colorScheme, boxShadow),
                          const SizedBox(height: 16),
                          _buildAccentColorsSection(colorScheme, boxShadow),
                          const SizedBox(height: 16),
                          _buildTextColorsSection(colorScheme, boxShadow),
                          const SizedBox(height: 16),
                          _buildBackgroundColorsSection(colorScheme, boxShadow),
                          const SizedBox(height: 16),
                          _buildBorderCoreSection(colorScheme, boxShadow),
                          const SizedBox(height: 16),
                          _buildBorderUtilitySection(colorScheme, boxShadow),
                          const SizedBox(height: 16),
                          _buildStateColorsSection(colorScheme, boxShadow),
                          const SizedBox(height: 16),
                          _buildSystemColorsSection(colorScheme, boxShadow),
                          const SizedBox(height: 16),
                          _buildAvatarPaletteSection(colorScheme),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    StreamColorScheme colorScheme,
    StreamTextTheme textTheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.backgroundSurface,
        border: Border(
          bottom: BorderSide(color: colorScheme.borderSurfaceSubtle),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.accentPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.tune, color: colorScheme.accentPrimary, size: 20),
          ),
          const SizedBox(width: 12),
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
              borderRadius: BorderRadius.circular(6),
              child: InkWell(
                onTap: widget.configuration.resetToDefaults,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.all(8),
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

  Widget _buildAppearanceSection(
    StreamColorScheme colorScheme,
    StreamTextTheme textTheme,
  ) {
    return SectionCard(
      colorScheme: colorScheme,
      title: 'Appearance',
      subtitle: 'brightness',
      icon: Icons.brightness_6,
      child: Row(
        children: [
          Expanded(
            child: ThemeStudioModeButton(
              label: 'Light',
              icon: Icons.light_mode,
              isSelected: widget.configuration.brightness == Brightness.light,
              colorScheme: colorScheme,
              textTheme: textTheme,
              onTap: () => widget.configuration.setBrightness(Brightness.light),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ThemeStudioModeButton(
              label: 'Dark',
              icon: Icons.dark_mode,
              isSelected: widget.configuration.brightness == Brightness.dark,
              colorScheme: colorScheme,
              textTheme: textTheme,
              onTap: () => widget.configuration.setBrightness(Brightness.dark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandSection(
    StreamColorScheme colorScheme,
    StreamBoxShadow boxShadow,
  ) {
    final config = widget.configuration;

    return SectionCard(
      colorScheme: colorScheme,
      title: 'Brand Color',
      subtitle: 'brand',
      icon: Icons.branding_watermark,
      child: ColorPickerTile(
        label: 'brandPrimary',
        color: config.brandPrimaryColor,
        colorScheme: colorScheme,
        boxShadow: boxShadow,
        onColorChanged: config.setBrandPrimaryColor,
      ),
    );
  }

  Widget _buildAccentColorsSection(
    StreamColorScheme colorScheme,
    StreamBoxShadow boxShadow,
  ) {
    final config = widget.configuration;
    return SectionCard(
      colorScheme: colorScheme,
      title: 'Accent Colors',
      subtitle: 'accent*',
      icon: Icons.color_lens,
      child: Column(
        children: [
          ColorPickerTile(
            label: 'accentPrimary',
            color: config.accentPrimary,
            colorScheme: colorScheme,
            boxShadow: boxShadow,
            onColorChanged: config.setAccentPrimary,
          ),
          ColorPickerTile(
            label: 'accentSuccess',
            color: config.accentSuccess,
            colorScheme: colorScheme,
            boxShadow: boxShadow,
            onColorChanged: config.setAccentSuccess,
          ),
          ColorPickerTile(
            label: 'accentWarning',
            color: config.accentWarning,
            colorScheme: colorScheme,
            boxShadow: boxShadow,
            onColorChanged: config.setAccentWarning,
          ),
          ColorPickerTile(
            label: 'accentError',
            color: config.accentError,
            colorScheme: colorScheme,
            boxShadow: boxShadow,
            onColorChanged: config.setAccentError,
          ),
          ColorPickerTile(
            label: 'accentNeutral',
            color: config.accentNeutral,
            colorScheme: colorScheme,
            boxShadow: boxShadow,
            onColorChanged: config.setAccentNeutral,
          ),
        ],
      ),
    );
  }

  Widget _buildTextColorsSection(
    StreamColorScheme colorScheme,
    StreamBoxShadow boxShadow,
  ) {
    final config = widget.configuration;
    return SectionCard(
      colorScheme: colorScheme,
      title: 'Text Colors',
      subtitle: 'text*',
      icon: Icons.format_color_text,
      child: Column(
        children: [
          ColorPickerTile(
            label: 'textPrimary',
            color: config.textPrimary,
            colorScheme: colorScheme,
            boxShadow: boxShadow,
            onColorChanged: config.setTextPrimary,
          ),
          ColorPickerTile(
            label: 'textSecondary',
            color: config.textSecondary,
            colorScheme: colorScheme,
            boxShadow: boxShadow,
            onColorChanged: config.setTextSecondary,
          ),
          ColorPickerTile(
            label: 'textTertiary',
            color: config.textTertiary,
            colorScheme: colorScheme,
            boxShadow: boxShadow,
            onColorChanged: config.setTextTertiary,
          ),
          ColorPickerTile(
            label: 'textDisabled',
            color: config.textDisabled,
            colorScheme: colorScheme,
            boxShadow: boxShadow,
            onColorChanged: config.setTextDisabled,
          ),
          ColorPickerTile(
            label: 'textInverse',
            color: config.textInverse,
            colorScheme: colorScheme,
            boxShadow: boxShadow,
            onColorChanged: config.setTextInverse,
          ),
          ColorPickerTile(
            label: 'textLink',
            color: config.textLink,
            colorScheme: colorScheme,
            boxShadow: boxShadow,
            onColorChanged: config.setTextLink,
          ),
          ColorPickerTile(
            label: 'textOnAccent',
            color: config.textOnAccent,
            colorScheme: colorScheme,
            boxShadow: boxShadow,
            onColorChanged: config.setTextOnAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundColorsSection(
    StreamColorScheme colorScheme,
    StreamBoxShadow boxShadow,
  ) {
    final config = widget.configuration;
    return SectionCard(
      colorScheme: colorScheme,
      title: 'Background Colors',
      subtitle: 'background*',
      icon: Icons.format_paint,
      child: Column(
        children: [
          ColorPickerTile(
            label: 'backgroundApp',
            color: config.backgroundApp,
            colorScheme: colorScheme,
            boxShadow: boxShadow,
            onColorChanged: config.setBackgroundApp,
          ),
          ColorPickerTile(
            label: 'backgroundSurface',
            color: config.backgroundSurface,
            colorScheme: colorScheme,
            boxShadow: boxShadow,
            onColorChanged: config.setBackgroundSurface,
          ),
          ColorPickerTile(
            label: 'backgroundSurfaceSubtle',
            color: config.backgroundSurfaceSubtle,
            colorScheme: colorScheme,
            boxShadow: boxShadow,
            onColorChanged: config.setBackgroundSurfaceSubtle,
          ),
          ColorPickerTile(
            label: 'backgroundSurfaceStrong',
            color: config.backgroundSurfaceStrong,
            colorScheme: colorScheme,
            boxShadow: boxShadow,
            onColorChanged: config.setBackgroundSurfaceStrong,
          ),
          ColorPickerTile(
            label: 'backgroundOverlay',
            color: config.backgroundOverlay,
            colorScheme: colorScheme,
            boxShadow: boxShadow,
            onColorChanged: config.setBackgroundOverlay,
          ),
        ],
      ),
    );
  }

  Widget _buildBorderCoreSection(
    StreamColorScheme colorScheme,
    StreamBoxShadow boxShadow,
  ) {
    final config = widget.configuration;
    return SectionCard(
      colorScheme: colorScheme,
      title: 'Border Colors - Core',
      subtitle: 'border*',
      icon: Icons.border_all,
      child: Column(
        children: [
          ColorPickerTile(
            label: 'borderSurface',
            color: config.borderSurface,
            colorScheme: colorScheme,
            boxShadow: boxShadow,
            onColorChanged: config.setBorderSurface,
          ),
          ColorPickerTile(
            label: 'borderSurfaceSubtle',
            color: config.borderSurfaceSubtle,
            colorScheme: colorScheme,
            boxShadow: boxShadow,
            onColorChanged: config.setBorderSurfaceSubtle,
          ),
          ColorPickerTile(
            label: 'borderSurfaceStrong',
            color: config.borderSurfaceStrong,
            colorScheme: colorScheme,
            boxShadow: boxShadow,
            onColorChanged: config.setBorderSurfaceStrong,
          ),
          ColorPickerTile(
            label: 'borderOnDark',
            color: config.borderOnDark,
            colorScheme: colorScheme,
            boxShadow: boxShadow,
            onColorChanged: config.setBorderOnDark,
          ),
          ColorPickerTile(
            label: 'borderOnAccent',
            color: config.borderOnAccent,
            colorScheme: colorScheme,
            boxShadow: boxShadow,
            onColorChanged: config.setBorderOnAccent,
          ),
          ColorPickerTile(
            label: 'borderSubtle',
            color: config.borderSubtle,
            colorScheme: colorScheme,
            boxShadow: boxShadow,
            onColorChanged: config.setBorderSubtle,
          ),
          ColorPickerTile(
            label: 'borderImage',
            color: config.borderImage,
            colorScheme: colorScheme,
            boxShadow: boxShadow,
            onColorChanged: config.setBorderImage,
          ),
        ],
      ),
    );
  }

  Widget _buildBorderUtilitySection(
    StreamColorScheme colorScheme,
    StreamBoxShadow boxShadow,
  ) {
    final config = widget.configuration;
    return SectionCard(
      colorScheme: colorScheme,
      title: 'Border Colors - Utility',
      subtitle: 'border*',
      icon: Icons.border_style,
      child: Column(
        children: [
          ColorPickerTile(
            label: 'borderFocus',
            color: config.borderFocus,
            colorScheme: colorScheme,
            boxShadow: boxShadow,
            onColorChanged: config.setBorderFocus,
          ),
          ColorPickerTile(
            label: 'borderDisabled',
            color: config.borderDisabled,
            colorScheme: colorScheme,
            boxShadow: boxShadow,
            onColorChanged: config.setBorderDisabled,
          ),
          ColorPickerTile(
            label: 'borderError',
            color: config.borderError,
            colorScheme: colorScheme,
            boxShadow: boxShadow,
            onColorChanged: config.setBorderError,
          ),
          ColorPickerTile(
            label: 'borderWarning',
            color: config.borderWarning,
            colorScheme: colorScheme,
            boxShadow: boxShadow,
            onColorChanged: config.setBorderWarning,
          ),
          ColorPickerTile(
            label: 'borderSuccess',
            color: config.borderSuccess,
            colorScheme: colorScheme,
            boxShadow: boxShadow,
            onColorChanged: config.setBorderSuccess,
          ),
          ColorPickerTile(
            label: 'borderSelected',
            color: config.borderSelected,
            colorScheme: colorScheme,
            boxShadow: boxShadow,
            onColorChanged: config.setBorderSelected,
          ),
        ],
      ),
    );
  }

  Widget _buildStateColorsSection(
    StreamColorScheme colorScheme,
    StreamBoxShadow boxShadow,
  ) {
    final config = widget.configuration;
    return SectionCard(
      colorScheme: colorScheme,
      title: 'State Colors',
      subtitle: 'state*',
      icon: Icons.touch_app,
      child: Column(
        children: [
          ColorPickerTile(
            label: 'stateHover',
            color: config.stateHover,
            colorScheme: colorScheme,
            boxShadow: boxShadow,
            onColorChanged: config.setStateHover,
          ),
          ColorPickerTile(
            label: 'statePressed',
            color: config.statePressed,
            colorScheme: colorScheme,
            boxShadow: boxShadow,
            onColorChanged: config.setStatePressed,
          ),
          ColorPickerTile(
            label: 'stateSelected',
            color: config.stateSelected,
            colorScheme: colorScheme,
            boxShadow: boxShadow,
            onColorChanged: config.setStateSelected,
          ),
          ColorPickerTile(
            label: 'stateFocused',
            color: config.stateFocused,
            colorScheme: colorScheme,
            boxShadow: boxShadow,
            onColorChanged: config.setStateFocused,
          ),
          ColorPickerTile(
            label: 'stateDisabled',
            color: config.stateDisabled,
            colorScheme: colorScheme,
            boxShadow: boxShadow,
            onColorChanged: config.setStateDisabled,
          ),
        ],
      ),
    );
  }

  Widget _buildSystemColorsSection(
    StreamColorScheme colorScheme,
    StreamBoxShadow boxShadow,
  ) {
    final config = widget.configuration;
    return SectionCard(
      colorScheme: colorScheme,
      title: 'System Colors',
      subtitle: 'system*',
      icon: Icons.settings_system_daydream,
      child: Column(
        children: [
          ColorPickerTile(
            label: 'systemText',
            color: config.systemText,
            colorScheme: colorScheme,
            boxShadow: boxShadow,
            onColorChanged: config.setSystemText,
          ),
          ColorPickerTile(
            label: 'systemScrollbar',
            color: config.systemScrollbar,
            colorScheme: colorScheme,
            boxShadow: boxShadow,
            onColorChanged: config.setSystemScrollbar,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPaletteSection(StreamColorScheme colorScheme) {
    final config = widget.configuration;
    final palette = config.avatarPalette;

    return SectionCard(
      colorScheme: colorScheme,
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
              colorScheme: colorScheme,
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
          const SizedBox(height: 8),
          AddPaletteButton(
            colorScheme: colorScheme,
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
