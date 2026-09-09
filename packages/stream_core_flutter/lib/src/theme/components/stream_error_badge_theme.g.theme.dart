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
      errorStyle: StreamErrorBadgeThemeStyle.lerp(
        a.errorStyle,
        b.errorStyle,
        t,
      ),
      warningStyle: StreamErrorBadgeThemeStyle.lerp(
        a.warningStyle,
        b.warningStyle,
        t,
      ),
      border: BoxBorder.lerp(a.border, b.border, t),
    );
  }

  StreamErrorBadgeThemeData copyWith({
    StreamErrorBadgeSize? size,
    StreamErrorBadgeThemeStyle? errorStyle,
    StreamErrorBadgeThemeStyle? warningStyle,
    BoxBorder? border,
  }) {
    final _this = (this as StreamErrorBadgeThemeData);

    return StreamErrorBadgeThemeData(
      size: size ?? _this.size,
      errorStyle: errorStyle ?? _this.errorStyle,
      warningStyle: warningStyle ?? _this.warningStyle,
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
      errorStyle: _this.errorStyle?.merge(other.errorStyle) ?? other.errorStyle,
      warningStyle:
          _this.warningStyle?.merge(other.warningStyle) ?? other.warningStyle,
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
        _other.errorStyle == _this.errorStyle &&
        _other.warningStyle == _this.warningStyle &&
        _other.border == _this.border;
  }

  @override
  int get hashCode {
    final _this = (this as StreamErrorBadgeThemeData);

    return Object.hash(
      runtimeType,
      _this.size,
      _this.errorStyle,
      _this.warningStyle,
      _this.border,
    );
  }
}

mixin _$StreamErrorBadgeThemeStyle {
  bool get canMerge => true;

  static StreamErrorBadgeThemeStyle? lerp(
    StreamErrorBadgeThemeStyle? a,
    StreamErrorBadgeThemeStyle? b,
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

    return StreamErrorBadgeThemeStyle(
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      foregroundColor: Color.lerp(a.foregroundColor, b.foregroundColor, t),
    );
  }

  StreamErrorBadgeThemeStyle copyWith({
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    final _this = (this as StreamErrorBadgeThemeStyle);

    return StreamErrorBadgeThemeStyle(
      backgroundColor: backgroundColor ?? _this.backgroundColor,
      foregroundColor: foregroundColor ?? _this.foregroundColor,
    );
  }

  StreamErrorBadgeThemeStyle merge(StreamErrorBadgeThemeStyle? other) {
    final _this = (this as StreamErrorBadgeThemeStyle);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      backgroundColor: other.backgroundColor,
      foregroundColor: other.foregroundColor,
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

    final _this = (this as StreamErrorBadgeThemeStyle);
    final _other = (other as StreamErrorBadgeThemeStyle);

    return _other.backgroundColor == _this.backgroundColor &&
        _other.foregroundColor == _this.foregroundColor;
  }

  @override
  int get hashCode {
    final _this = (this as StreamErrorBadgeThemeStyle);

    return Object.hash(
      runtimeType,
      _this.backgroundColor,
      _this.foregroundColor,
    );
  }
}
