import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

import '../stream_colors.dart';

class StreamColorSwatchHelper {
  const StreamColorSwatchHelper._();

  /// Tone (CIE L*) assigned to each shade in light mode.
  ///
  /// These values were measured from the Figma design tokens in
  /// `theme/primitives/internal/tokens/`. All four default scales (brand and chrome,
  /// light and dark) sit on this single ladder within 3.3 tone, so generating against
  /// it keeps a custom seed visually consistent with the shipped palette.
  ///
  /// Because tone is CIE L*, it maps directly onto WCAG relative luminance. A shade's
  /// contrast against white or black is therefore fixed by its position on this ladder
  /// and does not vary with hue — shade 500 always yields roughly 5.2:1 against white.
  static const _toneLadder = <int, double>{
    50: 97,
    100: 93.5,
    150: 86,
    200: 79,
    300: 69,
    400: 58,
    500: 46,
    600: 38,
    700: 29,
    800: 20.5,
    900: 10,
  };

  /// Chroma multiplier applied to each shade, as a fraction of the seed's own chroma.
  ///
  /// The default scales do not hold chroma constant: it peaks at shade 500 and tapers
  /// toward both ends (the default brand scale runs 7.7 → 76.8 → 27.1). These ratios
  /// are measured from that scale.
  ///
  /// The taper matters most at the dark end. Towards the light end, HCT already clamps
  /// chroma to what is representable in sRGB at a given tone, which does most of the
  /// work for a vivid seed; the explicit taper is what keeps a low-chroma seed — such
  /// as a generated chrome scale — from reading as tinted in its lightest shades.
  static const _chromaEnvelope = <int, double>{
    50: 0.10,
    100: 0.18,
    150: 0.34,
    200: 0.48,
    300: 0.67,
    400: 0.85,
    500: 1,
    600: 0.78,
    700: 0.62,
    800: 0.48,
    900: 0.35,
  };

  /// Maps a shade onto the shade whose ladder position it takes in dark mode.
  ///
  /// The default dark scales are the light scales reversed — `dark[50..900]` equals
  /// `light[900..50]` — so a dark scale ascends the same ladder. One consequence is
  /// that the seed's own tone lands on shade 300 in dark mode rather than 500.
  static const _darkMirror = <int, int>{
    50: 900,
    100: 800,
    150: 700,
    200: 600,
    300: 500,
    400: 400,
    500: 300,
    600: 200,
    700: 150,
    800: 100,
    900: 50,
  };

  /// Generates a map of color shades based on the provided base color.
  ///
  /// Shades are generated in the HCT color space: the seed's hue is held constant
  /// across the whole scale, each shade takes its tone from a fixed ladder measured
  /// from the design tokens, and chroma is scaled by an envelope that peaks at the
  /// seed's own chroma. This makes a shade's lightness — and therefore its contrast
  /// against text — predictable regardless of which hue was seeded.
  ///
  /// Note that the seed is **not** reproduced verbatim at shade 500; it is normalized
  /// onto the ladder's tone. Seeding a very light color such as yellow yields a shade
  /// 500 dark enough to carry white text, which is what makes the accent slots usable
  /// for any seed.
  ///
  /// When [brightness] is [Brightness.dark] the ladder is mirrored, so lower shade
  /// numbers are darker and higher shade numbers are lighter, matching the default
  /// dark scales.
  ///
  /// The [chroma] parameter overrides the seed's chroma, in HCT units. Pass a low
  /// value to derive a near-neutral scale that still carries the seed's hue. The
  /// default value is null, which means the seed's own chroma is used.
  ///
  /// The return value is a map of color shades, indexed by the shade number.
  static Map<int, Color> generateShadeMap(
    Color baseColor, {
    Brightness brightness = Brightness.light,
    double? chroma,
  }) {
    final base = Hct.fromInt(baseColor.toARGB32());
    final baseChroma = chroma ?? base.chroma;
    final isLight = brightness == Brightness.light;

    return {
      0: isLight ? StreamColors.white : StreamColors.black,
      for (final shade in _toneLadder.keys)
        shade: _shade(
          hue: base.hue,
          chroma: baseChroma,
          shade: isLight ? shade : _darkMirror[shade]!,
        ),
      1000: isLight ? StreamColors.black : StreamColors.white,
    };
  }

  /// Builds the color for a single [shade], reading its tone and chroma multiplier
  /// from the ladder and envelope.
  ///
  /// HCT clamps the requested chroma down to what is achievable in sRGB at the target
  /// tone, so the tone is always honored exactly even when the hue cannot sustain that
  /// much chroma.
  static Color _shade({
    required double hue,
    required double chroma,
    required int shade,
  }) {
    final tone = _toneLadder[shade]!;
    final effectiveChroma = chroma * _chromaEnvelope[shade]!;
    return Color(Hct.from(hue, effectiveChroma, tone).toInt());
  }
}
