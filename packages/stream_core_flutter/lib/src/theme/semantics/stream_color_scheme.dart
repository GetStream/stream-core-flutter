import 'package:flutter/material.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../../theme/primitives/stream_colors.dart';
import '../primitives/tokens/dark/stream_tokens.dart' as dark_tokens;
import '../primitives/tokens/light/stream_tokens.dart' as light_tokens;

part 'stream_color_scheme.g.theme.dart';

/// A color scheme for the Stream design system.
///
/// [StreamColorScheme] defines the semantic color palette for the Stream design
/// system, including brand colors, accent colors, text colors, background colors,
/// border colors, and state colors. It supports light and dark themes.
///
/// {@tool snippet}
///
/// Create a light color scheme:
///
/// ```dart
/// final colorScheme = StreamColorScheme.light();
/// final primary = colorScheme.accentPrimary;
/// final surface = colorScheme.backgroundSurface;
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Create a dark color scheme with custom brand color:
///
/// ```dart
/// final colorScheme = StreamColorScheme.dark(
///   brand: StreamBrandColor.dark(),
/// );
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamBrandColor], which provides brand color shades.
///  * [StreamColors], which defines the primitive color palette.
@immutable
@ThemeGen(constructor: 'raw')
class StreamColorScheme with _$StreamColorScheme {
  /// Creates a light color scheme.
  factory StreamColorScheme.light({
    // Brand
    StreamColorSwatch? brand,
    // Accent
    Color? accentPrimary,
    Color? accentSuccess,
    Color? accentWarning,
    Color? accentError,
    Color? accentNeutral,
    Color? accentBlack,
    // Text
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textDisabled,
    Color? textInverse,
    Color? textLink,
    Color? textOnAccent,
    Color? textOnDark,
    // Background
    Color? backgroundApp,
    Color? backgroundSurface,
    Color? backgroundSurfaceSubtle,
    Color? backgroundSurfaceStrong,
    Color? backgroundOverlay,
    Color? backgroundOverlayLight,
    Color? backgroundOverlayDark,
    Color? backgroundDisabled,
    Color? backgroundInverse,

    // Background - Elevation
    Color? backgroundElevation0,
    Color? backgroundElevation1,
    Color? backgroundElevation2,
    Color? backgroundElevation3,
    Color? backgroundElevation4,
    // Border - Core
    Color? borderDefault,
    Color? borderSubtle,
    Color? borderStrong,
    Color? borderOnDark,
    Color? borderOnAccent,
    Color? borderOnSurface,
    Color? borderOpacity10,
    Color? borderOpacity25,
    // Border - Utility
    Color? borderFocus,
    Color? borderDisabled,
    Color? borderError,
    Color? borderWarning,
    Color? borderSuccess,
    Color? borderSelected,
    // State
    Color? stateHover,
    Color? statePressed,
    Color? stateSelected,
    Color? stateFocused,
    Color? stateDisabled,
    // System
    Color? systemText,
    Color? systemScrollbar,
    // Avatar
    List<StreamAvatarColorPair>? avatarPalette,
  }) {
    // Brand
    brand ??= StreamBrandColor.light();

    // Accent
    accentPrimary ??= brand.shade500;
    accentSuccess ??= light_tokens.StreamTokens.accentSuccess;
    accentWarning ??= light_tokens.StreamTokens.accentWarning;
    accentError ??= light_tokens.StreamTokens.accentError;
    accentNeutral ??= light_tokens.StreamTokens.accentNeutral;
    accentBlack ??= light_tokens.StreamTokens.accentBlack;

    // Text
    textPrimary ??= light_tokens.StreamTokens.textPrimary;
    textSecondary ??= light_tokens.StreamTokens.textSecondary;
    textTertiary ??= light_tokens.StreamTokens.textTertiary;
    textDisabled ??= light_tokens.StreamTokens.textDisabled;
    textInverse ??= light_tokens.StreamTokens.textInverse;
    textLink ??= accentPrimary;
    textOnAccent ??= light_tokens.StreamTokens.textOnAccent;
    textOnDark ??= light_tokens.StreamTokens.textOnDark;

    // Background

    backgroundApp ??= light_tokens.StreamTokens.backgroundCoreApp;
    backgroundSurface ??= light_tokens.StreamTokens.backgroundCoreSurface;
    backgroundSurfaceSubtle ??= light_tokens.StreamTokens.backgroundCoreSurfaceSubtle;
    backgroundSurfaceStrong ??= light_tokens.StreamTokens.backgroundCoreSurfaceStrong;
    backgroundOverlay ??= light_tokens.StreamTokens.backgroundCoreOverlay;
    backgroundOverlayLight ??= light_tokens.StreamTokens.backgroundCoreOverlayLight;
    backgroundOverlayDark ??= light_tokens.StreamTokens.backgroundCoreOverlayDark;
    backgroundDisabled ??= light_tokens.StreamTokens.backgroundCoreDisabled;
    backgroundInverse ??= light_tokens.StreamTokens.backgroundCoreInverse;

    backgroundElevation0 ??= light_tokens.StreamTokens.backgroundElevationElevation0;
    backgroundElevation1 ??= light_tokens.StreamTokens.backgroundElevationElevation1;
    backgroundElevation2 ??= light_tokens.StreamTokens.backgroundElevationElevation2;
    backgroundElevation3 ??= light_tokens.StreamTokens.backgroundElevationElevation3;
    backgroundElevation4 ??= light_tokens.StreamTokens.backgroundElevationElevation4;

    // Border - Core
    borderDefault ??= light_tokens.StreamTokens.borderCoreDefault;
    borderSubtle ??= light_tokens.StreamTokens.borderCoreSubtle;
    borderStrong ??= light_tokens.StreamTokens.borderCoreStrong;
    borderOnDark ??= light_tokens.StreamTokens.borderCoreOnDark;
    borderOnAccent ??= light_tokens.StreamTokens.borderCoreOnAccent;
    borderOnSurface ??= light_tokens.StreamTokens.borderCoreOnSurface;
    borderOpacity10 ??= light_tokens.StreamTokens.borderCoreOpacity10;
    borderOpacity25 ??= light_tokens.StreamTokens.borderCoreOpacity25;

    // Border - Utility
    borderFocus ??= brand.shade300;
    borderDisabled ??= light_tokens.StreamTokens.borderUtilityDisabled;
    borderError ??= accentError;
    borderWarning ??= accentWarning;
    borderSuccess ??= accentSuccess;
    borderSelected ??= accentPrimary;

    // State
    stateHover ??= light_tokens.StreamTokens.backgroundCoreHover;
    statePressed ??= light_tokens.StreamTokens.backgroundCorePressed;
    stateSelected ??= light_tokens.StreamTokens.backgroundCoreSelected;
    stateFocused ??= brand.shade100;
    stateDisabled ??= light_tokens.StreamTokens.backgroundCoreDisabled;

    // System
    systemText ??= light_tokens.StreamTokens.systemText;
    systemScrollbar ??= light_tokens.StreamTokens.systemScrollbar;

    // Avatar
    avatarPalette ??= [
      StreamAvatarColorPair(
        backgroundColor: StreamColors.blue.shade100,
        foregroundColor: StreamColors.blue.shade800,
      ),
      StreamAvatarColorPair(
        backgroundColor: StreamColors.cyan.shade100,
        foregroundColor: StreamColors.cyan.shade800,
      ),
      StreamAvatarColorPair(
        backgroundColor: StreamColors.green.shade100,
        foregroundColor: StreamColors.green.shade800,
      ),
      StreamAvatarColorPair(
        backgroundColor: StreamColors.purple.shade100,
        foregroundColor: StreamColors.purple.shade800,
      ),
      StreamAvatarColorPair(
        backgroundColor: StreamColors.yellow.shade100,
        foregroundColor: StreamColors.yellow.shade800,
      ),
    ];

    return .raw(
      brand: brand,
      accentPrimary: accentPrimary,
      accentSuccess: accentSuccess,
      accentWarning: accentWarning,
      accentError: accentError,
      accentNeutral: accentNeutral,
      accentBlack: accentBlack,
      textPrimary: textPrimary,
      textSecondary: textSecondary,
      textTertiary: textTertiary,
      textDisabled: textDisabled,
      textInverse: textInverse,
      textLink: textLink,
      textOnAccent: textOnAccent,
      textOnDark: textOnDark,
      backgroundApp: backgroundApp,
      backgroundSurface: backgroundSurface,
      backgroundSurfaceSubtle: backgroundSurfaceSubtle,
      backgroundSurfaceStrong: backgroundSurfaceStrong,
      backgroundOverlay: backgroundOverlay,
      backgroundOverlayLight: backgroundOverlayLight,
      backgroundOverlayDark: backgroundOverlayDark,
      backgroundDisabled: backgroundDisabled,
      backgroundInverse: backgroundInverse,
      backgroundElevation0: backgroundElevation0,
      backgroundElevation1: backgroundElevation1,
      backgroundElevation2: backgroundElevation2,
      backgroundElevation3: backgroundElevation3,
      backgroundElevation4: backgroundElevation4,
      borderDefault: borderDefault,
      borderOnDark: borderOnDark,
      borderOnAccent: borderOnAccent,
      borderOnSurface: borderOnSurface,
      borderSubtle: borderSubtle,
      borderStrong: borderStrong,
      borderOpacity10: borderOpacity10,
      borderOpacity25: borderOpacity25,
      borderFocus: borderFocus,
      borderDisabled: borderDisabled,
      borderError: borderError,
      borderWarning: borderWarning,
      borderSuccess: borderSuccess,
      borderSelected: borderSelected,
      stateHover: stateHover,
      statePressed: statePressed,
      stateSelected: stateSelected,
      stateFocused: stateFocused,
      stateDisabled: stateDisabled,
      systemText: systemText,
      systemScrollbar: systemScrollbar,
      avatarPalette: avatarPalette,
    );
  }

