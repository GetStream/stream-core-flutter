// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_playback_speed_toggle_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamPlaybackSpeedToggleThemeData {
  bool get canMerge => true;

  static StreamPlaybackSpeedToggleThemeData? lerp(
    StreamPlaybackSpeedToggleThemeData? a,
    StreamPlaybackSpeedToggleThemeData? b,
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

    return StreamPlaybackSpeedToggleThemeData(
      style: StreamPlaybackSpeedToggleStyle.lerp(a.style, b.style, t),
    );
  }

  StreamPlaybackSpeedToggleThemeData copyWith({
    StreamPlaybackSpeedToggleStyle? style,
  }) {
    final _this = (this as StreamPlaybackSpeedToggleThemeData);

    return StreamPlaybackSpeedToggleThemeData(style: style ?? _this.style);
  }

  StreamPlaybackSpeedToggleThemeData merge(
    StreamPlaybackSpeedToggleThemeData? other,
  ) {
    final _this = (this as StreamPlaybackSpeedToggleThemeData);

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

    final _this = (this as StreamPlaybackSpeedToggleThemeData);
    final _other = (other as StreamPlaybackSpeedToggleThemeData);

    return _other.style == _this.style;
  }

  @override
  int get hashCode {
    final _this = (this as StreamPlaybackSpeedToggleThemeData);

    return Object.hash(runtimeType, _this.style);
  }
}

mixin _$StreamPlaybackSpeedToggleStyle {
  bool get canMerge => true;

  static StreamPlaybackSpeedToggleStyle? lerp(
    StreamPlaybackSpeedToggleStyle? a,
    StreamPlaybackSpeedToggleStyle? b,
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

    return StreamPlaybackSpeedToggleStyle(
      backgroundColor: WidgetStateProperty.lerp<Color?>(
        a.backgroundColor,
        b.backgroundColor,
        t,
        Color.lerp,
      ),
      foregroundColor: WidgetStateProperty.lerp<Color?>(
        a.foregroundColor,
        b.foregroundColor,
        t,
        Color.lerp,
      ),
      borderColor: WidgetStateProperty.lerp<Color?>(
        a.borderColor,
        b.borderColor,
        t,
        Color.lerp,
      ),
      overlayColor: WidgetStateProperty.lerp<Color?>(
        a.overlayColor,
        b.overlayColor,
        t,
        Color.lerp,
      ),
      elevation: WidgetStateProperty.lerp<double?>(
        a.elevation,
        b.elevation,
        t,
        lerpDouble$,
      ),
      textStyle: WidgetStateProperty.lerp<TextStyle?>(
        a.textStyle,
        b.textStyle,
        t,
        TextStyle.lerp,
      ),
      shape: OutlinedBorder.lerp(a.shape, b.shape, t),
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      minimumSize: Size.lerp(a.minimumSize, b.minimumSize, t),
      maximumSize: Size.lerp(a.maximumSize, b.maximumSize, t),
      tapTargetSize: t < 0.5 ? a.tapTargetSize : b.tapTargetSize,
    );
  }

  StreamPlaybackSpeedToggleStyle copyWith({
    WidgetStateProperty<Color?>? backgroundColor,
    WidgetStateProperty<Color?>? foregroundColor,
    WidgetStateProperty<Color?>? borderColor,
    WidgetStateProperty<Color?>? overlayColor,
    WidgetStateProperty<double?>? elevation,
    WidgetStateProperty<TextStyle?>? textStyle,
    OutlinedBorder? shape,
    EdgeInsetsGeometry? padding,
    Size? minimumSize,
    Size? maximumSize,
    MaterialTapTargetSize? tapTargetSize,
  }) {
    final _this = (this as StreamPlaybackSpeedToggleStyle);

    return StreamPlaybackSpeedToggleStyle(
      backgroundColor: backgroundColor ?? _this.backgroundColor,
      foregroundColor: foregroundColor ?? _this.foregroundColor,
      borderColor: borderColor ?? _this.borderColor,
      overlayColor: overlayColor ?? _this.overlayColor,
      elevation: elevation ?? _this.elevation,
      textStyle: textStyle ?? _this.textStyle,
      shape: shape ?? _this.shape,
      padding: padding ?? _this.padding,
      minimumSize: minimumSize ?? _this.minimumSize,
      maximumSize: maximumSize ?? _this.maximumSize,
      tapTargetSize: tapTargetSize ?? _this.tapTargetSize,
    );
  }

  StreamPlaybackSpeedToggleStyle merge(StreamPlaybackSpeedToggleStyle? other) {
    final _this = (this as StreamPlaybackSpeedToggleStyle);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      backgroundColor: other.backgroundColor,
      foregroundColor: other.foregroundColor,
      borderColor: other.borderColor,
      overlayColor: other.overlayColor,
      elevation: other.elevation,
      textStyle: other.textStyle,
      shape: other.shape,
      padding: other.padding,
      minimumSize: other.minimumSize,
      maximumSize: other.maximumSize,
      tapTargetSize: other.tapTargetSize,
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

    final _this = (this as StreamPlaybackSpeedToggleStyle);
    final _other = (other as StreamPlaybackSpeedToggleStyle);

    return _other.backgroundColor == _this.backgroundColor &&
        _other.foregroundColor == _this.foregroundColor &&
        _other.borderColor == _this.borderColor &&
        _other.overlayColor == _this.overlayColor &&
        _other.elevation == _this.elevation &&
        _other.textStyle == _this.textStyle &&
        _other.shape == _this.shape &&
        _other.padding == _this.padding &&
        _other.minimumSize == _this.minimumSize &&
        _other.maximumSize == _this.maximumSize &&
        _other.tapTargetSize == _this.tapTargetSize;
  }

  @override
  int get hashCode {
    final _this = (this as StreamPlaybackSpeedToggleStyle);

    return Object.hash(
      runtimeType,
      _this.backgroundColor,
      _this.foregroundColor,
      _this.borderColor,
      _this.overlayColor,
      _this.elevation,
      _this.textStyle,
      _this.shape,
      _this.padding,
      _this.minimumSize,
      _this.maximumSize,
      _this.tapTargetSize,
    );
  }
}
