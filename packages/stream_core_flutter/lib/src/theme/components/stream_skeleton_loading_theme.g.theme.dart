// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_skeleton_loading_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamSkeletonLoadingThemeData {
  bool get canMerge => true;

  static StreamSkeletonLoadingThemeData? lerp(
    StreamSkeletonLoadingThemeData? a,
    StreamSkeletonLoadingThemeData? b,
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

    return StreamSkeletonLoadingThemeData(
      baseColor: Color.lerp(a.baseColor, b.baseColor, t),
      highlightColor: Color.lerp(a.highlightColor, b.highlightColor, t),
      period: lerpDuration$(a.period, b.period, t),
    );
  }

  StreamSkeletonLoadingThemeData copyWith({
    Color? baseColor,
    Color? highlightColor,
    Duration? period,
  }) {
    final _this = (this as StreamSkeletonLoadingThemeData);

    return StreamSkeletonLoadingThemeData(
      baseColor: baseColor ?? _this.baseColor,
      highlightColor: highlightColor ?? _this.highlightColor,
      period: period ?? _this.period,
    );
  }

  StreamSkeletonLoadingThemeData merge(StreamSkeletonLoadingThemeData? other) {
    final _this = (this as StreamSkeletonLoadingThemeData);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      baseColor: other.baseColor,
      highlightColor: other.highlightColor,
      period: other.period,
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

    final _this = (this as StreamSkeletonLoadingThemeData);
    final _other = (other as StreamSkeletonLoadingThemeData);

    return _other.baseColor == _this.baseColor &&
        _other.highlightColor == _this.highlightColor &&
        _other.period == _this.period;
  }

  @override
  int get hashCode {
    final _this = (this as StreamSkeletonLoadingThemeData);

    return Object.hash(
      runtimeType,
      _this.baseColor,
      _this.highlightColor,
      _this.period,
    );
  }
}