  /// Creates a dark color scheme.
  factory StreamColorScheme.dark({
    // Brand
    StreamColorSwatch? brand,
    // Accent
    Color? accentPrimary,
    Color? accentSuccess,
    Color? accentWarning,
    Color? accentError,
    Color? accentNeutral,
    Color? accentBlack,
    // Text
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textDisabled,
    Color? textInverse,
    Color? textLink,
    Color? textOnAccent,
    Color? textOnDark,
    // Background
    Color? backgroundApp,
    Color? backgroundSurface,
    Color? backgroundSurfaceSubtle,
    Color? backgroundSurfaceStrong,
    Color? backgroundOverlay,
    Color? backgroundOverlayLight,
    Color? backgroundOverlayDark,
    Color? backgroundDisabled,
    Color? backgroundInverse,
    // Background - Elevation
    Color? backgroundElevation0,
    Color? backgroundElevation1,
    Color? backgroundElevation2,
    Color? backgroundElevation3,
    Color? backgroundElevation4,
    // Border - Core
    Color? borderDefault,
    Color? borderSubtle,
    Color? borderStrong,
    Color? borderOpacity10,
    Color? borderOpacity25,
    Color? borderOnDark,
    Color? borderOnAccent,
    Color? borderOnSurface,
    // Border - Utility
    Color? borderFocus,
    Color? borderDisabled,
    Color? borderError,
    Color? borderWarning,
    Color? borderSuccess,
    Color? borderSelected,
    // State
    Color? stateHover,
    Color? statePressed,
    Color? stateSelected,
    Color? stateFocused,
    Color? stateDisabled,
    // System
    Color? systemText,
    Color? systemScrollbar,
    // Avatar
    List<StreamAvatarColorPair>? avatarPalette,
  }) {
    // Brand
    brand ??= StreamBrandColor.dark();

    // Accent
    accentPrimary ??= brand.shade500;
    accentSuccess ??= dark_tokens.StreamTokens.accentSuccess;
    accentWarning ??= dark_tokens.StreamTokens.accentWarning;
    accentError ??= dark_tokens.StreamTokens.accentError;
    accentNeutral ??= dark_tokens.StreamTokens.accentNeutral;
    accentBlack ??= dark_tokens.StreamTokens.accentBlack;

    // Text
    textPrimary ??= dark_tokens.StreamTokens.textPrimary;
    textSecondary ??= dark_tokens.StreamTokens.textSecondary;
    textTertiary ??= dark_tokens.StreamTokens.textTertiary;
    textDisabled ??= dark_tokens.StreamTokens.textDisabled;
    textInverse ??= dark_tokens.StreamTokens.textInverse;
    textLink ??= accentPrimary;
    textOnAccent ??= dark_tokens.StreamTokens.textOnAccent;
    textOnDark ??= dark_tokens.StreamTokens.textOnDark;

    // Background
    backgroundApp ??= dark_tokens.StreamTokens.backgroundCoreApp;
    backgroundSurface ??= dark_tokens.StreamTokens.backgroundCoreSurface;
    backgroundSurfaceSubtle ??= dark_tokens.StreamTokens.backgroundCoreSurfaceSubtle;
    backgroundSurfaceStrong ??= dark_tokens.StreamTokens.backgroundCoreSurfaceStrong;
    backgroundOverlay ??= dark_tokens.StreamTokens.backgroundCoreOverlay;
    backgroundOverlayLight ??= dark_tokens.StreamTokens.backgroundCoreOverlayLight;
    backgroundOverlayDark ??= dark_tokens.StreamTokens.backgroundCoreOverlayDark;
    backgroundDisabled ??= dark_tokens.StreamTokens.backgroundCoreDisabled;
    backgroundInverse ??= dark_tokens.StreamTokens.backgroundCoreInverse;

    backgroundElevation0 ??= dark_tokens.StreamTokens.backgroundElevationElevation0;
    backgroundElevation1 ??= dark_tokens.StreamTokens.backgroundElevationElevation1;
    backgroundElevation2 ??= dark_tokens.StreamTokens.backgroundElevationElevation2;
    backgroundElevation3 ??= dark_tokens.StreamTokens.backgroundElevationElevation3;
    backgroundElevation4 ??= dark_tokens.StreamTokens.backgroundElevationElevation4;

    // Border - Core
    borderDefault ??= dark_tokens.StreamTokens.borderCoreDefault;
    borderSubtle ??= dark_tokens.StreamTokens.borderCoreSubtle;
    borderStrong ??= dark_tokens.StreamTokens.borderCoreStrong;
    borderOpacity10 ??= dark_tokens.StreamTokens.borderCoreOpacity10;
    borderOpacity25 ??= dark_tokens.StreamTokens.borderCoreOpacity25;
    borderOnDark ??= dark_tokens.StreamTokens.borderCoreOnDark;
    borderOnAccent ??= dark_tokens.StreamTokens.borderCoreOnAccent;
    borderOnSurface ??= dark_tokens.StreamTokens.borderCoreOnSurface;

    // Border - Utility
    borderFocus ??= brand.shade300;
    borderDisabled ??= dark_tokens.StreamTokens.borderUtilityDisabled;
    borderError ??= accentError;
    borderWarning ??= accentWarning;
    borderSuccess ??= accentSuccess;
    borderSelected ??= accentPrimary;

    // State
    stateHover ??= dark_tokens.StreamTokens.backgroundCoreHover;
    statePressed ??= dark_tokens.StreamTokens.backgroundCorePressed;
    stateSelected ??= dark_tokens.StreamTokens.backgroundCoreSelected;
    stateFocused ??= brand.shade100;
    stateDisabled ??= dark_tokens.StreamTokens.backgroundCoreDisabled;

    // System
    systemText ??= dark_tokens.StreamTokens.systemText;
    systemScrollbar ??= dark_tokens.StreamTokens.systemScrollbar;

    // Avatar
    avatarPalette ??= [
      StreamAvatarColorPair(
        backgroundColor: StreamColors.blue.shade800,
        foregroundColor: StreamColors.blue.shade100,
      ),
      StreamAvatarColorPair(
        backgroundColor: StreamColors.cyan.shade800,
        foregroundColor: StreamColors.cyan.shade100,
      ),
      StreamAvatarColorPair(
        backgroundColor: StreamColors.green.shade800,
        foregroundColor: StreamColors.green.shade100,
      ),
      StreamAvatarColorPair(
        backgroundColor: StreamColors.purple.shade800,
        foregroundColor: StreamColors.purple.shade100,
      ),
      StreamAvatarColorPair(
        backgroundColor: StreamColors.yellow.shade800,
        foregroundColor: StreamColors.yellow.shade100,
      ),
    ];

    return .raw(
      brand: brand,
      accentPrimary: accentPrimary,
      accentSuccess: accentSuccess,
      accentWarning: accentWarning,
      accentError: accentError,
      accentNeutral: accentNeutral,
      accentBlack: accentBlack,
      textPrimary: textPrimary,
      textSecondary: textSecondary,
      textTertiary: textTertiary,
      textDisabled: textDisabled,
      textInverse: textInverse,
      textLink: textLink,
      textOnAccent: textOnAccent,
      textOnDark: textOnDark,
      backgroundApp: backgroundApp,
      backgroundSurface: backgroundSurface,
      backgroundSurfaceSubtle: backgroundSurfaceSubtle,
      backgroundSurfaceStrong: backgroundSurfaceStrong,
      backgroundOverlay: backgroundOverlay,
      backgroundOverlayLight: backgroundOverlayLight,
      backgroundOverlayDark: backgroundOverlayDark,
      backgroundDisabled: backgroundDisabled,
      backgroundInverse: backgroundInverse,
      backgroundElevation0: backgroundElevation0,
      backgroundElevation1: backgroundElevation1,
      backgroundElevation2: backgroundElevation2,
      backgroundElevation3: backgroundElevation3,
      backgroundElevation4: backgroundElevation4,
      borderDefault: borderDefault,
      borderStrong: borderStrong,
      borderOpacity10: borderOpacity10,
      borderOpacity25: borderOpacity25,
      borderOnDark: borderOnDark,
      borderOnAccent: borderOnAccent,
      borderOnSurface: borderOnSurface,
      borderSubtle: borderSubtle,
      borderFocus: borderFocus,
      borderDisabled: borderDisabled,
      borderError: borderError,
      borderWarning: borderWarning,
      borderSuccess: borderSuccess,
      borderSelected: borderSelected,
      stateHover: stateHover,
      statePressed: statePressed,
      stateSelected: stateSelected,
      stateFocused: stateFocused,
      stateDisabled: stateDisabled,
      systemText: systemText,
      systemScrollbar: systemScrollbar,
      avatarPalette: avatarPalette,
    );
  }

