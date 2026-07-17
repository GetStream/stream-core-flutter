import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

/// The shades every generated [StreamColorSwatch] exposes (see
/// `StreamColorSwatchHelper.generateShadeMap`).
const _shades = [0, 50, 100, 150, 200, 300, 400, 500, 600, 700, 800, 900, 1000];

void main() {
  group('StreamTheme color generation Golden Tests', () {
    goldenTest(
      'renders the generated brand and chrome scales for custom seed colors',
      fileName: 'stream_theme_color_generation',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 1200),
        children: [
          GoldenTestScenario(
            name: 'deep orange seed',
            child: const _SeedColorPreview(seedColor: Color(0xFFFF5722)),
          ),
          GoldenTestScenario(
            name: 'purple seed',
            child: const _SeedColorPreview(seedColor: Color(0xFF9C27B0)),
          ),
          GoldenTestScenario(
            name: 'yellow seed',
            child: const _SeedColorPreview(seedColor: Color(0xFFFFEB3B)),
          ),
          GoldenTestScenario(
            name: 'green seed',
            child: const _SeedColorPreview(seedColor: Color(0xFF4CAF50)),
          ),
          GoldenTestScenario(
            name: 'blue seed',
            child: const _SeedColorPreview(seedColor: Color(0xFF2196F3)),
          ),
          GoldenTestScenario(
            name: 'red seed',
            child: const _SeedColorPreview(seedColor: Color(0xFFF44336)),
          ),
        ],
      ),
    );
  });
}

/// Renders the [StreamTheme.light] and [StreamTheme.dark] brand/chrome
/// scales generated from a single [seedColor] as plain color swatches,
/// pinning the HSL-based shade generation in `StreamColorSwatchHelper`
/// against regressions. See `stream_theme_color_generation_test.dart` for
/// assertions on the exact generated values.
class _SeedColorPreview extends StatelessWidget {
  const _SeedColorPreview({required this.seedColor});

  final Color seedColor;

  @override
  Widget build(BuildContext context) {
    final light = StreamTheme.light(brandColor: seedColor).colorScheme;
    final dark = StreamTheme.dark(brandColor: seedColor).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ColorScaleRow(swatch: light.brand),
        _ColorScaleRow(swatch: light.chrome),
        const SizedBox(height: 8),
        _ColorScaleRow(swatch: dark.brand),
        _ColorScaleRow(swatch: dark.chrome),
      ],
    );
  }
}

class _ColorScaleRow extends StatelessWidget {
  const _ColorScaleRow({required this.swatch});

  final StreamColorSwatch swatch;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final shade in _shades) Container(width: 76, height: 56, color: swatch[shade]),
      ],
    );
  }
}
