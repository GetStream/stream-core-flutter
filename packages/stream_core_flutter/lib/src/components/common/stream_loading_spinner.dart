import 'package:flutter/material.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/stream_theme_extensions.dart';

/// Predefined sizes for [StreamLoadingSpinner].
///
/// Each size defines three dimensions:
/// - [value] — the outer container diameter (includes circular background).
/// - [visualValue] — the indicator diameter (the [CircularProgressIndicator]
///   constraints inside the container).
/// - [strokeWidth] — the arc/track stroke width.
enum StreamLoadingSpinnerSize {
  /// Large spinner (32px container, 24px indicator, 3px stroke).
  lg(32, 24, 3),

  /// Medium spinner (24px container, 18px indicator, 2.5px stroke).
  md(24, 18, 2.5),

  /// Small spinner (20px container, 18px indicator, 2px stroke).
  sm(20, 15, 2),

  /// Extra small spinner (16px container, 12px indicator, 2px stroke).
  xs(16, 12, 2)
  ;

  const StreamLoadingSpinnerSize(
    this.value,
    this.visualValue,
    this.strokeWidth,
  );

  /// The outer container diameter in logical pixels.
  final double value;

  /// The indicator diameter in logical pixels.
  final double visualValue;

  /// The default stroke width for this size.
  final double strokeWidth;
}

/// A circular progress indicator styled for the Stream design system.
///
/// [StreamLoadingSpinner] displays a circular arc that fills to indicate
/// progress. It supports both determinate (fixed value) and indeterminate
/// (loading animation) states. When [value] reaches `1.0`, the spinner
/// transitions to a checkmark indicating completion.
///
/// {@tool snippet}
///
/// Basic determinate spinner:
///
/// ```dart
/// StreamLoadingSpinner(value: 0.5)
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Indeterminate spinner (loading state):
///
/// ```dart
/// StreamLoadingSpinner()
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Customized spinner:
///
/// ```dart
/// StreamLoadingSpinner(
///   value: 0.75,
///   size: StreamLoadingSpinnerSize.lg,
///   color: Colors.green,
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamLoadingSpinnerSize], the available size variants.
class StreamLoadingSpinner extends StatelessWidget {
  /// Creates a Stream loading spinner.
  ///
  /// If [value] is non-null, it must be between 0.0 and 1.0.
  /// If [value] is null, the spinner shows an indeterminate animation.
  StreamLoadingSpinner({
    super.key,
    double? value,
    StreamLoadingSpinnerSize? size,
    Color? color,
    Color? trackColor,
    Color? backgroundColor,
  }) : props = .new(
         value: value,
         size: size,
         color: color,
         trackColor: trackColor,
         backgroundColor: backgroundColor,
       );

  /// The props controlling the appearance and behavior of this spinner.
  final StreamLoadingSpinnerProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).loadingSpinner;
    if (builder != null) return builder(context, props);
    return DefaultStreamLoadingSpinner(props: props);
  }
}

/// Properties for configuring a [StreamLoadingSpinner].
///
/// This class holds all the configuration options for a loading spinner,
/// allowing them to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamLoadingSpinner], which uses these properties.
///  * [DefaultStreamLoadingSpinner], the default implementation.
class StreamLoadingSpinnerProps {
  /// Creates properties for a loading spinner.
  const StreamLoadingSpinnerProps({
    this.value,
    this.size,
    this.color,
    this.trackColor,
    this.backgroundColor,
  });

  /// The progress value from 0.0 to 1.0.
  ///
  /// If null, the spinner is indeterminate, displaying a looping
  /// animation rather than a fixed fill. When the value reaches `1.0`,
  /// the spinner transitions to a checkmark indicating completion.
  final double? value;

  /// The size of the spinner.
  ///
  /// If null, defaults to [StreamLoadingSpinnerSize.sm].
  final StreamLoadingSpinnerSize? size;

  /// The color of the filled arc.
  ///
  /// If null, falls back to the design system default.
  final Color? color;

  /// The color of the unfilled track.
  ///
  /// If null, falls back to the design system default.
  final Color? trackColor;

  /// The fill color of the circular background behind the spinner.
  ///
  /// If null, falls back to the design system default.
  final Color? backgroundColor;
}

/// Default implementation of [StreamLoadingSpinner].
///
/// Renders a spinner using [CircularProgressIndicator], transitioning to a
/// checkmark when the progress reaches `1.0`. Styling is resolved from widget
/// props and built-in defaults in that order.
///
/// See also:
///
///  * [StreamLoadingSpinner], the public API widget.
class DefaultStreamLoadingSpinner extends StatelessWidget {
  /// Creates a default Stream loading spinner.
  const DefaultStreamLoadingSpinner({super.key, required this.props});

  /// The props controlling the appearance and behavior of this spinner.
  final StreamLoadingSpinnerProps props;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;

    final resolvedSize = props.size ?? .sm;
    final effectiveColor = props.color ?? colorScheme.accentPrimary;
    final effectiveTrackColor = props.trackColor ?? colorScheme.borderDefault;
    final effectiveBackgroundColor = props.backgroundColor ?? colorScheme.backgroundElevation0;

    final effectiveValue = props.value?.clamp(0.0, 1.0);
    final indicator = switch (effectiveValue) {
      1.0 => Container(
        key: const ValueKey('completed'),
        decoration: BoxDecoration(shape: .circle, color: effectiveColor),
        constraints: .tight(.square(resolvedSize.visualValue + resolvedSize.strokeWidth)),
        child: Center(child: Icon(context.streamIcons.checkmark)),
      ),
      _ => CircularProgressIndicator(
        key: const ValueKey('progress'),
        trackGap: 0,
        padding: EdgeInsets.zero,
        color: effectiveColor,
        strokeCap: StrokeCap.round,
        value: effectiveValue,
        strokeWidth: resolvedSize.strokeWidth,
        strokeAlign: BorderSide.strokeAlignCenter,
        backgroundColor: effectiveTrackColor,
        constraints: .tight(.square(resolvedSize.visualValue)),
      ),
    };

    return SizedBox.square(
      dimension: resolvedSize.value,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: effectiveBackgroundColor,
        ),
        child: Center(
          child: IconTheme(
            data: IconThemeData(
              size: _iconSizeForSize(resolvedSize),
              color: colorScheme.textOnAccent,
            ),
            child: AnimatedSwitcher(
              duration: kThemeChangeDuration,
              child: indicator,
            ),
          ),
        ),
      ),
    );
  }

  // Returns the appropriate icon size for the given spinner size.
  double _iconSizeForSize(
    StreamLoadingSpinnerSize size,
  ) => switch (size) {
    .xs => 8,
    .sm => 10,
    .md => 12,
    .lg => 16,
  };
}
