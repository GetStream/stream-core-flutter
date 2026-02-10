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
  });

  final String title;
  final String subtitle;
  final ImageProvider? image;
  final VoidCallback? onRemovePressed;

  @override
  Widget build(BuildContext context) {
    final chatTheme = context.streamChatTheme;
    final chatDefaults = ChatThemeDefaults(context: context).data;

    final spacing = context.streamSpacing;
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.all(spacing.xxs),
          decoration: BoxDecoration(
            color: chatTheme.backgroundIncoming ?? chatDefaults.backgroundIncoming,
            borderRadius: BorderRadius.all(context.streamRadius.lg),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(title),
                    Row(
                      children: [
                        if (image != null) Icon(context.streamIcons.camera1),
                        Expanded(child: Text(subtitle)),
                      ],
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
