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
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.all(spacing.xxs),
          padding: EdgeInsets.fromLTRB(spacing.md, spacing.md, spacing.sm, spacing.md),
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.all(context.streamRadius.lg),
            border: Border.all(
              color: context.streamColorScheme.borderDefault,
            ),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(context.streamRadius.lg),
          ),
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
