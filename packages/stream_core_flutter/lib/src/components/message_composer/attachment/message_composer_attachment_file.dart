import 'package:flutter/widgets.dart';

import '../../../../stream_core_flutter.dart';
import 'message_composer_attachment_container.dart';

class MessageComposerAttachmentFile extends StatelessWidget {
  const MessageComposerAttachmentFile({
    super.key,
    this.title,
    this.fileTypeIcon,
    this.subtitle,
    this.onRemovePressed,
  });

  final StreamFileTypeIcon? fileTypeIcon;
  final String? title;
  final Widget? subtitle;
  final VoidCallback? onRemovePressed;

  @override
  Widget build(BuildContext context) {
    final textColor = context.streamColorScheme.textPrimary;
    final titleStyle = context.streamTextTheme.captionEmphasis.copyWith(color: textColor);
    final spacing = context.streamSpacing;

    return StreamMessageComposerAttachmentContainer(
      padding: EdgeInsets.fromLTRB(spacing.md, spacing.md, spacing.sm, spacing.md),
      onRemovePressed: onRemovePressed,
      borderColor: context.streamColorScheme.borderDefault,
      child: Row(
        children: [
          ?fileTypeIcon,
          SizedBox(width: spacing.xs),
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
                ?subtitle,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
