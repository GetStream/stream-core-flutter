import 'package:flutter/widgets.dart';

import '../../../../stream_core_flutter.dart';
import '../../controls/remove_control.dart';

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
    final chatTheme = context.streamChatTheme;
    final chatDefaults = ChatThemeDefaults(context: context).data;
    final backgroundColor = chatTheme.backgroundOutgoing ?? chatDefaults.backgroundOutgoing;
    final textColor = chatTheme.textOutgoing ?? chatDefaults.textOutgoing;

    final titleStyle = context.streamTextTheme.metadataEmphasis.copyWith(color: textColor);
    final bodyStyle = context.streamTextTheme.metadataDefault.copyWith(color: textColor);

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
