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

    return StreamComponentBuilders(
      avatar: t < 0.5 ? a.avatar : b.avatar,
      avatarGroup: t < 0.5 ? a.avatarGroup : b.avatarGroup,
      avatarStack: t < 0.5 ? a.avatarStack : b.avatarStack,
      badgeCount: t < 0.5 ? a.badgeCount : b.badgeCount,
      button: t < 0.5 ? a.button : b.button,
      emoji: t < 0.5 ? a.emoji : b.emoji,
      emojiButton: t < 0.5 ? a.emojiButton : b.emojiButton,
      fileTypeIcon: t < 0.5 ? a.fileTypeIcon : b.fileTypeIcon,
      onlineIndicator: t < 0.5 ? a.onlineIndicator : b.onlineIndicator,
    );
  }

  StreamComponentBuilders copyWith({
    Widget Function(BuildContext, StreamAvatarProps)? avatar,
    Widget Function(BuildContext, StreamAvatarGroupProps)? avatarGroup,
    Widget Function(BuildContext, StreamAvatarStackProps)? avatarStack,
    Widget Function(BuildContext, StreamBadgeCountProps)? badgeCount,
    Widget Function(BuildContext, StreamButtonProps)? button,
    Widget Function(BuildContext, StreamEmojiProps)? emoji,
    Widget Function(BuildContext, StreamEmojiButtonProps)? emojiButton,
    Widget Function(BuildContext, StreamFileTypeIconProps)? fileTypeIcon,
    Widget Function(BuildContext, StreamOnlineIndicatorProps)? onlineIndicator,
  }) {
    final _this = (this as StreamComponentBuilders);

    return StreamComponentBuilders(
      avatar: avatar ?? _this.avatar,
      avatarGroup: avatarGroup ?? _this.avatarGroup,
      avatarStack: avatarStack ?? _this.avatarStack,
      badgeCount: badgeCount ?? _this.badgeCount,
      button: button ?? _this.button,
      emoji: emoji ?? _this.emoji,
      emojiButton: emojiButton ?? _this.emojiButton,
      fileTypeIcon: fileTypeIcon ?? _this.fileTypeIcon,
      onlineIndicator: onlineIndicator ?? _this.onlineIndicator,
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
      avatar: other.avatar,
      avatarGroup: other.avatarGroup,
      avatarStack: other.avatarStack,
      badgeCount: other.badgeCount,
      button: other.button,
      emoji: other.emoji,
      emojiButton: other.emojiButton,
      fileTypeIcon: other.fileTypeIcon,
      onlineIndicator: other.onlineIndicator,
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

    return _other.avatar == _this.avatar &&
        _other.avatarGroup == _this.avatarGroup &&
        _other.avatarStack == _this.avatarStack &&
        _other.badgeCount == _this.badgeCount &&
        _other.button == _this.button &&
        _other.emoji == _this.emoji &&
        _other.emojiButton == _this.emojiButton &&
        _other.fileTypeIcon == _this.fileTypeIcon &&
        _other.onlineIndicator == _this.onlineIndicator;
  }

  @override
  int get hashCode {
    final _this = (this as StreamComponentBuilders);

    return Object.hash(
      runtimeType,
      _this.avatar,
      _this.avatarGroup,
      _this.avatarStack,
      _this.badgeCount,
      _this.button,
      _this.emoji,
      _this.emojiButton,
      _this.fileTypeIcon,
      _this.onlineIndicator,
    );
  }
}
