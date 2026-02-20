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
      primary: StreamButtonTypeStyle.lerp(a.primary, b.primary, t),
      secondary: StreamButtonTypeStyle.lerp(a.secondary, b.secondary, t),
      destructive: StreamButtonTypeStyle.lerp(a.destructive, b.destructive, t),
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
      solid: StreamButtonThemeStyle.lerp(a.solid, b.solid, t),
      outline: StreamButtonThemeStyle.lerp(a.outline, b.outline, t),
      ghost: StreamButtonThemeStyle.lerp(a.ghost, b.ghost, t),
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
      solid: _this.solid?.merge(other.solid) ?? other.solid,
      outline: _this.outline?.merge(other.outline) ?? other.outline,
      ghost: _this.ghost?.merge(other.ghost) ?? other.ghost,
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

mixin _$StreamButtonThemeStyle {
  bool get canMerge => true;

  static StreamButtonThemeStyle? lerp(
    StreamButtonThemeStyle? a,
    StreamButtonThemeStyle? b,
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

    return StreamButtonThemeStyle(
      backgroundColor: WidgetStateProperty.lerp<Color?>(
        a.backgroundColor,
        b.backgroundColor,
        t,
        Color.lerp,
      ),
      foregroundColor: WidgetStateProperty.lerp<Color?>(
        a.foregroundColor,
        b.foregroundColor,
        t,
        Color.lerp,
      ),
      borderColor: WidgetStateProperty.lerp<Color?>(
        a.borderColor,
        b.borderColor,
        t,
        Color.lerp,
      ),
      overlayColor: WidgetStateProperty.lerp<Color?>(
        a.overlayColor,
        b.overlayColor,
        t,
        Color.lerp,
      ),
      elevation: WidgetStateProperty.lerp<double?>(
        a.elevation,
        b.elevation,
        t,
        lerpDouble$,
      ),
      iconSize: WidgetStateProperty.lerp<double?>(
        a.iconSize,
        b.iconSize,
        t,
        lerpDouble$,
      ),
    );
  }

  StreamButtonThemeStyle copyWith({
    WidgetStateProperty<Color?>? backgroundColor,
    WidgetStateProperty<Color?>? foregroundColor,
    WidgetStateProperty<Color?>? borderColor,
    WidgetStateProperty<Color?>? overlayColor,
    WidgetStateProperty<double?>? elevation,
    WidgetStateProperty<double?>? iconSize,
  }) {
    final _this = (this as StreamButtonThemeStyle);

    return StreamButtonThemeStyle(
      backgroundColor: backgroundColor ?? _this.backgroundColor,
      foregroundColor: foregroundColor ?? _this.foregroundColor,
      borderColor: borderColor ?? _this.borderColor,
      overlayColor: overlayColor ?? _this.overlayColor,
      elevation: elevation ?? _this.elevation,
      iconSize: iconSize ?? _this.iconSize,
    );
  }

  StreamButtonThemeStyle merge(StreamButtonThemeStyle? other) {
    final _this = (this as StreamButtonThemeStyle);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      backgroundColor: other.backgroundColor,
      foregroundColor: other.foregroundColor,
      borderColor: other.borderColor,
      overlayColor: other.overlayColor,
      elevation: other.elevation,
      iconSize: other.iconSize,
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

    final _this = (this as StreamButtonThemeStyle);
    final _other = (other as StreamButtonThemeStyle);

    return _other.backgroundColor == _this.backgroundColor &&
        _other.foregroundColor == _this.foregroundColor &&
        _other.borderColor == _this.borderColor &&
        _other.overlayColor == _this.overlayColor &&
        _other.elevation == _this.elevation &&
        _other.iconSize == _this.iconSize;
  }

  @override
  int get hashCode {
    final _this = (this as StreamButtonThemeStyle);

    return Object.hash(
      runtimeType,
      _this.backgroundColor,
      _this.foregroundColor,
      _this.borderColor,
      _this.overlayColor,
      _this.elevation,
      _this.iconSize,
    );
  }
}
