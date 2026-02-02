import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';

part 'stream_badge_count_theme.g.theme.dart';

/// Predefined sizes for the badge count indicator.
///
/// Each size corresponds to a specific height in logical pixels.
///
/// See also:
///
///  * [StreamBadgeCount], which uses these size variants.
///  * [StreamBadgeCountThemeData.size], for setting a global default size.
enum StreamBadgeCountSize {
  /// Extra small badge (20px height).
  xs(20),

  /// Small badge (24px height).
  sm(24),

  /// Medium badge (32px height).
  md(32);

  /// Constructs a [StreamBadgeCountSize] with the given height.
  const StreamBadgeCountSize(this.value);

  /// The height of the badge in logical pixels.
  final double value;
}

/// Applies a badge count theme to descendant [StreamBadgeCount] widgets.
///
/// Wrap a subtree with [StreamBadgeCountTheme] to override badge styling.
/// Access the merged theme using [BuildContext.streamBadgeCountTheme].
///
/// {@tool snippet}
///
/// Override badge colors for a specific section:
///
/// ```dart
/// StreamBadgeCountTheme(
///   data: StreamBadgeCountThemeData(
///     backgroundColor: Colors.red,
///     textColor: Colors.white,
///   ),
///   child: StreamBadgeCount(label: '5'),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamBadgeCountThemeData], which describes the badge theme.
///  * [StreamBadgeCount], the widget affected by this theme.
class StreamBadgeCountTheme extends InheritedTheme {
  /// Creates a badge count theme that controls descendant badges.
  const StreamBadgeCountTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The badge count theme data for descendant widgets.
  final StreamBadgeCountThemeData data;

  /// Returns the [StreamBadgeCountThemeData] merged from local and global
  /// themes.
  ///
  /// Local values from the nearest [StreamBadgeCountTheme] ancestor take
  /// precedence over global values from [StreamTheme.of].
  ///
  /// This allows partial overrides - for example, overriding only
  /// [backgroundColor] while inheriting other properties from the global theme.
  static StreamBadgeCountThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamBadgeCountTheme>();
    return StreamTheme.of(context).badgeCountTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamBadgeCountTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamBadgeCountTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing [StreamBadgeCount] widgets.
///
/// {@tool snippet}
///
/// Customize badge appearance globally:
///
/// ```dart
/// StreamTheme(
///   badgeCountTheme: StreamBadgeCountThemeData(
///     size: StreamBadgeCountSize.sm,
///     backgroundColor: Colors.red,
///     textColor: Colors.white,
///     borderColor: Colors.white,
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamBadgeCount], the widget that uses this theme data.
///  * [StreamBadgeCountTheme], for overriding theme in a widget subtree.
@themeGen
@immutable
class StreamBadgeCountThemeData with _$StreamBadgeCountThemeData {
  /// Creates a badge count theme with optional style overrides.
  const StreamBadgeCountThemeData({
    this.size,
    this.textColor,
    this.backgroundColor,
    this.borderColor,
  });

  /// The default size for badge counts.
  ///
  /// Falls back to [StreamBadgeCountSize.xs].
  final StreamBadgeCountSize? size;

  /// The text color for the count label.
  ///
  /// Applied to the numeric count displayed inside the badge.
  final Color? textColor;

  /// The background color of the badge.
  ///
  /// The fill color behind the count text. Typically uses a color that
  /// contrasts with the surface it's placed on.
  final Color? backgroundColor;

  /// The border color of the badge.
  ///
  /// A thin outline around the badge that helps separate it from the
  /// underlying content.
  final Color? borderColor;

  /// Linearly interpolate between two [StreamBadgeCountThemeData] objects.
  static StreamBadgeCountThemeData? lerp(
    StreamBadgeCountThemeData? a,
    StreamBadgeCountThemeData? b,
    double t,
  ) => _$StreamBadgeCountThemeData.lerp(a, b, t);
}
