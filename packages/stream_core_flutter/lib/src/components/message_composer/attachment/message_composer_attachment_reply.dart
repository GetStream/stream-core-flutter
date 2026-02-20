import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../../stream_core_flutter.dart';
import 'message_composer_attachment_container.dart';

class MessageComposerAttachmentReply extends StatelessWidget {
  const MessageComposerAttachmentReply({
    super.key,
    required this.title,
    required this.subtitle,
    this.image,
    this.onRemovePressed,
    this.style = ReplyStyle.incoming,
  });

  final String title;
  final String subtitle;
  final ImageProvider? image;
  final VoidCallback? onRemovePressed;
  final ReplyStyle style;

  @override
  Widget build(BuildContext context) {
    final messageTheme = context.streamMessageTheme.mergeWithDefaults(context);
    final messageStyle = switch (style) {
      ReplyStyle.incoming => messageTheme.incoming,
      ReplyStyle.outgoing => messageTheme.outgoing,
    };

    final indicatorColor = messageStyle?.replyIndicatorColor;
    final backgroundColor = messageStyle?.backgroundColor;
    final textColor = messageStyle?.textColor;

    final spacing = context.streamSpacing;
    return StreamMessageComposerAttachmentContainer(
      onRemovePressed: onRemovePressed,
      backgroundColor: backgroundColor,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 2, bottom: 2),
              color: indicatorColor,
              child: const SizedBox(
                width: 2,
                height: double.infinity,
              ),
            ),
            SizedBox(width: spacing.xs),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.streamTextTheme.metadataEmphasis.copyWith(color: textColor)),
                  Row(
                    children: [
                      if (image != null) ...[
                        Icon(context.streamIcons.camera1, size: 12),
                        SizedBox(width: spacing.xxs),
                      ],
                      Expanded(
                        child: Text(
                          subtitle,
                          style: context.streamTextTheme.metadataDefault.copyWith(color: textColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (image != null) ...[
              SizedBox(width: spacing.xs),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(context.streamRadius.md),
                  image: DecorationImage(image: image!, fit: BoxFit.cover),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum ReplyStyle {
  incoming,
  outgoing,
}
