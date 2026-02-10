import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../../stream_core_flutter.dart';
import '../../controls/remove_control.dart';

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
    final chatTheme = context.streamChatTheme;
    final chatDefaults = ChatThemeDefaults(context: context).data;
    final indicatorColor = switch (style) {
      ReplyStyle.incoming => chatTheme.replyIndicatorIncoming ?? chatDefaults.replyIndicatorIncoming!,
      ReplyStyle.outgoing => chatTheme.replyIndicatorOutgoing ?? chatDefaults.replyIndicatorOutgoing!,
    };
    final backgroundColor = switch (style) {
      ReplyStyle.incoming => chatTheme.backgroundIncoming ?? chatDefaults.backgroundIncoming,
      ReplyStyle.outgoing => chatTheme.backgroundOutgoing ?? chatDefaults.backgroundOutgoing,
    };

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
                      Text(title, style: context.streamTextTheme.metadataEmphasis),
                      Row(
                        children: [
                          if (image != null) ...[
                            Icon(context.streamIcons.camera1, size: 12),
                            SizedBox(width: spacing.xxs),
                          ],
                          Expanded(child: Text(subtitle, style: context.streamTextTheme.metadataDefault)),
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
            child: RemoveControl(onPressed: onRemovePressed),
          ),
      ],
    );
  }
}

enum ReplyStyle {
  incoming,
  outgoing,
}
