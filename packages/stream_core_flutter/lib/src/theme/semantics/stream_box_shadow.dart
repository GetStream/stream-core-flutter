// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'stream_box_shadow.g.theme.dart';

/// Box shadow tokens for the Stream design system.
///
/// [StreamBoxShadow] provides consistent box shadow values for creating
/// depth and visual hierarchy. Each elevation level represents a different
/// degree of surface separation.
///
/// - [elevation1]: Low elevation for subtle separation
/// - [elevation2]: Medium-low elevation
/// - [elevation3]: Medium-high elevation
/// - [elevation4]: High elevation for prominent elements
///
/// For no shadow (elevation 0), simply don't apply any box shadow.
///
/// {@tool snippet}
///
/// Create a light theme box shadow and apply to a container:
///
/// ```dart
/// final boxShadow = StreamBoxShadow.light();
/// Container(
///   decoration: BoxDecoration(
///     boxShadow: boxShadow.elevation2,
///   ),
/// );
/// ```
/// {@end-tool}
@immutable
@ThemeGen(constructor: 'raw')
class StreamBoxShadow with _$StreamBoxShadow {
  /// Creates a light theme box shadow configuration.
  ///
  /// Light theme shadows use lower opacity values for a softer appearance
  /// on light backgrounds.
  factory StreamBoxShadow.light({
    List<BoxShadow>? elevation1,
    List<BoxShadow>? elevation2,
    List<BoxShadow>? elevation3,
    List<BoxShadow>? elevation4,
  }) {
    elevation1 ??= [
      const BoxShadow(
        offset: Offset(0, 1),
        blurRadius: 2,
        spreadRadius: 0,
        color: Color.fromRGBO(0, 0, 0, 0.1),
      ),
      const BoxShadow(
        offset: Offset(0, 4),
        blurRadius: 8,
        spreadRadius: 0,
        color: Color.fromRGBO(0, 0, 0, 0.06),
      ),
    ];
    elevation2 ??= [
      const BoxShadow(
        offset: Offset(0, 2),
        blurRadius: 4,
        spreadRadius: 0,
        color: Color.fromRGBO(0, 0, 0, 0.12),
      ),
      const BoxShadow(
        offset: Offset(0, 6),
        blurRadius: 16,
        spreadRadius: 0,
        color: Color.fromRGBO(0, 0, 0, 0.06),
      ),
    ];
    elevation3 ??= [
      const BoxShadow(
        offset: Offset(0, 4),
        blurRadius: 8,
        spreadRadius: 0,
        color: Color.fromRGBO(0, 0, 0, 0.14),
      ),
      const BoxShadow(
        offset: Offset(0, 12),
        blurRadius: 24,
        spreadRadius: 0,
        color: Color.fromRGBO(0, 0, 0, 0.1),
      ),
    ];
    elevation4 ??= [
      const BoxShadow(
        offset: Offset(0, 6),
        blurRadius: 12,
        spreadRadius: 0,
        color: Color.fromRGBO(0, 0, 0, 0.16),
      ),
      const BoxShadow(
        offset: Offset(0, 20),
        blurRadius: 32,
        spreadRadius: 0,
        color: Color.fromRGBO(0, 0, 0, 0.12),
      ),
    ];

    return .raw(
      elevation1: elevation1,
      elevation2: elevation2,
      elevation3: elevation3,
      elevation4: elevation4,
    );
  }

  /// Creates a dark theme box shadow configuration.
  ///
  /// Dark theme shadows use higher opacity values for visibility
  /// on dark backgrounds.
  factory StreamBoxShadow.dark({
    List<BoxShadow>? elevation1,
    List<BoxShadow>? elevation2,
    List<BoxShadow>? elevation3,
    List<BoxShadow>? elevation4,
  }) {
    elevation1 ??= [
      const BoxShadow(
        offset: Offset(0, 1),
        blurRadius: 2,
        spreadRadius: 0,
        color: Color.fromRGBO(0, 0, 0, 0.2),
      ),
      const BoxShadow(
        offset: Offset(0, 4),
        blurRadius: 8,
        spreadRadius: 0,
        color: Color.fromRGBO(0, 0, 0, 0.1),
      ),
    ];
    elevation2 ??= [
      const BoxShadow(
        offset: Offset(0, 2),
        blurRadius: 4,
        spreadRadius: 0,
        color: Color.fromRGBO(0, 0, 0, 0.22),
      ),
      const BoxShadow(
        offset: Offset(0, 6),
        blurRadius: 16,
        spreadRadius: 0,
        color: Color.fromRGBO(0, 0, 0, 0.12),
      ),
    ];
    elevation3 ??= [
      const BoxShadow(
        offset: Offset(0, 4),
        blurRadius: 8,
        spreadRadius: 0,
        color: Color.fromRGBO(0, 0, 0, 0.24),
      ),
      const BoxShadow(
        offset: Offset(0, 12),
        blurRadius: 24,
        spreadRadius: 0,
        color: Color.fromRGBO(0, 0, 0, 0.14),
      ),
    ];
    elevation4 ??= [
      const BoxShadow(
        offset: Offset(0, 6),
        blurRadius: 12,
        spreadRadius: 0,
        color: Color.fromRGBO(0, 0, 0, 0.28),
      ),
      const BoxShadow(
        offset: Offset(0, 20),
        blurRadius: 32,
        spreadRadius: 0,
        color: Color.fromRGBO(0, 0, 0, 0.16),
      ),
    ];

    return .raw(
      elevation1: elevation1,
      elevation2: elevation2,
      elevation3: elevation3,
      elevation4: elevation4,
    );
  }

  /// Creates a [StreamBoxShadow] with the given values.
  const StreamBoxShadow.raw({
    required this.elevation1,
    required this.elevation2,
    required this.elevation3,
    required this.elevation4,
  });

  /// Low elevation level for subtle separation.
  ///
  /// Used for cards, list items, and subtle surface distinctions.
  final List<BoxShadow> elevation1;

  /// Medium-low elevation level.
  ///
  /// Used for raised buttons, search bars, and interactive elements.
  final List<BoxShadow> elevation2;

  /// Medium-high elevation level.
  ///
  /// Used for navigation drawers, bottom sheets, and menus.
  final List<BoxShadow> elevation3;

  /// High elevation level for prominent elements.
  ///
  /// Used for dialogs, modals, and floating action buttons.
  final List<BoxShadow> elevation4;

  /// Linearly interpolates between two [StreamBoxShadow] instances.
  static StreamBoxShadow? lerp(
    StreamBoxShadow? a,
    StreamBoxShadow? b,
    double t,
  ) => _$StreamBoxShadow.lerp(a, b, t);
}
