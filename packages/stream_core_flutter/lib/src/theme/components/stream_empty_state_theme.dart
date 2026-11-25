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
///     constraints: BoxConstraints(maxWidth: 320),
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
    this.constraints,
  });

  /// The size of the icon, in logical pixels.
  ///
  /// Defaults to 32.
  final double? iconSize;

  /// The color of the icon.
  ///
  /// Defaults to [StreamColorScheme.textTertiary].
  final Color? iconColor;

  /// The text style of the title, merged over the default.
  ///
  /// Defaults to [StreamTextTheme.headingSm] in
  /// [StreamColorScheme.textPrimary]. A style that sets only some properties,
  /// such as a color, keeps the default for the rest.
  final TextStyle? titleTextStyle;

  /// The text style of the description, merged over the default.
  ///
  /// Defaults to [StreamTextTheme.bodyDefault] in
  /// [StreamColorScheme.textSecondary]. A style that sets only some properties,
  /// such as a color, keeps the default for the rest.
  final TextStyle? descriptionTextStyle;

  /// The padding around the content.
  ///
  /// Defaults to [StreamSpacing.md] horizontally and [StreamSpacing.xxxl]
  /// vertically.
  final EdgeInsetsGeometry? padding;

  /// The gap between the icon and the text.
  ///
  /// Defaults to [StreamSpacing.sm].
  final double? iconSpacing;

  /// The gap between the title and the description.
  ///
  /// Defaults to [StreamSpacing.xs].
  final double? textSpacing;

  /// The gap between the text and the action.
  ///
  /// Defaults to [StreamSpacing.md].
  final double? actionSpacing;

  /// Constraints on the size of the content inside the [padding].
  ///
  /// A `maxWidth` makes the text wrap sooner than the available width.
  /// Defaults to unconstrained, so the content takes up to the full width the
  /// empty state is given.
  final BoxConstraints? constraints;

  /// Linearly interpolate between two [StreamEmptyStateThemeData] objects.
  static StreamEmptyStateThemeData? lerp(
    StreamEmptyStateThemeData? a,
    StreamEmptyStateThemeData? b,
    double t,
  ) => _$StreamEmptyStateThemeData.lerp(a, b, t);
}
