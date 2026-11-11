import 'package:flutter/material.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_switch_theme.dart';
import '../../theme/primitives/stream_colors.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/stream_theme_extensions.dart';

/// A switch styled for the Stream design system.
///
/// [StreamSwitch] displays a platform-adaptive switch that
/// renders as a [CupertinoSwitch] on iOS/macOS and a Material [Switch] on
/// other platforms. Visual properties can be customized via
/// [StreamSwitchTheme] and [StreamSwitchStyle].
///
/// The switch itself does not maintain any state. Instead, when the
/// state of the switch changes, the widget calls the [onChanged] callback.
/// Most widgets that use a switch will listen for the [onChanged]
/// callback and rebuild the switch with a new [value] to update the visual
/// appearance.
///
/// {@tool snippet}
///
/// Basic switch:
///
/// ```dart
/// StreamSwitch(
///   value: isEnabled,
///   onChanged: (value) => setState(() => isEnabled = value),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Disabled switch:
///
/// ```dart
/// StreamSwitch(
///   value: true,
///   onChanged: null,
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamSwitchTheme], for customizing switch appearance.
///  * [StreamSwitchStyle], for the visual style properties.
class StreamSwitch extends StatelessWidget {
  /// Creates a Stream switch.
  StreamSwitch({
    super.key,
    required bool value,
    required ValueChanged<bool>? onChanged,
    StreamSwitchStyle? style,
    String? semanticLabel,
  }) : props = .new(
         value: value,
         onChanged: onChanged,
         style: style,
         semanticLabel: semanticLabel,
       );

  /// The props controlling the appearance and behavior of this switch.
  final StreamSwitchProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).toggleSwitch;
    if (builder != null) return builder(context, props);
    return DefaultStreamSwitch(props: props);
  }
}

/// Properties for configuring a [StreamSwitch].
///
/// This class holds all the configuration options for a switch,
/// allowing them to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamSwitch], which uses these properties.
///  * [DefaultStreamSwitch], the default implementation.
class StreamSwitchProps {
  /// Creates properties for a switch.
  const StreamSwitchProps({
    required this.value,
    required this.onChanged,
    this.style,
    this.semanticLabel,
  });

  /// Whether this switch is on.
  final bool value;

  /// Called when the value of the switch should change.
  ///
  /// The switch passes the new value to the callback but does not
  /// actually change state until the parent widget rebuilds the switch with
  /// the new value.
  ///
  /// If null, the switch will be displayed as disabled.
  final ValueChanged<bool>? onChanged;

  /// Per-instance style overrides.
  ///
  /// Values here take precedence over [StreamSwitchTheme].
  final StreamSwitchStyle? style;

  /// The semantic label for the switch that will be announced by
  /// screen readers.
  ///
  /// This label does not show in the UI.
  final String? semanticLabel;
}

/// Default implementation of [StreamSwitch].
///
/// Renders a platform-adaptive switch using [Switch.adaptive]. Styling is
/// resolved from widget props, theme, and built-in defaults in that order.
///
/// Platform-specific defaults are applied automatically:
///  * iOS/macOS — Cupertino defaults (filled track, white thumb).
///  * Android and others — Material defaults (outlined track when unselected,
///    colored thumb).
class DefaultStreamSwitch extends StatelessWidget {
  /// Creates a default switch.
  const DefaultStreamSwitch({super.key, required this.props});

  /// The props controlling the appearance and behavior of this switch.
  final StreamSwitchProps props;

