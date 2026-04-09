import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';

part 'stream_progress_bar_theme.g.theme.dart';

/// Applies a progress bar theme to descendant [StreamProgressBar] widgets.
///
/// Wrap a subtree with [StreamProgressBarTheme] to override progress bar
/// styling. Access the merged theme using
/// [BuildContext.streamProgressBarTheme].
///
/// {@tool snippet}
///
/// Override progress bar colors for a specific section:
///
/// ```dart
/// StreamProgressBarTheme(
///   data: StreamProgressBarThemeData(
///     style: StreamProgressBarStyle(
///       trackColor: Colors.grey.shade200,
///       fillColor: Colors.green,
///     ),
///   ),
///   child: Column(
///     children: [
///       StreamProgressBar(value: 0.3),
///       StreamProgressBar(value: 0.7),
///     ],
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamProgressBarThemeData], which describes the progress bar theme.
///  * [StreamProgressBar], the widget affected by this theme.
class StreamProgressBarTheme extends InheritedTheme {
  /// Creates a progress bar theme that controls descendant progress bars.
  const StreamProgressBarTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The progress bar theme data for descendant widgets.
  final StreamProgressBarThemeData data;

  /// Returns the [StreamProgressBarThemeData] merged from local and global
  /// themes.
  ///
  /// Local values from the nearest [StreamProgressBarTheme] ancestor take
  /// precedence over global values from [StreamTheme.of].
  ///
  /// This allows partial overrides - for example, overriding only
  /// [StreamProgressBarStyle.fillColor] while inheriting other properties
  /// from the global theme.
  static StreamProgressBarThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamProgressBarTheme>();
    return StreamTheme.of(context).progressBarTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamProgressBarTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamProgressBarTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing [StreamProgressBar] widgets.
///
/// {@tool snippet}
///
/// Customize progress bar appearance globally via [StreamTheme]:
///
/// ```dart
/// StreamTheme(
///   data: StreamThemeData(
///     progressBarTheme: StreamProgressBarThemeData(
///       style: StreamProgressBarStyle(
///         trackColor: Colors.grey.shade200,
///         fillColor: Colors.blue,
///         minHeight: 6,
///       ),
///     ),
///   ),
///   child: MyApp(),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamProgressBar], the widget that uses this theme data.
///  * [StreamProgressBarTheme], for overriding theme in a widget subtree.
@themeGen
@immutable
class StreamProgressBarThemeData with _$StreamProgressBarThemeData {
  /// Creates progress bar theme data with optional style overrides.
  const StreamProgressBarThemeData({this.style});

  /// The visual styling for progress bars.
  ///
  /// Contains track color, fill color, height, and border radius.
  final StreamProgressBarStyle? style;

  /// Linearly interpolate between two [StreamProgressBarThemeData] objects.
  static StreamProgressBarThemeData? lerp(
    StreamProgressBarThemeData? a,
    StreamProgressBarThemeData? b,
    double t,
  ) => _$StreamProgressBarThemeData.lerp(a, b, t);
}

/// Visual styling properties for progress bars.
///
/// Defines the appearance of progress bars including track color, fill color,
/// height, and border radius.
///
/// See also:
///
///  * [StreamProgressBarThemeData], which wraps this style for theming.
///  * [StreamProgressBar], which uses this styling.
@themeGen
@immutable
class StreamProgressBarStyle with _$StreamProgressBarStyle {
  /// Creates progress bar style properties.
  const StreamProgressBarStyle({
    this.trackColor,
    this.fillColor,
    this.minHeight,
    this.borderRadius,
  });

  /// The background track color of the progress bar.
  ///
  /// The track is the unfilled portion behind the indicator.
  final Color? trackColor;

  /// The filled portion color of the progress bar.
  ///
  /// This color fills from the leading edge to indicate progress.
  final Color? fillColor;

  /// The minimum height of the progress bar.
  ///
  /// Falls back to 8 logical pixels.
  final double? minHeight;

  /// The border radius applied to both track and fill.
  ///
  /// Falls back to the design system's max radius.
  final BorderRadiusGeometry? borderRadius;

  /// Linearly interpolate between two [StreamProgressBarStyle] objects.
  static StreamProgressBarStyle? lerp(
    StreamProgressBarStyle? a,
    StreamProgressBarStyle? b,
    double t,
  ) => _$StreamProgressBarStyle.lerp(a, b, t);
}
