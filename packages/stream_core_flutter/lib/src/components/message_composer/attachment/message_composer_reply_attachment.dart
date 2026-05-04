import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../../stream_core_flutter.dart';

const _kDefaultConstraints = BoxConstraints(minWidth: 272, minHeight: 56);

const _kIndicatorWidth = 2.0;
const _kIndicatorHeight = 36.0;

enum ReplyStyle {
  incoming,
  outgoing,
}

class MessageComposerReplyAttachment extends StatelessWidget {
  const MessageComposerReplyAttachment({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onRemovePressed,
    this.style = .incoming,
  });

  final Widget title;
  final Widget subtitle;
  final Widget? trailing;
  final VoidCallback? onRemovePressed;
  final ReplyStyle style;

  @override
  Widget build(BuildContext context) {
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    final textTheme = context.streamTextTheme;
    final colorScheme = context.streamColorScheme;

    final backgroundColor = switch (style) {
      ReplyStyle.incoming => colorScheme.backgroundSurface,
      ReplyStyle.outgoing => colorScheme.brand.shade100,
    };

    final indicatorColor = switch (style) {
      ReplyStyle.incoming => colorScheme.chrome.shade400,
      ReplyStyle.outgoing => colorScheme.brand.shade400,
    };

    final textColor = switch (style) {
      ReplyStyle.incoming => colorScheme.textPrimary,
      ReplyStyle.outgoing => colorScheme.brand.shade900,
    };

    return StreamMessageComposerAttachmentContainer(
      onRemovePressed: onRemovePressed,
      backgroundColor: backgroundColor,
      borderColor: StreamColors.transparent,
      child: ConstrainedBox(
        constraints: _kDefaultConstraints,
        child: Padding(
          padding: .all(spacing.xs),
          child: Row(
            spacing: spacing.xs,
            children: [
              Expanded(
                child: Row(
                  spacing: spacing.xs,
                  children: [
                    Container(
                      width: _kIndicatorWidth,
                      height: _kIndicatorHeight,
                      decoration: BoxDecoration(
                        color: indicatorColor,
                        borderRadius: .all(radius.max),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisSize: .min,
                        spacing: spacing.xxxs,
                        mainAxisAlignment: .center,
                        crossAxisAlignment: .start,
                        children: [
                          DefaultTextStyle.merge(
                            maxLines: 1,
                            style: textTheme.metadataEmphasis.copyWith(color: textColor),
                            overflow: TextOverflow.ellipsis,
                            child: title,
                          ),
                          DefaultTextStyle.merge(
                            maxLines: 1,
                            style: textTheme.metadataDefault.copyWith(color: textColor),
                            overflow: TextOverflow.ellipsis,
                            child: subtitle,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}
