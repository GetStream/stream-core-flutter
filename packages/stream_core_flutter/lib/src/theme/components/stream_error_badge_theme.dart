import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';

part 'stream_error_badge_theme.g.theme.dart';

/// Predefined sizes for [StreamErrorBadge].
///
/// Each size corresponds to a specific diameter and icon size in logical
/// pixels.
///
/// See also:
///
///  * [StreamErrorBadge], which uses these size variants.
///  * [StreamErrorBadgeThemeData.size], for setting a global default.
enum StreamErrorBadgeSize {
  /// Medium badge (24px diameter, 20px icon).
  md(24, 20),

  /// Small badge (20px diameter, 16px icon).
  sm(20, 16),

  /// Extra-small badge (16px diameter, 12px icon).
  xs(16, 12);

  const StreamErrorBadgeSize(this.value, this.iconSize);

  /// The diameter of the badge in logical pixels.
  final double value;

  /// The icon size for this badge size.
  final double iconSize;
}

/// The severity a [StreamErrorBadge] conveys.
///
/// Determines which background and icon color the badge applies.
///
/// See also:
///
///  * [StreamErrorBadge], which uses these style variants.
enum StreamErrorBadgeStyle {
  /// Error style — an error-colored background with an on-accent icon.
  ///
  /// The default. Reads as a failure that needs the user's attention.
  error,

  /// Warning style — a warning-colored background with a black icon.
  ///
  /// For a cautionary state rather than an outright failure, and for
  /// surfaces where the error style would not separate from what sits
  /// underneath — a call control button, or arbitrary video.
  ///
  /// The icon is pinned to black rather than to a mode-aware text color,
  /// because the warning background does not invert between light and dark.
  warning,
}

/// Applies an error badge theme to descendant widgets.
///
/// Wrap a subtree with [StreamErrorBadgeTheme] to override error badge
/// styling. Access the merged theme using [BuildContext.streamErrorBadgeTheme].
///
/// See also:
///
///  * [StreamErrorBadgeThemeData], which describes the theme.
///  * [StreamErrorBadge], the widget affected by this theme.
class StreamErrorBadgeTheme extends InheritedTheme {
  /// Creates an error badge theme.
  const StreamErrorBadgeTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The error badge theme data for descendant widgets.
  final StreamErrorBadgeThemeData data;

  /// Returns the merged [StreamErrorBadgeThemeData] from local and global
  /// themes.
  static StreamErrorBadgeThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamErrorBadgeTheme>();
    return StreamTheme.of(context).errorBadgeTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamErrorBadgeTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamErrorBadgeTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing [StreamErrorBadge] widgets.
///
/// Organizes badge colors by [StreamErrorBadgeStyle], so the warning style can
/// be styled without touching the error one.
///
/// {@tool snippet}
///
/// Customize badge appearance globally via [StreamTheme]:
///
/// ```dart
/// StreamTheme(
///   errorBadgeTheme: StreamErrorBadgeThemeData(
///     warningBackgroundColor: Colors.amber,
///     warningForegroundColor: Colors.black,
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamErrorBadge], the widget that uses this theme data.
///  * [StreamErrorBadgeTheme], for overriding theme in a widget subtree.
@themeGen
@immutable
class StreamErrorBadgeThemeData with _$StreamErrorBadgeThemeData {
  /// Creates an error badge theme with optional style overrides.
  const StreamErrorBadgeThemeData({
    this.size,
    this.errorBackgroundColor,
    this.errorForegroundColor,
    this.warningBackgroundColor,
    this.warningForegroundColor,
    this.border,
  });

  /// The default size for error badges.
  ///
  /// Falls back to [StreamErrorBadgeSize.sm].
  final StreamErrorBadgeSize? size;

  /// The fill color of badges of the [StreamErrorBadgeStyle.error] style.
  ///
  /// Defaults to [StreamColorScheme.accentError].
  final Color? errorBackgroundColor;

  /// The icon color of badges of the [StreamErrorBadgeStyle.error] style.
  ///
  /// Defaults to [StreamColorScheme.textOnAccent].
  final Color? errorForegroundColor;

  /// The fill color of badges of the [StreamErrorBadgeStyle.warning] style.
  ///
  /// Defaults to [StreamColorScheme.accentWarning].
  final Color? warningBackgroundColor;

  /// The icon color of badges of the [StreamErrorBadgeStyle.warning] style.
  ///
  /// Defaults to black rather than to a mode-aware text color, because the
  /// warning background does not invert between light and dark.
  final Color? warningForegroundColor;

  /// The border drawn around the badge.
  ///
  /// Applied when [StreamErrorBadge.showBorder] is true. Allows customization
  /// of both border color and width. Shared by both styles.
  final BoxBorder? border;

  /// Linearly interpolate between two [StreamErrorBadgeThemeData].
  static StreamErrorBadgeThemeData? lerp(
    StreamErrorBadgeThemeData? a,
    StreamErrorBadgeThemeData? b,
    double t,
  ) => _$StreamErrorBadgeThemeData.lerp(a, b, t);
}
