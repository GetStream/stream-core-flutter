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

    return StreamEmojiButtonThemeData(
      style: StreamEmojiButtonThemeStyle.lerp(a.style, b.style, t),
    );
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

    return copyWith(style: _this.style?.merge(other.style) ?? other.style);
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

mixin _$StreamEmojiButtonThemeStyle {
  bool get canMerge => true;

  static StreamEmojiButtonThemeStyle? lerp(
    StreamEmojiButtonThemeStyle? a,
    StreamEmojiButtonThemeStyle? b,
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

    return StreamEmojiButtonThemeStyle(
      size: t < 0.5 ? a.size : b.size,
      backgroundColor: WidgetStateProperty.lerp<Color?>(
        a.backgroundColor,
        b.backgroundColor,
        t,
        Color.lerp,
      ),
      foregroundColor: WidgetStateProperty.lerp<Color?>(
        a.foregroundColor,
        b.foregroundColor,
        t,
        Color.lerp,
      ),
      overlayColor: WidgetStateProperty.lerp<Color?>(
        a.overlayColor,
        b.overlayColor,
        t,
        Color.lerp,
      ),
      side: WidgetStateBorderSide.lerp(a.side, b.side, t),
    );
  }

  StreamEmojiButtonThemeStyle copyWith({
    StreamEmojiButtonSize? size,
    WidgetStateProperty<Color?>? backgroundColor,
    WidgetStateProperty<Color?>? foregroundColor,
    WidgetStateProperty<Color?>? overlayColor,
    WidgetStateBorderSide? side,
  }) {
    final _this = (this as StreamEmojiButtonThemeStyle);

    return StreamEmojiButtonThemeStyle(
      size: size ?? _this.size,
      backgroundColor: backgroundColor ?? _this.backgroundColor,
      foregroundColor: foregroundColor ?? _this.foregroundColor,
      overlayColor: overlayColor ?? _this.overlayColor,
      side: side ?? _this.side,
    );
  }

  StreamEmojiButtonThemeStyle merge(StreamEmojiButtonThemeStyle? other) {
    final _this = (this as StreamEmojiButtonThemeStyle);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      size: other.size,
      backgroundColor: other.backgroundColor,
      foregroundColor: other.foregroundColor,
      overlayColor: other.overlayColor,
      side: other.side,
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

    final _this = (this as StreamEmojiButtonThemeStyle);
    final _other = (other as StreamEmojiButtonThemeStyle);

    return _other.size == _this.size &&
        _other.backgroundColor == _this.backgroundColor &&
        _other.foregroundColor == _this.foregroundColor &&
        _other.overlayColor == _this.overlayColor &&
        _other.side == _this.side;
  }

  @override
  int get hashCode {
    final _this = (this as StreamEmojiButtonThemeStyle);

    return Object.hash(
      runtimeType,
      _this.size,
      _this.backgroundColor,
      _this.foregroundColor,
      _this.overlayColor,
      _this.side,
    );
  }
}
