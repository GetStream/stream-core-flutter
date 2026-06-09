// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_snackbar_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamSnackbarThemeData {
  bool get canMerge => true;

  static StreamSnackbarThemeData? lerp(
    StreamSnackbarThemeData? a,
    StreamSnackbarThemeData? b,
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

    return StreamSnackbarThemeData(
      style: StreamSnackbarStyle.lerp(a.style, b.style, t),
    );
  }

  StreamSnackbarThemeData copyWith({StreamSnackbarStyle? style}) {
    final _this = (this as StreamSnackbarThemeData);

    return StreamSnackbarThemeData(style: style ?? _this.style);
  }

  StreamSnackbarThemeData merge(StreamSnackbarThemeData? other) {
    final _this = (this as StreamSnackbarThemeData);

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

    final _this = (this as StreamSnackbarThemeData);
    final _other = (other as StreamSnackbarThemeData);

    return _other.style == _this.style;
  }

  @override
  int get hashCode {
    final _this = (this as StreamSnackbarThemeData);

    return Object.hash(runtimeType, _this.style);
  }
}

mixin _$StreamSnackbarStyle {
  bool get canMerge => true;

  static StreamSnackbarStyle? lerp(
    StreamSnackbarStyle? a,
    StreamSnackbarStyle? b,
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

    return StreamSnackbarStyle(
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      foregroundColor: Color.lerp(a.foregroundColor, b.foregroundColor, t),
      shape: OutlinedBorder.lerp(a.shape, b.shape, t),
      side: a.side == null
          ? b.side
          : b.side == null
          ? a.side
          : BorderSide.lerp(a.side!, b.side!, t),
      elevation: lerpDouble$(a.elevation, b.elevation, t),
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      margin: EdgeInsetsGeometry.lerp(a.margin, b.margin, t),
      constraints: BoxConstraints.lerp(a.constraints, b.constraints, t),
      textStyle: TextStyle.lerp(a.textStyle, b.textStyle, t),
      actionStyle: StreamButtonThemeStyle.lerp(a.actionStyle, b.actionStyle, t),
      dismissDirection: t < 0.5 ? a.dismissDirection : b.dismissDirection,
    );
  }

  StreamSnackbarStyle copyWith({
    Color? backgroundColor,
    Color? foregroundColor,
    OutlinedBorder? shape,
    BorderSide? side,
    double? elevation,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BoxConstraints? constraints,
    TextStyle? textStyle,
    StreamButtonThemeStyle? actionStyle,
    DismissDirection? dismissDirection,
  }) {
    final _this = (this as StreamSnackbarStyle);

    return StreamSnackbarStyle(
      backgroundColor: backgroundColor ?? _this.backgroundColor,
      foregroundColor: foregroundColor ?? _this.foregroundColor,
      shape: shape ?? _this.shape,
      side: side ?? _this.side,
      elevation: elevation ?? _this.elevation,
      padding: padding ?? _this.padding,
      margin: margin ?? _this.margin,
      constraints: constraints ?? _this.constraints,
      textStyle: textStyle ?? _this.textStyle,
      actionStyle: actionStyle ?? _this.actionStyle,
      dismissDirection: dismissDirection ?? _this.dismissDirection,
    );
  }

  StreamSnackbarStyle merge(StreamSnackbarStyle? other) {
    final _this = (this as StreamSnackbarStyle);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      backgroundColor: other.backgroundColor,
      foregroundColor: other.foregroundColor,
      shape: other.shape,
      side: _this.side != null && other.side != null
          ? BorderSide.merge(_this.side!, other.side!)
          : other.side,
      elevation: other.elevation,
      padding: other.padding,
      margin: other.margin,
      constraints: other.constraints,
      textStyle: _this.textStyle?.merge(other.textStyle) ?? other.textStyle,
      actionStyle:
          _this.actionStyle?.merge(other.actionStyle) ?? other.actionStyle,
      dismissDirection: other.dismissDirection,
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

    final _this = (this as StreamSnackbarStyle);
    final _other = (other as StreamSnackbarStyle);

    return _other.backgroundColor == _this.backgroundColor &&
        _other.foregroundColor == _this.foregroundColor &&
        _other.shape == _this.shape &&
        _other.side == _this.side &&
        _other.elevation == _this.elevation &&
        _other.padding == _this.padding &&
        _other.margin == _this.margin &&
        _other.constraints == _this.constraints &&
        _other.textStyle == _this.textStyle &&
        _other.actionStyle == _this.actionStyle &&
        _other.dismissDirection == _this.dismissDirection;
  }

  @override
  int get hashCode {
    final _this = (this as StreamSnackbarStyle);

    return Object.hash(
      runtimeType,
      _this.backgroundColor,
      _this.foregroundColor,
      _this.shape,
      _this.side,
      _this.elevation,
      _this.padding,
      _this.margin,
      _this.constraints,
      _this.textStyle,
      _this.actionStyle,
      _this.dismissDirection,
    );
  }
}
