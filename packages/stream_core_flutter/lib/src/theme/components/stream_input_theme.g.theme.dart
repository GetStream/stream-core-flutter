// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_input_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamInputThemeData {
  bool get canMerge => true;

  static StreamInputThemeData? lerp(
    StreamInputThemeData? a,
    StreamInputThemeData? b,
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

    return StreamInputThemeData(
      textColor: Color.lerp(a.textColor, b.textColor, t),
      placeholderColor: Color.lerp(a.placeholderColor, b.placeholderColor, t),
      disabledColor: Color.lerp(a.disabledColor, b.disabledColor, t),
      iconColor: Color.lerp(a.iconColor, b.iconColor, t),
      borderColor: Color.lerp(a.borderColor, b.borderColor, t),
    );
  }

  StreamInputThemeData copyWith({
    Color? textColor,
    Color? placeholderColor,
    Color? disabledColor,
    Color? iconColor,
    Color? borderColor,
  }) {
    final _this = (this as StreamInputThemeData);

    return StreamInputThemeData(
      textColor: textColor ?? _this.textColor,
      placeholderColor: placeholderColor ?? _this.placeholderColor,
      disabledColor: disabledColor ?? _this.disabledColor,
      iconColor: iconColor ?? _this.iconColor,
      borderColor: borderColor ?? _this.borderColor,
    );
  }

  StreamInputThemeData merge(StreamInputThemeData? other) {
    final _this = (this as StreamInputThemeData);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      textColor: other.textColor,
      placeholderColor: other.placeholderColor,
      disabledColor: other.disabledColor,
      iconColor: other.iconColor,
      borderColor: other.borderColor,
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

    final _this = (this as StreamInputThemeData);
    final _other = (other as StreamInputThemeData);

    return _other.textColor == _this.textColor &&
        _other.placeholderColor == _this.placeholderColor &&
        _other.disabledColor == _this.disabledColor &&
        _other.iconColor == _this.iconColor &&
        _other.borderColor == _this.borderColor;
  }

  @override
  int get hashCode {
    final _this = (this as StreamInputThemeData);

    return Object.hash(
      runtimeType,
      _this.textColor,
      _this.placeholderColor,
      _this.disabledColor,
      _this.iconColor,
      _this.borderColor,
    );
  }
}
