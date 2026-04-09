import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';

part 'stream_emoji_button_theme.g.theme.dart';

/// Predefined sizes for the emoji button.
///
/// Each size corresponds to a specific diameter in logical pixels.
///
/// See also:
///
///  * [StreamEmojiButtonThemeStyle.size], for setting a global default size.
enum StreamEmojiButtonSize {
  /// Medium button (32px diameter).
  md(32),

  /// Large button (40px diameter).
  lg(40),

  /// Extra large button (48px diameter).
  xl(48)
  ;

  /// Constructs a [StreamEmojiButtonSize] with the given diameter.
  const StreamEmojiButtonSize(this.value);

  /// The diameter of the button in logical pixels.
  final double value;
}

/// Applies an emoji button theme to descendant emoji button widgets.
///
/// Wrap a subtree with [StreamEmojiButtonTheme] to override emoji button
/// styling. Access the merged theme using
/// [BuildContext.streamEmojiButtonTheme].
///
/// {@tool snippet}
///
/// Override emoji button styling for a specific section:
///
/// ```dart
/// StreamEmojiButtonTheme(
///   data: StreamEmojiButtonThemeData(
///     style: StreamEmojiButtonThemeStyle(
///       size: StreamEmojiButtonSize.lg,
///     ),
///   ),
///   child: StreamEmojiButton(
///     emoji: Text('👍'),
///     onPressed: () {},
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamEmojiButtonThemeData], which describes the emoji button theme.
class StreamEmojiButtonTheme extends InheritedTheme {
  /// Creates an emoji button theme that controls descendant emoji buttons.
  const StreamEmojiButtonTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The emoji button theme data for descendant widgets.
  final StreamEmojiButtonThemeData data;

  /// Returns the [StreamEmojiButtonThemeData] from the current theme context.
  ///
  /// This merges the local theme (if any) with the global theme from [StreamTheme].
  static StreamEmojiButtonThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamEmojiButtonTheme>();
    return StreamTheme.of(context).emojiButtonTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamEmojiButtonTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamEmojiButtonTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing emoji button widgets.
///
/// {@tool snippet}
///
/// Customize emoji button appearance globally:
///
/// ```dart
/// StreamTheme(
///   emojiButtonTheme: StreamEmojiButtonThemeData(
///     style: StreamEmojiButtonThemeStyle(
///       size: StreamEmojiButtonSize.lg,
///       backgroundColor: WidgetStateProperty.resolveWith((states) {
///         if (states.contains(WidgetState.hovered)) {
///           return Colors.grey.shade200;
///         }
///         return Colors.transparent;
///       }),
///     ),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamEmojiButtonTheme], for overriding theme in a widget subtree.
@themeGen
@immutable
class StreamEmojiButtonThemeData with _$StreamEmojiButtonThemeData {
  /// Creates an emoji button theme with optional style overrides.
  const StreamEmojiButtonThemeData({this.style});

  /// The visual styling for emoji buttons.
  ///
  /// Contains size, background, foreground, overlay colors and border styling.
  final StreamEmojiButtonThemeStyle? style;

  /// Linearly interpolate between two [StreamEmojiButtonThemeData] objects.
  static StreamEmojiButtonThemeData? lerp(
    StreamEmojiButtonThemeData? a,
    StreamEmojiButtonThemeData? b,
    double t,
  ) => _$StreamEmojiButtonThemeData.lerp(a, b, t);
}

/// Visual styling properties for emoji buttons.
///
/// Defines the appearance of emoji buttons including size, colors, and borders.
/// All color properties support state-based styling for interactive feedback.
///
/// See also:
///
///  * [StreamEmojiButtonThemeData], which wraps this style for theming.
///  * [StreamEmojiButton], which uses this styling.
@themeGen
@immutable
class StreamEmojiButtonThemeStyle with _$StreamEmojiButtonThemeStyle {
  /// Creates emoji button style properties.
  const StreamEmojiButtonThemeStyle({
    this.size,
    this.backgroundColor,
    this.foregroundColor,
    this.overlayColor,
    WidgetStateProperty<BorderSide?>? side,
  }) // TODO: Fix this or try to find something better
  : side = side as WidgetStateBorderSide?;

  /// The size of emoji buttons.
  ///
  /// Falls back to [StreamEmojiButtonSize.xl].
  final StreamEmojiButtonSize? size;

  /// The background color for emoji buttons.
  ///
  /// Supports state-based colors for different interaction states
  /// (default, hover, pressed, disabled, selected).
  final WidgetStateProperty<Color?>? backgroundColor;

  /// The foreground color for emoji/icon content.
  ///
  /// Supports state-based colors for different interaction states.
  final WidgetStateProperty<Color?>? foregroundColor;

  /// The overlay color for the button's interaction feedback.
  ///
  /// Supports state-based colors for hover and press states.
  final WidgetStateProperty<Color?>? overlayColor;

  /// The border for the button.
  ///
  /// Supports state-based borders for different interaction states.
  final WidgetStateBorderSide? side;

  /// Linearly interpolate between two [StreamEmojiButtonThemeStyle] objects.
  static StreamEmojiButtonThemeStyle? lerp(
    StreamEmojiButtonThemeStyle? a,
    StreamEmojiButtonThemeStyle? b,
    double t,
  ) => _$StreamEmojiButtonThemeStyle.lerp(a, b, t);
}
