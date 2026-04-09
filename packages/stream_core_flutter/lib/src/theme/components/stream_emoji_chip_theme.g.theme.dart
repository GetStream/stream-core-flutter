// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_emoji_chip_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamEmojiChipThemeData {
  bool get canMerge => true;

  static StreamEmojiChipThemeData? lerp(
    StreamEmojiChipThemeData? a,
    StreamEmojiChipThemeData? b,
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

    return StreamEmojiChipThemeData(
      style: StreamEmojiChipThemeStyle.lerp(a.style, b.style, t),
    );
  }

  StreamEmojiChipThemeData copyWith({StreamEmojiChipThemeStyle? style}) {
    final _this = (this as StreamEmojiChipThemeData);

    return StreamEmojiChipThemeData(style: style ?? _this.style);
  }

  StreamEmojiChipThemeData merge(StreamEmojiChipThemeData? other) {
    final _this = (this as StreamEmojiChipThemeData);

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

    final _this = (this as StreamEmojiChipThemeData);
    final _other = (other as StreamEmojiChipThemeData);

    return _other.style == _this.style;
  }

  @override
  int get hashCode {
    final _this = (this as StreamEmojiChipThemeData);

    return Object.hash(runtimeType, _this.style);
  }
}

mixin _$StreamEmojiChipThemeStyle {
  bool get canMerge => true;

  static StreamEmojiChipThemeStyle? lerp(
    StreamEmojiChipThemeStyle? a,
    StreamEmojiChipThemeStyle? b,
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

    return StreamEmojiChipThemeStyle(
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
      textStyle: WidgetStateProperty.lerp<TextStyle?>(
        a.textStyle,
        b.textStyle,
        t,
        TextStyle.lerp,
      ),
      elevation: WidgetStateProperty.lerp<double?>(
        a.elevation,
        b.elevation,
        t,
        lerpDouble$,
      ),
      shadowColor: WidgetStateProperty.lerp<Color?>(
        a.shadowColor,
        b.shadowColor,
        t,
        Color.lerp,
      ),
      emojiSize: lerpDouble$(a.emojiSize, b.emojiSize, t),
      minimumSize: Size.lerp(a.minimumSize, b.minimumSize, t),
      maximumSize: Size.lerp(a.maximumSize, b.maximumSize, t),
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      shape: OutlinedBorder.lerp(a.shape, b.shape, t),
      side: WidgetStateBorderSide.lerp(a.side, b.side, t),
    );
  }

  StreamEmojiChipThemeStyle copyWith({
    WidgetStateProperty<Color?>? backgroundColor,
    WidgetStateProperty<Color?>? foregroundColor,
    WidgetStateProperty<Color?>? overlayColor,
    WidgetStateProperty<TextStyle?>? textStyle,
    WidgetStateProperty<double?>? elevation,
    WidgetStateProperty<Color?>? shadowColor,
    double? emojiSize,
    Size? minimumSize,
    Size? maximumSize,
    EdgeInsetsGeometry? padding,
    OutlinedBorder? shape,
    WidgetStateBorderSide? side,
  }) {
    final _this = (this as StreamEmojiChipThemeStyle);

    return StreamEmojiChipThemeStyle(
      backgroundColor: backgroundColor ?? _this.backgroundColor,
      foregroundColor: foregroundColor ?? _this.foregroundColor,
      overlayColor: overlayColor ?? _this.overlayColor,
      textStyle: textStyle ?? _this.textStyle,
      elevation: elevation ?? _this.elevation,
      shadowColor: shadowColor ?? _this.shadowColor,
      emojiSize: emojiSize ?? _this.emojiSize,
      minimumSize: minimumSize ?? _this.minimumSize,
      maximumSize: maximumSize ?? _this.maximumSize,
      padding: padding ?? _this.padding,
      shape: shape ?? _this.shape,
      side: side ?? _this.side,
    );
  }

  StreamEmojiChipThemeStyle merge(StreamEmojiChipThemeStyle? other) {
    final _this = (this as StreamEmojiChipThemeStyle);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      backgroundColor: other.backgroundColor,
      foregroundColor: other.foregroundColor,
      overlayColor: other.overlayColor,
      textStyle: other.textStyle,
      elevation: other.elevation,
      shadowColor: other.shadowColor,
      emojiSize: other.emojiSize,
      minimumSize: other.minimumSize,
      maximumSize: other.maximumSize,
      padding: other.padding,
      shape: other.shape,
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

    final _this = (this as StreamEmojiChipThemeStyle);
    final _other = (other as StreamEmojiChipThemeStyle);

    return _other.backgroundColor == _this.backgroundColor &&
        _other.foregroundColor == _this.foregroundColor &&
        _other.overlayColor == _this.overlayColor &&
        _other.textStyle == _this.textStyle &&
        _other.elevation == _this.elevation &&
        _other.shadowColor == _this.shadowColor &&
        _other.emojiSize == _this.emojiSize &&
        _other.minimumSize == _this.minimumSize &&
        _other.maximumSize == _this.maximumSize &&
        _other.padding == _this.padding &&
        _other.shape == _this.shape &&
        _other.side == _this.side;
  }

  @override
  int get hashCode {
    final _this = (this as StreamEmojiChipThemeStyle);

    return Object.hash(
      runtimeType,
      _this.backgroundColor,
      _this.foregroundColor,
      _this.overlayColor,
      _this.textStyle,
      _this.elevation,
      _this.shadowColor,
      _this.emojiSize,
      _this.minimumSize,
      _this.maximumSize,
      _this.padding,
      _this.shape,
      _this.side,
    );
  }
}
