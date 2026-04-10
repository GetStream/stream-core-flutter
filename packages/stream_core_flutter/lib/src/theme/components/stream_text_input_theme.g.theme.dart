// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_text_input_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamTextInputThemeData {
  bool get canMerge => true;

  static StreamTextInputThemeData? lerp(
    StreamTextInputThemeData? a,
    StreamTextInputThemeData? b,
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

    return StreamTextInputThemeData(
      style: StreamTextInputStyle.lerp(a.style, b.style, t),
    );
  }

  StreamTextInputThemeData copyWith({StreamTextInputStyle? style}) {
    final _this = (this as StreamTextInputThemeData);

    return StreamTextInputThemeData(style: style ?? _this.style);
  }

  StreamTextInputThemeData merge(StreamTextInputThemeData? other) {
    final _this = (this as StreamTextInputThemeData);

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

    final _this = (this as StreamTextInputThemeData);
    final _other = (other as StreamTextInputThemeData);

    return _other.style == _this.style;
  }

  @override
  int get hashCode {
    final _this = (this as StreamTextInputThemeData);

    return Object.hash(runtimeType, _this.style);
  }
}

mixin _$StreamTextInputStyle {
  bool get canMerge => true;

  static StreamTextInputStyle? lerp(
    StreamTextInputStyle? a,
    StreamTextInputStyle? b,
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

    return StreamTextInputStyle(
      textStyle: TextStyle.lerp(a.textStyle, b.textStyle, t),
      hintStyle: TextStyle.lerp(a.hintStyle, b.hintStyle, t),
      iconColor: Color.lerp(a.iconColor, b.iconColor, t),
      iconSize: lerpDouble$(a.iconSize, b.iconSize, t),
      helperInfoStyle: TextStyle.lerp(a.helperInfoStyle, b.helperInfoStyle, t),
      helperErrorStyle: TextStyle.lerp(
        a.helperErrorStyle,
        b.helperErrorStyle,
        t,
      ),
      helperSuccessStyle: TextStyle.lerp(
        a.helperSuccessStyle,
        b.helperSuccessStyle,
        t,
      ),
      borderRadius: BorderRadiusGeometry.lerp(
        a.borderRadius,
        b.borderRadius,
        t,
      ),
      border: a.border == null
          ? b.border
          : b.border == null
          ? a.border
          : BorderSide.lerp(a.border!, b.border!, t),
      focusBorder: a.focusBorder == null
          ? b.focusBorder
          : b.focusBorder == null
          ? a.focusBorder
          : BorderSide.lerp(a.focusBorder!, b.focusBorder!, t),
      errorBorder: a.errorBorder == null
          ? b.errorBorder
          : b.errorBorder == null
          ? a.errorBorder
          : BorderSide.lerp(a.errorBorder!, b.errorBorder!, t),
      fillColor: Color.lerp(a.fillColor, b.fillColor, t),
      contentPadding: EdgeInsetsGeometry.lerp(
        a.contentPadding,
        b.contentPadding,
        t,
      ),
      constraints: BoxConstraints.lerp(a.constraints, b.constraints, t),
      helperIconSize: lerpDouble$(a.helperIconSize, b.helperIconSize, t),
      helperMaxLines: t < 0.5 ? a.helperMaxLines : b.helperMaxLines,
    );
  }

  StreamTextInputStyle copyWith({
    TextStyle? textStyle,
    TextStyle? hintStyle,
    Color? iconColor,
    double? iconSize,
    TextStyle? helperInfoStyle,
    TextStyle? helperErrorStyle,
    TextStyle? helperSuccessStyle,
    BorderRadiusGeometry? borderRadius,
    BorderSide? border,
    BorderSide? focusBorder,
    BorderSide? errorBorder,
    Color? fillColor,
    EdgeInsetsGeometry? contentPadding,
    BoxConstraints? constraints,
    double? helperIconSize,
    int? helperMaxLines,
  }) {
    final _this = (this as StreamTextInputStyle);

    return StreamTextInputStyle(
      textStyle: textStyle ?? _this.textStyle,
      hintStyle: hintStyle ?? _this.hintStyle,
      iconColor: iconColor ?? _this.iconColor,
      iconSize: iconSize ?? _this.iconSize,
      helperInfoStyle: helperInfoStyle ?? _this.helperInfoStyle,
      helperErrorStyle: helperErrorStyle ?? _this.helperErrorStyle,
      helperSuccessStyle: helperSuccessStyle ?? _this.helperSuccessStyle,
      borderRadius: borderRadius ?? _this.borderRadius,
      border: border ?? _this.border,
      focusBorder: focusBorder ?? _this.focusBorder,
      errorBorder: errorBorder ?? _this.errorBorder,
      fillColor: fillColor ?? _this.fillColor,
      contentPadding: contentPadding ?? _this.contentPadding,
      constraints: constraints ?? _this.constraints,
      helperIconSize: helperIconSize ?? _this.helperIconSize,
      helperMaxLines: helperMaxLines ?? _this.helperMaxLines,
    );
  }

  StreamTextInputStyle merge(StreamTextInputStyle? other) {
    final _this = (this as StreamTextInputStyle);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      textStyle: _this.textStyle?.merge(other.textStyle) ?? other.textStyle,
      hintStyle: _this.hintStyle?.merge(other.hintStyle) ?? other.hintStyle,
      iconColor: other.iconColor,
      iconSize: other.iconSize,
      helperInfoStyle:
          _this.helperInfoStyle?.merge(other.helperInfoStyle) ??
          other.helperInfoStyle,
      helperErrorStyle:
          _this.helperErrorStyle?.merge(other.helperErrorStyle) ??
          other.helperErrorStyle,
      helperSuccessStyle:
          _this.helperSuccessStyle?.merge(other.helperSuccessStyle) ??
          other.helperSuccessStyle,
      borderRadius: other.borderRadius,
      border: _this.border != null && other.border != null
          ? BorderSide.merge(_this.border!, other.border!)
          : other.border,
      focusBorder: _this.focusBorder != null && other.focusBorder != null
          ? BorderSide.merge(_this.focusBorder!, other.focusBorder!)
          : other.focusBorder,
      errorBorder: _this.errorBorder != null && other.errorBorder != null
          ? BorderSide.merge(_this.errorBorder!, other.errorBorder!)
          : other.errorBorder,
      fillColor: other.fillColor,
      contentPadding: other.contentPadding,
      constraints: other.constraints,
      helperIconSize: other.helperIconSize,
      helperMaxLines: other.helperMaxLines,
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

    final _this = (this as StreamTextInputStyle);
    final _other = (other as StreamTextInputStyle);

    return _other.textStyle == _this.textStyle &&
        _other.hintStyle == _this.hintStyle &&
        _other.iconColor == _this.iconColor &&
        _other.iconSize == _this.iconSize &&
        _other.helperInfoStyle == _this.helperInfoStyle &&
        _other.helperErrorStyle == _this.helperErrorStyle &&
        _other.helperSuccessStyle == _this.helperSuccessStyle &&
        _other.borderRadius == _this.borderRadius &&
        _other.border == _this.border &&
        _other.focusBorder == _this.focusBorder &&
        _other.errorBorder == _this.errorBorder &&
        _other.fillColor == _this.fillColor &&
        _other.contentPadding == _this.contentPadding &&
        _other.constraints == _this.constraints &&
        _other.helperIconSize == _this.helperIconSize &&
        _other.helperMaxLines == _this.helperMaxLines;
  }

  @override
  int get hashCode {
    final _this = (this as StreamTextInputStyle);

    return Object.hash(
      runtimeType,
      _this.textStyle,
      _this.hintStyle,
      _this.iconColor,
      _this.iconSize,
      _this.helperInfoStyle,
      _this.helperErrorStyle,
      _this.helperSuccessStyle,
      _this.borderRadius,
      _this.border,
      _this.focusBorder,
      _this.errorBorder,
      _this.fillColor,
      _this.contentPadding,
      _this.constraints,
      _this.helperIconSize,
      _this.helperMaxLines,
    );
  }
}
