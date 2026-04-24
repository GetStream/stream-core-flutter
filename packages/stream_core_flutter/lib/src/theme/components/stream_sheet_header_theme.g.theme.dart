// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_sheet_header_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamSheetHeaderThemeData {
  bool get canMerge => true;

  static StreamSheetHeaderThemeData? lerp(
    StreamSheetHeaderThemeData? a,
    StreamSheetHeaderThemeData? b,
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

    return StreamSheetHeaderThemeData(
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

  StreamSheetHeaderThemeData copyWith({
    EdgeInsetsGeometry? padding,
    double? spacing,
    TextStyle? titleTextStyle,
    TextStyle? subtitleTextStyle,
    StreamButtonThemeStyle? leadingStyle,
    StreamButtonThemeStyle? trailingStyle,
  }) {
    final _this = (this as StreamSheetHeaderThemeData);

    return StreamSheetHeaderThemeData(
      padding: padding ?? _this.padding,
      spacing: spacing ?? _this.spacing,
      titleTextStyle: titleTextStyle ?? _this.titleTextStyle,
      subtitleTextStyle: subtitleTextStyle ?? _this.subtitleTextStyle,
      leadingStyle: leadingStyle ?? _this.leadingStyle,
      trailingStyle: trailingStyle ?? _this.trailingStyle,
    );
  }

  StreamSheetHeaderThemeData merge(StreamSheetHeaderThemeData? other) {
    final _this = (this as StreamSheetHeaderThemeData);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
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

    final _this = (this as StreamSheetHeaderThemeData);
    final _other = (other as StreamSheetHeaderThemeData);

    return _other.padding == _this.padding &&
        _other.spacing == _this.spacing &&
        _other.titleTextStyle == _this.titleTextStyle &&
        _other.subtitleTextStyle == _this.subtitleTextStyle &&
        _other.leadingStyle == _this.leadingStyle &&
        _other.trailingStyle == _this.trailingStyle;
  }

  @override
  int get hashCode {
    final _this = (this as StreamSheetHeaderThemeData);

    return Object.hash(
      runtimeType,
      _this.padding,
      _this.spacing,
      _this.titleTextStyle,
      _this.subtitleTextStyle,
      _this.leadingStyle,
      _this.trailingStyle,
    );
  }
}
