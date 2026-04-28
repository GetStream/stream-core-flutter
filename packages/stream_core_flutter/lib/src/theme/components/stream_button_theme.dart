import 'package:flutter/material.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';
import '../widget_state_utils.dart';

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
///     onPressed: () {},
///     child: Text('Submit'),
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

  /// Creates button theme data that applies [style] to every style variant.
  ///
  /// [primary], [secondary], and [destructive] are all set to [style]. Useful
  /// when scoping a [StreamButtonTheme] to a slot that should override every
  /// button regardless of its configured [StreamButtonStyle].
  const StreamButtonThemeData.all(
    StreamButtonTypeStyle style,
  ) : primary = style,
      secondary = style,
      destructive = style;

  /// Styles for primary (brand/accent) buttons.
  final StreamButtonTypeStyle? primary;

  /// Styles for secondary (neutral) buttons.
  final StreamButtonTypeStyle? secondary;

  /// Styles for destructive (error/danger) buttons.
  final StreamButtonTypeStyle? destructive;

  /// Linearly interpolate between two [StreamButtonThemeData] objects.
  static StreamButtonThemeData? lerp(
    StreamButtonThemeData? a,
    StreamButtonThemeData? b,
    double t,
  ) => _$StreamButtonThemeData.lerp(a, b, t);
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

  /// Creates type-specific button styles that apply [style] to every type.
  ///
  /// [solid], [outline], and [ghost] are all set to [style]. Useful when
  /// scoping a [StreamButtonTheme] to a slot that should override every
  /// button regardless of its configured [StreamButtonType].
  const StreamButtonTypeStyle.all(
    StreamButtonThemeStyle style,
  ) : solid = style,
      outline = style,
      ghost = style;

  /// Style for solid (filled) buttons.
  final StreamButtonThemeStyle? solid;

  /// Style for outline (bordered) buttons.
  final StreamButtonThemeStyle? outline;

  /// Style for ghost (borderless) buttons.
  final StreamButtonThemeStyle? ghost;

  /// Linearly interpolate between two [StreamButtonTypeStyle] objects.
  static StreamButtonTypeStyle? lerp(
    StreamButtonTypeStyle? a,
    StreamButtonTypeStyle? b,
    double t,
  ) => _$StreamButtonTypeStyle.lerp(a, b, t);
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
@themeGen
@immutable
class StreamButtonThemeStyle with _$StreamButtonThemeStyle {
  /// Creates button style properties.
  ///
  /// All color properties are [WidgetStateProperty]-based for full
  /// state-level control. For a simpler API that accepts plain values and
  /// builds state properties internally, use [StreamButtonThemeStyle.from].
  const StreamButtonThemeStyle({
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.overlayColor,
    this.elevation,
    this.iconSize,
    this.textStyle,
    this.shape,
    this.padding,
    this.fixedSize,
    this.minimumSize,
    this.maximumSize,
    this.alignment,
    this.tapTargetSize,
  });

  /// Creates a [StreamButtonThemeStyle] from simple values.
  ///
  /// This is a convenience factory that wraps plain colors into
  /// [WidgetStateProperty] values, similar to how Flutter's
  /// `TextButton.styleFrom` works.
  ///
  /// State-specific parameters (prefixed with `disabled`, `hovered`, or
  /// `pressed`) take precedence for their respective states; unprefixed
  /// parameters are used as the default for all other states.
  ///
  /// {@tool snippet}
  ///
  /// Create a solid button style with disabled state:
  ///
  /// ```dart
  /// StreamButtonThemeStyle.from(
  ///   backgroundColor: Colors.blue,
  ///   disabledBackgroundColor: Colors.grey,
  ///   foregroundColor: Colors.white,
  ///   disabledForegroundColor: Colors.white70,
  /// )
  /// ```
  /// {@end-tool}
  factory StreamButtonThemeStyle.from({
    Color? backgroundColor,
    Color? disabledBackgroundColor,
    Color? foregroundColor,
    Color? disabledForegroundColor,
    Color? borderColor,
    Color? disabledBorderColor,
    Color? overlayColor,
    Color? hoveredOverlayColor,
    Color? pressedOverlayColor,
    double? elevation,
    double? iconSize,
    TextStyle? textStyle,
    OutlinedBorder? shape,
    EdgeInsetsGeometry? padding,
    Size? fixedSize,
    Size? minimumSize,
    Size? maximumSize,
    AlignmentGeometry? alignment,
    MaterialTapTargetSize? tapTargetSize,
  }) {
    return StreamButtonThemeStyle(
      backgroundColor: WidgetStateUtils.resolveWith(backgroundColor, null, disabledBackgroundColor),
      foregroundColor: WidgetStateUtils.resolveWith(foregroundColor, null, disabledForegroundColor),
      borderColor: WidgetStateUtils.resolveWith(borderColor, null, disabledBorderColor),
      overlayColor: WidgetStateUtils.resolveOverlay(overlayColor, hoveredOverlayColor, pressedOverlayColor),
      elevation: WidgetStateUtils.allOrNull(elevation),
      iconSize: WidgetStateUtils.allOrNull(iconSize),
      textStyle: WidgetStateUtils.allOrNull(textStyle),
      shape: WidgetStateUtils.allOrNull(shape),
      padding: WidgetStateUtils.allOrNull(padding),
      fixedSize: WidgetStateUtils.allOrNull(fixedSize),
      minimumSize: WidgetStateUtils.allOrNull(minimumSize),
      maximumSize: WidgetStateUtils.allOrNull(maximumSize),
      alignment: alignment,
      tapTargetSize: tapTargetSize,
    );
  }

