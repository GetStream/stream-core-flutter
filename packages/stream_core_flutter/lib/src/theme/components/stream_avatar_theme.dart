import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../semantics/stream_color_scheme.dart';
import '../stream_theme.dart';

part 'stream_avatar_theme.g.theme.dart';

/// Predefined avatar sizes for the Stream design system.
///
/// Each size corresponds to a specific diameter in logical pixels.
///
/// See also:
///
///  * [StreamAvatar], which uses these size variants.
///  * [StreamAvatarThemeData.size], for setting a global default size.
enum StreamAvatarSize {
  /// Extra small avatar (20px diameter).
  xs(20),

  /// Small avatar (24px diameter).
  sm(24),

  /// Medium avatar (32px diameter).
  md(32),

  /// Large avatar (40px diameter).
  lg(40)
  ;

  /// Constructs a [StreamAvatarSize] with the given diameter.
  const StreamAvatarSize(this.value);

  /// The diameter of the avatar in logical pixels.
  final double value;
}

/// Applies an avatar theme to descendant [StreamAvatar] widgets.
///
/// Wrap a subtree with [StreamAvatarTheme] to override avatar styling.
/// Access the merged theme using [BuildContext.streamAvatarTheme].
///
/// {@tool snippet}
///
/// Override avatar colors for a specific section:
///
/// ```dart
/// StreamAvatarTheme(
///   data: StreamAvatarThemeData(
///     backgroundColor: Colors.blue.shade100,
///     foregroundColor: Colors.blue.shade800,
///   ),
///   child: Row(
///     children: [
///       StreamAvatar(placeholder: (context) => Text('A')),
///       StreamAvatar(placeholder: (context) => Text('B')),
///     ],
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamAvatarThemeData], which describes the avatar theme.
///  * [StreamAvatar], the widget affected by this theme.
class StreamAvatarTheme extends InheritedTheme {
  /// Creates an avatar theme that controls the styling of descendant avatars.
  const StreamAvatarTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The avatar theme data for descendant widgets.
  final StreamAvatarThemeData data;

  /// Returns the [StreamAvatarThemeData] merged from local and global themes.
  ///
  /// Local values from the nearest [StreamAvatarTheme] ancestor take
  /// precedence over global values from [StreamTheme.of].
  ///
  /// This allows partial overrides - for example, overriding only [size]
  /// while inheriting colors from the global theme.
  static StreamAvatarThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamAvatarTheme>();
    return StreamTheme.of(context).avatarTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamAvatarTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamAvatarTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing [StreamAvatar] widgets.
///
/// {@tool snippet}
///
/// Customize avatar appearance globally:
///
/// ```dart
/// StreamTheme(
///   avatarTheme: StreamAvatarThemeData(
///     backgroundColor: Colors.grey.shade200,
///     foregroundColor: Colors.grey.shade800,
///     borderColor: Colors.grey.shade300,
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamAvatar], the widget that uses this theme data.
///  * [StreamAvatarTheme], for overriding theme in a widget subtree.
///  * [StreamColorScheme.avatarPalette], for user-specific avatar colors.
@themeGen
@immutable
class StreamAvatarThemeData with _$StreamAvatarThemeData {
  /// Creates an avatar theme with optional style overrides.
  const StreamAvatarThemeData({
    this.size,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
  });

  /// The default size for avatars.
  ///
  /// Falls back to [StreamAvatarSize.lg]. The text style for initials is
  /// automatically determined based on this size.
  final StreamAvatarSize? size;

  /// The background color for this avatar.
  ///
  /// Used as the fill color behind the avatar image or placeholder content.
  final Color? backgroundColor;

  /// The foreground color for this avatar's placeholder content.
  ///
  /// Applied to text (initials) and icons when no image is available.
  final Color? foregroundColor;

  /// The border color for this avatar.
  ///
  /// Applied when [StreamAvatar.showBorder] is true.
  final Color? borderColor;

  /// Linearly interpolate between two [StreamAvatarThemeData] objects.
  static StreamAvatarThemeData? lerp(
    StreamAvatarThemeData? a,
    StreamAvatarThemeData? b,
    double t,
  ) => _$StreamAvatarThemeData.lerp(a, b, t);
}
