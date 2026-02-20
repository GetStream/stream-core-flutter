import 'package:flutter/widgets.dart';

import '../../../../stream_core_flutter.dart';

class StreamMessageComposerAttachmentContainer extends StatelessWidget {
  const StreamMessageComposerAttachmentContainer({
    super.key,
    required this.child,
    this.onRemovePressed,
    this.backgroundColor,
    this.borderColor,
    this.padding,
  });

  final Widget child;
  final VoidCallback? onRemovePressed;
  final Color? backgroundColor;
  final Color? borderColor;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Stack(
      children: [
        Container(
          margin: EdgeInsets.all(spacing.xxs),
          padding: padding ?? EdgeInsets.all(spacing.xs),
          foregroundDecoration: borderColor != null
              ? BoxDecoration(
                  borderRadius: BorderRadius.all(context.streamRadius.lg),
                  border: Border.all(color: borderColor!),
                )
              : null,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.all(context.streamRadius.lg),
          ),
          child: child,
        ),
        if (onRemovePressed case final VoidCallback onRemovePressed?)
          Align(
            alignment: Alignment.topRight,
            child: StreamRemoveControl(onPressed: onRemovePressed),
          ),
      ],
    );
  }
}
