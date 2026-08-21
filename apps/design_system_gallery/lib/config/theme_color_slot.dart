import 'package:flutter/material.dart';
import 'package:stream_core_flutter/core.dart';

/// A single, plain [Color]-valued parameter of [StreamColorScheme].
///
/// Every value here has a matching named parameter on both
/// [StreamColorScheme.light] and [StreamColorScheme.dark] with the exact same
/// [parameterName]. This enum exists so the theme studio panel, the export
/// page, and the code generator can all iterate the same list instead of
/// hand-writing it four times over — which is how the studio silently lost
/// track of [textOnInverse], [borderOnInverse] and [borderDisabledOnSurface]
/// in the first place.
///
/// `brand` and `chrome` are intentionally excluded: they are
/// [StreamColorSwatch]-valued, not [Color]-valued, so they have a different
/// write path (see [ThemeSeedSlot]). `avatarPalette` is excluded too, since
/// it's a `List<StreamAvatarColorPair>`, not a color.
///
/// The order of values matches the parameter order of
/// [StreamColorScheme.light] so generated code and studio sections read like
/// the SDK API.
enum ThemeColorSlot {
  // Accent
  accentPrimary('accentPrimary', _readAccentPrimary),
  accentSuccess('accentSuccess', _readAccentSuccess),
  accentWarning('accentWarning', _readAccentWarning),
  accentError('accentError', _readAccentError),
  accentNeutral('accentNeutral', _readAccentNeutral),

  // Text
  textPrimary('textPrimary', _readTextPrimary),
  textSecondary('textSecondary', _readTextSecondary),
  textTertiary('textTertiary', _readTextTertiary),
  textDisabled('textDisabled', _readTextDisabled),
  textLink('textLink', _readTextLink),
  textOnAccent('textOnAccent', _readTextOnAccent),
  textOnInverse('textOnInverse', _readTextOnInverse),

  // Background
  backgroundApp('backgroundApp', _readBackgroundApp),
  backgroundSurface('backgroundSurface', _readBackgroundSurface),
  backgroundSurfaceSubtle('backgroundSurfaceSubtle', _readBackgroundSurfaceSubtle),
  backgroundSurfaceStrong('backgroundSurfaceStrong', _readBackgroundSurfaceStrong),
  backgroundSurfaceCard('backgroundSurfaceCard', _readBackgroundSurfaceCard),
  backgroundOnAccent('backgroundOnAccent', _readBackgroundOnAccent),
  backgroundHighlight('backgroundHighlight', _readBackgroundHighlight),
  backgroundScrim('backgroundScrim', _readBackgroundScrim),
  backgroundOverlayLight('backgroundOverlayLight', _readBackgroundOverlayLight),
  backgroundOverlayDark('backgroundOverlayDark', _readBackgroundOverlayDark),
  backgroundDisabled('backgroundDisabled', _readBackgroundDisabled),
  backgroundInverse('backgroundInverse', _readBackgroundInverse),

  // Background - Elevation
  backgroundElevation0('backgroundElevation0', _readBackgroundElevation0),
  backgroundElevation1('backgroundElevation1', _readBackgroundElevation1),
  backgroundElevation2('backgroundElevation2', _readBackgroundElevation2),
  backgroundElevation3('backgroundElevation3', _readBackgroundElevation3),

  // Border - Core
  borderDefault('borderDefault', _readBorderDefault),
  borderSubtle('borderSubtle', _readBorderSubtle),
  borderStrong('borderStrong', _readBorderStrong),
  borderOnAccent('borderOnAccent', _readBorderOnAccent),
  borderOnInverse('borderOnInverse', _readBorderOnInverse),
  borderOnSurface('borderOnSurface', _readBorderOnSurface),
  borderOpacitySubtle('borderOpacitySubtle', _readBorderOpacitySubtle),
  borderOpacityStrong('borderOpacityStrong', _readBorderOpacityStrong),

  // Border - Utility
  borderFocus('borderFocus', _readBorderFocus),
  borderDisabled('borderDisabled', _readBorderDisabled),
  borderDisabledOnSurface('borderDisabledOnSurface', _readBorderDisabledOnSurface),
  borderHover('borderHover', _readBorderHover),
  borderPressed('borderPressed', _readBorderPressed),
  borderActive('borderActive', _readBorderActive),
  borderError('borderError', _readBorderError),
  borderWarning('borderWarning', _readBorderWarning),
  borderSuccess('borderSuccess', _readBorderSuccess),
  borderSelected('borderSelected', _readBorderSelected),

  // State
  backgroundHover('backgroundHover', _readBackgroundHover),
  backgroundPressed('backgroundPressed', _readBackgroundPressed),
  backgroundSelected('backgroundSelected', _readBackgroundSelected),

  // System
  systemText('systemText', _readSystemText),
  systemScrollbar('systemScrollbar', _readSystemScrollbar);

  const ThemeColorSlot(this.parameterName, this.read);

  /// The exact named-parameter name on [StreamColorScheme.light]/`.dark`.
  final String parameterName;

  /// Reads this slot's resolved value off a built [StreamColorScheme].
  final Color Function(StreamColorScheme scheme) read;
}

