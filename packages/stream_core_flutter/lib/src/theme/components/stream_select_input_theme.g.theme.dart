// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_select_input_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamSelectInputThemeData {
  bool get canMerge => true;

  static StreamSelectInputThemeData? lerp(
    StreamSelectInputThemeData? a,
    StreamSelectInputThemeData? b,
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

    return StreamSelectInputThemeData(
      style: StreamSelectInputStyle.lerp(a.style, b.style, t),
    );
  }

  StreamSelectInputThemeData copyWith({StreamSelectInputStyle? style}) {
    final _this = (this as StreamSelectInputThemeData);

    return StreamSelectInputThemeData(style: style ?? _this.style);
  }

  StreamSelectInputThemeData merge(StreamSelectInputThemeData? other) {
    final _this = (this as StreamSelectInputThemeData);

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

    final _this = (this as StreamSelectInputThemeData);
    final _other = (other as StreamSelectInputThemeData);

    return _other.style == _this.style;
  }

  @override
  int get hashCode {
    final _this = (this as StreamSelectInputThemeData);

    return Object.hash(runtimeType, _this.style);
  }
}

mixin _$StreamSelectInputStyle {
  bool get canMerge => true;

  static StreamSelectInputStyle? lerp(
    StreamSelectInputStyle? a,
    StreamSelectInputStyle? b,
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

    return StreamSelectInputStyle(
      textStyle: TextStyle.lerp(a.textStyle, b.textStyle, t),
      hintStyle: TextStyle.lerp(a.hintStyle, b.hintStyle, t),
      labelStyle: TextStyle.lerp(a.labelStyle, b.labelStyle, t),
      iconColor: Color.lerp(a.iconColor, b.iconColor, t),
      iconSize: lerpDouble$(a.iconSize, b.iconSize, t),
      borderRadius: BorderRadiusGeometry.lerp(
        a.borderRadius,
        b.borderRadius,
        t,
      ),
      border: a.border == null || b.border == null
          ? t < 0.5
                ? a.border
                : b.border
          : BorderSide.lerp(a.border!, b.border!, t),
      activeBorder: a.activeBorder == null || b.activeBorder == null
          ? t < 0.5
                ? a.activeBorder
                : b.activeBorder
          : BorderSide.lerp(a.activeBorder!, b.activeBorder!, t),
      errorBorder: a.errorBorder == null || b.errorBorder == null
          ? t < 0.5
                ? a.errorBorder
                : b.errorBorder
          : BorderSide.lerp(a.errorBorder!, b.errorBorder!, t),
      disabledBorder: a.disabledBorder == null || b.disabledBorder == null
          ? t < 0.5
                ? a.disabledBorder
                : b.disabledBorder
          : BorderSide.lerp(a.disabledBorder!, b.disabledBorder!, t),
      hoverRing: a.hoverRing == null || b.hoverRing == null
          ? t < 0.5
                ? a.hoverRing
                : b.hoverRing
          : BorderSide.lerp(a.hoverRing!, b.hoverRing!, t),
      focusRing: a.focusRing == null || b.focusRing == null
          ? t < 0.5
                ? a.focusRing
                : b.focusRing
          : BorderSide.lerp(a.focusRing!, b.focusRing!, t),
      fillColor: Color.lerp(a.fillColor, b.fillColor, t),
      contentPadding: EdgeInsetsGeometry.lerp(
        a.contentPadding,
        b.contentPadding,
        t,
      ),
    );
  }

  StreamSelectInputStyle copyWith({
    TextStyle? textStyle,
    TextStyle? hintStyle,
    TextStyle? labelStyle,
    Color? iconColor,
    double? iconSize,
    BorderRadiusGeometry? borderRadius,
    BorderSide? border,
    BorderSide? activeBorder,
    BorderSide? errorBorder,
    BorderSide? disabledBorder,
    BorderSide? hoverRing,
    BorderSide? focusRing,
    Color? fillColor,
    EdgeInsetsGeometry? contentPadding,
  }) {
    final _this = (this as StreamSelectInputStyle);

    return StreamSelectInputStyle(
      textStyle: textStyle ?? _this.textStyle,
      hintStyle: hintStyle ?? _this.hintStyle,
      labelStyle: labelStyle ?? _this.labelStyle,
      iconColor: iconColor ?? _this.iconColor,
      iconSize: iconSize ?? _this.iconSize,
      borderRadius: borderRadius ?? _this.borderRadius,
      border: border ?? _this.border,
      activeBorder: activeBorder ?? _this.activeBorder,
      errorBorder: errorBorder ?? _this.errorBorder,
      disabledBorder: disabledBorder ?? _this.disabledBorder,
      hoverRing: hoverRing ?? _this.hoverRing,
      focusRing: focusRing ?? _this.focusRing,
      fillColor: fillColor ?? _this.fillColor,
      contentPadding: contentPadding ?? _this.contentPadding,
    );
  }

  StreamSelectInputStyle merge(StreamSelectInputStyle? other) {
    final _this = (this as StreamSelectInputStyle);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      textStyle: _this.textStyle?.merge(other.textStyle) ?? other.textStyle,
      hintStyle: _this.hintStyle?.merge(other.hintStyle) ?? other.hintStyle,
      labelStyle: _this.labelStyle?.merge(other.labelStyle) ?? other.labelStyle,
      iconColor: other.iconColor,
      iconSize: other.iconSize,
      borderRadius: other.borderRadius,
      border: _this.border == null
          ? other.border
          : other.border == null
          ? _this.border
          : BorderSide.merge(_this.border!, other.border!),
      activeBorder: _this.activeBorder == null
          ? other.activeBorder
          : other.activeBorder == null
          ? _this.activeBorder
          : BorderSide.merge(_this.activeBorder!, other.activeBorder!),
      errorBorder: _this.errorBorder == null
          ? other.errorBorder
          : other.errorBorder == null
          ? _this.errorBorder
          : BorderSide.merge(_this.errorBorder!, other.errorBorder!),
      disabledBorder: _this.disabledBorder == null
          ? other.disabledBorder
          : other.disabledBorder == null
          ? _this.disabledBorder
          : BorderSide.merge(_this.disabledBorder!, other.disabledBorder!),
      hoverRing: _this.hoverRing == null
          ? other.hoverRing
          : other.hoverRing == null
          ? _this.hoverRing
          : BorderSide.merge(_this.hoverRing!, other.hoverRing!),
      focusRing: _this.focusRing == null
          ? other.focusRing
          : other.focusRing == null
          ? _this.focusRing
          : BorderSide.merge(_this.focusRing!, other.focusRing!),
      fillColor: other.fillColor,
      contentPadding: other.contentPadding,
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

    final _this = (this as StreamSelectInputStyle);
    final _other = (other as StreamSelectInputStyle);

    return _other.textStyle == _this.textStyle &&
        _other.hintStyle == _this.hintStyle &&
        _other.labelStyle == _this.labelStyle &&
        _other.iconColor == _this.iconColor &&
        _other.iconSize == _this.iconSize &&
        _other.borderRadius == _this.borderRadius &&
        _other.border == _this.border &&
        _other.activeBorder == _this.activeBorder &&
        _other.errorBorder == _this.errorBorder &&
        _other.disabledBorder == _this.disabledBorder &&
        _other.hoverRing == _this.hoverRing &&
        _other.focusRing == _this.focusRing &&
        _other.fillColor == _this.fillColor &&
        _other.contentPadding == _this.contentPadding;
  }

  @override
  int get hashCode {
    final _this = (this as StreamSelectInputStyle);

    return Object.hash(
      runtimeType,
      _this.textStyle,
      _this.hintStyle,
      _this.labelStyle,
      _this.iconColor,
      _this.iconSize,
      _this.borderRadius,
      _this.border,
      _this.activeBorder,
      _this.errorBorder,
      _this.disabledBorder,
      _this.hoverRing,
      _this.focusRing,
      _this.fillColor,
      _this.contentPadding,
    );
  }
}
