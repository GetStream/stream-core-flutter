// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_toggle_switch_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamToggleSwitchThemeData {
  bool get canMerge => true;

  static StreamToggleSwitchThemeData? lerp(
    StreamToggleSwitchThemeData? a,
    StreamToggleSwitchThemeData? b,
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

    return StreamToggleSwitchThemeData(
      style: StreamToggleSwitchStyle.lerp(a.style, b.style, t),
    );
  }

  StreamToggleSwitchThemeData copyWith({StreamToggleSwitchStyle? style}) {
    final _this = (this as StreamToggleSwitchThemeData);

    return StreamToggleSwitchThemeData(style: style ?? _this.style);
  }

  StreamToggleSwitchThemeData merge(StreamToggleSwitchThemeData? other) {
    final _this = (this as StreamToggleSwitchThemeData);

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

    final _this = (this as StreamToggleSwitchThemeData);
    final _other = (other as StreamToggleSwitchThemeData);

    return _other.style == _this.style;
  }

  @override
  int get hashCode {
    final _this = (this as StreamToggleSwitchThemeData);

    return Object.hash(runtimeType, _this.style);
  }
}

mixin _$StreamToggleSwitchStyle {
  bool get canMerge => true;

  static StreamToggleSwitchStyle? lerp(
    StreamToggleSwitchStyle? a,
    StreamToggleSwitchStyle? b,
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

    return StreamToggleSwitchStyle(
      trackColor: WidgetStateProperty.lerp<Color?>(
        a.trackColor,
        b.trackColor,
        t,
        Color.lerp,
      ),
      thumbColor: WidgetStateProperty.lerp<Color?>(
        a.thumbColor,
        b.thumbColor,
        t,
        Color.lerp,
      ),
      trackOutlineColor: WidgetStateProperty.lerp<Color?>(
        a.trackOutlineColor,
        b.trackOutlineColor,
        t,
        Color.lerp,
      ),
      trackOutlineWidth: WidgetStateProperty.lerp<double?>(
        a.trackOutlineWidth,
        b.trackOutlineWidth,
        t,
        lerpDouble$,
      ),
      overlayColor: WidgetStateProperty.lerp<Color?>(
        a.overlayColor,
        b.overlayColor,
        t,
        Color.lerp,
      ),
    );
  }

  StreamToggleSwitchStyle copyWith({
    WidgetStateProperty<Color?>? trackColor,
    WidgetStateProperty<Color?>? thumbColor,
    WidgetStateProperty<Color?>? trackOutlineColor,
    WidgetStateProperty<double?>? trackOutlineWidth,
    WidgetStateProperty<Color?>? overlayColor,
  }) {
    final _this = (this as StreamToggleSwitchStyle);

    return StreamToggleSwitchStyle(
      trackColor: trackColor ?? _this.trackColor,
      thumbColor: thumbColor ?? _this.thumbColor,
      trackOutlineColor: trackOutlineColor ?? _this.trackOutlineColor,
      trackOutlineWidth: trackOutlineWidth ?? _this.trackOutlineWidth,
      overlayColor: overlayColor ?? _this.overlayColor,
    );
  }

  StreamToggleSwitchStyle merge(StreamToggleSwitchStyle? other) {
    final _this = (this as StreamToggleSwitchStyle);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      trackColor: other.trackColor,
      thumbColor: other.thumbColor,
      trackOutlineColor: other.trackOutlineColor,
      trackOutlineWidth: other.trackOutlineWidth,
      overlayColor: other.overlayColor,
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

    final _this = (this as StreamToggleSwitchStyle);
    final _other = (other as StreamToggleSwitchStyle);

    return _other.trackColor == _this.trackColor &&
        _other.thumbColor == _this.thumbColor &&
        _other.trackOutlineColor == _this.trackOutlineColor &&
        _other.trackOutlineWidth == _this.trackOutlineWidth &&
        _other.overlayColor == _this.overlayColor;
  }

  @override
  int get hashCode {
    final _this = (this as StreamToggleSwitchStyle);

    return Object.hash(
      runtimeType,
      _this.trackColor,
      _this.thumbColor,
      _this.trackOutlineColor,
      _this.trackOutlineWidth,
      _this.overlayColor,
    );
  }
}
