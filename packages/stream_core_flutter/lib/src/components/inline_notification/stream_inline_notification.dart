import 'package:flutter/material.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_inline_notification_theme.dart';
import '../../theme/primitives/stream_radius.dart';
import '../../theme/primitives/stream_spacing.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/semantics/stream_text_theme.dart';
import '../../theme/stream_theme_extensions.dart';

/// A message box, colored by its type, that sits inline with the content it
/// describes.
///
/// [StreamInlineNotification] shows a short `title`, an optional
/// `description` and a leading icon for its `type`. Use it for context or
/// validation messages that belong to a specific part of a screen. For
/// system-wide states that block the experience, consider [StreamBanner]; for
/// transient feedback, consider [StreamSnackbar]. Takes the full width of its
/// parent.
///
/// The notification is marked as a live region, so assistive technologies may
/// announce it when it appears and when its text changes. Show it in response
/// to something, such as a failed action, rather than as a static note. The
/// default icons have no label, so let the text say what kind of message it is.
///
/// {@tool snippet}
///
/// Confirm that a change was saved:
///
/// ```dart
/// StreamInlineNotification(
///   type: StreamInlineNotificationType.success,
///   title: const Text('Changes saved'),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Report an error:
///
/// ```dart
/// StreamInlineNotification(
///   type: StreamInlineNotificationType.error,
///   title: const Text("Couldn't load content"),
///   description: const Text('Check your connection and try again.'),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamInlineNotificationType], which defines the available types.
///  * [StreamInlineNotificationTheme], for customizing the appearance.
///  * [StreamBanner], for system-level states.
class StreamInlineNotification extends StatelessWidget {
  /// Creates an inline notification.
  StreamInlineNotification({
    super.key,
    required Widget title,
    Widget? description,
    StreamInlineNotificationType type = .info,
    Widget? icon,
    bool showIcon = true,
  }) : props = .new(
         title: title,
         description: description,
         type: type,
         icon: icon,
         showIcon: showIcon,
       );

  /// The properties that configure this inline notification.
  final StreamInlineNotificationProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).inlineNotification;
    if (builder != null) return builder(context, props);
    return DefaultStreamInlineNotification(props: props);
  }
}

/// Properties for configuring a [StreamInlineNotification].
///
/// This class holds all the configuration options for an inline notification,
/// allowing them to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamInlineNotification], which uses these properties.
///  * [DefaultStreamInlineNotification], the default implementation.
class StreamInlineNotificationProps {
  /// Creates properties for an inline notification.
  const StreamInlineNotificationProps({
    required this.title,
    this.description,
    this.type = .info,
    this.icon,
    this.showIcon = true,
  });

  /// The primary message.
  ///
  /// Typically a [Text]; the notification provides its text style and lets it
  /// wrap.
  final Widget title;

  /// Supporting text shown under [title].
  ///
  /// When null, only the title is shown.
  final Widget? description;

  /// The kind of message, which picks the leading icon and the colors.
  final StreamInlineNotificationType type;

  /// A leading icon that replaces the default one for [type].
  ///
  /// Typically an [Icon]; the notification provides its size and color.
  final Widget? icon;

  /// Whether to show the leading icon.
  ///
  /// When false, [icon] is ignored.
  final bool showIcon;
}

/// The default implementation of [StreamInlineNotification].
///
/// See also:
///
///  * [StreamInlineNotification], the public API widget.
///  * [StreamInlineNotificationProps], which configures this widget.
class DefaultStreamInlineNotification extends StatelessWidget {
  /// Creates a default inline notification with the given [props].
  const DefaultStreamInlineNotification({super.key, required this.props});

  /// The properties that configure this inline notification.
  final StreamInlineNotificationProps props;

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;
    final icons = context.streamIcons;

    final theme = context.streamInlineNotificationTheme;
    final defaults = _StreamInlineNotificationThemeDefaults(context);
    final (style, defaultStyle) = switch (props.type) {
      .info => (theme.info, defaults.info),
      .success => (theme.success, defaults.success),
      .warning => (theme.warning, defaults.warning),
      .error => (theme.error, defaults.error),
    };

