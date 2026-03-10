// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_message_annotation_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamMessageAnnotationStyle {
  bool get canMerge => true;

  static StreamMessageAnnotationStyle? lerp(
    StreamMessageAnnotationStyle? a,
    StreamMessageAnnotationStyle? b,
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

    return StreamMessageAnnotationStyle(
      textStyle: TextStyle.lerp(a.textStyle, b.textStyle, t),
      textColor: Color.lerp(a.textColor, b.textColor, t),
      iconColor: Color.lerp(a.iconColor, b.iconColor, t),
      iconSize: lerpDouble$(a.iconSize, b.iconSize, t),
      spacing: lerpDouble$(a.spacing, b.spacing, t),
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
    );
  }

  StreamMessageAnnotationStyle copyWith({
    TextStyle? textStyle,
    Color? textColor,
    Color? iconColor,
    double? iconSize,
    double? spacing,
    EdgeInsetsGeometry? padding,
  }) {
    final _this = (this as StreamMessageAnnotationStyle);

    return StreamMessageAnnotationStyle(
      textStyle: textStyle ?? _this.textStyle,
      textColor: textColor ?? _this.textColor,
      iconColor: iconColor ?? _this.iconColor,
      iconSize: iconSize ?? _this.iconSize,
      spacing: spacing ?? _this.spacing,
      padding: padding ?? _this.padding,
    );
  }

  StreamMessageAnnotationStyle merge(StreamMessageAnnotationStyle? other) {
    final _this = (this as StreamMessageAnnotationStyle);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      textStyle: _this.textStyle?.merge(other.textStyle) ?? other.textStyle,
      textColor: other.textColor,
      iconColor: other.iconColor,
      iconSize: other.iconSize,
      spacing: other.spacing,
      padding: other.padding,
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

    final _this = (this as StreamMessageAnnotationStyle);
    final _other = (other as StreamMessageAnnotationStyle);

    return _other.textStyle == _this.textStyle &&
        _other.textColor == _this.textColor &&
        _other.iconColor == _this.iconColor &&
        _other.iconSize == _this.iconSize &&
        _other.spacing == _this.spacing &&
        _other.padding == _this.padding;
  }

  @override
  int get hashCode {
    final _this = (this as StreamMessageAnnotationStyle);

    return Object.hash(
      runtimeType,
      _this.textStyle,
      _this.textColor,
      _this.iconColor,
      _this.iconSize,
      _this.spacing,
      _this.padding,
    );
  }
}

mixin _$StreamMessageAnnotationThemeData {
  bool get canMerge => true;

  static StreamMessageAnnotationThemeData? lerp(
    StreamMessageAnnotationThemeData? a,
    StreamMessageAnnotationThemeData? b,
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

    return StreamMessageAnnotationThemeData(
      style: StreamMessageAnnotationStyle.lerp(a.style, b.style, t),
    );
  }

  StreamMessageAnnotationThemeData copyWith({
    StreamMessageAnnotationStyle? style,
  }) {
    final _this = (this as StreamMessageAnnotationThemeData);

    return StreamMessageAnnotationThemeData(style: style ?? _this.style);
  }

  StreamMessageAnnotationThemeData merge(
    StreamMessageAnnotationThemeData? other,
  ) {
    final _this = (this as StreamMessageAnnotationThemeData);

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

    final _this = (this as StreamMessageAnnotationThemeData);
    final _other = (other as StreamMessageAnnotationThemeData);

    return _other.style == _this.style;
  }

  @override
  int get hashCode {
    final _this = (this as StreamMessageAnnotationThemeData);

    return Object.hash(runtimeType, _this.style);
  }
}
