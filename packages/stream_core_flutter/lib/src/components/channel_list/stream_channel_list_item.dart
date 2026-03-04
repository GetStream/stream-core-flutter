import 'package:flutter/material.dart';

import '../../../stream_core_flutter.dart';
import '../list/stream_list_tile.dart' show ListTileContainer;

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
///   title: Text('General'),
///   subtitle: Text('Hello, how are you?'),
///   timestamp: Text('9:41'),
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
///   title: Text('Muted Channel'),
///   titleTrailing: Icon(Icons.volume_off, size: 16),
///   subtitle: Text('Last message...'),
///   timestamp: Text('Yesterday'),
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
///  * [StreamBadgeNotification], which displays the unread count badge.
class StreamChannelListItem extends StatelessWidget {
  /// Creates a channel list item.
  StreamChannelListItem({
    super.key,
    required Widget avatar,
    required Widget title,
    Widget? subtitle,
    Widget? timestamp,
    int unreadCount = 0,
    bool isMuted = false,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    bool selected = false,
  }) : props = StreamChannelListItemProps(
         avatar: avatar,
         title: title,
         subtitle: subtitle,
         timestamp: timestamp,
         unreadCount: unreadCount,
         isMuted: isMuted,
         onTap: onTap,
         onLongPress: onLongPress,
         selected: selected,
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
    this.subtitle,
    this.timestamp,
    this.unreadCount = 0,
    this.isMuted = false,
    this.onTap,
    this.onLongPress,
    this.selected = false,
  });

  /// The avatar widget displayed at the leading edge.
  ///
  /// Typically a [StreamAvatar], [StreamAvatarGroup], or an avatar wrapped
  /// in a [StreamOnlineIndicator].
  final Widget avatar;

  /// The channel title widget.
  ///
  /// Typically a [Text] widget with the channel name. The default text style
  /// is provided by the theme's title style via [DefaultTextStyle].
  final Widget title;

  /// The message preview widget displayed below the title.
  ///
  /// Typically a [Text] widget with the last message, but can be any widget
  /// for richer content (e.g., icons, read receipts, sender prefix).
  final Widget? subtitle;

  /// The timestamp widget displayed in the trailing section of the title row.
  ///
  /// Typically a [Text] widget with a formatted date string. The default text
  /// style is provided by the theme's timestamp style via [DefaultTextStyle].
  final Widget? timestamp;

  /// The number of unread messages.
  ///
  /// When greater than zero, a [StreamBadgeNotification] is displayed.
  final int unreadCount;

  /// Whether the channel is muted.
  ///
  /// When true, a mute icon is displayed in the title or subtitle.
  final bool isMuted;

  /// Called when the list item is tapped.
  final VoidCallback? onTap;

  /// Called when the list item is long-pressed.
  final VoidCallback? onLongPress;

  /// Whether the list item is in a selected state.
  final bool selected;
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
  StreamChannelListItemProps get props => widget.props;

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;
    final channelListItemTheme = context.streamChannelListItemTheme;
    final defaults = _StreamChannelListItemThemeDefaults(context);

    final effectiveTitleStyle = channelListItemTheme.titleStyle ?? defaults.titleStyle;
    final effectiveSubtitleStyle = channelListItemTheme.subtitleStyle ?? defaults.subtitleStyle;
    final effectiveTimestampStyle = channelListItemTheme.timestampStyle ?? defaults.timestampStyle;
    final effectiveMuteIconPosition = channelListItemTheme.muteIconPosition ?? defaults.muteIconPosition;

    final muteIcon = props.isMuted
        ? Icon(
            context.streamIcons.mute,
            size: 20,
            color: context.streamColorScheme.textTertiary,
          )
        : null;

    final hasMuteIconInSubtitle = effectiveMuteIconPosition == MuteIconPosition.subtitle && props.isMuted;

    return StreamListTileTheme(
      data: context.streamListTileTheme.copyWith(contentPadding: EdgeInsets.all(spacing.md - 4)),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Material(
          type: MaterialType.transparency,
          child: ListTileContainer(
            enabled: true,
            selected: props.selected,
            onTap: props.onTap,
            onLongPress: props.onLongPress,
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
                          titleTrailing: effectiveMuteIconPosition == MuteIconPosition.title ? muteIcon : null,
                          timestamp: props.timestamp,
                          unreadCount: props.unreadCount,
                          titleStyle: effectiveTitleStyle,
                          timestampStyle: effectiveTimestampStyle,
                          spacing: spacing,
                        ),
                        if (props.subtitle != null || hasMuteIconInSubtitle)
                          _SubtitleRow(
                            subtitle: props.subtitle,
                            subtitleTrailing: effectiveMuteIconPosition == MuteIconPosition.subtitle ? muteIcon : null,
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

  final Widget title;
  final Widget? titleTrailing;
  final Widget? timestamp;
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
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: StreamBadgeNotificationSize.sm.value),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    widthFactor: 1,
                    child: DefaultTextStyle.merge(
                      style: titleStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      child: title,
                    ),
                  ),
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
              if (timestamp case final timestamp?)
                DefaultTextStyle.merge(
                  style: timestampStyle,
                  child: timestamp,
                ),
              if (unreadCount > 0) StreamBadgeNotification(label: '$unreadCount'),
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

  final Widget? subtitle;
  final Widget? subtitleTrailing;
  final TextStyle subtitleStyle;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: subtitleStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      child: Row(
        children: [
          Expanded(child: subtitle ?? const SizedBox.shrink()),
          ?subtitleTrailing,
        ],
      ),
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

  @override
  MuteIconPosition get muteIconPosition => MuteIconPosition.title;
}
