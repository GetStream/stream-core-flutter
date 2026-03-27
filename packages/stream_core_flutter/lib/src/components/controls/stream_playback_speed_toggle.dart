import 'package:flutter/material.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_playback_speed_toggle_theme.dart';
import '../../theme/primitives/stream_colors.dart';
import '../../theme/primitives/stream_radius.dart';
import '../../theme/primitives/stream_spacing.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/semantics/stream_text_theme.dart';
import '../../theme/stream_theme_extensions.dart';

/// Predefined playback speed values for [StreamPlaybackSpeedToggle].
enum StreamPlaybackSpeed {
  /// Normal speed (1x).
  x1(1, 'x1'),

  /// Double speed (2x).
  x2(2, 'x2'),

  /// Half speed (0.5x).
  x0_5(0.5, 'x0.5'),
  ;

  const StreamPlaybackSpeed(this.speed, this.label);

  /// The numeric speed multiplier (e.g. 1.0, 2.0, 0.5).
  final double speed;

  /// The display label for this speed (e.g. "x1", "x2", "x0.5").
  final String label;

  /// Returns the next speed in the cycle: x1 → x2 → x0.5 → x1.
  StreamPlaybackSpeed get next => switch (this) {
    StreamPlaybackSpeed.x1 => StreamPlaybackSpeed.x2,
    StreamPlaybackSpeed.x2 => StreamPlaybackSpeed.x0_5,
    StreamPlaybackSpeed.x0_5 => StreamPlaybackSpeed.x1,
  };
}

/// A pill-shaped toggle button for displaying and cycling playback speed.
///
/// [StreamPlaybackSpeedToggle] renders a compact text button showing the
/// current playback speed (e.g. "x1", "x2", "x0.5"). Tapping it cycles to
/// the next speed via [onChanged]. It is typically used inside an audio or
/// voice message player.
///
/// {@tool snippet}
///
/// Display a playback speed toggle:
///
/// ```dart
/// StreamPlaybackSpeedToggle(
///   value: _currentSpeed,
///   onChanged: (speed) => setState(() => _currentSpeed = speed),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamPlaybackSpeedToggleTheme], for customizing toggle appearance.
class StreamPlaybackSpeedToggle extends StatelessWidget {
  /// Creates a playback speed toggle with a [value] and optional
  /// [onChanged] callback.
  StreamPlaybackSpeedToggle({
    super.key,
    required StreamPlaybackSpeed value,
    ValueChanged<StreamPlaybackSpeed>? onChanged,
    StreamPlaybackSpeedToggleStyle? style,
  }) : props = .new(value: value, onChanged: onChanged, style: style);

  /// The props controlling the appearance and behavior of this toggle.
  final StreamPlaybackSpeedToggleProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).playbackSpeedToggle;
    if (builder != null) return builder(context, props);
    return DefaultStreamPlaybackSpeedToggle(props: props);
  }
}

/// Properties for configuring a [StreamPlaybackSpeedToggle].
///
/// See also:
///
///  * [StreamPlaybackSpeedToggle], which uses these properties.
///  * [DefaultStreamPlaybackSpeedToggle], the default implementation.
class StreamPlaybackSpeedToggleProps {
  /// Creates properties for a playback speed toggle.
  const StreamPlaybackSpeedToggleProps({
    required this.value,
    this.onChanged,
    this.style,
  });

  /// The current playback speed.
  final StreamPlaybackSpeed value;

  /// Called with the next speed when the toggle is tapped.
  ///
  /// When null the toggle is rendered in a disabled state.
  final ValueChanged<StreamPlaybackSpeed>? onChanged;

  /// Per-instance style overrides for this toggle.
  ///
  /// These properties take precedence over the inherited
  /// [StreamPlaybackSpeedToggleTheme] values for this specific instance.
  final StreamPlaybackSpeedToggleStyle? style;
}

/// Default implementation of [StreamPlaybackSpeedToggle].
class DefaultStreamPlaybackSpeedToggle extends StatelessWidget {
  /// Creates a default playback speed toggle.
  const DefaultStreamPlaybackSpeedToggle({super.key, required this.props});

  /// The props controlling the appearance and behavior of this toggle.
  final StreamPlaybackSpeedToggleProps props;

