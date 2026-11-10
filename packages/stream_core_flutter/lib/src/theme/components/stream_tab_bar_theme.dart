import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../../components/toolbar/stream_tab_bar.dart';
import '../stream_theme.dart';

part 'stream_tab_bar_theme.g.theme.dart';

/// Applies a tab bar theme to descendant [StreamTabBar] widgets.
///
/// Wrap a subtree with [StreamTabBarTheme] to override tab bar styling.
/// Access the merged theme using [BuildContext.streamTabBarTheme].
///
/// {@tool snippet}
///
/// Thicken the underline of the tab bars in one section:
///
/// ```dart
/// StreamTabBarTheme(
///   data: StreamTabBarThemeData(indicatorWeight: 3),
///   child: StreamTabBar(
///     selectedIndex: selectedIndex,
///     onSelected: (index) => setState(() => selectedIndex = index),
///     tabs: [
///       StreamTabBarItem(label: 'Photos'),
///       StreamTabBarItem(label: 'Videos'),
///     ],
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamTabBarThemeData], which describes the tab bar theme.
///  * [StreamTabBar], the widget affected by this theme.
@experimental
class StreamTabBarTheme extends InheritedTheme {
  /// Creates a tab bar theme that controls descendant tab bars.
  const StreamTabBarTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The tab bar theme data for descendant widgets.
  final StreamTabBarThemeData data;

  /// Returns the [StreamTabBarThemeData] merged from local and global themes.
  ///
  /// Local values from the nearest [StreamTabBarTheme] ancestor take
  /// precedence over global values from [StreamTheme.of].
  static StreamTabBarThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamTabBarTheme>();
    return StreamTheme.of(context).tabBarTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamTabBarTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamTabBarTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing [StreamTabBar] widgets.
///
/// Every property is null by default; the tab bar resolves the design-system
/// value for anything left unset.
///
/// The color properties resolve against the tab's [WidgetState]s:
/// [WidgetState.selected] for the selected tab, plus [WidgetState.hovered],
/// [WidgetState.focused] and [WidgetState.pressed] while the pointer or the
/// keyboard is interacting with it.
///
/// {@tool snippet}
///
/// Customize tab bar appearance globally via [StreamTheme]:
///
/// ```dart
/// StreamTheme(
///   tabBarTheme: StreamTabBarThemeData(
///     height: 40,
///     indicatorColor: WidgetStateProperty.resolveWith(
///       (states) => states.contains(WidgetState.selected) ? Colors.purple : Colors.transparent,
///     ),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamTabBarTheme], for overriding the theme in a widget subtree.
///  * [StreamTabBar], the widget that uses this theme data.
@themeGen
@immutable
@experimental
class StreamTabBarThemeData with _$StreamTabBarThemeData {
  /// Creates tab bar theme data with optional property overrides.
  const StreamTabBarThemeData({
    this.height,
    this.indicatorWeight,
    this.indicatorColor,
    this.labelStyle,
    this.foregroundColor,
    this.overlayColor,
    this.tabPadding,
    this.spacing,
  });

  /// The height of the bar in logical pixels, underline included.
  ///
  /// Defaults to [StreamTabBar.height] (48).
  final double? height;

  /// The thickness of the underline along the bottom of every tab, in logical
  /// pixels.
  ///
  /// Defaults to 2.
  final double? indicatorWeight;

  /// The color of the underline along the bottom of a tab.
  ///
  /// Every tab draws the underline, so unselected tabs together form the bar's
  /// bottom border. Defaults to [StreamColorScheme.accentPrimary] for the
  /// selected tab and [StreamColorScheme.borderDefault] for the others.
  final WidgetStateProperty<Color?>? indicatorColor;

  /// The text style of each tab's label.
  ///
  /// This only controls typography. Color comes from [foregroundColor].
  /// Defaults to [StreamTextTheme.captionEmphasis].
  final TextStyle? labelStyle;

  /// The color of each tab's label and icon.
  ///
  /// Defaults to [StreamColorScheme.accentPrimary] for the selected tab and
  /// [StreamColorScheme.textSecondary] for the others.
  final WidgetStateProperty<Color?>? foregroundColor;

  /// The highlight painted over a tab while it is hovered, focused or pressed.
  ///
  /// Defaults to [StreamColorScheme.backgroundPressed] while pressed and
  /// [StreamColorScheme.backgroundHover] while hovered or focused.
  final WidgetStateProperty<Color?>? overlayColor;

  /// The padding around each tab's icon and label, inside the tab.
  ///
  /// Defaults to [StreamSpacing.sm] on every side.
  final EdgeInsetsGeometry? tabPadding;

  /// The gap between a tab's icon and its label, in logical pixels.
  ///
  /// Defaults to [StreamSpacing.xs].
  final double? spacing;

  /// Linearly interpolate between two [StreamTabBarThemeData] objects.
  static StreamTabBarThemeData? lerp(
    StreamTabBarThemeData? a,
    StreamTabBarThemeData? b,
    double t,
  ) => _$StreamTabBarThemeData.lerp(a, b, t);
}
