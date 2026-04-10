// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_stepper_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamStepperThemeData {
  bool get canMerge => true;

  static StreamStepperThemeData? lerp(
    StreamStepperThemeData? a,
    StreamStepperThemeData? b,
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

    return StreamStepperThemeData(
      style: StreamStepperStyle.lerp(a.style, b.style, t),
    );
  }

  StreamStepperThemeData copyWith({StreamStepperStyle? style}) {
    final _this = (this as StreamStepperThemeData);

    return StreamStepperThemeData(style: style ?? _this.style);
  }

  StreamStepperThemeData merge(StreamStepperThemeData? other) {
    final _this = (this as StreamStepperThemeData);

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

    final _this = (this as StreamStepperThemeData);
    final _other = (other as StreamStepperThemeData);

    return _other.style == _this.style;
  }

  @override
  int get hashCode {
    final _this = (this as StreamStepperThemeData);

    return Object.hash(runtimeType, _this.style);
  }
}

mixin _$StreamStepperStyle {
  bool get canMerge => true;

  static StreamStepperStyle? lerp(
    StreamStepperStyle? a,
    StreamStepperStyle? b,
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

    return StreamStepperStyle(
      buttonStyle: StreamButtonThemeStyle.lerp(a.buttonStyle, b.buttonStyle, t),
      inputStyle: StreamTextInputStyle.lerp(a.inputStyle, b.inputStyle, t),
      spacing: lerpDouble$(a.spacing, b.spacing, t),
    );
  }

  StreamStepperStyle copyWith({
    StreamButtonThemeStyle? buttonStyle,
    StreamTextInputStyle? inputStyle,
    double? spacing,
  }) {
    final _this = (this as StreamStepperStyle);

    return StreamStepperStyle(
      buttonStyle: buttonStyle ?? _this.buttonStyle,
      inputStyle: inputStyle ?? _this.inputStyle,
      spacing: spacing ?? _this.spacing,
    );
  }

  StreamStepperStyle merge(StreamStepperStyle? other) {
    final _this = (this as StreamStepperStyle);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      buttonStyle:
          _this.buttonStyle?.merge(other.buttonStyle) ?? other.buttonStyle,
      inputStyle: _this.inputStyle?.merge(other.inputStyle) ?? other.inputStyle,
      spacing: other.spacing,
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

    final _this = (this as StreamStepperStyle);
    final _other = (other as StreamStepperStyle);

    return _other.buttonStyle == _this.buttonStyle &&
        _other.inputStyle == _this.inputStyle &&
        _other.spacing == _this.spacing;
  }

  @override
  int get hashCode {
    final _this = (this as StreamStepperStyle);

    return Object.hash(
      runtimeType,
      _this.buttonStyle,
      _this.inputStyle,
      _this.spacing,
    );
  }
}