  @override
  Widget build(BuildContext context) {
    final defaults = _StreamPlaybackSpeedToggleDefaults(context);
    final inheritedStyle = context.streamPlaybackSpeedToggleTheme.style;
    final themeStyle = inheritedStyle?.merge(props.style) ?? props.style;

    final effectiveBackgroundColor = themeStyle?.backgroundColor ?? defaults.backgroundColor;
    final effectiveForegroundColor = themeStyle?.foregroundColor ?? defaults.foregroundColor;
    final effectiveBorderColor = themeStyle?.borderColor ?? defaults.borderColor;
    final effectiveOverlayColor = themeStyle?.overlayColor ?? defaults.overlayColor;
    final effectiveElevation = themeStyle?.elevation ?? defaults.elevation;
    final effectiveTextStyle = themeStyle?.textStyle ?? defaults.textStyle;
    final effectiveShape = themeStyle?.shape ?? defaults.shape;
    final effectivePadding = themeStyle?.padding ?? defaults.padding;
    final effectiveMinimumSize = themeStyle?.minimumSize ?? defaults.minimumSize;
    final effectiveMaximumSize = themeStyle?.maximumSize ?? defaults.maximumSize;
    final effectiveTapTargetSize = themeStyle?.tapTargetSize ?? defaults.tapTargetSize;

    return TextButton(
      onPressed: switch (props.onChanged) {
        final onChanged? => () => onChanged(props.value.next),
        _ => null,
      },
      style: ButtonStyle(
        visualDensity: VisualDensity.standard,
        tapTargetSize: effectiveTapTargetSize,
        backgroundColor: effectiveBackgroundColor,
        foregroundColor: effectiveForegroundColor,
        overlayColor: effectiveOverlayColor,
        elevation: effectiveElevation,
        side: WidgetStateProperty.resolveWith((states) {
          final color = effectiveBorderColor.resolve(states);
          if (color == null) return null;
          return BorderSide(color: color);
        }),
        shape: .all(effectiveShape),
        minimumSize: .all(effectiveMinimumSize),
        maximumSize: .all(effectiveMaximumSize),
        padding: .all(effectivePadding),
        textStyle: effectiveTextStyle,
      ),
      child: MediaQuery.withNoTextScaling(
        child: Text(props.value.label),
      ),
    );
  }
}

// Provides default values for [StreamPlaybackSpeedToggle] based on the
// current theme.
class _StreamPlaybackSpeedToggleDefaults extends StreamPlaybackSpeedToggleStyle {
  _StreamPlaybackSpeedToggleDefaults(this._context);

  final BuildContext _context;

  late final StreamColorScheme _colorScheme = _context.streamColorScheme;
  late final StreamTextTheme _textTheme = _context.streamTextTheme;
  late final StreamSpacing _spacing = _context.streamSpacing;
  late final StreamRadius _radius = _context.streamRadius;

  @override
  WidgetStateProperty<Color> get backgroundColor => .all(StreamColors.transparent);

  @override
  WidgetStateProperty<Color> get foregroundColor => .resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return _colorScheme.textDisabled;
    return _colorScheme.textPrimary;
  });

  @override
  WidgetStateProperty<Color> get borderColor => .resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return _colorScheme.borderDisabled;
    return _colorScheme.borderDefault;
  });

  @override
  WidgetStateProperty<Color> get overlayColor => .resolveWith((states) {
    if (states.contains(WidgetState.pressed)) return _colorScheme.statePressed;
    if (states.contains(WidgetState.hovered)) return _colorScheme.stateHover;
    return StreamColors.transparent;
  });

  @override
  WidgetStateProperty<double> get elevation => .all(0);

  @override
  WidgetStateProperty<TextStyle> get textStyle => .all(_textTheme.metadataEmphasis);

  @override
  OutlinedBorder get shape => RoundedRectangleBorder(borderRadius: .all(_radius.max));

  @override
  EdgeInsetsGeometry get padding => .symmetric(vertical: _spacing.xxs);

  @override
  Size get minimumSize => const Size(40, 24);

  @override
  Size get maximumSize => const Size.fromWidth(40);

  @override
  MaterialTapTargetSize get tapTargetSize => .padded;
}
