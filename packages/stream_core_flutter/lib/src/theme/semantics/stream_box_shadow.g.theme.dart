// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_box_shadow.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamBoxShadow {
  bool get canMerge => true;

  static StreamBoxShadow? lerp(
    StreamBoxShadow? a,
    StreamBoxShadow? b,
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

    return StreamBoxShadow.raw(
      elevation1: t < 0.5 ? a.elevation1 : b.elevation1,
      elevation2: t < 0.5 ? a.elevation2 : b.elevation2,
      elevation3: t < 0.5 ? a.elevation3 : b.elevation3,
      elevation4: t < 0.5 ? a.elevation4 : b.elevation4,
    );
  }

  StreamBoxShadow copyWith({
    List<BoxShadow>? elevation1,
    List<BoxShadow>? elevation2,
    List<BoxShadow>? elevation3,
    List<BoxShadow>? elevation4,
  }) {
    final _this = (this as StreamBoxShadow);

    return StreamBoxShadow.raw(
      elevation1: elevation1 ?? _this.elevation1,
      elevation2: elevation2 ?? _this.elevation2,
      elevation3: elevation3 ?? _this.elevation3,
      elevation4: elevation4 ?? _this.elevation4,
    );
  }

  StreamBoxShadow merge(StreamBoxShadow? other) {
    final _this = (this as StreamBoxShadow);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      elevation1: other.elevation1,
      elevation2: other.elevation2,
      elevation3: other.elevation3,
      elevation4: other.elevation4,
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

    final _this = (this as StreamBoxShadow);
    final _other = (other as StreamBoxShadow);

    return _other.elevation1 == _this.elevation1 &&
        _other.elevation2 == _this.elevation2 &&
        _other.elevation3 == _this.elevation3 &&
        _other.elevation4 == _this.elevation4;
  }

  @override
  int get hashCode {
    final _this = (this as StreamBoxShadow);

    return Object.hash(
      runtimeType,
      _this.elevation1,
      _this.elevation2,
      _this.elevation3,
      _this.elevation4,
    );
  }
}
