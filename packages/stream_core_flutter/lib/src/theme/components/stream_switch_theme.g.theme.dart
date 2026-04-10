// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_switch_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamSwitchThemeData {
  bool get canMerge => true;

  static StreamSwitchThemeData? lerp(
    StreamSwitchThemeData? a,
    StreamSwitchThemeData? b,
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

    return StreamSwitchThemeData(
      style: StreamSwitchStyle.lerp(a.style, b.style, t),
    );
  }

  StreamSwitchThemeData copyWith({StreamSwitchStyle? style}) {
    final _this = (this as StreamSwitchThemeData);

    return StreamSwitchThemeData(style: style ?? _this.style);
  }

  StreamSwitchThemeData merge(StreamSwitchThemeData? other) {
    final _this = (this as StreamSwitchThemeData);

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

    final _this = (this as StreamSwitchThemeData);
    final _other = (other as StreamSwitchThemeData);

    return _other.style == _this.style;
  }

  @override
  int get hashCode {
    final _this = (this as StreamSwitchThemeData);

    return Object.hash(runtimeType, _this.style);
  }
}

mixin _$StreamSwitchStyle {
  bool get canMerge => true;

  static StreamSwitchStyle? lerp(
    StreamSwitchStyle? a,
    StreamSwitchStyle? b,
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

    return StreamSwitchStyle(
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

  StreamSwitchStyle copyWith({
    WidgetStateProperty<Color?>? trackColor,
    WidgetStateProperty<Color?>? thumbColor,
    WidgetStateProperty<Color?>? trackOutlineColor,
    WidgetStateProperty<double?>? trackOutlineWidth,
    WidgetStateProperty<Color?>? overlayColor,
  }) {
    final _this = (this as StreamSwitchStyle);

    return StreamSwitchStyle(
      trackColor: trackColor ?? _this.trackColor,
      thumbColor: thumbColor ?? _this.thumbColor,
      trackOutlineColor: trackOutlineColor ?? _this.trackOutlineColor,
      trackOutlineWidth: trackOutlineWidth ?? _this.trackOutlineWidth,
      overlayColor: overlayColor ?? _this.overlayColor,
    );
  }

  StreamSwitchStyle merge(StreamSwitchStyle? other) {
    final _this = (this as StreamSwitchStyle);

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

    final _this = (this as StreamSwitchStyle);
    final _other = (other as StreamSwitchStyle);

    return _other.trackColor == _this.trackColor &&
        _other.thumbColor == _this.thumbColor &&
        _other.trackOutlineColor == _this.trackOutlineColor &&
        _other.trackOutlineWidth == _this.trackOutlineWidth &&
        _other.overlayColor == _this.overlayColor;
  }

  @override
  int get hashCode {
    final _this = (this as StreamSwitchStyle);

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
