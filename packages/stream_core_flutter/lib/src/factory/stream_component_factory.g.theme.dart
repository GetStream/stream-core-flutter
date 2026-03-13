// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_component_factory.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamComponentBuilders {
  bool get canMerge => true;

  static StreamComponentBuilders? lerp(
    StreamComponentBuilders? a,
    StreamComponentBuilders? b,
    double t,
  ) {
    if (identical(a, b)) {
      return a;
    }

    if (a == null) {
      return t == 1.0 ? b : null;
    }

    if (b == null) {
      return t == 0.0 ? a : null;
    }

    return StreamComponentBuilders.raw(
      extensions: t < 0.5 ? a.extensions : b.extensions,
      avatar: t < 0.5 ? a.avatar : b.avatar,
      avatarGroup: t < 0.5 ? a.avatarGroup : b.avatarGroup,
      avatarStack: t < 0.5 ? a.avatarStack : b.avatarStack,
      badgeCount: t < 0.5 ? a.badgeCount : b.badgeCount,
      badgeNotification: t < 0.5 ? a.badgeNotification : b.badgeNotification,
      button: t < 0.5 ? a.button : b.button,
      checkbox: t < 0.5 ? a.checkbox : b.checkbox,
      commandChip: t < 0.5 ? a.commandChip : b.commandChip,
      contextMenuAction: t < 0.5 ? a.contextMenuAction : b.contextMenuAction,
      emoji: t < 0.5 ? a.emoji : b.emoji,
      emojiButton: t < 0.5 ? a.emojiButton : b.emojiButton,
      emojiChip: t < 0.5 ? a.emojiChip : b.emojiChip,
      emojiChipBar: t < 0.5 ? a.emojiChipBar : b.emojiChipBar,
      fileTypeIcon: t < 0.5 ? a.fileTypeIcon : b.fileTypeIcon,
      listTile: t < 0.5 ? a.listTile : b.listTile,
      onlineIndicator: t < 0.5 ? a.onlineIndicator : b.onlineIndicator,
      progressBar: t < 0.5 ? a.progressBar : b.progressBar,
      reactions: t < 0.5 ? a.reactions : b.reactions,
    );
  }

  StreamComponentBuilders copyWith({
    Map<Object, StreamComponentBuilderExtension<Object>>? extensions,
    Widget Function(BuildContext, StreamAvatarProps)? avatar,
    Widget Function(BuildContext, StreamAvatarGroupProps)? avatarGroup,
    Widget Function(BuildContext, StreamAvatarStackProps)? avatarStack,
    Widget Function(BuildContext, StreamBadgeCountProps)? badgeCount,
    Widget Function(BuildContext, StreamBadgeNotificationProps)?
    badgeNotification,
    Widget Function(BuildContext, StreamButtonProps)? button,
    Widget Function(BuildContext, StreamCheckboxProps)? checkbox,
    Widget Function(BuildContext, StreamCommandChipProps)? commandChip,
    Widget Function(BuildContext, StreamContextMenuActionProps<Object?>)?
    contextMenuAction,
    Widget Function(BuildContext, StreamEmojiProps)? emoji,
    Widget Function(BuildContext, StreamEmojiButtonProps)? emojiButton,
    Widget Function(BuildContext, StreamEmojiChipProps)? emojiChip,
    Widget Function(BuildContext, StreamEmojiChipBarProps<Object?>)?
    emojiChipBar,
    Widget Function(BuildContext, StreamFileTypeIconProps)? fileTypeIcon,
    Widget Function(BuildContext, StreamListTileProps)? listTile,
    Widget Function(BuildContext, StreamOnlineIndicatorProps)? onlineIndicator,
    Widget Function(BuildContext, StreamProgressBarProps)? progressBar,
    Widget Function(BuildContext, StreamReactionsProps)? reactions,
  }) {
    final _this = (this as StreamComponentBuilders);

    return StreamComponentBuilders.raw(
      extensions: extensions ?? _this.extensions,
      avatar: avatar ?? _this.avatar,
      avatarGroup: avatarGroup ?? _this.avatarGroup,
      avatarStack: avatarStack ?? _this.avatarStack,
      badgeCount: badgeCount ?? _this.badgeCount,
      badgeNotification: badgeNotification ?? _this.badgeNotification,
      button: button ?? _this.button,
      checkbox: checkbox ?? _this.checkbox,
      commandChip: commandChip ?? _this.commandChip,
      contextMenuAction: contextMenuAction ?? _this.contextMenuAction,
      emoji: emoji ?? _this.emoji,
      emojiButton: emojiButton ?? _this.emojiButton,
      emojiChip: emojiChip ?? _this.emojiChip,
      emojiChipBar: emojiChipBar ?? _this.emojiChipBar,
      fileTypeIcon: fileTypeIcon ?? _this.fileTypeIcon,
      listTile: listTile ?? _this.listTile,
      onlineIndicator: onlineIndicator ?? _this.onlineIndicator,
      progressBar: progressBar ?? _this.progressBar,
      reactions: reactions ?? _this.reactions,
    );
  }

  StreamComponentBuilders merge(StreamComponentBuilders? other) {
    final _this = (this as StreamComponentBuilders);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      extensions: other.extensions,
      avatar: other.avatar,
      avatarGroup: other.avatarGroup,
      avatarStack: other.avatarStack,
      badgeCount: other.badgeCount,
      badgeNotification: other.badgeNotification,
      button: other.button,
      checkbox: other.checkbox,
      commandChip: other.commandChip,
      contextMenuAction: other.contextMenuAction,
      emoji: other.emoji,
      emojiButton: other.emojiButton,
      emojiChip: other.emojiChip,
      emojiChipBar: other.emojiChipBar,
      fileTypeIcon: other.fileTypeIcon,
      listTile: other.listTile,
      onlineIndicator: other.onlineIndicator,
      progressBar: other.progressBar,
      reactions: other.reactions,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other.runtimeType != runtimeType) {
      return false;
    }

    final _this = (this as StreamComponentBuilders);
    final _other = (other as StreamComponentBuilders);

    return _other.extensions == _this.extensions &&
        _other.avatar == _this.avatar &&
        _other.avatarGroup == _this.avatarGroup &&
        _other.avatarStack == _this.avatarStack &&
        _other.badgeCount == _this.badgeCount &&
        _other.badgeNotification == _this.badgeNotification &&
        _other.button == _this.button &&
        _other.checkbox == _this.checkbox &&
        _other.commandChip == _this.commandChip &&
        _other.contextMenuAction == _this.contextMenuAction &&
        _other.emoji == _this.emoji &&
        _other.emojiButton == _this.emojiButton &&
        _other.emojiChip == _this.emojiChip &&
        _other.emojiChipBar == _this.emojiChipBar &&
        _other.fileTypeIcon == _this.fileTypeIcon &&
        _other.listTile == _this.listTile &&
        _other.onlineIndicator == _this.onlineIndicator &&
        _other.progressBar == _this.progressBar &&
        _other.reactions == _this.reactions;
  }

  @override
  int get hashCode {
    final _this = (this as StreamComponentBuilders);

    return Object.hash(
      runtimeType,
      _this.extensions,
      _this.avatar,
      _this.avatarGroup,
      _this.avatarStack,
      _this.badgeCount,
      _this.badgeNotification,
      _this.button,
      _this.checkbox,
      _this.commandChip,
      _this.contextMenuAction,
      _this.emoji,
      _this.emojiButton,
      _this.emojiChip,
      _this.emojiChipBar,
      _this.fileTypeIcon,
      _this.listTile,
      _this.onlineIndicator,
      _this.progressBar,
      _this.reactions,
    );
  }
}
