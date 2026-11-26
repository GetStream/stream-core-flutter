import 'package:flutter/material.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_radio_button_theme.dart';
import '../../theme/primitives/stream_colors.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/stream_theme_extensions.dart';

/// A control for selecting one entry from a group.
///
/// Each [StreamRadioButton] represents one value of type [T]. Place the
/// radio buttons of a group under a [RadioGroup] of the same type: the group
/// holds the selected value and is called when the user selects another one.
/// A selected radio button is filled with an indicator; an unselected one is
/// outlined. It adapts its appearance to the interaction state (hover,
/// pressed, focused, disabled, selected). Visual properties can be customized
/// via [StreamRadioButtonTheme] and [StreamRadioButtonStyle].
///
/// Screen readers announce it as a radio button in a group that is either
/// checked or not. Tab moves focus into the group and the arrow keys move the
/// selection within it. Consider setting [StreamRadioButtonProps.semanticLabel]
/// to describe the entry.
///
/// To only mark the selected entry inside a row that handles the tap and the
/// semantics itself, such as a menu item, use [StreamRadioIndicator] instead.
///
/// {@tool snippet}
///
/// A group of radio buttons:
///
/// ```dart
/// RadioGroup<AudioDevice>(
///   groupValue: selectedDevice,
///   onChanged: (device) => setState(() => selectedDevice = device),
///   child: Column(
///     children: [
///       for (final device in devices)
///         StreamRadioButton(value: device, semanticLabel: device.name),
///     ],
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [RadioGroup], which holds the selected value of a group.
///  * [StreamRadioIndicator], for marking the selection in a row that owns the
///    tap.
///  * [StreamRadioButtonTheme], for customizing radio button appearance.
///  * [StreamRadioButtonSize], for available size variants.
///  * [StreamCheckbox], for selecting any number of entries.
class StreamRadioButton<T> extends StatelessWidget {
  /// Creates a Stream radio button for [value].
  ///
  /// The radio button is selected when [value] equals the group value of the
  /// nearest [RadioGroup] of type [T].
  StreamRadioButton({
    super.key,
    required T value,
    bool? enabled,
    bool toggleable = false,
    FocusNode? focusNode,
    bool autofocus = false,
    StreamRadioButtonSize? size,
    String? semanticLabel,
  }) : props = .new(
         value: value,
         enabled: enabled,
         toggleable: toggleable,
         focusNode: focusNode,
         autofocus: autofocus,
         size: size,
         semanticLabel: semanticLabel,
       );

  /// The props controlling the appearance and behavior of this radio button.
  final StreamRadioButtonProps<T> props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).radioButton;
    if (builder != null) return builder(context, props);
    return DefaultStreamRadioButton<T>(props: props);
  }
}

/// Properties for configuring a [StreamRadioButton].
///
/// This class holds all the configuration options for a radio button,
/// allowing them to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamRadioButton], which uses these properties.
///  * [DefaultStreamRadioButton], the default implementation.
@immutable
final class StreamRadioButtonProps<T extends Object?> {
  /// Creates properties for a radio button.
  const StreamRadioButtonProps({
    required this.value,
    this.enabled,
    this.toggleable = false,
    this.focusNode,
    this.autofocus = false,
    this.size,
    this.semanticLabel,
  });

  /// The value this radio button represents in its [RadioGroup].
  ///
  /// The radio button is selected when this equals the group value.
  final T value;

  /// Whether the radio button responds to input.
  ///
  /// If null, the radio button is enabled when a [RadioGroup] of type [T] is
  /// above it. A disabled radio button still shows whether it is selected.
  final bool? enabled;

  /// Whether tapping the selected radio button deselects it.
  ///
  /// When deselected, the [RadioGroup] is called with null. Defaults to false,
  /// so a radio button is only deselected by selecting another entry.
  final bool toggleable;

  /// An optional focus node to use as the focus node for this radio button.
  final FocusNode? focusNode;

  /// Whether this radio button is focused when nothing else is.
  final bool autofocus;

  /// The size of the radio button.
  ///
  /// If null, falls back to [StreamRadioButtonStyle.size], then
  /// [StreamRadioButtonSize.lg].
  final StreamRadioButtonSize? size;

  /// The semantic label for the radio button that will be announced by
  /// screen readers.
  ///
  /// This label does not show in the UI.
  final String? semanticLabel;

