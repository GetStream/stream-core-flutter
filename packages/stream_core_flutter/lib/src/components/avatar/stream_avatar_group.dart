import 'package:flutter/material.dart';

import '../../theme/components/stream_avatar_theme.dart';
import '../../theme/components/stream_badge_count_theme.dart';
import '../../theme/stream_theme_extensions.dart';
import '../badge/stream_badge_count.dart';
import 'stream_avatar.dart';

/// Predefined avatar group sizes.
///
/// Each size corresponds to a specific diameter in logical pixels.
///
/// See also:
///
///  * [StreamAvatarGroup], which uses these size variants.
enum StreamAvatarGroupSize {
  /// Large avatar group (40px diameter).
  lg(40),

  /// Extra large avatar group (64px diameter).
  xl(64)
  ;

  /// Constructs a [StreamAvatarGroupSize] with the given diameter.
  const StreamAvatarGroupSize(this.value);

  /// The diameter of the avatar group in logical pixels.
  final double value;
}

/// A widget that displays multiple avatars in a grid layout.
///
/// [StreamAvatarGroup] arranges avatars in a 2x2 grid pattern, typically used
/// for displaying group channel participants. It supports two sizes and
/// automatically handles overflow with a [StreamBadgeCount] indicator.
///
/// The avatar automatically handles:
/// - Grid layout for up to 4 avatars
/// - Overflow indicator using [StreamBadgeCount] for additional participants
/// - Consistent sizing across all child avatars
///
/// {@tool snippet}
///
/// Basic usage with avatars:
///
/// ```dart
/// StreamAvatarGroup(
///   children: [
///     StreamAvatar(placeholder: (context) => Text('A')),
///     StreamAvatar(placeholder: (context) => Text('B')),
///     StreamAvatar(placeholder: (context) => Text('C')),
///     StreamAvatar(placeholder: (context) => Text('D')),
///   ],
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// With custom size:
///
/// ```dart
/// StreamAvatarGroup(
///   size: StreamAvatarGroupSize.xl,
///   children: [
///     StreamAvatar(placeholder: (context) => Text('A')),
///     StreamAvatar(placeholder: (context) => Text('B')),
///   ],
/// )
/// ```
/// {@end-tool}
///
/// ## Theming
///
/// [StreamAvatarGroup] uses [StreamAvatarThemeData] for styling the child
/// avatars. Colors are inherited from the theme or can be customized
/// per-avatar.
///
/// See also:
///
///  * [StreamAvatarGroupSize], which defines the available size variants.
///  * [StreamAvatar], the individual avatar widget.
///  * [StreamBadgeCount], used for the overflow indicator.
///  * [StreamAvatarThemeData], which provides theme-level customization.
class StreamAvatarGroup extends StatelessWidget {
  /// Creates a Stream avatar group.
  const StreamAvatarGroup({
    super.key,
    this.size,
    required this.children,
  });

  /// The list of avatars to display in the group.
  ///
  /// Typically a list of [StreamAvatar] widgets.
  final Iterable<Widget> children;

  /// The size of the avatar group.
  ///
  /// If null, defaults to [StreamAvatarGroupSize.lg].
  final StreamAvatarGroupSize? size;

