import 'package:flutter/material.dart';
import 'package:svg_icon_widget/svg_icon_widget.dart';

import '../../factory/stream_component_factory.dart';
import '../../theme/primitives/stream_colors.dart';
import '../../theme/primitives/stream_radius.dart';
import '../../theme/primitives/stream_spacing.dart';
import '../../theme/semantics/stream_color_scheme.dart';
import '../../theme/semantics/stream_text_theme.dart';
import '../../theme/stream_theme_extensions.dart';

/// A pill-shaped overlay badge that identifies the source of content.
///
/// [StreamImageSourceBadge] displays a leading icon alongside a label in a
/// semi-transparent dark pill. It's used as an image overlay to indicate
/// the origin of media content (e.g., Giphy, Imgur).
///
/// Pre-built badges are available for common sources:
///
/// ```dart
/// StreamImageSourceBadge.giphy
/// StreamImageSourceBadge.imgur
/// ```
///
/// {@tool snippet}
///
/// Custom usage:
///
/// ```dart
/// StreamImageSourceBadge(
///   leading: SvgIcon(context.streamIcons.giphy),
///   label: Text('GIPHY'),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamRetryBadge], a badge for retry actions.
///  * [StreamBadgeCount], a badge for displaying counts.
class StreamImageSourceBadge extends StatelessWidget {
  /// Creates a source badge with the given [leading] icon and [label].
  StreamImageSourceBadge({
    super.key,
    required Widget leading,
    required Widget label,
    Color? backgroundColor,
    Color? foregroundColor,
  }) : props = .new(
         leading: leading,
         label: label,
         backgroundColor: backgroundColor,
         foregroundColor: foregroundColor,
       );

  /// A Giphy source badge.
  static Widget giphy = StreamImageSourceBadge(
    leading: const _GiphyIcon(),
    label: const Text('GIPHY'),
  );

  /// An Imgur source badge.
  static Widget imgur = StreamImageSourceBadge(
    leading: const _ImgurIcon(),
    label: const Text('IMGUR'),
  );

  /// The properties that configure this source badge.
  final StreamImageSourceBadgeProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).imageSourceBadge;
    if (builder != null) return builder(context, props);
    return DefaultStreamImageSourceBadge(props: props);
  }
}

/// Properties for configuring a [StreamImageSourceBadge].
///
/// This class holds all the configuration options for a source badge,
/// allowing them to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamImageSourceBadge], which uses these properties.
///  * [DefaultStreamImageSourceBadge], the default implementation.
class StreamImageSourceBadgeProps {
  /// Creates properties for a source badge.
  const StreamImageSourceBadgeProps({
    required this.leading,
    required this.label,
    this.backgroundColor,
    this.foregroundColor,
  });

  /// The leading icon widget.
  ///
  /// Typically a brand logo or icon identifying the content source.
  final Widget leading;

  /// The label widget.
  ///
  /// Typically a [Text] widget displaying the source name
  /// (e.g., "GIPHY", "IMGUR").
  final Widget label;

  /// The background color of the badge.
  ///
  /// If null, defaults to [StreamColors.black75].
  final Color? backgroundColor;

  /// The foreground color applied to the label text and icon.
  ///
  /// If null, defaults to [StreamColorScheme.textOnAccent].
  final Color? foregroundColor;
}

/// The default implementation of [StreamImageSourceBadge].
///
/// Renders a pill-shaped overlay badge with a leading icon and label.
/// Styling is resolved from the current [StreamColorScheme],
/// [StreamTextTheme], [StreamSpacing], and [StreamRadius].
///
/// See also:
///
///  * [StreamImageSourceBadge], the public API widget.
///  * [StreamImageSourceBadgeProps], which configures this widget.
class DefaultStreamImageSourceBadge extends StatelessWidget {
  /// Creates a default source badge with the given [props].
  const DefaultStreamImageSourceBadge({super.key, required this.props});

  /// The properties that configure this source badge.
  final StreamImageSourceBadgeProps props;

  @override
  Widget build(BuildContext context) {
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;
    final textTheme = context.streamTextTheme;
    final colorScheme = context.streamColorScheme;

    final backgroundColor = props.backgroundColor ?? StreamColors.black75;
    final foregroundColor = props.foregroundColor ?? colorScheme.textOnAccent;

    return AnimatedContainer(
      height: 24,
      duration: kThemeChangeDuration,
      padding: .directional(
        start: spacing.xxs,
        top: spacing.xxxs,
        bottom: spacing.xxxs,
        end: spacing.xs,
      ),
      decoration: ShapeDecoration(
        color: backgroundColor,
        shape: RoundedSuperellipseBorder(borderRadius: .all(radius.lg)),
      ),
      child: DefaultTextStyle(
        style: textTheme.metadataEmphasis.copyWith(color: foregroundColor),
        child: IconTheme(
          data: IconThemeData(color: foregroundColor, size: 16),
          child: Row(
            mainAxisSize: .min,
            spacing: spacing.xxs,
            children: [props.leading, props.label],
          ),
        ),
      ),
    );
  }
}

class _GiphyIcon extends StatelessWidget {
  const _GiphyIcon();

  @override
  Widget build(BuildContext context) => SvgIcon(context.streamIcons.giphy);
}

class _ImgurIcon extends StatelessWidget {
  const _ImgurIcon();

  @override
  Widget build(BuildContext context) => SvgIcon(context.streamIcons.imgur);
}