  // Builds the RawRadio where T is still the type the props were created with:
  // a builder only sees StreamRadioButtonProps<Object?>, and the RadioGroup
  // lookup matches on the exact type.
  Widget _buildRawRadio(
    BuildContext context, {
    required FocusNode focusNode,
    required RadioBuilder builder,
  }) {
    final registry = RadioGroup.maybeOf<T>(context);
    assert(
      enabled != true || registry != null,
      'StreamRadioButton<$T> is enabled but has no RadioGroup<$T> above it.',
    );
    return RawRadio<T>(
      value: value,
      mouseCursor: WidgetStateMouseCursor.adaptiveClickable,
      toggleable: toggleable,
      focusNode: focusNode,
      autofocus: autofocus,
      groupRegistry: registry,
      enabled: (enabled ?? true) && registry != null,
      builder: builder,
    );
  }
}

/// Default implementation of [StreamRadioButton].
///
/// The size comes from [StreamRadioButtonProps.size], then the theme, then
/// [StreamRadioButtonSize.lg]; every other style property comes from the
/// theme, falling back to the built-in default for each state.
class DefaultStreamRadioButton<T> extends StatefulWidget {
  /// Creates a default radio button.
  const DefaultStreamRadioButton({super.key, required this.props});

  /// The props controlling the appearance and behavior of this radio button.
  final StreamRadioButtonProps<T> props;

  @override
  State<DefaultStreamRadioButton<T>> createState() => _DefaultStreamRadioButtonState<T>();
}

class _DefaultStreamRadioButtonState<T> extends State<DefaultStreamRadioButton<T>> {
  FocusNode? _internalFocusNode;
  FocusNode get _focusNode => widget.props.focusNode ?? (_internalFocusNode ??= FocusNode());

  @override
  void dispose() {
    _internalFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final props = widget.props;
    return Semantics(
      label: props.semanticLabel,
      child: props._buildRawRadio(
        context,
        focusNode: _focusNode,
        // RawRadio runs the 200ms selection animation in state.position.
        builder: (context, state) => ListenableBuilder(
          listenable: state.position,
          builder: (context, _) => _StreamRadio(
            size: props.size,
            progress: state.position.value,
            states: {...state.states, if (state.downPosition != null) WidgetState.pressed},
          ),
        ),
      ),
    );
  }
}

/// A non-interactive radio button that only shows whether [selected] is true.
///
/// Use it inside a row that owns the tap target, the focus and the semantics
/// of the entry, such as a menu item or a list tile. It looks like a
/// [StreamRadioButton], enabled or disabled as [enabled] says, and follows the
/// same [StreamRadioButtonTheme], but takes no focus and adds no semantics, so
/// screen readers announce the row once instead of the row and the indicator.
///
/// {@tool snippet}
///
/// As the leading of a row that handles the tap itself:
///
/// ```dart
/// StreamListTile(
///   leading: StreamRadioIndicator(selected: device == selectedDevice),
///   title: Text(device.name),
///   selected: device == selectedDevice,
///   onTap: () => setState(() => selectedDevice = device),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamRadioButton], the interactive radio button.
class StreamRadioIndicator extends StatelessWidget {
  /// Creates a radio indicator.
  const StreamRadioIndicator({super.key, required this.selected, this.enabled = true, this.size});

  /// Whether the indicator shows the selected look.
  ///
  /// A change animates over 200ms, like [StreamRadioButton].
  final bool selected;

  /// Whether the indicator shows the enabled look.
  ///
  /// Set to false when the row it sits in is disabled.
  final bool enabled;

  /// The size of the indicator.
  ///
  /// If null, falls back to [StreamRadioButtonStyle.size], then
  /// [StreamRadioButtonSize.lg].
  final StreamRadioButtonSize? size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: selected ? 1 : 0),
        duration: _kSelectionDuration,
        builder: (context, progress, _) => _StreamRadio(
          size: size,
          progress: progress,
          states: {if (!enabled) WidgetState.disabled},
        ),
      ),
    );
  }
}

// The selection animation of StreamRadioIndicator, matching the one RawRadio
// runs for StreamRadioButton.
const _kSelectionDuration = Duration(milliseconds: 200);

