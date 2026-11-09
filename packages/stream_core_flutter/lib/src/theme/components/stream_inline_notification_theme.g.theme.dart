// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_inline_notification_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamInlineNotificationThemeData {
  bool get canMerge => true;

  static StreamInlineNotificationThemeData? lerp(
    StreamInlineNotificationThemeData? a,
    StreamInlineNotificationThemeData? b,
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

    return StreamInlineNotificationThemeData(
      info: StreamInlineNotificationThemeStyle.lerp(a.info, b.info, t),
      success: StreamInlineNotificationThemeStyle.lerp(a.success, b.success, t),
      warning: StreamInlineNotificationThemeStyle.lerp(a.warning, b.warning, t),
      error: StreamInlineNotificationThemeStyle.lerp(a.error, b.error, t),
      shape: OutlinedBorder.lerp(a.shape, b.shape, t),
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      spacing: lerpDouble$(a.spacing, b.spacing, t),
      constraints: BoxConstraints.lerp(a.constraints, b.constraints, t),
    );
  }

  StreamInlineNotificationThemeData copyWith({
    StreamInlineNotificationThemeStyle? info,
    StreamInlineNotificationThemeStyle? success,
    StreamInlineNotificationThemeStyle? warning,
    StreamInlineNotificationThemeStyle? error,
    OutlinedBorder? shape,
    EdgeInsetsGeometry? padding,
    double? spacing,
    BoxConstraints? constraints,
  }) {
    final _this = (this as StreamInlineNotificationThemeData);

    return StreamInlineNotificationThemeData(
      info: info ?? _this.info,
      success: success ?? _this.success,
      warning: warning ?? _this.warning,
      error: error ?? _this.error,
      shape: shape ?? _this.shape,
      padding: padding ?? _this.padding,
      spacing: spacing ?? _this.spacing,
      constraints: constraints ?? _this.constraints,
    );
  }

  StreamInlineNotificationThemeData merge(
    StreamInlineNotificationThemeData? other,
  ) {
    final _this = (this as StreamInlineNotificationThemeData);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      info: _this.info?.merge(other.info) ?? other.info,
      success: _this.success?.merge(other.success) ?? other.success,
      warning: _this.warning?.merge(other.warning) ?? other.warning,
      error: _this.error?.merge(other.error) ?? other.error,
      shape: other.shape,
      padding: other.padding,
      spacing: other.spacing,
      constraints: other.constraints,
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

    final _this = (this as StreamInlineNotificationThemeData);
    final _other = (other as StreamInlineNotificationThemeData);

    return _other.info == _this.info &&
        _other.success == _this.success &&
        _other.warning == _this.warning &&
        _other.error == _this.error &&
        _other.shape == _this.shape &&
        _other.padding == _this.padding &&
        _other.spacing == _this.spacing &&
        _other.constraints == _this.constraints;
  }

  @override
  int get hashCode {
    final _this = (this as StreamInlineNotificationThemeData);

    return Object.hash(
      runtimeType,
      _this.info,
      _this.success,
      _this.warning,
      _this.error,
      _this.shape,
      _this.padding,
      _this.spacing,
      _this.constraints,
    );
  }
}

mixin _$StreamInlineNotificationThemeStyle {
  bool get canMerge => true;

  static StreamInlineNotificationThemeStyle? lerp(
    StreamInlineNotificationThemeStyle? a,
    StreamInlineNotificationThemeStyle? b,
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

    return StreamInlineNotificationThemeStyle(
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      iconColor: Color.lerp(a.iconColor, b.iconColor, t),
      titleTextStyle: TextStyle.lerp(a.titleTextStyle, b.titleTextStyle, t),
      descriptionTextStyle: TextStyle.lerp(
        a.descriptionTextStyle,
        b.descriptionTextStyle,
        t,
      ),
    );
  }

  StreamInlineNotificationThemeStyle copyWith({
    Color? backgroundColor,
    Color? iconColor,
    TextStyle? titleTextStyle,
    TextStyle? descriptionTextStyle,
  }) {
    final _this = (this as StreamInlineNotificationThemeStyle);

    return StreamInlineNotificationThemeStyle(
      backgroundColor: backgroundColor ?? _this.backgroundColor,
      iconColor: iconColor ?? _this.iconColor,
      titleTextStyle: titleTextStyle ?? _this.titleTextStyle,
      descriptionTextStyle: descriptionTextStyle ?? _this.descriptionTextStyle,
    );
  }

  StreamInlineNotificationThemeStyle merge(
    StreamInlineNotificationThemeStyle? other,
  ) {
    final _this = (this as StreamInlineNotificationThemeStyle);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      backgroundColor: other.backgroundColor,
      iconColor: other.iconColor,
      titleTextStyle:
          _this.titleTextStyle?.merge(other.titleTextStyle) ??
          other.titleTextStyle,
      descriptionTextStyle:
          _this.descriptionTextStyle?.merge(other.descriptionTextStyle) ??
          other.descriptionTextStyle,
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

    final _this = (this as StreamInlineNotificationThemeStyle);
    final _other = (other as StreamInlineNotificationThemeStyle);

    return _other.backgroundColor == _this.backgroundColor &&
        _other.iconColor == _this.iconColor &&
        _other.titleTextStyle == _this.titleTextStyle &&
        _other.descriptionTextStyle == _this.descriptionTextStyle;
  }

  @override
  int get hashCode {
    final _this = (this as StreamInlineNotificationThemeStyle);

    return Object.hash(
      runtimeType,
      _this.backgroundColor,
      _this.iconColor,
      _this.titleTextStyle,
      _this.descriptionTextStyle,
    );
  }
}
