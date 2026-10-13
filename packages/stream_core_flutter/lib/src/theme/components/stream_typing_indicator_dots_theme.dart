import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';

part 'stream_typing_indicator_dots_theme.g.theme.dart';

/// Applies a theme to descendant [StreamTypingIndicatorDots] widgets.
///
/// Wrap a subtree with [StreamTypingIndicatorDotsTheme] to override typing
/// indicator dots styling. Access the merged theme using
/// [BuildContext.streamTypingIndicatorDotsTheme].
///
/// {@tool snippet}
///
/// Override the dot color for a specific section:
///
/// ```dart
/// StreamTypingIndicatorDotsTheme(
///   data: StreamTypingIndicatorDotsThemeData(
///     color: Colors.blue,
///   ),
///   child: StreamTypingIndicatorDots(),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamTypingIndicatorDotsThemeData], which describes the typing
///    indicator dots theme.
///  * [StreamTypingIndicatorDots], the widget affected by this theme.
class StreamTypingIndicatorDotsTheme extends InheritedTheme {
  /// Creates a theme that controls descendant typing indicator dots.
  const StreamTypingIndicatorDotsTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The typing indicator dots theme data for descendant widgets.
  final StreamTypingIndicatorDotsThemeData data;

  /// Returns the [StreamTypingIndicatorDotsThemeData] merged from local and
  /// global themes.
  ///
  /// Local values from the nearest [StreamTypingIndicatorDotsTheme] ancestor take
  /// precedence over global values from [StreamTheme.of].
  static StreamTypingIndicatorDotsThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamTypingIndicatorDotsTheme>();
    return StreamTheme.of(context).typingIndicatorDotsTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamTypingIndicatorDotsTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamTypingIndicatorDotsTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing [StreamTypingIndicatorDots] widgets.
///
/// {@tool snippet}
///
/// Customize the typing indicator dots globally:
///
/// ```dart
/// StreamTheme(
///   typingIndicatorDotsTheme: StreamTypingIndicatorDotsThemeData(
///     color: Colors.blue,
///     period: Duration(seconds: 2),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamTypingIndicatorDots], the widget that uses this theme data.
///  * [StreamTypingIndicatorDotsTheme], for overriding theme in a widget subtree.
@themeGen
@immutable
class StreamTypingIndicatorDotsThemeData with _$StreamTypingIndicatorDotsThemeData {
  /// Creates typing indicator dots theme data with optional style overrides.
  const StreamTypingIndicatorDotsThemeData({
    this.color,
    this.dotSize,
    this.spacing,
    this.period,
  });

  /// The color of the dots.
  final Color? color;

  /// The diameter of each dot in logical pixels.
  final double? dotSize;

  /// The gap between adjacent dots in logical pixels.
  final double? spacing;

  /// The duration of one full cycle of the animation.
  final Duration? period;

  /// Linearly interpolate between two [StreamTypingIndicatorDotsThemeData] objects.
  static StreamTypingIndicatorDotsThemeData? lerp(
    StreamTypingIndicatorDotsThemeData? a,
    StreamTypingIndicatorDotsThemeData? b,
    double t,
  ) => _$StreamTypingIndicatorDotsThemeData.lerp(a, b, t);
}
