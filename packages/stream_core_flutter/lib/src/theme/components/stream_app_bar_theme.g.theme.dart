// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_app_bar_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamAppBarThemeData {
  bool get canMerge => true;

  static StreamAppBarThemeData? lerp(
    StreamAppBarThemeData? a,
    StreamAppBarThemeData? b,
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

    return StreamAppBarThemeData(
      style: StreamAppBarStyle.lerp(a.style, b.style, t),
    );
  }

  StreamAppBarThemeData copyWith({StreamAppBarStyle? style}) {
    final _this = (this as StreamAppBarThemeData);

    return StreamAppBarThemeData(style: style ?? _this.style);
  }

  StreamAppBarThemeData merge(StreamAppBarThemeData? other) {
    final _this = (this as StreamAppBarThemeData);

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

    final _this = (this as StreamAppBarThemeData);
    final _other = (other as StreamAppBarThemeData);

    return _other.style == _this.style;
  }

  @override
  int get hashCode {
    final _this = (this as StreamAppBarThemeData);

    return Object.hash(runtimeType, _this.style);
  }
}

mixin _$StreamAppBarStyle {
  bool get canMerge => true;

  static StreamAppBarStyle? lerp(
    StreamAppBarStyle? a,
    StreamAppBarStyle? b,
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

    return StreamAppBarStyle(
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      spacing: lerpDouble$(a.spacing, b.spacing, t),
      titleTextStyle: TextStyle.lerp(a.titleTextStyle, b.titleTextStyle, t),
      subtitleTextStyle: TextStyle.lerp(
        a.subtitleTextStyle,
        b.subtitleTextStyle,
        t,
      ),
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

  StreamAppBarStyle copyWith({
    Color? backgroundColor,
    EdgeInsetsGeometry? padding,
    double? spacing,
    TextStyle? titleTextStyle,
    TextStyle? subtitleTextStyle,
    StreamButtonThemeStyle? leadingStyle,
    StreamButtonThemeStyle? trailingStyle,
  }) {
    final _this = (this as StreamAppBarStyle);

    return StreamAppBarStyle(
      backgroundColor: backgroundColor ?? _this.backgroundColor,
      padding: padding ?? _this.padding,
      spacing: spacing ?? _this.spacing,
      titleTextStyle: titleTextStyle ?? _this.titleTextStyle,
      subtitleTextStyle: subtitleTextStyle ?? _this.subtitleTextStyle,
      leadingStyle: leadingStyle ?? _this.leadingStyle,
      trailingStyle: trailingStyle ?? _this.trailingStyle,
    );
  }

  StreamAppBarStyle merge(StreamAppBarStyle? other) {
    final _this = (this as StreamAppBarStyle);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      backgroundColor: other.backgroundColor,
      padding: other.padding,
      spacing: other.spacing,
      titleTextStyle:
          _this.titleTextStyle?.merge(other.titleTextStyle) ??
          other.titleTextStyle,
      subtitleTextStyle:
          _this.subtitleTextStyle?.merge(other.subtitleTextStyle) ??
          other.subtitleTextStyle,
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

    final _this = (this as StreamAppBarStyle);
    final _other = (other as StreamAppBarStyle);

    return _other.backgroundColor == _this.backgroundColor &&
        _other.padding == _this.padding &&
        _other.spacing == _this.spacing &&
        _other.titleTextStyle == _this.titleTextStyle &&
        _other.subtitleTextStyle == _this.subtitleTextStyle &&
        _other.leadingStyle == _this.leadingStyle &&
        _other.trailingStyle == _this.trailingStyle;
  }

  @override
  int get hashCode {
    final _this = (this as StreamAppBarStyle);

    return Object.hash(
      runtimeType,
      _this.backgroundColor,
      _this.padding,
      _this.spacing,
      _this.titleTextStyle,
      _this.subtitleTextStyle,
      _this.leadingStyle,
      _this.trailingStyle,
    );
  }
}
