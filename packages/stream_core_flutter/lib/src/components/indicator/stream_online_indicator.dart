import 'package:flutter/material.dart';

import '../../theme/components/stream_online_indicator_theme.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/stream_theme_extensions.dart';

/// Predefined sizes for the online indicator.
///
/// Each size corresponds to a specific diameter in logical pixels.
///
/// See also:
///
///  * [StreamOnlineIndicator], which uses these size variants.
///  * [StreamOnlineIndicatorThemeData], for customizing indicator appearance.
enum StreamOnlineIndicatorSize {
  /// Small indicator (8px diameter).
  sm(8),

  /// Medium indicator (12px diameter).
  md(12),

  /// Large indicator (14px diameter).
  lg(14)
  ;

  const StreamOnlineIndicatorSize(this.value);

  /// The diameter of the indicator in logical pixels.
  final double value;
}

/// A circular indicator showing online/offline presence status.
///
/// This indicator is typically positioned on or near an avatar to show
/// whether a user is currently online or offline.
///
/// {@tool snippet}
///
/// Basic usage:
///
/// ```dart
/// StreamOnlineIndicator(isOnline: true)
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Positioned on an avatar:
///
/// ```dart
/// Stack(
///   children: [
///     StreamAvatar(placeholder: (context) => Text('AB')),
///     Positioned(
///       right: 0,
///       bottom: 0,
///       child: StreamOnlineIndicator(isOnline: user.isOnline),
///     ),
///   ],
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Custom size:
///
/// ```dart
/// StreamOnlineIndicator(
///   isOnline: false,
///   size: StreamOnlineIndicatorSize.lg,
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamOnlineIndicatorThemeData], for customizing indicator appearance.
///  * [StreamOnlineIndicatorTheme], for overriding theme in a widget subtree.
///  * [StreamAvatar], which often displays this indicator.
class StreamOnlineIndicator extends StatelessWidget {
  /// Creates an online indicator.
  const StreamOnlineIndicator({
    super.key,
    required this.isOnline,
    this.size,
  });

  /// Whether the user is online.
  ///
  /// When true, displays [StreamOnlineIndicatorThemeData.backgroundOnline].
  /// When false, displays [StreamOnlineIndicatorThemeData.backgroundOffline].
  final bool isOnline;

  /// The size of the indicator.
  ///
  /// Defaults to [StreamOnlineIndicatorSize.lg].
  final StreamOnlineIndicatorSize? size;

  @override
  Widget build(BuildContext context) {
    final onlineIndicatorTheme = context.streamOnlineIndicatorTheme;
    final defaults = _StreamOnlineIndicatorThemeDefaults(context);

    final effectiveSize = size ?? StreamOnlineIndicatorSize.lg;
    final effectiveBackgroundOnline = onlineIndicatorTheme.backgroundOnline ?? defaults.backgroundOnline;
    final effectiveBackgroundOffline = onlineIndicatorTheme.backgroundOffline ?? defaults.backgroundOffline;
    final effectiveBorderColor = onlineIndicatorTheme.borderColor ?? defaults.borderColor;

    final color = isOnline ? effectiveBackgroundOnline : effectiveBackgroundOffline;
    final border = Border.all(color: effectiveBorderColor, width: _borderWidthForSize(effectiveSize));

    return AnimatedContainer(
      width: effectiveSize.value,
      height: effectiveSize.value,
      duration: kThemeChangeDuration,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      foregroundDecoration: BoxDecoration(shape: BoxShape.circle, border: border),
    );
  }

  // Returns the appropriate border width for the given indicator size.
  double _borderWidthForSize(
    StreamOnlineIndicatorSize size,
  ) => switch (size) {
    .sm => 1,
    .md || .lg => 2,
  };
}

// Provides default values for [StreamOnlineIndicatorThemeData] based on
// the current [StreamColorScheme].
class _StreamOnlineIndicatorThemeDefaults extends StreamOnlineIndicatorThemeData {
  _StreamOnlineIndicatorThemeDefaults(this.context) : _colorScheme = context.streamColorScheme;

  final BuildContext context;
  final StreamColorScheme _colorScheme;

  @override
  Color get backgroundOnline => _colorScheme.accentSuccess;

  @override
  Color get backgroundOffline => _colorScheme.accentNeutral;

  @override
  Color get borderColor => _colorScheme.borderOnDark;
}
