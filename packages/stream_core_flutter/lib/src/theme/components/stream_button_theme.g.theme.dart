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
      primaryButtonColors: t < 0.5
          ? a.primaryButtonColors
          : b.primaryButtonColors,
      disabledPrimaryButtonColors: t < 0.5
          ? a.disabledPrimaryButtonColors
          : b.disabledPrimaryButtonColors,
      secondaryButtonColors: t < 0.5
          ? a.secondaryButtonColors
          : b.secondaryButtonColors,
      disabledSecondaryButtonColors: t < 0.5
          ? a.disabledSecondaryButtonColors
          : b.disabledSecondaryButtonColors,
      destructiveButtonColors: t < 0.5
          ? a.destructiveButtonColors
          : b.destructiveButtonColors,
      disabledDestructiveButtonColors: t < 0.5
          ? a.disabledDestructiveButtonColors
          : b.disabledDestructiveButtonColors,
    );
  }

  StreamButtonThemeData copyWith({
    StreamButtonColors? primaryButtonColors,
    StreamButtonColors? disabledPrimaryButtonColors,
    StreamButtonColors? secondaryButtonColors,
    StreamButtonColors? disabledSecondaryButtonColors,
    StreamButtonColors? destructiveButtonColors,
    StreamButtonColors? disabledDestructiveButtonColors,
  }) {
    final _this = (this as StreamButtonThemeData);

    return StreamButtonThemeData(
      primaryButtonColors: primaryButtonColors ?? _this.primaryButtonColors,
      disabledPrimaryButtonColors:
          disabledPrimaryButtonColors ?? _this.disabledPrimaryButtonColors,
      secondaryButtonColors:
          secondaryButtonColors ?? _this.secondaryButtonColors,
      disabledSecondaryButtonColors:
          disabledSecondaryButtonColors ?? _this.disabledSecondaryButtonColors,
      destructiveButtonColors:
          destructiveButtonColors ?? _this.destructiveButtonColors,
      disabledDestructiveButtonColors:
          disabledDestructiveButtonColors ??
          _this.disabledDestructiveButtonColors,
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
      primaryButtonColors:
          _this.primaryButtonColors?.merge(other.primaryButtonColors) ??
          other.primaryButtonColors,
      disabledPrimaryButtonColors:
          _this.disabledPrimaryButtonColors?.merge(
            other.disabledPrimaryButtonColors,
          ) ??
          other.disabledPrimaryButtonColors,
      secondaryButtonColors:
          _this.secondaryButtonColors?.merge(other.secondaryButtonColors) ??
          other.secondaryButtonColors,
      disabledSecondaryButtonColors:
          _this.disabledSecondaryButtonColors?.merge(
            other.disabledSecondaryButtonColors,
          ) ??
          other.disabledSecondaryButtonColors,
      destructiveButtonColors:
          _this.destructiveButtonColors?.merge(other.destructiveButtonColors) ??
          other.destructiveButtonColors,
      disabledDestructiveButtonColors:
          _this.disabledDestructiveButtonColors?.merge(
            other.disabledDestructiveButtonColors,
          ) ??
          other.disabledDestructiveButtonColors,
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

    return _other.primaryButtonColors == _this.primaryButtonColors &&
        _other.disabledPrimaryButtonColors ==
            _this.disabledPrimaryButtonColors &&
        _other.secondaryButtonColors == _this.secondaryButtonColors &&
        _other.disabledSecondaryButtonColors ==
            _this.disabledSecondaryButtonColors &&
        _other.destructiveButtonColors == _this.destructiveButtonColors &&
        _other.disabledDestructiveButtonColors ==
            _this.disabledDestructiveButtonColors;
  }

  @override
  int get hashCode {
    final _this = (this as StreamButtonThemeData);

    return Object.hash(
      runtimeType,
      _this.primaryButtonColors,
      _this.disabledPrimaryButtonColors,
      _this.secondaryButtonColors,
      _this.disabledSecondaryButtonColors,
      _this.destructiveButtonColors,
      _this.disabledDestructiveButtonColors,
    );
  }
}

mixin _$StreamButtonColors {
  bool get canMerge => true;

  static StreamButtonColors? lerp(
    StreamButtonColors? a,
    StreamButtonColors? b,
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

    return StreamButtonColors(
      solidBackgroundColor: Color.lerp(
        a.solidBackgroundColor,
        b.solidBackgroundColor,
        t,
      ),
      solidForegroundColor: Color.lerp(
        a.solidForegroundColor,
        b.solidForegroundColor,
        t,
      ),
      outlineBorderColor: Color.lerp(
        a.outlineBorderColor,
        b.outlineBorderColor,
        t,
      ),
      outlineForegroundColor: Color.lerp(
        a.outlineForegroundColor,
        b.outlineForegroundColor,
        t,
      ),
      ghostForegroundColor: Color.lerp(
        a.ghostForegroundColor,
        b.ghostForegroundColor,
        t,
      ),
    );
  }

  StreamButtonColors copyWith({
    Color? solidBackgroundColor,
    Color? solidForegroundColor,
    Color? outlineBorderColor,
    Color? outlineForegroundColor,
    Color? ghostForegroundColor,
  }) {
    final _this = (this as StreamButtonColors);

    return StreamButtonColors(
      solidBackgroundColor: solidBackgroundColor ?? _this.solidBackgroundColor,
      solidForegroundColor: solidForegroundColor ?? _this.solidForegroundColor,
      outlineBorderColor: outlineBorderColor ?? _this.outlineBorderColor,
      outlineForegroundColor:
          outlineForegroundColor ?? _this.outlineForegroundColor,
      ghostForegroundColor: ghostForegroundColor ?? _this.ghostForegroundColor,
    );
  }

  StreamButtonColors merge(StreamButtonColors? other) {
    final _this = (this as StreamButtonColors);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      solidBackgroundColor: other.solidBackgroundColor,
      solidForegroundColor: other.solidForegroundColor,
      outlineBorderColor: other.outlineBorderColor,
      outlineForegroundColor: other.outlineForegroundColor,
      ghostForegroundColor: other.ghostForegroundColor,
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

    final _this = (this as StreamButtonColors);
    final _other = (other as StreamButtonColors);

    return _other.solidBackgroundColor == _this.solidBackgroundColor &&
        _other.solidForegroundColor == _this.solidForegroundColor &&
        _other.outlineBorderColor == _this.outlineBorderColor &&
        _other.outlineForegroundColor == _this.outlineForegroundColor &&
        _other.ghostForegroundColor == _this.ghostForegroundColor;
  }

  @override
  int get hashCode {
    final _this = (this as StreamButtonColors);

    return Object.hash(
      runtimeType,
      _this.solidBackgroundColor,
      _this.solidForegroundColor,
      _this.outlineBorderColor,
      _this.outlineForegroundColor,
      _this.ghostForegroundColor,
    );
  }
}
