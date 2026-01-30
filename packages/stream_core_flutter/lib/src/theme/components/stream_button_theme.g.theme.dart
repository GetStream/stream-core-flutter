// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_button_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamButtonThemeData {
  bool get canMerge => true;

  static StreamButtonThemeData? lerp(
    StreamButtonThemeData? a,
    StreamButtonThemeData? b,
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

    return StreamButtonThemeData(
      primary: t < 0.5 ? a.primary : b.primary,
      secondary: t < 0.5 ? a.secondary : b.secondary,
      destructive: t < 0.5 ? a.destructive : b.destructive,
    );
  }

  StreamButtonThemeData copyWith({
    StreamButtonTypeStyle? primary,
    StreamButtonTypeStyle? secondary,
    StreamButtonTypeStyle? destructive,
  }) {
    final _this = (this as StreamButtonThemeData);

    return StreamButtonThemeData(
      primary: primary ?? _this.primary,
      secondary: secondary ?? _this.secondary,
      destructive: destructive ?? _this.destructive,
    );
  }

  StreamButtonThemeData merge(StreamButtonThemeData? other) {
    final _this = (this as StreamButtonThemeData);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      primary: _this.primary?.merge(other.primary) ?? other.primary,
      secondary: _this.secondary?.merge(other.secondary) ?? other.secondary,
      destructive:
          _this.destructive?.merge(other.destructive) ?? other.destructive,
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

    final _this = (this as StreamButtonThemeData);
    final _other = (other as StreamButtonThemeData);

    return _other.primary == _this.primary &&
        _other.secondary == _this.secondary &&
        _other.destructive == _this.destructive;
  }

  @override
  int get hashCode {
    final _this = (this as StreamButtonThemeData);

    return Object.hash(
      runtimeType,
      _this.primary,
      _this.secondary,
      _this.destructive,
    );
  }
}

mixin _$StreamButtonTypeStyle {
  bool get canMerge => true;

  static StreamButtonTypeStyle? lerp(
    StreamButtonTypeStyle? a,
    StreamButtonTypeStyle? b,
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

    return StreamButtonTypeStyle(
      solid: t < 0.5 ? a.solid : b.solid,
      outline: t < 0.5 ? a.outline : b.outline,
      ghost: t < 0.5 ? a.ghost : b.ghost,
    );
  }

  StreamButtonTypeStyle copyWith({
    StreamButtonThemeStyle? solid,
    StreamButtonThemeStyle? outline,
    StreamButtonThemeStyle? ghost,
  }) {
    final _this = (this as StreamButtonTypeStyle);

    return StreamButtonTypeStyle(
      solid: solid ?? _this.solid,
      outline: outline ?? _this.outline,
      ghost: ghost ?? _this.ghost,
    );
  }

  StreamButtonTypeStyle merge(StreamButtonTypeStyle? other) {
    final _this = (this as StreamButtonTypeStyle);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      solid: other.solid,
      outline: other.outline,
      ghost: other.ghost,
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

    final _this = (this as StreamButtonTypeStyle);
    final _other = (other as StreamButtonTypeStyle);

    return _other.solid == _this.solid &&
        _other.outline == _this.outline &&
        _other.ghost == _this.ghost;
  }

  @override
  int get hashCode {
    final _this = (this as StreamButtonTypeStyle);

    return Object.hash(runtimeType, _this.solid, _this.outline, _this.ghost);
  }
}
