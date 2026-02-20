import 'package:flutter/material.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_progress_bar_theme.dart';
import '../../theme/primitives/stream_radius.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/stream_theme_extensions.dart';

/// A linear progress indicator styled for the Stream design system.
///
/// [StreamProgressBar] displays a horizontal bar that fills to indicate
/// progress. It supports both determinate (fixed value) and indeterminate
/// (loading animation) states.
///
/// Visual properties can be customized per-instance via constructor parameters,
/// or globally via [StreamProgressBarThemeData].
///
/// {@tool snippet}
///
/// Basic determinate progress bar:
///
/// ```dart
/// StreamProgressBar(value: 0.5)
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Indeterminate progress bar (loading state):
///
/// ```dart
/// StreamProgressBar()
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Customized progress bar:
///
/// ```dart
/// StreamProgressBar(
///   value: 0.75,
///   trackColor: Colors.grey.shade200,
///   fillColor: Colors.green,
///   minHeight: 12,
/// )
/// ```
/// {@end-tool}
///
/// ## Theming
///
/// [StreamProgressBar] uses [StreamProgressBarThemeData] for default styling.
///
/// See also:
///
///  * [StreamProgressBarThemeData], for customizing progress bar appearance.
///  * [StreamProgressBarTheme], for overriding theme in a widget subtree.
class StreamProgressBar extends StatelessWidget {
  /// Creates a Stream progress bar.
  ///
  /// If [value] is non-null, it must be between 0.0 and 1.0.
  /// If [value] is null, the progress bar shows an indeterminate animation.
  StreamProgressBar({
    super.key,
    double? value,
    Color? trackColor,
    Color? fillColor,
    double? minHeight,
    BorderRadiusGeometry? borderRadius,
  }) : props = .new(
         value: value,
         trackColor: trackColor,
         fillColor: fillColor,
         minHeight: minHeight,
         borderRadius: borderRadius,
       );

  /// The props controlling the appearance and behavior of this progress bar.
  final StreamProgressBarProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.maybeOf(context)?.progressBar;
    if (builder != null) return builder(context, props);
    return DefaultStreamProgressBar(props: props);
  }
}

/// Properties for configuring a [StreamProgressBar].
///
/// This class holds all the configuration options for a progress bar,
/// allowing them to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamProgressBar], which uses these properties.
///  * [DefaultStreamProgressBar], the default implementation.
class StreamProgressBarProps {
  /// Creates properties for a progress bar.
  const StreamProgressBarProps({
    this.value,
    this.trackColor,
    this.fillColor,
    this.minHeight,
    this.borderRadius,
  });

  /// The progress value from 0.0 to 1.0.
  ///
  /// If null, the progress bar is indeterminate, displaying a looping
  /// animation rather than a fixed fill.
  final double? value;

  /// The color of the unfilled track.
  ///
  /// If null, uses [StreamProgressBarThemeData.trackColor], or falls back
  /// to the design system default.
  final Color? trackColor;

  /// The color of the filled portion.
  ///
  /// If null, uses [StreamProgressBarThemeData.fillColor], or falls back
  /// to the design system default.
  final Color? fillColor;

  /// The minimum height of the progress bar.
  ///
  /// If null, uses [StreamProgressBarThemeData.minHeight], or falls back
  /// to 8.
  final double? minHeight;

  /// The border radius of the progress bar.
  ///
  /// If null, uses [StreamProgressBarThemeData.borderRadius], or falls back
  /// to the design system's max radius.
  final BorderRadiusGeometry? borderRadius;
}

/// Default implementation of [StreamProgressBar].
///
/// Renders a progress bar using [LinearProgressIndicator]. Styling is resolved
/// from widget props, theme, and built-in defaults in that order.
///
/// See also:
///
///  * [StreamProgressBar], the public API widget.
class DefaultStreamProgressBar extends StatelessWidget {
  /// Creates a default Stream progress bar.
  const DefaultStreamProgressBar({super.key, required this.props});

  /// The props controlling the appearance and behavior of this progress bar.
  final StreamProgressBarProps props;

  @override
  Widget build(BuildContext context) {
    final theme = context.streamProgressBarTheme;
    final defaults = _StreamProgressBarStyleDefaults(context);

    final effectiveTrackColor = props.trackColor ?? theme.trackColor ?? defaults.trackColor;
    final effectiveFillColor = props.fillColor ?? theme.fillColor ?? defaults.fillColor;
    final effectiveMinHeight = props.minHeight ?? theme.minHeight ?? defaults.minHeight;
    final effectiveBorderRadius = props.borderRadius ?? theme.borderRadius ?? defaults.borderRadius;

    return LinearProgressIndicator(
      trackGap: 0,
      stopIndicatorRadius: 0,
      value: props.value?.clamp(0.0, 1.0),
      backgroundColor: effectiveTrackColor,
      color: effectiveFillColor,
      minHeight: effectiveMinHeight,
      borderRadius: effectiveBorderRadius,
    );
  }
}

// Provides default values for [StreamProgressBarThemeData] based on the
// current [StreamColorScheme].
class _StreamProgressBarStyleDefaults extends StreamProgressBarThemeData {
  _StreamProgressBarStyleDefaults(this.context);

  final BuildContext context;

  late final StreamRadius _radius = context.streamRadius;
  late final StreamColorScheme _colorScheme = context.streamColorScheme;

  @override
  double? get minHeight => 8;

  @override
  Color get fillColor => _colorScheme.accentNeutral;

  @override
  Color get trackColor => _colorScheme.backgroundSurfaceStrong;

  @override
  BorderRadiusGeometry get borderRadius => .all(_radius.max);
}