  @override
  Widget build(BuildContext context) {
    assert(children.isNotEmpty, 'StreamAvatarGroup must have at least one child');

    final colorScheme = context.streamColorScheme;

    final effectiveSize = size ?? StreamAvatarGroupSize.lg;
    final avatarSize = _avatarSizeForGroupSize(effectiveSize);
    final badgeCountSize = _badgeCountSizeForGroupSize(effectiveSize);

    const avatarBorderWidth = 2.0;

    return AnimatedContainer(
      width: effectiveSize.value,
      height: effectiveSize.value,
      padding: const EdgeInsets.all(avatarBorderWidth),
      duration: kThemeChangeDuration,
      child: StreamAvatarTheme(
        data: StreamAvatarThemeData(
          size: avatarSize,
          border: Border.all(
            width: avatarBorderWidth,
            color: colorScheme.borderOnDark,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
        ),
        child: StreamBadgeCountTheme(
          data: StreamBadgeCountThemeData(size: badgeCountSize),
          child: Builder(
            builder: (context) => switch (children.length) {
              1 => _buildForOne(context, children),
              2 => _buildForTwo(context, children),
              3 => _buildForThree(context, children),
              4 => _buildForFour(context, children),
              _ => _buildForFourOrMore(context, children),
            },
          ),
        ),
      ),
    );
  }

  Widget _buildForOne(
    BuildContext context,
    Iterable<Widget> avatars,
  ) {
    final avatarOne = avatars.first;

    return Stack(
      children: [
        Positioned.fill(
          child: Align(
            alignment: AlignmentDirectional.topStart,
            child: StreamAvatar(
              placeholder: (_) => const Icon(Icons.person),
            ),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: AlignmentDirectional.bottomEnd,
            child: avatarOne,
          ),
        ),
      ],
    );
  }

  Widget _buildForTwo(
    BuildContext context,
    Iterable<Widget> avatars,
  ) {
    final avatarOne = avatars.first;
    final avatarTwo = avatars.last;

    return Stack(
      children: [
        Positioned.fill(
          child: Align(
            alignment: AlignmentDirectional.topStart,
            child: avatarOne,
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: AlignmentDirectional.bottomEnd,
            child: avatarTwo,
          ),
        ),
      ],
    );
  }

  Widget _buildForThree(
    BuildContext context,
    Iterable<Widget> avatars,
  ) {
    final avatarOne = avatars.first;
    final avatarTwo = avatars.elementAt(1);
    final avatarThree = avatars.last;

    return Stack(
      children: [
        Positioned.fill(
          child: Align(
            alignment: AlignmentDirectional.topCenter,
            child: avatarOne,
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: AlignmentDirectional.bottomStart,
            child: avatarTwo,
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: AlignmentDirectional.bottomEnd,
            child: avatarThree,
          ),
        ),
      ],
    );
  }

  Widget _buildForFour(
    BuildContext context,
    Iterable<Widget> avatars,
  ) {
    final avatarOne = avatars.first;
    final avatarTwo = avatars.elementAt(1);
    final avatarThree = avatars.elementAt(2);
    final avatarFour = avatars.last;

    return Stack(
      children: [
        Positioned.fill(
          child: Align(
            alignment: AlignmentDirectional.topStart,
            child: avatarOne,
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: AlignmentDirectional.topEnd,
            child: avatarTwo,
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: AlignmentDirectional.bottomStart,
            child: avatarThree,
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: AlignmentDirectional.bottomEnd,
            child: avatarFour,
          ),
        ),
      ],
    );
  }

  Widget _buildForFourOrMore(
    BuildContext context,
    Iterable<Widget> avatars,
  ) {
    final avatarOne = avatars.first;
    final avatarTwo = avatars.elementAt(1);
    final extraCount = avatars.length - 2;

    return Stack(
      children: [
        Positioned.fill(
          child: Align(
            alignment: AlignmentDirectional.topStart,
            child: avatarOne,
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: AlignmentDirectional.topEnd,
            child: avatarTwo,
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: AlignmentDirectional.bottomCenter,
            child: StreamBadgeCount(label: '+$extraCount'),
          ),
        ),
      ],
    );
  }

  StreamAvatarSize _avatarSizeForGroupSize(
    StreamAvatarGroupSize size,
  ) => switch (size) {
    .lg => StreamAvatarSize.sm,
    .xl => StreamAvatarSize.lg,
  };

  StreamBadgeCountSize _badgeCountSizeForGroupSize(
    StreamAvatarGroupSize size,
  ) => switch (size) {
    .lg => StreamBadgeCountSize.sm,
    .xl => StreamBadgeCountSize.md,
  };
}
