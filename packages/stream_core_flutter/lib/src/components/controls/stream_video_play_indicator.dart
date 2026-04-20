import 'package:flutter/widgets.dart';

import '../../theme/primitives/stream_colors.dart';
import '../../theme/stream_theme_extensions.dart';

/// Predefined sizes for [StreamVideoPlayIndicator].
///
/// Each size corresponds to a specific diameter and icon size in logical pixels.
enum StreamVideoPlayIndicatorSize {
  /// Extra-large indicator (64px diameter, 32px icon).
  xl(dimension: 64, iconSize: 32),

  /// Large indicator (48px diameter, 20px icon).
  lg(dimension: 48, iconSize: 20),

  /// Medium indicator (40px diameter, 20px icon).
  md(dimension: 40, iconSize: 20),

  /// Small indicator (20px diameter, 12px icon).
  sm(dimension: 20, iconSize: 12)
  ;

  const StreamVideoPlayIndicatorSize({
    required this.dimension,
    required this.iconSize,
  });

  /// The diameter of the indicator in logical pixels.
  final double dimension;

  /// The icon size for this indicator size.
  final double iconSize;
}

/// A circular play/pause indicator for video content.
///
/// [StreamVideoPlayIndicator] is a purely visual indicator, typically overlaid
/// on video thumbnails or video players. It renders a dark translucent circle
/// with a play or pause icon depending on [isPlaying].
///
/// {@tool snippet}
///
/// Basic usage:
///
/// ```dart
/// StreamVideoPlayIndicator()
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Paused state on a video thumbnail:
///
/// ```dart
/// StreamVideoPlayIndicator(
///   isPlaying: false,
///   size: StreamVideoPlayIndicatorSize.lg,
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamVideoPlayIndicatorSize], the available size variants.
class StreamVideoPlayIndicator extends StatelessWidget {
  /// Creates a video play indicator.
  const StreamVideoPlayIndicator({
    super.key,
    this.isPlaying = false,
    this.size = StreamVideoPlayIndicatorSize.xl,
  });

  /// Whether the video is currently playing.
  ///
  /// When true, shows a pause icon. When false, shows a play icon.
  final bool isPlaying;

  /// The size of the indicator.
  ///
  /// Defaults to [StreamVideoPlayIndicatorSize.xl].
  final StreamVideoPlayIndicatorSize size;

  @override
  Widget build(BuildContext context) {
    final icons = context.streamIcons;
    final colorScheme = context.streamColorScheme;

    return Container(
      width: size.dimension,
      height: size.dimension,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: StreamColors.black75,
      ),
      child: Icon(
        isPlaying ? icons.pauseFill : icons.playFill,
        size: size.iconSize,
        color: colorScheme.textOnAccent,
      ),
    );
  }
}
