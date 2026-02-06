import 'package:flutter/widgets.dart';

import '../../../stream_core_flutter.dart';

class MediaBadge extends StatelessWidget {
  const MediaBadge({
    super.key,
    required this.type,
    required this.duration,
  });

  final MediaBadgeType type;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.streamColorScheme.backgroundInverse,
        shape: BoxShape.circle,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: context.streamSpacing.xs,
        vertical: context.streamSpacing.xxs,
      ),
      child: Column(
        children: [
          Icon(
            switch (type) {
              MediaBadgeType.video => context.streamIcons.videoSolid,
              MediaBadgeType.audio => context.streamIcons.microphoneSolid,
            },
            size: 12,
            color: context.streamColorScheme.textPrimary,
          ),

          Text(duration.toReadableString()),
        ],
      ),
    );
  }
}

extension on Duration {
  String toReadableString() {
    if (inSeconds < 60) {
      return '${inSeconds}s';
    }
    if (inSeconds < 3600) {
      return '${inMinutes}m';
    }
    return '${inHours}h';
  }
}

enum MediaBadgeType {
  video,
  audio,
}
