// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_banner_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamBannerThemeData {
  bool get canMerge => true;

  static StreamBannerThemeData? lerp(
    StreamBannerThemeData? a,
    StreamBannerThemeData? b,
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

    return StreamBannerThemeData(
      neutral: StreamBannerThemeStyle.lerp(a.neutral, b.neutral, t),
      loading: StreamBannerThemeStyle.lerp(a.loading, b.loading, t),
      error: StreamBannerThemeStyle.lerp(a.error, b.error, t),
      shape: OutlinedBorder.lerp(a.shape, b.shape, t),
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      spacing: lerpDouble$(a.spacing, b.spacing, t),
      constraints: BoxConstraints.lerp(a.constraints, b.constraints, t),
    );
  }

  StreamBannerThemeData copyWith({
    StreamBannerThemeStyle? neutral,
    StreamBannerThemeStyle? loading,
    StreamBannerThemeStyle? error,
    OutlinedBorder? shape,
    EdgeInsetsGeometry? padding,
    double? spacing,
    BoxConstraints? constraints,
  }) {
    final _this = (this as StreamBannerThemeData);

    return StreamBannerThemeData(
      neutral: neutral ?? _this.neutral,
      loading: loading ?? _this.loading,
      error: error ?? _this.error,
      shape: shape ?? _this.shape,
      padding: padding ?? _this.padding,
      spacing: spacing ?? _this.spacing,
      constraints: constraints ?? _this.constraints,
    );
  }

  StreamBannerThemeData merge(StreamBannerThemeData? other) {
    final _this = (this as StreamBannerThemeData);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      neutral: _this.neutral?.merge(other.neutral) ?? other.neutral,
      loading: _this.loading?.merge(other.loading) ?? other.loading,
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

    final _this = (this as StreamBannerThemeData);
    final _other = (other as StreamBannerThemeData);

    return _other.neutral == _this.neutral &&
        _other.loading == _this.loading &&
        _other.error == _this.error &&
        _other.shape == _this.shape &&
        _other.padding == _this.padding &&
        _other.spacing == _this.spacing &&
        _other.constraints == _this.constraints;
  }

  @override
  int get hashCode {
    final _this = (this as StreamBannerThemeData);

    return Object.hash(
      runtimeType,
      _this.neutral,
      _this.loading,
      _this.error,
      _this.shape,
      _this.padding,
      _this.spacing,
      _this.constraints,
    );
  }
}

mixin _$StreamBannerThemeStyle {
  bool get canMerge => true;

  static StreamBannerThemeStyle? lerp(
    StreamBannerThemeStyle? a,
    StreamBannerThemeStyle? b,
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

    return StreamBannerThemeStyle(
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      iconColor: Color.lerp(a.iconColor, b.iconColor, t),
      titleTextStyle: TextStyle.lerp(a.titleTextStyle, b.titleTextStyle, t),
    );
  }

  StreamBannerThemeStyle copyWith({
    Color? backgroundColor,
    Color? iconColor,
    TextStyle? titleTextStyle,
  }) {
    final _this = (this as StreamBannerThemeStyle);

    return StreamBannerThemeStyle(
      backgroundColor: backgroundColor ?? _this.backgroundColor,
      iconColor: iconColor ?? _this.iconColor,
      titleTextStyle: titleTextStyle ?? _this.titleTextStyle,
    );
  }

  StreamBannerThemeStyle merge(StreamBannerThemeStyle? other) {
    final _this = (this as StreamBannerThemeStyle);

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

    final _this = (this as StreamBannerThemeStyle);
    final _other = (other as StreamBannerThemeStyle);

    return _other.backgroundColor == _this.backgroundColor &&
        _other.iconColor == _this.iconColor &&
        _other.titleTextStyle == _this.titleTextStyle;
  }

  @override
  int get hashCode {
    final _this = (this as StreamBannerThemeStyle);

    return Object.hash(
      runtimeType,
      _this.backgroundColor,
      _this.iconColor,
      _this.titleTextStyle,
    );
  }
}
