// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_command_chip_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamCommandChipThemeData {
  bool get canMerge => true;

  static StreamCommandChipThemeData? lerp(
    StreamCommandChipThemeData? a,
    StreamCommandChipThemeData? b,
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

    return StreamCommandChipThemeData(
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      foregroundColor: Color.lerp(a.foregroundColor, b.foregroundColor, t),
      labelStyle: TextStyle.lerp(a.labelStyle, b.labelStyle, t),
      minHeight: lerpDouble$(a.minHeight, b.minHeight, t),
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      borderRadius: BorderRadiusGeometry.lerp(
        a.borderRadius,
        b.borderRadius,
        t,
      ),
    );
  }

  StreamCommandChipThemeData copyWith({
    Color? backgroundColor,
    Color? foregroundColor,
    TextStyle? labelStyle,
    double? minHeight,
    EdgeInsetsGeometry? padding,
    BorderRadiusGeometry? borderRadius,
  }) {
    final _this = (this as StreamCommandChipThemeData);

    return StreamCommandChipThemeData(
      backgroundColor: backgroundColor ?? _this.backgroundColor,
      foregroundColor: foregroundColor ?? _this.foregroundColor,
      labelStyle: labelStyle ?? _this.labelStyle,
      minHeight: minHeight ?? _this.minHeight,
      padding: padding ?? _this.padding,
      borderRadius: borderRadius ?? _this.borderRadius,
    );
  }

  StreamCommandChipThemeData merge(StreamCommandChipThemeData? other) {
    final _this = (this as StreamCommandChipThemeData);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      backgroundColor: other.backgroundColor,
      foregroundColor: other.foregroundColor,
      labelStyle: _this.labelStyle?.merge(other.labelStyle) ?? other.labelStyle,
      minHeight: other.minHeight,
      padding: other.padding,
      borderRadius: other.borderRadius,
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

    final _this = (this as StreamCommandChipThemeData);
    final _other = (other as StreamCommandChipThemeData);

    return _other.backgroundColor == _this.backgroundColor &&
        _other.foregroundColor == _this.foregroundColor &&
        _other.labelStyle == _this.labelStyle &&
        _other.minHeight == _this.minHeight &&
        _other.padding == _this.padding &&
        _other.borderRadius == _this.borderRadius;
  }

  @override
  int get hashCode {
    final _this = (this as StreamCommandChipThemeData);

    return Object.hash(
      runtimeType,
      _this.backgroundColor,
      _this.foregroundColor,
      _this.labelStyle,
      _this.minHeight,
      _this.padding,
      _this.borderRadius,
    );
  }
}