  const StreamColorScheme.raw({
    required this.brand,
    // Accent
    required this.accentPrimary,
    required this.accentSuccess,
    required this.accentWarning,
    required this.accentError,
    required this.accentNeutral,
    required this.accentBlack,
    // Text
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.textInverse,
    required this.textLink,
    required this.textOnAccent,
    required this.textOnDark,
    // Background
    required this.backgroundApp,
    required this.backgroundSurface,
    required this.backgroundSurfaceSubtle,
    required this.backgroundSurfaceStrong,
    required this.backgroundOverlay,
    required this.backgroundOverlayLight,
    required this.backgroundOverlayDark,
    required this.backgroundDisabled,
    required this.backgroundInverse,
    // Background - Elevation
    required this.backgroundElevation0,
    required this.backgroundElevation1,
    required this.backgroundElevation2,
    required this.backgroundElevation3,
    required this.backgroundElevation4,
    // Border - Core
    required this.borderDefault,
    required this.borderSubtle,
    required this.borderStrong,
    required this.borderOnDark,
    required this.borderOnAccent,
    required this.borderOnSurface,
    required this.borderOpacity10,
    required this.borderOpacity25,
    // Border - Utility
    required this.borderFocus,
    required this.borderDisabled,
    required this.borderError,
    required this.borderWarning,
    required this.borderSuccess,
    required this.borderSelected,
    // State
    required this.stateHover,
    required this.statePressed,
    required this.stateSelected,
    required this.stateFocused,
    required this.stateDisabled,
    // System
    required this.systemText,
    required this.systemScrollbar,
    // Avatar
    required this.avatarPalette,
  });