// Enum-constant arguments must be constant expressions, which rules out
// closures — so each reader is a top-level function tear-off (tear-offs of
// top-level functions are compile-time constants) instead of an inline
// `(s) => s.foo` lambda.
Color _readAccentPrimary(StreamColorScheme s) => s.accentPrimary;
Color _readAccentSuccess(StreamColorScheme s) => s.accentSuccess;
Color _readAccentWarning(StreamColorScheme s) => s.accentWarning;
Color _readAccentError(StreamColorScheme s) => s.accentError;
Color _readAccentNeutral(StreamColorScheme s) => s.accentNeutral;

Color _readTextPrimary(StreamColorScheme s) => s.textPrimary;
Color _readTextSecondary(StreamColorScheme s) => s.textSecondary;
Color _readTextTertiary(StreamColorScheme s) => s.textTertiary;
Color _readTextDisabled(StreamColorScheme s) => s.textDisabled;
Color _readTextLink(StreamColorScheme s) => s.textLink;
Color _readTextOnAccent(StreamColorScheme s) => s.textOnAccent;
Color _readTextOnInverse(StreamColorScheme s) => s.textOnInverse;

Color _readBackgroundApp(StreamColorScheme s) => s.backgroundApp;
Color _readBackgroundSurface(StreamColorScheme s) => s.backgroundSurface;
Color _readBackgroundSurfaceSubtle(StreamColorScheme s) => s.backgroundSurfaceSubtle;
Color _readBackgroundSurfaceStrong(StreamColorScheme s) => s.backgroundSurfaceStrong;
Color _readBackgroundSurfaceCard(StreamColorScheme s) => s.backgroundSurfaceCard;
Color _readBackgroundOnAccent(StreamColorScheme s) => s.backgroundOnAccent;
Color _readBackgroundHighlight(StreamColorScheme s) => s.backgroundHighlight;
Color _readBackgroundScrim(StreamColorScheme s) => s.backgroundScrim;
Color _readBackgroundOverlayLight(StreamColorScheme s) => s.backgroundOverlayLight;
Color _readBackgroundOverlayDark(StreamColorScheme s) => s.backgroundOverlayDark;
Color _readBackgroundDisabled(StreamColorScheme s) => s.backgroundDisabled;
Color _readBackgroundInverse(StreamColorScheme s) => s.backgroundInverse;

Color _readBackgroundElevation0(StreamColorScheme s) => s.backgroundElevation0;
Color _readBackgroundElevation1(StreamColorScheme s) => s.backgroundElevation1;
Color _readBackgroundElevation2(StreamColorScheme s) => s.backgroundElevation2;
Color _readBackgroundElevation3(StreamColorScheme s) => s.backgroundElevation3;

Color _readBorderDefault(StreamColorScheme s) => s.borderDefault;
Color _readBorderSubtle(StreamColorScheme s) => s.borderSubtle;
Color _readBorderStrong(StreamColorScheme s) => s.borderStrong;
Color _readBorderOnAccent(StreamColorScheme s) => s.borderOnAccent;
Color _readBorderOnInverse(StreamColorScheme s) => s.borderOnInverse;
Color _readBorderOnSurface(StreamColorScheme s) => s.borderOnSurface;
Color _readBorderOpacitySubtle(StreamColorScheme s) => s.borderOpacitySubtle;
Color _readBorderOpacityStrong(StreamColorScheme s) => s.borderOpacityStrong;

Color _readBorderFocus(StreamColorScheme s) => s.borderFocus;
Color _readBorderDisabled(StreamColorScheme s) => s.borderDisabled;
Color _readBorderDisabledOnSurface(StreamColorScheme s) => s.borderDisabledOnSurface;
Color _readBorderHover(StreamColorScheme s) => s.borderHover;
Color _readBorderPressed(StreamColorScheme s) => s.borderPressed;
Color _readBorderActive(StreamColorScheme s) => s.borderActive;
Color _readBorderError(StreamColorScheme s) => s.borderError;
Color _readBorderWarning(StreamColorScheme s) => s.borderWarning;
Color _readBorderSuccess(StreamColorScheme s) => s.borderSuccess;
Color _readBorderSelected(StreamColorScheme s) => s.borderSelected;

Color _readBackgroundHover(StreamColorScheme s) => s.backgroundHover;
Color _readBackgroundPressed(StreamColorScheme s) => s.backgroundPressed;
Color _readBackgroundSelected(StreamColorScheme s) => s.backgroundSelected;

Color _readSystemText(StreamColorScheme s) => s.systemText;
Color _readSystemScrollbar(StreamColorScheme s) => s.systemScrollbar;

/// The two [StreamColorSwatch]-valued seed parameters of [StreamColorScheme].
///
/// Unlike [ThemeColorSlot], a seed is written by wrapping a plain [Color] in
/// [StreamColorSwatch.fromColor] and is exported the same way — see
/// `theme_code_generator.dart`.
enum ThemeSeedSlot {
  brand('brand'),
  chrome('chrome');

  const ThemeSeedSlot(this.parameterName);

  /// The exact named-parameter name on [StreamColorScheme.light]/`.dark`.
  final String parameterName;
}
