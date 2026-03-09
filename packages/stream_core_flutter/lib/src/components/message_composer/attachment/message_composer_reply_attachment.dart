import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../../stream_core_flutter.dart';

class MessageComposerReplyAttachment extends StatelessWidget {
  const MessageComposerReplyAttachment({
    super.key,
    required this.title,
    required this.subtitle,
    this.image,
    this.onRemovePressed,
    this.style = ReplyStyle.incoming,
  });

  final Widget title;
  final Widget subtitle;
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
      child: Row(
        spacing: spacing.xs,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2, bottom: 2),
            color: indicatorColor,
            child: const SizedBox(width: 2, height: 36),
          ),
          Expanded(
            child: Column(
              spacing: spacing.xxxs,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DefaultTextStyle.merge(
                  style: context.streamTextTheme.metadataEmphasis.copyWith(color: textColor),
                  child: title,
                ),
                DefaultTextStyle.merge(
                  style: context.streamTextTheme.metadataDefault.copyWith(color: textColor),
                  child: subtitle,
                ),
              ],
            ),
          ),
          if (image != null) ...[
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
    );
  }
}

enum ReplyStyle {
  incoming,
  outgoing,
}