  // ---- Brand ----

  /// The brand color swatch with shades from 50 to 950.
  final StreamColorSwatch brand;

  // ---- Accent colors ----

  /// The primary accent color.
  final Color accentPrimary;

  /// The success accent color.
  final Color accentSuccess;

  /// The warning accent color.
  final Color accentWarning;

  /// The error accent color.
  final Color accentError;

  /// The neutral accent color.
  final Color accentNeutral;

  /// The black accent color.
  final Color accentBlack;

  // ---- Text colors ----

  /// The primary text color.
  final Color textPrimary;

  /// The secondary text color.
  final Color textSecondary;

  /// The tertiary text color.
  final Color textTertiary;

  /// The disabled text color.
  final Color textDisabled;

  /// The inverse text color.
  final Color textInverse;

  /// The link text color.
  final Color textLink;

  /// The text color on accent backgrounds.
  final Color textOnAccent;

  /// The text color on dark backgrounds.
  final Color textOnDark;

  // ---- Background colors ----

  /// The main app background color.
  final Color backgroundApp;

  /// The surface background color.
  final Color backgroundSurface;

  /// The subtle surface background color.
  final Color backgroundSurfaceSubtle;

  /// The strong surface background color.
  final Color backgroundSurfaceStrong;

  /// The overlay background color.
  final Color backgroundOverlay;

