import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';

part 'stream_inline_notification_theme.g.theme.dart';

/// The kinds of message a [StreamInlineNotification] can carry.
///
/// Each type picks the default leading icon, its color and the background
/// color behind the content.
///
/// See also:
///
///  * [StreamInlineNotificationProps.type], which selects one of these types.
///  * [StreamInlineNotificationThemeData], which styles each type.
enum StreamInlineNotificationType {
  /// General informational context, such as how a value is interpreted.
  info,

  /// A positive or completed outcome.
  success,

  /// A cautionary state that needs attention.
  warning,

  /// A failure or a validation error.
  error,
}

/// Applies an inline notification theme to descendant [StreamInlineNotification]
/// widgets.
///
/// Wrap a subtree with [StreamInlineNotificationTheme] to override inline
/// notification styling. Access the merged theme using
/// [BuildContext.streamInlineNotificationTheme].
///
/// {@tool snippet}
///
/// Restyle error notifications for a specific subtree:
///
/// ```dart
/// StreamInlineNotificationTheme(
///   data: StreamInlineNotificationThemeData(
///     error: StreamInlineNotificationThemeStyle(
///       backgroundColor: Colors.red.shade50,
///       iconColor: Colors.red,
///     ),
///   ),
///   child: child,
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamInlineNotificationThemeData], which describes the theme.
///  * [StreamInlineNotification], the widget affected by this theme.
class StreamInlineNotificationTheme extends InheritedTheme {
  /// Creates an inline notification theme that controls descendant inline
  /// notifications.
  const StreamInlineNotificationTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The inline notification theme data for descendant widgets.
  final StreamInlineNotificationThemeData data;

  /// Returns the [StreamInlineNotificationThemeData] merged from local and
  /// global themes.
  ///
  /// Local values from the nearest [StreamInlineNotificationTheme] ancestor
  /// take precedence over global values from [StreamTheme.of].
  static StreamInlineNotificationThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamInlineNotificationTheme>();
    return StreamTheme.of(context).inlineNotificationTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamInlineNotificationTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamInlineNotificationTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing [StreamInlineNotification] widgets.
///
/// Each type's colors and text styles are set through [info], [success],
/// [warning] and [error]. The geometry ([shape], [padding], [spacing] and
/// [constraints]) is shared by every type. A property left null falls back to
/// the design system default.
///
/// {@tool snippet}
///
/// Customize inline notifications globally:
///
/// ```dart
/// StreamTheme(
///   inlineNotificationTheme: StreamInlineNotificationThemeData(
///     info: StreamInlineNotificationThemeStyle(
///       backgroundColor: Colors.blue.shade50,
///     ),
///     padding: EdgeInsets.all(16),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamInlineNotification], the widget that uses this theme data.
///  * [StreamInlineNotificationTheme], for overriding the theme in a widget
///    subtree.
@themeGen
@immutable
class StreamInlineNotificationThemeData with _$StreamInlineNotificationThemeData {
  /// Creates inline notification theme data with optional overrides.
  const StreamInlineNotificationThemeData({
    this.info,
    this.success,
    this.warning,
    this.error,
    this.shape,
    this.padding,
    this.spacing,
    this.constraints,
  });

  /// The style of [StreamInlineNotificationType.info] notifications.
  final StreamInlineNotificationThemeStyle? info;

  /// The style of [StreamInlineNotificationType.success] notifications.
  final StreamInlineNotificationThemeStyle? success;

  /// The style of [StreamInlineNotificationType.warning] notifications.
  final StreamInlineNotificationThemeStyle? warning;

  /// The style of [StreamInlineNotificationType.error] notifications.
  final StreamInlineNotificationThemeStyle? error;

  /// The shape of the notification container.
  ///
  /// When null, a superellipse with a medium corner radius.
  final OutlinedBorder? shape;

  /// The padding between the container edge and its content.
  final EdgeInsetsGeometry? padding;

  /// The gap between the icon and the text.
  final double? spacing;

  /// Size constraints for the notification container.
  ///
  /// When null, a minimum height of 46.
  final BoxConstraints? constraints;

  /// Linearly interpolate between two [StreamInlineNotificationThemeData]
  /// objects.
  static StreamInlineNotificationThemeData? lerp(
    StreamInlineNotificationThemeData? a,
    StreamInlineNotificationThemeData? b,
    double t,
  ) => _$StreamInlineNotificationThemeData.lerp(a, b, t);
}

/// The colors and text styles of one [StreamInlineNotificationType] of
/// [StreamInlineNotification].
///
/// See also:
///
///  * [StreamInlineNotificationThemeData], which holds one of these per type.
@themeGen
@immutable
class StreamInlineNotificationThemeStyle with _$StreamInlineNotificationThemeStyle {
  /// Creates an inline notification style with optional overrides.
  const StreamInlineNotificationThemeStyle({
    this.backgroundColor,
    this.iconColor,
    this.titleTextStyle,
    this.descriptionTextStyle,
  });

  /// The fill behind the notification.
  final Color? backgroundColor;

  /// The color of the leading icon.
  final Color? iconColor;

  /// The text style of the title, including its color.
  final TextStyle? titleTextStyle;

  /// The text style of the description, including its color.
  final TextStyle? descriptionTextStyle;

  /// Linearly interpolate between two [StreamInlineNotificationThemeStyle]
  /// objects.
  static StreamInlineNotificationThemeStyle? lerp(
    StreamInlineNotificationThemeStyle? a,
    StreamInlineNotificationThemeStyle? b,
    double t,
  ) => _$StreamInlineNotificationThemeStyle.lerp(a, b, t);
}
