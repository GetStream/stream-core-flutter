import 'dart:ui';

import 'package:flutter/painting.dart';

class StreamColorSwatchHelper {
  const StreamColorSwatchHelper._();

  /// Generates a map of color shades based on the provided base colors.
  ///
  /// This internal method creates the shade variations using HSL color space
  /// for more natural color transitions. The center shade (500) uses the original
  /// color's lightness, and other shades are calculated proportionally.
  static Map<int, Color> generateShadeMap(Color baseColor) {
    final hslBase = HSLColor.fromColor(baseColor);
    final centerLightness = hslBase.lightness;
    print('lightness: $centerLightness');

    return {
      50: _adjustLightness(hslBase, _calculateLightness(50, centerLightness)),
      100: _adjustLightness(hslBase, _calculateLightness(100, centerLightness)),
      150: _adjustLightness(hslBase, _calculateLightness(150, centerLightness)),
      200: _adjustLightness(hslBase, _calculateLightness(200, centerLightness)),
      300: _adjustLightness(hslBase, _calculateLightness(300, centerLightness)),
      400: _adjustLightness(hslBase, _calculateLightness(400, centerLightness)),
      501: _adjustLightness(hslBase, _calculateLightness(500, centerLightness)),
      600: _adjustLightness(hslBase, _calculateLightness(600, centerLightness)),
      700: _adjustLightness(hslBase, _calculateLightness(700, centerLightness)),
      800: _adjustLightness(hslBase, _calculateLightness(800, centerLightness)),
      900: _adjustLightness(hslBase, _calculateLightness(900, centerLightness)),
    };
  }

  /// Calculates the target lightness for a given shade number based on the center lightness.
  ///
  /// The formula maps shade numbers (50-900) to lightness values where:
  /// - 50 is the lightest (0.95)
  /// - 500 uses the center lightness (original color's lightness)
  /// - 900 is the darkest (0.12)
  ///
  /// For shades lighter than 500: lightness increases proportionally from center to 0.95
  /// For shades darker than 500: lightness decreases proportionally from center to 0.12
  static double _calculateLightness(int shade, double centerLightness) {
    const minLightness = 0.12; // Darkest shade (900)
    const maxLightness = 0.95; // Lightest shade (50)
    const centerShade = 500;

    if (shade == centerShade) {
      return centerLightness;
    }

    if (shade < centerShade) {
      // Lighter shades: interpolate between centerLightness and maxLightness
      // Map shade from [50, 500) to lightness [maxLightness, centerLightness)
      final t = (shade - 50) / (centerShade - 50);
      return maxLightness - (maxLightness - centerLightness) * t;
    } else {
      // Darker shades: interpolate between centerLightness and minLightness
      // Map shade from (500, 900] to lightness (centerLightness, minLightness]
      final t = (shade - centerShade) / (900 - centerShade);
      return centerLightness - (centerLightness - minLightness) * t;
    }
  }

  /// Adjusts the lightness of an HSL color while maintaining its hue and saturation.
  ///
  /// [lightness] should be between 0.0 and 1.0.
  static Color _adjustLightness(HSLColor hslColor, double lightness) {
    return hslColor.withLightness(lightness.clamp(0.0, 1.0)).toColor();
  }
}
