// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_message_item_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamMessageItemThemeData {
  bool get canMerge => true;

  static StreamMessageItemThemeData? lerp(
    StreamMessageItemThemeData? a,
    StreamMessageItemThemeData? b,
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

    return StreamMessageItemThemeData(
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      leadingVisibility: StreamMessageLayoutVisibility.lerp(
        a.leadingVisibility,
        b.leadingVisibility,
        t,
      ),
      headerVisibility: StreamMessageLayoutVisibility.lerp(
        a.headerVisibility,
        b.headerVisibility,
        t,
      ),
      footerVisibility: StreamMessageLayoutVisibility.lerp(
        a.footerVisibility,
        b.footerVisibility,
        t,
      ),
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      spacing: lerpDouble$(a.spacing, b.spacing, t),
      avatarSize: t < 0.5 ? a.avatarSize : b.avatarSize,
      text: StreamMessageTextStyle.lerp(a.text, b.text, t),
      bubble: StreamMessageBubbleStyle.lerp(a.bubble, b.bubble, t),
      attachment: StreamMessageAttachmentStyle.lerp(
        a.attachment,
        b.attachment,
        t,
      ),
      annotation: StreamMessageAnnotationStyle.lerp(
        a.annotation,
        b.annotation,
        t,
      ),
      metadata: StreamMessageMetadataStyle.lerp(a.metadata, b.metadata, t),
      replies: StreamMessageRepliesStyle.lerp(a.replies, b.replies, t),
    );
  }

  StreamMessageItemThemeData copyWith({
    Color? backgroundColor,
    StreamMessageLayoutVisibility? leadingVisibility,
    StreamMessageLayoutVisibility? headerVisibility,
    StreamMessageLayoutVisibility? footerVisibility,
    EdgeInsetsGeometry? padding,
    double? spacing,
    StreamAvatarSize? avatarSize,
    StreamMessageTextStyle? text,
    StreamMessageBubbleStyle? bubble,
    StreamMessageAttachmentStyle? attachment,
    StreamMessageAnnotationStyle? annotation,
    StreamMessageMetadataStyle? metadata,
    StreamMessageRepliesStyle? replies,
  }) {
    final _this = (this as StreamMessageItemThemeData);

    return StreamMessageItemThemeData(
      backgroundColor: backgroundColor ?? _this.backgroundColor,
      leadingVisibility: leadingVisibility ?? _this.leadingVisibility,
      headerVisibility: headerVisibility ?? _this.headerVisibility,
      footerVisibility: footerVisibility ?? _this.footerVisibility,
      padding: padding ?? _this.padding,
      spacing: spacing ?? _this.spacing,
      avatarSize: avatarSize ?? _this.avatarSize,
      text: text ?? _this.text,
      bubble: bubble ?? _this.bubble,
      attachment: attachment ?? _this.attachment,
      annotation: annotation ?? _this.annotation,
      metadata: metadata ?? _this.metadata,
      replies: replies ?? _this.replies,
    );
  }

  StreamMessageItemThemeData merge(StreamMessageItemThemeData? other) {
    final _this = (this as StreamMessageItemThemeData);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      backgroundColor: other.backgroundColor,
      leadingVisibility: other.leadingVisibility,
      headerVisibility: other.headerVisibility,
      footerVisibility: other.footerVisibility,
      padding: other.padding,
      spacing: other.spacing,
      avatarSize: other.avatarSize,
      text: _this.text?.merge(other.text) ?? other.text,
      bubble: _this.bubble?.merge(other.bubble) ?? other.bubble,
      attachment: _this.attachment?.merge(other.attachment) ?? other.attachment,
      annotation: _this.annotation?.merge(other.annotation) ?? other.annotation,
      metadata: _this.metadata?.merge(other.metadata) ?? other.metadata,
      replies: _this.replies?.merge(other.replies) ?? other.replies,
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

    final _this = (this as StreamMessageItemThemeData);
    final _other = (other as StreamMessageItemThemeData);

    return _other.backgroundColor == _this.backgroundColor &&
        _other.leadingVisibility == _this.leadingVisibility &&
        _other.headerVisibility == _this.headerVisibility &&
        _other.footerVisibility == _this.footerVisibility &&
        _other.padding == _this.padding &&
        _other.spacing == _this.spacing &&
        _other.avatarSize == _this.avatarSize &&
        _other.text == _this.text &&
        _other.bubble == _this.bubble &&
        _other.attachment == _this.attachment &&
        _other.annotation == _this.annotation &&
        _other.metadata == _this.metadata &&
        _other.replies == _this.replies;
  }

  @override
  int get hashCode {
    final _this = (this as StreamMessageItemThemeData);

    return Object.hash(
      runtimeType,
      _this.backgroundColor,
      _this.leadingVisibility,
      _this.headerVisibility,
      _this.footerVisibility,
      _this.padding,
      _this.spacing,
      _this.avatarSize,
      _this.text,
      _this.bubble,
      _this.attachment,
      _this.annotation,
      _this.metadata,
      _this.replies,
    );
  }
}
