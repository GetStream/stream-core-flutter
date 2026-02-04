import 'package:flutter/material.dart';

import '../../theme/components/stream_online_indicator_theme.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/stream_theme_extensions.dart';

/// A circular indicator showing online/offline presence status.
///
/// This indicator is typically positioned on or near an avatar to show
/// whether a user is currently online or offline.
///
/// When [child] is provided, the indicator is automatically positioned
/// relative to the child using a [Stack], similar to Flutter's [Badge] widget.
///
/// {@tool snippet}
///
/// Basic usage (standalone indicator):
///
/// ```dart
/// StreamOnlineIndicator(isOnline: true)
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// With a child widget (automatically positioned):
///
/// ```dart
/// StreamOnlineIndicator(
///   isOnline: user.isOnline,
///   child: StreamAvatar(placeholder: (context) => Text('AB')),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Custom positioning:
///
/// ```dart
/// StreamOnlineIndicator(
///   isOnline: true,
///   alignment: Alignment.topRight,
///   offset: Offset(2, -2),
///   child: StreamAvatar(placeholder: (context) => Text('AB')),
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
  ///
  /// If [child] is provided, the indicator will be positioned relative to the
  /// child using [alignment] and [offset].
  const StreamOnlineIndicator({
    super.key,
    required this.isOnline,
    this.size,
    this.child,
    this.alignment,
    this.offset,
  });

  /// Whether the user is online.
  ///
  /// When true, displays [StreamOnlineIndicatorThemeData.backgroundOnline].
  /// When false, displays [StreamOnlineIndicatorThemeData.backgroundOffline].
  final bool isOnline;

  /// The size of the indicator.
  ///
  /// If null, uses [StreamOnlineIndicatorThemeData.size], or falls back to
  /// [StreamOnlineIndicatorSize.lg].
  final StreamOnlineIndicatorSize? size;

  /// The widget below this widget in the tree.
  ///
  /// When provided, the indicator is positioned relative to this child
  /// using a [Stack]. When null, only the indicator is displayed.
  final Widget? child;

  /// The alignment of the indicator relative to [child].
  ///
  /// Only used when [child] is provided.
  /// Falls back to [StreamOnlineIndicatorThemeData.alignment], or
  /// [AlignmentDirectional.topEnd].
  final AlignmentGeometry? alignment;

  /// The offset for fine-tuning indicator position.
  ///
  /// Applied after [alignment] to adjust the indicator's final position.
  /// Falls back to [StreamOnlineIndicatorThemeData.offset], or [Offset.zero].
  final Offset? offset;

  @override
  Widget build(BuildContext context) {
    final onlineIndicatorTheme = context.streamOnlineIndicatorTheme;
    final defaults = _StreamOnlineIndicatorThemeDefaults(context);

    final effectiveSize = size ?? onlineIndicatorTheme.size ?? defaults.size;
    final effectiveBackgroundOnline = onlineIndicatorTheme.backgroundOnline ?? defaults.backgroundOnline;
    final effectiveBackgroundOffline = onlineIndicatorTheme.backgroundOffline ?? defaults.backgroundOffline;
    final effectiveBorderColor = onlineIndicatorTheme.borderColor ?? defaults.borderColor;

    final color = isOnline ? effectiveBackgroundOnline : effectiveBackgroundOffline;
    final border = Border.all(color: effectiveBorderColor, width: _borderWidthForSize(effectiveSize));

    final indicator = AnimatedContainer(
      width: effectiveSize.value,
      height: effectiveSize.value,
      duration: kThemeChangeDuration,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      foregroundDecoration: BoxDecoration(shape: BoxShape.circle, border: border),
    );

    // If no child, just return the indicator.
    if (child == null) return indicator;

    // Otherwise, wrap in Stack like Badge.
    final effectiveAlignment = alignment ?? onlineIndicatorTheme.alignment ?? defaults.alignment;
    final effectiveOffset = offset ?? onlineIndicatorTheme.offset ?? defaults.offset;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child!,
        Positioned.fill(
          child: Align(
            alignment: effectiveAlignment,
            child: Transform.translate(
              offset: effectiveOffset,
              child: indicator,
            ),
          ),
        ),
      ],
    );
  }

  // Returns the appropriate border width for the given indicator size.
  double _borderWidthForSize(
    StreamOnlineIndicatorSize size,
  ) => switch (size) {
    .sm => 1,
    .md || .lg || .xl => 2,
  };
}

// Provides default values for [StreamOnlineIndicatorThemeData] based on
// the current [StreamColorScheme].
class _StreamOnlineIndicatorThemeDefaults extends StreamOnlineIndicatorThemeData {
  _StreamOnlineIndicatorThemeDefaults(
    this.context,
  ) : _colorScheme = context.streamColorScheme;

  final BuildContext context;
  final StreamColorScheme _colorScheme;

  @override
  StreamOnlineIndicatorSize get size => StreamOnlineIndicatorSize.lg;

  @override
  Color get backgroundOnline => _colorScheme.accentSuccess;

  @override
  Color get backgroundOffline => _colorScheme.accentNeutral;

  @override
  Color get borderColor => _colorScheme.borderOnDark;

  @override
  AlignmentGeometry get alignment => AlignmentDirectional.topEnd;

  @override
  Offset get offset => Offset.zero;
}
