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
      iconColor: StreamMessageLayoutProperty.lerp<Color?>(
        a.iconColor,
        b.iconColor,
        t,
        Color.lerp,
      ),
      iconSize: StreamMessageLayoutProperty.lerp<double?>(
        a.iconSize,
        b.iconSize,
        t,
        lerpDouble$,
      ),
      spacing: StreamMessageLayoutProperty.lerp<double?>(
        a.spacing,
        b.spacing,
        t,
        lerpDouble$,
      ),
      padding: StreamMessageLayoutProperty.lerp<EdgeInsetsGeometry?>(
        a.padding,
        b.padding,
        t,
        EdgeInsetsGeometry.lerp,
      ),
      trailingTextStyle: StreamMessageLayoutProperty.lerp<TextStyle?>(
        a.trailingTextStyle,
        b.trailingTextStyle,
        t,
        TextStyle.lerp,
      ),
      trailingTextColor: StreamMessageLayoutProperty.lerp<Color?>(
        a.trailingTextColor,
        b.trailingTextColor,
        t,
        Color.lerp,
      ),
    );
  }

  StreamMessageAnnotationStyle copyWith({
    StreamMessageLayoutProperty<TextStyle?>? textStyle,
    StreamMessageLayoutProperty<Color?>? textColor,
    StreamMessageLayoutProperty<Color?>? iconColor,
    StreamMessageLayoutProperty<double?>? iconSize,
    StreamMessageLayoutProperty<double?>? spacing,
    StreamMessageLayoutProperty<EdgeInsetsGeometry?>? padding,
    StreamMessageLayoutProperty<TextStyle?>? trailingTextStyle,
    StreamMessageLayoutProperty<Color?>? trailingTextColor,
  }) {
    final _this = (this as StreamMessageAnnotationStyle);

    return StreamMessageAnnotationStyle(
      textStyle: textStyle ?? _this.textStyle,
      textColor: textColor ?? _this.textColor,
      iconColor: iconColor ?? _this.iconColor,
      iconSize: iconSize ?? _this.iconSize,
      spacing: spacing ?? _this.spacing,
      padding: padding ?? _this.padding,
      trailingTextStyle: trailingTextStyle ?? _this.trailingTextStyle,
      trailingTextColor: trailingTextColor ?? _this.trailingTextColor,
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
      textStyle: other.textStyle,
      textColor: other.textColor,
      iconColor: other.iconColor,
      iconSize: other.iconSize,
      spacing: other.spacing,
      padding: other.padding,
      trailingTextStyle: other.trailingTextStyle,
      trailingTextColor: other.trailingTextColor,
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
        _other.padding == _this.padding &&
        _other.trailingTextStyle == _this.trailingTextStyle &&
        _other.trailingTextColor == _this.trailingTextColor;
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
      _this.trailingTextStyle,
      _this.trailingTextColor,
    );
  }
}
