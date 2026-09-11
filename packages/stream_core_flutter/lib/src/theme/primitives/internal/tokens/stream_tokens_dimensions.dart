/// Dimension tokens from the design system.
///
/// Mode-independent, unlike the colors: the token repo publishes one set of
/// spacing, radius and line-height values, so these live here rather than being
/// duplicated under `light/` and `dark/`. They are also identical across the
/// android, ios and web flavors of the token build, so no flavor choice arises
/// here — unlike the font sizes, where iOS runs a size up at every step.
///
/// Declared as `double` because that is what `Radius`, `EdgeInsets` and
/// `TextStyle` take; the token repo emits them without a decimal point.
///
/// Read these through `StreamSpacing`, `StreamRadius` and `StreamLineHeight`,
/// which are the public surface. Three groups of upstream dimensions are
/// deliberately not carried, because nothing here can read them:
///
/// - **Font sizes.** `StreamFontSize` ships two platform scales, and only the
///   android one matches these values; the ios scale comes from a flavor this
///   package does not vendor. Wiring one and not the other would read as an
///   oversight rather than a choice.
/// - **Font weights.** `TextStyle.fontWeight` takes a `FontWeight`, which
///   cannot be built from a number in a const expression.
/// - **`radiusNone`.** The analyzer's `use_named_constants` prefers
///   `Radius.zero` over `circular(0)`.
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
}
