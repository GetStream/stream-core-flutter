import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

class StreamColorSwatchHelper {
  const StreamColorSwatchHelper._();

  /// Generates a map of color shades based on the provided base colors.
  ///
  /// This internal method creates the shade variations using HSL color space
  /// for more natural color transitions. The center shade (500) uses the original
  /// color's lightness, and other shades are calculated proportionally.
  ///
  /// When [brightness] is [Brightness.dark], the lightness values are inverted
  /// so that lower shade numbers (e.g., 50) are darker and higher shade numbers
  /// (e.g., 900) are lighter.
  static Map<int, Color> generateShadeMap(
    Color baseColor, {
    Brightness brightness = Brightness.light,
  }) {
    final hslBase = HSLColor.fromColor(baseColor);
    final centerLightness = hslBase.lightness;

    final shades = [50, 100, 150, 200, 300, 400, 500, 600, 700, 800, 900];

    return {
      for (final shade in shades)
        shade: _adjustLightness(
          hslBase,
          _calculateLightness(shade, centerLightness, brightness: brightness),
        ),
    };
  }

  /// Calculates the target lightness for a given shade number based on the center lightness.
  ///
  /// The formula maps shade numbers (50-900) to lightness values where:
  /// - For [Brightness.light]:
  ///   - 50 is the lightest (0.95)
  ///   - 500 uses the center lightness (original color's lightness)
  ///   - 900 is the darkest (0.12)
  /// - For [Brightness.dark]:
  ///   - 50 is the darkest (0.12)
  ///   - 500 uses the center lightness (original color's lightness)
  ///   - 900 is the lightest (0.95)
  ///
  /// For shades lighter than 500: lightness increases proportionally from center to 0.95 (light mode)
  /// For shades darker than 500: lightness decreases proportionally from center to 0.12 (light mode)
  /// In dark mode, these mappings are inverted.
  static double _calculateLightness(
    int shade,
    double centerLightness, {
    Brightness brightness = Brightness.light,
  }) {
    const minLightness = 0.12; // Darkest shade
    const maxLightness = 0.95; // Lightest shade
    const centerShade = 500;

    if (shade == centerShade) {
      return centerLightness;
    }

    final isDark = brightness == Brightness.dark;

    if (shade < centerShade) {
      // For light mode: lighter shades (toward maxLightness)
      // For dark mode: darker shades (toward minLightness)
      final targetLightness = isDark ? minLightness : maxLightness;
      final t = (shade - 50) / (centerShade - 50);
      return targetLightness - (targetLightness - centerLightness) * t;
    } else {
      // For light mode: darker shades (toward minLightness)
      // For dark mode: lighter shades (toward maxLightness)
      final targetLightness = isDark ? maxLightness : minLightness;
      final t = (shade - centerShade) / (900 - centerShade);
      return centerLightness - (centerLightness - targetLightness) * t;
    }
  }

  /// Adjusts the lightness of an HSL color while maintaining its hue and saturation.
  ///
  /// [lightness] should be between 0.0 and 1.0.
  static Color _adjustLightness(HSLColor hslColor, double lightness) {
    return hslColor.withLightness(lightness.clamp(0.0, 1.0)).toColor();
  }
}