  /// The light overlay background color.
  final Color backgroundOverlayLight;

  /// The dark overlay background color.
  final Color backgroundOverlayDark;

  /// Disabled background for inputs, buttons, or chips.
  final Color backgroundDisabled;

  /// The inverse background color.
  final Color backgroundInverse;

  // ---- Background - Elevation ----

  /// The elevation 0 background color.
  final Color backgroundElevation0;

  /// The elevation 1 background color.
  final Color backgroundElevation1;

  /// The elevation 2 background color.
  final Color backgroundElevation2;

  /// The elevation 3 background color.
  final Color backgroundElevation3;

  /// The elevation 4 background color.
  final Color backgroundElevation4;

  // ---- Border colors - Core ----

  /// Standard surface border
  final Color borderDefault;

  /// The subtle surface border color for separators.
  final Color borderSubtle;

  /// The strong surface border color.
  final Color borderStrong;

  /// The border color on dark backgrounds.
  final Color borderOnDark;

  /// The border color on accent backgrounds.
  final Color borderOnAccent;

  /// The border color on surface backgrounds.
  final Color borderOnSurface;

  /// The 10% opacity border color.
  final Color borderOpacity10;

  /// The 25% opacity border color.
  final Color borderOpacity25;

  // ---- Border colors - Utility ----

