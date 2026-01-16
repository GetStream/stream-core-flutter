import 'package:flutter/material.dart';

import '../../stream_core_flutter.dart';
import '../theme/stream_component_factory.dart';

class StreamButton extends StatelessWidget {
  StreamButton({
    super.key,
    String? label,
    VoidCallback? onTap,
    StreamButtonType type = StreamButtonType.primary,
    StreamButtonSize size = StreamButtonSize.medium,
    Widget? iconLeft,
    Widget? iconRight,
  }) : props = StreamButtonProps(
         label: label,
         onTap: onTap,
         type: type,
         size: size,
         iconLeft: iconLeft,
         iconRight: iconRight,
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
    required this.type,
    required this.size,
    required this.iconLeft,
    required this.iconRight,
  });

  final String? label;
  final VoidCallback? onTap;
  final StreamButtonType type;
  final StreamButtonSize size;
  final Widget? iconLeft;
  final Widget? iconRight;
}

enum StreamButtonType { primary, secondary, destructive }

enum StreamButtonSize { small, medium, large }

class DefaultStreamButton extends StatelessWidget {
  const DefaultStreamButton({super.key, required this.props});

  static StreamComponentBuilder<StreamButtonProps> get factory =>
      (context, props) => DefaultStreamButton(props: props);

  final StreamButtonProps props;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final streamTheme = StreamTheme.of(context);
    final buttonTheme = streamTheme.buttonTheme;

    final colors = switch (props.type) {
      StreamButtonType.primary => _primaryColors(
        theme,
        streamTheme,
        buttonTheme,
      ),
      StreamButtonType.secondary => _secondaryColors(
        theme,
        streamTheme,
        buttonTheme,
      ),
      StreamButtonType.destructive => _destructiveColors(
        theme,
        streamTheme,
        buttonTheme,
      ),
    };

    return ElevatedButton(
      onPressed: props.onTap,
      style: ButtonStyle(
        backgroundColor: colors.bgColor,
        foregroundColor: colors.textColor,
        side: WidgetStateProperty.resolveWith(
          (states) => BorderSide(
            color: colors.borderColor.resolve(states),
          ),
        ),
        elevation: WidgetStateProperty.all(0),
      ),
      child: Row(
        children: [
          ?props.iconLeft,
          if (props.label case final label?) Text(label),
          ?props.iconRight,
        ],
      ),
    );
  }

  _StreamButtonColors _primaryColors(
    ThemeData theme,
    StreamTheme streamTheme,
    StreamButtonTheme buttonTheme,
  ) => _StreamButtonColors(
    bgColor:
        buttonTheme.primaryColor ??
        (streamTheme.primaryColor != null
            ? WidgetStateProperty.all(streamTheme.primaryColor!)
            : WidgetStateProperty.all(theme.colorScheme.primary)),
    borderColor:
        buttonTheme.primaryColor ??
        (streamTheme.primaryColor != null
            ? WidgetStateProperty.all(streamTheme.primaryColor!)
            : WidgetStateProperty.all(theme.colorScheme.primary)),
    textColor: WidgetStateProperty.all(Colors.white),
  );

  _StreamButtonColors _secondaryColors(
    ThemeData theme,
    StreamTheme streamTheme,
    StreamButtonTheme buttonTheme,
  ) => _StreamButtonColors(
    bgColor: WidgetStateProperty.all(Colors.white),
    borderColor: WidgetStateProperty.all(Colors.grey),
    textColor: WidgetStateProperty.all(Colors.black),
  );

  _StreamButtonColors _destructiveColors(
    ThemeData theme,
    StreamTheme streamTheme,
    StreamButtonTheme buttonTheme,
  ) => _StreamButtonColors(
    bgColor: WidgetStateProperty.all(Colors.red),
    borderColor: WidgetStateProperty.all(Colors.red),
    textColor: WidgetStateProperty.all(Colors.white),
  );
}

class _StreamButtonColors {
  _StreamButtonColors({
    required this.bgColor,
    required this.borderColor,
    required this.textColor,
  });

  final WidgetStateProperty<Color> bgColor;
  final WidgetStateProperty<Color> borderColor;
  final WidgetStateProperty<Color> textColor;
}
