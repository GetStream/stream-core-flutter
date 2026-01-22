import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../primitives/stream_typography.dart';

part 'stream_text_theme.g.theme.dart';

/// Semantic text theme for the Stream design system.
///
/// [StreamTextTheme] provides semantic text styles built from [StreamTypography]
/// primitives. It includes styles for headings, body text, captions, metadata,
/// and numeric displays.
///
/// {@tool snippet}
///
/// Create a text theme:
///
/// ```dart
/// final textTheme = StreamTextTheme();
/// Text('Hello', style: textTheme.headingLg);
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamTypography], which provides the primitive building blocks.
@immutable
@ThemeGen(constructor: 'raw')
class StreamTextTheme with _$StreamTextTheme {
  /// Creates a [StreamTextTheme] with platform-specific values.
  ///
  /// If [platform] is null, uses [defaultTargetPlatform].
  /// Individual text styles can be overridden by providing them directly.
  factory StreamTextTheme({
    TargetPlatform? platform,
    StreamTypography? typography,
    TextStyle? headingLg,
    TextStyle? headingMd,
    TextStyle? headingSm,
    TextStyle? bodyDefault,
    TextStyle? bodyEmphasis,
    TextStyle? bodyLink,
    TextStyle? bodyLinkEmphasis,
    TextStyle? captionDefault,
    TextStyle? captionEmphasis,
    TextStyle? captionLink,
    TextStyle? captionLinkEmphasis,
    TextStyle? metadataDefault,
    TextStyle? metadataEmphasis,
    TextStyle? metadataLink,
    TextStyle? metadataLinkEmphasis,
    TextStyle? numericLg,
    TextStyle? numericMd,
    TextStyle? numericSm,
  }) {
    platform ??= defaultTargetPlatform;
    typography ??= StreamTypography(platform: platform);

    final fontSize = typography.fontSize;
    final lineHeight = typography.lineHeight;
    final fontWeight = typography.fontWeight;

    // Heading styles
    headingLg ??= TextStyle(
      fontSize: fontSize.xl,
      fontWeight: fontWeight.semibold,
      height: lineHeight.relaxed / fontSize.xl,
      fontStyle: FontStyle.normal,
      decoration: TextDecoration.none,
    );
    headingMd ??= TextStyle(
      fontSize: fontSize.lg,
      fontWeight: fontWeight.semibold,
      height: lineHeight.normal / fontSize.lg,
      fontStyle: FontStyle.normal,
      decoration: TextDecoration.none,
    );
    headingSm ??= TextStyle(
      fontSize: fontSize.md,
      fontWeight: fontWeight.semibold,
      height: lineHeight.tight / fontSize.md,
      fontStyle: FontStyle.normal,
      decoration: TextDecoration.none,
    );

    // Body styles
    bodyDefault ??= TextStyle(
      fontSize: fontSize.md,
      fontWeight: fontWeight.regular,
      height: lineHeight.normal / fontSize.md,
      fontStyle: FontStyle.normal,
      decoration: TextDecoration.none,
    );
    bodyEmphasis ??= TextStyle(
      fontSize: fontSize.md,
      fontWeight: fontWeight.semibold,
      height: lineHeight.normal / fontSize.md,
      fontStyle: FontStyle.normal,
      decoration: TextDecoration.none,
    );
    bodyLink ??= TextStyle(
      fontSize: fontSize.md,
      fontWeight: fontWeight.regular,
      height: lineHeight.normal / fontSize.md,
      fontStyle: FontStyle.normal,
      decoration: TextDecoration.none,
    );
    bodyLinkEmphasis ??= TextStyle(
      fontSize: fontSize.md,
      fontWeight: fontWeight.semibold,
      height: lineHeight.normal / fontSize.md,
      fontStyle: FontStyle.normal,
      decoration: TextDecoration.none,
    );

    // Caption styles
    captionDefault ??= TextStyle(
      fontSize: fontSize.sm,
      fontWeight: fontWeight.regular,
      height: lineHeight.tight / fontSize.sm,
      fontStyle: FontStyle.normal,
      decoration: TextDecoration.none,
    );
    captionEmphasis ??= TextStyle(
      fontSize: fontSize.sm,
      fontWeight: fontWeight.semibold,
      height: lineHeight.tight / fontSize.sm,
      fontStyle: FontStyle.normal,
      decoration: TextDecoration.none,
    );
    captionLink ??= TextStyle(
      fontSize: fontSize.sm,
      fontWeight: fontWeight.regular,
      height: lineHeight.tight / fontSize.sm,
      fontStyle: FontStyle.normal,
      decoration: TextDecoration.none,
    );
    captionLinkEmphasis ??= TextStyle(
      fontSize: fontSize.sm,
      fontWeight: fontWeight.semibold,
      height: lineHeight.tight / fontSize.sm,
      fontStyle: FontStyle.normal,
      decoration: TextDecoration.none,
    );

    // Metadata styles
    metadataDefault ??= TextStyle(
      fontSize: fontSize.xs,
      fontWeight: fontWeight.regular,
      height: lineHeight.tight / fontSize.xs,
      fontStyle: FontStyle.normal,
      decoration: TextDecoration.none,
    );
    metadataEmphasis ??= TextStyle(
      fontSize: fontSize.xs,
      fontWeight: fontWeight.semibold,
      height: lineHeight.tight / fontSize.xs,
      fontStyle: FontStyle.normal,
      decoration: TextDecoration.none,
    );
    metadataLink ??= TextStyle(
      fontSize: fontSize.xs,
      fontWeight: fontWeight.regular,
      height: lineHeight.tight / fontSize.xs,
      fontStyle: FontStyle.normal,
      decoration: TextDecoration.none,
    );
    metadataLinkEmphasis ??= TextStyle(
      fontSize: fontSize.xs,
      fontWeight: fontWeight.semibold,
      height: lineHeight.tight / fontSize.xs,
      fontStyle: FontStyle.normal,
      decoration: TextDecoration.none,
    );

    // Numeric styles
    numericLg ??= TextStyle(
      fontSize: fontSize.xs,
      fontWeight: fontWeight.bold,
      height: 12 / fontSize.xs,
      fontStyle: FontStyle.normal,
      decoration: TextDecoration.none,
    );
    numericMd ??= TextStyle(
      fontSize: fontSize.xxs,
      fontWeight: fontWeight.bold,
      height: 10 / fontSize.xxs,
      fontStyle: FontStyle.normal,
      decoration: TextDecoration.none,
    );
    numericSm ??= TextStyle(
      fontSize: fontSize.micro,
      fontWeight: fontWeight.bold,
      height: 8 / fontSize.micro,
      fontStyle: FontStyle.normal,
      decoration: TextDecoration.none,
    );

    return .raw(
      headingLg: headingLg,
      headingMd: headingMd,
      headingSm: headingSm,
      bodyDefault: bodyDefault,
      bodyEmphasis: bodyEmphasis,
      bodyLink: bodyLink,
      bodyLinkEmphasis: bodyLinkEmphasis,
      captionDefault: captionDefault,
      captionEmphasis: captionEmphasis,
      captionLink: captionLink,
      captionLinkEmphasis: captionLinkEmphasis,
      metadataDefault: metadataDefault,
      metadataEmphasis: metadataEmphasis,
      metadataLink: metadataLink,
      metadataLinkEmphasis: metadataLinkEmphasis,
      numericLg: numericLg,
      numericMd: numericMd,
      numericSm: numericSm,
    );
  }

