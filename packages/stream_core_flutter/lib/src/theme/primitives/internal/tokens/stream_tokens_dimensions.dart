/// Dimension tokens from the design system.
///
/// Mode-independent, unlike the colors: the token repo publishes one set of
/// spacing, radius and type values, so these live here rather than being
/// duplicated under `light/` and `dark/`.
///
/// Type comes from the **web** flavor of the token build — the only one
/// carrying the `Geist` family this package ships. Android resolves to Roboto,
/// iOS to SF Pro, and iOS runs a size up at every step.
///
/// Declared as `double` because that is what `Radius`, `EdgeInsets` and
/// `TextStyle` take; the token repo emits them without a decimal point.
///
/// Read these through `StreamSpacing`, `StreamRadius` and
/// `StreamTokensTypography`, which are the public surface. Font weights are
/// deliberately absent: `TextStyle.fontWeight` takes a `FontWeight`, which
/// cannot be built from a number in a const expression, so the weight tokens
/// would have no consumer.
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
  static const typographyFontFamilySans = 'Geist';
  static const double typographyFontSizeMicro = 8;
  static const double typographyFontSizeXxs = 10;
  static const double typographyFontSizeXs = 12;
  static const double typographyFontSizeSm = 14;
  static const double typographyFontSizeMd = 16;
  static const double typographyFontSizeLg = 18;
  static const double typographyFontSizeXl = 20;
  static const double typographyLineHeightTight = 16;
  static const double typographyLineHeightNormal = 20;
  static const double typographyLineHeightRelaxed = 24;
}
