import 'package:flutter/widgets.dart';

import '../../../theme/components/stream_avatar_theme.dart';

/// Forces descendant avatars to a diameter that no [StreamAvatarSize] names.
///
/// The size still decides the avatar's text style, icon size and border — only
/// the diameter is taken from here. It exists for [StreamAvatarGroup], whose
/// largest variant packs children at a diameter that sits between two named
/// sizes; nothing else should reach for it, which is why it stays out of the
/// public barrel.
class AvatarDimensionOverride extends InheritedWidget {
  /// Creates an override that draws descendant avatars at [dimension].
  const AvatarDimensionOverride({
    super.key,
    required this.dimension,
    required super.child,
  });

  /// The diameter descendant avatars are drawn at, in logical pixels.
  final double dimension;

  /// The diameter forced on avatars at [context], or null when none is.
  static double? maybeOf(BuildContext context) {
    final override = context.dependOnInheritedWidgetOfExactType<AvatarDimensionOverride>();
    return override?.dimension;
  }

  @override
  bool updateShouldNotify(AvatarDimensionOverride oldWidget) => dimension != oldWidget.dimension;
}
