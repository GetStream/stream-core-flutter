// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_spacing.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamSpacing {
  bool get canMerge => true;

  static StreamSpacing? lerp(StreamSpacing? a, StreamSpacing? b, double t) {
    if (identical(a, b)) {
      return a;
    }

    if (a == null) {
      return t == 1.0 ? b : null;
    }

    if (b == null) {
      return t == 0.0 ? a : null;
    }

    return StreamSpacing(
      none: lerpDouble$(a.none, b.none, t)!,
      xxxs: lerpDouble$(a.xxxs, b.xxxs, t)!,
      xxs: lerpDouble$(a.xxs, b.xxs, t)!,
      xs: lerpDouble$(a.xs, b.xs, t)!,
      sm: lerpDouble$(a.sm, b.sm, t)!,
      md: lerpDouble$(a.md, b.md, t)!,
      lg: lerpDouble$(a.lg, b.lg, t)!,
      xl: lerpDouble$(a.xl, b.xl, t)!,
      xxl: lerpDouble$(a.xxl, b.xxl, t)!,
      xxxl: lerpDouble$(a.xxxl, b.xxxl, t)!,
    );
  }

  StreamSpacing copyWith({
    double? none,
    double? xxxs,
    double? xxs,
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
    double? xxxl,
  }) {
    final _this = (this as StreamSpacing);

    return StreamSpacing(
      none: none ?? _this.none,
      xxxs: xxxs ?? _this.xxxs,
      xxs: xxs ?? _this.xxs,
      xs: xs ?? _this.xs,
      sm: sm ?? _this.sm,
      md: md ?? _this.md,
      lg: lg ?? _this.lg,
      xl: xl ?? _this.xl,
      xxl: xxl ?? _this.xxl,
      xxxl: xxxl ?? _this.xxxl,
    );
  }

  StreamSpacing merge(StreamSpacing? other) {
    final _this = (this as StreamSpacing);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      none: other.none,
      xxxs: other.xxxs,
      xxs: other.xxs,
      xs: other.xs,
      sm: other.sm,
      md: other.md,
      lg: other.lg,
      xl: other.xl,
      xxl: other.xxl,
      xxxl: other.xxxl,
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

    final _this = (this as StreamSpacing);
    final _other = (other as StreamSpacing);

    return _other.none == _this.none &&
        _other.xxxs == _this.xxxs &&
        _other.xxs == _this.xxs &&
        _other.xs == _this.xs &&
        _other.sm == _this.sm &&
        _other.md == _this.md &&
        _other.lg == _this.lg &&
        _other.xl == _this.xl &&
        _other.xxl == _this.xxl &&
        _other.xxxl == _this.xxxl;
  }

  @override
  int get hashCode {
    final _this = (this as StreamSpacing);

    return Object.hash(
      runtimeType,
      _this.none,
      _this.xxxs,
      _this.xxs,
      _this.xs,
      _this.sm,
      _this.md,
      _this.lg,
      _this.xl,
      _this.xxl,
      _this.xxxl,
    );
  }
}