  const StreamTextTheme.raw({
    required this.headingLg,
    required this.headingMd,
    required this.headingSm,
    required this.bodyDefault,
    required this.bodyEmphasis,
    required this.bodyLink,
    required this.bodyLinkEmphasis,
    required this.captionDefault,
    required this.captionEmphasis,
    required this.captionLink,
    required this.captionLinkEmphasis,
    required this.metadataDefault,
    required this.metadataEmphasis,
    required this.metadataLink,
    required this.metadataLinkEmphasis,
    required this.numericLg,
    required this.numericMd,
    required this.numericSm,
  });

  /// Large heading text style.
  ///
  /// Uses semibold weight, xl font size, and relaxed line height.
  final TextStyle headingLg;

  /// Medium heading text style.
  ///
  /// Uses semibold weight, lg font size, and normal line height.
  final TextStyle headingMd;

  /// Small heading text style.
  ///
  /// Uses semibold weight, md font size, and tight line height.
  final TextStyle headingSm;

  /// Default body text style.
  ///
  /// Uses regular weight, md font size, and normal line height.
  final TextStyle bodyDefault;

  /// Emphasized body text style.
  ///
  /// Uses semibold weight, md font size, and normal line height.
  final TextStyle bodyEmphasis;

  /// Body link text style.
  ///
  /// Uses regular weight, md font size, and normal line height.
  final TextStyle bodyLink;

