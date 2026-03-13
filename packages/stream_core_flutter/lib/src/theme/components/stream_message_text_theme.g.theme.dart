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
      textStyle: StreamMessageStyleProperty.lerp<TextStyle?>(
        a.textStyle,
        b.textStyle,
        t,
        TextStyle.lerp,
      ),
      textColor: StreamMessageStyleProperty.lerp<Color?>(
        a.textColor,
        b.textColor,
        t,
        Color.lerp,
      ),
      linkStyle: StreamMessageStyleProperty.lerp<TextStyle?>(
        a.linkStyle,
        b.linkStyle,
        t,
        TextStyle.lerp,
      ),
      linkColor: StreamMessageStyleProperty.lerp<Color?>(
        a.linkColor,
        b.linkColor,
        t,
        Color.lerp,
      ),
      mentionStyle: StreamMessageStyleProperty.lerp<TextStyle?>(
        a.mentionStyle,
        b.mentionStyle,
        t,
        TextStyle.lerp,
      ),
      mentionColor: StreamMessageStyleProperty.lerp<Color?>(
        a.mentionColor,
        b.mentionColor,
        t,
        Color.lerp,
      ),
      singleEmojiStyle: StreamMessageStyleProperty.lerp<TextStyle?>(
        a.singleEmojiStyle,
        b.singleEmojiStyle,
        t,
        TextStyle.lerp,
      ),
      doubleEmojiStyle: StreamMessageStyleProperty.lerp<TextStyle?>(
        a.doubleEmojiStyle,
        b.doubleEmojiStyle,
        t,
        TextStyle.lerp,
      ),
      tripleEmojiStyle: StreamMessageStyleProperty.lerp<TextStyle?>(
        a.tripleEmojiStyle,
        b.tripleEmojiStyle,
        t,
        TextStyle.lerp,
      ),
    );
  }

  StreamMessageTextStyle copyWith({
    StreamMessageStyleProperty<TextStyle?>? textStyle,
    StreamMessageStyleProperty<Color?>? textColor,
    StreamMessageStyleProperty<TextStyle?>? linkStyle,
    StreamMessageStyleProperty<Color?>? linkColor,
    StreamMessageStyleProperty<TextStyle?>? mentionStyle,
    StreamMessageStyleProperty<Color?>? mentionColor,
    StreamMessageStyleProperty<TextStyle?>? singleEmojiStyle,
    StreamMessageStyleProperty<TextStyle?>? doubleEmojiStyle,
    StreamMessageStyleProperty<TextStyle?>? tripleEmojiStyle,
  }) {
    final _this = (this as StreamMessageTextStyle);

    return StreamMessageTextStyle(
      textStyle: textStyle ?? _this.textStyle,
      textColor: textColor ?? _this.textColor,
      linkStyle: linkStyle ?? _this.linkStyle,
      linkColor: linkColor ?? _this.linkColor,
      mentionStyle: mentionStyle ?? _this.mentionStyle,
      mentionColor: mentionColor ?? _this.mentionColor,
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
      textStyle: other.textStyle,
      textColor: other.textColor,
      linkStyle: other.linkStyle,
      linkColor: other.linkColor,
      mentionStyle: other.mentionStyle,
      mentionColor: other.mentionColor,
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

    return _other.textStyle == _this.textStyle &&
        _other.textColor == _this.textColor &&
        _other.linkStyle == _this.linkStyle &&
        _other.linkColor == _this.linkColor &&
        _other.mentionStyle == _this.mentionStyle &&
        _other.mentionColor == _this.mentionColor &&
        _other.singleEmojiStyle == _this.singleEmojiStyle &&
        _other.doubleEmojiStyle == _this.doubleEmojiStyle &&
        _other.tripleEmojiStyle == _this.tripleEmojiStyle;
  }

  @override
  int get hashCode {
    final _this = (this as StreamMessageTextStyle);

    return Object.hash(
      runtimeType,
      _this.textStyle,
      _this.textColor,
      _this.linkStyle,
      _this.linkColor,
      _this.mentionStyle,
      _this.mentionColor,
      _this.singleEmojiStyle,
      _this.doubleEmojiStyle,
      _this.tripleEmojiStyle,
    );
  }
}