    final effectiveBackgroundColor = style?.backgroundColor ?? defaultStyle.backgroundColor;
    final effectiveIconColor = style?.iconColor ?? defaultStyle.iconColor;
    final effectiveTitleTextStyle = style?.titleTextStyle ?? defaultStyle.titleTextStyle;
    final descriptionStyle = style?.descriptionTextStyle;
    final effectiveDescriptionStyle = descriptionStyle ?? defaultStyle.descriptionTextStyle;
    final effectiveShape = theme.shape ?? defaults.shape;
    final effectivePadding = theme.padding ?? defaults.padding;
    final effectiveSpacing = theme.spacing ?? defaults.spacing;
    final effectiveConstraints = theme.constraints ?? defaults.constraints;

    final defaultIcon = switch (props.type) {
      .info => icons.info,
      .success => icons.checkmark,
      .warning => icons.exclamationTriangleFill,
      .error => icons.exclamationCircle,
    };

    return Semantics(
      container: true,
      liveRegion: true,
      child: ConstrainedBox(
        constraints: effectiveConstraints,
        child: Material(
          shape: effectiveShape,
          color: effectiveBackgroundColor,
          child: Padding(
            padding: effectivePadding,
            child: Row(
              spacing: effectiveSpacing,
              children: [
                if (props.showIcon)
                  IconTheme.merge(
                    data: IconThemeData(size: 20, color: effectiveIconColor),
                    child: props.icon ?? Icon(defaultIcon),
                  ),
                Expanded(
                  child: Column(
                    mainAxisSize: .min,
                    crossAxisAlignment: .start,
                    spacing: spacing.xxxs,
                    children: [
                      DefaultTextStyle(
                        style: effectiveTitleTextStyle,
                        child: props.title,
                      ),
                      if (props.description case final description?)
                        DefaultTextStyle(
                          style: effectiveDescriptionStyle,
                          child: description,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Default theme values for [StreamInlineNotification].
//
// Used when the theme doesn't provide a value. Each type's colors and text
// styles come from [_StreamInlineNotificationStyleDefaults].
class _StreamInlineNotificationThemeDefaults extends StreamInlineNotificationThemeData {
  _StreamInlineNotificationThemeDefaults(this._context);

  final BuildContext _context;

  late final StreamSpacing _spacing = _context.streamSpacing;
  late final StreamRadius _radius = _context.streamRadius;

  @override
  _StreamInlineNotificationStyleDefaults get info => .new(_context, .info);

  @override
  _StreamInlineNotificationStyleDefaults get success => .new(_context, .success);

  @override
  _StreamInlineNotificationStyleDefaults get warning => .new(_context, .warning);

  @override
  _StreamInlineNotificationStyleDefaults get error => .new(_context, .error);

  @override
  OutlinedBorder get shape => RoundedSuperellipseBorder(borderRadius: .all(_radius.md));

  @override
  EdgeInsetsGeometry get padding => EdgeInsets.all(_spacing.sm);

  @override
  double get spacing => _spacing.xs;

  // Taller than the padding and icon need (44), to match the design.
  @override
  BoxConstraints get constraints => const BoxConstraints(minHeight: 46);
}

// Default colors and text styles for one [StreamInlineNotificationType].
//
// The types differ only in their colors; they share the same text styles.
class _StreamInlineNotificationStyleDefaults extends StreamInlineNotificationThemeStyle {
  _StreamInlineNotificationStyleDefaults(this._context, this._type);

  final BuildContext _context;
  final StreamInlineNotificationType _type;

  late final StreamColorScheme _colorScheme = _context.streamColorScheme;
  late final StreamTextTheme _textTheme = _context.streamTextTheme;

  @override
  Color get backgroundColor => switch (_type) {
    .info => _colorScheme.backgroundInfoSubtle,
    .success => _colorScheme.backgroundSuccessSubtle,
    .warning => _colorScheme.backgroundWarningSubtle,
    .error => _colorScheme.backgroundErrorSubtle,
  };

  @override
  Color get iconColor => switch (_type) {
    .info => _colorScheme.accentPrimary,
    .success => _colorScheme.accentSuccess,
    .warning => _colorScheme.accentWarning,
    .error => _colorScheme.accentError,
  };

  @override
  TextStyle get titleTextStyle => _textTheme.metadataEmphasis.copyWith(
    color: _colorScheme.textPrimary,
  );

  @override
  TextStyle get descriptionTextStyle => _textTheme.metadataDefault.copyWith(
    color: _colorScheme.textSecondary,
  );
}