  /// Emphasized body link text style.
  ///
  /// Uses semibold weight, md font size, and normal line height.
  final TextStyle bodyLinkEmphasis;

  /// Default caption text style.
  ///
  /// Uses regular weight, sm font size, and tight line height.
  final TextStyle captionDefault;

  /// Emphasized caption text style.
  ///
  /// Uses semibold weight, sm font size, and tight line height.
  final TextStyle captionEmphasis;

  /// Caption link text style.
  ///
  /// Uses regular weight, sm font size, and tight line height.
  final TextStyle captionLink;

  /// Emphasized caption link text style.
  ///
  /// Uses semibold weight, sm font size, and tight line height.
  final TextStyle captionLinkEmphasis;

  /// Default metadata text style.
  ///
  /// Uses regular weight, xs font size, and tight line height.
  final TextStyle metadataDefault;

  /// Emphasized metadata text style.
  ///
  /// Uses semibold weight, xs font size, and tight line height.
  final TextStyle metadataEmphasis;

  /// Metadata link text style.
  ///
  /// Uses regular weight, xs font size, and tight line height.
  final TextStyle metadataLink;

  /// Emphasized metadata link text style.
  ///
  /// Uses semibold weight, xs font size, and tight line height.
  final TextStyle metadataLinkEmphasis;

  /// Large numeric text style.
  ///
  /// Uses bold weight and xs font size. Optimized for displaying numbers.
  final TextStyle numericLg;

  /// Medium numeric text style.
  ///
  /// Uses bold weight and xxs font size. Optimized for displaying numbers.
  final TextStyle numericMd;

  /// Small numeric text style.
  ///
  /// Uses bold weight and micro font size. Optimized for displaying numbers.
  final TextStyle numericSm;

  /// Linearly interpolates between this and another [StreamTextTheme].
  StreamTextTheme lerp(StreamTextTheme? other, double t) {
    return _$StreamTextTheme.lerp(this, other, t)!;
  }

