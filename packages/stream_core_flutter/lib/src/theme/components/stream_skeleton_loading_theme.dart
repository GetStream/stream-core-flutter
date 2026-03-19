import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';

part 'stream_skeleton_loading_theme.g.theme.dart';

/// Applies a skeleton loading theme to descendant [StreamSkeletonLoading]
/// widgets.
///
/// Wrap a subtree with [StreamSkeletonLoadingTheme] to override skeleton
/// shimmer styling. Access the merged theme using
/// [BuildContext.streamSkeletonLoadingTheme].
///
/// {@tool snippet}
///
/// Override skeleton colors for a specific section:
///
/// ```dart
/// StreamSkeletonLoadingTheme(
///   data: StreamSkeletonLoadingThemeData(
///     baseColor: Colors.grey.shade300,
///     highlightColor: Colors.grey.shade100,
///   ),
///   child: Column(
///     children: [
///       StreamSkeletonLoading(child: Container(height: 20)),
///       StreamSkeletonLoading(child: Container(height: 40)),
///     ],
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamSkeletonLoadingThemeData], which describes the skeleton theme.
///  * [StreamSkeletonLoading], the widget affected by this theme.
class StreamSkeletonLoadingTheme extends InheritedTheme {
  /// Creates a skeleton loading theme that controls descendant skeleton
  /// widgets.
  const StreamSkeletonLoadingTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The skeleton loading theme data for descendant widgets.
  final StreamSkeletonLoadingThemeData data;

  /// Returns the [StreamSkeletonLoadingThemeData] merged from local and
  /// global themes.
  ///
  /// Local values from the nearest [StreamSkeletonLoadingTheme] ancestor take
  /// precedence over global values from [StreamTheme.of].
  static StreamSkeletonLoadingThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamSkeletonLoadingTheme>();
    return StreamTheme.of(context).skeletonLoadingTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamSkeletonLoadingTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamSkeletonLoadingTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing [StreamSkeletonLoading] widgets.
///
/// {@tool snippet}
///
/// Customize skeleton loading appearance globally:
///
/// ```dart
/// StreamTheme(
///   skeletonLoadingTheme: StreamSkeletonLoadingThemeData(
///     baseColor: Colors.grey.shade300,
///     highlightColor: Colors.grey.shade100,
///     period: Duration(milliseconds: 1200),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamSkeletonLoading], the widget that uses this theme data.
///  * [StreamSkeletonLoadingTheme], for overriding theme in a widget subtree.
@themeGen
@immutable
class StreamSkeletonLoadingThemeData with _$StreamSkeletonLoadingThemeData {
  /// Creates skeleton loading theme data with optional style overrides.
  const StreamSkeletonLoadingThemeData({
    this.baseColor,
    this.highlightColor,
    this.period,
  });

  /// The base color of the shimmer effect.
  ///
  /// Falls back to [StreamColorScheme.backgroundSurfaceStrong].
  final Color? baseColor;

  /// The highlight color of the shimmer effect.
  final Color? highlightColor;

  /// The duration of one shimmer animation cycle.
  ///
  /// Falls back to 1500 milliseconds.
  final Duration? period;

  /// Linearly interpolate between two [StreamSkeletonLoadingThemeData] objects.
  static StreamSkeletonLoadingThemeData? lerp(
    StreamSkeletonLoadingThemeData? a,
    StreamSkeletonLoadingThemeData? b,
    double t,
  ) => _$StreamSkeletonLoadingThemeData.lerp(a, b, t);
}
