import 'package:flutter/material.dart';

import '../../theme/components/stream_avatar_theme.dart';
import '../../theme/stream_theme_extensions.dart';
import 'stream_avatar.dart';

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
/// With max limit showing "+X" for overflow:
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
/// // Shows: [A] [B] [C] [+2]
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Custom size and overlap:
///
/// ```dart
/// StreamAvatarStack(
///   size: StreamAvatarSize.sm,
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
///  * [StreamAvatar], the individual avatar widget.
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
    this.extraAvatarBuilder,
  }) : assert(max >= 2, 'max must be at least 2');

  /// The list of widgets to display in the stack.
  ///
  /// Typically a list of [StreamAvatar] widgets.
  final List<Widget> children;

  /// The size of the avatars in the stack.
  ///
  /// If null, uses [StreamAvatarThemeData.size], or falls back to
  /// [StreamAvatarSize.lg].
  final StreamAvatarSize? size;

  /// How much each avatar overlaps the previous one, as a fraction of size.
  ///
  /// - `0.0`: No overlap (side by side)
  /// - `0.33`: 33% overlap (default)
  /// - `1.0`: Fully stacked
  final double overlap;

  /// Maximum number of avatars to display before showing "+X".
  ///
  /// When [children] exceeds this value, displays [max] avatars followed
  /// by a "+X" avatar showing the overflow count.
  ///
  /// Must be at least 2. Defaults to 5.
  final int max;

  /// Builder for the extra avatar showing the overflow count.
  ///
  /// If null, a default [StreamAvatar] with "+X" text is used.
  ///
  /// The [extraCount] parameter indicates how many avatars are hidden.
  ///
  /// {@tool snippet}
  ///
  /// Custom extra avatar:
  ///
  /// ```dart
  /// StreamAvatarStack(
  ///   max: 3,
  ///   extraAvatarBuilder: (context, extraCount) => StreamAvatar(
  ///     backgroundColor: Colors.grey,
  ///     placeholder: (context) => Text('+$extraCount'),
  ///   ),
  ///   children: [...],
  /// )
  /// ```
  /// {@end-tool}
  final Widget Function(BuildContext context, int extraCount)? extraAvatarBuilder;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    final avatarTheme = context.streamAvatarTheme;
    final colorScheme = context.streamColorScheme;

    final effectiveSize = size ?? avatarTheme.size ?? .lg;
    final diameter = effectiveSize.value;

    // Split children into visible and overflow
    final visible = children.take(max).toList();
    final extraCount = children.length - visible.length;

    // Build the list of widgets to display
    final displayChildren = <Widget>[
      ...visible,
      if (extraCount > 0) ...[
        switch (extraAvatarBuilder) {
          final builder? => builder.call(context, extraCount),
          _ => StreamAvatar(
            backgroundColor: colorScheme.backgroundSurfaceStrong,
            foregroundColor: colorScheme.textSecondary,
            placeholder: (context) => Text('+$extraCount'),
          ),
        },
      ],
    ];

    // Calculate the offset between each avatar (how much of each avatar is visible)
    final visiblePortion = diameter * (1 - overlap);

    // Total width: first avatar full + remaining avatars visible portion
    final totalWidth = diameter + (displayChildren.length - 1) * visiblePortion;

    return SizedBox(
      width: totalWidth,
      height: diameter,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          for (var i = 0; i < displayChildren.length; i++)
            Positioned(
              left: i * visiblePortion,
              child: StreamAvatarTheme(
                data: StreamAvatarThemeData(size: effectiveSize),
                child: displayChildren[i],
              ),
            ),
        ],
      ),
    );
  }
}
