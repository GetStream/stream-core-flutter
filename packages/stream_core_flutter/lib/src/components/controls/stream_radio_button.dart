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
/// checked or not. Consider setting [StreamRadioButtonProps.semanticLabel] to
/// describe the entry.
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
    required ValueChanged<bool>? onChanged,
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
@immutable
final class StreamRadioButtonProps {
  /// Creates properties for a radio button.
  ///
  /// A [decorative] radio button takes no [onChanged] or [semanticLabel].
  const StreamRadioButtonProps({
    required this.selected,
    this.onChanged,
    this.size,
    this.semanticLabel,
    this.decorative = false,
  }) : assert(
         !decorative || (onChanged == null && semanticLabel == null),
         'A decorative radio button takes no onChanged or semanticLabel.',
       );

  /// Whether this radio button is the selected entry of its group.
  final bool selected;

  /// Called when the user selects this radio button.
  ///
  /// The value is always `true`: it is not called when the radio button is
  /// already [selected], because a radio button is deselected by selecting
  /// another entry.
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
  /// A custom [StreamComponentBuilders.radioButton] must honor this flag, so
  /// that rows using [StreamRadioButton.decorative] are not announced twice.
  ///
  /// See [StreamRadioButton.decorative].
  final bool decorative;

  /// Creates a copy of these props with the given fields replaced.
  StreamRadioButtonProps copyWith({
    bool? selected,
    ValueChanged<bool>? onChanged,
    StreamRadioButtonSize? size,
    String? semanticLabel,
    bool? decorative,
  }) {
    return StreamRadioButtonProps(
      selected: selected ?? this.selected,
      onChanged: onChanged ?? this.onChanged,
      size: size ?? this.size,
      semanticLabel: semanticLabel ?? this.semanticLabel,
      decorative: decorative ?? this.decorative,
    );
  }
}

/// Default implementation of [StreamRadioButton].
///
/// Renders an interactive radio button, or a non-interactive one when
/// [StreamRadioButtonProps.decorative] is true. The size comes from
/// [StreamRadioButtonProps.size], then the theme, then
/// [StreamRadioButtonSize.lg]; every other style property comes from the
/// theme, falling back to the built-in default for each state.
class DefaultStreamRadioButton extends StatelessWidget {
  /// Creates a default radio button.
  const DefaultStreamRadioButton({super.key, required this.props});

  /// The props controlling the appearance and behavior of this radio button.
  final StreamRadioButtonProps props;

  @override
  Widget build(BuildContext context) {
    final radioStyle = context.streamRadioButtonTheme.style;
    final defaults = _StreamRadioButtonStyleDefaults(context);

    final size = props.size ?? radioStyle?.size ?? defaults.size;

    // The button never sees WidgetState.selected: IconButton.isSelected would
    // also mark the node as "selected" for screen readers, on top of
    // "checked". The selected state is added here instead.
    WidgetStateProperty<T?> withSelected<T>(WidgetStateProperty<T?>? themed, WidgetStateProperty<T?> fallback) {
      return WidgetStateProperty.resolveWith((states) {
        final effective = {...states, if (props.selected) WidgetState.selected};
        return themed?.resolve(effective) ?? fallback.resolve(effective);
      });
    }

    final fillColor = withSelected(radioStyle?.fillColor, defaults.fillColor);
    final dotColor = withSelected(radioStyle?.dotColor, defaults.dotColor);
    final overlayColor = withSelected(radioStyle?.overlayColor, defaults.overlayColor);
    final themedSide = withSelected(radioStyle?.side, defaults.side);

    if (props.decorative) {
      const states = <WidgetState>{};
      return ExcludeSemantics(
        child: Container(
          width: size.diameter,
          height: size.diameter,
          alignment: Alignment.center,
          decoration: ShapeDecoration(
            shape: CircleBorder(side: themedSide.resolve(states) ?? BorderSide.none),
            color: fillColor.resolve(states),
          ),
          child: _Dot(size: size.dotDiameter, color: dotColor.resolve(states)),
        ),
      );
    }

    // The focus ring replaces the border whatever the theme sets, so a themed
    // side never hides keyboard focus.
    final side = WidgetStateBorderSide.resolveWith((states) {
      if (states.contains(WidgetState.focused)) return defaults.focusSide;
      return themedSide.resolve(states) ?? BorderSide.none;
    });

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
          icon: Builder(
            // The button resolves dotColor for the current states and hands
            // it down as the icon color.
            builder: (context) => _Dot(size: size.dotDiameter, color: IconTheme.of(context).color),
          ),
          style: ButtonStyle(
            tapTargetSize: .shrinkWrap,
            visualDensity: .standard,
            fixedSize: .all(.square(size.diameter)),
            minimumSize: .all(.square(size.diameter)),
            maximumSize: .all(.square(size.diameter)),
            padding: .all(.zero),
            shape: .all(const CircleBorder()),
            backgroundColor: fillColor,
            foregroundColor: dotColor,
            overlayColor: overlayColor,
            side: side,
          ),
        ),
      ),
    );
  }
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

  // Drawn in place of side while the radio button has keyboard focus.
  BorderSide get focusSide => BorderSide(color: _colorScheme.borderFocus, width: 2);

  @override
  WidgetStateBorderSide get side => WidgetStateBorderSide.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) {
      if (states.contains(WidgetState.selected)) return BorderSide.none;
      return BorderSide(color: _colorScheme.borderDisabled);
    }
    if (states.contains(WidgetState.selected)) return BorderSide.none;
    return BorderSide(color: _colorScheme.borderDefault);
  });
}