  /// The background color for the button.
  ///
  /// Supports state-based colors for different interaction states
  /// (default, hover, pressed, disabled, selected).
  final WidgetStateProperty<Color?>? backgroundColor;

  /// The foreground color for the button text and icons.
  ///
  /// Supports state-based colors for different interaction states.
  final WidgetStateProperty<Color?>? foregroundColor;

  /// The border color for the button.
  ///
  /// Typically used by outline-type buttons. If null, no border is rendered.
  final WidgetStateProperty<Color?>? borderColor;

  /// The overlay color for the button's interaction feedback.
  ///
  /// Supports state-based colors for hover and press states.
  final WidgetStateProperty<Color?>? overlayColor;

  /// The elevation of the button.
  ///
  /// Controls the shadow depth. Typically non-zero only for floating buttons.
  final WidgetStateProperty<double?>? elevation;

  /// The size of icons inside the button.
  ///
  /// If null, defaults to 20.
  final WidgetStateProperty<double?>? iconSize;

  /// The text style for the button label.
  ///
  /// Supports state-based text styles for different interaction states.
  final WidgetStateProperty<TextStyle?>? textStyle;

  /// The shape of the button.
  ///
  /// If null, icon buttons default to [CircleBorder] and label buttons
  /// default to [RoundedSuperellipseBorder].
  final WidgetStateProperty<OutlinedBorder?>? shape;

  /// The padding inside the button.
  ///
  /// If null, icon buttons default to [EdgeInsets.zero] and label buttons
  /// default to horizontal padding based on [StreamSpacing.md].
  final WidgetStateProperty<EdgeInsetsGeometry?>? padding;

  /// The button's size.
  ///
  /// This size is still constrained by [minimumSize] and [maximumSize].
  /// Fixed size dimensions whose value is [double.infinity] are ignored.
  ///
  /// If null, defaults to the value derived from [StreamButtonProps.size].
  final WidgetStateProperty<Size?>? fixedSize;

  /// The minimum size of the button itself.
  ///
  /// The [StreamButtonProps.size] is constrained to be at least as large
  /// as this value. Defaults to [Size.zero].
  final WidgetStateProperty<Size?>? minimumSize;

  /// The maximum size of the button itself.
  ///
  /// The [StreamButtonProps.size] is constrained to be no larger
  /// than this value. Defaults to [Size.infinite].
  final WidgetStateProperty<Size?>? maximumSize;

  /// The alignment of the button's child.
  ///
  /// Typically buttons are sized to be just big enough to contain the child
  /// and its padding. If the button's size is constrained to a fixed size,
  /// this property defines how the child is aligned within the available
  /// space.
  ///
  /// If null, defaults to [Alignment.center].
  final AlignmentGeometry? alignment;

  /// The minimum tap target size of the button.
  ///
  /// If null, defaults to [MaterialTapTargetSize.padded].
  final MaterialTapTargetSize? tapTargetSize;

  /// Linearly interpolate between two [StreamButtonThemeStyle] objects.
  static StreamButtonThemeStyle? lerp(
    StreamButtonThemeStyle? a,
    StreamButtonThemeStyle? b,
    double t,
  ) => _$StreamButtonThemeStyle.lerp(a, b, t);
}
