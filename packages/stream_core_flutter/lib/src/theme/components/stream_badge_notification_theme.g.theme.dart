// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_badge_notification_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamBadgeNotificationThemeData {
  bool get canMerge => true;

  static StreamBadgeNotificationThemeData? lerp(
    StreamBadgeNotificationThemeData? a,
    StreamBadgeNotificationThemeData? b,
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

    return StreamBadgeNotificationThemeData(
      size: t < 0.5 ? a.size : b.size,
      primaryBackgroundColor: Color.lerp(
        a.primaryBackgroundColor,
        b.primaryBackgroundColor,
        t,
      ),
      errorBackgroundColor: Color.lerp(
        a.errorBackgroundColor,
        b.errorBackgroundColor,
        t,
      ),
      neutralBackgroundColor: Color.lerp(
        a.neutralBackgroundColor,
        b.neutralBackgroundColor,
        t,
      ),
      textColor: Color.lerp(a.textColor, b.textColor, t),
      borderColor: Color.lerp(a.borderColor, b.borderColor, t),
    );
  }

  StreamBadgeNotificationThemeData copyWith({
    StreamBadgeNotificationSize? size,
    Color? primaryBackgroundColor,
    Color? errorBackgroundColor,
    Color? neutralBackgroundColor,
    Color? textColor,
    Color? borderColor,
  }) {
    final _this = (this as StreamBadgeNotificationThemeData);

    return StreamBadgeNotificationThemeData(
      size: size ?? _this.size,
      primaryBackgroundColor:
          primaryBackgroundColor ?? _this.primaryBackgroundColor,
      errorBackgroundColor: errorBackgroundColor ?? _this.errorBackgroundColor,
      neutralBackgroundColor:
          neutralBackgroundColor ?? _this.neutralBackgroundColor,
      textColor: textColor ?? _this.textColor,
      borderColor: borderColor ?? _this.borderColor,
    );
  }

  StreamBadgeNotificationThemeData merge(
    StreamBadgeNotificationThemeData? other,
  ) {
    final _this = (this as StreamBadgeNotificationThemeData);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      size: other.size,
      primaryBackgroundColor: other.primaryBackgroundColor,
      errorBackgroundColor: other.errorBackgroundColor,
      neutralBackgroundColor: other.neutralBackgroundColor,
      textColor: other.textColor,
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

    final _this = (this as StreamBadgeNotificationThemeData);
    final _other = (other as StreamBadgeNotificationThemeData);

    return _other.size == _this.size &&
        _other.primaryBackgroundColor == _this.primaryBackgroundColor &&
        _other.errorBackgroundColor == _this.errorBackgroundColor &&
        _other.neutralBackgroundColor == _this.neutralBackgroundColor &&
        _other.textColor == _this.textColor &&
        _other.borderColor == _this.borderColor;
  }

  @override
  int get hashCode {
    final _this = (this as StreamBadgeNotificationThemeData);

    return Object.hash(
      runtimeType,
      _this.size,
      _this.primaryBackgroundColor,
      _this.errorBackgroundColor,
      _this.neutralBackgroundColor,
      _this.textColor,
      _this.borderColor,
    );
  }
}
