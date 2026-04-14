import 'package:flutter/material.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/primitives/stream_icons.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/stream_theme_extensions.dart';

/// Predefined sizes for [StreamErrorBadge].
///
/// Each size corresponds to a specific diameter and icon size in logical pixels.
enum StreamErrorBadgeSize {
  /// Medium badge (24px diameter, 20px icon).
  md(24, 20),

  /// Small badge (20px diameter, 16px icon).
  sm(20, 16),

  /// Extra-small badge (16px diameter, 12px icon).
  xs(16, 12)
  ;

  const StreamErrorBadgeSize(this.value, this.iconSize);

  /// The diameter of the badge in logical pixels.
  final double value;

  /// The icon size for this badge size.
  final double iconSize;
}

/// A circular error badge that displays an exclamation mark icon.
///
/// [StreamErrorBadge] is used to indicate a failed operation, such as a
/// message that could not be sent. It renders as a fixed-size circle with
/// an error-colored background and an exclamation mark icon.
///
/// {@tool snippet}
///
/// Basic usage:
///
/// ```dart
/// StreamErrorBadge()
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Medium variant:
///
/// ```dart
/// StreamErrorBadge(size: StreamErrorBadgeSize.md)
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamErrorBadgeSize], the available size variants.
///  * [StreamRetryBadge], a badge for indicating retryable actions.
///  * [StreamBadgeNotification], a badge for displaying notification counts.
class StreamErrorBadge extends StatelessWidget {
  /// Creates an error badge.
  StreamErrorBadge({
    super.key,
    StreamErrorBadgeSize? size,
  }) : props = .new(size: size);

  /// The properties that configure this error badge.
  final StreamErrorBadgeProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).errorBadge;
    if (builder != null) return builder(context, props);
    return DefaultStreamErrorBadge(props: props);
  }
}

/// Properties for configuring a [StreamErrorBadge].
///
/// This class holds all the configuration options for an error badge,
/// allowing them to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamErrorBadge], which uses these properties.
///  * [DefaultStreamErrorBadge], the default implementation.
class StreamErrorBadgeProps {
  /// Creates properties for an error badge.
  const StreamErrorBadgeProps({this.size});

  /// The size of the badge.
  ///
  /// If null, defaults to [StreamErrorBadgeSize.sm].
  final StreamErrorBadgeSize? size;
}

/// The default implementation of [StreamErrorBadge].
///
/// Renders a circular badge with an exclamation mark icon. Styling is
/// resolved from the current [StreamColorScheme] and [StreamIcons].
///
/// See also:
///
///  * [StreamErrorBadge], the public API widget.
///  * [StreamErrorBadgeProps], which configures this widget.
class DefaultStreamErrorBadge extends StatelessWidget {
  /// Creates a default error badge with the given [props].
  const DefaultStreamErrorBadge({super.key, required this.props});

  /// The properties that configure this error badge.
  final StreamErrorBadgeProps props;

  @override
  Widget build(BuildContext context) {
    final icons = context.streamIcons;
    final colorScheme = context.streamColorScheme;

    final effectiveSize = props.size ?? StreamErrorBadgeSize.sm;

    final border = Border.all(
      width: 2,
      color: colorScheme.borderOnInverse,
      strokeAlign: BorderSide.strokeAlignOutside,
    );

    return AnimatedContainer(
      width: effectiveSize.value,
      height: effectiveSize.value,
      clipBehavior: Clip.antiAlias,
      duration: kThemeChangeDuration,
      decoration: BoxDecoration(shape: BoxShape.circle, color: colorScheme.accentError),
      foregroundDecoration: BoxDecoration(shape: BoxShape.circle, border: border),
      child: IconTheme(
        data: .new(size: effectiveSize.iconSize, color: colorScheme.textOnAccent),
        child: Center(child: Icon(icons.exclamationMarkFill)),
      ),
    );
  }
}
