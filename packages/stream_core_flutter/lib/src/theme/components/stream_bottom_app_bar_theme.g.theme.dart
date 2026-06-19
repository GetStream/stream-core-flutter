// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_bottom_app_bar_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamBottomAppBarThemeData {
  bool get canMerge => true;

  static StreamBottomAppBarThemeData? lerp(
    StreamBottomAppBarThemeData? a,
    StreamBottomAppBarThemeData? b,
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

    return StreamBottomAppBarThemeData(
      style: StreamBottomAppBarStyle.lerp(a.style, b.style, t),
    );
  }

  StreamBottomAppBarThemeData copyWith({StreamBottomAppBarStyle? style}) {
    final _this = (this as StreamBottomAppBarThemeData);

    return StreamBottomAppBarThemeData(style: style ?? _this.style);
  }

  StreamBottomAppBarThemeData merge(StreamBottomAppBarThemeData? other) {
    final _this = (this as StreamBottomAppBarThemeData);

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

    final _this = (this as StreamBottomAppBarThemeData);
    final _other = (other as StreamBottomAppBarThemeData);

    return _other.style == _this.style;
  }

  @override
  int get hashCode {
    final _this = (this as StreamBottomAppBarThemeData);

    return Object.hash(runtimeType, _this.style);
  }
}

mixin _$StreamBottomAppBarStyle {
  bool get canMerge => true;

  static StreamBottomAppBarStyle? lerp(
    StreamBottomAppBarStyle? a,
    StreamBottomAppBarStyle? b,
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

    return StreamBottomAppBarStyle(
      behavior: t < 0.5 ? a.behavior : b.behavior,
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

  StreamBottomAppBarStyle copyWith({
    StreamBottomAppBarBehavior? behavior,
    Color? backgroundColor,
    EdgeInsetsGeometry? padding,
    double? spacing,
    TextStyle? titleTextStyle,
    TextStyle? subtitleTextStyle,
    StreamButtonThemeStyle? leadingStyle,
    StreamButtonThemeStyle? trailingStyle,
  }) {
    final _this = (this as StreamBottomAppBarStyle);

    return StreamBottomAppBarStyle(
      behavior: behavior ?? _this.behavior,
      backgroundColor: backgroundColor ?? _this.backgroundColor,
      padding: padding ?? _this.padding,
      spacing: spacing ?? _this.spacing,
      titleTextStyle: titleTextStyle ?? _this.titleTextStyle,
      subtitleTextStyle: subtitleTextStyle ?? _this.subtitleTextStyle,
      leadingStyle: leadingStyle ?? _this.leadingStyle,
      trailingStyle: trailingStyle ?? _this.trailingStyle,
    );
  }

  StreamBottomAppBarStyle merge(StreamBottomAppBarStyle? other) {
    final _this = (this as StreamBottomAppBarStyle);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      behavior: other.behavior,
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

    final _this = (this as StreamBottomAppBarStyle);
    final _other = (other as StreamBottomAppBarStyle);

    return _other.behavior == _this.behavior &&
        _other.backgroundColor == _this.backgroundColor &&
        _other.padding == _this.padding &&
        _other.spacing == _this.spacing &&
        _other.titleTextStyle == _this.titleTextStyle &&
        _other.subtitleTextStyle == _this.subtitleTextStyle &&
        _other.leadingStyle == _this.leadingStyle &&
        _other.trailingStyle == _this.trailingStyle;
  }

  @override
  int get hashCode {
    final _this = (this as StreamBottomAppBarStyle);

    return Object.hash(
      runtimeType,
      _this.behavior,
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
