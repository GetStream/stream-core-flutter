// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_checkbox_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamCheckboxThemeData {
  bool get canMerge => true;

  static StreamCheckboxThemeData? lerp(
    StreamCheckboxThemeData? a,
    StreamCheckboxThemeData? b,
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

    return StreamCheckboxThemeData(
      style: StreamCheckboxStyle.lerp(a.style, b.style, t),
    );
  }

  StreamCheckboxThemeData copyWith({StreamCheckboxStyle? style}) {
    final _this = (this as StreamCheckboxThemeData);

    return StreamCheckboxThemeData(style: style ?? _this.style);
  }

  StreamCheckboxThemeData merge(StreamCheckboxThemeData? other) {
    final _this = (this as StreamCheckboxThemeData);

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

    final _this = (this as StreamCheckboxThemeData);
    final _other = (other as StreamCheckboxThemeData);

    return _other.style == _this.style;
  }

  @override
  int get hashCode {
    final _this = (this as StreamCheckboxThemeData);

    return Object.hash(runtimeType, _this.style);
  }
}

mixin _$StreamCheckboxStyle {
  bool get canMerge => true;

  static StreamCheckboxStyle? lerp(
    StreamCheckboxStyle? a,
    StreamCheckboxStyle? b,
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

    return StreamCheckboxStyle(
      size: t < 0.5 ? a.size : b.size,
      checkSize: lerpDouble$(a.checkSize, b.checkSize, t),
      fillColor: WidgetStateProperty.lerp<Color?>(
        a.fillColor,
        b.fillColor,
        t,
        Color.lerp,
      ),
      checkColor: WidgetStateProperty.lerp<Color?>(
        a.checkColor,
        b.checkColor,
        t,
        Color.lerp,
      ),
      overlayColor: WidgetStateProperty.lerp<Color?>(
        a.overlayColor,
        b.overlayColor,
        t,
        Color.lerp,
      ),
      shape: OutlinedBorder.lerp(a.shape, b.shape, t),
      side: WidgetStateBorderSide.lerp(a.side, b.side, t),
    );
  }

  StreamCheckboxStyle copyWith({
    StreamCheckboxSize? size,
    double? checkSize,
    WidgetStateProperty<Color?>? fillColor,
    WidgetStateProperty<Color?>? checkColor,
    WidgetStateProperty<Color?>? overlayColor,
    OutlinedBorder? shape,
    WidgetStateBorderSide? side,
  }) {
    final _this = (this as StreamCheckboxStyle);

    return StreamCheckboxStyle(
      size: size ?? _this.size,
      checkSize: checkSize ?? _this.checkSize,
      fillColor: fillColor ?? _this.fillColor,
      checkColor: checkColor ?? _this.checkColor,
      overlayColor: overlayColor ?? _this.overlayColor,
      shape: shape ?? _this.shape,
      side: side ?? _this.side,
    );
  }

  StreamCheckboxStyle merge(StreamCheckboxStyle? other) {
    final _this = (this as StreamCheckboxStyle);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      size: other.size,
      checkSize: other.checkSize,
      fillColor: other.fillColor,
      checkColor: other.checkColor,
      overlayColor: other.overlayColor,
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

    final _this = (this as StreamCheckboxStyle);
    final _other = (other as StreamCheckboxStyle);

    return _other.size == _this.size &&
        _other.checkSize == _this.checkSize &&
        _other.fillColor == _this.fillColor &&
        _other.checkColor == _this.checkColor &&
        _other.overlayColor == _this.overlayColor &&
        _other.shape == _this.shape &&
        _other.side == _this.side;
  }

  @override
  int get hashCode {
    final _this = (this as StreamCheckboxStyle);

    return Object.hash(
      runtimeType,
      _this.size,
      _this.checkSize,
      _this.fillColor,
      _this.checkColor,
      _this.overlayColor,
      _this.shape,
      _this.side,
    );
  }
}
