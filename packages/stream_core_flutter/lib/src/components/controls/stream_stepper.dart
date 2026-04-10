import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_button_theme.dart';
import '../../theme/components/stream_stepper_theme.dart';
import '../../theme/components/stream_text_input_theme.dart';
import '../../theme/primitives/stream_spacing.dart';
import '../../theme/stream_theme_extensions.dart';
import '../buttons/stream_button.dart';
import '../common/stream_text_input.dart';

/// A numeric stepper control styled for the Stream design system.
///
/// [StreamStepper] displays a row with a decrement button, an editable numeric
/// text field, and an increment button. The buttons automatically disable at
/// the [min] and [max] bounds.
///
/// The stepper does not maintain its own state. When the user taps a button or
/// edits the text field, it calls [onChanged] with the new value. The parent
/// widget is responsible for rebuilding the stepper with the updated [value].
///
/// {@tool snippet}
///
/// Basic stepper:
///
/// ```dart
/// StreamStepper(
///   value: count,
///   onChanged: (value) => setState(() => count = value),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Stepper with custom bounds:
///
/// ```dart
/// StreamStepper(
///   value: count,
///   min: 1,
///   max: 10,
///   onChanged: (value) => setState(() => count = value),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Disabled stepper:
///
/// ```dart
/// StreamStepper(
///   value: 5,
///   onChanged: null,
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamStepperTheme], for customizing stepper appearance.
///  * [StreamStepperStyle], for the visual style properties.
class StreamStepper extends StatelessWidget {
  /// Creates a Stream stepper.
  StreamStepper({
    super.key,
    required int value,
    required ValueChanged<int>? onChanged,
    int min = 0,
    int max = 99,
    StreamStepperStyle? style,
  }) : props = .new(
         value: value,
         onChanged: onChanged,
         min: min,
         max: max,
         style: style,
       );

  /// The props controlling the appearance and behavior of this stepper.
  final StreamStepperProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).stepper;
    if (builder != null) return builder(context, props);
    return DefaultStreamStepper(props: props);
  }
}

/// Properties for configuring a [StreamStepper].
///
/// This class holds all the configuration options for a stepper,
/// allowing them to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamStepper], which uses these properties.
///  * [DefaultStreamStepper], the default implementation.
class StreamStepperProps {
  /// Creates properties for a stepper.
  const StreamStepperProps({
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 99,
    this.style,
  });

  /// The current integer value displayed in the stepper.
  final int value;

  /// Called when the value changes via button tap or text editing.
  ///
  /// If null, the stepper will be displayed as disabled.
  final ValueChanged<int>? onChanged;

  /// The minimum allowed value (inclusive).
  ///
  /// The decrement button is disabled when [value] equals [min].
  /// Defaults to 0.
  final int min;

  /// The maximum allowed value (inclusive).
  ///
  /// The increment button is disabled when [value] equals [max].
  /// Defaults to 99.
  final int max;

  /// Per-instance style overrides.
  ///
  /// Values here take precedence over [StreamStepperTheme].
  final StreamStepperStyle? style;
}

/// Default implementation of [StreamStepper].
///
/// Renders a horizontal row containing two [StreamButton.icon] instances
/// (decrement and increment) with an editable [StreamTextInput] between them.
///
/// Button styling is fully delegated to [StreamButtonTheme]; only the text
/// input area is styled by [StreamStepperTheme].
///
/// See also:
///
///  * [StreamStepper], the public widget that delegates to this.
///  * [StreamStepperProps], the configuration properties.
class DefaultStreamStepper extends StatefulWidget {
  /// Creates a default stepper.
  const DefaultStreamStepper({super.key, required this.props});

  /// The props controlling the appearance and behavior of this stepper.
  final StreamStepperProps props;

  @override
  State<DefaultStreamStepper> createState() => _DefaultStreamStepperState();
}

class _DefaultStreamStepperState extends State<DefaultStreamStepper> {
  late final TextEditingController _controller;

  StreamStepperProps get props => widget.props;
  bool get _isEnabled => props.onChanged != null;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: props.value.toString());
  }

  @override
  void didUpdateWidget(DefaultStreamStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.props.value != props.value) {
      _controller.text = props.value.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _decrement() {
    final newValue = math.max(props.min, props.value - 1);
    if (newValue != props.value) props.onChanged?.call(newValue);
  }

  void _increment() {
    final newValue = math.min(props.max, props.value + 1);
    if (newValue != props.value) props.onChanged?.call(newValue);
  }

  @override
  Widget build(BuildContext context) {
    final icons = context.streamIcons;
    final style = props.style;
    final themeStyle = context.streamStepperTheme.style;
    final defaults = _StreamStepperDefaults(context);

    final canDecrement = _isEnabled && props.value > props.min;
    final canIncrement = _isEnabled && props.value < props.max;

    final effectiveButtonStyle = style?.buttonStyle ?? themeStyle?.buttonStyle ?? defaults.buttonStyle;
    final effectiveInputStyle = style?.inputStyle ?? themeStyle?.inputStyle ?? defaults.inputStyle;
    final effectiveSpacing = style?.spacing ?? themeStyle?.spacing ?? defaults.spacing;

    return Row(
      mainAxisSize: .min,
      spacing: effectiveSpacing,
      children: [
        StreamButton.icon(
          icon: icons.minus20,
          style: .secondary,
          type: .outline,
          themeStyle: effectiveButtonStyle,
          onTap: canDecrement ? _decrement : null,
        ),
        StreamTextInput(
          controller: _controller,
          readOnly: true,
          enabled: _isEnabled,
          textAlign: TextAlign.center,
          style: effectiveInputStyle,
        ),
        StreamButton.icon(
          icon: icons.plus20,
          style: .secondary,
          type: .outline,
          themeStyle: effectiveButtonStyle,
          onTap: canIncrement ? _increment : null,
        ),
      ],
    );
  }
}

// Default theme values for [StreamStepper].
//
// These defaults are used when no explicit value is provided via
// [StreamStepperStyle] or [StreamStepperThemeData].
class _StreamStepperDefaults extends StreamStepperStyle {
  _StreamStepperDefaults(this.context);

  final BuildContext context;

  late final StreamSpacing _spacing = context.streamSpacing;

  @override
  double get spacing => _spacing.xxs;

  @override
  StreamButtonThemeStyle? get buttonStyle => .from(tapTargetSize: .shrinkWrap);

  @override
  StreamTextInputStyle get inputStyle => const .collapsed(constraints: .tightFor(width: 40, height: 40));
}