// Paints a radio button for the given interaction states, blended between its
// unselected (progress 0) and selected (progress 1) look.
class _StreamRadio extends StatelessWidget {
  const _StreamRadio({required this.size, required this.progress, required this.states});

  final StreamRadioButtonSize? size;
  final double progress;
  final Set<WidgetState> states;

  @override
  Widget build(BuildContext context) {
    final style = context.streamRadioButtonTheme.style;
    final defaults = _StreamRadioButtonStyleDefaults(context);

    final unselected = {...states}..remove(WidgetState.selected);
    final selected = {...unselected, WidgetState.selected};

    T? resolve<T>(WidgetStateProperty<T?>? themed, WidgetStateProperty<T?> fallback, Set<WidgetState> states) {
      return themed?.resolve(states) ?? fallback.resolve(states);
    }

    // Returns the resolved colors themselves at rest, so a themed color is
    // painted as given rather than as a lerped copy.
    Color? lerpColor(WidgetStateProperty<Color?>? themed, WidgetStateProperty<Color?> fallback) {
      final from = resolve(themed, fallback, unselected);
      final to = resolve(themed, fallback, selected);
      if (progress == 0) return from;
      if (progress == 1) return to;
      return Color.lerp(from, to, progress);
    }

    final effectiveSize = size ?? style?.size ?? defaults.size;
    final effectiveBackgroundColor = lerpColor(style?.backgroundColor, defaults.backgroundColor);
    final effectiveIndicatorColor = lerpColor(style?.indicatorColor, defaults.indicatorColor);
    final effectiveOverlayColor = resolve(style?.overlayColor, defaults.overlayColor, states);
    final effectiveSide = BorderSide.lerp(
      resolve(style?.side, defaults.side, unselected) ?? BorderSide.none,
      resolve(style?.side, defaults.side, selected) ?? BorderSide.none,
      progress,
    );
    final effectiveIndicatorDiameter = effectiveSize.indicatorDiameter * progress;

    return Container(
      width: effectiveSize.diameter,
      height: effectiveSize.diameter,
      decoration: ShapeDecoration(shape: const CircleBorder(), color: effectiveBackgroundColor),
      foregroundDecoration: ShapeDecoration(shape: CircleBorder(side: effectiveSide)),
      child: DecoratedBox(
        decoration: ShapeDecoration(shape: const CircleBorder(), color: effectiveOverlayColor),
        child: Center(
          child: Container(
            width: effectiveIndicatorDiameter,
            height: effectiveIndicatorDiameter,
            decoration: BoxDecoration(shape: BoxShape.circle, color: effectiveIndicatorColor),
          ),
        ),
      ),
    );
  }
}

// Provides default values for [StreamRadioButtonStyle] based on the current
// [StreamColorScheme].
class _StreamRadioButtonStyleDefaults extends StreamRadioButtonStyle {
  _StreamRadioButtonStyleDefaults(this.context);

  final BuildContext context;
  late final StreamColorScheme _colorScheme = context.streamColorScheme;

  @override
  StreamRadioButtonSize get size => .lg;

  @override
  WidgetStateProperty<Color?> get backgroundColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) {
      if (states.contains(WidgetState.disabled)) return _colorScheme.backgroundDisabled;
      return _colorScheme.accentPrimary;
    }
    return StreamColors.transparent;
  });

  @override
  WidgetStateProperty<Color?> get indicatorColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) {
      if (states.contains(WidgetState.disabled)) return _colorScheme.textDisabled;
      return _colorScheme.textOnAccent;
    }
    return StreamColors.transparent;
  });

  @override
  WidgetStateProperty<Color?> get overlayColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.pressed)) return _colorScheme.backgroundPressed;
    if (states.contains(WidgetState.hovered)) return _colorScheme.backgroundHover;
    return StreamColors.transparent;
  });

  @override
  WidgetStateBorderSide get side => WidgetStateBorderSide.resolveWith((states) {
    if (states.contains(WidgetState.focused)) return BorderSide(color: _colorScheme.borderFocus, width: 2);
    if (states.contains(WidgetState.disabled)) {
      if (states.contains(WidgetState.selected)) return BorderSide.none;
      return BorderSide(color: _colorScheme.borderDisabled);
    }
    if (states.contains(WidgetState.selected)) return BorderSide.none;
    return BorderSide(color: _colorScheme.borderDefault);
  });
}