  /// The focus ring border color.
  final Color borderFocus;

  /// The disabled state border color.
  final Color borderDisabled;

  /// The error state border color.
  final Color borderError;

  /// The warning state border color.
  final Color borderWarning;

  /// The success state border color.
  final Color borderSuccess;

  /// The selected state border color.
  final Color borderSelected;

  // ---- State colors ----

  /// The hover state overlay color.
  final Color stateHover;

  /// The pressed state overlay color.
  final Color statePressed;

  /// The selected state overlay color.
  final Color stateSelected;

  /// The focused state overlay color.
  final Color stateFocused;

  /// The disabled state color.
  final Color stateDisabled;

  // ---- System colors ----

  /// The system text color.
  final Color systemText;

  /// The system scrollbar color.
  final Color systemScrollbar;

  // ---- Avatar colors ----

  /// The color palette for generating avatar colors based on user identity.
  ///
  /// Used by domain widgets like `UserAvatar` to deterministically
  /// select colors based on user name or ID.
  final List<StreamAvatarColorPair> avatarPalette;

  /// Linearly interpolates between this and another [StreamColorScheme].
  StreamColorScheme lerp(StreamColorScheme? other, double t) {
    return _$StreamColorScheme.lerp(this, other, t)!;
  }
}

/// The brand color swatch for the Stream design system.
///
/// [StreamBrandColor] extends [StreamColorSwatch] and provides the primary
/// brand color palette with shades from 50 to 950. The default brand color
/// is blue, but it can be customized to match your brand identity.
///
/// Note: This class extends [ColorSwatch] and cannot implement [ThemeExtension].
/// Color interpolation is handled via [Color.lerp] on the primary value.
///
/// {@tool snippet}
///
/// Use brand colors from a color scheme:
///
/// ```dart
/// final colorScheme = StreamColorScheme.light();
/// final brandColor = colorScheme.brand; // Uses shade500 by default
/// final lightBrand = colorScheme.brand.shade300;
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamColorScheme], which contains the brand color.
///  * [StreamColorSwatch], the base class for color swatches.
@immutable
class StreamBrandColor extends StreamColorSwatch {
  const StreamBrandColor._(super.primary, super._swatch);

