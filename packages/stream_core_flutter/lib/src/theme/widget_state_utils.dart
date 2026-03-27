import 'package:flutter/widgets.dart';

/// Utility methods for building [WidgetStateProperty] values from simple
/// parameters.
///
/// Provides convenience factories for common state resolution patterns
/// used across Stream design system component styles.
///
/// See also:
///
///  * [StreamCheckboxStyle.from], which uses these helpers.
///  * [StreamButtonThemeStyle.from], which uses these helpers.
mixin WidgetStateUtils {
  /// Returns null if [value] is null, otherwise
  /// `WidgetStatePropertyAll<T>(value)`.
  static WidgetStateProperty<T>? allOrNull<T>(T? value) {
    return value == null ? null : WidgetStatePropertyAll<T>(value);
  }

  /// Returns a [WidgetStateProperty] that resolves to [disabled] when
  /// [WidgetState.disabled], [selected] when [WidgetState.selected],
  /// and [defaultValue] otherwise.
  ///
  /// Returns null if all arguments are null.
  ///
  /// {@tool snippet}
  ///
  /// Create a fill color that is transparent by default, blue when selected,
  /// and grey when disabled:
  ///
  /// ```dart
  /// WidgetStateUtils.resolveWith(Colors.transparent, Colors.blue, Colors.grey)
  /// ```
  /// {@end-tool}
  static WidgetStateProperty<T?>? resolveWith<T>(T? defaultValue, T? selected, T? disabled) {
    if ((defaultValue ?? selected ?? disabled) == null) return null;
    return WidgetStateProperty<T?>.fromMap({
      WidgetState.disabled: disabled,
      WidgetState.selected: selected,
      WidgetState.any: defaultValue,
    });
  }

  /// Returns a [WidgetStateProperty] for overlay colors that resolves to
  /// [pressed] when [WidgetState.pressed], [hovered] when
  /// [WidgetState.hovered], and [defaultValue] otherwise.
  ///
  /// Returns null if all arguments are null.
  ///
  /// {@tool snippet}
  ///
  /// Create an overlay color with different opacities for hover and press:
  ///
  /// ```dart
  /// WidgetStateUtils.resolveOverlay(
  ///   Colors.transparent,
  ///   Colors.blue.withOpacity(0.08),
  ///   Colors.blue.withOpacity(0.1),
  /// )
  /// ```
  /// {@end-tool}
  static WidgetStateProperty<Color?>? resolveOverlay(Color? defaultValue, Color? hovered, Color? pressed) {
    if ((defaultValue ?? hovered ?? pressed) == null) return null;
    return WidgetStateProperty<Color?>.fromMap({
      WidgetState.pressed: pressed,
      WidgetState.hovered: hovered,
      WidgetState.any: defaultValue,
    });
  }

  /// Returns a [WidgetStateBorderSide] that resolves to [disabled] when
  /// [WidgetState.disabled], [selected] when [WidgetState.selected],
  /// and [defaultValue] otherwise.
  ///
  /// Returns null if all arguments are null.
  ///
  /// Uses [WidgetStateBorderSide.resolveWith] because the returned type
  /// must be a [WidgetStateBorderSide] (which extends [BorderSide]).
  ///
  /// {@tool snippet}
  ///
  /// Create a border that is visible by default and hidden when selected:
  ///
  /// ```dart
  /// WidgetStateUtils.resolveSide(
  ///   BorderSide(color: Colors.grey),
  ///   BorderSide.none,
  ///   null,
  /// )
  /// ```
  /// {@end-tool}
  static WidgetStateBorderSide? resolveSide(BorderSide? defaultValue, BorderSide? selected, BorderSide? disabled) {
    if ((defaultValue ?? selected ?? disabled) == null) return null;
    return WidgetStateBorderSide.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) return disabled;
      if (states.contains(WidgetState.selected)) return selected;
      return defaultValue;
    });
  }
}
