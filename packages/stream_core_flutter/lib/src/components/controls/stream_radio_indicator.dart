import 'package:flutter/widgets.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_radio_indicator_theme.dart';
import '../../theme/primitives/stream_colors.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/stream_theme_extensions.dart';

/// A non-interactive radio button that marks the selected entry of a group.
///
/// A circle that is filled with a dot when [selected], and outlined when it
/// is not.
///
/// Use it as a decoration inside a row that owns the tap target and the
/// selection, such as a menu item. It has no tap handling and adds no
/// semantics: the row it sits in is responsible for announcing the entry and
/// whether it is selected. For a control with its own tap target, use
/// [StreamCheckbox.circular] instead.
///
/// {@tool snippet}
///
/// Mark the selected entry of a list:
///
/// ```dart
/// StreamListTile(
///   leading: StreamRadioIndicator(selected: option == selectedOption),
///   title: Text(option.label),
///   onTap: () => setState(() => selectedOption = option),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamRadioIndicatorTheme], for customizing radio indicator appearance.
///  * [StreamRadioIndicatorStyle], for the visual style properties.
class StreamRadioIndicator extends StatelessWidget {
  /// Creates a radio indicator.
  StreamRadioIndicator({super.key, required bool selected}) : props = .new(selected: selected);

  /// The properties that configure this radio indicator.
  final StreamRadioIndicatorProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).radioIndicator;
    if (builder != null) return builder(context, props);
    return DefaultStreamRadioIndicator(props: props);
  }
}

/// Properties for configuring a [StreamRadioIndicator].
///
/// This class holds all the configuration options for a radio indicator,
/// allowing them to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamRadioIndicator], which uses these properties.
///  * [DefaultStreamRadioIndicator], the default implementation.
class StreamRadioIndicatorProps {
  /// Creates properties for a radio indicator.
  const StreamRadioIndicatorProps({required this.selected});

  /// Whether the entry this indicator belongs to is the selected one.
  final bool selected;
}

/// The default implementation of [StreamRadioIndicator].
///
/// Styling is resolved from the theme and the built-in defaults, in that
/// order.
///
/// See also:
///
///  * [StreamRadioIndicator], the public API widget.
///  * [StreamRadioIndicatorProps], which configures this widget.
class DefaultStreamRadioIndicator extends StatelessWidget {
  /// Creates a default radio indicator with the given [props].
  const DefaultStreamRadioIndicator({super.key, required this.props});

  /// The properties that configure this radio indicator.
  final StreamRadioIndicatorProps props;

  @override
  Widget build(BuildContext context) {
    final style = context.streamRadioIndicatorTheme.style;
    final defaults = _StreamRadioIndicatorStyleDefaults(context);

    final effectiveSize = style?.size ?? defaults.size;
    final effectiveDotSize = style?.dotSize ?? defaults.dotSize;
    final effectiveFillColor = style?.fillColor ?? defaults.fillColor;
    final effectiveDotColor = style?.dotColor ?? defaults.dotColor;
    final effectiveSide = style?.side ?? defaults.side;

    final states = {if (props.selected) WidgetState.selected};
    final side = effectiveSide.resolve(states) ?? BorderSide.none;

    return Container(
      width: effectiveSize,
      height: effectiveSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: effectiveFillColor.resolve(states),
        border: Border.fromBorderSide(side),
      ),
      child: Container(
        width: effectiveDotSize,
        height: effectiveDotSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: effectiveDotColor.resolve(states),
        ),
      ),
    );
  }
}

// Provides default values for [StreamRadioIndicatorStyle] based on the
// current [StreamColorScheme].
class _StreamRadioIndicatorStyleDefaults extends StreamRadioIndicatorStyle {
  _StreamRadioIndicatorStyleDefaults(this.context);

  final BuildContext context;
  late final StreamColorScheme _colorScheme = context.streamColorScheme;

  @override
  double get size => 16;

  @override
  double get dotSize => 8;

  @override
  WidgetStateProperty<Color?> get fillColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) return _colorScheme.accentPrimary;
    return StreamColors.transparent;
  });

  @override
  WidgetStateProperty<Color?> get dotColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) return _colorScheme.textOnAccent;
    return StreamColors.transparent;
  });

  @override
  WidgetStateBorderSide get side => WidgetStateBorderSide.resolveWith((states) {
    if (states.contains(WidgetState.selected)) return BorderSide.none;
    return BorderSide(color: _colorScheme.borderDefault);
  });
}
