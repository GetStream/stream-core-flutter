// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_elevation.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamElevation {
  bool get canMerge => true;

  static StreamElevation? lerp(
    StreamElevation? a,
    StreamElevation? b,
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

    return StreamElevation(
      none: lerpDouble$(a.none, b.none, t)!,
      level1: lerpDouble$(a.level1, b.level1, t)!,
      level2: lerpDouble$(a.level2, b.level2, t)!,
      level3: lerpDouble$(a.level3, b.level3, t)!,
      level4: lerpDouble$(a.level4, b.level4, t)!,
    );
  }

  StreamElevation copyWith({
    double? none,
    double? level1,
    double? level2,
    double? level3,
    double? level4,
  }) {
    final _this = (this as StreamElevation);

    return StreamElevation(
      none: none ?? _this.none,
      level1: level1 ?? _this.level1,
      level2: level2 ?? _this.level2,
      level3: level3 ?? _this.level3,
      level4: level4 ?? _this.level4,
    );
  }

  StreamElevation merge(StreamElevation? other) {
    final _this = (this as StreamElevation);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      none: other.none,
      level1: other.level1,
      level2: other.level2,
      level3: other.level3,
      level4: other.level4,
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

    final _this = (this as StreamElevation);
    final _other = (other as StreamElevation);

    return _other.none == _this.none &&
        _other.level1 == _this.level1 &&
        _other.level2 == _this.level2 &&
        _other.level3 == _this.level3 &&
        _other.level4 == _this.level4;
  }

  @override
  int get hashCode {
    final _this = (this as StreamElevation);

    return Object.hash(
      runtimeType,
      _this.none,
      _this.level1,
      _this.level2,
      _this.level3,
      _this.level4,
    );
  }
}
