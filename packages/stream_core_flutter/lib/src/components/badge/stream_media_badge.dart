import 'package:flutter/widgets.dart';

import '../../theme/stream_theme_extensions.dart';

/// Controls how a duration value is formatted inside [StreamMediaBadge].
enum MediaBadgeDurationFormat {
  /// Compact contextual format — floored, no exact time shown.
  ///
  /// - < 1 minute → `Xs`  (e.g. `8s`)
  /// - < 1 hour   → `Xm`  (e.g. `1m`, `10m`)
  /// - ≥ 1 hour   → `Xh`  (e.g. `1h`, `2h`)
  compact,

  /// Exact time format — no rounding or truncation.
  ///
  /// - < 1 hour → `M:SS`    (e.g. `0:08`, `10:08`)
  /// - ≥ 1 hour → `H:MM:SS` (e.g. `1:00:08`)
  exact,
}

class StreamMediaBadge extends StatelessWidget {
  const StreamMediaBadge({
    super.key,
    required this.type,
    this.duration,
    this.durationFormat = MediaBadgeDurationFormat.compact,
    this.semanticsLabel,
  });

  final MediaBadgeType type;
  final Duration? duration;

  /// How the [duration] value is formatted. Defaults to [MediaBadgeDurationFormat.compact].
  final MediaBadgeDurationFormat durationFormat;

  /// An alternative semantics label for this badge.
  ///
  /// If present, the semantics of this widget will contain this value instead
  /// of the rendered icon and duration.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final icons = context.streamIcons;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    final textTheme = context.streamTextTheme;
    final colorScheme = context.streamColorScheme;

    Widget badge = Container(
      decoration: BoxDecoration(
        color: colorScheme.backgroundInverse,
        borderRadius: .all(radius.max),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: spacing.xs,
        vertical: spacing.xxs,
      ),
      child: Row(
        mainAxisSize: .min,
        spacing: spacing.xxs,
        children: [
          Icon(
            switch (type) {
              MediaBadgeType.video => icons.videoFill,
              MediaBadgeType.audio => icons.voiceFill,
            },
            size: 12,
            color: colorScheme.textOnInverse,
          ),

          if (duration case final duration?)
            Text(
              switch (durationFormat) {
                MediaBadgeDurationFormat.compact => duration.toCompactString(),
                MediaBadgeDurationFormat.exact => duration.toExactString(),
              },
              style: textTheme.numericMd.copyWith(color: colorScheme.textOnInverse),
            ),
        ],
      ),
    );

    if (semanticsLabel case final label?) {
      badge = Semantics(
        label: label,
        child: ExcludeSemantics(child: badge),
      );
    }

    return badge;
  }
}

extension on Duration {
  /// Compact contextual format, always floored.
  /// `8s`, `1m`, `10m`, `1h`, `2h`
  String toCompactString() {
    if (inSeconds < 60) {
      return '${inSeconds}s';
    }
    if (inSeconds < 3600) {
      return '${inMinutes}m';
    }
    return '${inHours}h';
  }

  /// Exact time format.
  /// `0:08`, `10:08`, `1:00:08`
  String toExactString() {
    final h = inHours;
    final m = inMinutes.remainder(60);
    final s = inSeconds.remainder(60);
    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

enum MediaBadgeType { video, audio }
