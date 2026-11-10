// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_radio_button_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamRadioButtonThemeData {
  bool get canMerge => true;

  static StreamRadioButtonThemeData? lerp(
    StreamRadioButtonThemeData? a,
    StreamRadioButtonThemeData? b,
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

    return StreamRadioButtonThemeData(
      style: StreamRadioButtonStyle.lerp(a.style, b.style, t),
    );
  }

  StreamRadioButtonThemeData copyWith({StreamRadioButtonStyle? style}) {
    final _this = (this as StreamRadioButtonThemeData);

    return StreamRadioButtonThemeData(style: style ?? _this.style);
  }

  StreamRadioButtonThemeData merge(StreamRadioButtonThemeData? other) {
    final _this = (this as StreamRadioButtonThemeData);

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

    final _this = (this as StreamRadioButtonThemeData);
    final _other = (other as StreamRadioButtonThemeData);

    return _other.style == _this.style;
  }

  @override
  int get hashCode {
    final _this = (this as StreamRadioButtonThemeData);

    return Object.hash(runtimeType, _this.style);
  }
}

mixin _$StreamRadioButtonStyle {
  bool get canMerge => true;

  static StreamRadioButtonStyle? lerp(
    StreamRadioButtonStyle? a,
    StreamRadioButtonStyle? b,
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

    return StreamRadioButtonStyle(
      size: t < 0.5 ? a.size : b.size,
      dotSize: lerpDouble$(a.dotSize, b.dotSize, t),
      fillColor: WidgetStateProperty.lerp<Color?>(
        a.fillColor,
        b.fillColor,
        t,
        Color.lerp,
      ),
      dotColor: WidgetStateProperty.lerp<Color?>(
        a.dotColor,
        b.dotColor,
        t,
        Color.lerp,
      ),
      overlayColor: WidgetStateProperty.lerp<Color?>(
        a.overlayColor,
        b.overlayColor,
        t,
        Color.lerp,
      ),
      side: t < 0.5 ? a.side : b.side,
    );
  }

  StreamRadioButtonStyle copyWith({
    StreamRadioButtonSize? size,
    double? dotSize,
    WidgetStateProperty<Color?>? fillColor,
    WidgetStateProperty<Color?>? dotColor,
    WidgetStateProperty<Color?>? overlayColor,
    WidgetStateBorderSide? side,
  }) {
    final _this = (this as StreamRadioButtonStyle);

    return StreamRadioButtonStyle(
      size: size ?? _this.size,
      dotSize: dotSize ?? _this.dotSize,
      fillColor: fillColor ?? _this.fillColor,
      dotColor: dotColor ?? _this.dotColor,
      overlayColor: overlayColor ?? _this.overlayColor,
      side: side ?? _this.side,
    );
  }

  StreamRadioButtonStyle merge(StreamRadioButtonStyle? other) {
    final _this = (this as StreamRadioButtonStyle);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      size: other.size,
      dotSize: other.dotSize,
      fillColor: other.fillColor,
      dotColor: other.dotColor,
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

    final _this = (this as StreamRadioButtonStyle);
    final _other = (other as StreamRadioButtonStyle);

    return _other.size == _this.size &&
        _other.dotSize == _this.dotSize &&
        _other.fillColor == _this.fillColor &&
        _other.dotColor == _this.dotColor &&
        _other.overlayColor == _this.overlayColor &&
        _other.side == _this.side;
  }

  @override
  int get hashCode {
    final _this = (this as StreamRadioButtonStyle);

    return Object.hash(
      runtimeType,
      _this.size,
      _this.dotSize,
      _this.fillColor,
      _this.dotColor,
      _this.overlayColor,
      _this.side,
    );
  }
}
