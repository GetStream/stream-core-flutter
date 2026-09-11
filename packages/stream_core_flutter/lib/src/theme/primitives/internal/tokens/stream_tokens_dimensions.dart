import 'dart:ui';

/// Dimension tokens from the design system.
///
/// Mode-independent, unlike the colors: the token repo publishes one set of
/// spacing, radius, line-height and weight values, so these live here rather
/// than being duplicated under `light/` and `dark/`. They are also identical
/// across the android, ios and web flavors of the token build, so no flavor
/// choice arises. Font sizes are the exception and live in `android/` and
/// `ios/` beside this file.
///
/// Declared in the types Flutter consumes rather than the raw numbers upstream
/// emits — `double` for what `Radius`, `EdgeInsets` and `TextStyle` take, and
/// `FontWeight` for the weights, which have no public constructor from a number
/// and so could not otherwise be read in a const expression.
///
/// Read these through `StreamSpacing`, `StreamRadius`, `StreamLineHeight` and
/// `StreamFontWeight`, which are the public surface.
///
/// One upstream dimension is deliberately not carried: `radiusNone`, since the
/// analyzer's `use_named_constants` prefers `Radius.zero` over `circular(0)`.
/// The font family is not carried either — this package never sets one for
/// text, only for the emoji and icon fonts.
class StreamTokensDimensions {
  StreamTokensDimensions._();

  // Spacing
  static const double spacingNone = 0;
  static const double spacingXxxs = 2;
  static const double spacingXxs = 4;
  static const double spacingXs = 8;
  static const double spacingSm = 12;
  static const double spacingMd = 16;
  static const double spacingLg = 20;
  static const double spacingXl = 24;
  static const double spacing2xl = 32;
  static const double spacing3xl = 40;

  // Radius
  static const double radiusXxs = 2;
  static const double radiusXs = 4;
  static const double radiusSm = 6;
  static const double radiusMd = 8;
  static const double radiusLg = 12;
  static const double radiusXl = 16;
  static const double radius2xl = 20;
  static const double radius3xl = 24;
  static const double radius4xl = 32;
  static const double radiusMax = 9999;

  // Typography
  static const double typographyLineHeightTight = 16;
  static const double typographyLineHeightNormal = 20;
  static const double typographyLineHeightRelaxed = 24;

  // Typography — weight
  //
  // Declared as `FontWeight` rather than the raw 400/500/600/700 upstream
  // emits, for the same reason the values above are `double`: it is the type
  // Flutter consumes, and `FontWeight` has no public constructor taking a
  // number, so an int here could not be read in a const expression.
  static const FontWeight typographyFontWeightRegular = FontWeight.w400;
  static const FontWeight typographyFontWeightMedium = FontWeight.w500;
  static const FontWeight typographyFontWeightSemiBold = FontWeight.w600;
  static const FontWeight typographyFontWeightBold = FontWeight.w700;
}
