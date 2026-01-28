import 'package:flutter/material.dart';

import '../../../stream_core_flutter.dart';
import '../../factory/stream_component_factory.dart' show StreamComponentBuilder;
import '../../theme/components/stream_button_theme.dart';

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
  }) : props = StreamButtonProps(
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
  }) : props = StreamButtonProps(
         label: null,
         onTap: onTap,
         style: style,
         type: type,
         size: size,
         iconLeft: icon,
         iconRight: null,
       );

  final StreamButtonProps props;

  @override
  Widget build(BuildContext context) {
    return StreamTheme.of(
      context,
    ).componentFactory.buttonFactory(context, props);
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
  });

  final String? label;
  final VoidCallback? onTap;
  final StreamButtonStyle style;
  final StreamButtonType type;
  final StreamButtonSize size;
  final IconData? iconLeft;
  final IconData? iconRight;
}

enum StreamButtonStyle { primary, secondary, destructive }

enum StreamButtonSize { small, medium, large }

enum StreamButtonType { solid, outline, ghost }

class DefaultStreamButton extends StatelessWidget {
  const DefaultStreamButton({super.key, required this.props});

  static StreamComponentBuilder<StreamButtonProps> get factory =>
      (context, props) => DefaultStreamButton(props: props);

  final StreamButtonProps props;

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;
    final buttonTheme = context.streamButtonTheme;
    final defaults = _StreamButtonDefaults(context: context);

    final isDisabled = props.onTap == null;

    final themeColors = switch (props.style) {
      StreamButtonStyle.primary => isDisabled ? buttonTheme.disabledPrimaryButtonColors : buttonTheme.primaryButtonColors,
      StreamButtonStyle.secondary => isDisabled ? buttonTheme.disabledSecondaryButtonColors : buttonTheme.secondaryButtonColors,
      StreamButtonStyle.destructive => isDisabled ? buttonTheme.disabledDestructiveButtonColors : buttonTheme.destructiveButtonColors,
    };

    final defaultColors = switch (props.style) {
      StreamButtonStyle.primary => isDisabled ? defaults.disabledColors : defaults.primaryColors,
      StreamButtonStyle.secondary => isDisabled ? defaults.disabledColors : defaults.secondaryColors,
      StreamButtonStyle.destructive => isDisabled ? defaults.disabledColors : defaults.destructiveColors,
    };

    final backgroundColor = switch (props.type) {
      StreamButtonType.solid =>  themeColors?.solidBackgroundColor ?? defaultColors.solidBackgroundColor,
      StreamButtonType.outline => Colors.transparent,
      StreamButtonType.ghost => Colors.transparent,
    };

    final foregroundColor = switch (props.type) {
      StreamButtonType.solid => themeColors?.solidForegroundColor ?? defaultColors.solidForegroundColor,
      StreamButtonType.outline => themeColors?.outlineForegroundColor ?? defaultColors.outlineForegroundColor,
      StreamButtonType.ghost => themeColors?.ghostForegroundColor ?? defaultColors.ghostForegroundColor,
    };

    final borderColor = switch (props.type) {
      StreamButtonType.solid => null,
      StreamButtonType.outline => themeColors?.outlineBorderColor ?? defaultColors.outlineBorderColor,
      StreamButtonType.ghost => null,
    };

    final minimumSize = switch (props.size) {
      StreamButtonSize.small => 32.0,
      StreamButtonSize.medium => 40.0,
      StreamButtonSize.large => 48.0,
    };

    const iconSize = 20.0;

    return ElevatedButton(
      onPressed: props.onTap,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(backgroundColor),
        foregroundColor: WidgetStateProperty.all(foregroundColor),
        minimumSize: WidgetStateProperty.all(Size(minimumSize, minimumSize)),
        padding: WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: spacing.md)),
        side: borderColor == null
            ? null
            : WidgetStateProperty.all(
                BorderSide(color: borderColor),
              ),
        elevation: WidgetStateProperty.all(0),
        shape: props.label == null
            ? WidgetStateProperty.all(const CircleBorder())
            : WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.all(context.streamRadius.max)),
              ),
      ),
      child: Row(
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
  _StreamButtonDefaults({
    required this.context,
  }) : _colorScheme = context.streamColorScheme;

  final BuildContext context;
  final StreamColorScheme _colorScheme;

  StreamButtonColors get primaryColors => StreamButtonColors(
    solidBackgroundColor: _colorScheme.brand.shade500,
    solidForegroundColor: _colorScheme.textOnAccent,
    outlineBorderColor: _colorScheme.brand.shade200,
    outlineForegroundColor: _colorScheme.brand.shade500,
    ghostForegroundColor: _colorScheme.brand.shade500,
  );

  StreamButtonColors get secondaryColors => StreamButtonColors(
    solidBackgroundColor: _colorScheme.backgroundSurface,
    solidForegroundColor: _colorScheme.textPrimary,
    outlineBorderColor: _colorScheme.borderDefault,
    outlineForegroundColor: _colorScheme.textPrimary,
    ghostForegroundColor: _colorScheme.textPrimary,
  );

  StreamButtonColors get destructiveColors => StreamButtonColors(
    solidBackgroundColor: _colorScheme.accentError,
    solidForegroundColor: _colorScheme.textOnAccent,
    outlineBorderColor: _colorScheme.accentError,
    outlineForegroundColor: _colorScheme.textOnAccent,
    ghostForegroundColor: _colorScheme.textOnAccent,
  );

  StreamButtonColors get disabledColors => StreamButtonColors(
    solidBackgroundColor: _colorScheme.backgroundDisabled,
    solidForegroundColor: _colorScheme.textDisabled,
    outlineBorderColor: _colorScheme.borderDefault,
    outlineForegroundColor: _colorScheme.textDisabled,
    ghostForegroundColor: _colorScheme.textDisabled,
  );
}
