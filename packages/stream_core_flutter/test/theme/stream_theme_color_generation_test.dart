import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:stream_core_flutter/core.dart';

/// Every shade a generated [StreamColorSwatch] exposes.
const _shades = [0, 50, 100, 150, 200, 300, 400, 500, 600, 700, 800, 900, 1000];

/// The tone (CIE L*) each shade is expected to land on in light mode. Mirrored in dark
/// mode. Kept in sync with `StreamColorSwatchHelper._toneLadder`.
const _expectedTones = {
  50: 97.0,
  100: 93.5,
  150: 86.0,
  200: 79.0,
  300: 69.0,
  400: 58.0,
  500: 46.0,
  600: 38.0,
  700: 29.0,
  800: 20.5,
  900: 10.0,
};

/// Seeds spanning the hue circle, including the two pathological cases for HSL-based
/// generation: yellow (very light at full saturation) and purple (very dark).
const _seeds = {
  'deep orange': Color(0xFFFF5722),
  'blue': Color(0xFF2196F3),
  'green': Color(0xFF4CAF50),
  'purple': Color(0xFF9C27B0),
  'red': Color(0xFFF44336),
  'yellow': Color(0xFFFFEB3B),
};

/// The Stream brand color, which the default token palette is built from.
const _defaultSeed = Color(0xFF005FFF);

double _toneOf(Color color) => Hct.fromInt(color.toARGB32()).tone;

double _hueOf(Color color) => Hct.fromInt(color.toARGB32()).hue;

double _chromaOf(Color color) => Hct.fromInt(color.toARGB32()).chroma;

