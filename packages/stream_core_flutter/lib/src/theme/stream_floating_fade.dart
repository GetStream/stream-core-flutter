import 'package:material_ui/material_ui.dart';

/// Builds a [LinearGradient] that fades from a solid [color] into transparent,
/// suitable for floating app bars, bottom navigation bars, and composers.
///
/// The gradient is solid from `0.0` up to [solidFraction] (the fraction of the
/// total height occupied by a system safe-area inset), then fades through four
/// alpha stops to fully transparent at `1.0`.
///
/// [begin] and [end] control the direction of the fade:
/// * top-to-bottom (`Alignment.topCenter` → `Alignment.bottomCenter`) for
///   floating app bars, where the bar fades into the scrollable content below.
/// * bottom-to-top (`Alignment.bottomCenter` → `Alignment.topCenter`) for
///   floating nav bars and composers, where they fade into content above.
LinearGradient streamFloatingFadeLinearGradient({
  required Color color,
  double solidFraction = 0.0,
  AlignmentGeometry begin = Alignment.topCenter,
  AlignmentGeometry end = Alignment.bottomCenter,
}) {
  assert(solidFraction >= 0.0 && solidFraction <= 1.0, 'solidFraction must be in [0, 1]');
  final f = solidFraction;

  return LinearGradient(
    colors: [
      color,
      color,
      color.withAlpha(0xE8), // ~91 %
      color.withAlpha(0xA8), // ~66 %
      color.withAlpha(0x40), // ~25 %
      color.withAlpha(0x00), // transparent
    ],
    stops: [
      0.0,
      f,
      f + (1 - f) * 0.55,
      f + (1 - f) * 0.75,
      f + (1 - f) * 0.90,
      1.0,
    ],
    begin: begin,
    end: end,
  );
}
