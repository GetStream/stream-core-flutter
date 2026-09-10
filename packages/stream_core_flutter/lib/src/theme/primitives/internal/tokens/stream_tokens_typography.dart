import 'package:flutter/widgets.dart';

import 'stream_tokens_dimensions.dart';

class StreamTokensTypography {
  StreamTokensTypography._();

  static const headingLg = TextStyle(
    fontFamily: StreamTokensDimensions.typographyFontFamilySans,
    fontSize: StreamTokensDimensions.typographyFontSizeXl,
    fontWeight: FontWeight.w600,
    height: StreamTokensDimensions.typographyLineHeightRelaxed / StreamTokensDimensions.typographyFontSizeXl,
  );
  static const headingMd = TextStyle(
    fontFamily: StreamTokensDimensions.typographyFontFamilySans,
    fontSize: StreamTokensDimensions.typographyFontSizeLg,
    fontWeight: FontWeight.w600,
    height: StreamTokensDimensions.typographyLineHeightNormal / StreamTokensDimensions.typographyFontSizeLg,
  );
  static const headingSm = TextStyle(
    fontFamily: StreamTokensDimensions.typographyFontFamilySans,
    fontSize: StreamTokensDimensions.typographyFontSizeMd,
    fontWeight: FontWeight.w600,
    height: StreamTokensDimensions.typographyLineHeightNormal / StreamTokensDimensions.typographyFontSizeMd,
  );
  static const headingXs = TextStyle(
    fontFamily: StreamTokensDimensions.typographyFontFamilySans,
    fontSize: StreamTokensDimensions.typographyFontSizeXs,
    fontWeight: FontWeight.w600,
    height: StreamTokensDimensions.typographyLineHeightTight / StreamTokensDimensions.typographyFontSizeXs,
  );
  static const bodyDefault = TextStyle(
    fontFamily: StreamTokensDimensions.typographyFontFamilySans,
    fontSize: StreamTokensDimensions.typographyFontSizeMd,
    fontWeight: FontWeight.w400,
    height: StreamTokensDimensions.typographyLineHeightNormal / StreamTokensDimensions.typographyFontSizeMd,
  );
  static const bodyEmphasis = TextStyle(
    fontFamily: StreamTokensDimensions.typographyFontFamilySans,
    fontSize: StreamTokensDimensions.typographyFontSizeMd,
    fontWeight: FontWeight.w600,
    height: StreamTokensDimensions.typographyLineHeightNormal / StreamTokensDimensions.typographyFontSizeMd,
  );
  static const bodyLink = TextStyle(
    fontFamily: StreamTokensDimensions.typographyFontFamilySans,
    fontSize: StreamTokensDimensions.typographyFontSizeMd,
    fontWeight: FontWeight.w400,
    height: StreamTokensDimensions.typographyLineHeightNormal / StreamTokensDimensions.typographyFontSizeMd,
  );
  static const bodyLinkEmphasis = TextStyle(
    fontFamily: StreamTokensDimensions.typographyFontFamilySans,
    fontSize: StreamTokensDimensions.typographyFontSizeMd,
    fontWeight: FontWeight.w600,
    height: StreamTokensDimensions.typographyLineHeightNormal / StreamTokensDimensions.typographyFontSizeMd,
  );
  static const captionDefault = TextStyle(
    fontFamily: StreamTokensDimensions.typographyFontFamilySans,
    fontSize: StreamTokensDimensions.typographyFontSizeSm,
    fontWeight: FontWeight.w400,
    height: StreamTokensDimensions.typographyLineHeightTight / StreamTokensDimensions.typographyFontSizeSm,
  );
  static const captionEmphasis = TextStyle(
    fontFamily: StreamTokensDimensions.typographyFontFamilySans,
    fontSize: StreamTokensDimensions.typographyFontSizeSm,
    fontWeight: FontWeight.w600,
    height: StreamTokensDimensions.typographyLineHeightTight / StreamTokensDimensions.typographyFontSizeSm,
  );
  static const captionLink = TextStyle(
    fontFamily: StreamTokensDimensions.typographyFontFamilySans,
    fontSize: StreamTokensDimensions.typographyFontSizeSm,
    fontWeight: FontWeight.w400,
    height: StreamTokensDimensions.typographyLineHeightTight / StreamTokensDimensions.typographyFontSizeSm,
  );
  static const captionLinkEmphasis = TextStyle(
    fontFamily: StreamTokensDimensions.typographyFontFamilySans,
    fontSize: StreamTokensDimensions.typographyFontSizeSm,
    fontWeight: FontWeight.w600,
    height: StreamTokensDimensions.typographyLineHeightTight / StreamTokensDimensions.typographyFontSizeSm,
  );
  static const metadataDefault = TextStyle(
    fontFamily: StreamTokensDimensions.typographyFontFamilySans,
    fontSize: StreamTokensDimensions.typographyFontSizeXs,
    fontWeight: FontWeight.w400,
    height: StreamTokensDimensions.typographyLineHeightTight / StreamTokensDimensions.typographyFontSizeXs,
  );
  static const metadataEmphasis = TextStyle(
    fontFamily: StreamTokensDimensions.typographyFontFamilySans,
    fontSize: StreamTokensDimensions.typographyFontSizeXs,
    fontWeight: FontWeight.w600,
    height: StreamTokensDimensions.typographyLineHeightTight / StreamTokensDimensions.typographyFontSizeXs,
  );
  static const metadataLink = TextStyle(
    fontFamily: StreamTokensDimensions.typographyFontFamilySans,
    fontSize: StreamTokensDimensions.typographyFontSizeXs,
    fontWeight: FontWeight.w400,
    height: StreamTokensDimensions.typographyLineHeightTight / StreamTokensDimensions.typographyFontSizeXs,
  );
  static const metadataLinkEmphasis = TextStyle(
    fontFamily: StreamTokensDimensions.typographyFontFamilySans,
    fontSize: StreamTokensDimensions.typographyFontSizeXs,
    fontWeight: FontWeight.w600,
    height: StreamTokensDimensions.typographyLineHeightTight / StreamTokensDimensions.typographyFontSizeXs,
  );
  static const numericXl = TextStyle(
    fontFamily: StreamTokensDimensions.typographyFontFamilySans,
    fontSize: StreamTokensDimensions.typographyFontSizeSm,
    fontWeight: FontWeight.w700,
  );
  static const numericLg = TextStyle(
    fontFamily: StreamTokensDimensions.typographyFontFamilySans,
    fontSize: StreamTokensDimensions.typographyFontSizeXs,
    fontWeight: FontWeight.w700,
  );
  static const numericMd = TextStyle(
    fontFamily: StreamTokensDimensions.typographyFontFamilySans,
    fontSize: StreamTokensDimensions.typographyFontSizeXxs,
    fontWeight: FontWeight.w700,
  );
  static const numericSm = TextStyle(
    fontFamily: StreamTokensDimensions.typographyFontFamilySans,
    fontSize: StreamTokensDimensions.typographyFontSizeMicro,
    fontWeight: FontWeight.w700,
  );
}
