import 'package:flutter/widgets.dart';

import '../../../../stream_core_flutter.dart';

class MessageComposerMediaFileAttachment extends StatelessWidget {
  const MessageComposerMediaFileAttachment({
    super.key,
    required this.child,
    this.onRemovePressed,
    this.mediaBadge,
  });

  MessageComposerMediaFileAttachment.image({
    super.key,
    required ImageProvider image,
    required this.onRemovePressed,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    this.mediaBadge,
  }) : child = Image(
         image: image,
         frameBuilder: frameBuilder,
         errorBuilder: errorBuilder,
         fit: BoxFit.cover,
       );

  final Widget child;
  final Widget? mediaBadge;
  final VoidCallback? onRemovePressed;

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return StreamMessageComposerAttachmentContainer(
      onRemovePressed: onRemovePressed,
      child: SizedBox.square(
        dimension: 72,
        child: Stack(
          children: [
            child,
            if (mediaBadge case final badge?)
              PositionedDirectional(
                start: spacing.xxs,
                bottom: spacing.xxs,
                child: badge,
              ),
          ],
        ),
      ),
    );
  }
}
