import 'package:flutter/material.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_button_theme.dart';
import '../../theme/components/stream_split_button_theme.dart';
import '../../theme/primitives/stream_colors.dart';
import '../../theme/primitives/stream_spacing.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/stream_theme_extensions.dart';
import 'internal/stream_button_defaults.dart';
import 'stream_button.dart';

/// Two buttons sharing one surface, separated by a divider.
///
/// A split button pairs a primary action with a secondary one — most often a
/// caret that opens the options for that action. Both halves are
/// [StreamButton.icon] instances painted on a single background, so the
/// control reads as one pill rather than two adjacent buttons.
///
/// The surface is resolved from the same [StreamButtonTheme] entry the halves
/// use, which is what keeps the two from drifting apart. For
/// [StreamButtonType.outline] the border is drawn once around the whole
/// control rather than around each half.
///
/// Each half keeps its own tap target, hover and press feedback, and
/// accessibility node; the divider is decorative.
///
/// {@tool snippet}
///
/// A microphone button with a caret that opens the audio settings:
///
/// ```dart
/// StreamSplitButton.icon(
///   style: StreamButtonStyle.secondary,
///   icon: Icon(context.streamIcons.voiceFill),
///   trailingIcon: Icon(context.streamIcons.caretDown),
///   tooltip: 'Mute',
///   trailingTooltip: 'Audio settings',
///   onPressed: () => toggleMute(),
///   onTrailingPressed: () => showAudioSettings(),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Flip the caret while the menu it opens is showing:
///
/// ```dart
/// StreamSplitButton.icon(
///   type: StreamButtonType.outline,
///   icon: const Icon(Icons.share),
///   trailingIcon: Icon(isMenuOpen ? icons.caretUp : icons.caretDown),
///   onPressed: () => share(),
///   onTrailingPressed: () => toggleMenu(),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamButton], the button each half is built from.
///  * [StreamSplitButtonTheme], for customizing split button appearance.
class StreamSplitButton extends StatelessWidget {
  /// Creates a split button with an icon in each half.
  ///
  /// [icon] labels the primary half and [trailingIcon] the secondary one.
  /// Both are configurable so the trailing half can point the caret at
  /// whatever it opens — [StreamIcons.caretDown] for a menu below,
  /// [StreamIcons.caretUp] for one above.
  ///
  /// A half with a null callback is disabled; the control as a whole only
  /// takes on its disabled surface once both halves are.
  StreamSplitButton.icon({
    super.key,
    required Widget icon,
    required Widget trailingIcon,
    VoidCallback? onPressed,
    VoidCallback? onTrailingPressed,
    StreamButtonStyle style = .primary,
    StreamButtonType type = .solid,
    StreamButtonSize size = .medium,
    String? tooltip,
    String? trailingTooltip,
    StreamSplitButtonStyle? themeStyle,
  }) : props = .new(
         icon: icon,
         trailingIcon: trailingIcon,
         onPressed: onPressed,
         onTrailingPressed: onTrailingPressed,
         style: style,
         type: type,
         size: size,
         tooltip: tooltip,
         trailingTooltip: trailingTooltip,
         themeStyle: themeStyle,
       );

  /// The props controlling the appearance and behavior of this split button.
  final StreamSplitButtonProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).splitButton;
    if (builder != null) return builder(context, props);
    return DefaultStreamSplitButton(props: props);
  }
}

/// Properties for configuring a [StreamSplitButton].
///
/// This class holds all the configuration options for a split button,
/// allowing them to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamSplitButton], which uses these properties.
///  * [DefaultStreamSplitButton], the default implementation.
class StreamSplitButtonProps {
  /// Creates properties for a split button.
  const StreamSplitButtonProps({
    required this.icon,
    required this.trailingIcon,
    this.onPressed,
    this.onTrailingPressed,
    this.style = .primary,
    this.type = .solid,
    this.size = .medium,
    this.tooltip,
    this.trailingTooltip,
    this.themeStyle,
  });

  /// The icon rendered in the primary (leading) half.
  final Widget icon;

  /// The icon rendered in the secondary (trailing) half.
  ///
  /// Typically a caret pointing at whatever the half opens.
  final Widget trailingIcon;

  /// Called when the primary half is pressed.
  ///
  /// If null, that half is disabled.
  final VoidCallback? onPressed;

  /// Called when the trailing half is pressed.
  ///
  /// If null, that half is disabled.
  final VoidCallback? onTrailingPressed;

  /// The visual style variant of the split button.
  ///
  /// Determines the color scheme used (primary, secondary, destructive).
  final StreamButtonStyle style;

  /// The type variant of the split button.
  ///
  /// Controls the visual weight (solid, outline, ghost). An outline split
  /// button draws a single border around both halves.
  final StreamButtonType type;

  /// The size of each half.
  ///
  /// Sets the painted area of a half — the surface it highlights on hover and
  /// press. Each half keeps an accessible tap target regardless of this value.
  final StreamButtonSize size;

