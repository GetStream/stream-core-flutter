// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_badge_count_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamBadgeCountThemeData {
  bool get canMerge => true;

  static StreamBadgeCountThemeData? lerp(
    StreamBadgeCountThemeData? a,
    StreamBadgeCountThemeData? b,
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

    return StreamBadgeCountThemeData(
      size: t < 0.5 ? a.size : b.size,
      textColor: Color.lerp(a.textColor, b.textColor, t),
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      borderColor: Color.lerp(a.borderColor, b.borderColor, t),
    );
  }

  StreamBadgeCountThemeData copyWith({
    StreamBadgeCountSize? size,
    Color? textColor,
    Color? backgroundColor,
    Color? borderColor,
  }) {
    final _this = (this as StreamBadgeCountThemeData);

    return StreamBadgeCountThemeData(
      size: size ?? _this.size,
      textColor: textColor ?? _this.textColor,
      backgroundColor: backgroundColor ?? _this.backgroundColor,
      borderColor: borderColor ?? _this.borderColor,
    );
  }

  StreamBadgeCountThemeData merge(StreamBadgeCountThemeData? other) {
    final _this = (this as StreamBadgeCountThemeData);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      size: other.size,
      textColor: other.textColor,
      backgroundColor: other.backgroundColor,
      borderColor: other.borderColor,
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

    final _this = (this as StreamBadgeCountThemeData);
    final _other = (other as StreamBadgeCountThemeData);

    return _other.size == _this.size &&
        _other.textColor == _this.textColor &&
        _other.backgroundColor == _this.backgroundColor &&
        _other.borderColor == _this.borderColor;
  }

  @override
  int get hashCode {
    final _this = (this as StreamBadgeCountThemeData);

    return Object.hash(
      runtimeType,
      _this.size,
      _this.textColor,
      _this.backgroundColor,
      _this.borderColor,
    );
  }
}
