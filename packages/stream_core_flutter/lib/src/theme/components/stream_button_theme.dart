import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';

part 'stream_button_theme.g.theme.dart';

/// Applies a button theme to descendant [StreamButton] widgets.
///
/// Wrap a subtree with [StreamButtonTheme] to override button styling.
/// Access the merged theme using [BuildContext.streamButtonTheme].
///
/// {@tool snippet}
///
/// Override button styling for a specific section:
///
/// ```dart
/// StreamButtonTheme(
///   data: StreamButtonThemeData(
///     primary: StreamButtonTypeStyle(
///       solid: StreamButtonThemeStyle(
///         backgroundColor: WidgetStateProperty.all(Colors.blue),
///       ),
///     ),
///   ),
///   child: StreamButton(
///     label: 'Submit',
///     onTap: () {},
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamButtonThemeData], which describes the button theme.
///  * [StreamButton], which uses this theme.
class StreamButtonTheme extends InheritedTheme {
  /// Creates a button theme that controls descendant buttons.
  const StreamButtonTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The button theme data for descendant widgets.
  final StreamButtonThemeData data;

  /// Returns the [StreamButtonThemeData] from the current theme context.
  ///
  /// This merges the local theme (if any) with the global theme from
  /// [StreamTheme].
  static StreamButtonThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamButtonTheme>();
    return StreamTheme.of(context).buttonTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamButtonTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamButtonTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing [StreamButton] widgets.
///
/// Organizes button styles by [StreamButtonStyle] variant (primary,
/// secondary, destructive). Each variant can define styles for all
/// [StreamButtonType]s (solid, outline, ghost).
///
/// See also:
///
///  * [StreamButtonTheme], for overriding theme in a widget subtree.
///  * [StreamButtonTypeStyle], for per-type styling.
@themeGen
@immutable
class StreamButtonThemeData with _$StreamButtonThemeData {
  /// Creates button theme data with optional style overrides per variant.
  const StreamButtonThemeData({
    this.primary,
    this.secondary,
    this.destructive,
  });

  /// Styles for primary (brand/accent) buttons.
  final StreamButtonTypeStyle? primary;

  /// Styles for secondary (neutral) buttons.
  final StreamButtonTypeStyle? secondary;

  /// Styles for destructive (error/danger) buttons.
  final StreamButtonTypeStyle? destructive;
}

/// Organizes button theme styles by [StreamButtonType] variant.
///
/// See also:
///
///  * [StreamButtonThemeData], which uses this per style variant.
///  * [StreamButtonThemeStyle], for the individual style properties.
@themeGen
@immutable
class StreamButtonTypeStyle with _$StreamButtonTypeStyle {
  /// Creates type-specific button styles.
  const StreamButtonTypeStyle({
    this.solid,
    this.outline,
    this.ghost,
  });

  /// Style for solid (filled) buttons.
  final StreamButtonThemeStyle? solid;

  /// Style for outline (bordered) buttons.
  final StreamButtonThemeStyle? outline;

  /// Style for ghost (borderless) buttons.
  final StreamButtonThemeStyle? ghost;
}

/// Visual styling properties for a single button style/type combination.
///
/// Defines the appearance of buttons including colors and borders.
/// All color properties support state-based styling for interactive feedback
/// (default, hover, pressed, disabled, selected).
///
/// See also:
///
///  * [StreamButtonTypeStyle], which wraps this style per type variant.
///  * [StreamButton], which uses this styling.
class StreamButtonThemeStyle {
  /// Creates button style properties.
  const StreamButtonThemeStyle({
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.overlayColor,
    this.elevation,
    this.iconSize,
  });

  /// The background color for the button.
  ///
  /// Supports state-based colors for different interaction states
  /// (default, hover, pressed, disabled, selected).
  final WidgetStateProperty<Color>? backgroundColor;

  /// The foreground color for the button text and icons.
  ///
  /// Supports state-based colors for different interaction states.
  final WidgetStateProperty<Color>? foregroundColor;

  /// The border color for the button.
  ///
  /// Typically used by outline-type buttons. If null, no border is rendered.
  final WidgetStateProperty<Color>? borderColor;

  /// The overlay color for the button's interaction feedback.
  ///
  /// Supports state-based colors for hover and press states.
  final WidgetStateProperty<Color>? overlayColor;

  /// The elevation of the button.
  ///
  /// Controls the shadow depth. Typically non-zero only for floating buttons.
  final WidgetStateProperty<double>? elevation;

  /// The size of icons inside the button.
  ///
  /// If null, defaults to 20.
  final WidgetStateProperty<double>? iconSize;
}
