import 'package:flutter/widgets.dart';

import '../../../../stream_core_flutter.dart';
import '../../controls/remove_control.dart';

class MessageComposerAttachmentMediaFile extends StatelessWidget {
  const MessageComposerAttachmentMediaFile({
    super.key,
    required this.child,
    this.onRemovePressed,
    this.mediaBadge,
  });

  MessageComposerAttachmentMediaFile.image({
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
    return SizedBox(
      height: 80,
      width: 80,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(context.streamSpacing.xxs),
            child: Container(
              clipBehavior: Clip.antiAlias,
              foregroundDecoration: BoxDecoration(
                borderRadius: BorderRadius.all(context.streamRadius.lg),
                border: Border.all(
                  color: context.streamColorScheme.borderDefault.withAlpha(25),
                ),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(context.streamRadius.lg),
              ),
              child: child,
            ),
          ),
          if (onRemovePressed case final VoidCallback onRemovePressed?)
            Align(
              alignment: Alignment.topRight,
              child: RemoveControl(onPressed: onRemovePressed),
            ),
          if (mediaBadge case final Widget mediaBadge?)
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.all(context.streamSpacing.xs),
                child: mediaBadge,
              ),
            ),
        ],
      ),
    );
  }
}
