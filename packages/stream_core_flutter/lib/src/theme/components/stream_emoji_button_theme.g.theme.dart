// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_emoji_button_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamEmojiButtonThemeData {
  bool get canMerge => true;

  static StreamEmojiButtonThemeData? lerp(
    StreamEmojiButtonThemeData? a,
    StreamEmojiButtonThemeData? b,
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

    return StreamEmojiButtonThemeData(style: t < 0.5 ? a.style : b.style);
  }

  StreamEmojiButtonThemeData copyWith({StreamEmojiButtonThemeStyle? style}) {
    final _this = (this as StreamEmojiButtonThemeData);

    return StreamEmojiButtonThemeData(style: style ?? _this.style);
  }

  StreamEmojiButtonThemeData merge(StreamEmojiButtonThemeData? other) {
    final _this = (this as StreamEmojiButtonThemeData);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(style: other.style);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other.runtimeType != runtimeType) {
      return false;
    }

    final _this = (this as StreamEmojiButtonThemeData);
    final _other = (other as StreamEmojiButtonThemeData);

    return _other.style == _this.style;
  }

  @override
  int get hashCode {
    final _this = (this as StreamEmojiButtonThemeData);

    return Object.hash(runtimeType, _this.style);
  }
}
