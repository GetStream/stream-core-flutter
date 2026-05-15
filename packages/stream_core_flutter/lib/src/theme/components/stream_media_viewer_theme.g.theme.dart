// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_media_viewer_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamMediaViewerThemeData {
  bool get canMerge => true;

  static StreamMediaViewerThemeData? lerp(
    StreamMediaViewerThemeData? a,
    StreamMediaViewerThemeData? b,
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

    return StreamMediaViewerThemeData(
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      immersiveBackgroundColor: Color.lerp(
        a.immersiveBackgroundColor,
        b.immersiveBackgroundColor,
        t,
      ),
      chromeAnimationDuration: lerpDuration$(
        a.chromeAnimationDuration,
        b.chromeAnimationDuration,
        t,
      ),
      appBarStyle: StreamAppBarStyle.lerp(a.appBarStyle, b.appBarStyle, t),
      bottomAppBarStyle: StreamBottomAppBarStyle.lerp(
        a.bottomAppBarStyle,
        b.bottomAppBarStyle,
        t,
      ),
    );
  }

  StreamMediaViewerThemeData copyWith({
    Color? backgroundColor,
    Color? immersiveBackgroundColor,
    Duration? chromeAnimationDuration,
    StreamAppBarStyle? appBarStyle,
    StreamBottomAppBarStyle? bottomAppBarStyle,
  }) {
    final _this = (this as StreamMediaViewerThemeData);

    return StreamMediaViewerThemeData(
      backgroundColor: backgroundColor ?? _this.backgroundColor,
      immersiveBackgroundColor:
          immersiveBackgroundColor ?? _this.immersiveBackgroundColor,
      chromeAnimationDuration:
          chromeAnimationDuration ?? _this.chromeAnimationDuration,
      appBarStyle: appBarStyle ?? _this.appBarStyle,
      bottomAppBarStyle: bottomAppBarStyle ?? _this.bottomAppBarStyle,
    );
  }

  StreamMediaViewerThemeData merge(StreamMediaViewerThemeData? other) {
    final _this = (this as StreamMediaViewerThemeData);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      backgroundColor: other.backgroundColor,
      immersiveBackgroundColor: other.immersiveBackgroundColor,
      chromeAnimationDuration: other.chromeAnimationDuration,
      appBarStyle:
          _this.appBarStyle?.merge(other.appBarStyle) ?? other.appBarStyle,
      bottomAppBarStyle:
          _this.bottomAppBarStyle?.merge(other.bottomAppBarStyle) ??
          other.bottomAppBarStyle,
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

    final _this = (this as StreamMediaViewerThemeData);
    final _other = (other as StreamMediaViewerThemeData);

    return _other.backgroundColor == _this.backgroundColor &&
        _other.immersiveBackgroundColor == _this.immersiveBackgroundColor &&
        _other.chromeAnimationDuration == _this.chromeAnimationDuration &&
        _other.appBarStyle == _this.appBarStyle &&
        _other.bottomAppBarStyle == _this.bottomAppBarStyle;
  }

  @override
  int get hashCode {
    final _this = (this as StreamMediaViewerThemeData);

    return Object.hash(
      runtimeType,
      _this.backgroundColor,
      _this.immersiveBackgroundColor,
      _this.chromeAnimationDuration,
      _this.appBarStyle,
      _this.bottomAppBarStyle,
    );
  }
}
