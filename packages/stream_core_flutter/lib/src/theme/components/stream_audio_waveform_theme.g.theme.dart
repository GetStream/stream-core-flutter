// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'stream_audio_waveform_theme.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$StreamAudioWaveformThemeData {
  bool get canMerge => true;

  static StreamAudioWaveformThemeData? lerp(
    StreamAudioWaveformThemeData? a,
    StreamAudioWaveformThemeData? b,
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

    return StreamAudioWaveformThemeData(
      color: Color.lerp(a.color, b.color, t),
      progressColor: Color.lerp(a.progressColor, b.progressColor, t),
      minBarHeight: lerpDouble$(a.minBarHeight, b.minBarHeight, t),
      spacingRatio: lerpDouble$(a.spacingRatio, b.spacingRatio, t),
      heightScale: lerpDouble$(a.heightScale, b.heightScale, t),
      activeThumbColor: Color.lerp(a.activeThumbColor, b.activeThumbColor, t),
      idleThumbColor: Color.lerp(a.idleThumbColor, b.idleThumbColor, t),
      thumbBorderColor: Color.lerp(a.thumbBorderColor, b.thumbBorderColor, t),
    );
  }

  StreamAudioWaveformThemeData copyWith({
    Color? color,
    Color? progressColor,
    double? minBarHeight,
    double? spacingRatio,
    double? heightScale,
    Color? activeThumbColor,
    Color? idleThumbColor,
    Color? thumbBorderColor,
  }) {
    final _this = (this as StreamAudioWaveformThemeData);

    return StreamAudioWaveformThemeData(
      color: color ?? _this.color,
      progressColor: progressColor ?? _this.progressColor,
      minBarHeight: minBarHeight ?? _this.minBarHeight,
      spacingRatio: spacingRatio ?? _this.spacingRatio,
      heightScale: heightScale ?? _this.heightScale,
      activeThumbColor: activeThumbColor ?? _this.activeThumbColor,
      idleThumbColor: idleThumbColor ?? _this.idleThumbColor,
      thumbBorderColor: thumbBorderColor ?? _this.thumbBorderColor,
    );
  }

  StreamAudioWaveformThemeData merge(StreamAudioWaveformThemeData? other) {
    final _this = (this as StreamAudioWaveformThemeData);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      color: other.color,
      progressColor: other.progressColor,
      minBarHeight: other.minBarHeight,
      spacingRatio: other.spacingRatio,
      heightScale: other.heightScale,
      activeThumbColor: other.activeThumbColor,
      idleThumbColor: other.idleThumbColor,
      thumbBorderColor: other.thumbBorderColor,
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

    final _this = (this as StreamAudioWaveformThemeData);
    final _other = (other as StreamAudioWaveformThemeData);

    return _other.color == _this.color &&
        _other.progressColor == _this.progressColor &&
        _other.minBarHeight == _this.minBarHeight &&
        _other.spacingRatio == _this.spacingRatio &&
        _other.heightScale == _this.heightScale &&
        _other.activeThumbColor == _this.activeThumbColor &&
        _other.idleThumbColor == _this.idleThumbColor &&
        _other.thumbBorderColor == _this.thumbBorderColor;
  }

  @override
  int get hashCode {
    final _this = (this as StreamAudioWaveformThemeData);

    return Object.hash(
      runtimeType,
      _this.color,
      _this.progressColor,
      _this.minBarHeight,
      _this.spacingRatio,
      _this.heightScale,
      _this.activeThumbColor,
      _this.idleThumbColor,
      _this.thumbBorderColor,
    );
  }
}
