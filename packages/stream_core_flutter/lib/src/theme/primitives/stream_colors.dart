import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'stream_color_swatch_helper.dart';
import 'tokens/light/stream_tokens.dart' as tokens;

/// [Color] and [ColorSwatch] constants for the Stream design system.
///
/// Most swatches have colors from 50 to 900. The smaller the number, the more
/// pale the color. The greater the number, the darker the color. Shades 50-450
/// are incremented by 50, and shades 500-900 are incremented by 100.
///
/// In addition, a series of blacks and whites with common opacities are
/// available. For example, [white70] is a pure white with 70% opacity.
///
/// {@tool snippet}
///
/// To select a specific color from one of the swatches, index into the swatch
/// using an integer for the specific color desired, as follows:
///
/// ```dart
/// Color selection = StreamColors.blue[400]!; // Selects a mid-range blue.
/// ```
/// {@end-tool}
/// {@tool snippet}
///
/// Each [ColorSwatch] constant is a color and can used directly. For example:
///
/// ```dart
/// Container(
///   // same as StreamColors.blue[500] or StreamColors.blue.shade500
///   color: StreamColors.blue,
/// )
/// ```
/// {@end-tool}
abstract final class StreamColors {
  const StreamColors._();

  /// The fully transparent color.
  static const transparent = tokens.StreamTokens.baseTransparent0;

  /// The pure white color.
  static const white = tokens.StreamTokens.baseWhite;

  /// The white color with 10% opacity.
  static const white10 = tokens.StreamTokens.baseTransparentWhite10;

  /// The white color with 20% opacity.
  static const white20 = tokens.StreamTokens.baseTransparentWhite20;

  /// The white color with 50% opacity.
  static const white50 = Color(0x80FFFFFF);

  /// The white color with 70% opacity.
  static const white70 = tokens.StreamTokens.baseTransparentWhite70;

  /// The pure black color.
  static const black = tokens.StreamTokens.baseBlack;

  /// The black color with 5% opacity.
  static const black5 = tokens.StreamTokens.baseTransparentBlack5;

  /// The black color with 10% opacity.
  static const black10 = tokens.StreamTokens.baseTransparentBlack10;

  /// The black color with 50% opacity.
  static const black50 = Color(0x80000000);

  /// The slate color swatch.
  static final slate = StreamColorSwatch(
    _slatePrimaryValue.toARGB32(),
    const <int, Color>{
      50: tokens.StreamTokens.slate50,
      100: tokens.StreamTokens.slate100,
      150: tokens.StreamTokens.slate150,
      200: tokens.StreamTokens.slate200,
      300: tokens.StreamTokens.slate300,
      400: tokens.StreamTokens.slate400,
      500: tokens.StreamTokens.slate500,
      600: tokens.StreamTokens.slate600,
      700: tokens.StreamTokens.slate700,
      800: tokens.StreamTokens.slate800,
      900: tokens.StreamTokens.slate900,
    },
  );
  static const _slatePrimaryValue = tokens.StreamTokens.slate500;

  /// The neutral color swatch.
  static final neutral = StreamColorSwatch(
    _neutralPrimaryValue.toARGB32(),
    const <int, Color>{
      50: tokens.StreamTokens.neutral50,
      100: tokens.StreamTokens.neutral100,
      150: tokens.StreamTokens.neutral150,
      200: tokens.StreamTokens.neutral200,
      300: tokens.StreamTokens.neutral300,
      400: tokens.StreamTokens.neutral400,
      500: tokens.StreamTokens.neutral500,
      600: tokens.StreamTokens.neutral600,
      700: tokens.StreamTokens.neutral700,
      800: tokens.StreamTokens.neutral800,
      900: tokens.StreamTokens.neutral900,
    },
  );
  static const _neutralPrimaryValue = tokens.StreamTokens.neutral500;

  /// The blue color swatch.
  static final blue = StreamColorSwatch(
    _bluePrimaryValue.toARGB32(),
    const <int, Color>{
      50: tokens.StreamTokens.blue50,
      100: tokens.StreamTokens.blue100,
      150: tokens.StreamTokens.blue150,
      200: tokens.StreamTokens.blue200,
      300: tokens.StreamTokens.blue300,
      400: tokens.StreamTokens.blue400,
      500: tokens.StreamTokens.blue500,
      600: tokens.StreamTokens.blue600,
      700: tokens.StreamTokens.blue700,
      800: tokens.StreamTokens.blue800,
      900: tokens.StreamTokens.blue900,
    },
  );
  static const _bluePrimaryValue = tokens.StreamTokens.blue500;

  /// The cyan color swatch.
  static final cyan = StreamColorSwatch(
    _cyanPrimaryValue.toARGB32(),
    const <int, Color>{
      50: tokens.StreamTokens.cyan50,
      100: tokens.StreamTokens.cyan100,
      150: tokens.StreamTokens.cyan150,
      200: tokens.StreamTokens.cyan200,
      300: tokens.StreamTokens.cyan300,
      400: tokens.StreamTokens.cyan400,
      500: tokens.StreamTokens.cyan500,
      600: tokens.StreamTokens.cyan600,
      700: tokens.StreamTokens.cyan700,
      800: tokens.StreamTokens.cyan800,
      900: tokens.StreamTokens.cyan900,
    },
  );
  static const _cyanPrimaryValue = tokens.StreamTokens.cyan500;

