import 'package:flutter/material.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_channel_list_item_theme.dart';
import '../../theme/primitives/stream_spacing.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/semantics/stream_text_theme.dart';
import '../../theme/stream_theme_extensions.dart';
import '../badge/stream_badge_count.dart';

/// A list item for displaying a channel in a channel list.
///
/// [StreamChannelListItem] displays a channel's avatar, title, message preview,
/// timestamp, and unread count in a standard list item layout.
///
/// The [avatar] is passed as a widget, allowing full customization of
/// the avatar appearance (e.g., single user avatar, group avatar, or
/// avatar with online indicator).
///
/// {@tool snippet}
///
/// Basic usage:
///
/// ```dart
/// StreamChannelListItem(
///   avatar: StreamAvatar(placeholder: (context) => Text('AB')),
///   title: 'General',
///   subtitle: 'Hello, how are you?',
///   timestamp: '9:41',
///   unreadCount: 3,
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// With a mute icon after the title:
///
/// ```dart
/// StreamChannelListItem(
///   avatar: StreamAvatar(placeholder: (context) => Text('AB')),
///   title: 'Muted Channel',
///   titleTrailing: Icon(Icons.volume_off, size: 16),
///   subtitle: 'Last message...',
///   timestamp: 'Yesterday',
/// )
/// ```
/// {@end-tool}
///
/// ## Theming
///
/// [StreamChannelListItem] uses [StreamChannelListItemThemeData] for default
/// styling. Colors and text styles are determined by the current
/// [StreamColorScheme] and [StreamTextTheme].
///
/// See also:
///
///  * [StreamChannelListItemThemeData], for customizing appearance.
///  * [StreamChannelListItemTheme], for overriding theme in a widget subtree.
///  * [StreamBadgeCount], which displays the unread count badge.
class StreamChannelListItem extends StatelessWidget {
  /// Creates a channel list item.
  StreamChannelListItem({
    super.key,
    required Widget avatar,
    required String title,
    Widget? titleTrailing,
    String? subtitle,
    Widget? subtitleTrailing,
    String? timestamp,
    int unreadCount = 0,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) : props = StreamChannelListItemProps(
         avatar: avatar,
         title: title,
         titleTrailing: titleTrailing,
         subtitle: subtitle,
         subtitleTrailing: subtitleTrailing,
         timestamp: timestamp,
         unreadCount: unreadCount,
         onTap: onTap,
         onLongPress: onLongPress,
       );

  /// The properties that configure this channel list item.
  final StreamChannelListItemProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.maybeOf(context)?.channelListItem;
    if (builder != null) return builder(context, props);
    return DefaultStreamChannelListItem(props: props);
  }
}

/// Properties for configuring a [StreamChannelListItem].
///
/// This class holds all the configuration options for a channel list item,
/// allowing them to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamChannelListItem], which uses these properties.
///  * [DefaultStreamChannelListItem], the default implementation.
class StreamChannelListItemProps {
  /// Creates properties for a channel list item.
  const StreamChannelListItemProps({
    required this.avatar,
    required this.title,
    this.titleTrailing,
    this.subtitle,
    this.subtitleTrailing,
    this.timestamp,
    this.unreadCount = 0,
    this.onTap,
    this.onLongPress,
  });

  /// The avatar widget displayed at the leading edge.
  ///
  /// Typically a [StreamAvatar], [StreamAvatarGroup], or an avatar wrapped
  /// in a [StreamOnlineIndicator].
  final Widget avatar;

  /// The channel title text.
  final String title;

  /// An optional widget displayed after the title text.
  ///
  /// Typically used for a mute icon or similar indicator.
  final Widget? titleTrailing;

  /// The message preview text displayed below the title.
  final String? subtitle;

  /// An optional trailing widget in the subtitle row.
  ///
  /// Typically used for a mute icon or similar indicator.
  final Widget? subtitleTrailing;

  /// The formatted timestamp string.
  ///
  /// Displayed in the trailing section of the title row.
  final String? timestamp;

  /// The number of unread messages.
  ///
  /// When greater than zero, a [StreamBadgeCount] is displayed.
  final int unreadCount;

  /// Called when the list item is tapped.
  final VoidCallback? onTap;

  /// Called when the list item is long-pressed.
  final VoidCallback? onLongPress;
}

/// The default implementation of [StreamChannelListItem].
///
/// This widget renders the channel list item with theming support.
/// It's used as the default factory implementation in [StreamComponentFactory].
///
/// See also:
///
///  * [StreamChannelListItem], the public API widget.
///  * [StreamChannelListItemProps], which configures this widget.
class DefaultStreamChannelListItem extends StatefulWidget {
  /// Creates a default channel list item with the given [props].
  const DefaultStreamChannelListItem({super.key, required this.props});

