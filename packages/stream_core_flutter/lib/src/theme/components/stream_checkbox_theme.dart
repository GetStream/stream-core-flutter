import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

import '../stream_theme.dart';

part 'stream_checkbox_theme.g.theme.dart';

/// Predefined sizes for [StreamCheckbox].
///
/// Each size corresponds to a specific dimension in logical pixels.
///
/// See also:
///
///  * [StreamCheckboxStyle.size], for setting a global default size.
enum StreamCheckboxSize {
  /// Small checkbox (20px).
  sm(20),

  /// Medium checkbox (24px).
  md(24)
  ;

  /// Constructs a [StreamCheckboxSize] with the given dimension.
  const StreamCheckboxSize(this.value);

  /// The dimension of the checkbox in logical pixels.
  final double value;
}

/// Applies a checkbox theme to descendant [StreamCheckbox] widgets.
///
/// Wrap a subtree with [StreamCheckboxTheme] to override checkbox styling.
/// Access the merged theme using [BuildContext.streamCheckboxTheme].
///
/// {@tool snippet}
///
/// Override checkbox styling for a specific section:
///
/// ```dart
/// StreamCheckboxTheme(
///   data: StreamCheckboxThemeData(
///     style: StreamCheckboxStyle(
///       size: StreamCheckboxSize.sm,
///     ),
///   ),
///   child: StreamCheckbox(
///     value: true,
///     onChanged: (value) {},
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamCheckboxThemeData], which describes the checkbox theme.
///  * [StreamCheckbox], the widget affected by this theme.
class StreamCheckboxTheme extends InheritedTheme {
  /// Creates a checkbox theme that controls descendant checkboxes.
  const StreamCheckboxTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The checkbox theme data for descendant widgets.
  final StreamCheckboxThemeData data;

  /// Returns the [StreamCheckboxThemeData] merged from local and global themes.
  ///
  /// Local values from the nearest [StreamCheckboxTheme] ancestor take
  /// precedence over global values from [StreamTheme.of].
  static StreamCheckboxThemeData of(BuildContext context) {
    final localTheme = context.dependOnInheritedWidgetOfExactType<StreamCheckboxTheme>();
    return StreamTheme.of(context).checkboxTheme.merge(localTheme?.data);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return StreamCheckboxTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(StreamCheckboxTheme oldWidget) => data != oldWidget.data;
}

/// Theme data for customizing [StreamCheckbox] widgets.
///
/// {@tool snippet}
///
/// Customize checkbox appearance globally via [StreamTheme]:
///
/// ```dart
/// StreamTheme(
///   data: StreamThemeData(
///     checkboxTheme: StreamCheckboxThemeData(
///       style: StreamCheckboxStyle(
///         size: StreamCheckboxSize.sm,
///         fillColor: WidgetStateProperty.resolveWith((states) {
///           if (states.contains(WidgetState.selected)) {
///             return Colors.green;
///           }
///           return Colors.transparent;
///         }),
///       ),
///     ),
///   ),
///   child: MyApp(),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamCheckboxTheme], for overriding theme in a widget subtree.
@themeGen
@immutable
class StreamCheckboxThemeData with _$StreamCheckboxThemeData {
  /// Creates checkbox theme data with optional style overrides.
  const StreamCheckboxThemeData({this.style});

  /// The visual styling for checkboxes.
  ///
  /// Contains size, fill color, check color, overlay color, border, and shape.
  final StreamCheckboxStyle? style;

  /// Linearly interpolate between two [StreamCheckboxThemeData] objects.
  static StreamCheckboxThemeData? lerp(
    StreamCheckboxThemeData? a,
    StreamCheckboxThemeData? b,
    double t,
  ) => _$StreamCheckboxThemeData.lerp(a, b, t);
}

/// Visual styling properties for checkboxes.
///
/// Defines the appearance of checkboxes including size, colors, border, and
/// shape. All color properties support state-based styling via
/// [WidgetStateProperty] for interactive feedback (default, hover, pressed,
/// disabled, selected).
///
/// This follows the same pattern as Flutter's [CheckboxThemeData] where
/// `fillColor`, `checkColor`, and `overlayColor` are state-dependent.
///
/// See also:
///
///  * [StreamCheckboxThemeData], which wraps this style for theming.
///  * [StreamCheckbox], which uses this styling.
@themeGen
@immutable
class StreamCheckboxStyle with _$StreamCheckboxStyle {
  /// Creates checkbox style properties.
  const StreamCheckboxStyle({
    this.size,
    this.checkSize,
    this.fillColor,
    this.checkColor,
    this.overlayColor,
    this.shape,
    WidgetStateProperty<BorderSide?>? side,
  }) : side = side as WidgetStateBorderSide?;

  /// The size of checkboxes.
  ///
  /// Falls back to [StreamCheckboxSize.md].
  final StreamCheckboxSize? size;

  /// The size of the checkmark icon inside the checkbox.
  ///
  /// If null, defaults to 16.
  final double? checkSize;

  /// The color that fills the checkbox, resolved per [WidgetState].
  ///
  /// Resolves based on:
  ///  * [WidgetState.selected] -- accent color when checked.
  ///  * [WidgetState.disabled] + [WidgetState.selected] -- disabled background.
  ///
  /// Transparent when not selected, giving a border-only appearance.
  final WidgetStateProperty<Color?>? fillColor;

  /// The color of the checkmark icon, resolved per [WidgetState].
  ///
  /// Resolves based on:
  ///  * [WidgetState.selected] -- high-contrast color against the fill.
  ///  * [WidgetState.disabled] + [WidgetState.selected] -- muted color.
  ///
  /// Transparent when not selected so the icon is hidden.
  final WidgetStateProperty<Color?>? checkColor;

  /// The overlay color for interaction feedback, resolved per [WidgetState].
  ///
  /// Resolves based on:
  ///  * [WidgetState.hovered] -- hover overlay.
  ///  * [WidgetState.pressed] -- pressed overlay.
  final WidgetStateProperty<Color?>? overlayColor;

  /// The shape of the checkbox.
  ///
  /// Defaults to a [RoundedRectangleBorder] with the design system's
  /// small radius.
  final OutlinedBorder? shape;

  /// The border of the checkbox, resolved per [WidgetState].
  ///
  /// Visible when unchecked, [BorderSide.none] when checked, and uses the
  /// disabled border color when disabled.
  final WidgetStateBorderSide? side;

  /// Linearly interpolate between two [StreamCheckboxStyle] objects.
  static StreamCheckboxStyle? lerp(
    StreamCheckboxStyle? a,
    StreamCheckboxStyle? b,
    double t,
  ) => _$StreamCheckboxStyle.lerp(a, b, t);
}
