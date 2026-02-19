import 'package:flutter/material.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_checkbox_theme.dart';
import '../../theme/primitives/stream_colors.dart';
import '../../theme/primitives/stream_radius.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/stream_theme_extensions.dart';

/// A checkbox styled for the Stream design system.
///
/// [StreamCheckbox] displays a toggleable check indicator that adapts its
/// appearance based on interaction state (hover, pressed, disabled, selected).
/// Visual properties can be customized via [StreamCheckboxTheme] and
/// [StreamCheckboxStyle].
///
/// The checkbox itself does not maintain any state. Instead, when the state of
/// the checkbox changes, the widget calls the [onChanged] callback. Most
/// widgets that use a checkbox will listen for the [onChanged] callback and
/// rebuild the checkbox with a new [value] to update the visual appearance.
///
/// Use [StreamCheckbox.circular] for a circle-shaped variant commonly used in
/// single-selection (radio-like) patterns.
///
/// The widget wraps its content with [Semantics] for accessibility support.
/// Provide a [semanticLabel] to give screen readers a meaningful description.
///
/// {@tool snippet}
///
/// Basic checkbox:
///
/// ```dart
/// StreamCheckbox(
///   value: isChecked,
///   onChanged: (value) => setState(() => isChecked = value),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Small disabled checkbox:
///
/// ```dart
/// StreamCheckbox(
///   value: true,
///   size: StreamCheckboxSize.sm,
///   onChanged: null,
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamCheckboxTheme], for customizing checkbox appearance.
///  * [StreamCheckboxStyle], for the visual style properties.
///  * [StreamCheckboxSize], for available size variants.
class StreamCheckbox extends StatelessWidget {
  /// Creates a Stream checkbox.
  StreamCheckbox({
    super.key,
    required bool value,
    required ValueChanged<bool>? onChanged,
    StreamCheckboxSize? size,
    OutlinedBorder? shape,
    String? semanticLabel,
  }) : props = StreamCheckboxProps(
         value: value,
         onChanged: onChanged,
         size: size,
         shape: shape,
         semanticLabel: semanticLabel,
       );

  /// Creates a circular Stream checkbox (radio check).
  ///
  /// This is a convenience constructor that sets the shape to [CircleBorder],
  /// commonly used for single-selection (radio-like) patterns.
  StreamCheckbox.circular({
    super.key,
    required bool value,
    required ValueChanged<bool>? onChanged,
    StreamCheckboxSize? size,
    String? semanticLabel,
  }) : props = StreamCheckboxProps(
         value: value,
         onChanged: onChanged,
         size: size,
         shape: const CircleBorder(),
         semanticLabel: semanticLabel,
       );

  /// The props controlling the appearance and behavior of this checkbox.
  final StreamCheckboxProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.maybeOf(context)?.checkbox;
    if (builder != null) return builder(context, props);
    return DefaultStreamCheckbox(props: props);
  }
}

/// Properties for configuring a [StreamCheckbox].
///
/// This class holds all the configuration options for a checkbox,
/// allowing them to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamCheckbox], which uses these properties.
///  * [DefaultStreamCheckbox], the default implementation.
class StreamCheckboxProps {
  /// Creates properties for a checkbox.
  const StreamCheckboxProps({
    required this.value,
    required this.onChanged,
    this.size,
    this.shape,
    this.semanticLabel,
  });

  /// Whether this checkbox is checked.
  final bool value;

  /// Called when the value of the checkbox should change.
  ///
  /// The checkbox passes the new value to the callback but does not actually
  /// change state until the parent widget rebuilds the checkbox with the new
  /// value.
  ///
  /// If null, the checkbox will be displayed as disabled.
  final ValueChanged<bool>? onChanged;

  /// The size of the checkbox.
  ///
  /// If null, falls back to [StreamCheckboxStyle.size], then
  /// [StreamCheckboxSize.md].
  final StreamCheckboxSize? size;

  /// The shape of the checkbox.
  ///
  /// If null, falls back to [StreamCheckboxStyle.shape], then
  /// the design system defaults.
  final OutlinedBorder? shape;

