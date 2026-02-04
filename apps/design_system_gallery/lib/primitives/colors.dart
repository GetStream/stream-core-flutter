import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(
  name: 'All Colors',
  type: StreamColors,
  path: '[App Foundation]/Primitives/Colors',
)
Widget buildStreamColorsShowcase(BuildContext context) {
  final textTheme = context.streamTextTheme;
  final colorScheme = context.streamColorScheme;
  final spacing = context.streamSpacing;

  return DefaultTextStyle(
    style: textTheme.bodyDefault.copyWith(color: colorScheme.textPrimary),
    child: SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Color swatches - full width
          const _ColorSwatchesList(),
          SizedBox(height: spacing.xl),

          // Neutrals section
          const _NeutralsSection(),
        ],
      ),
    ),
  );
}

/// Full-width color swatches
class _ColorSwatchesList extends StatelessWidget {
  const _ColorSwatchesList();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    final swatches = [
      _SwatchData(
        name: 'blue',
        swatch: StreamColors.blue,
        usage: 'Primary actions, links, focus states',
      ),
      _SwatchData(
        name: 'cyan',
        swatch: StreamColors.cyan,
        usage: 'Info states, secondary highlights',
      ),
      _SwatchData(
        name: 'green',
        swatch: StreamColors.green,
        usage: 'Success states, positive feedback',
      ),
      _SwatchData(
        name: 'purple',
        swatch: StreamColors.purple,
        usage: 'Premium features, special content',
      ),
      _SwatchData(
        name: 'yellow',
        swatch: StreamColors.yellow,
        usage: 'Warnings, attention states',
      ),
      _SwatchData(
        name: 'red',
        swatch: StreamColors.red,
        usage: 'Errors, destructive actions',
      ),
      _SwatchData(
        name: 'slate',
        swatch: StreamColors.slate,
        usage: 'Dark backgrounds, text on light',
      ),
      _SwatchData(
        name: 'neutral',
        swatch: StreamColors.neutral,
        usage: 'Light backgrounds, borders',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: 'COLOR SWATCHES'),
        SizedBox(height: spacing.md),
        ...swatches.map((data) => _FullWidthSwatchCard(data: data)),
      ],
    );
  }
}

class _FullWidthSwatchCard extends StatelessWidget {
  const _FullWidthSwatchCard({required this.data});

