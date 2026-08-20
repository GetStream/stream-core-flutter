import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';
import 'stream_button_theme.dart';

part 'stream_split_button_theme.g.theme.dart';

/// Applies a split button theme to descendant [StreamSplitButton] widgets.
///
/// Wrap a subtree with [StreamSplitButtonTheme] to override split button
/// styling. Access the merged theme using
/// [BuildContext.streamSplitButtonTheme].
///
/// {@tool snippet}
///
/// Override the separator for a specific section:
///
/// ```dart
/// StreamSplitButtonTheme(
///   data: StreamSplitButtonThemeData(
///     style: StreamSplitButtonStyle(
///       separatorColor: WidgetStatePropertyAll(Colors.white24),
///     ),
///   ),
///   child: StreamSplitButton.icon(
///     icon: Icon(icons.voiceFill),
///     trailingIcon: Icon(icons.caretDown),
///     onPressed: () {},
///     onTrailingPressed: () {},
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamSplitButtonThemeData], which describes the split button theme.
///  * [StreamSplitButton], the widget affected by this theme.
@experimental
class StreamSplitButtonTheme extends InheritedTheme {
  /// Creates a split button theme that controls descendant split buttons.
  const StreamSplitButtonTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The split button theme data for descendant widgets.
  final StreamSplitButtonThemeData data;

  /// Returns the [StreamSplitButtonThemeData] merged from local and global
  /// themes.
  ///
  /// Local values from the nearest [StreamSplitButtonTheme] ancestor take
  /// precedence over global values from [StreamTheme.of].
  static StreamSplitButtonThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamSplitButtonTheme>();
    return StreamTheme.of(context).splitButtonTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamSplitButtonTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamSplitButtonTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing [StreamSplitButton] widgets.
///
/// {@tool snippet}
///
/// Customize split button appearance globally via [StreamTheme]:
///
/// ```dart
/// StreamTheme(
///   splitButtonTheme: StreamSplitButtonThemeData(
///     style: StreamSplitButtonStyle(separatorThickness: 2),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamSplitButtonTheme], for overriding theme in a widget subtree.
///  * [StreamSplitButton], the widget that uses this theme data.
@themeGen
@immutable
@experimental
class StreamSplitButtonThemeData with _$StreamSplitButtonThemeData {
  /// Creates split button theme data with optional style overrides.
  const StreamSplitButtonThemeData({this.style});

  /// The visual styling for split buttons.
  final StreamSplitButtonStyle? style;

  /// Linearly interpolate between two [StreamSplitButtonThemeData] objects.
  static StreamSplitButtonThemeData? lerp(
    StreamSplitButtonThemeData? a,
    StreamSplitButtonThemeData? b,
    double t,
  ) => _$StreamSplitButtonThemeData.lerp(a, b, t);
}

/// Visual styling properties for [StreamSplitButton].
///
/// A split button paints one shared surface behind two [StreamButton] halves.
/// That surface is derived from the same [StreamButtonTheme] entry the halves
/// use, so the two can never drift apart; [buttonStyle] adjusts both at once.
/// The remaining properties describe the divider between the halves.
///
/// See also:
///
///  * [StreamSplitButtonThemeData], which wraps this style for theming.
///  * [StreamSplitButton], which uses this styling.
///  * [StreamButtonThemeStyle], for available button style properties.
@themeGen
@immutable
@experimental
class StreamSplitButtonStyle with _$StreamSplitButtonStyle {
  /// Creates split button style properties.
  const StreamSplitButtonStyle({
    this.buttonStyle,
    this.separatorColor,
    this.separatorThickness,
    this.separatorHeight,
  });

  /// Per-instance style overrides for the split button.
  ///
  /// These take precedence over the inherited [StreamButtonTheme] entry for
  /// the split button's `style`/`type` combination, and apply to both the
  /// shared surface and the two halves, without affecting other
  /// [StreamButton] instances in the tree.
  ///
  /// [StreamButtonThemeStyle.backgroundColor] and
  /// [StreamButtonThemeStyle.borderColor] land on the shared surface — the
  /// halves themselves are always painted transparent and borderless so the
  /// surface reads as a single control.
  ///
  /// {@tool snippet}
  ///
  /// Give the split button a custom surface:
  ///
  /// ```dart
  /// StreamSplitButtonStyle(
  ///   buttonStyle: StreamButtonThemeStyle.from(
  ///     backgroundColor: Colors.black12,
  ///     foregroundColor: Colors.white,
  ///   ),
  /// )
  /// ```
  /// {@end-tool}
  final StreamButtonThemeStyle? buttonStyle;

  /// The color of the divider between the two halves.
  ///
  /// Defaults to [StreamColorScheme.borderDefault], or
  /// [StreamColorScheme.borderDisabled] while the whole control is disabled.
  final WidgetStateProperty<Color?>? separatorColor;

  /// The width of the divider between the two halves, in logical pixels.
  ///
  /// Defaults to 1.
  final double? separatorThickness;

  /// The height of the divider between the two halves, in logical pixels.
  ///
  /// The divider is shorter than the halves it separates, which are in turn
  /// shorter than the surface. Defaults to the button size inset by
  /// [StreamSpacing.xxs] twice over on both ends — 24 for a
  /// [StreamButtonSize.medium] split button.
  final double? separatorHeight;

  /// Linearly interpolate between two [StreamSplitButtonStyle] objects.
  static StreamSplitButtonStyle? lerp(
    StreamSplitButtonStyle? a,
    StreamSplitButtonStyle? b,
    double t,
  ) => _$StreamSplitButtonStyle.lerp(a, b, t);
}
