// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_online_indicator_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamOnlineIndicatorThemeData {
  bool get canMerge => true;

  static StreamOnlineIndicatorThemeData? lerp(
    StreamOnlineIndicatorThemeData? a,
    StreamOnlineIndicatorThemeData? b,
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

    return StreamOnlineIndicatorThemeData(
      backgroundOnline: Color.lerp(a.backgroundOnline, b.backgroundOnline, t),
      backgroundOffline: Color.lerp(
        a.backgroundOffline,
        b.backgroundOffline,
        t,
      ),
      borderColor: Color.lerp(a.borderColor, b.borderColor, t),
    );
  }

  StreamOnlineIndicatorThemeData copyWith({
    Color? backgroundOnline,
    Color? backgroundOffline,
    Color? borderColor,
  }) {
    final _this = (this as StreamOnlineIndicatorThemeData);

    return StreamOnlineIndicatorThemeData(
      backgroundOnline: backgroundOnline ?? _this.backgroundOnline,
      backgroundOffline: backgroundOffline ?? _this.backgroundOffline,
      borderColor: borderColor ?? _this.borderColor,
    );
  }

  StreamOnlineIndicatorThemeData merge(StreamOnlineIndicatorThemeData? other) {
    final _this = (this as StreamOnlineIndicatorThemeData);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      backgroundOnline: other.backgroundOnline,
      backgroundOffline: other.backgroundOffline,
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

    final _this = (this as StreamOnlineIndicatorThemeData);
    final _other = (other as StreamOnlineIndicatorThemeData);

    return _other.backgroundOnline == _this.backgroundOnline &&
        _other.backgroundOffline == _this.backgroundOffline &&
        _other.borderColor == _this.borderColor;
  }

  @override
  int get hashCode {
    final _this = (this as StreamOnlineIndicatorThemeData);

    return Object.hash(
      runtimeType,
      _this.backgroundOnline,
      _this.backgroundOffline,
      _this.borderColor,
    );
  }
}
