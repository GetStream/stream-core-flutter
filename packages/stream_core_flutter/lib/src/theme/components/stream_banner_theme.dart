import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';

part 'stream_banner_theme.g.theme.dart';

/// The kinds of state a [StreamBanner] can report.
///
/// Each type has its own leading icon and style.
///
/// See also:
///
///  * [StreamBannerProps.type], which selects one of these types.
enum StreamBannerType {
  /// A general system state.
  neutral,

  /// A waiting state, such as reconnecting, shown with a spinner.
  loading,

  /// A failure, such as content that could not be loaded.
  error,
}

/// Applies a banner theme to descendant [StreamBanner] widgets.
///
/// Wrap a subtree with [StreamBannerTheme] to override banner styling.
/// Access the merged theme using [BuildContext.streamBannerTheme].
///
/// {@tool snippet}
///
/// Restyle error banners for a specific subtree:
///
/// ```dart
/// StreamBannerTheme(
///   data: StreamBannerThemeData(
///     error: StreamBannerThemeStyle(iconColor: Colors.red),
///   ),
///   child: child,
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamBannerThemeData], which describes the banner theme.
///  * [StreamBanner], the widget affected by this theme.
class StreamBannerTheme extends InheritedTheme {
  /// Creates a banner theme that controls descendant banners.
  const StreamBannerTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The banner theme data for descendant widgets.
  final StreamBannerThemeData data;

  /// Returns the [StreamBannerThemeData] merged from local and global themes.
  ///
  /// Local values from the nearest [StreamBannerTheme] ancestor take
  /// precedence over global values from [StreamTheme.of].
  static StreamBannerThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamBannerTheme>();
    return StreamTheme.of(context).bannerTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamBannerTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamBannerTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing [StreamBanner] widgets.
///
/// Each type's colors and text style are set through [neutral], [loading] and
/// [error]. The geometry ([shape], [padding], [spacing] and [constraints]) is
/// shared by every type. A property left null falls back to the design system
/// default.
///
/// {@tool snippet}
///
/// Customize banners globally:
///
/// ```dart
/// StreamTheme(
///   bannerTheme: StreamBannerThemeData(
///     error: StreamBannerThemeStyle(iconColor: Colors.red),
///     padding: EdgeInsets.all(16),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamBanner], the widget that uses this theme data.
///  * [StreamBannerTheme], for overriding the theme in a widget subtree.
@themeGen
@immutable
class StreamBannerThemeData with _$StreamBannerThemeData {
  /// Creates banner theme data with optional overrides.
  const StreamBannerThemeData({
    this.neutral,
    this.loading,
    this.error,
    this.shape,
    this.padding,
    this.spacing,
    this.constraints,
  });

  /// The style of [StreamBannerType.neutral] banners.
  final StreamBannerThemeStyle? neutral;

  /// The style of [StreamBannerType.loading] banners.
  final StreamBannerThemeStyle? loading;

  /// The style of [StreamBannerType.error] banners.
  final StreamBannerThemeStyle? error;

  /// The shape of the banner.
  final OutlinedBorder? shape;

  /// The padding between the banner edge and its content.
  final EdgeInsetsGeometry? padding;

  /// The gap between the icon and the title.
  final double? spacing;

  /// Constraints on the banner's size.
  final BoxConstraints? constraints;

  /// Linearly interpolate between two [StreamBannerThemeData] objects.
  static StreamBannerThemeData? lerp(
    StreamBannerThemeData? a,
    StreamBannerThemeData? b,
    double t,
  ) => _$StreamBannerThemeData.lerp(a, b, t);
}

/// The colors and text style of one [StreamBannerType] of [StreamBanner].
///
/// See also:
///
///  * [StreamBannerThemeData], which holds one of these per type.
@themeGen
@immutable
class StreamBannerThemeStyle with _$StreamBannerThemeStyle {
  /// Creates a banner style with optional overrides.
  const StreamBannerThemeStyle({
    this.backgroundColor,
    this.iconColor,
    this.titleTextStyle,
  });

  /// The fill behind the banner.
  final Color? backgroundColor;

  /// The color of the leading icon, including the loading spinner.
  final Color? iconColor;

  /// The text style of the title, including its color.
  final TextStyle? titleTextStyle;

  /// Linearly interpolate between two [StreamBannerThemeStyle] objects.
  static StreamBannerThemeStyle? lerp(
    StreamBannerThemeStyle? a,
    StreamBannerThemeStyle? b,
    double t,
  ) => _$StreamBannerThemeStyle.lerp(a, b, t);
}