  /// The properties that configure this channel list item.
  final StreamChannelListItemProps props;

  @override
  State<DefaultStreamChannelListItem> createState() => _DefaultStreamChannelListItemState();
}

class _DefaultStreamChannelListItemState extends State<DefaultStreamChannelListItem> {
  var _isHovered = false;
  var _isPressed = false;

  StreamChannelListItemProps get props => widget.props;

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;
    final channelListItemTheme = context.streamChannelListItemTheme;
    final defaults = _StreamChannelListItemThemeDefaults(context);

    final effectiveBackgroundColor = channelListItemTheme.backgroundColor ?? defaults.backgroundColor;
    final effectiveHoverColor = channelListItemTheme.hoverColor ?? defaults.hoverColor;
    final effectivePressedColor = channelListItemTheme.pressedColor ?? defaults.pressedColor;
    final effectiveBorderColor = channelListItemTheme.borderColor ?? defaults.borderColor;
    final effectiveTitleStyle = channelListItemTheme.titleStyle ?? defaults.titleStyle;
    final effectiveSubtitleStyle = channelListItemTheme.subtitleStyle ?? defaults.subtitleStyle;
    final effectiveTimestampStyle = channelListItemTheme.timestampStyle ?? defaults.timestampStyle;

    final background = _isPressed
        ? effectivePressedColor
        : _isHovered
        ? effectiveHoverColor
        : effectiveBackgroundColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: props.onTap,
        onLongPress: props.onLongPress,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(spacing.lg),
          ),
          padding: EdgeInsets.all(spacing.md - 4),
          margin: const EdgeInsets.all(4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: spacing.md,
            children: [
              props.avatar,
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: spacing.xxxs),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: spacing.xxs,
                    children: [
                      _TitleRow(
                        title: props.title,
                        titleTrailing: props.titleTrailing,
                        timestamp: props.timestamp,
                        unreadCount: props.unreadCount,
                        titleStyle: effectiveTitleStyle,
                        timestampStyle: effectiveTimestampStyle,
                        spacing: spacing,
                      ),
                      if (props.subtitle != null)
                        _SubtitleRow(
                          subtitle: props.subtitle!,
                          subtitleTrailing: props.subtitleTrailing,
                          subtitleStyle: effectiveSubtitleStyle,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TitleRow extends StatelessWidget {
  const _TitleRow({
    required this.title,
    this.titleTrailing,
    this.timestamp,
    required this.unreadCount,
    required this.titleStyle,
    required this.timestampStyle,
    required this.spacing,
  });

  final String title;
  final Widget? titleTrailing;
  final String? timestamp;
  final int unreadCount;
  final TextStyle titleStyle;
  final TextStyle timestampStyle;
  final StreamSpacing spacing;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: spacing.md,
      children: [
        Expanded(
          child: Row(
            spacing: spacing.xxs,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: titleStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ?titleTrailing,
            ],
          ),
        ),
        if (timestamp != null || unreadCount > 0)
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: spacing.xs,
            children: [
              if (timestamp != null) Text(timestamp!, style: timestampStyle),
              if (unreadCount > 0) StreamBadgeCount(label: '$unreadCount'),
            ],
          ),
      ],
    );
  }
}

class _SubtitleRow extends StatelessWidget {
  const _SubtitleRow({
    required this.subtitle,
    this.subtitleTrailing,
    required this.subtitleStyle,
  });

  final String subtitle;
  final Widget? subtitleTrailing;
  final TextStyle subtitleStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            subtitle,
            style: subtitleStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ?subtitleTrailing,
      ],
    );
  }
}

class _StreamChannelListItemThemeDefaults extends StreamChannelListItemThemeData {
  _StreamChannelListItemThemeDefaults(this._context);

  final BuildContext _context;

  late final _colorScheme = _context.streamColorScheme;
  late final _textTheme = _context.streamTextTheme;

  @override
  TextStyle get titleStyle => _textTheme.headingSm.copyWith(color: _colorScheme.textPrimary);

  @override
  TextStyle get subtitleStyle => _textTheme.captionDefault.copyWith(color: _colorScheme.textSecondary);

  @override
  TextStyle get timestampStyle => _textTheme.captionDefault.copyWith(color: _colorScheme.textTertiary);

  @override
  Color get backgroundColor => _colorScheme.backgroundApp;

  @override
  Color get hoverColor => _colorScheme.stateHover;

  @override
  Color get pressedColor => _colorScheme.statePressed;

  @override
  Color get borderColor => _colorScheme.borderSubtle;
}
