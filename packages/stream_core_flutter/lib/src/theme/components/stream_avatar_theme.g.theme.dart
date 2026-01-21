// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_avatar_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamAvatarThemeData {
  bool get canMerge => true;

  static StreamAvatarThemeData? lerp(
    StreamAvatarThemeData? a,
    StreamAvatarThemeData? b,
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

    return StreamAvatarThemeData(
      size: t < 0.5 ? a.size : b.size,
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      foregroundColor: Color.lerp(a.foregroundColor, b.foregroundColor, t),
      borderColor: Color.lerp(a.borderColor, b.borderColor, t),
    );
  }

  StreamAvatarThemeData copyWith({
    StreamAvatarSize? size,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? borderColor,
  }) {
    final _this = (this as StreamAvatarThemeData);

    return StreamAvatarThemeData(
      size: size ?? _this.size,
      backgroundColor: backgroundColor ?? _this.backgroundColor,
      foregroundColor: foregroundColor ?? _this.foregroundColor,
      borderColor: borderColor ?? _this.borderColor,
    );
  }

  StreamAvatarThemeData merge(StreamAvatarThemeData? other) {
    final _this = (this as StreamAvatarThemeData);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      size: other.size,
      backgroundColor: other.backgroundColor,
      foregroundColor: other.foregroundColor,
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

    final _this = (this as StreamAvatarThemeData);
    final _other = (other as StreamAvatarThemeData);

    return _other.size == _this.size &&
        _other.backgroundColor == _this.backgroundColor &&
        _other.foregroundColor == _this.foregroundColor &&
        _other.borderColor == _this.borderColor;
  }

  @override
  int get hashCode {
    final _this = (this as StreamAvatarThemeData);

    return Object.hash(
      runtimeType,
      _this.size,
      _this.backgroundColor,
      _this.foregroundColor,
      _this.borderColor,
    );
  }
}
