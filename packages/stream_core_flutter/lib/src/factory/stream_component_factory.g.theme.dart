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
      appBar: t < 0.5 ? a.appBar : b.appBar,
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
      loadingSpinner: t < 0.5 ? a.loadingSpinner : b.loadingSpinner,
      messageAnnotation: t < 0.5 ? a.messageAnnotation : b.messageAnnotation,
      messageBubble: t < 0.5 ? a.messageBubble : b.messageBubble,
      messageContent: t < 0.5 ? a.messageContent : b.messageContent,
      messageMetadata: t < 0.5 ? a.messageMetadata : b.messageMetadata,
      messageReplies: t < 0.5 ? a.messageReplies : b.messageReplies,
      messageText: t < 0.5 ? a.messageText : b.messageText,
      networkImage: t < 0.5 ? a.networkImage : b.networkImage,
      onlineIndicator: t < 0.5 ? a.onlineIndicator : b.onlineIndicator,
      progressBar: t < 0.5 ? a.progressBar : b.progressBar,
      reactionPicker: t < 0.5 ? a.reactionPicker : b.reactionPicker,
      reactions: t < 0.5 ? a.reactions : b.reactions,
      retryBadge: t < 0.5 ? a.retryBadge : b.retryBadge,
      skeletonLoading: t < 0.5 ? a.skeletonLoading : b.skeletonLoading,
    );
  }

  StreamComponentBuilders copyWith({
    Map<Object, StreamComponentBuilderExtension<Object>>? extensions,
    Widget Function(BuildContext, StreamAppBarProps)? appBar,
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
    Widget Function(BuildContext, StreamLoadingSpinnerProps)? loadingSpinner,
    Widget Function(BuildContext, StreamMessageAnnotationProps)?
    messageAnnotation,
    Widget Function(BuildContext, StreamMessageBubbleProps)? messageBubble,
    Widget Function(BuildContext, StreamMessageContentProps)? messageContent,
    Widget Function(BuildContext, StreamMessageMetadataProps)? messageMetadata,
    Widget Function(BuildContext, StreamMessageRepliesProps)? messageReplies,
    Widget Function(BuildContext, StreamMessageTextProps)? messageText,
    Widget Function(BuildContext, StreamNetworkImageProps)? networkImage,
    Widget Function(BuildContext, StreamOnlineIndicatorProps)? onlineIndicator,
    Widget Function(BuildContext, StreamProgressBarProps)? progressBar,
    Widget Function(BuildContext, StreamReactionPickerProps)? reactionPicker,
    Widget Function(BuildContext, StreamReactionsProps)? reactions,
    Widget Function(BuildContext, StreamRetryBadgeProps)? retryBadge,
    Widget Function(BuildContext, StreamSkeletonLoadingProps)? skeletonLoading,
  }) {
    final _this = (this as StreamComponentBuilders);

    return StreamComponentBuilders.raw(
      extensions: extensions ?? _this.extensions,
      appBar: appBar ?? _this.appBar,
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
      loadingSpinner: loadingSpinner ?? _this.loadingSpinner,
      messageAnnotation: messageAnnotation ?? _this.messageAnnotation,
      messageBubble: messageBubble ?? _this.messageBubble,
      messageContent: messageContent ?? _this.messageContent,
      messageMetadata: messageMetadata ?? _this.messageMetadata,
      messageReplies: messageReplies ?? _this.messageReplies,
      messageText: messageText ?? _this.messageText,
      networkImage: networkImage ?? _this.networkImage,
      onlineIndicator: onlineIndicator ?? _this.onlineIndicator,
      progressBar: progressBar ?? _this.progressBar,
      reactionPicker: reactionPicker ?? _this.reactionPicker,
      reactions: reactions ?? _this.reactions,
      retryBadge: retryBadge ?? _this.retryBadge,
      skeletonLoading: skeletonLoading ?? _this.skeletonLoading,
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
      appBar: other.appBar,
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
      loadingSpinner: other.loadingSpinner,
      messageAnnotation: other.messageAnnotation,
      messageBubble: other.messageBubble,
      messageContent: other.messageContent,
      messageMetadata: other.messageMetadata,
      messageReplies: other.messageReplies,
      messageText: other.messageText,
      networkImage: other.networkImage,
      onlineIndicator: other.onlineIndicator,
      progressBar: other.progressBar,
      reactionPicker: other.reactionPicker,
      reactions: other.reactions,
      retryBadge: other.retryBadge,
      skeletonLoading: other.skeletonLoading,
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
        _other.appBar == _this.appBar &&
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
        _other.loadingSpinner == _this.loadingSpinner &&
        _other.messageAnnotation == _this.messageAnnotation &&
        _other.messageBubble == _this.messageBubble &&
        _other.messageContent == _this.messageContent &&
        _other.messageMetadata == _this.messageMetadata &&
        _other.messageReplies == _this.messageReplies &&
        _other.messageText == _this.messageText &&
        _other.networkImage == _this.networkImage &&
        _other.onlineIndicator == _this.onlineIndicator &&
        _other.progressBar == _this.progressBar &&
        _other.reactionPicker == _this.reactionPicker &&
        _other.reactions == _this.reactions &&
        _other.retryBadge == _this.retryBadge &&
        _other.skeletonLoading == _this.skeletonLoading;
  }

  @override
  int get hashCode {
    final _this = (this as StreamComponentBuilders);

    return Object.hashAll([
      runtimeType,
      _this.extensions,
      _this.appBar,
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
      _this.loadingSpinner,
      _this.messageAnnotation,
      _this.messageBubble,
      _this.messageContent,
      _this.messageMetadata,
      _this.messageReplies,
      _this.messageText,
      _this.networkImage,
      _this.onlineIndicator,
      _this.progressBar,
      _this.reactionPicker,
      _this.reactions,
      _this.retryBadge,
      _this.skeletonLoading,
    ]);
  }
}