  /// Creates a light theme brand color swatch.
  ///
  /// Defaults to blue with shade500 as the primary color.
  factory StreamBrandColor.light() {
    final primaryColorValue = light_tokens.StreamTokens.brand500.toARGB32();
    return ._(primaryColorValue, <int, Color>{
      50: light_tokens.StreamTokens.brand50,
      100: light_tokens.StreamTokens.brand100,
      150: light_tokens.StreamTokens.brand150,
      200: light_tokens.StreamTokens.brand200,
      300: light_tokens.StreamTokens.brand300,
      400: light_tokens.StreamTokens.brand400,
      500: Color(primaryColorValue),
      600: light_tokens.StreamTokens.brand600,
      700: light_tokens.StreamTokens.brand700,
      800: light_tokens.StreamTokens.brand800,
      900: light_tokens.StreamTokens.brand900,
    });
  }

  /// Creates a dark theme brand color swatch.
  ///
  /// Defaults to blue with shade400 as the primary color. The shade values
  /// are inverted for dark mode, with lighter shades becoming darker and
  /// vice versa.
  factory StreamBrandColor.dark() {
    final primaryColorValue = dark_tokens.StreamTokens.brand500.toARGB32();
    return ._(primaryColorValue, <int, Color>{
      50: dark_tokens.StreamTokens.brand50,
      100: dark_tokens.StreamTokens.brand100,
      150: dark_tokens.StreamTokens.brand150,
      200: dark_tokens.StreamTokens.brand200,
      300: dark_tokens.StreamTokens.brand300,
      400: dark_tokens.StreamTokens.brand400,
      500: Color(primaryColorValue),
      600: dark_tokens.StreamTokens.brand600,
      700: dark_tokens.StreamTokens.brand700,
      800: dark_tokens.StreamTokens.brand800,
      900: dark_tokens.StreamTokens.brand900,
    });
  }
}

/// A background/foreground color pair for avatars.
///
/// Used for deterministic color selection based on user identity.
/// The palette is part of [StreamColorScheme] to support light/dark themes.
@themeGen
@immutable
class StreamAvatarColorPair with _$StreamAvatarColorPair {
  /// Creates an avatar color pair with the given values.
  const StreamAvatarColorPair({
    required this.backgroundColor,
    required this.foregroundColor,
  });

  /// The background color for the avatar.
  final Color backgroundColor;

  /// The foreground color for the avatar initials.
  final Color foregroundColor;

  /// Linearly interpolates between two [StreamAvatarColorPair] instances.
  static StreamAvatarColorPair? lerp(
    StreamAvatarColorPair? a,
    StreamAvatarColorPair? b,
    double t,
  ) => _$StreamAvatarColorPair.lerp(a, b, t);
}
