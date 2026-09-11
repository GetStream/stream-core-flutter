/// Font-size tokens from the design system, android flavor.
///
/// The one dimension group that differs per platform: iOS runs a size up at
/// almost every step, so the token repo publishes a separate set. Read through
/// `StreamFontSize.android`, which is the public surface.
///
/// Declared as `double` because that is what `TextStyle` takes; the token repo
/// emits them without a decimal point.
class StreamTokensFontSize {
  StreamTokensFontSize._();

  static const double typographyFontSizeMicro = 8;
  static const double typographyFontSizeXxs = 10;
  static const double typographyFontSizeXs = 12;
  static const double typographyFontSizeSm = 14;
  static const double typographyFontSizeMd = 16;
  static const double typographyFontSizeLg = 18;
  static const double typographyFontSizeXl = 20;
  static const double typographyFontSize2xl = 24;
}
