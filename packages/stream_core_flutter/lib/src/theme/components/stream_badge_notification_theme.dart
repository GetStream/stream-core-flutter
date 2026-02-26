import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';

part 'stream_badge_notification_theme.g.theme.dart';

/// Predefined sizes for the badge notification indicator.
///
/// Each size corresponds to a specific height in logical pixels.
///
/// See also:
///
///  * [StreamBadgeNotification], which uses these size variants.
///  * [StreamBadgeNotificationThemeData.size], for setting a global default.
enum StreamBadgeNotificationSize {
  /// Extra small badge (16px height).
  xs(16),

  /// Small badge (20px height).
  sm(20);

  /// Constructs a [StreamBadgeNotificationSize] with the given height.
  const StreamBadgeNotificationSize(this.value);

  /// The height of the badge in logical pixels.
  final double value;
}

/// The visual type of a [StreamBadgeNotification].
///
/// Determines which background color is applied to the badge.
enum StreamBadgeNotificationType {
  /// Primary style — uses the brand accent color.
  primary,

  /// Error style — uses the error accent color.
  error,

  /// Neutral style — uses a muted neutral color.
  neutral,
}

/// Applies a badge notification theme to descendant widgets.
///
/// Wrap a subtree with [StreamBadgeNotificationTheme] to override badge
/// notification styling. Access the merged theme using
/// [BuildContext.streamBadgeNotificationTheme].
///
/// See also:
///
///  * [StreamBadgeNotificationThemeData], which describes the theme.
///  * [StreamBadgeNotification], the widget affected by this theme.
class StreamBadgeNotificationTheme extends InheritedTheme {
  /// Creates a badge notification theme.
  const StreamBadgeNotificationTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The badge notification theme data for descendant widgets.
  final StreamBadgeNotificationThemeData data;

  /// Returns the merged [StreamBadgeNotificationThemeData] from local and
  /// global themes.
  static StreamBadgeNotificationThemeData of(BuildContext context) {
    final localTheme = context
        .dependOnInheritedWidgetOfExactType<StreamBadgeNotificationTheme>();
    return StreamTheme.of(context)
        .badgeNotificationTheme
        .merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamBadgeNotificationTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamBadgeNotificationTheme oldWidget) =>
      data != oldWidget.data;
}

/// Theme data for customizing [StreamBadgeNotification] widgets.
///
/// See also:
///
///  * [StreamBadgeNotification], the widget that uses this theme data.
///  * [StreamBadgeNotificationTheme], for overriding theme in a widget subtree.
@themeGen
@immutable
class StreamBadgeNotificationThemeData
    with _$StreamBadgeNotificationThemeData {
  /// Creates a badge notification theme with optional style overrides.
  const StreamBadgeNotificationThemeData({
    this.size,
    this.primaryBackgroundColor,
    this.errorBackgroundColor,
    this.neutralBackgroundColor,
    this.textColor,
    this.borderColor,
  });

  /// The default size for badge notifications.
  ///
  /// Falls back to [StreamBadgeNotificationSize.sm].
  final StreamBadgeNotificationSize? size;

  /// The background color for the [StreamBadgeNotificationType.primary] type.
  final Color? primaryBackgroundColor;

  /// The background color for the [StreamBadgeNotificationType.error] type.
  final Color? errorBackgroundColor;

  /// The background color for the [StreamBadgeNotificationType.neutral] type.
  final Color? neutralBackgroundColor;

  /// The text color for the count label.
  final Color? textColor;

  /// The border color of the badge.
  final Color? borderColor;

  /// Linearly interpolate between two [StreamBadgeNotificationThemeData].
  static StreamBadgeNotificationThemeData? lerp(
    StreamBadgeNotificationThemeData? a,
    StreamBadgeNotificationThemeData? b,
    double t,
  ) => _$StreamBadgeNotificationThemeData.lerp(a, b, t);
}
