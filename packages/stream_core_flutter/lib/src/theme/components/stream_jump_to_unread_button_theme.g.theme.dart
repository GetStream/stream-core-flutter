// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_jump_to_unread_button_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamJumpToUnreadButtonThemeData {
  bool get canMerge => true;

  static StreamJumpToUnreadButtonThemeData? lerp(
    StreamJumpToUnreadButtonThemeData? a,
    StreamJumpToUnreadButtonThemeData? b,
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

    return StreamJumpToUnreadButtonThemeData(
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      shape: OutlinedBorder.lerp(a.shape, b.shape, t),
      side: a.side == null
          ? b.side
          : b.side == null
          ? a.side
          : BorderSide.lerp(a.side!, b.side!, t),
      elevation: lerpDouble$(a.elevation, b.elevation, t),
      shadowColor: Color.lerp(a.shadowColor, b.shadowColor, t),
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      leadingStyle: StreamButtonThemeStyle.lerp(
        a.leadingStyle,
        b.leadingStyle,
        t,
      ),
      trailingStyle: StreamButtonThemeStyle.lerp(
        a.trailingStyle,
        b.trailingStyle,
        t,
      ),
    );
  }

  StreamJumpToUnreadButtonThemeData copyWith({
    Color? backgroundColor,
    OutlinedBorder? shape,
    BorderSide? side,
    double? elevation,
    Color? shadowColor,
    EdgeInsetsGeometry? padding,
    StreamButtonThemeStyle? leadingStyle,
    StreamButtonThemeStyle? trailingStyle,
  }) {
    final _this = (this as StreamJumpToUnreadButtonThemeData);

    return StreamJumpToUnreadButtonThemeData(
      backgroundColor: backgroundColor ?? _this.backgroundColor,
      shape: shape ?? _this.shape,
      side: side ?? _this.side,
      elevation: elevation ?? _this.elevation,
      shadowColor: shadowColor ?? _this.shadowColor,
      padding: padding ?? _this.padding,
      leadingStyle: leadingStyle ?? _this.leadingStyle,
      trailingStyle: trailingStyle ?? _this.trailingStyle,
    );
  }

  StreamJumpToUnreadButtonThemeData merge(
    StreamJumpToUnreadButtonThemeData? other,
  ) {
    final _this = (this as StreamJumpToUnreadButtonThemeData);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      backgroundColor: other.backgroundColor,
      shape: other.shape,
      side: _this.side != null && other.side != null
          ? BorderSide.merge(_this.side!, other.side!)
          : other.side,
      elevation: other.elevation,
      shadowColor: other.shadowColor,
      padding: other.padding,
      leadingStyle:
          _this.leadingStyle?.merge(other.leadingStyle) ?? other.leadingStyle,
      trailingStyle:
          _this.trailingStyle?.merge(other.trailingStyle) ??
          other.trailingStyle,
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

    final _this = (this as StreamJumpToUnreadButtonThemeData);
    final _other = (other as StreamJumpToUnreadButtonThemeData);

    return _other.backgroundColor == _this.backgroundColor &&
        _other.shape == _this.shape &&
        _other.side == _this.side &&
        _other.elevation == _this.elevation &&
        _other.shadowColor == _this.shadowColor &&
        _other.padding == _this.padding &&
        _other.leadingStyle == _this.leadingStyle &&
        _other.trailingStyle == _this.trailingStyle;
  }

  @override
  int get hashCode {
    final _this = (this as StreamJumpToUnreadButtonThemeData);

    return Object.hash(
      runtimeType,
      _this.backgroundColor,
      _this.shape,
      _this.side,
      _this.elevation,
      _this.shadowColor,
      _this.padding,
      _this.leadingStyle,
      _this.trailingStyle,
    );
  }
}
