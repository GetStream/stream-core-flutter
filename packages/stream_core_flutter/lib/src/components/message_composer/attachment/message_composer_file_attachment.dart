import 'package:flutter/widgets.dart';

import '../../../../stream_core_flutter.dart';

class MessageComposerFileAttachment extends StatelessWidget {
  const MessageComposerFileAttachment({
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
      onRemovePressed: onRemovePressed,
      child: Padding(
        padding: .directional(
          start: spacing.md,
          end: spacing.sm,
          top: spacing.md,
          bottom: spacing.md,
        ),
        child: Row(
          spacing: spacing.sm,
          children: [
            ?fileTypeIcon,
            Expanded(
              child: Column(
                spacing: spacing.xxs,
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
      ),
    );
  }
}
