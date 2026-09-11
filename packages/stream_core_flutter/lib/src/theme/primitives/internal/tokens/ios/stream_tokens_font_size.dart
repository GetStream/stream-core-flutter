/// Font-size tokens from the design system, ios flavor.
///
/// The one dimension group that differs per platform: iOS runs a size up at
/// almost every step, so the token repo publishes a separate set. Read through
/// `StreamFontSize.ios`, which is the public surface.
///
/// Declared as `double` because that is what `TextStyle` takes; the token repo
/// emits them without a decimal point.
class StreamTokensFontSize {
  StreamTokensFontSize._();

  static const double typographyFontSizeMicro = 8;
  static const double typographyFontSizeXxs = 12;
  static const double typographyFontSizeXs = 13;
  static const double typographyFontSizeSm = 15;
  static const double typographyFontSizeMd = 17;
  static const double typographyFontSizeLg = 20;
  static const double typographyFontSizeXl = 22;
  static const double typographyFontSize2xl = 24;
}