  /// The semantic label for the checkbox that will be announced by
  /// screen readers.
  ///
  /// This label does not show in the UI.
  final String? semanticLabel;
}

/// Default implementation of [StreamCheckbox].
///
/// Renders a checkbox using [IconButton] wrapped in [Semantics] for
/// accessibility. Styling is resolved from widget props, theme, and
/// built-in defaults in that order.
class DefaultStreamCheckbox extends StatelessWidget {
  /// Creates a default checkbox.
  const DefaultStreamCheckbox({super.key, required this.props});

  /// The props controlling the appearance and behavior of this checkbox.
  final StreamCheckboxProps props;

  @override
  Widget build(BuildContext context) {
    final checkboxStyle = context.streamCheckboxTheme.style;
    final defaults = _StreamCheckboxStyleDefaults(context);

    final effectiveSize = props.size ?? checkboxStyle?.size ?? defaults.size;
    final effectiveCheckSize = checkboxStyle?.checkSize ?? defaults.checkSize;
    final effectiveFillColor = checkboxStyle?.fillColor ?? defaults.fillColor;
    final effectiveCheckColor = checkboxStyle?.checkColor ?? defaults.checkColor;
    final effectiveOverlayColor = checkboxStyle?.overlayColor ?? defaults.overlayColor;
    final effectiveSide = checkboxStyle?.side ?? defaults.side;
    final effectiveShape = props.shape ?? checkboxStyle?.shape ?? defaults.shape;

    final icons = context.streamIcons;
    final dimension = effectiveSize.value;

    return Semantics(
      label: props.semanticLabel,
      checked: props.value,
      child: IconButton(
        onPressed: switch (props.onChanged) {
          final callback? => () => callback(!props.value),
          _ => null,
        },
        isSelected: props.value,
        iconSize: effectiveCheckSize,
        icon: Icon(icons.checkmark2),
        style: ButtonStyle(
          tapTargetSize: .shrinkWrap,
          visualDensity: .standard,
          fixedSize: .all(.square(dimension)),
          minimumSize: .all(.square(dimension)),
          maximumSize: .all(.square(dimension)),
          padding: .all(.zero),
          shape: .all(effectiveShape),
          backgroundColor: effectiveFillColor,
          foregroundColor: effectiveCheckColor,
          overlayColor: effectiveOverlayColor,
          side: effectiveSide,
        ),
      ),
    );
  }
}

// Provides default values for [StreamCheckboxStyle] based on the current
// [StreamColorScheme].
class _StreamCheckboxStyleDefaults extends StreamCheckboxStyle {
  _StreamCheckboxStyleDefaults(this.context);

  final BuildContext context;
  late final StreamColorScheme _colorScheme = context.streamColorScheme;
  late final StreamRadius _radius = context.streamRadius;

  @override
  StreamCheckboxSize get size => .md;

  @override
  double get checkSize => 16;

  @override
  WidgetStateProperty<Color?> get fillColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) {
      if (states.contains(WidgetState.disabled)) return _colorScheme.backgroundDisabled;
      return _colorScheme.accentPrimary;
    }

    return StreamColors.transparent;
  });

  @override
  WidgetStateProperty<Color?> get checkColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) {
      if (states.contains(WidgetState.disabled)) return _colorScheme.textDisabled;
      return _colorScheme.textOnDark;
    }
    return StreamColors.transparent;
  });

  @override
  WidgetStateProperty<Color?> get overlayColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.pressed)) return _colorScheme.statePressed;
    if (states.contains(WidgetState.hovered)) return _colorScheme.stateHover;
    return StreamColors.transparent;
  });

  @override
  WidgetStateBorderSide? get side => WidgetStateBorderSide.resolveWith((states) {
    if (states.contains(WidgetState.selected)) return BorderSide.none;
    if (states.contains(WidgetState.disabled)) return BorderSide(color: _colorScheme.borderDisabled);
    return BorderSide(color: _colorScheme.borderDefault);
  });

  @override
  OutlinedBorder get shape => RoundedRectangleBorder(borderRadius: .all(_radius.sm));
}