  final _SwatchData data;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final boxShadow = context.streamBoxShadow;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;
    final shades = [50, 100, 150, 200, 300, 400, 500, 600, 700, 800, 900];

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.md),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colorScheme.backgroundSurface,
          borderRadius: BorderRadius.all(radius.lg),
          boxShadow: boxShadow.elevation1,
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.all(radius.lg),
          border: Border.all(color: colorScheme.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(spacing.sm),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: data.swatch.shade500,
                      borderRadius: BorderRadius.all(radius.sm),
                    ),
                  ),
                  SizedBox(width: spacing.sm + spacing.xxs),
                  Text(
                    'StreamColors.${data.name}',
                    style: textTheme.captionEmphasis.copyWith(
                      color: colorScheme.textPrimary,
                      fontFamily: 'monospace',
                    ),
                  ),
                  SizedBox(width: spacing.sm),
                  Text(
                    '— ${data.usage}',
                    style: textTheme.captionDefault.copyWith(
                      color: colorScheme.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            // Full width shade strip
            Row(
              children: shades.map((shade) {
                final color = data.swatch[shade]!;
                final textColor = _getTextColorForShade(data.swatch, shade);

                return Expanded(
                  child: InkWell(
                    onTap: () {
                      Clipboard.setData(
                        ClipboardData(
                          text: 'StreamColors.${data.name}.shade$shade',
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Copied: StreamColors.${data.name}.shade$shade',
                          ),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Container(
                      height: 56,
                      color: color,
                      child: Center(
                        child: Text(
                          '$shade',
                          style: textTheme.metadataEmphasis.copyWith(
                            color: textColor,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Neutrals section
class _NeutralsSection extends StatelessWidget {
  const _NeutralsSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: 'NEUTRALS'),
        SizedBox(height: spacing.md),
        // White variants
        const _NeutralStrip(
          title: 'White',
          colors: [
            ('white', StreamColors.white, '100%'),
            ('white70', StreamColors.white70, '70%'),
            ('white50', StreamColors.white50, '50%'),
            ('white20', StreamColors.white20, '20%'),
            ('white10', StreamColors.white10, '10%'),
          ],
        ),
        SizedBox(height: spacing.sm),
        // Black variants
        const _NeutralStrip(
          title: 'Black',
          colors: [
            ('black', StreamColors.black, '100%'),
            ('black50', StreamColors.black50, '50%'),
            ('black10', StreamColors.black10, '10%'),
            ('black5', StreamColors.black5, '5%'),
          ],
        ),
        SizedBox(height: spacing.sm),
        // Transparent
        const _TransparentTile(),
      ],
    );
  }
}

class _NeutralStrip extends StatelessWidget {
  const _NeutralStrip({
    required this.title,
    required this.colors,
  });

  final String title;
  final List<(String, Color, String)> colors;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final boxShadow = context.streamBoxShadow;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(radius.lg),
        boxShadow: boxShadow.elevation1,
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.all(radius.lg),
        border: Border.all(color: colorScheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: spacing.sm, vertical: spacing.sm),
            color: colorScheme.backgroundSurfaceSubtle,
            child: Text(
              title,
              style: textTheme.captionEmphasis.copyWith(
                color: colorScheme.textSecondary,
              ),
            ),
          ),
          // Colors row
          Row(
            children: colors.map((entry) {
              final (name, color, opacity) = entry;
              final brightness = ThemeData.estimateBrightnessForColor(color);
              final textColor = brightness == Brightness.dark ? StreamColors.white : StreamColors.black;

              return Expanded(
                child: InkWell(
                  onTap: () {
                    Clipboard.setData(
                      ClipboardData(text: 'StreamColors.$name'),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Copied: StreamColors.$name'),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Container(
                    height: 64,
                    color: color,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          name,
                          style: textTheme.metadataEmphasis.copyWith(
                            color: textColor,
                            fontFamily: 'monospace',
                            fontSize: 9,
                          ),
                        ),
                        SizedBox(height: spacing.xxs),
                        Text(
                          opacity,
                          style: textTheme.metadataDefault.copyWith(
                            color: textColor.withValues(alpha: 0.7),
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _TransparentTile extends StatelessWidget {
  const _TransparentTile();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final boxShadow = context.streamBoxShadow;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return InkWell(
      onTap: () {
        Clipboard.setData(
          const ClipboardData(text: 'StreamColors.transparent'),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Copied: StreamColors.transparent'),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      borderRadius: BorderRadius.all(radius.lg),
      child: Container(
        padding: EdgeInsets.all(spacing.md),
        decoration: BoxDecoration(
          color: StreamColors.transparent,
          borderRadius: BorderRadius.all(radius.lg),
          boxShadow: boxShadow.elevation1,
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.all(radius.lg),
          border: Border.all(
            color: colorScheme.borderDefault,
          ),
        ),
        child: Row(
          children: [
            // Checkerboard preview
            Container(
              width: 40,
              height: 40,
              foregroundDecoration: BoxDecoration(
                borderRadius: BorderRadius.all(radius.md),
                border: Border.all(color: colorScheme.borderSubtle),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.all(radius.md),
                child: CustomPaint(
                  painter: _CheckerboardPainter(
                    color: colorScheme.borderSubtle,
                  ),
                ),
              ),
            ),
            SizedBox(width: spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'StreamColors.transparent',
                        style: textTheme.captionEmphasis.copyWith(
                          color: colorScheme.textPrimary,
                          fontFamily: 'monospace',
                        ),
                      ),
                      SizedBox(width: spacing.xs + spacing.xxs),
                      Icon(
                        Icons.copy,
                        size: 12,
                        color: colorScheme.textTertiary,
                      ),
                    ],
                  ),
                  SizedBox(height: spacing.xxs),
                  Text(
                    '0% opacity - fully transparent',
                    style: textTheme.captionDefault.copyWith(
                      color: colorScheme.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckerboardPainter extends CustomPainter {
  const _CheckerboardPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const squareSize = 8.0;
    for (var i = 0; i < size.width / squareSize; i++) {
      for (var j = 0; j < size.height / squareSize; j++) {
        if ((i + j).isEven) {
          canvas.drawRect(
            Rect.fromLTWH(i * squareSize, j * squareSize, squareSize, squareSize),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: spacing.sm, vertical: spacing.xs),
      decoration: BoxDecoration(
        color: colorScheme.accentPrimary,
        borderRadius: BorderRadius.all(radius.xs),
      ),
      child: Text(
        label,
        style: textTheme.metadataEmphasis.copyWith(
          color: colorScheme.textOnAccent,
          letterSpacing: 1,
          fontSize: 9,
        ),
      ),
    );
  }
}

class _SwatchData {
  const _SwatchData({
    required this.name,
    required this.swatch,
    required this.usage,
  });

  final String name;
  final StreamColorSwatch swatch;
  final String usage;
}

/// Returns the appropriate text color for a given shade background,
/// using the same swatch for visual harmony.
///
/// This follows the industry-standard "on-color" pattern used by Material
/// Design, Carbon (IBM), and Atlassian design systems. Using colors from
/// the same family (rather than pure black/white) creates better visual
/// cohesion while maintaining WCAG contrast requirements.
///
/// The graduated contrast approach is based on perceptual depth theory—
/// mimicking how light affects surfaces in real-world environments.
///
/// Light backgrounds (50-500) use darker shades for text.
/// Dark backgrounds (600+) use the lightest shade for text.
Color _getTextColorForShade(StreamColorSwatch swatch, int shade) {
  // Graduated contrast scale:
  // - shade 50-100: use shade 700 for text (~5:1 contrast)
  // - shade 200-300: use shade 800 for text (~6:1 contrast)
  // - shade 400-500: use shade 900 for text (~7:1 contrast)
  // - shade 600+: use shade 50 for text (inverted for dark backgrounds)
  if (shade <= 100) return swatch.shade700;
  if (shade <= 300) return swatch.shade800;
  if (shade <= 500) return swatch.shade900;
  return swatch.shade50;
}
