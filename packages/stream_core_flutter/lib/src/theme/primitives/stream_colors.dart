import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'stream_color_swatch_helper.dart';

/// [Color] and [ColorSwatch] constants for the Stream design system.
///
/// Most swatches have colors from 50 to 950. The smaller the number, the more
/// pale the color. The greater the number, the darker the color. Shades 50-450
/// are incremented by 50, and shades 500-950 are incremented by 100 or 50 for
/// the darkest shade (950).
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
  static const transparent = Color(0x00000000);

  /// The pure white color.
  static const white = Color(0xFFFFFFFF);

  /// The white color with 10% opacity.
  static const white10 = Color(0x1AFFFFFF);

  /// The white color with 20% opacity.
  static const white20 = Color(0x33FFFFFF);

  /// The white color with 50% opacity.
  static const white50 = Color(0x80FFFFFF);

  /// The white color with 70% opacity.
  static const white70 = Color(0xB3FFFFFF);

  /// The pure black color.
  static const black = Color(0xFF000000);

  /// The black color with 5% opacity.
  static const black5 = Color(0x0D000000);

  /// The black color with 10% opacity.
  static const black10 = Color(0x1A000000);

  /// The black color with 50% opacity.
  static const black50 = Color(0x80000000);

  /// The slate color swatch.
  static const slate = StreamColorSwatch(
    _slatePrimaryValue,
    <int, Color>{
      50: Color(0xFFFAFBFC),
      100: Color(0xFFF2F4F6),
      200: Color(0xFFE2E6EA),
      300: Color(0xFFD0D5DA),
      400: Color(0xFFB8BEC4),
      500: Color(_slatePrimaryValue),
      600: Color(0xFF838990),
      700: Color(0xFF6A7077),
      800: Color(0xFF50565D),
      900: Color(0xFF384047),
      950: Color(0xFF1E252B),
    },
  );
  static const _slatePrimaryValue = 0xFF9EA4AA;

  /// The neutral color swatch.
  static const neutral = StreamColorSwatch(
    _neutralPrimaryValue,
    <int, Color>{
      50: Color(0xFFF7F7F7),
      100: Color(0xFFEDEDED),
      200: Color(0xFFD9D9D9),
      300: Color(0xFFC1C1C1),
      400: Color(0xFFA3A3A3),
      500: Color(_neutralPrimaryValue),
      600: Color(0xFF636363),
      700: Color(0xFF4A4A4A),
      800: Color(0xFF383838),
      900: Color(0xFF262626),
      950: Color(0xFF151515),
    },
  );
  static const _neutralPrimaryValue = 0xFF7F7F7F;

  /// The blue color swatch.
  static const blue = StreamColorSwatch(
    _bluePrimaryValue,
    <int, Color>{
      50: Color(0xFFEBF3FF),
      100: Color(0xFFD2E3FF),
      200: Color(0xFFA6C4FF),
      300: Color(0xFF7AA7FF),
      400: Color(0xFF4E8BFF),
      500: Color(_bluePrimaryValue),
      600: Color(0xFF0052CE),
      700: Color(0xFF0042A3),
      800: Color(0xFF003179),
      900: Color(0xFF001F4F),
      950: Color(0xFF001025),
    },
  );
  static const _bluePrimaryValue = 0xFF005FFF;

  /// The cyan color swatch.
  static const cyan = StreamColorSwatch(
    _cyanPrimaryValue,
    <int, Color>{
      50: Color(0xFFF0FCFE),
      100: Color(0xFFD7F7FB),
      200: Color(0xFFBDF1F8),
      300: Color(0xFFA3ECF4),
      400: Color(0xFF89E6F1),
      500: Color(_cyanPrimaryValue),
      600: Color(0xFF3EC9D9),
      700: Color(0xFF28A8B5),
      800: Color(0xFF1C8791),
      900: Color(0xFF125F66),
      950: Color(0xFF0B3D44),
    },
  );
  static const _cyanPrimaryValue = 0xFF69E5F6;

  /// The green color swatch.
  static const green = StreamColorSwatch(
    _greenPrimaryValue,
    <int, Color>{
      50: Color(0xFFE8FFF5),
      100: Color(0xFFC9FCE7),
      200: Color(0xFFA9F8D9),
      300: Color(0xFF88F2CA),
      400: Color(0xFF59E9B5),
      500: Color(_greenPrimaryValue),
      600: Color(0xFF00B681),
      700: Color(0xFF008D64),
      800: Color(0xFF006548),
      900: Color(0xFF003D2B),
      950: Color(0xFF002319),
    },
  );
  static const _greenPrimaryValue = 0xFF00E2A1;

  /// The purple color swatch.
  static const purple = StreamColorSwatch(
    _purplePrimaryValue,
    <int, Color>{
      50: Color(0xFFF5EFFE),
      100: Color(0xFFEBDEFD),
      200: Color(0xFFD8BFFC),
      300: Color(0xFFC79FFC),
      400: Color(0xFFB98AF9),
      500: Color(_purplePrimaryValue),
      600: Color(0xFF996CE3),
      700: Color(0xFF7F55C7),
      800: Color(0xFF6640AB),
      900: Color(0xFF4D2C8F),
      950: Color(0xFF351C6B),
    },
  );
  static const _purplePrimaryValue = 0xFFB38AF8;

  /// The yellow color swatch.
  static const yellow = StreamColorSwatch(
    _yellowPrimaryValue,
    <int, Color>{
      50: Color(0xFFFFF9E5),
      100: Color(0xFFFFF1C2),
      200: Color(0xFFFFE8A0),
      300: Color(0xFFFFDE7D),
      400: Color(0xFFFFD65A),
      500: Color(_yellowPrimaryValue),
      600: Color(0xFFE6B400),
      700: Color(0xFFC59600),
      800: Color(0xFF9F7700),
      900: Color(0xFF7A5A00),
      950: Color(0xFF4F3900),
    },
  );
  static const _yellowPrimaryValue = 0xFFFFD233;

  /// The red color swatch.
  static const red = StreamColorSwatch(
    _redPrimaryValue,
    <int, Color>{
      50: Color(0xFFFCEBEA),
      100: Color(0xFFF8CFCD),
      200: Color(0xFFF3B3B0),
      300: Color(0xFFED958F),
      400: Color(0xFFE6756C),
      500: Color(_redPrimaryValue),
      600: Color(0xFFB9261F),
      700: Color(0xFF98201A),
      800: Color(0xFF761915),
      900: Color(0xFF54120F),
      950: Color(0xFF360B09),
    },
  );
  static const _redPrimaryValue = 0xFFD92F26;
}

/// A color swatch with multiple shades of a single color.
///
/// See also:
///
///  * [StreamColors], which defines all of the standard swatch colors.
@immutable
class StreamColorSwatch extends ColorSwatch<int> {
  const StreamColorSwatch(super.primary, super._swatch);

  factory StreamColorSwatch.fromColor(Color color) {
    return StreamColorSwatch(color.toARGB32(), StreamColorSwatchHelper.generateShadeMap(color));
  }

  /// The lightest shade.
  Color get shade50 => this[50]!;

  /// The second lightest shade.
  Color get shade100 => this[100]!;

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

  /// The darkest shade.
  Color get shade950 => this[950]!;
}
