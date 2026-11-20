import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';

part 'stream_empty_state_theme.g.theme.dart';

/// Applies an empty state theme to descendant [StreamEmptyState] widgets.
///
/// Wrap a subtree with [StreamEmptyStateTheme] to override empty state
/// styling. Access the merged theme using
/// [BuildContext.streamEmptyStateTheme].
///
/// {@tool snippet}
///
/// Use a larger icon for the empty states in a subtree:
///
/// ```dart
/// StreamEmptyStateTheme(
///   data: StreamEmptyStateThemeData(iconSize: 48),
///   child: child,
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamEmptyStateThemeData], which describes the empty state theme.
///  * [StreamEmptyState], the widget affected by this theme.
class StreamEmptyStateTheme extends InheritedTheme {
  /// Creates an empty state theme that controls descendant empty states.
  const StreamEmptyStateTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The empty state theme data for descendant widgets.
  final StreamEmptyStateThemeData data;

  /// Returns the [StreamEmptyStateThemeData] merged from local and global
  /// themes.
  ///
  /// Local values from the nearest [StreamEmptyStateTheme] ancestor take
  /// precedence over global values from [StreamTheme.of].
  static StreamEmptyStateThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamEmptyStateTheme>();
    return StreamTheme.of(context).emptyStateTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamEmptyStateTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamEmptyStateTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing [StreamEmptyState] widgets.
///
/// A property left null falls back to the design system default.
///
/// {@tool snippet}
///
/// Customize empty states globally:
///
/// ```dart
/// StreamTheme(
///   emptyStateTheme: StreamEmptyStateThemeData(
///     iconSize: 48,
///     maxTextWidth: 320,
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamEmptyState], the widget that uses this theme data.
///  * [StreamEmptyStateTheme], for overriding the theme in a widget subtree.
@themeGen
@immutable
class StreamEmptyStateThemeData with _$StreamEmptyStateThemeData {
  /// Creates empty state theme data with optional overrides.
  const StreamEmptyStateThemeData({
    this.iconSize,
    this.iconColor,
    this.titleTextStyle,
    this.descriptionTextStyle,
    this.padding,
    this.iconSpacing,
    this.textSpacing,
    this.actionSpacing,
    this.maxTextWidth,
  });

  /// The size of the icon, in logical pixels.
  ///
  /// Falls back to 32.
  final double? iconSize;

  /// The color of the icon.
  final Color? iconColor;

  /// The text style of the title, including its color.
  final TextStyle? titleTextStyle;

  /// The text style of the description, including its color.
  final TextStyle? descriptionTextStyle;

  /// The padding between the empty state's edge and its content.
  final EdgeInsetsGeometry? padding;

  /// The gap between the icon and the text.
  final double? iconSpacing;

  /// The gap between the title and the description.
  final double? textSpacing;

  /// The gap between the text and the action.
  final double? actionSpacing;

  /// The widest the title and description grow, in logical pixels.
  ///
  /// When null, the text takes up to the full width the empty state is given.
  final double? maxTextWidth;

  /// Linearly interpolate between two [StreamEmptyStateThemeData] objects.
  static StreamEmptyStateThemeData? lerp(
    StreamEmptyStateThemeData? a,
    StreamEmptyStateThemeData? b,
    double t,
  ) => _$StreamEmptyStateThemeData.lerp(a, b, t);
}
