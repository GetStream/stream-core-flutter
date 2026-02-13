import 'package:flutter/widgets.dart';

import '../../../stream_core_flutter.dart';

class StreamMediaBadge extends StatelessWidget {
  const StreamMediaBadge({super.key, required this.type, this.duration});

  final MediaBadgeType type;
  final Duration? duration;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.streamColorScheme.backgroundInverse,
        borderRadius: BorderRadius.all(context.streamRadius.max),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: context.streamSpacing.xs,
        vertical: context.streamSpacing.xxs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            switch (type) {
              MediaBadgeType.video => context.streamIcons.videoSolid,
              MediaBadgeType.audio => context.streamIcons.microphoneSolid,
            },
            size: 12,
            color: context.streamColorScheme.textOnDark,
          ),

          if (duration case final duration?)
            Text(
              duration.toReadableString(),
              style: context.streamTextTheme.numericMd.copyWith(color: context.streamColorScheme.textOnDark),
            ),
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

enum MediaBadgeType { video, audio }