  /// Creates a copy of this text theme but with the given fields replaced with
  /// the new values.
  ///
  /// The [heightFactor] applies a multiplier to all line heights.
  /// The [heightDelta] adds a fixed amount to all line heights after the factor.
  /// The [fontSizeFactor] applies a multiplier to all font sizes.
  /// The [fontSizeDelta] adds a fixed amount to all font sizes after the factor.
  ///
  /// {@tool snippet}
  ///
  /// Apply a color and font family to all text styles:
  ///
  /// ```dart
  /// final textTheme = StreamTextTheme();
  /// final themed = textTheme.apply(
  ///   color: Colors.blue,
  ///   fontFamily: 'Roboto',
  /// );
  /// ```
  /// {@end-tool}
  StreamTextTheme apply({
    Color? color,
    String? package,
    String? fontFamily,
    List<String>? fontFamilyFallback,
    double heightFactor = 1.0,
    double heightDelta = 0.0,
    double fontSizeFactor = 1.0,
    double fontSizeDelta = 0.0,
    TextDecoration? decoration,
  }) => StreamTextTheme.raw(
    headingLg: headingLg.apply(
      color: color,
      package: package,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      heightFactor: heightFactor,
      heightDelta: heightDelta,
      fontSizeFactor: fontSizeFactor,
      fontSizeDelta: fontSizeDelta,
      decoration: decoration,
    ),
    headingMd: headingMd.apply(
      color: color,
      package: package,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      heightFactor: heightFactor,
      heightDelta: heightDelta,
      fontSizeFactor: fontSizeFactor,
      fontSizeDelta: fontSizeDelta,
      decoration: decoration,
    ),
    headingSm: headingSm.apply(
      color: color,
      package: package,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      heightFactor: heightFactor,
      heightDelta: heightDelta,
      fontSizeFactor: fontSizeFactor,
      fontSizeDelta: fontSizeDelta,
      decoration: decoration,
    ),
    bodyDefault: bodyDefault.apply(
      color: color,
      package: package,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      heightFactor: heightFactor,
      heightDelta: heightDelta,
      fontSizeFactor: fontSizeFactor,
      fontSizeDelta: fontSizeDelta,
      decoration: decoration,
    ),
    bodyEmphasis: bodyEmphasis.apply(
      color: color,
      package: package,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      heightFactor: heightFactor,
      heightDelta: heightDelta,
      fontSizeFactor: fontSizeFactor,
      fontSizeDelta: fontSizeDelta,
      decoration: decoration,
    ),
    bodyLink: bodyLink.apply(
      color: color,
      package: package,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      heightFactor: heightFactor,
      heightDelta: heightDelta,
      fontSizeFactor: fontSizeFactor,
      fontSizeDelta: fontSizeDelta,
      decoration: decoration,
    ),
    bodyLinkEmphasis: bodyLinkEmphasis.apply(
      color: color,
      package: package,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      heightFactor: heightFactor,
      heightDelta: heightDelta,
      fontSizeFactor: fontSizeFactor,
      fontSizeDelta: fontSizeDelta,
      decoration: decoration,
    ),
    captionDefault: captionDefault.apply(
      color: color,
      package: package,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      heightFactor: heightFactor,
      heightDelta: heightDelta,
      fontSizeFactor: fontSizeFactor,
      fontSizeDelta: fontSizeDelta,
      decoration: decoration,
    ),
    captionEmphasis: captionEmphasis.apply(
      color: color,
      package: package,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      heightFactor: heightFactor,
      heightDelta: heightDelta,
      fontSizeFactor: fontSizeFactor,
      fontSizeDelta: fontSizeDelta,
      decoration: decoration,
    ),
    captionLink: captionLink.apply(
      color: color,
      package: package,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      heightFactor: heightFactor,
      heightDelta: heightDelta,
      fontSizeFactor: fontSizeFactor,
      fontSizeDelta: fontSizeDelta,
      decoration: decoration,
    ),
    captionLinkEmphasis: captionLinkEmphasis.apply(
      color: color,
      package: package,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      heightFactor: heightFactor,
      heightDelta: heightDelta,
      fontSizeFactor: fontSizeFactor,
      fontSizeDelta: fontSizeDelta,
      decoration: decoration,
    ),
    metadataDefault: metadataDefault.apply(
      color: color,
      package: package,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      heightFactor: heightFactor,
      heightDelta: heightDelta,
      fontSizeFactor: fontSizeFactor,
      fontSizeDelta: fontSizeDelta,
      decoration: decoration,
    ),
    metadataEmphasis: metadataEmphasis.apply(
      color: color,
      package: package,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      heightFactor: heightFactor,
      heightDelta: heightDelta,
      fontSizeFactor: fontSizeFactor,
      fontSizeDelta: fontSizeDelta,
      decoration: decoration,
    ),
    metadataLink: metadataLink.apply(
      color: color,
      package: package,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      heightFactor: heightFactor,
      heightDelta: heightDelta,
      fontSizeFactor: fontSizeFactor,
      fontSizeDelta: fontSizeDelta,
      decoration: decoration,
    ),
    metadataLinkEmphasis: metadataLinkEmphasis.apply(
      color: color,
      package: package,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      heightFactor: heightFactor,
      heightDelta: heightDelta,
      fontSizeFactor: fontSizeFactor,
      fontSizeDelta: fontSizeDelta,
      decoration: decoration,
    ),
    numericLg: numericLg.apply(
      color: color,
      package: package,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      heightFactor: heightFactor,
      heightDelta: heightDelta,
      fontSizeFactor: fontSizeFactor,
      fontSizeDelta: fontSizeDelta,
      decoration: decoration,
    ),
    numericMd: numericMd.apply(
      color: color,
      package: package,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      heightFactor: heightFactor,
      heightDelta: heightDelta,
      fontSizeFactor: fontSizeFactor,
      fontSizeDelta: fontSizeDelta,
      decoration: decoration,
    ),
    numericSm: numericSm.apply(
      color: color,
      package: package,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      heightFactor: heightFactor,
      heightDelta: heightDelta,
      fontSizeFactor: fontSizeFactor,
      fontSizeDelta: fontSizeDelta,
      decoration: decoration,
    ),
  );
}
