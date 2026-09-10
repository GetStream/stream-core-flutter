// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_error_badge_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamErrorBadgeThemeData {
  bool get canMerge => true;

  static StreamErrorBadgeThemeData? lerp(
    StreamErrorBadgeThemeData? a,
    StreamErrorBadgeThemeData? b,
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

    return StreamErrorBadgeThemeData(
      size: t < 0.5 ? a.size : b.size,
      errorBackgroundColor: Color.lerp(
        a.errorBackgroundColor,
        b.errorBackgroundColor,
        t,
      ),
      errorForegroundColor: Color.lerp(
        a.errorForegroundColor,
        b.errorForegroundColor,
        t,
      ),
      warningBackgroundColor: Color.lerp(
        a.warningBackgroundColor,
        b.warningBackgroundColor,
        t,
      ),
      warningForegroundColor: Color.lerp(
        a.warningForegroundColor,
        b.warningForegroundColor,
        t,
      ),
      border: BoxBorder.lerp(a.border, b.border, t),
    );
  }

  StreamErrorBadgeThemeData copyWith({
    StreamErrorBadgeSize? size,
    Color? errorBackgroundColor,
    Color? errorForegroundColor,
    Color? warningBackgroundColor,
    Color? warningForegroundColor,
    BoxBorder? border,
  }) {
    final _this = (this as StreamErrorBadgeThemeData);

    return StreamErrorBadgeThemeData(
      size: size ?? _this.size,
      errorBackgroundColor: errorBackgroundColor ?? _this.errorBackgroundColor,
      errorForegroundColor: errorForegroundColor ?? _this.errorForegroundColor,
      warningBackgroundColor:
          warningBackgroundColor ?? _this.warningBackgroundColor,
      warningForegroundColor:
          warningForegroundColor ?? _this.warningForegroundColor,
      border: border ?? _this.border,
    );
  }

  StreamErrorBadgeThemeData merge(StreamErrorBadgeThemeData? other) {
    final _this = (this as StreamErrorBadgeThemeData);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      size: other.size,
      errorBackgroundColor: other.errorBackgroundColor,
      errorForegroundColor: other.errorForegroundColor,
      warningBackgroundColor: other.warningBackgroundColor,
      warningForegroundColor: other.warningForegroundColor,
      border: other.border,
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

    final _this = (this as StreamErrorBadgeThemeData);
    final _other = (other as StreamErrorBadgeThemeData);

    return _other.size == _this.size &&
        _other.errorBackgroundColor == _this.errorBackgroundColor &&
        _other.errorForegroundColor == _this.errorForegroundColor &&
        _other.warningBackgroundColor == _this.warningBackgroundColor &&
        _other.warningForegroundColor == _this.warningForegroundColor &&
        _other.border == _this.border;
  }

  @override
  int get hashCode {
    final _this = (this as StreamErrorBadgeThemeData);

    return Object.hash(
      runtimeType,
      _this.size,
      _this.errorBackgroundColor,
      _this.errorForegroundColor,
      _this.warningBackgroundColor,
      _this.warningForegroundColor,
      _this.border,
    );
  }
}
