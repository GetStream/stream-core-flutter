import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/components/stream_avatar_theme.dart';
import '../../theme/components/stream_badge_count_theme.dart';
import '../badge/stream_badge_count.dart';

/// Predefined avatar stack sizes.
///
/// Each size corresponds to a specific diameter in logical pixels.
///
/// See also:
///
///  * [StreamAvatarStack], which uses these size variants.
enum StreamAvatarStackSize {
  /// Extra small avatar stack (20px diameter).
  xs(20),

  /// Small avatar stack (24px diameter).
  sm(24)
  ;

  /// Constructs a [StreamAvatarStackSize] with the given diameter.
  const StreamAvatarStackSize(this.value);

  /// The diameter of the avatar stack in logical pixels.
  final double value;
}

/// A widget that displays a stack of [StreamAvatar] widgets with overlap.
///
/// This is useful for showing multiple participants in a chat, group, or team.
/// The [size], [overlap], and [max] can be customized.
///
/// {@tool snippet}
///
/// Basic usage with default size and overlap:
///
/// ```dart
/// StreamAvatarStack(
///   children: [
///     StreamAvatar(placeholder: (context) => Text('A')),
///     StreamAvatar(placeholder: (context) => Text('B')),
///     StreamAvatar(placeholder: (context) => Text('C')),
///   ],
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// With max limit showing overflow badge:
///
/// ```dart
/// StreamAvatarStack(
///   max: 3,
///   children: [
///     StreamAvatar(placeholder: (context) => Text('A')),
///     StreamAvatar(placeholder: (context) => Text('B')),
///     StreamAvatar(placeholder: (context) => Text('C')),
///     StreamAvatar(placeholder: (context) => Text('D')),
///     StreamAvatar(placeholder: (context) => Text('E')),
///   ],
/// )
/// // Shows: [A] [B] [C] [StreamBadgeCount with +2]
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Custom size and overlap:
///
/// ```dart
/// StreamAvatarStack(
///   size: StreamAvatarStackSize.sm,
///   overlap: 0.5, // 50% overlap
///   children: [
///     StreamAvatar(placeholder: (context) => Text('A')),
///     StreamAvatar(placeholder: (context) => Text('B')),
///     StreamAvatar(placeholder: (context) => Text('C')),
///   ],
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamAvatarStackSize], which defines the available size variants.
///  * [StreamAvatar], the individual avatar widget.
///  * [StreamBadgeCount], used for the overflow indicator.
///  * [StreamAvatarThemeData], for customizing avatar theme properties.
class StreamAvatarStack extends StatelessWidget {
  /// Creates a [StreamAvatarStack] with the given children.
  ///
  /// The [children] are typically [StreamAvatar] widgets.
  /// The [overlap] controls how much each avatar overlaps the previous one,
  /// ranging from 0.0 (no overlap) to 1.0 (fully stacked).
  const StreamAvatarStack({
    super.key,
    this.size,
    required this.children,
    this.overlap = 0.33,
    this.max = 5,
  }) : assert(max >= 2, 'max must be at least 2');

  /// The list of widgets to display in the stack.
  ///
  /// Typically a list of [StreamAvatar] widgets.
  final Iterable<Widget> children;

  /// The size of the avatar stack.
  ///
  /// If null, defaults to [StreamAvatarStackSize.sm].
  final StreamAvatarStackSize? size;

  /// How much each avatar overlaps the previous one, as a fraction of size.
  ///
  /// - `0.0`: No overlap (side by side)
  /// - `0.33`: 33% overlap (default)
  /// - `1.0`: Fully stacked
  final double overlap;

  /// Maximum number of avatars to display before showing overflow badge.
  ///
  /// When [children] exceeds this value, displays [max] avatars followed
  /// by a [StreamBadgeCount] showing the overflow count.
  ///
  /// Must be at least 2. Defaults to 5.
  final int max;

  @override
  Widget build(BuildContext context) {
    assert(children.isNotEmpty, 'StreamAvatarStack must have at least one child');

    final effectiveSize = size ?? StreamAvatarStackSize.sm;
    final avatarSize = _avatarSizeForStackSize(effectiveSize);
    final extraBadgeSize = _badgeCountSizeForStackSize(effectiveSize);

    final diameter = avatarSize.value;
    final badgeDiameter = extraBadgeSize.value;

    // Split children into visible and overflow
    final visible = children.take(max).toList();
    final extraCount = children.length - visible.length;

    // Build the list of widgets to display
    final displayChildren = <Widget>[
      ...visible,
      if (extraCount > 0) StreamBadgeCount(label: '+$extraCount', size: extraBadgeSize),
    ];

    // Calculate the offset between each avatar (how much of each avatar is visible)
    final visiblePortion = diameter * (1 - overlap);
    final badgeVisiblePortion = badgeDiameter * (1 - overlap);

    // Total width: first avatar full + remaining avatars visible portion
    var totalWidth = diameter + (visible.length - 1) * visiblePortion;
    if (extraCount > 0) totalWidth += badgeVisiblePortion;

    return AnimatedContainer(
      width: totalWidth,
      height: math.max(diameter, badgeDiameter),
      duration: kThemeChangeDuration,
      child: StreamAvatarTheme(
        data: StreamAvatarThemeData(size: avatarSize),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            for (var i = 0; i < displayChildren.length; i++)
              Positioned(
                left: i * visiblePortion,
                child: displayChildren[i],
              ),
          ],
        ),
      ),
    );
  }

  StreamAvatarSize _avatarSizeForStackSize(
    StreamAvatarStackSize size,
  ) => switch (size) {
    .xs => StreamAvatarSize.xs,
    .sm => StreamAvatarSize.sm,
  };

  StreamBadgeCountSize _badgeCountSizeForStackSize(
    StreamAvatarStackSize size,
  ) => switch (size) {
    .xs => StreamBadgeCountSize.xs,
    .sm => StreamBadgeCountSize.sm,
  };
}
