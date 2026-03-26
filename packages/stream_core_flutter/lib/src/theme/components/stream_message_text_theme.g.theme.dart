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
        _other.singleEmojiStyle == _this.singleEmojiStyle &&
        _other.doubleEmojiStyle == _this.doubleEmojiStyle &&
        _other.tripleEmojiStyle == _this.tripleEmojiStyle;
  }

  @override
  int get hashCode {
    final _this = (this as StreamMessageTextStyle);

    return Object.hash(
      runtimeType,
      _this.padding,
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
