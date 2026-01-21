// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_radius.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamRadius {
  bool get canMerge => true;

  static StreamRadius? lerp(StreamRadius? a, StreamRadius? b, double t) {
    if (identical(a, b)) {
      return a;
    }

    if (a == null) {
      return t == 1.0 ? b : null;
    }

    if (b == null) {
      return t == 0.0 ? a : null;
    }

    return StreamRadius.raw(
      none: Radius.lerp(a.none, b.none, t)!,
      xxs: Radius.lerp(a.xxs, b.xxs, t)!,
      xs: Radius.lerp(a.xs, b.xs, t)!,
      sm: Radius.lerp(a.sm, b.sm, t)!,
      md: Radius.lerp(a.md, b.md, t)!,
      lg: Radius.lerp(a.lg, b.lg, t)!,
      xl: Radius.lerp(a.xl, b.xl, t)!,
      xxl: Radius.lerp(a.xxl, b.xxl, t)!,
      xxxl: Radius.lerp(a.xxxl, b.xxxl, t)!,
      xxxxl: Radius.lerp(a.xxxxl, b.xxxxl, t)!,
      max: Radius.lerp(a.max, b.max, t)!,
    );
  }

  StreamRadius copyWith({
    Radius? none,
    Radius? xxs,
    Radius? xs,
    Radius? sm,
    Radius? md,
    Radius? lg,
    Radius? xl,
    Radius? xxl,
    Radius? xxxl,
    Radius? xxxxl,
    Radius? max,
  }) {
    final _this = (this as StreamRadius);

    return StreamRadius.raw(
      none: none ?? _this.none,
      xxs: xxs ?? _this.xxs,
      xs: xs ?? _this.xs,
      sm: sm ?? _this.sm,
      md: md ?? _this.md,
      lg: lg ?? _this.lg,
      xl: xl ?? _this.xl,
      xxl: xxl ?? _this.xxl,
      xxxl: xxxl ?? _this.xxxl,
      xxxxl: xxxxl ?? _this.xxxxl,
      max: max ?? _this.max,
    );
  }

  StreamRadius merge(StreamRadius? other) {
    final _this = (this as StreamRadius);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      none: other.none,
      xxs: other.xxs,
      xs: other.xs,
      sm: other.sm,
      md: other.md,
      lg: other.lg,
      xl: other.xl,
      xxl: other.xxl,
      xxxl: other.xxxl,
      xxxxl: other.xxxxl,
      max: other.max,
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

    final _this = (this as StreamRadius);
    final _other = (other as StreamRadius);

    return _other.none == _this.none &&
        _other.xxs == _this.xxs &&
        _other.xs == _this.xs &&
        _other.sm == _this.sm &&
        _other.md == _this.md &&
        _other.lg == _this.lg &&
        _other.xl == _this.xl &&
        _other.xxl == _this.xxl &&
        _other.xxxl == _this.xxxl &&
        _other.xxxxl == _this.xxxxl &&
        _other.max == _this.max;
  }

  @override
  int get hashCode {
    final _this = (this as StreamRadius);

    return Object.hash(
      runtimeType,
      _this.none,
      _this.xxs,
      _this.xs,
      _this.sm,
      _this.md,
      _this.lg,
      _this.xl,
      _this.xxl,
      _this.xxxl,
      _this.xxxxl,
      _this.max,
    );
  }
}
