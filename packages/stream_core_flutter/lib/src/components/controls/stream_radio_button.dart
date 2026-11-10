import 'package:flutter/material.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_radio_button_theme.dart';
import '../../theme/primitives/stream_colors.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/stream_theme_extensions.dart';

/// A radio button styled for the Stream design system.
///
/// [StreamRadioButton] marks one entry of a group as the selected one. A
/// selected radio button is filled with a dot; an unselected one is outlined.
/// It adapts its appearance to the interaction state (hover, pressed,
/// focused, disabled, selected). Visual properties can be customized via
/// [StreamRadioButtonTheme] and [StreamRadioButtonStyle].
///
/// The radio button itself does not maintain any state. When the user taps
/// an unselected radio button, the widget calls [StreamRadioButtonProps.onChanged]
/// with `true`; the parent is expected to rebuild the group with this entry
/// selected. Tapping a radio button that is already selected does nothing,
/// because a radio button is deselected by selecting another entry. When
/// `onChanged` is null the radio button is displayed as disabled.
///
/// Screen readers announce it as a radio button in a group that is either
/// checked or not. Provide a `semanticLabel` to describe the entry.
///
/// Use [StreamRadioButton.decorative] when the radio button only marks the
/// selection inside a row that owns the tap target and the semantics, such
/// as a menu item.
///
/// {@tool snippet}
///
/// A group of radio buttons:
///
/// ```dart
/// Column(
///   children: [
///     for (final option in options)
///       StreamRadioButton(
///         selected: option == selectedOption,
///         onChanged: (_) => setState(() => selectedOption = option),
///         semanticLabel: option.label,
///       ),
///   ],
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// As the leading of a row that handles the tap itself:
///
/// ```dart
/// StreamListTile(
///   leading: StreamRadioButton.decorative(selected: option == selectedOption),
///   title: Text(option.label),
///   selected: option == selectedOption,
///   onTap: () => setState(() => selectedOption = option),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamRadioButtonTheme], for customizing radio button appearance.
///  * [StreamRadioButtonStyle], for the visual style properties.
///  * [StreamRadioButtonSize], for available size variants.
///  * [StreamCheckbox], for selecting any number of entries.
class StreamRadioButton extends StatelessWidget {
  /// Creates a Stream radio button.
  ///
  /// If [onChanged] is null, the radio button is displayed as disabled.
  StreamRadioButton({
    super.key,
    required bool selected,
    ValueChanged<bool>? onChanged,
    StreamRadioButtonSize? size,
    String? semanticLabel,
  }) : props = .new(
         selected: selected,
         onChanged: onChanged,
         size: size,
         semanticLabel: semanticLabel,
       );

  /// Creates a non-interactive radio button that only shows whether
  /// [selected] is true.
  ///
  /// Use this inside a row that owns the tap target, the focus and the
  /// semantics of the entry, such as a menu item or a list tile. It has the
  /// enabled look, takes no focus and adds no semantics, so screen readers
  /// announce the row once instead of the row and the radio button.
  StreamRadioButton.decorative({
    super.key,
    required bool selected,
    StreamRadioButtonSize? size,
  }) : props = .new(selected: selected, size: size, decorative: true);

  /// The props controlling the appearance and behavior of this radio button.
  final StreamRadioButtonProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).radioButton;
    if (builder != null) return builder(context, props);
    return DefaultStreamRadioButton(props: props);
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
class StreamRadioButtonProps {
  /// Creates properties for a radio button.
  const StreamRadioButtonProps({
    required this.selected,
    this.onChanged,
    this.size,
    this.semanticLabel,
    this.decorative = false,
  });

  /// Whether this radio button is the selected entry of its group.
  final bool selected;

  /// Called with `true` when the user selects this radio button.
  ///
  /// It is not called when the radio button is already [selected].
  ///
  /// If null, the radio button is displayed as disabled, unless it is
  /// [decorative].
  final ValueChanged<bool>? onChanged;

  /// The size of the radio button.
  ///
  /// If null, falls back to [StreamRadioButtonStyle.size], then
  /// [StreamRadioButtonSize.lg].
  final StreamRadioButtonSize? size;

  /// The semantic label for the radio button that will be announced by
  /// screen readers.
  ///
  /// This label does not show in the UI. It is ignored when [decorative].
  final String? semanticLabel;

