import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';

part 'stream_audio_waveform_theme.g.theme.dart';

/// Applies an audio waveform theme to descendant [StreamAudioWaveform] and
/// [StreamAudioWaveformSlider] widgets.
///
/// Wrap a subtree with [StreamAudioWaveformTheme] to override waveform
/// styling. Access the merged theme using
/// [BuildContext.streamAudioWaveformTheme].
///
/// {@tool snippet}
///
/// Override waveform colors for a specific section:
///
/// ```dart
/// StreamAudioWaveformTheme(
///   data: StreamAudioWaveformThemeData(
///     color: Colors.grey,
///     progressColor: Colors.blue,
///     activeThumbColor: Colors.blue,
///     idleThumbColor: Colors.grey,
///   ),
///   child: StreamAudioWaveformSlider(
///     waveform: waveformData,
///     onChanged: (value) {},
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamAudioWaveformThemeData], which describes the waveform theme.
///  * [StreamAudioWaveform], the waveform widget affected by this theme.
///  * [StreamAudioWaveformSlider], the slider widget affected by this theme.
class StreamAudioWaveformTheme extends InheritedTheme {
  /// Creates an audio waveform theme that controls descendant waveforms.
  const StreamAudioWaveformTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The audio waveform theme data for descendant widgets.
  final StreamAudioWaveformThemeData data;

  /// Returns the [StreamAudioWaveformThemeData] merged from local and global
  /// themes.
  ///
  /// Local values from the nearest [StreamAudioWaveformTheme] ancestor take
  /// precedence over global values from [StreamTheme.of].
  ///
  /// This allows partial overrides - for example, overriding only
  /// [StreamAudioWaveformThemeData.color] while inheriting other properties
  /// from the global theme.
  static StreamAudioWaveformThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamAudioWaveformTheme>();
    return StreamTheme.of(context).audioWaveformTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamAudioWaveformTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamAudioWaveformTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing [StreamAudioWaveform] and
/// [StreamAudioWaveformSlider] widgets.
///
/// {@tool snippet}
///
/// Customize waveform appearance globally:
///
/// ```dart
/// StreamTheme(
///   audioWaveformTheme: StreamAudioWaveformThemeData(
///     color: Colors.grey,
///     progressColor: Colors.blue,
///     minBarHeight: 2,
///     spacingRatio: 0.3,
///     heightScale: 1,
///     activeThumbColor: Colors.blue,
///     idleThumbColor: Colors.grey,
///     thumbBorderColor: Colors.grey,
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamAudioWaveform], the widget that uses this theme data.
///  * [StreamAudioWaveformSlider], the slider widget that uses this theme data.
///  * [StreamAudioWaveformTheme], for overriding theme in a widget subtree.
@themeGen
@immutable
class StreamAudioWaveformThemeData with _$StreamAudioWaveformThemeData {
  /// Creates audio waveform theme data with optional style overrides.
  const StreamAudioWaveformThemeData({
    this.color,
    this.progressColor,
    this.minBarHeight,
    this.spacingRatio,
    this.heightScale,
    this.activeThumbColor,
    this.idleThumbColor,
    this.thumbBorderColor,
  });

  /// The color of the waveform bars.
  ///
  /// Falls back to [StreamColorScheme.borderOpacity25].
  final Color? color;

  /// The color of the progressed waveform bars.
  ///
  /// Falls back to [StreamColorScheme.accentPrimary].
  final Color? progressColor;

  /// The minimum height of the waveform bars.
  ///
  /// Falls back to 2 logical pixels.
  final double? minBarHeight;

  /// The ratio of the spacing between the waveform bars.
  ///
  /// Falls back to 0.3.
  final double? spacingRatio;

  /// The scale of the height of the waveform bars.
  ///
  /// Falls back to 1.
  final double? heightScale;

  /// The color of the slider thumb when the waveform is active (playing).
  ///
  /// Falls back to [StreamColorScheme.accentPrimary].
  final Color? activeThumbColor;

  /// The color of the slider thumb when the waveform is idle (not playing).
  ///
  /// Falls back to [StreamColorScheme.accentNeutral].
  final Color? idleThumbColor;

  /// The border color of the slider thumb.
  ///
  /// Falls back to [StreamColorScheme.borderOnAccent].
  final Color? thumbBorderColor;

  /// Linearly interpolate between two [StreamAudioWaveformThemeData] objects.
  static StreamAudioWaveformThemeData? lerp(
    StreamAudioWaveformThemeData? a,
    StreamAudioWaveformThemeData? b,
    double t,
  ) => _$StreamAudioWaveformThemeData.lerp(a, b, t);
}
