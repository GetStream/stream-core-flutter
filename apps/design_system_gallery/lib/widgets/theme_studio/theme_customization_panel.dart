import 'dart:math' show Random;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_core_flutter/core.dart';

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
        isDefault: !config.brandIsCustom,
        onColorChanged: config.setBrandPrimaryColor,
        onReset: config.resetBrand,
      ),
    );
  }

  Widget _buildChromeSection(BuildContext context) {
    final config = context.read<ThemeConfiguration>();
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
            isDefault: !config.accentPrimaryIsCustom,
            onColorChanged: config.setAccentPrimary,
            onReset: config.resetAccentPrimary,
          ),
          ColorPickerTile(
            label: 'accentSuccess',
            color: config.accentSuccess,
            isDefault: !config.accentSuccessIsCustom,
            onColorChanged: config.setAccentSuccess,
            onReset: config.resetAccentSuccess,
          ),
          ColorPickerTile(
            label: 'accentWarning',
            color: config.accentWarning,
            isDefault: !config.accentWarningIsCustom,
            onColorChanged: config.setAccentWarning,
            onReset: config.resetAccentWarning,
          ),
          ColorPickerTile(
            label: 'accentError',
            color: config.accentError,
            isDefault: !config.accentErrorIsCustom,
            onColorChanged: config.setAccentError,
            onReset: config.resetAccentError,
          ),
          ColorPickerTile(
            label: 'accentNeutral',
            color: config.accentNeutral,
            isDefault: !config.accentNeutralIsCustom,
            onColorChanged: config.setAccentNeutral,
            onReset: config.resetAccentNeutral,
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
            isDefault: !config.textPrimaryIsCustom,
            onColorChanged: config.setTextPrimary,
            onReset: config.resetTextPrimary,
          ),
          ColorPickerTile(
            label: 'textSecondary',
            color: config.textSecondary,
            isDefault: !config.textSecondaryIsCustom,
            onColorChanged: config.setTextSecondary,
            onReset: config.resetTextSecondary,
          ),
          ColorPickerTile(
            label: 'textTertiary',
            color: config.textTertiary,
            isDefault: !config.textTertiaryIsCustom,
            onColorChanged: config.setTextTertiary,
            onReset: config.resetTextTertiary,
          ),
          ColorPickerTile(
            label: 'textDisabled',
            color: config.textDisabled,
            isDefault: !config.textDisabledIsCustom,
            onColorChanged: config.setTextDisabled,
            onReset: config.resetTextDisabled,
          ),
          ColorPickerTile(
            label: 'textLink',
            color: config.textLink,
            isDefault: !config.textLinkIsCustom,
            onColorChanged: config.setTextLink,
            onReset: config.resetTextLink,
          ),
          ColorPickerTile(
            label: 'textOnAccent',
            color: config.textOnAccent,
            isDefault: !config.textOnAccentIsCustom,
            onColorChanged: config.setTextOnAccent,
            onReset: config.resetTextOnAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundColorsSection(BuildContext context) {
    final config = context.read<ThemeConfiguration>();
    final spacing = context.streamSpacing;
    return SectionCard(
      title: 'Background Colors',
      subtitle: 'background*',
      icon: Icons.format_paint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ColorPickerTile(
            label: 'backgroundApp',
            color: config.backgroundApp,
            isDefault: !config.backgroundAppIsCustom,
            onColorChanged: config.setBackgroundApp,
            onReset: config.resetBackgroundApp,
          ),
          ColorPickerTile(
            label: 'backgroundInverse',
            color: config.backgroundInverse,
            isDefault: !config.backgroundInverseIsCustom,
            onColorChanged: config.setBackgroundInverse,
            onReset: config.resetBackgroundInverse,
          ),
          ColorPickerTile(
            label: 'backgroundOnAccent',
            color: config.backgroundOnAccent,
            isDefault: !config.backgroundOnAccentIsCustom,
            onColorChanged: config.setBackgroundOnAccent,
            onReset: config.resetBackgroundOnAccent,
          ),
          ColorPickerTile(
            label: 'backgroundHighlight',
            color: config.backgroundHighlight,
            isDefault: !config.backgroundHighlightIsCustom,
            onColorChanged: config.setBackgroundHighlight,
            onReset: config.resetBackgroundHighlight,
          ),
          ColorPickerTile(
            label: 'backgroundScrim',
            color: config.backgroundScrim,
            isDefault: !config.backgroundScrimIsCustom,
            onColorChanged: config.setBackgroundScrim,
            onReset: config.resetBackgroundScrim,
          ),
          ColorPickerTile(
            label: 'backgroundOverlayLight',
            color: config.backgroundOverlayLight,
            isDefault: !config.backgroundOverlayLightIsCustom,
            onColorChanged: config.setBackgroundOverlayLight,
            onReset: config.resetBackgroundOverlayLight,
          ),
          ColorPickerTile(
            label: 'backgroundOverlayDark',
            color: config.backgroundOverlayDark,
            isDefault: !config.backgroundOverlayDarkIsCustom,
            onColorChanged: config.setBackgroundOverlayDark,
            onReset: config.resetBackgroundOverlayDark,
          ),
          ColorPickerTile(
            label: 'backgroundDisabled',
            color: config.backgroundDisabled,
            isDefault: !config.backgroundDisabledIsCustom,
            onColorChanged: config.setBackgroundDisabled,
            onReset: config.resetBackgroundDisabled,
          ),
          ColorPickerTile(
            label: 'backgroundHover',
            color: config.backgroundHover,
            isDefault: !config.backgroundHoverIsCustom,
            onColorChanged: config.setBackgroundHover,
            onReset: config.resetBackgroundHover,
          ),
          ColorPickerTile(
            label: 'backgroundPressed',
            color: config.backgroundPressed,
            isDefault: !config.backgroundPressedIsCustom,
            onColorChanged: config.setBackgroundPressed,
            onReset: config.resetBackgroundPressed,
          ),
          ColorPickerTile(
            label: 'backgroundSelected',
            color: config.backgroundSelected,
            isDefault: !config.backgroundSelectedIsCustom,
            onColorChanged: config.setBackgroundSelected,
            onReset: config.resetBackgroundSelected,
          ),
          SizedBox(height: spacing.xs),
          Text(
            'Surface',
            style: context.streamTextTheme.metadataEmphasis.copyWith(
              color: context.streamColorScheme.textSecondary,
            ),
          ),
          SizedBox(height: spacing.xs),
          ColorPickerTile(
            label: 'backgroundSurface',
            color: config.backgroundSurface,
            isDefault: !config.backgroundSurfaceIsCustom,
            onColorChanged: config.setBackgroundSurface,
            onReset: config.resetBackgroundSurface,
          ),
          ColorPickerTile(
            label: 'backgroundSurfaceSubtle',
            color: config.backgroundSurfaceSubtle,
            isDefault: !config.backgroundSurfaceSubtleIsCustom,
            onColorChanged: config.setBackgroundSurfaceSubtle,
            onReset: config.resetBackgroundSurfaceSubtle,
          ),
          ColorPickerTile(
            label: 'backgroundSurfaceStrong',
            color: config.backgroundSurfaceStrong,
            isDefault: !config.backgroundSurfaceStrongIsCustom,
            onColorChanged: config.setBackgroundSurfaceStrong,
            onReset: config.resetBackgroundSurfaceStrong,
          ),
          ColorPickerTile(
            label: 'backgroundSurfaceCard',
            color: config.backgroundSurfaceCard,
            isDefault: !config.backgroundSurfaceCardIsCustom,
            onColorChanged: config.setBackgroundSurfaceCard,
            onReset: config.resetBackgroundSurfaceCard,
          ),
          SizedBox(height: spacing.xs),
          Text(
            'Elevation',
            style: context.streamTextTheme.metadataEmphasis.copyWith(
              color: context.streamColorScheme.textSecondary,
            ),
          ),
          SizedBox(height: spacing.xs),
          ColorPickerTile(
            label: 'backgroundElevation0',
            color: config.backgroundElevation0,
            isDefault: !config.backgroundElevation0IsCustom,
            onColorChanged: config.setBackgroundElevation0,
            onReset: config.resetBackgroundElevation0,
          ),
          ColorPickerTile(
            label: 'backgroundElevation1',
            color: config.backgroundElevation1,
            isDefault: !config.backgroundElevation1IsCustom,
            onColorChanged: config.setBackgroundElevation1,
            onReset: config.resetBackgroundElevation1,
          ),
          ColorPickerTile(
            label: 'backgroundElevation2',
            color: config.backgroundElevation2,
            isDefault: !config.backgroundElevation2IsCustom,
            onColorChanged: config.setBackgroundElevation2,
            onReset: config.resetBackgroundElevation2,
          ),
          ColorPickerTile(
            label: 'backgroundElevation3',
            color: config.backgroundElevation3,
            isDefault: !config.backgroundElevation3IsCustom,
            onColorChanged: config.setBackgroundElevation3,
            onReset: config.resetBackgroundElevation3,
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
            label: 'borderDefault',
            color: config.borderDefault,
            isDefault: !config.borderDefaultIsCustom,
            onColorChanged: config.setBorderDefault,
            onReset: config.resetBorderDefault,
          ),
          ColorPickerTile(
            label: 'borderSubtle',
            color: config.borderSubtle,
            isDefault: !config.borderSubtleIsCustom,
            onColorChanged: config.setBorderSubtle,
            onReset: config.resetBorderSubtle,
          ),
          ColorPickerTile(
            label: 'borderStrong',
            color: config.borderStrong,
            isDefault: !config.borderStrongIsCustom,
            onColorChanged: config.setBorderStrong,
            onReset: config.resetBorderStrong,
          ),
          ColorPickerTile(
            label: 'borderOnAccent',
            color: config.borderOnAccent,
            isDefault: !config.borderOnAccentIsCustom,
            onColorChanged: config.setBorderOnAccent,
            onReset: config.resetBorderOnAccent,
          ),
          ColorPickerTile(
            label: 'borderOnSurface',
            color: config.borderOnSurface,
            isDefault: !config.borderOnSurfaceIsCustom,
            onColorChanged: config.setBorderOnSurface,
            onReset: config.resetBorderOnSurface,
          ),
          ColorPickerTile(
            label: 'borderOpacitySubtle',
            color: config.borderOpacitySubtle,
            isDefault: !config.borderOpacitySubtleIsCustom,
            onColorChanged: config.setBorderOpacitySubtle,
            onReset: config.resetBorderOpacitySubtle,
          ),
          ColorPickerTile(
            label: 'borderOpacityStrong',
            color: config.borderOpacityStrong,
            isDefault: !config.borderOpacityStrongIsCustom,
            onColorChanged: config.setBorderOpacityStrong,
            onReset: config.resetBorderOpacityStrong,
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
            isDefault: !config.borderFocusIsCustom,
            onColorChanged: config.setBorderFocus,
            onReset: config.resetBorderFocus,
          ),
          ColorPickerTile(
            label: 'borderActive',
            color: config.borderActive,
            isDefault: !config.borderActiveIsCustom,
            onColorChanged: config.setBorderActive,
            onReset: config.resetBorderActive,
          ),
          ColorPickerTile(
            label: 'borderHover',
            color: config.borderHover,
            isDefault: !config.borderHoverIsCustom,
            onColorChanged: config.setBorderHover,
            onReset: config.resetBorderHover,
          ),
          ColorPickerTile(
            label: 'borderPressed',
            color: config.borderPressed,
            isDefault: !config.borderPressedIsCustom,
            onColorChanged: config.setBorderPressed,
            onReset: config.resetBorderPressed,
          ),
          ColorPickerTile(
            label: 'borderDisabled',
            color: config.borderDisabled,
            isDefault: !config.borderDisabledIsCustom,
            onColorChanged: config.setBorderDisabled,
            onReset: config.resetBorderDisabled,
          ),
          ColorPickerTile(
            label: 'borderError',
            color: config.borderError,
            isDefault: !config.borderErrorIsCustom,
            onColorChanged: config.setBorderError,
            onReset: config.resetBorderError,
          ),
          ColorPickerTile(
            label: 'borderWarning',
            color: config.borderWarning,
            isDefault: !config.borderWarningIsCustom,
            onColorChanged: config.setBorderWarning,
            onReset: config.resetBorderWarning,
          ),
          ColorPickerTile(
            label: 'borderSuccess',
            color: config.borderSuccess,
            isDefault: !config.borderSuccessIsCustom,
            onColorChanged: config.setBorderSuccess,
            onReset: config.resetBorderSuccess,
          ),
          ColorPickerTile(
            label: 'borderSelected',
            color: config.borderSelected,
            isDefault: !config.borderSelectedIsCustom,
            onColorChanged: config.setBorderSelected,
            onReset: config.resetBorderSelected,
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
            isDefault: !config.systemTextIsCustom,
            onColorChanged: config.setSystemText,
            onReset: config.resetSystemText,
          ),
          ColorPickerTile(
            label: 'systemScrollbar',
            color: config.systemScrollbar,
            isDefault: !config.systemScrollbarIsCustom,
            onColorChanged: config.setSystemScrollbar,
            onReset: config.resetSystemScrollbar,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPaletteSection(BuildContext context) {
    final config = context.read<ThemeConfiguration>();
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
}