  /// Whether the radio button only shows [selected], without interaction or
  /// semantics of its own.
  ///
  /// See [StreamRadioButton.decorative].
  final bool decorative;
}

/// Default implementation of [StreamRadioButton].
///
/// Renders an interactive radio button using [IconButton] wrapped in
/// [Semantics], or a plain decoration when [StreamRadioButtonProps.decorative]
/// is true. Styling is resolved from widget props, theme, and built-in
/// defaults in that order.
class DefaultStreamRadioButton extends StatelessWidget {
  /// Creates a default radio button.
  const DefaultStreamRadioButton({super.key, required this.props});

  /// The props controlling the appearance and behavior of this radio button.
  final StreamRadioButtonProps props;

  @override
  Widget build(BuildContext context) {
    final radioStyle = context.streamRadioButtonTheme.style;
    final defaults = _StreamRadioButtonStyleDefaults(context);

    final effectiveSize = props.size ?? radioStyle?.size ?? defaults.size;
    final effectiveDotSize = radioStyle?.dotSize ?? _defaultDotSize(effectiveSize);
    final effectiveFillColor = radioStyle?.fillColor ?? defaults.fillColor;
    final effectiveDotColor = radioStyle?.dotColor ?? defaults.dotColor;
    final effectiveOverlayColor = radioStyle?.overlayColor ?? defaults.overlayColor;
    final effectiveSide = radioStyle?.side ?? defaults.side;

    final dimension = effectiveSize.value;

    if (props.decorative) {
      final states = {if (props.selected) WidgetState.selected};
      return ExcludeSemantics(
        child: Container(
          width: dimension,
          height: dimension,
          alignment: Alignment.center,
          decoration: ShapeDecoration(
            shape: CircleBorder(side: effectiveSide.resolve(states) ?? BorderSide.none),
            color: effectiveFillColor.resolve(states),
          ),
          child: _Dot(size: effectiveDotSize, color: effectiveDotColor.resolve(states)),
        ),
      );
    }

    return MergeSemantics(
      child: Semantics(
        label: props.semanticLabel,
        checked: props.selected,
        inMutuallyExclusiveGroup: true,
        child: IconButton(
          onPressed: switch (props.onChanged) {
            final callback? => () {
              if (!props.selected) callback(true);
            },
            _ => null,
          },
          isSelected: props.selected,
          icon: Builder(
            // The button resolves dotColor for the current states and hands
            // it down as the icon color.
            builder: (context) => _Dot(size: effectiveDotSize, color: IconTheme.of(context).color),
          ),
          style: ButtonStyle(
            tapTargetSize: .shrinkWrap,
            visualDensity: .standard,
            fixedSize: .all(.square(dimension)),
            minimumSize: .all(.square(dimension)),
            maximumSize: .all(.square(dimension)),
            padding: .all(.zero),
            shape: .all(const CircleBorder()),
            backgroundColor: effectiveFillColor,
            foregroundColor: effectiveDotColor,
            overlayColor: effectiveOverlayColor,
            side: effectiveSide,
          ),
        ),
      ),
    );
  }

  // The dot of the large size is 10px; the smaller sizes share an 8px dot.
  double _defaultDotSize(StreamRadioButtonSize size) => switch (size) {
    .sm || .md => 8,
    .lg => 10,
  };
}

class _Dot extends StatelessWidget {
  const _Dot({required this.size, required this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
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
  WidgetStateProperty<Color?> get fillColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) {
      if (states.contains(WidgetState.disabled)) return _colorScheme.backgroundDisabled;
      return _colorScheme.accentPrimary;
    }
    return StreamColors.transparent;
  });

  @override
  WidgetStateProperty<Color?> get dotColor => WidgetStateProperty.resolveWith((states) {
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
    if (states.contains(WidgetState.disabled)) {
      if (states.contains(WidgetState.selected)) return BorderSide.none;
      return BorderSide(color: _colorScheme.borderDisabled);
    }
    if (states.contains(WidgetState.focused)) return BorderSide(color: _colorScheme.borderFocus, width: 2);
    if (states.contains(WidgetState.selected)) return BorderSide.none;
    return BorderSide(color: _colorScheme.borderDefault);
  });
}
