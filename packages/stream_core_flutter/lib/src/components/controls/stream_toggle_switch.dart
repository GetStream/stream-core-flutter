import 'package:flutter/material.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_toggle_switch_theme.dart';
import '../../theme/primitives/stream_colors.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/stream_theme_extensions.dart';

/// A toggle switch styled for the Stream design system.
///
/// [StreamToggleSwitch] displays a platform-adaptive toggle switch that
/// renders as a [CupertinoSwitch] on iOS/macOS and a Material [Switch] on
/// other platforms. Visual properties can be customized via
/// [StreamToggleSwitchTheme] and [StreamToggleSwitchStyle].
///
/// The toggle switch itself does not maintain any state. Instead, when the
/// state of the switch changes, the widget calls the [onChanged] callback.
/// Most widgets that use a toggle switch will listen for the [onChanged]
/// callback and rebuild the switch with a new [value] to update the visual
/// appearance.
///
/// {@tool snippet}
///
/// Basic toggle switch:
///
/// ```dart
/// StreamToggleSwitch(
///   value: isEnabled,
///   onChanged: (value) => setState(() => isEnabled = value),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Disabled toggle switch:
///
/// ```dart
/// StreamToggleSwitch(
///   value: true,
///   onChanged: null,
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamToggleSwitchTheme], for customizing toggle switch appearance.
///  * [StreamToggleSwitchStyle], for the visual style properties.
class StreamToggleSwitch extends StatelessWidget {
  /// Creates a Stream toggle switch.
  StreamToggleSwitch({
    super.key,
    required bool value,
    required ValueChanged<bool>? onChanged,
    String? semanticLabel,
  }) : props = StreamToggleSwitchProps(
         value: value,
         onChanged: onChanged,
         semanticLabel: semanticLabel,
       );

  /// The props controlling the appearance and behavior of this toggle switch.
  final StreamToggleSwitchProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).toggleSwitch;
    if (builder != null) return builder(context, props);
    return DefaultStreamToggleSwitch(props: props);
  }
}

/// Properties for configuring a [StreamToggleSwitch].
///
/// This class holds all the configuration options for a toggle switch,
/// allowing them to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamToggleSwitch], which uses these properties.
///  * [DefaultStreamToggleSwitch], the default implementation.
class StreamToggleSwitchProps {
  /// Creates properties for a toggle switch.
  const StreamToggleSwitchProps({
    required this.value,
    required this.onChanged,
    this.semanticLabel,
  });

  /// Whether this toggle switch is on.
  final bool value;

  /// Called when the value of the toggle switch should change.
  ///
  /// The toggle switch passes the new value to the callback but does not
  /// actually change state until the parent widget rebuilds the switch with
  /// the new value.
  ///
  /// If null, the toggle switch will be displayed as disabled.
  final ValueChanged<bool>? onChanged;

  /// The semantic label for the toggle switch that will be announced by
  /// screen readers.
  ///
  /// This label does not show in the UI.
  final String? semanticLabel;
}

/// Default implementation of [StreamToggleSwitch].
///
/// Renders a platform-adaptive switch using [Switch.adaptive]. Styling is
/// resolved from widget props, theme, and built-in defaults in that order.
///
/// Platform-specific defaults are applied automatically:
///  * iOS/macOS — Cupertino defaults (filled track, white thumb).
///  * Android and others — Material defaults (outlined track when unselected,
///    colored thumb).
class DefaultStreamToggleSwitch extends StatelessWidget {
  /// Creates a default toggle switch.
  const DefaultStreamToggleSwitch({super.key, required this.props});

  /// The props controlling the appearance and behavior of this toggle switch.
  final StreamToggleSwitchProps props;

  @override
  Widget build(BuildContext context) {
    final switchStyle = context.streamToggleSwitchTheme.style;

    final defaults = switch (Theme.of(context).platform) {
      .iOS || .macOS => _CupertinoToggleSwitchDefaults(context),
      _ => _MaterialToggleSwitchDefaults(context),
    };

    final effectiveTrackColor = switchStyle?.trackColor ?? defaults.trackColor;
    final effectiveThumbColor = switchStyle?.thumbColor ?? defaults.thumbColor;
    final effectiveTrackOutlineColor = switchStyle?.trackOutlineColor ?? defaults.trackOutlineColor;
    final effectiveTrackOutlineWidth = switchStyle?.trackOutlineWidth ?? defaults.trackOutlineWidth;
    final effectiveOverlayColor = switchStyle?.overlayColor ?? defaults.overlayColor;

    return Semantics(
      label: props.semanticLabel,
      toggled: props.value,
      child: Switch.adaptive(
        value: props.value,
        onChanged: props.onChanged,
        trackColor: effectiveTrackColor,
        thumbColor: effectiveThumbColor,
        trackOutlineColor: effectiveTrackOutlineColor,
        trackOutlineWidth: effectiveTrackOutlineWidth,
        overlayColor: effectiveOverlayColor,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

// Cupertino (iOS/macOS) defaults — filled track, always-white thumb.
class _CupertinoToggleSwitchDefaults extends StreamToggleSwitchStyle {
  _CupertinoToggleSwitchDefaults(this.context);

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
class _MaterialToggleSwitchDefaults extends StreamToggleSwitchStyle {
  _MaterialToggleSwitchDefaults(this.context);

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
