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
///  * [StreamChromeColor], which provides neutral chrome color shades.
///  * [StreamColors], which defines the primitive color palette.
@immutable
@ThemeGen(constructor: 'raw')
class StreamColorScheme with _$StreamColorScheme {
  /// Creates a light color scheme.
  factory StreamColorScheme.light({
    // Brand
    StreamColorSwatch? brand,
    StreamColorSwatch? chrome,
    // Accent
    Color? accentPrimary,
    Color? accentSuccess,
    Color? accentWarning,
    Color? accentError,
    Color? accentNeutral,
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
    Color? backgroundSurfaceCard,
    Color? backgroundOnAccent,
    Color? backgroundHighlight,
    Color? backgroundScrim,
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
    Color? borderInverse,
    Color? borderOnAccent,
    Color? borderOnSurface,
    Color? borderOpacitySubtle,
    Color? borderOpacityStrong,
    // Border - Utility
    Color? borderFocus,
    Color? borderDisabled,
    Color? borderHover,
    Color? borderPressed,
    Color? borderActive,
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
    chrome ??= StreamChromeColor.light();

    // Accent
    accentPrimary ??= brand.shade500;
    accentSuccess ??= light_tokens.StreamTokens.accentSuccess;
    accentWarning ??= light_tokens.StreamTokens.accentWarning;
    accentError ??= light_tokens.StreamTokens.accentError;
    accentNeutral ??= chrome.shade500;

    // Text
    textPrimary ??= chrome.shade900;
    textSecondary ??= chrome.shade700;
    textTertiary ??= chrome.shade500;
    textDisabled ??= chrome.shade300;
    textInverse ??= chrome[0] ?? StreamColors.white;
    textLink ??= accentPrimary;
    textOnAccent ??= chrome[0] ?? StreamColors.white;

    // Background
    backgroundSurface ??= chrome.shade100;
    backgroundSurfaceSubtle ??= chrome.shade50;
    backgroundSurfaceStrong ??= chrome.shade150;
    backgroundSurfaceCard ??= chrome.shade50;
    backgroundOnAccent ??= chrome[0] ?? StreamColors.white;
    backgroundHighlight ??= light_tokens.StreamTokens.backgroundCoreHighlight;
    backgroundScrim ??= light_tokens.StreamTokens.backgroundCoreScrim;
    backgroundOverlayLight ??= light_tokens.StreamTokens.backgroundCoreOverlayLight;
    backgroundOverlayDark ??= light_tokens.StreamTokens.backgroundCoreOverlayDark;
    backgroundDisabled ??= chrome.shade100;
    backgroundInverse ??= chrome.shade900;

    backgroundElevation0 ??= chrome[0] ?? StreamColors.white;
    backgroundElevation1 ??= chrome[0] ?? StreamColors.white;
    backgroundElevation2 ??= chrome[0] ?? StreamColors.white;
    backgroundElevation3 ??= chrome[0] ?? StreamColors.white;
    backgroundElevation4 ??= chrome[0] ?? StreamColors.white;

    backgroundApp ??= backgroundElevation0;

    // Border - Core
    borderDefault ??= light_tokens.StreamTokens.borderCoreDefault;
    borderSubtle ??= light_tokens.StreamTokens.borderCoreSubtle;
    borderStrong ??= light_tokens.StreamTokens.borderCoreStrong;
    borderInverse ??= chrome[0] ?? StreamColors.white;
    borderOnAccent ??= chrome[0] ?? StreamColors.white;
    borderOnSurface ??= chrome.shade200;
    borderOpacitySubtle ??= light_tokens.StreamTokens.borderCoreOpacitySubtle;
    borderOpacityStrong ??= light_tokens.StreamTokens.borderCoreOpacityStrong;

    // Border - Utility
    borderFocus ??= brand.shade150;
    borderDisabled ??= chrome.shade100;
    borderHover ??= light_tokens.StreamTokens.borderUtilityHover;
    borderPressed ??= light_tokens.StreamTokens.borderUtilityPressed;
    borderActive ??= accentPrimary;
    borderError ??= accentError;
    borderWarning ??= accentWarning;
    borderSuccess ??= accentSuccess;
    borderSelected ??= light_tokens.StreamTokens.borderUtilitySelected;

    // State
    stateHover ??= light_tokens.StreamTokens.backgroundUtilityHover;
    statePressed ??= light_tokens.StreamTokens.backgroundUtilityPressed;
    stateSelected ??= light_tokens.StreamTokens.backgroundUtilitySelected;
    stateFocused ??= brand.shade100;
    stateDisabled ??= light_tokens.StreamTokens.backgroundUtilityDisabled;

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
      chrome: chrome,
      accentPrimary: accentPrimary,
      accentSuccess: accentSuccess,
      accentWarning: accentWarning,
      accentError: accentError,
      accentNeutral: accentNeutral,
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
      backgroundSurfaceCard: backgroundSurfaceCard,
      backgroundOnAccent: backgroundOnAccent,
      backgroundHighlight: backgroundHighlight,
      backgroundScrim: backgroundScrim,
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
      borderInverse: borderInverse,
      borderOnAccent: borderOnAccent,
      borderOnSurface: borderOnSurface,
      borderSubtle: borderSubtle,
      borderStrong: borderStrong,
      borderOpacitySubtle: borderOpacitySubtle,
      borderOpacityStrong: borderOpacityStrong,
      borderFocus: borderFocus,
      borderDisabled: borderDisabled,
      borderHover: borderHover,
      borderPressed: borderPressed,
      borderActive: borderActive,
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
    StreamColorSwatch? chrome,
    // Accent
    Color? accentPrimary,
    Color? accentSuccess,
    Color? accentWarning,
    Color? accentError,
    Color? accentNeutral,
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
    Color? backgroundSurfaceCard,
    Color? backgroundOnAccent,
    Color? backgroundHighlight,
    Color? backgroundScrim,
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
    Color? borderInverse,
    Color? borderOpacitySubtle,
    Color? borderOpacityStrong,
    Color? borderOnAccent,
    Color? borderOnSurface,
    // Border - Utility
    Color? borderFocus,
    Color? borderDisabled,
    Color? borderHover,
    Color? borderPressed,
    Color? borderActive,
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
    chrome ??= StreamChromeColor.dark();

    // Accent
    accentPrimary ??= brand.shade400;
    accentSuccess ??= dark_tokens.StreamTokens.accentSuccess;
    accentWarning ??= dark_tokens.StreamTokens.accentWarning;
    accentError ??= dark_tokens.StreamTokens.accentError;
    accentNeutral ??= chrome.shade500;

    // Text
    textPrimary ??= chrome.shade900;
    textSecondary ??= chrome.shade700;
    textTertiary ??= chrome.shade500;
    textDisabled ??= chrome.shade300;
    textInverse ??= chrome[1000] ?? StreamColors.black;
    textLink ??= brand.shade600;
    textOnAccent ??= chrome[0] ?? StreamColors.white;

    // Background
    backgroundApp ??= chrome[1000] ?? StreamColors.black;
    backgroundSurface ??= chrome.shade100;
    backgroundSurfaceSubtle ??= chrome.shade50;
    backgroundSurfaceStrong ??= chrome.shade150;
    backgroundSurfaceCard ??= chrome.shade100;
    backgroundOnAccent ??= chrome[0] ?? StreamColors.white;
    backgroundHighlight ??= dark_tokens.StreamTokens.backgroundCoreHighlight;
    backgroundScrim ??= dark_tokens.StreamTokens.backgroundCoreScrim;
    backgroundOverlayLight ??= dark_tokens.StreamTokens.backgroundCoreOverlayLight;
    backgroundOverlayDark ??= dark_tokens.StreamTokens.backgroundCoreOverlayDark;
    backgroundDisabled ??= chrome.shade100;
    backgroundInverse ??= chrome.shade900;

    backgroundElevation0 ??= chrome[1000] ?? StreamColors.black;
    backgroundElevation1 ??= chrome.shade50;
    backgroundElevation2 ??= chrome.shade100;
    backgroundElevation3 ??= chrome.shade200;
    backgroundElevation4 ??= chrome.shade300;

    // Border - Core
    borderDefault ??= dark_tokens.StreamTokens.borderCoreDefault;
    borderSubtle ??= dark_tokens.StreamTokens.borderCoreSubtle;
    borderStrong ??= dark_tokens.StreamTokens.borderCoreStrong;
    borderInverse ??= dark_tokens.StreamTokens.borderCoreInverse;
    borderOpacitySubtle ??= dark_tokens.StreamTokens.borderCoreOpacitySubtle;
    borderOpacityStrong ??= dark_tokens.StreamTokens.borderCoreOpacityStrong;
    borderOnAccent ??= chrome[0] ?? StreamColors.white;
    borderOnSurface ??= chrome.shade200;

    // Border - Utility
    borderFocus ??= brand.shade150;
    borderDisabled ??= chrome.shade100;
    borderHover ??= dark_tokens.StreamTokens.borderUtilityHover;
    borderPressed ??= dark_tokens.StreamTokens.borderUtilityPressed;
    borderActive ??= accentPrimary;
    borderError ??= accentError;
    borderWarning ??= accentWarning;
    borderSuccess ??= accentSuccess;
    borderSelected ??= dark_tokens.StreamTokens.borderUtilitySelected;

    // State
    stateHover ??= dark_tokens.StreamTokens.backgroundUtilityHover;
    statePressed ??= dark_tokens.StreamTokens.backgroundUtilityPressed;
    stateSelected ??= dark_tokens.StreamTokens.backgroundUtilitySelected;
    stateFocused ??= brand.shade100;
    stateDisabled ??= dark_tokens.StreamTokens.backgroundUtilityDisabled;

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
      chrome: chrome,
      accentPrimary: accentPrimary,
      accentSuccess: accentSuccess,
      accentWarning: accentWarning,
      accentError: accentError,
      accentNeutral: accentNeutral,
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
      backgroundSurfaceCard: backgroundSurfaceCard,
      backgroundOnAccent: backgroundOnAccent,
      backgroundHighlight: backgroundHighlight,
      backgroundScrim: backgroundScrim,
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
      borderInverse: borderInverse,
      borderStrong: borderStrong,
      borderOpacitySubtle: borderOpacitySubtle,
      borderOpacityStrong: borderOpacityStrong,
      borderOnAccent: borderOnAccent,
      borderOnSurface: borderOnSurface,
      borderSubtle: borderSubtle,
      borderFocus: borderFocus,
      borderDisabled: borderDisabled,
      borderHover: borderHover,
      borderPressed: borderPressed,
      borderActive: borderActive,
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
    required this.chrome,
    // Accent
    required this.accentPrimary,
    required this.accentSuccess,
    required this.accentWarning,
    required this.accentError,
    required this.accentNeutral,
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
    required this.backgroundSurfaceCard,
    required this.backgroundOnAccent,
    required this.backgroundHighlight,
    required this.backgroundScrim,
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
    required this.borderInverse,
    required this.borderOnAccent,
    required this.borderOnSurface,
    required this.borderOpacitySubtle,
    required this.borderOpacityStrong,
    // Border - Utility
    required this.borderFocus,
    required this.borderDisabled,
    required this.borderHover,
    required this.borderPressed,
    required this.borderActive,
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

  /// The chrome (neutral) color swatch with shades from 0 to 1000.
  final StreamColorSwatch chrome;

  // ---- Accent colors ----

  /// The primary accent color.
  final Color accentPrimary;

  /// The success accent color.
  final Color accentSuccess;

  /// The warning accent color.
  final Color accentWarning;

  /// The error accent color.
  final Color accentError;

  /// Neutral accent for low-priority badges.
  final Color accentNeutral;

  // ---- Text colors ----

  /// Main text color.
  final Color textPrimary;

  /// Secondary metadata text.
  final Color textSecondary;

  /// Lowest priority text.
  final Color textTertiary;

  /// Disabled text.
  final Color textDisabled;

  /// Text on dark or accent backgrounds.
  final Color textInverse;

  /// The link text color.
  final Color textLink;

  /// Text on dark or accent backgrounds.
  final Color textOnAccent;

  // ---- Background colors ----

  /// Global application background.
  final Color backgroundApp;

  /// Standard section background.
  final Color backgroundSurface;

  /// Very light section background.
  final Color backgroundSurfaceSubtle;

  /// Stronger section background.
  final Color backgroundSurfaceStrong;

  /// Card surface background (slightly elevated above subtle).
  final Color backgroundSurfaceCard;

  /// Surface that must remain white across themes (e.g., media controls over video).
  final Color backgroundOnAccent;

  /// Highlight background (e.g., quoted message, search hit).
  final Color backgroundHighlight;

  /// Dimmed overlay for modals.
  final Color backgroundScrim;

  /// The light overlay background color.
  final Color backgroundOverlayLight;

  /// The dark overlay background color.
  final Color backgroundOverlayDark;

  /// Disabled backgrounds for inputs, buttons, or chips.
  final Color backgroundDisabled;

  /// Inverse background used for elevated, transient, or high-attention UI surfaces that sit on top of the default app background.
  final Color backgroundInverse;

  // ---- Background - Elevation ----

  /// Flat surfaces.
  final Color backgroundElevation0;

  /// Slightly elevated surfaces.
  final Color backgroundElevation1;

  /// Card-like elements.
  final Color backgroundElevation2;

  /// Popovers.
  final Color backgroundElevation3;

  /// Dialogs, modals.
  final Color backgroundElevation4;

  // ---- Border colors - Core ----

  /// Standard surface border.
  final Color borderDefault;

  /// Very light separators.
  final Color borderSubtle;

  /// Stronger surface border.
  final Color borderStrong;

  /// Used on dark backgrounds.
  final Color borderInverse;

  /// Borders on accent backgrounds.
  final Color borderOnAccent;

  /// The border color on surface backgrounds.
  final Color borderOnSurface;

  /// Image frame border treatment (subtle opacity).
  final Color borderOpacitySubtle;

  /// Image frame border treatment (strong opacity).
  final Color borderOpacityStrong;

  // ---- Border colors - Utility ----

  /// Focus ring or focus border.
  final Color borderFocus;

  /// Optional disabled border for inputs, buttons, or chips.
  final Color borderDisabled;

  /// Hover feedback border overlay.
  final Color borderHover;

  /// Pressed feedback border overlay.
  final Color borderPressed;

  /// Active/selected border (same value as borderSelected).
  final Color borderActive;

  /// The error state border color.
  final Color borderError;

  /// The warning state border color.
  final Color borderWarning;

  /// The success state border color.
  final Color borderSuccess;

  /// The selected state border color.
  final Color borderSelected;

  // ---- State colors ----

  /// Hover feedback overlay.
  final Color stateHover;

  /// Pressed feedback overlay.
  final Color statePressed;

  /// Selected overlay.
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
///  * [StreamChromeColor], the neutral chrome swatch.
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

/// The chrome (neutral) color swatch for the Stream design system.
///
/// [StreamChromeColor] extends [StreamColorSwatch] and provides the neutral
/// chrome color palette with shades from 0 (white) to 1000 (black). Chrome
/// colors are used for backgrounds, text, borders, and other UI elements that
/// adapt to light/dark themes through the neutral gray scale.
///
/// See also:
///  * [StreamColorScheme], which contains the chrome color.
///  * [StreamColorSwatch], the base class for color swatches.
@immutable
class StreamChromeColor extends StreamColorSwatch {
  const StreamChromeColor._(super.primary, super._swatch);

  /// Creates a light theme chrome color swatch.
  factory StreamChromeColor.light() {
    final primaryColorValue = light_tokens.StreamTokens.chrome500.toARGB32();
    return ._(
      primaryColorValue,
      <int, Color>{
        0: light_tokens.StreamTokens.chrome0,
        50: light_tokens.StreamTokens.chrome50,
        100: light_tokens.StreamTokens.chrome100,
        150: light_tokens.StreamTokens.chrome150,
        200: light_tokens.StreamTokens.chrome200,
        300: light_tokens.StreamTokens.chrome300,
        400: light_tokens.StreamTokens.chrome400,
        500: Color(primaryColorValue),
        600: light_tokens.StreamTokens.chrome600,
        700: light_tokens.StreamTokens.chrome700,
        800: light_tokens.StreamTokens.chrome800,
        900: light_tokens.StreamTokens.chrome900,
        1000: light_tokens.StreamTokens.chrome1000,
      },
    );
  }

  /// Creates a dark theme chrome color swatch.
  factory StreamChromeColor.dark() {
    final primaryColorValue = dark_tokens.StreamTokens.chrome500.toARGB32();
    return ._(
      primaryColorValue,
      <int, Color>{
        0: dark_tokens.StreamTokens.chrome0,
        50: dark_tokens.StreamTokens.chrome50,
        100: dark_tokens.StreamTokens.chrome100,
        150: dark_tokens.StreamTokens.chrome150,
        200: dark_tokens.StreamTokens.chrome200,
        300: dark_tokens.StreamTokens.chrome300,
        400: dark_tokens.StreamTokens.chrome400,
        500: Color(primaryColorValue),
        600: dark_tokens.StreamTokens.chrome600,
        700: dark_tokens.StreamTokens.chrome700,
        800: dark_tokens.StreamTokens.chrome800,
        900: dark_tokens.StreamTokens.chrome900,
        1000: dark_tokens.StreamTokens.chrome1000,
      },
    );
  }

  /// The shade-0 color (always white – used on dark/accent surfaces).
  Color get shade0 => this[0]!;

  /// The shade-1000 color (always black – used as the deepest neutral).
  Color get shade1000 => this[1000]!;
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
