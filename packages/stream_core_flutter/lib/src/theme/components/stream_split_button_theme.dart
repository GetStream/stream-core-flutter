import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../../components/buttons/stream_split_button.dart';
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
/// Override the separator of regular split buttons for a specific section:
///
/// ```dart
/// StreamSplitButtonTheme(
///   data: StreamSplitButtonThemeData(
///     regular: StreamSplitButtonStyle(
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
/// Organizes split button styles by [StreamSplitButtonVariant], so the
/// destructive variant can be styled without touching the regular one.
///
/// {@tool snippet}
///
/// Customize split button appearance globally via [StreamTheme]:
///
/// ```dart
/// StreamTheme(
///   splitButtonTheme: StreamSplitButtonThemeData(
///     regular: StreamSplitButtonStyle(separatorThickness: 2),
///     destructive: StreamSplitButtonStyle(
///       separatorColor: WidgetStatePropertyAll(Colors.white),
///     ),
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
  /// Creates split button theme data with optional style overrides per
  /// variant.
  const StreamSplitButtonThemeData({this.regular, this.destructive});

  /// Creates split button theme data that applies [style] to every variant.
  ///
  /// Both [regular] and [destructive] are set to [style]. Useful when scoping
  /// a [StreamSplitButtonTheme] to a slot that should override every split
  /// button regardless of its configured [StreamSplitButtonVariant].
  const StreamSplitButtonThemeData.all(
    StreamSplitButtonStyle style,
  ) : regular = style,
      destructive = style;

  /// Styling for regular (neutral surface) split buttons.
  final StreamSplitButtonStyle? regular;

  /// Styling for destructive (error/danger) split buttons.
  final StreamSplitButtonStyle? destructive;

  /// The styling for split buttons of the given [variant].
  StreamSplitButtonStyle? styleOf(StreamSplitButtonVariant variant) => switch (variant) {
    StreamSplitButtonVariant.regular => regular,
    StreamSplitButtonVariant.destructive => destructive,
  };

  /// Linearly interpolate between two [StreamSplitButtonThemeData] objects.
  static StreamSplitButtonThemeData? lerp(
    StreamSplitButtonThemeData? a,
    StreamSplitButtonThemeData? b,
    double t,
  ) => _$StreamSplitButtonThemeData.lerp(a, b, t);
}

/// Visual styling properties for a single [StreamSplitButtonVariant].
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
  /// These take precedence over the inherited [StreamButtonTheme] entry the
  /// split button's [StreamSplitButtonVariant] maps to, and apply to both the
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
  /// Defaults to [StreamColorScheme.borderDefault] on the regular variant and
  /// [StreamColorScheme.borderOnAccent] on the destructive one, falling back
  /// to [StreamColorScheme.borderDefault] while the whole control is disabled
  /// and painting the shared disabled surface.
  final WidgetStateProperty<Color?>? separatorColor;

  /// The width of the divider between the two halves, in logical pixels.
  ///
  /// Defaults to 1.
  final double? separatorThickness;

  /// The height of the divider between the two halves, in logical pixels.
  ///
  /// The divider is shorter than the halves it separates, which are in turn
  /// shorter than the surface. Defaults to the half's own size inset by
  /// [StreamSpacing.xxs] at both ends — 24, since the halves are
  /// [StreamButtonSize.small].
  final double? separatorHeight;

  /// Linearly interpolate between two [StreamSplitButtonStyle] objects.
  static StreamSplitButtonStyle? lerp(
    StreamSplitButtonStyle? a,
    StreamSplitButtonStyle? b,
    double t,
  ) => _$StreamSplitButtonStyle.lerp(a, b, t);
}
