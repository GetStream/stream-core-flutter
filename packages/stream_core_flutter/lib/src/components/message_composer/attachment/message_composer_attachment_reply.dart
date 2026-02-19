import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../../stream_core_flutter.dart';

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
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.all(spacing.xxs),
          padding: EdgeInsets.all(spacing.xs),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.all(context.streamRadius.lg),
          ),
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

enum ReplyStyle {
  incoming,
  outgoing,
}