  /// Text shown in a [Tooltip] on hover / long-press of the primary half, and
  /// used as its accessibility label.
  ///
  /// When null, that half has no tooltip.
  final String? tooltip;

  /// Text shown in a [Tooltip] on hover / long-press of the trailing half, and
  /// used as its accessibility label.
  ///
  /// When null, that half has no tooltip.
  final String? trailingTooltip;

  /// Per-instance style overrides for this split button.
  ///
  /// These properties take precedence over the inherited
  /// [StreamSplitButtonTheme] values for this specific instance.
  final StreamSplitButtonStyle? themeStyle;
}

/// Default implementation of [StreamSplitButton].
///
/// Renders a [Row] of two [StreamButton.icon] halves over a shared surface,
/// with a divider between them.
///
/// See also:
///
///  * [StreamSplitButton], the public widget that delegates to this.
///  * [StreamSplitButtonProps], the configuration properties.
class DefaultStreamSplitButton extends StatelessWidget {
  /// Creates a default split button.
  const DefaultStreamSplitButton({super.key, required this.props});

  /// The props controlling the appearance and behavior of this split button.
  final StreamSplitButtonProps props;

  @override
  Widget build(BuildContext context) {
    final themeStyle = context.streamSplitButtonTheme.style?.merge(props.themeStyle) ?? props.themeStyle;
    final defaults = _StreamSplitButtonDefaults(context, size: props.size);

    // Resolved once and shared: the surface below and the halves above are the
    // same button style, so they cannot render as different colors.
    final buttonStyle = resolveStreamButtonThemeStyle(
      context,
      style: props.style,
      type: props.type,
      isFloating: false,
      themeStyle: defaults.buttonStyle.merge(themeStyle?.buttonStyle),
    );

    final isEnabled = props.onPressed != null || props.onTrailingPressed != null;
    final states = <WidgetState>{if (!isEnabled) WidgetState.disabled};

    final shape = buttonStyle.shape?.resolve(states) ?? const StadiumBorder();
    final borderColor = buttonStyle.borderColor?.resolve(states);

    final effectiveSeparatorColor = (themeStyle?.separatorColor ?? defaults.separatorColor).resolve(states);
    final effectiveSeparatorThickness = themeStyle?.separatorThickness ?? defaults.separatorThickness;
    final effectiveSeparatorHeight = themeStyle?.separatorHeight ?? defaults.separatorHeight;

    // The halves sit on the shared surface, so they paint neither their own
    // background nor their own border.
    final halfStyle = buttonStyle.copyWith(
      backgroundColor: const WidgetStatePropertyAll(StreamColors.transparent),
      borderColor: const WidgetStatePropertyAll(null),
      elevation: const WidgetStatePropertyAll(0),
    );

    return DecoratedBox(
      decoration: ShapeDecoration(
        color: buttonStyle.backgroundColor?.resolve(states),
        shape: switch (borderColor) {
          final color? => shape.copyWith(side: BorderSide(color: color)),
          _ => shape,
        },
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StreamButton.icon(
            icon: props.icon,
            onPressed: props.onPressed,
            style: props.style,
            type: props.type,
            size: props.size,
            tooltip: props.tooltip,
            themeStyle: halfStyle,
          ),
          SizedBox(
            width: effectiveSeparatorThickness,
            height: effectiveSeparatorHeight,
            child: ColoredBox(color: effectiveSeparatorColor ?? StreamColors.transparent),
          ),
          StreamButton.icon(
            icon: props.trailingIcon,
            onPressed: props.onTrailingPressed,
            style: props.style,
            type: props.type,
            size: props.size,
            tooltip: props.trailingTooltip,
            themeStyle: halfStyle,
          ),
        ],
      ),
    );
  }
}

// Default theme values for [StreamSplitButton].
//
// These defaults are used when no explicit value is provided via
// [StreamSplitButtonStyle] or [StreamSplitButtonThemeData].
class _StreamSplitButtonDefaults extends StreamSplitButtonStyle {
  _StreamSplitButtonDefaults(this.context, {required this.size});

  final BuildContext context;
  final StreamButtonSize size;

  late final StreamSpacing _spacing = context.streamSpacing;
  late final StreamColorScheme _colorScheme = context.streamColorScheme;

  // Forced onto both halves and the surface, above the inherited
  // [StreamButtonTheme] but below the caller's own overrides: a split button
  // whose halves lost their tap target is not worth shipping.
  @override
  StreamButtonThemeStyle get buttonStyle => const StreamButtonThemeStyle(tapTargetSize: MaterialTapTargetSize.padded);

  @override
  WidgetStateProperty<Color?> get separatorColor => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return _colorScheme.borderDisabled;
    return _colorScheme.borderDefault;
  });

  @override
  double get separatorThickness => 1;

  @override
  double get separatorHeight => size.value - _spacing.xxs * 2;
}
