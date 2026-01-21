// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import 'components/stream_avatar_theme.dart';
import 'components/stream_button_theme.dart';
import 'components/stream_online_indicator_theme.dart';
import 'primitives/stream_radius.dart';
import 'primitives/stream_spacing.dart';
import 'primitives/stream_typography.dart';
import 'semantics/stream_box_shadow.dart';
import 'semantics/stream_color_scheme.dart';
import 'semantics/stream_text_theme.dart';

part 'stream_theme.g.theme.dart';

/// The main theme configuration for Stream design system.
///
/// [StreamTheme] aggregates all design tokens and component themes into a
/// single theme object. It supports light, dark, and high contrast modes
/// with platform-aware defaults.
///
/// {@tool snippet}
///
/// Create a light theme:
///
/// ```dart
/// final theme = StreamTheme.light();
/// final primaryColor = theme.colorScheme.brand.shade500;
/// final spacing = theme.spacing.md;
/// ```
/// {@end-tool}
/// {@tool snippet}
///
/// Create a theme based on brightness:
///
/// ```dart
/// final theme = StreamTheme(brightness: Brightness.dark);
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamColorScheme], which defines semantic colors.
///  * [StreamTypography], which defines typography primitives.
///  * [StreamTextTheme], which defines semantic text styles.
///  * [StreamRadius], which defines border radius values.
///  * [StreamSpacing], which defines spacing values.
///  * [StreamBoxShadow], which defines elevation shadows.
///  * [StreamButtonThemeData], which defines button styles.
///  * [StreamAvatarThemeData], which defines avatar styles.
@immutable
@ThemeExtensions(constructor: 'raw', buildContextExtension: false)
class StreamTheme extends ThemeExtension<StreamTheme> with _$StreamTheme {
  /// Creates a theme configuration.
  ///
  /// The theme is configured based on the given [brightness]. If [brightness]
  /// is not provided, it defaults to [Brightness.light].
  ///
  /// The [platform] parameter affects platform-specific defaults for
  /// typography and radius. If not provided, it defaults to
  /// [defaultTargetPlatform].
  ///
  /// If [typography] is provided, it will be used to build [textTheme].
  ///
  /// See also:
  ///
  ///  * [StreamTheme.light], which creates a light theme.
  ///  * [StreamTheme.dark], which creates a dark theme.
  factory StreamTheme({
    Brightness brightness = .light,
    TargetPlatform? platform,
    StreamRadius? radius,
    StreamSpacing? spacing,
    StreamTypography? typography,
    StreamColorScheme? colorScheme,
    StreamTextTheme? textTheme,
    StreamBoxShadow? boxShadow,
    // Components themes
    StreamButtonThemeData? buttonTheme,
    StreamAvatarThemeData? avatarTheme,
    StreamOnlineIndicatorThemeData? onlineIndicatorTheme,
  }) {
    platform ??= defaultTargetPlatform;
    final isDark = brightness == Brightness.dark;

    // Primitives
    radius ??= StreamRadius(platform: platform);
    spacing ??= const StreamSpacing();
    typography ??= StreamTypography(platform: platform);

    // Semantics
    colorScheme ??= isDark ? StreamColorScheme.dark() : StreamColorScheme.light();
    textTheme ??= StreamTextTheme(typography: typography).apply(color: colorScheme.systemText);
    boxShadow ??= isDark ? StreamBoxShadow.dark() : StreamBoxShadow.light();

    // Components
    buttonTheme ??= const StreamButtonThemeData();
    avatarTheme ??= const StreamAvatarThemeData();
    onlineIndicatorTheme ??= const StreamOnlineIndicatorThemeData();

    return .raw(
      brightness: brightness,
      radius: radius,
      spacing: spacing,
      typography: typography,
      colorScheme: colorScheme,
      textTheme: textTheme,
      boxShadow: boxShadow,
      buttonTheme: buttonTheme,
      avatarTheme: avatarTheme,
      onlineIndicatorTheme: onlineIndicatorTheme,
    );
  }

  /// Creates a dark theme configuration.
  ///
  /// This is a convenience factory that calls [StreamTheme] with
  /// [Brightness.dark].
  factory StreamTheme.dark() => StreamTheme(brightness: .dark);

  /// Creates a light theme configuration.
  ///
  /// This is a convenience factory that calls [StreamTheme] with
  /// [Brightness.light].
  factory StreamTheme.light() => StreamTheme(brightness: .light);

  const StreamTheme.raw({
    required this.brightness,
    required this.radius,
    required this.spacing,
    required this.typography,
    required this.colorScheme,
    required this.textTheme,
    required this.boxShadow,
    required this.buttonTheme,
    required this.avatarTheme,
    required this.onlineIndicatorTheme,
  });

  /// Returns the [StreamTheme] from the closest [Theme] ancestor.
  ///
  /// If no [StreamTheme] is found in the widget tree, a default theme is
  /// returned based on the current [Theme]'s brightness (light or dark).
  ///
  /// {@tool snippet}
  ///
  /// Access the theme in a widget:
  ///
  /// ```dart
  /// @override
  /// Widget build(BuildContext context) {
  ///   final theme = StreamTheme.of(context);
  ///   return Container(
  ///     color: theme.colorScheme.backgroundPrimary,
  ///     padding: EdgeInsets.all(theme.spacing.md),
  ///     child: Text('Hello', style: theme.textTheme.bodyDefault),
  ///   );
  /// }
  /// ```
  /// {@end-tool}
  static StreamTheme of(BuildContext context) {
    final theme = Theme.of(context);
    final streamTheme = theme.extension<StreamTheme>();
    if (streamTheme != null) return streamTheme;

    return StreamTheme(brightness: theme.brightness);
  }

  /// The brightness of this theme.
  final Brightness brightness;

  /// The border radius values for this theme.
  final StreamRadius radius;

  /// The spacing values for this theme.
  final StreamSpacing spacing;

  /// The typography primitives for this theme.
  ///
  /// Contains font sizes, line heights, and font weights.
  /// Used to build [textTheme].
  final StreamTypography typography;

  /// The color scheme for this theme.
  final StreamColorScheme colorScheme;

  /// The semantic text theme for this theme.
  ///
  /// Built from [typography] primitives.
  final StreamTextTheme textTheme;

  /// The box shadow (elevation) values for this theme.
  final StreamBoxShadow boxShadow;

  /// The button theme for this theme.
  final StreamButtonThemeData buttonTheme;

  /// The avatar theme for this theme.
  final StreamAvatarThemeData avatarTheme;

  /// The online indicator theme for this theme.
  final StreamOnlineIndicatorThemeData onlineIndicatorTheme;
}
