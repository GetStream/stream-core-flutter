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
/// value for anything left unset. A color property that resolves to null for
/// some state falls back to the design-system color for that state, so a
/// theme can override just the selected tab.
///
/// The color properties resolve against [WidgetState.selected] for the
/// selected tab and [WidgetState.disabled] for a disabled one. Only
/// [overlayColor] also receives [WidgetState.hovered], [WidgetState.focused]
/// and [WidgetState.pressed] while the pointer or the keyboard is interacting
/// with the tab.
///
/// {@tool snippet}
///
/// Customize tab bar appearance globally via [StreamTheme]. Returning null
/// for the unselected tabs keeps their default underline:
///
/// ```dart
/// final colorScheme = StreamColorScheme.light();
///
/// StreamTheme(
///   colorScheme: colorScheme,
///   tabBarTheme: StreamTabBarThemeData(
///     minHeight: 40,
///     indicatorColor: WidgetStateProperty.resolveWith(
///       (states) => states.contains(WidgetState.selected) ? colorScheme.accentSuccess : null,
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
    this.minHeight,
    this.indicatorWeight,
    this.indicatorColor,
    this.labelStyle,
    this.foregroundColor,
    this.overlayColor,
    this.tabPadding,
    this.spacing,
  });

  /// The minimum height of the bar in logical pixels, underline included.
  ///
  /// The bar grows taller when the text scale needs more room. Defaults to 48.
  final double? minHeight;

  /// The thickness of the underline along the bottom of every tab, in logical
  /// pixels.
  ///
  /// Defaults to 2.
  final double? indicatorWeight;

  /// The color of the underline along the bottom of a tab.
  ///
  /// Every tab draws the underline, so unselected tabs together form the bar's
  /// bottom border. Defaults to [StreamColorScheme.accentPrimary] for the
  /// selected tab, [StreamColorScheme.borderDisabled] for a disabled tab and
  /// [StreamColorScheme.borderDefault] for the others.
  final WidgetStateProperty<Color?>? indicatorColor;

  /// The text style of each tab's label.
  ///
  /// It is merged over the default, so setting only `fontSize` keeps the
  /// default font family and weight. This only controls typography. Color
  /// comes from [foregroundColor].
  /// Defaults to [StreamTextTheme.captionEmphasis].
  final TextStyle? labelStyle;

  /// The color of each tab's label and icon.
  ///
  /// Defaults to [StreamColorScheme.accentPrimary] for the selected tab,
  /// [StreamColorScheme.textDisabled] for a disabled tab and
  /// [StreamColorScheme.textSecondary] for the others.
  final WidgetStateProperty<Color?>? foregroundColor;

  /// The highlight painted over a tab while it is hovered, focused or pressed.
  ///
  /// Defaults to [StreamColorScheme.backgroundPressed] while pressed and
  /// [StreamColorScheme.backgroundHover] while hovered or focused.
  final WidgetStateProperty<Color?>? overlayColor;

  /// The padding around each tab's icon and label, inside the tab.
  ///
  /// The underline sits below this padding, so it never covers the label.
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