  @override
  Widget build(BuildContext context) {
    final style = props.style;
    final themeStyle = context.streamSwitchTheme.style;

    final defaults = switch (Theme.of(context).platform) {
      .iOS || .macOS => _CupertinoSwitchDefaults(context),
      _ => _MaterialSwitchDefaults(context),
    };

    final effectiveTrackColor = style?.trackColor ?? themeStyle?.trackColor ?? defaults.trackColor;
    final effectiveThumbColor = style?.thumbColor ?? themeStyle?.thumbColor ?? defaults.thumbColor;
    final effectiveTrackOutlineColor =
        style?.trackOutlineColor ?? themeStyle?.trackOutlineColor ?? defaults.trackOutlineColor;
    final effectiveTrackOutlineWidth =
        style?.trackOutlineWidth ?? themeStyle?.trackOutlineWidth ?? defaults.trackOutlineWidth;
    final effectiveOverlayColor = style?.overlayColor ?? themeStyle?.overlayColor ?? defaults.overlayColor;

    Widget result = Switch.adaptive(
      value: props.value,
      onChanged: props.onChanged,
      trackColor: effectiveTrackColor,
      thumbColor: effectiveThumbColor,
      trackOutlineColor: effectiveTrackOutlineColor,
      trackOutlineWidth: effectiveTrackOutlineWidth,
      overlayColor: effectiveOverlayColor,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    if (props.semanticLabel case final label?) {
      result = MergeSemantics(
        child: Semantics(label: label, child: result),
      );
    }

    return result;
  }
}

// Cupertino (iOS/macOS) defaults — filled track, always-white thumb.
class _CupertinoSwitchDefaults extends StreamSwitchStyle {
  _CupertinoSwitchDefaults(this.context);

  final BuildContext context;
  late final StreamColorScheme _colorScheme = context.streamColorScheme;

  @override
  WidgetStateProperty<Color?> get trackColor => .resolveWith((states) {
    if (states.contains(WidgetState.selected)) {
      if (states.contains(WidgetState.disabled)) return _colorScheme.backgroundDisabled;
      return _colorScheme.accentPrimary;
    }

    if (states.contains(WidgetState.disabled)) return _colorScheme.backgroundDisabled;
    return _colorScheme.accentNeutral;
  });

  @override
  WidgetStateProperty<Color?> get thumbColor => .all(_colorScheme.backgroundOnAccent);

  @override
  WidgetStateProperty<Color?> get trackOutlineColor => .all(StreamColors.transparent);

  @override
  WidgetStateProperty<double?> get trackOutlineWidth => .all(0);

  @override
  WidgetStateProperty<Color?> get overlayColor => .resolveWith((states) {
    if (states.contains(WidgetState.pressed)) return _colorScheme.backgroundPressed;
    if (states.contains(WidgetState.hovered)) return _colorScheme.backgroundHover;
    return StreamColors.transparent;
  });
}

// Material (Android/others) defaults — transparent track with outline when
// unselected, colored thumb that changes between selected/unselected states.
class _MaterialSwitchDefaults extends StreamSwitchStyle {
  _MaterialSwitchDefaults(this.context);

  final BuildContext context;
  late final StreamColorScheme _colorScheme = context.streamColorScheme;

  @override
  WidgetStateProperty<Color?> get trackColor => .resolveWith((states) {
    if (states.contains(WidgetState.selected)) {
      if (states.contains(WidgetState.disabled)) return _colorScheme.backgroundDisabled;
      return _colorScheme.accentPrimary;
    }

    return StreamColors.transparent;
  });

  @override
  WidgetStateProperty<Color?> get thumbColor => .resolveWith((states) {
    if (states.contains(WidgetState.selected)) return _colorScheme.backgroundOnAccent;
    if (states.contains(WidgetState.disabled)) return _colorScheme.textDisabled;
    return _colorScheme.accentNeutral;
  });

  @override
  WidgetStateProperty<Color?> get trackOutlineColor => .resolveWith((states) {
    if (states.contains(WidgetState.selected)) return StreamColors.transparent;
    if (states.contains(WidgetState.disabled)) return _colorScheme.borderDisabled;
    return _colorScheme.borderDefault;
  });

  @override
  WidgetStateProperty<double?> get trackOutlineWidth => .resolveWith((states) {
    if (states.contains(WidgetState.selected)) return 0;
    return 2;
  });

  @override
  WidgetStateProperty<Color?> get overlayColor => .resolveWith((states) {
    if (states.contains(WidgetState.pressed)) return _colorScheme.backgroundPressed;
    if (states.contains(WidgetState.hovered)) return _colorScheme.backgroundHover;
    return StreamColors.transparent;
  });
}
