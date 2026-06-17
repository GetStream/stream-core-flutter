// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_message_text_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamMessageTextStyle {
  bool get canMerge => true;

  static StreamMessageTextStyle? lerp(
    StreamMessageTextStyle? a,
    StreamMessageTextStyle? b,
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

    return StreamMessageTextStyle(
      padding: StreamMessageLayoutProperty.lerp<EdgeInsetsGeometry?>(
        a.padding,
        b.padding,
        t,
        EdgeInsetsGeometry.lerp,
      ),
      textStyle: StreamMessageLayoutProperty.lerp<TextStyle?>(
        a.textStyle,
        b.textStyle,
        t,
        TextStyle.lerp,
      ),
      textColor: StreamMessageLayoutProperty.lerp<Color?>(
        a.textColor,
        b.textColor,
        t,
        Color.lerp,
      ),
      linkStyle: StreamMessageLayoutProperty.lerp<TextStyle?>(
        a.linkStyle,
        b.linkStyle,
        t,
        TextStyle.lerp,
      ),
      linkColor: StreamMessageLayoutProperty.lerp<Color?>(
        a.linkColor,
        b.linkColor,
        t,
        Color.lerp,
      ),
      mentionStyle: StreamMessageLayoutProperty.lerp<TextStyle?>(
        a.mentionStyle,
        b.mentionStyle,
        t,
        TextStyle.lerp,
      ),
      mentionColor: StreamMessageLayoutProperty.lerp<Color?>(
        a.mentionColor,
        b.mentionColor,
        t,
        Color.lerp,
      ),
      mentionBackgroundColor: StreamMessageLayoutProperty.lerp<Color?>(
        a.mentionBackgroundColor,
        b.mentionBackgroundColor,
        t,
        Color.lerp,
      ),
      mentionBroadcastStyle: StreamMessageLayoutProperty.lerp<TextStyle?>(
        a.mentionBroadcastStyle,
        b.mentionBroadcastStyle,
        t,
        TextStyle.lerp,
      ),
      mentionBroadcastColor: StreamMessageLayoutProperty.lerp<Color?>(
        a.mentionBroadcastColor,
        b.mentionBroadcastColor,
        t,
        Color.lerp,
      ),
      mentionBroadcastBackgroundColor: StreamMessageLayoutProperty.lerp<Color?>(
        a.mentionBroadcastBackgroundColor,
        b.mentionBroadcastBackgroundColor,
        t,
        Color.lerp,
      ),
      mentionRoleStyle: StreamMessageLayoutProperty.lerp<TextStyle?>(
        a.mentionRoleStyle,
        b.mentionRoleStyle,
        t,
        TextStyle.lerp,
      ),
      mentionRoleColor: StreamMessageLayoutProperty.lerp<Color?>(
        a.mentionRoleColor,
        b.mentionRoleColor,
        t,
        Color.lerp,
      ),
      mentionRoleBackgroundColor: StreamMessageLayoutProperty.lerp<Color?>(
        a.mentionRoleBackgroundColor,
        b.mentionRoleBackgroundColor,
        t,
        Color.lerp,
      ),
      mentionGroupStyle: StreamMessageLayoutProperty.lerp<TextStyle?>(
        a.mentionGroupStyle,
        b.mentionGroupStyle,
        t,
        TextStyle.lerp,
      ),
      mentionGroupColor: StreamMessageLayoutProperty.lerp<Color?>(
        a.mentionGroupColor,
        b.mentionGroupColor,
        t,
        Color.lerp,
      ),
      mentionGroupBackgroundColor: StreamMessageLayoutProperty.lerp<Color?>(
        a.mentionGroupBackgroundColor,
        b.mentionGroupBackgroundColor,
        t,
        Color.lerp,
      ),
      mentionUserStyle: StreamMessageLayoutProperty.lerp<TextStyle?>(
        a.mentionUserStyle,
        b.mentionUserStyle,
        t,
        TextStyle.lerp,
      ),
      mentionUserColor: StreamMessageLayoutProperty.lerp<Color?>(
        a.mentionUserColor,
        b.mentionUserColor,
        t,
        Color.lerp,
      ),
      mentionUserBackgroundColor: StreamMessageLayoutProperty.lerp<Color?>(
        a.mentionUserBackgroundColor,
        b.mentionUserBackgroundColor,
        t,
        Color.lerp,
      ),
      singleEmojiStyle: StreamMessageLayoutProperty.lerp<TextStyle?>(
        a.singleEmojiStyle,
        b.singleEmojiStyle,
        t,
        TextStyle.lerp,
      ),
      doubleEmojiStyle: StreamMessageLayoutProperty.lerp<TextStyle?>(
        a.doubleEmojiStyle,
        b.doubleEmojiStyle,
        t,
        TextStyle.lerp,
      ),
      tripleEmojiStyle: StreamMessageLayoutProperty.lerp<TextStyle?>(
        a.tripleEmojiStyle,
        b.tripleEmojiStyle,
        t,
        TextStyle.lerp,
      ),
    );
  }

  StreamMessageTextStyle copyWith({
    StreamMessageLayoutProperty<EdgeInsetsGeometry?>? padding,
    StreamMessageLayoutProperty<TextStyle?>? textStyle,
    StreamMessageLayoutProperty<Color?>? textColor,
    StreamMessageLayoutProperty<TextStyle?>? linkStyle,
    StreamMessageLayoutProperty<Color?>? linkColor,
    StreamMessageLayoutProperty<TextStyle?>? mentionStyle,
    StreamMessageLayoutProperty<Color?>? mentionColor,
    StreamMessageLayoutProperty<Color?>? mentionBackgroundColor,
    StreamMessageLayoutProperty<TextStyle?>? mentionBroadcastStyle,
    StreamMessageLayoutProperty<Color?>? mentionBroadcastColor,
    StreamMessageLayoutProperty<Color?>? mentionBroadcastBackgroundColor,
    StreamMessageLayoutProperty<TextStyle?>? mentionRoleStyle,
    StreamMessageLayoutProperty<Color?>? mentionRoleColor,
    StreamMessageLayoutProperty<Color?>? mentionRoleBackgroundColor,
    StreamMessageLayoutProperty<TextStyle?>? mentionGroupStyle,
    StreamMessageLayoutProperty<Color?>? mentionGroupColor,
    StreamMessageLayoutProperty<Color?>? mentionGroupBackgroundColor,
    StreamMessageLayoutProperty<TextStyle?>? mentionUserStyle,
    StreamMessageLayoutProperty<Color?>? mentionUserColor,
    StreamMessageLayoutProperty<Color?>? mentionUserBackgroundColor,
    StreamMessageLayoutProperty<TextStyle?>? singleEmojiStyle,
    StreamMessageLayoutProperty<TextStyle?>? doubleEmojiStyle,
    StreamMessageLayoutProperty<TextStyle?>? tripleEmojiStyle,
  }) {
    final _this = (this as StreamMessageTextStyle);

    return StreamMessageTextStyle(
      padding: padding ?? _this.padding,
      textStyle: textStyle ?? _this.textStyle,
      textColor: textColor ?? _this.textColor,
      linkStyle: linkStyle ?? _this.linkStyle,
      linkColor: linkColor ?? _this.linkColor,
      mentionStyle: mentionStyle ?? _this.mentionStyle,
      mentionColor: mentionColor ?? _this.mentionColor,
      mentionBackgroundColor:
          mentionBackgroundColor ?? _this.mentionBackgroundColor,
      mentionBroadcastStyle:
          mentionBroadcastStyle ?? _this.mentionBroadcastStyle,
      mentionBroadcastColor:
          mentionBroadcastColor ?? _this.mentionBroadcastColor,
      mentionBroadcastBackgroundColor:
          mentionBroadcastBackgroundColor ??
          _this.mentionBroadcastBackgroundColor,
      mentionRoleStyle: mentionRoleStyle ?? _this.mentionRoleStyle,
      mentionRoleColor: mentionRoleColor ?? _this.mentionRoleColor,
      mentionRoleBackgroundColor:
          mentionRoleBackgroundColor ?? _this.mentionRoleBackgroundColor,
      mentionGroupStyle: mentionGroupStyle ?? _this.mentionGroupStyle,
      mentionGroupColor: mentionGroupColor ?? _this.mentionGroupColor,
      mentionGroupBackgroundColor:
          mentionGroupBackgroundColor ?? _this.mentionGroupBackgroundColor,
      mentionUserStyle: mentionUserStyle ?? _this.mentionUserStyle,
      mentionUserColor: mentionUserColor ?? _this.mentionUserColor,
      mentionUserBackgroundColor:
          mentionUserBackgroundColor ?? _this.mentionUserBackgroundColor,
      singleEmojiStyle: singleEmojiStyle ?? _this.singleEmojiStyle,
      doubleEmojiStyle: doubleEmojiStyle ?? _this.doubleEmojiStyle,
      tripleEmojiStyle: tripleEmojiStyle ?? _this.tripleEmojiStyle,
    );
  }

  StreamMessageTextStyle merge(StreamMessageTextStyle? other) {
    final _this = (this as StreamMessageTextStyle);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      padding: other.padding,
      textStyle: other.textStyle,
      textColor: other.textColor,
      linkStyle: other.linkStyle,
      linkColor: other.linkColor,
      mentionStyle: other.mentionStyle,
      mentionColor: other.mentionColor,
      mentionBackgroundColor: other.mentionBackgroundColor,
      mentionBroadcastStyle: other.mentionBroadcastStyle,
      mentionBroadcastColor: other.mentionBroadcastColor,
      mentionBroadcastBackgroundColor: other.mentionBroadcastBackgroundColor,
      mentionRoleStyle: other.mentionRoleStyle,
      mentionRoleColor: other.mentionRoleColor,
      mentionRoleBackgroundColor: other.mentionRoleBackgroundColor,
      mentionGroupStyle: other.mentionGroupStyle,
      mentionGroupColor: other.mentionGroupColor,
      mentionGroupBackgroundColor: other.mentionGroupBackgroundColor,
      mentionUserStyle: other.mentionUserStyle,
      mentionUserColor: other.mentionUserColor,
      mentionUserBackgroundColor: other.mentionUserBackgroundColor,
      singleEmojiStyle: other.singleEmojiStyle,
      doubleEmojiStyle: other.doubleEmojiStyle,
      tripleEmojiStyle: other.tripleEmojiStyle,
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

    final _this = (this as StreamMessageTextStyle);
    final _other = (other as StreamMessageTextStyle);

    return _other.padding == _this.padding &&
        _other.textStyle == _this.textStyle &&
        _other.textColor == _this.textColor &&
        _other.linkStyle == _this.linkStyle &&
        _other.linkColor == _this.linkColor &&
        _other.mentionStyle == _this.mentionStyle &&
        _other.mentionColor == _this.mentionColor &&
        _other.mentionBackgroundColor == _this.mentionBackgroundColor &&
        _other.mentionBroadcastStyle == _this.mentionBroadcastStyle &&
        _other.mentionBroadcastColor == _this.mentionBroadcastColor &&
        _other.mentionBroadcastBackgroundColor ==
            _this.mentionBroadcastBackgroundColor &&
        _other.mentionRoleStyle == _this.mentionRoleStyle &&
        _other.mentionRoleColor == _this.mentionRoleColor &&
        _other.mentionRoleBackgroundColor == _this.mentionRoleBackgroundColor &&
        _other.mentionGroupStyle == _this.mentionGroupStyle &&
        _other.mentionGroupColor == _this.mentionGroupColor &&
        _other.mentionGroupBackgroundColor ==
            _this.mentionGroupBackgroundColor &&
        _other.mentionUserStyle == _this.mentionUserStyle &&
        _other.mentionUserColor == _this.mentionUserColor &&
        _other.mentionUserBackgroundColor == _this.mentionUserBackgroundColor &&
        _other.singleEmojiStyle == _this.singleEmojiStyle &&
        _other.doubleEmojiStyle == _this.doubleEmojiStyle &&
        _other.tripleEmojiStyle == _this.tripleEmojiStyle;
  }

  @override
  int get hashCode {
    final _this = (this as StreamMessageTextStyle);

    return Object.hashAll([
      runtimeType,
      _this.padding,
      _this.textStyle,
      _this.textColor,
      _this.linkStyle,
      _this.linkColor,
      _this.mentionStyle,
      _this.mentionColor,
      _this.mentionBackgroundColor,
      _this.mentionBroadcastStyle,
      _this.mentionBroadcastColor,
      _this.mentionBroadcastBackgroundColor,
      _this.mentionRoleStyle,
      _this.mentionRoleColor,
      _this.mentionRoleBackgroundColor,
      _this.mentionGroupStyle,
      _this.mentionGroupColor,
      _this.mentionGroupBackgroundColor,
      _this.mentionUserStyle,
      _this.mentionUserColor,
      _this.mentionUserBackgroundColor,
      _this.singleEmojiStyle,
      _this.doubleEmojiStyle,
      _this.tripleEmojiStyle,
    ]);
  }
}