  /// The green color swatch.
  static final green = StreamColorSwatch(
    _greenPrimaryValue.toARGB32(),
    const <int, Color>{
      50: tokens.StreamTokens.green50,
      100: tokens.StreamTokens.green100,
      150: tokens.StreamTokens.green150,
      200: tokens.StreamTokens.green200,
      300: tokens.StreamTokens.green300,
      400: tokens.StreamTokens.green400,
      500: tokens.StreamTokens.green500,
      600: tokens.StreamTokens.green600,
      700: tokens.StreamTokens.green700,
      800: tokens.StreamTokens.green800,
      900: tokens.StreamTokens.green900,
    },
  );
  static const _greenPrimaryValue = tokens.StreamTokens.green500;

  /// The purple color swatch.
  static final purple = StreamColorSwatch(
    _purplePrimaryValue.toARGB32(),
    const <int, Color>{
      50: tokens.StreamTokens.purple50,
      100: tokens.StreamTokens.purple100,
      150: tokens.StreamTokens.purple150,
      200: tokens.StreamTokens.purple200,
      300: tokens.StreamTokens.purple300,
      400: tokens.StreamTokens.purple400,
      500: tokens.StreamTokens.purple500,
      600: tokens.StreamTokens.purple600,
      700: tokens.StreamTokens.purple700,
      800: tokens.StreamTokens.purple800,
      900: tokens.StreamTokens.purple900,
    },
  );
  static const _purplePrimaryValue = tokens.StreamTokens.purple500;

  /// The yellow color swatch.
  static final yellow = StreamColorSwatch(
    _yellowPrimaryValue.toARGB32(),
    const <int, Color>{
      50: tokens.StreamTokens.yellow50,
      100: tokens.StreamTokens.yellow100,
      150: tokens.StreamTokens.yellow150,
      200: tokens.StreamTokens.yellow200,
      300: tokens.StreamTokens.yellow300,
      400: tokens.StreamTokens.yellow400,
      500: tokens.StreamTokens.yellow500,
      600: tokens.StreamTokens.yellow600,
      700: tokens.StreamTokens.yellow700,
      800: tokens.StreamTokens.yellow800,
      900: tokens.StreamTokens.yellow900,
    },
  );
  static const _yellowPrimaryValue = tokens.StreamTokens.yellow500;

  /// The red color swatch.
  static final red = StreamColorSwatch(
    _redPrimaryValue.toARGB32(),
    const <int, Color>{
      50: tokens.StreamTokens.red50,
      100: tokens.StreamTokens.red100,
      150: tokens.StreamTokens.red150,
      200: tokens.StreamTokens.red200,
      300: tokens.StreamTokens.red300,
      400: tokens.StreamTokens.red400,
      500: tokens.StreamTokens.red500,
      600: tokens.StreamTokens.red600,
      700: tokens.StreamTokens.red700,
      800: tokens.StreamTokens.red800,
      900: tokens.StreamTokens.red900,
    },
  );
  static const _redPrimaryValue = tokens.StreamTokens.red500;

  /// The violet color swatch.
  static final violet = StreamColorSwatch(
    _violetPrimaryValue.toARGB32(),
    const <int, Color>{
      50: tokens.StreamTokens.violet50,
      100: tokens.StreamTokens.violet100,
      150: tokens.StreamTokens.violet150,
      200: tokens.StreamTokens.violet200,
      300: tokens.StreamTokens.violet300,
      400: tokens.StreamTokens.violet400,
      500: tokens.StreamTokens.violet500,
      600: tokens.StreamTokens.violet600,
      700: tokens.StreamTokens.violet700,
      800: tokens.StreamTokens.violet800,
      900: tokens.StreamTokens.violet900,
    },
  );
  static const _violetPrimaryValue = tokens.StreamTokens.violet500;

  /// The lime color swatch.
  static final lime = StreamColorSwatch(
    _limePrimaryValue.toARGB32(),
    const <int, Color>{
      50: tokens.StreamTokens.lime50,
      100: tokens.StreamTokens.lime100,
      150: tokens.StreamTokens.lime150,
      200: tokens.StreamTokens.lime200,
      300: tokens.StreamTokens.lime300,
      400: tokens.StreamTokens.lime400,
      500: tokens.StreamTokens.lime500,
      600: tokens.StreamTokens.lime600,
      700: tokens.StreamTokens.lime700,
      800: tokens.StreamTokens.lime800,
      900: tokens.StreamTokens.lime900,
    },
  );
  static const _limePrimaryValue = tokens.StreamTokens.lime500;
}

/// A color swatch with multiple shades of a single color.
///
/// See also:
///
///  * [StreamColors], which defines all of the standard swatch colors.
@immutable
class StreamColorSwatch extends ColorSwatch<int> {
  const StreamColorSwatch(super.primary, super._swatch);

  factory StreamColorSwatch.fromColor(Color color, {Brightness brightness = Brightness.light}) {
    return StreamColorSwatch(
      color.toARGB32(),
      StreamColorSwatchHelper.generateShadeMap(color, brightness: brightness),
    );
  }

  /// The lightest shade.
  Color get shade50 => this[50]!;

  /// The second lightest shade.
  Color get shade100 => this[100]!;

  /// The shade between 100 and 200.
  Color get shade150 => this[150]!;

  /// The third lightest shade.
  Color get shade200 => this[200]!;

  /// The fourth lightest shade.
  Color get shade300 => this[300]!;

  /// The fifth lightest shade.
  Color get shade400 => this[400]!;

  /// The default shade.
  Color get shade500 => this[500]!;

  /// The fourth darkest shade.
  Color get shade600 => this[600]!;

  /// The third darkest shade.
  Color get shade700 => this[700]!;

  /// The second darkest shade.
  Color get shade800 => this[800]!;

  /// The second shade.
  Color get shade900 => this[900]!;
}
