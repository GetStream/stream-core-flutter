// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_progress_bar_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamProgressBarThemeData {
  bool get canMerge => true;

  static StreamProgressBarThemeData? lerp(
    StreamProgressBarThemeData? a,
    StreamProgressBarThemeData? b,
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

    return StreamProgressBarThemeData(
      trackColor: Color.lerp(a.trackColor, b.trackColor, t),
      fillColor: Color.lerp(a.fillColor, b.fillColor, t),
      minHeight: lerpDouble$(a.minHeight, b.minHeight, t),
      borderRadius: BorderRadiusGeometry.lerp(
        a.borderRadius,
        b.borderRadius,
        t,
      ),
    );
  }

  StreamProgressBarThemeData copyWith({
    Color? trackColor,
    Color? fillColor,
    double? minHeight,
    BorderRadiusGeometry? borderRadius,
  }) {
    final _this = (this as StreamProgressBarThemeData);

    return StreamProgressBarThemeData(
      trackColor: trackColor ?? _this.trackColor,
      fillColor: fillColor ?? _this.fillColor,
      minHeight: minHeight ?? _this.minHeight,
      borderRadius: borderRadius ?? _this.borderRadius,
    );
  }

  StreamProgressBarThemeData merge(StreamProgressBarThemeData? other) {
    final _this = (this as StreamProgressBarThemeData);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      trackColor: other.trackColor,
      fillColor: other.fillColor,
      minHeight: other.minHeight,
      borderRadius: other.borderRadius,
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

    final _this = (this as StreamProgressBarThemeData);
    final _other = (other as StreamProgressBarThemeData);

    return _other.trackColor == _this.trackColor &&
        _other.fillColor == _this.fillColor &&
        _other.minHeight == _this.minHeight &&
        _other.borderRadius == _this.borderRadius;
  }

  @override
  int get hashCode {
    final _this = (this as StreamProgressBarThemeData);

    return Object.hash(
      runtimeType,
      _this.trackColor,
      _this.fillColor,
      _this.minHeight,
      _this.borderRadius,
    );
  }
}
