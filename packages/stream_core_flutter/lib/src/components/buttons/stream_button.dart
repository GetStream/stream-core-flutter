import 'package:flutter/material.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/components/stream_button_theme.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/stream_theme_extensions.dart';

class StreamButton extends StatelessWidget {
  StreamButton({
    super.key,
    required String label,
    VoidCallback? onTap,
    StreamButtonStyle style = StreamButtonStyle.primary,
    StreamButtonType type = StreamButtonType.solid,
    StreamButtonSize size = StreamButtonSize.medium,
    IconData? iconLeft,
    IconData? iconRight,
  }) : props = .new(
         label: label,
         onTap: onTap,
         style: style,
         type: type,
         size: size,
         iconLeft: iconLeft,
         iconRight: iconRight,
       );

  StreamButton.icon({
    super.key,
    VoidCallback? onTap,
    StreamButtonStyle style = StreamButtonStyle.primary,
    StreamButtonType type = StreamButtonType.solid,
    StreamButtonSize size = StreamButtonSize.medium,
    IconData? icon,
    bool isFloating = false,
  }) : props = .new(
         label: null,
         onTap: onTap,
         style: style,
         type: type,
         size: size,
         iconLeft: icon,
         iconRight: null,
         isFloating: isFloating,
       );

  final StreamButtonProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.maybeOf(context)?.button;
    if (builder != null) return builder(context, props);
    return DefaultStreamButton(props: props);
  }
}

class StreamButtonProps {
  const StreamButtonProps({
    required this.label,
    required this.onTap,
    required this.style,
    required this.type,
    required this.size,
    required this.iconLeft,
    required this.iconRight,
    this.isFloating = false,
  });

  final String? label;
  final VoidCallback? onTap;
  final StreamButtonStyle style;
  final StreamButtonType type;
  final StreamButtonSize size;
  final IconData? iconLeft;
  final IconData? iconRight;
  final bool isFloating;
}

enum StreamButtonStyle { primary, secondary, destructive }

enum StreamButtonSize { small, medium, large }

enum StreamButtonType { solid, outline, ghost }

class DefaultStreamButton extends StatelessWidget {
  const DefaultStreamButton({super.key, required this.props});

  final StreamButtonProps props;

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;
    final buttonTheme = context.streamButtonTheme;
    final colorScheme = context.streamColorScheme;
    final defaults = _StreamButtonDefaults(context: context);

    final themeButtonTypeStyle = switch (props.style) {
      StreamButtonStyle.primary => buttonTheme.primary,
      StreamButtonStyle.secondary => buttonTheme.secondary,
      StreamButtonStyle.destructive => buttonTheme.destructive,
    };

    final themeStyle = switch (props.type) {
      StreamButtonType.solid => themeButtonTypeStyle?.solid,
      StreamButtonType.outline => themeButtonTypeStyle?.outline,
      StreamButtonType.ghost => themeButtonTypeStyle?.ghost,
    };

    final defaultButtonTypeStyle = switch (props.style) {
      StreamButtonStyle.primary => defaults.primary,
      StreamButtonStyle.secondary => defaults.secondary,
      StreamButtonStyle.destructive => defaults.destructive,
    };
    final defaultStyle = switch (props.type) {
      StreamButtonType.solid => defaultButtonTypeStyle.solid,
      StreamButtonType.outline => defaultButtonTypeStyle.outline,
      StreamButtonType.ghost => defaultButtonTypeStyle.ghost,
    };

    final fallbackBackgroundColor = props.isFloating ? colorScheme.backgroundElevation1 : Colors.transparent;

    final backgroundColor =
        themeStyle?.backgroundColor ??
        defaultStyle?.backgroundColor ??
        WidgetStateProperty.all(fallbackBackgroundColor);
    final foregroundColor = themeStyle?.foregroundColor ?? defaultStyle?.foregroundColor;
    final borderColor = themeStyle?.borderColor ?? defaultStyle?.borderColor;

    final minimumSize = switch (props.size) {
      StreamButtonSize.small => 32.0,
      StreamButtonSize.medium => 40.0,
      StreamButtonSize.large => 48.0,
    };

    const iconSize = 20.0;
    final isIconButton = props.label == null;

    return ElevatedButton(
      onPressed: props.onTap,
      style: ButtonStyle(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        minimumSize: WidgetStateProperty.all(Size(minimumSize, minimumSize)),
        maximumSize: isIconButton ? WidgetStateProperty.all(Size(minimumSize, minimumSize)) : null,
        elevation: WidgetStateProperty.all(props.isFloating ? 4 : 0),
        padding: WidgetStateProperty.all(
          isIconButton ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: spacing.md),
        ),

        side: borderColor == null
            ? null
            : WidgetStateProperty.resolveWith(
                (states) => BorderSide(color: borderColor.resolve(states)),
              ),
        shape: props.label == null
            ? WidgetStateProperty.all(const CircleBorder())
            : WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(context.streamRadius.max),
                ),
              ),
      ),
      child: isIconButton
          ? Icon(props.iconLeft, size: iconSize)
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: spacing.xs,
              children: [
                if (props.iconLeft case final iconLeft?) Icon(iconLeft, size: iconSize),
                if (props.label case final label?) Text(label),
                if (props.iconRight case final iconRight?) Icon(iconRight, size: iconSize),
              ],
            ),
    );
  }
}

class _StreamButtonDefaults {
  _StreamButtonDefaults({required this.context}) : _colorScheme = context.streamColorScheme;

  final BuildContext context;
  final StreamColorScheme _colorScheme;

  StreamButtonTypeStyle get primary => StreamButtonTypeStyle(
    solid: StreamButtonThemeStyle(
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.disabled) ? _colorScheme.backgroundDisabled : _colorScheme.brand.shade500,
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled) ? _colorScheme.textDisabled : _colorScheme.textOnAccent,
      ),
    ),
    outline: StreamButtonThemeStyle(
      borderColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled) ? _colorScheme.borderDefault : _colorScheme.brand.shade200,
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled) ? _colorScheme.textDisabled : _colorScheme.brand.shade500,
      ),
    ),
    ghost: StreamButtonThemeStyle(
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled) ? _colorScheme.textDisabled : _colorScheme.brand.shade500,
      ),
    ),
  );

  StreamButtonTypeStyle get secondary => StreamButtonTypeStyle(
    solid: StreamButtonThemeStyle(
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.disabled) ? _colorScheme.backgroundDisabled : _colorScheme.backgroundSurface,
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled) ? _colorScheme.textDisabled : _colorScheme.textPrimary,
      ),
    ),
    outline: StreamButtonThemeStyle(
      borderColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled) ? _colorScheme.borderDefault : _colorScheme.borderDefault,
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled) ? _colorScheme.textDisabled : _colorScheme.textPrimary,
      ),
    ),
    ghost: StreamButtonThemeStyle(
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled) ? _colorScheme.textDisabled : _colorScheme.textPrimary,
      ),
    ),
  );
  StreamButtonTypeStyle get destructive => StreamButtonTypeStyle(
    solid: StreamButtonThemeStyle(
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled) ? _colorScheme.backgroundDisabled : _colorScheme.accentError,
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled) ? _colorScheme.textDisabled : _colorScheme.textOnAccent,
      ),
    ),
    outline: StreamButtonThemeStyle(
      borderColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled) ? _colorScheme.borderDefault : _colorScheme.accentError,
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled) ? _colorScheme.textDisabled : _colorScheme.accentError,
      ),
    ),
    ghost: StreamButtonThemeStyle(
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled) ? _colorScheme.textDisabled : _colorScheme.accentError,
      ),
    ),
  );
}
