import 'package:flutter/widgets.dart';

import '../../../../stream_core_flutter.dart';
import 'message_composer_attachment_container.dart';

class MessageComposerAttachmentLinkPreview extends StatelessWidget {
  const MessageComposerAttachmentLinkPreview({
    super.key,
    this.title,
    this.subtitle,
    this.url,
    this.image,
    this.onRemovePressed,
  });

  final String? title;
  final String? subtitle;
  final String? url;
  final ImageProvider? image;
  final VoidCallback? onRemovePressed;

  @override
  Widget build(BuildContext context) {
    final messageTheme = context.streamMessageTheme.mergeWithDefaults(context);
    final backgroundColor = messageTheme.outgoing?.backgroundColor;
    final textColor = messageTheme.outgoing?.textColor;

    final titleStyle = context.streamTextTheme.metadataEmphasis.copyWith(color: textColor);
    final bodyStyle = context.streamTextTheme.metadataDefault.copyWith(color: textColor);

    final spacing = context.streamSpacing;
    return StreamMessageComposerAttachmentContainer(
      onRemovePressed: onRemovePressed,
      backgroundColor: backgroundColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (image != null) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(context.streamRadius.md),
                image: DecorationImage(image: image!, fit: BoxFit.cover),
              ),
            ),
            SizedBox(width: spacing.xs),
          ],
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title case final title?)
                  Text(
                    title,
                    style: titleStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (subtitle case final subtitle?)
                  Text(
                    subtitle,
                    style: bodyStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (url case final url?)
                  Row(
                    children: [
                      Icon(context.streamIcons.chainLink3, size: 12),
                      SizedBox(width: spacing.xxs),
                      Expanded(
                        child: Text(
                          url,
                          style: bodyStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
