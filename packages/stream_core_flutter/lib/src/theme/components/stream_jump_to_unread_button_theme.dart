import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';
import 'stream_button_theme.dart';

part 'stream_jump_to_unread_button_theme.g.theme.dart';

/// Applies a jump-to-unread button theme to descendant
/// [StreamJumpToUnreadButton] widgets.
///
/// Wrap a subtree with [StreamJumpToUnreadButtonTheme] to override button
/// styling. Access the merged theme using
/// [BuildContext.streamJumpToUnreadButtonTheme].
///
/// {@tool snippet}
///
/// Override button colors for a specific section:
///
/// ```dart
/// StreamJumpToUnreadButtonTheme(
///   data: StreamJumpToUnreadButtonThemeData(
///     backgroundColor: Colors.blue,
///     leadingStyle: StreamButtonThemeStyle(
///       foregroundColor: WidgetStatePropertyAll(Colors.white),
///     ),
///   ),
///   child: StreamJumpToUnreadButton(
///     label: '5 unread',
///     onJumpPressed: () {},
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamJumpToUnreadButtonThemeData], which describes the theme.
///  * [StreamJumpToUnreadButton], the widget affected by this theme.
class StreamJumpToUnreadButtonTheme extends InheritedTheme {
  /// Creates a jump-to-unread button theme that controls descendant widgets.
  const StreamJumpToUnreadButtonTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The theme data for descendant widgets.
  final StreamJumpToUnreadButtonThemeData data;

  /// Returns the [StreamJumpToUnreadButtonThemeData] merged from local and
  /// global themes.
  ///
  /// Local values from the nearest [StreamJumpToUnreadButtonTheme] ancestor
  /// take precedence over global values from [StreamTheme.of].
  ///
  /// This allows partial overrides — for example, overriding only
  /// [StreamJumpToUnreadButtonThemeData.backgroundColor] while inheriting
  /// other properties from the global theme.
  static StreamJumpToUnreadButtonThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamJumpToUnreadButtonTheme>();
    return StreamTheme.of(context).jumpToUnreadButtonTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamJumpToUnreadButtonTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamJumpToUnreadButtonTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing [StreamJumpToUnreadButton] widgets.
///
/// The outer pill container is styled with [backgroundColor], [side],
/// [elevation], and [shadowColor]. The inner leading and trailing sub-buttons
/// (which use [StreamButton]) are independently styled via
/// [leadingStyle] and [trailingStyle].
///
/// {@tool snippet}
///
/// Customize button appearance globally:
///
/// ```dart
/// StreamTheme(
///   jumpToUnreadButtonTheme: StreamJumpToUnreadButtonThemeData(
///     backgroundColor: Colors.white,
///     side: BorderSide(color: Colors.grey),
///     leadingStyle: StreamButtonThemeStyle(
///       foregroundColor: WidgetStatePropertyAll(Colors.black),
///       textStyle: WidgetStatePropertyAll(myTextStyle),
///     ),
///     trailingStyle: StreamButtonThemeStyle(
///       iconSize: WidgetStatePropertyAll(20),
///     ),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamJumpToUnreadButton], the widget that uses this theme data.
///  * [StreamJumpToUnreadButtonTheme], for overriding theme in a subtree.
@themeGen
@immutable
class StreamJumpToUnreadButtonThemeData with _$StreamJumpToUnreadButtonThemeData {
  /// Creates a jump-to-unread button theme with optional style overrides.
  const StreamJumpToUnreadButtonThemeData({
    this.backgroundColor,
    this.shape,
    this.side,
    this.elevation,
    this.shadowColor,
    this.padding,
    this.leadingStyle,
    this.trailingStyle,
  });

  /// The background color of the pill container.
  ///
  /// Falls back to [StreamColorScheme.backgroundElevation1].
  final Color? backgroundColor;

  /// The shape of the pill container.
  ///
  /// The [side] is merged into this shape in the build method via
  /// [OutlinedBorder.copyWith].
  ///
  /// Falls back to a [RoundedRectangleBorder] with max radius.
  final OutlinedBorder? shape;

  /// The border side of the pill container.
  ///
  /// Merged into [shape] at build time. The [BorderSide.color] and
  /// [BorderSide.width] are also used for the separator between
  /// leading and trailing sections.
  ///
  /// Falls back to a 1px [BorderSide] using
  /// [StreamColorScheme.borderDefault].
  final BorderSide? side;

  /// The Material elevation of the pill container.
  ///
  /// Falls back to 3.
  final double? elevation;

  /// The shadow color used with [elevation].
  ///
  /// Falls back to the Material default.
  final Color? shadowColor;

  /// The padding between the pill border and the inner content.
  ///
  /// Falls back to [StreamSpacing.xxs] (4px) on all sides.
  final EdgeInsetsGeometry? padding;

  /// The style applied to the leading [StreamButton] (icon + label).
  ///
  /// Use this to customize foreground color, text style, icon size, padding,
  /// and other visual properties of the leading section.
  ///
  /// Falls back to a style with [StreamColorScheme.textPrimary] foreground,
  /// [StreamTextTheme.captionEmphasis] text, and 16px icons.
  final StreamButtonThemeStyle? leadingStyle;

  /// The style applied to the trailing [StreamButton.icon] (dismiss).
  ///
  /// Use this to customize foreground color, icon size, padding,
  /// and other visual properties of the trailing section.
  ///
  /// Falls back to a style with [StreamColorScheme.textPrimary] foreground
  /// and 16px icons.
  final StreamButtonThemeStyle? trailingStyle;

  /// Linearly interpolate between two
  /// [StreamJumpToUnreadButtonThemeData] objects.
  static StreamJumpToUnreadButtonThemeData? lerp(
    StreamJumpToUnreadButtonThemeData? a,
    StreamJumpToUnreadButtonThemeData? b,
    double t,
  ) => _$StreamJumpToUnreadButtonThemeData.lerp(a, b, t);
}
