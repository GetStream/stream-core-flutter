// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_radio_indicator_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamRadioIndicatorThemeData {
  bool get canMerge => true;

  static StreamRadioIndicatorThemeData? lerp(
    StreamRadioIndicatorThemeData? a,
    StreamRadioIndicatorThemeData? b,
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

    return StreamRadioIndicatorThemeData(
      style: StreamRadioIndicatorStyle.lerp(a.style, b.style, t),
    );
  }

  StreamRadioIndicatorThemeData copyWith({StreamRadioIndicatorStyle? style}) {
    final _this = (this as StreamRadioIndicatorThemeData);

    return StreamRadioIndicatorThemeData(style: style ?? _this.style);
  }

  StreamRadioIndicatorThemeData merge(StreamRadioIndicatorThemeData? other) {
    final _this = (this as StreamRadioIndicatorThemeData);

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

    final _this = (this as StreamRadioIndicatorThemeData);
    final _other = (other as StreamRadioIndicatorThemeData);

    return _other.style == _this.style;
  }

  @override
  int get hashCode {
    final _this = (this as StreamRadioIndicatorThemeData);

    return Object.hash(runtimeType, _this.style);
  }
}

mixin _$StreamRadioIndicatorStyle {
  bool get canMerge => true;

  static StreamRadioIndicatorStyle? lerp(
    StreamRadioIndicatorStyle? a,
    StreamRadioIndicatorStyle? b,
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

    return StreamRadioIndicatorStyle(
      size: lerpDouble$(a.size, b.size, t),
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
      side: t < 0.5 ? a.side : b.side,
    );
  }

  StreamRadioIndicatorStyle copyWith({
    double? size,
    double? dotSize,
    WidgetStateProperty<Color?>? fillColor,
    WidgetStateProperty<Color?>? dotColor,
    WidgetStateBorderSide? side,
  }) {
    final _this = (this as StreamRadioIndicatorStyle);

    return StreamRadioIndicatorStyle(
      size: size ?? _this.size,
      dotSize: dotSize ?? _this.dotSize,
      fillColor: fillColor ?? _this.fillColor,
      dotColor: dotColor ?? _this.dotColor,
      side: side ?? _this.side,
    );
  }

  StreamRadioIndicatorStyle merge(StreamRadioIndicatorStyle? other) {
    final _this = (this as StreamRadioIndicatorStyle);

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

    final _this = (this as StreamRadioIndicatorStyle);
    final _other = (other as StreamRadioIndicatorStyle);

    return _other.size == _this.size &&
        _other.dotSize == _this.dotSize &&
        _other.fillColor == _this.fillColor &&
        _other.dotColor == _this.dotColor &&
        _other.side == _this.side;
  }

  @override
  int get hashCode {
    final _this = (this as StreamRadioIndicatorStyle);

    return Object.hash(
      runtimeType,
      _this.size,
      _this.dotSize,
      _this.fillColor,
      _this.dotColor,
      _this.side,
    );
  }
}
