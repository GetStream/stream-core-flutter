import 'package:flutter/widgets.dart';

import 'components/stream_avatar_theme.dart';
import 'components/stream_online_indicator_theme.dart';
import 'primitives/stream_radius.dart';
import 'primitives/stream_spacing.dart';
import 'primitives/stream_typography.dart';
import 'semantics/stream_box_shadow.dart';
import 'semantics/stream_color_scheme.dart';
import 'semantics/stream_text_theme.dart';
import 'stream_icon.dart';
import 'stream_theme.dart';

/// Extension on [BuildContext] for convenient access to [StreamTheme].
///
/// {@tool snippet}
///
/// Access theme properties directly from context:
///
/// ```dart
/// @override
/// Widget build(BuildContext context) {
///   return Container(
///     color: context.streamColorScheme.backgroundPrimary,
///     padding: EdgeInsets.all(context.streamSpacing.md),
///     child: Text('Hello', style: context.streamTextTheme.bodyDefault),
///   );
/// }
/// ```
/// {@end-tool}
extension StreamThemeExtension on BuildContext {
  /// Returns the [StreamTheme] from the closest ancestor.
  ///
  /// If no [StreamTheme] is found, returns a default theme based on
  /// the current [Theme]'s brightness.
  StreamTheme get streamTheme => StreamTheme.of(this);

  /// Returns the [StreamColorScheme] from the current theme.
  StreamColorScheme get streamColorScheme => streamTheme.colorScheme;

  /// Returns the [StreamTextTheme] from the current theme.
  StreamTextTheme get streamTextTheme => streamTheme.textTheme;

  /// Returns the [StreamTypography] from the current theme.
  StreamTypography get streamTypography => streamTheme.typography;

  /// Returns the [StreamRadius] from the current theme.
  StreamRadius get streamRadius => streamTheme.radius;

  /// Returns the [StreamSpacing] from the current theme.
  StreamSpacing get streamSpacing => streamTheme.spacing;

  /// Returns the [StreamBoxShadow] from the current theme.
  StreamBoxShadow get streamBoxShadow => streamTheme.boxShadow;

  /// Returns the [StreamIcon] from the current theme.
  StreamIcon get streamIcons => streamTheme.icons;

  /// Returns the [StreamAvatarThemeData] from the nearest ancestor.
  StreamAvatarThemeData get streamAvatarTheme => StreamAvatarTheme.of(this);

  /// Returns the [StreamOnlineIndicatorThemeData] from the nearest ancestor.
  StreamOnlineIndicatorThemeData get streamOnlineIndicatorTheme => StreamOnlineIndicatorTheme.of(this);
}
