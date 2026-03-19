import 'package:flutter/material.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_badge_notification_theme.dart';
import '../../theme/primitives/stream_spacing.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/semantics/stream_text_theme.dart';
import '../../theme/stream_theme_extensions.dart';

/// A notification badge for displaying counts in colored pill shapes.
///
/// [StreamBadgeNotification] displays a count label in a colored pill-shaped
/// badge with a border. It's used in channel list items and other places to
/// indicate unread messages or pending notifications.
///
/// Unlike [StreamBadgeCount], which uses neutral colors, this badge uses
/// prominent colored backgrounds (primary, error, neutral) to draw attention.
///
/// The badge has three visual types controlled by
/// [StreamBadgeNotificationType]:
///
///  * [StreamBadgeNotificationType.primary] — Brand accent background.
///  * [StreamBadgeNotificationType.error] — Error/red background.
///  * [StreamBadgeNotificationType.neutral] — Muted gray background.
///
/// {@tool snippet}
///
/// Basic usage with unread count:
///
/// ```dart
/// StreamBadgeNotification(label: '3')
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Error variant:
///
/// ```dart
/// StreamBadgeNotification(
///   label: '!',
///   type: StreamBadgeNotificationType.error,
/// )
/// ```
/// {@end-tool}
///
/// ## Theming
///
/// [StreamBadgeNotification] uses [StreamBadgeNotificationThemeData] for
/// default styling. Colors are determined by the current [StreamColorScheme].
///
/// See also:
///
///  * [StreamBadgeNotificationSize], the available size variants.
///  * [StreamBadgeNotificationType], the available style variants.
///  * [StreamBadgeNotificationThemeData], for customizing appearance.
///  * [StreamBadgeNotificationTheme], for overriding theme in a subtree.
///  * [StreamBadgeCount], a neutral count badge without colored backgrounds.
class StreamBadgeNotification extends StatelessWidget {
  /// Creates a badge notification indicator.
  StreamBadgeNotification({
    super.key,
    StreamBadgeNotificationType? type,
    StreamBadgeNotificationSize? size,
    required String label,
  }) : props = StreamBadgeNotificationProps(
         type: type,
         size: size,
         label: label,
       );

  /// The properties that configure this badge notification.
  final StreamBadgeNotificationProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).badgeNotification;
    if (builder != null) return builder(context, props);
    return DefaultStreamBadgeNotification(props: props);
  }
}

/// Properties for configuring a [StreamBadgeNotification].
///
/// This class holds all the configuration options for a badge notification,
/// allowing them to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamBadgeNotification], which uses these properties.
///  * [DefaultStreamBadgeNotification], the default implementation.
class StreamBadgeNotificationProps {
  /// Creates properties for a badge notification.
  const StreamBadgeNotificationProps({
    this.type,
    this.size,
    required this.label,
  });

  /// The visual type determining the badge background color.
  ///
  /// If null, defaults to [StreamBadgeNotificationType.primary].
  final StreamBadgeNotificationType? type;

  /// The size of the badge.
  ///
  /// If null, uses [StreamBadgeNotificationThemeData.size], or falls back to
  /// [StreamBadgeNotificationSize.sm].
  final StreamBadgeNotificationSize? size;

  /// The text label to display in the badge.
  ///
  /// Typically a numeric count (e.g., "5") or an overflow indicator
  /// (e.g., "99+").
  final String label;
}

/// The default implementation of [StreamBadgeNotification].
///
/// This widget renders the badge notification with theming support.
/// It's used as the default factory implementation in
/// [StreamComponentFactory].
///
/// See also:
///
///  * [StreamBadgeNotification], the public API widget.
///  * [StreamBadgeNotificationProps], which configures this widget.
class DefaultStreamBadgeNotification extends StatelessWidget {
  /// Creates a default badge notification with the given [props].
  const DefaultStreamBadgeNotification({super.key, required this.props});

  /// The properties that configure this badge notification.
  final StreamBadgeNotificationProps props;

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;
    final textTheme = context.streamTextTheme;

    final theme = context.streamBadgeNotificationTheme;
    final defaults = _StreamBadgeNotificationThemeDefaults(context);

    final effectiveSize = props.size ?? theme.size ?? defaults.size;
    final effectiveType = props.type ?? StreamBadgeNotificationType.primary;
    final effectiveTextColor = theme.textColor ?? defaults.textColor;
    final effectiveBorderColor = theme.borderColor ?? defaults.borderColor;
    final effectiveBackgroundColor = _resolveBackgroundColor(effectiveType, theme, defaults);

    final padding = _paddingForSize(effectiveSize, spacing);
    final textStyle = _textStyleForSize(effectiveSize, textTheme).copyWith(color: effectiveTextColor);

    return IntrinsicWidth(
      child: AnimatedContainer(
        height: effectiveSize.value,
        constraints: BoxConstraints(minWidth: effectiveSize.value),
        padding: padding,
        alignment: Alignment.center,
        clipBehavior: Clip.antiAlias,
        duration: kThemeChangeDuration,
        decoration: ShapeDecoration(
          color: effectiveBackgroundColor,
          shape: const StadiumBorder(),
        ),
        foregroundDecoration: ShapeDecoration(
          shape: StadiumBorder(
            side: BorderSide(
              width: 2,
              color: effectiveBorderColor,
              strokeAlign: BorderSide.strokeAlignOutside,
            ),
          ),
        ),
        child: DefaultTextStyle(
          style: textStyle,
          child: Text(props.label),
        ),
      ),
    );
  }

  Color _resolveBackgroundColor(
    StreamBadgeNotificationType type,
    StreamBadgeNotificationThemeData theme,
    _StreamBadgeNotificationThemeDefaults defaults,
  ) => switch (type) {
    .primary => theme.primaryBackgroundColor ?? defaults.primaryBackgroundColor,
    .error => theme.errorBackgroundColor ?? defaults.errorBackgroundColor,
    .neutral => theme.neutralBackgroundColor ?? defaults.neutralBackgroundColor,
  };

  TextStyle _textStyleForSize(
    StreamBadgeNotificationSize size,
    StreamTextTheme textTheme,
  ) => switch (size) {
    .xs => textTheme.numericMd,
    .sm => textTheme.numericXl,
  };

  EdgeInsetsGeometry _paddingForSize(
    StreamBadgeNotificationSize size,
    StreamSpacing spacing,
  ) => switch (size) {
    .xs => EdgeInsets.symmetric(horizontal: spacing.xxs),
    .sm => EdgeInsets.symmetric(horizontal: spacing.xxs),
  };
}

class _StreamBadgeNotificationThemeDefaults extends StreamBadgeNotificationThemeData {
  _StreamBadgeNotificationThemeDefaults(this._context);

  final BuildContext _context;

  late final _colorScheme = _context.streamColorScheme;

  @override
  StreamBadgeNotificationSize get size => .sm;

  @override
  Color get primaryBackgroundColor => _colorScheme.accentPrimary;

  @override
  Color get errorBackgroundColor => _colorScheme.accentError;

  @override
  Color get neutralBackgroundColor => _colorScheme.accentNeutral;

  @override
  Color get textColor => _colorScheme.textOnAccent;

  @override
  Color get borderColor => _colorScheme.borderInverse;
}
