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
    // Background
    Color? backgroundApp,
    Color? backgroundSurface,
    Color? backgroundSurfaceSubtle,
    Color? backgroundSurfaceStrong,
    Color? backgroundOverlay,
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
    Color? borderSurface,
    Color? borderSurfaceSubtle,
    Color? borderSurfaceStrong,
    Color? borderOnDark,
    Color? borderOnAccent,
    Color? borderSubtle,
    Color? borderImage,
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
    accentSuccess ??= StreamColors.green.shade500;
    accentWarning ??= StreamColors.yellow.shade500;
    accentError ??= StreamColors.red.shade500;
    accentNeutral ??= StreamColors.slate.shade500;
    accentBlack ??= light_tokens.StreamTokens.accentBlack;

    // Text
    textPrimary ??= StreamColors.slate.shade900;
    textSecondary ??= StreamColors.slate.shade700;
    textTertiary ??= StreamColors.slate.shade600;
    textDisabled ??= StreamColors.slate.shade400;
    textInverse ??= StreamColors.white;
    textLink ??= accentPrimary;
    textOnAccent ??= StreamColors.white;

    // Background
    backgroundApp ??= StreamColors.white;
    backgroundSurface ??= StreamColors.slate.shade50;
    backgroundSurfaceSubtle ??= StreamColors.slate.shade100;
    backgroundSurfaceStrong ??= StreamColors.slate.shade200;
    backgroundOverlay ??= StreamColors.black10;
    backgroundDisabled ??= StreamColors.slate.shade100;
    backgroundInverse ??= light_tokens.StreamTokens.badgeBgInverse; // TODO move to backgroundCoreInverse

    backgroundElevation0 ??= light_tokens.StreamTokens.backgroundElevationElevation0;
    backgroundElevation1 ??= light_tokens.StreamTokens.backgroundElevationElevation1;
    backgroundElevation2 ??= light_tokens.StreamTokens.backgroundElevationElevation2;
    backgroundElevation3 ??= light_tokens.StreamTokens.backgroundElevationElevation3;
    backgroundElevation4 ??= light_tokens.StreamTokens.backgroundElevationElevation4;

    // Border - Core
    borderDefault ??= light_tokens.StreamTokens.borderCoreDefault;
    borderSurface ??= StreamColors.slate.shade400;
    borderSurfaceSubtle ??= StreamColors.slate.shade200;
    borderSurfaceStrong ??= StreamColors.slate.shade600;
    borderOnDark ??= StreamColors.white;
    borderOnAccent ??= StreamColors.white;
    borderSubtle ??= StreamColors.slate.shade100;
    borderImage ??= StreamColors.black10;

    // Border - Utility
    borderFocus ??= brand.shade300;
    borderDisabled ??= StreamColors.slate.shade100;
    borderError ??= accentError;
    borderWarning ??= accentWarning;
    borderSuccess ??= accentSuccess;
    borderSelected ??= accentPrimary;

    // State
    stateHover ??= StreamColors.black5;
    statePressed ??= StreamColors.black10;
    stateSelected ??= StreamColors.black10;
    stateFocused ??= brand.shade100;
    stateDisabled ??= StreamColors.slate.shade200;

    // System
    systemText ??= StreamColors.black;
    systemScrollbar ??= StreamColors.black50;

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
      backgroundApp: backgroundApp,
      backgroundSurface: backgroundSurface,
      backgroundSurfaceSubtle: backgroundSurfaceSubtle,
      backgroundSurfaceStrong: backgroundSurfaceStrong,
      backgroundOverlay: backgroundOverlay,
      backgroundDisabled: backgroundDisabled,
      backgroundInverse: backgroundInverse,
      backgroundElevation0: backgroundElevation0,
      backgroundElevation1: backgroundElevation1,
      backgroundElevation2: backgroundElevation2,
      backgroundElevation3: backgroundElevation3,
      backgroundElevation4: backgroundElevation4,
      borderDefault: borderDefault,
      borderSurface: borderSurface,
      borderSurfaceSubtle: borderSurfaceSubtle,
      borderSurfaceStrong: borderSurfaceStrong,
      borderOnDark: borderOnDark,
      borderOnAccent: borderOnAccent,
      borderSubtle: borderSubtle,
      borderImage: borderImage,
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
    // Background
    Color? backgroundApp,
    Color? backgroundSurface,
    Color? backgroundSurfaceSubtle,
    Color? backgroundSurfaceStrong,
    Color? backgroundOverlay,
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
    Color? borderSurface,
    Color? borderSurfaceSubtle,
    Color? borderSurfaceStrong,
    Color? borderOnDark,
    Color? borderOnAccent,
    Color? borderSubtle,
    Color? borderImage,
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
    accentSuccess ??= StreamColors.green.shade400;
    accentWarning ??= StreamColors.yellow.shade400;
    accentError ??= StreamColors.red.shade400;
    accentNeutral ??= StreamColors.neutral.shade500;
    accentBlack ??= dark_tokens.StreamTokens.accentBlack;

    // Text
    textPrimary ??= StreamColors.neutral.shade50;
    textSecondary ??= StreamColors.neutral.shade300;
    textTertiary ??= StreamColors.neutral.shade400;
    textDisabled ??= StreamColors.neutral.shade600;
    textInverse ??= StreamColors.black;
    textLink ??= accentPrimary;
    textOnAccent ??= StreamColors.white;

    // Background
    backgroundApp ??= StreamColors.black;
    backgroundSurface ??= StreamColors.neutral.shade900;
    backgroundSurfaceSubtle ??= StreamColors.neutral.shade800;
    backgroundSurfaceStrong ??= StreamColors.neutral.shade700;
    backgroundOverlay ??= StreamColors.black50;
    backgroundDisabled ??= StreamColors.neutral.shade900;
    backgroundInverse ??= dark_tokens.StreamTokens.badgeBgInverse; // TODO move to backgroundCoreInverse

    backgroundElevation0 ??= dark_tokens.StreamTokens.backgroundElevationElevation0;
    backgroundElevation1 ??= dark_tokens.StreamTokens.backgroundElevationElevation1;
    backgroundElevation2 ??= dark_tokens.StreamTokens.backgroundElevationElevation2;
    backgroundElevation3 ??= dark_tokens.StreamTokens.backgroundElevationElevation3;
    backgroundElevation4 ??= dark_tokens.StreamTokens.backgroundElevationElevation4;

    // Border - Core
    borderDefault ??= dark_tokens.StreamTokens.borderCoreDefault;
    borderSurface ??= StreamColors.neutral.shade500;
    borderSurfaceSubtle ??= StreamColors.neutral.shade700;
    borderSurfaceStrong ??= StreamColors.neutral.shade400;
    borderOnDark ??= StreamColors.white;
    borderOnAccent ??= StreamColors.white;
    borderSubtle ??= StreamColors.neutral.shade800;
    borderImage ??= StreamColors.white20;

    // Border - Utility
    borderFocus ??= brand.shade300;
    borderDisabled ??= StreamColors.neutral.shade800;
    borderError ??= accentError;
    borderWarning ??= accentWarning;
    borderSuccess ??= accentSuccess;
    borderSelected ??= StreamColors.white;

    // State
    stateHover ??= StreamColors.black5;
    statePressed ??= StreamColors.black10;
    stateSelected ??= StreamColors.black10;
    stateFocused ??= brand.shade100;
    stateDisabled ??= StreamColors.neutral.shade800;

    // System
    systemText ??= StreamColors.white;
    systemScrollbar ??= StreamColors.white50;

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
      backgroundApp: backgroundApp,
      backgroundSurface: backgroundSurface,
      backgroundSurfaceSubtle: backgroundSurfaceSubtle,
      backgroundSurfaceStrong: backgroundSurfaceStrong,
      backgroundOverlay: backgroundOverlay,
      backgroundDisabled: backgroundDisabled,
      backgroundInverse: backgroundInverse,
      backgroundElevation0: backgroundElevation0,
      backgroundElevation1: backgroundElevation1,
      backgroundElevation2: backgroundElevation2,
      backgroundElevation3: backgroundElevation3,
      backgroundElevation4: backgroundElevation4,
      borderDefault: borderDefault,
      borderSurface: borderSurface,
      borderSurfaceSubtle: borderSurfaceSubtle,
      borderSurfaceStrong: borderSurfaceStrong,
      borderOnDark: borderOnDark,
      borderOnAccent: borderOnAccent,
      borderSubtle: borderSubtle,
      borderImage: borderImage,
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
    // Background
    required this.backgroundApp,
    required this.backgroundSurface,
    required this.backgroundSurfaceSubtle,
    required this.backgroundSurfaceStrong,
    required this.backgroundOverlay,
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
    required this.borderSurface,
    required this.borderSurfaceSubtle,
    required this.borderSurfaceStrong,
    required this.borderOnDark,
    required this.borderOnAccent,
    required this.borderSubtle,
    required this.borderImage,
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

  /// The standard surface border color.
  final Color borderSurface;

  /// The subtle surface border color for separators.
  final Color borderSurfaceSubtle;

  /// The strong surface border color.
  final Color borderSurfaceStrong;

  /// The border color on dark backgrounds.
  final Color borderOnDark;

  /// The border color on accent backgrounds.
  final Color borderOnAccent;

  /// The subtle border color for light outlines.
  final Color borderSubtle;

  /// The image frame border color.
  final Color borderImage;

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
    return ._(
      primaryColorValue,
      <int, Color>{
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
      },
    );
  }

  /// Creates a dark theme brand color swatch.
  ///
  /// Defaults to blue with shade400 as the primary color. The shade values
  /// are inverted for dark mode, with lighter shades becoming darker and
  /// vice versa.
  factory StreamBrandColor.dark() {
    final primaryColorValue = dark_tokens.StreamTokens.brand500.toARGB32();
    return ._(
      primaryColorValue,
      <int, Color>{
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
      },
    );
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