/// WCAG 2.1 contrast ratio between two opaque colors.
double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final (hi, lo) = la > lb ? (la, lb) : (lb, la);
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  group('StreamColorScheme.fromSeed exact values', () {
    // A full snapshot for the default seed. The remaining seeds are covered by the
    // property tests below and by the golden test, which is a more useful regression
    // net than transcribing every hue's hex values.
    test('generates the expected light scales for the Stream brand seed', () {
      final scheme = StreamColorScheme.fromSeed(brand: _defaultSeed);

      expect(scheme.brand[0], const Color(0xFFFFFFFF));
      expect(scheme.brand[50], const Color(0xFFF6F5FF));
      expect(scheme.brand[100], const Color(0xFFE9EBFF));
      expect(scheme.brand[150], const Color(0xFFCCD6FF));
      expect(scheme.brand[200], const Color(0xFFB1C2FF));
      expect(scheme.brand[300], const Color(0xFF89A5FF));
      expect(scheme.brand[400], const Color(0xFF5984FF));
      expect(scheme.brand[500], const Color(0xFF005FFE));
      expect(scheme.brand[600], const Color(0xFF2651BE));
      expect(scheme.brand[700], const Color(0xFF223F8C));
      expect(scheme.brand[800], const Color(0xFF1B2E63));
      expect(scheme.brand[900], const Color(0xFF0E1A3B));
      expect(scheme.brand[1000], const Color(0xFF000000));

      expect(scheme.chrome[0], const Color(0xFFFFFFFF));
      expect(scheme.chrome[50], const Color(0xFFF9F5F7));
      expect(scheme.chrome[100], const Color(0xFFEEEBEE));
      expect(scheme.chrome[150], const Color(0xFFD8D6DD));
      expect(scheme.chrome[200], const Color(0xFFC3C3CD));
      expect(scheme.chrome[300], const Color(0xFFA6A8B6));
      expect(scheme.chrome[400], const Color(0xFF878B9C));
      expect(scheme.chrome[500], const Color(0xFF676C81));
      expect(scheme.chrome[600], const Color(0xFF565968));
      expect(scheme.chrome[700], const Color(0xFF42444F));
      expect(scheme.chrome[800], const Color(0xFF303139));
      expect(scheme.chrome[900], const Color(0xFF1A1B20));
      expect(scheme.chrome[1000], const Color(0xFF000000));
    });

    test('generates the expected dark scales for the Stream brand seed', () {
      final scheme = StreamColorScheme.fromSeed(brand: _defaultSeed, brightness: .dark);

      expect(scheme.brand[0], const Color(0xFF000000));
      expect(scheme.brand[50], const Color(0xFF0E1A3B));
      expect(scheme.brand[100], const Color(0xFF1B2E63));
      expect(scheme.brand[150], const Color(0xFF223F8C));
      expect(scheme.brand[200], const Color(0xFF2651BE));
      expect(scheme.brand[300], const Color(0xFF005FFE));
      expect(scheme.brand[400], const Color(0xFF5984FF));
      expect(scheme.brand[500], const Color(0xFF89A5FF));
      expect(scheme.brand[600], const Color(0xFFB1C2FF));
      expect(scheme.brand[700], const Color(0xFFCCD6FF));
      expect(scheme.brand[800], const Color(0xFFE9EBFF));
      expect(scheme.brand[900], const Color(0xFFF6F5FF));
      expect(scheme.brand[1000], const Color(0xFFFFFFFF));

      expect(scheme.chrome[0], const Color(0xFF000000));
      expect(scheme.chrome[50], const Color(0xFF1A1B20));
      expect(scheme.chrome[900], const Color(0xFFF9F5F7));
      expect(scheme.chrome[1000], const Color(0xFFFFFFFF));
    });
  });

  group('StreamColorScheme.fromSeed reproduces the default palette', () {
    // The payoff for generating in HCT: seeding the brand color the design tokens were
    // built from lands back on those tokens. If this drifts, the tone ladder or chroma
    // envelope in StreamColorSwatchHelper no longer matches Figma.
    test('lands within 2 tone of the default light brand scale', () {
      final generated = StreamColorScheme.fromSeed(brand: _defaultSeed).brand;
      final tokens = StreamBrandColor.light();

      for (final shade in _expectedTones.keys) {
        expect(
          _toneOf(generated[shade]!),
          closeTo(_toneOf(tokens[shade]!), 2),
          reason: 'brand shade $shade tone drifted from the design token',
        );
      }
    });

    test('lands within 2 tone of the default dark brand scale', () {
      final generated = StreamColorScheme.fromSeed(brand: _defaultSeed, brightness: .dark).brand;
      final tokens = StreamBrandColor.dark();

      for (final shade in _expectedTones.keys) {
        expect(
          _toneOf(generated[shade]!),
          closeTo(_toneOf(tokens[shade]!), 2),
          reason: 'brand shade $shade tone drifted from the design token',
        );
      }
    });

    test('stays close in chroma to the default light brand scale', () {
      final generated = StreamColorScheme.fromSeed(brand: _defaultSeed).brand;
      final tokens = StreamBrandColor.light();

      for (final shade in _expectedTones.keys) {
        expect(
          _chromaOf(generated[shade]!),
          closeTo(_chromaOf(tokens[shade]!), 3),
          reason: 'brand shade $shade chroma drifted from the design token',
        );
      }
    });
  });

  group('StreamColorScheme.fromSeed tone ladder', () {
    for (final MapEntry(key: name, value: seed) in _seeds.entries) {
      test('places every light $name shade on the expected tone', () {
        final brand = StreamColorScheme.fromSeed(brand: seed).brand;

        for (final MapEntry(key: shade, value: tone) in _expectedTones.entries) {
          expect(
            _toneOf(brand[shade]!),
            closeTo(tone, 1),
            reason: '$name shade $shade should sit on tone $tone regardless of hue',
          );
        }
      });

      test('mirrors the ladder for dark $name shades', () {
        final brand = StreamColorScheme.fromSeed(brand: seed, brightness: .dark).brand;
        // The full mapping from StreamColorSwatchHelper._darkMirror.
        const mirror = {
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

        for (final MapEntry(key: shade, value: mirrored) in mirror.entries) {
          expect(
            _toneOf(brand[shade]!),
            closeTo(_expectedTones[mirrored]!, 1),
            reason: 'dark $name shade $shade should take the tone of light shade $mirrored',
          );
        }
      });

      test('produces a monotonically darkening light $name scale', () {
        final brand = StreamColorScheme.fromSeed(brand: seed).brand;

        for (var i = 1; i < _shades.length; i++) {
          expect(
            _toneOf(brand[_shades[i]]!),
            lessThan(_toneOf(brand[_shades[i - 1]]!)),
            reason: '$name shade ${_shades[i]} should be darker than ${_shades[i - 1]}',
          );
        }
      });

      test('preserves the $name seed hue across the scale', () {
        final brand = StreamColorScheme.fromSeed(brand: seed).brand;
        final seedHue = _hueOf(seed);

        for (final shade in _expectedTones.keys) {
          final shadeColor = brand[shade]!;
          // Hue is meaningless once chroma is clamped to near zero.
          if (_chromaOf(shadeColor) < 5) continue;
          final delta = (_hueOf(shadeColor) - seedHue).abs();
          expect(
            delta < 15 || delta > 345,
            isTrue,
            reason: '$name shade $shade drifted to hue ${_hueOf(shadeColor)} from $seedHue',
          );
        }
      });
    }
  });

  group('StreamColorScheme.fromSeed contrast guarantees', () {
    // The reason for normalizing the seed onto a tone ladder rather than reproducing it
    // verbatim at shade 500. Under the previous HSL generation a yellow seed produced an
    // accent with 1.22:1 against white text.
    for (final MapEntry(key: name, value: seed) in _seeds.entries) {
      test('gives the light $name accent readable contrast against its on-color', () {
        final scheme = StreamColorScheme.fromSeed(brand: seed);

        expect(
          _contrast(scheme.accentPrimary, scheme.textOnAccent),
          greaterThanOrEqualTo(4.5),
          reason: 'white text on the $name accent must meet WCAG AA',
        );
      });

      test('gives $name brand text readable contrast on its tinted surface', () {
        final brand = StreamColorScheme.fromSeed(brand: seed).brand;

        expect(
          _contrast(brand.shade900, brand.shade100),
          greaterThanOrEqualTo(4.5),
          reason: 'brand 900 on brand 100 must meet WCAG AA for $name',
        );
      });
    }
  });

  group('StreamColorScheme.fromSeed derived chrome', () {
    for (final MapEntry(key: name, value: seed) in _seeds.entries) {
      test('derives a near-neutral chrome scale from the $name brand', () {
        final chrome = StreamColorScheme.fromSeed(brand: seed).chrome;

        for (final shade in _expectedTones.keys) {
          expect(
            _chromaOf(chrome[shade]!),
            // Rounding into 8-bit sRGB can land a fraction above the requested chroma.
            lessThanOrEqualTo(StreamColorScheme.neutralChroma + 0.5),
            reason: 'derived chrome shade $shade should stay neutral for $name',
          );
        }
      });
    }

    test('honors an explicitly supplied chrome color', () {
      final scheme = StreamColorScheme.fromSeed(
        brand: _defaultSeed,
        chrome: const Color(0xFF4CAF50),
      );

      // Chrome follows the supplied green rather than the blue brand hue.
      expect(_hueOf(scheme.chrome.shade500), closeTo(_hueOf(const Color(0xFF4CAF50)), 15));
      expect(_toneOf(scheme.chrome.shade500), closeTo(_expectedTones[500]!, 1));
    });

    test('keeps the endpoints pinned to white and black', () {
      final light = StreamColorScheme.fromSeed(brand: _defaultSeed);
      final dark = StreamColorScheme.fromSeed(brand: _defaultSeed, brightness: .dark);

      expect(light.chrome[0], const Color(0xFFFFFFFF));
      expect(light.chrome[1000], const Color(0xFF000000));
      expect(dark.chrome[0], const Color(0xFF000000));
      expect(dark.chrome[1000], const Color(0xFFFFFFFF));
    });
  });

  group('StreamColorSwatch.fromColor', () {
    test('normalizes the seed onto the ladder rather than preserving it verbatim', () {
      // Deliberate replacement for the old "shade 500 == seed" contract. A yellow seed
      // is far too light to carry white text, so it is pulled down onto tone 46.
      const seed = Color(0xFFFFEB3B);
      final swatch = StreamColorSwatch.fromColor(seed);

      expect(swatch[500], isNot(seed));
      expect(_toneOf(swatch[500]!), closeTo(_expectedTones[500]!, 1));
      expect(_hueOf(swatch[500]!), closeTo(_hueOf(seed), 15));
    });

    test('uses shade 500 as the swatch primary', () {
      final swatch = StreamColorSwatch.fromColor(_defaultSeed);

      expect(swatch.toARGB32(), swatch[500]!.toARGB32());
    });

    test('collapses to a neutral scale for an achromatic seed', () {
      final swatch = StreamColorSwatch.fromColor(const Color(0xFF808080));

      for (final shade in _expectedTones.keys) {
        expect(_chromaOf(swatch[shade]!), lessThan(2));
        expect(_toneOf(swatch[shade]!), closeTo(_expectedTones[shade]!, 1));
      }
    });

    test('honors an explicit chroma override', () {
      final vivid = StreamColorSwatch.fromColor(_defaultSeed);
      final muted = StreamColorSwatch.fromColor(_defaultSeed, chroma: 8);

      expect(_chromaOf(muted.shade500), lessThan(_chromaOf(vivid.shade500)));
      expect(_chromaOf(muted.shade500), closeTo(8, 1));
      // The override changes chroma only; tone is still driven by the ladder.
      expect(_toneOf(muted.shade500), closeTo(_toneOf(vivid.shade500), 1));
    });
  });
}
