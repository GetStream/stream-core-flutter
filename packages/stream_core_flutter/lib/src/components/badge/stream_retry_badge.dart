import 'package:flutter/material.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/primitives/stream_icons.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/stream_theme_extensions.dart';

/// Predefined sizes for [StreamRetryBadge].
///
/// Each size corresponds to a specific diameter and icon size in logical pixels.
enum StreamRetryBadgeSize {
  /// Large badge (32px diameter, 16px icon).
  lg(32, 16),

  /// Medium badge (24px diameter, 12px icon).
  md(24, 12)
  ;

  const StreamRetryBadgeSize(this.value, this.iconSize);

  /// The diameter of the badge in logical pixels.
  final double value;

  /// The icon size for this badge size.
  final double iconSize;
}

/// A circular retry badge that displays a clockwise arrow icon.
///
/// [StreamRetryBadge] is used to indicate that an action can be retried,
/// such as reloading a failed image or re-sending a message. It renders as
/// a fixed-size circle with an error-colored background and a retry icon.
///
/// {@tool snippet}
///
/// Basic usage:
///
/// ```dart
/// StreamRetryBadge()
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Large variant:
///
/// ```dart
/// StreamRetryBadge(size: StreamRetryBadgeSize.lg)
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamRetryBadgeSize], the available size variants.
///  * [StreamBadgeNotification], a badge for displaying notification counts.
class StreamRetryBadge extends StatelessWidget {
  /// Creates a retry badge.
  StreamRetryBadge({
    super.key,
    StreamRetryBadgeSize? size,
  }) : props = .new(size: size);

  /// The properties that configure this retry badge.
  final StreamRetryBadgeProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).retryBadge;
    if (builder != null) return builder(context, props);
    return DefaultStreamRetryBadge(props: props);
  }
}

/// Properties for configuring a [StreamRetryBadge].
///
/// This class holds all the configuration options for a retry badge,
/// allowing them to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamRetryBadge], which uses these properties.
///  * [DefaultStreamRetryBadge], the default implementation.
class StreamRetryBadgeProps {
  /// Creates properties for a retry badge.
  const StreamRetryBadgeProps({this.size});

  /// The size of the badge.
  ///
  /// If null, defaults to [StreamRetryBadgeSize.md].
  final StreamRetryBadgeSize? size;
}

/// The default implementation of [StreamRetryBadge].
///
/// Renders a circular badge with a retry icon. Styling is resolved from
/// the current [StreamColorScheme] and [StreamIcons].
///
/// See also:
///
///  * [StreamRetryBadge], the public API widget.
///  * [StreamRetryBadgeProps], which configures this widget.
class DefaultStreamRetryBadge extends StatelessWidget {
  /// Creates a default retry badge with the given [props].
  const DefaultStreamRetryBadge({super.key, required this.props});

  /// The properties that configure this retry badge.
  final StreamRetryBadgeProps props;

  @override
  Widget build(BuildContext context) {
    final icons = context.streamIcons;
    final colorScheme = context.streamColorScheme;

    final effectiveSize = props.size ?? StreamRetryBadgeSize.md;

    return AnimatedContainer(
      width: effectiveSize.value,
      height: effectiveSize.value,
      duration: kThemeChangeDuration,
      decoration: ShapeDecoration(
        color: colorScheme.accentError,
        shape: const CircleBorder(),
      ),
      foregroundDecoration: ShapeDecoration(
        shape: CircleBorder(
          side: BorderSide(
            width: 2,
            color: colorScheme.borderOnInverse,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
        ),
      ),
      child: Center(
        child: Icon(
          icons.retry16,
          size: effectiveSize.iconSize,
          color: colorScheme.textOnAccent,
        ),
      ),
    );
  }
}
