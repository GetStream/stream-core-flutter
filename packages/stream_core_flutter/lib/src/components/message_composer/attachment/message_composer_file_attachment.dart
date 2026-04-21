import 'package:flutter/widgets.dart';

import '../../../../stream_core_flutter.dart';

class MessageComposerFileAttachment extends StatelessWidget {
  const MessageComposerFileAttachment({
    super.key,
    required this.title,
    this.subtitle,
    this.fileTypeIcon,
    this.onRemovePressed,
  });

  final Widget title;
  final Widget? subtitle;
  final StreamFileTypeIcon? fileTypeIcon;
  final VoidCallback? onRemovePressed;

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    final textTheme = context.streamTextTheme;
    final colorScheme = context.streamColorScheme;

    final titleStyle = textTheme.metadataEmphasis.copyWith(color: colorScheme.textPrimary);
    final subtitleStyle = textTheme.metadataDefault.copyWith(color: colorScheme.textSecondary);

    final effectiveTitle = DefaultTextStyle.merge(style: titleStyle, maxLines: 1, overflow: .ellipsis, child: title);

    Widget? effectiveSubtitle;
    if (subtitle case final title?) {
      effectiveSubtitle = DefaultTextStyle.merge(style: subtitleStyle, maxLines: 1, overflow: .ellipsis, child: title);
    }

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
                  effectiveTitle,
                  ?effectiveSubtitle,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
