import 'package:flutter/material.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';

part 'stream_emoji_chip_theme.g.theme.dart';

/// Applies an emoji chip theme to descendant emoji chip widgets.
///
/// Wrap a subtree with [StreamEmojiChipTheme] to override emoji chip styling.
/// Access the merged theme using [BuildContext.streamEmojiChipTheme].
///
/// {@tool snippet}
///
/// Override emoji chip styling for a specific section:
///
/// ```dart
/// StreamEmojiChipTheme(
///   data: StreamEmojiChipThemeData(
///     style: StreamEmojiChipThemeStyle(
///       foregroundColor: WidgetStateProperty.all(Colors.blue),
///     ),
///   ),
///   child: StreamEmojiChip(
///     emoji: Text('👍'),
///     count: 3,
///     onPressed: () {},
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamEmojiChipThemeData], which describes the emoji chip theme.
class StreamEmojiChipTheme extends InheritedTheme {
  /// Creates an emoji chip theme that controls descendant emoji chips.
  const StreamEmojiChipTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The emoji chip theme data for descendant widgets.
  final StreamEmojiChipThemeData data;

  /// Returns the [StreamEmojiChipThemeData] from the current theme context.
  ///
  /// This merges the local theme (if any) with the global theme from
  /// [StreamTheme].
  static StreamEmojiChipThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamEmojiChipTheme>();
    return StreamTheme.of(context).emojiChipTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamEmojiChipTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamEmojiChipTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing emoji chip widgets.
///
/// {@tool snippet}
///
/// Customize emoji chip appearance globally:
///
/// ```dart
/// StreamTheme(
///   emojiChipTheme: StreamEmojiChipThemeData(
///     style: StreamEmojiChipThemeStyle(
///       foregroundColor: WidgetStateProperty.resolveWith((states) {
///         if (states.contains(WidgetState.disabled)) return Colors.grey;
///         return Colors.black;
///       }),
///     ),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamEmojiChipTheme], for overriding theme in a widget subtree.
@themeGen
@immutable
class StreamEmojiChipThemeData with _$StreamEmojiChipThemeData {
  /// Creates an emoji chip theme with optional style overrides.
  const StreamEmojiChipThemeData({this.style});

  /// The visual styling for emoji chips.
  final StreamEmojiChipThemeStyle? style;

  /// Linearly interpolate between two [StreamEmojiChipThemeData] objects.
  static StreamEmojiChipThemeData? lerp(
    StreamEmojiChipThemeData? a,
    StreamEmojiChipThemeData? b,
    double t,
  ) => _$StreamEmojiChipThemeData.lerp(a, b, t);
}

/// Visual styling properties for emoji chips.
///
/// Defines the appearance of emoji chips including background, foreground,
/// overlay colors, size, padding, and border styling. All color properties
/// support state-based styling for interactive feedback.
///
/// See also:
///
///  * [StreamEmojiChipThemeData], which wraps this style for theming.
///  * [StreamEmojiChip], which uses this styling.
@themeGen
@immutable
class StreamEmojiChipThemeStyle with _$StreamEmojiChipThemeStyle {
  /// Creates emoji chip style properties.
  const StreamEmojiChipThemeStyle({
    this.backgroundColor,
    this.foregroundColor,
    this.overlayColor,
    this.textStyle,
    this.elevation,
    this.shadowColor,
    this.emojiSize,
    this.minimumSize,
    this.maximumSize,
    this.padding,
    this.shape,
    WidgetStateProperty<BorderSide?>? side,
  })
    // TODO: Fix this or try to find something better
    : side = side as WidgetStateBorderSide?;

  /// The background color for emoji chips.
  ///
  /// Supports state-based colors for different interaction states
  /// (default, hover, pressed, disabled, selected).
  final WidgetStateProperty<Color?>? backgroundColor;

  /// The foreground color for emoji/icon and count text content.
  ///
  /// Supports state-based colors for different interaction states.
  final WidgetStateProperty<Color?>? foregroundColor;

  /// The overlay color for interaction feedback (hover, press).
  ///
  /// Supports state-based colors for hover and press states.
  final WidgetStateProperty<Color?>? overlayColor;

  /// The text style for the reaction count label.
  ///
  /// The color of [textStyle] is typically not used directly — use
  /// [foregroundColor] to control text and icon color instead.
  final WidgetStateProperty<TextStyle?>? textStyle;

  /// The elevation of the chip.
  ///
  /// Supports state-based elevation for different interaction states
  /// (default, hover, pressed, disabled, selected).
  final WidgetStateProperty<double?>? elevation;

  /// The shadow color of the chip.
  ///
  /// Must be set to a non-transparent color for [elevation] to produce a
  /// visible shadow.
  final WidgetStateProperty<Color?>? shadowColor;

  /// The display size of the emoji/icon in logical pixels.
  ///
  /// Falls back to [StreamEmojiSize.sm] (16px).
  final double? emojiSize;

  /// The minimum size of the chip.
  ///
  /// Falls back to `Size(64, 32)`.
  final Size? minimumSize;

  /// The maximum size of the chip.
  ///
  /// Falls back to `Size.fromHeight(32)` — unconstrained width, fixed 32px height.
  final Size? maximumSize;

  /// The internal padding of the chip.
  ///
  /// Falls back to horizontal `StreamSpacing.sm` and vertical
  /// `StreamSpacing.xxs + StreamSpacing.xxxs`.
  final EdgeInsetsGeometry? padding;

  /// The shape of the chip's container.
  ///
  /// Falls back to a [RoundedRectangleBorder] with `StreamRadius.max`.
  final OutlinedBorder? shape;

  /// The border for the chip.
  ///
  /// Supports state-based borders for different interaction states.
  final WidgetStateBorderSide? side;

  /// Linearly interpolate between two [StreamEmojiChipThemeStyle] objects.
  static StreamEmojiChipThemeStyle? lerp(
    StreamEmojiChipThemeStyle? a,
    StreamEmojiChipThemeStyle? b,
    double t,
  ) => _$StreamEmojiChipThemeStyle.lerp(a, b, t);
}
