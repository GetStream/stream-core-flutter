// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_context_menu_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamContextMenuThemeData {
  bool get canMerge => true;

  static StreamContextMenuThemeData? lerp(
    StreamContextMenuThemeData? a,
    StreamContextMenuThemeData? b,
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

    return StreamContextMenuThemeData(
      style: StreamContextMenuStyle.lerp(a.style, b.style, t),
    );
  }

  StreamContextMenuThemeData copyWith({StreamContextMenuStyle? style}) {
    final _this = (this as StreamContextMenuThemeData);

    return StreamContextMenuThemeData(style: style ?? _this.style);
  }

  StreamContextMenuThemeData merge(StreamContextMenuThemeData? other) {
    final _this = (this as StreamContextMenuThemeData);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(style: _this.style?.merge(other.style) ?? other.style);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other.runtimeType != runtimeType) {
      return false;
    }

    final _this = (this as StreamContextMenuThemeData);
    final _other = (other as StreamContextMenuThemeData);

    return _other.style == _this.style;
  }

  @override
  int get hashCode {
    final _this = (this as StreamContextMenuThemeData);

    return Object.hash(runtimeType, _this.style);
  }
}

mixin _$StreamContextMenuStyle {
  bool get canMerge => true;

  static StreamContextMenuStyle? lerp(
    StreamContextMenuStyle? a,
    StreamContextMenuStyle? b,
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

    return StreamContextMenuStyle(
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      elevation: lerpDouble$(a.elevation, b.elevation, t),
      shape: OutlinedBorder.lerp(a.shape, b.shape, t),
      side: a.side == null
          ? b.side
          : b.side == null
          ? a.side
          : BorderSide.lerp(a.side!, b.side!, t),
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
    );
  }

  StreamContextMenuStyle copyWith({
    Color? backgroundColor,
    double? elevation,
    OutlinedBorder? shape,
    BorderSide? side,
    EdgeInsetsGeometry? padding,
  }) {
    final _this = (this as StreamContextMenuStyle);

    return StreamContextMenuStyle(
      backgroundColor: backgroundColor ?? _this.backgroundColor,
      elevation: elevation ?? _this.elevation,
      shape: shape ?? _this.shape,
      side: side ?? _this.side,
      padding: padding ?? _this.padding,
    );
  }

  StreamContextMenuStyle merge(StreamContextMenuStyle? other) {
    final _this = (this as StreamContextMenuStyle);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      backgroundColor: other.backgroundColor,
      elevation: other.elevation,
      shape: other.shape,
      side: _this.side != null && other.side != null
          ? BorderSide.merge(_this.side!, other.side!)
          : other.side,
      padding: other.padding,
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

    final _this = (this as StreamContextMenuStyle);
    final _other = (other as StreamContextMenuStyle);

    return _other.backgroundColor == _this.backgroundColor &&
        _other.elevation == _this.elevation &&
        _other.shape == _this.shape &&
        _other.side == _this.side &&
        _other.padding == _this.padding;
  }

  @override
  int get hashCode {
    final _this = (this as StreamContextMenuStyle);

    return Object.hash(
      runtimeType,
      _this.backgroundColor,
      _this.elevation,
      _this.shape,
      _this.side,
      _this.padding,
    );
  }
}
