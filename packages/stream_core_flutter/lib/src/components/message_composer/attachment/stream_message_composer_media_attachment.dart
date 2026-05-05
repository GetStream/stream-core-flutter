import 'package:flutter/widgets.dart';

import '../../../../stream_core_flutter.dart';

/// A composer attachment that displays a fixed-size thumbnail for an image or video.
///
/// [StreamMessageComposerMediaAttachment] displays a [child] (typically an image or video
/// thumbnail) inside a square frame (default 72×72), with an optional [mediaBadge] overlaid
/// at the bottom-start corner — used to indicate video duration or media type. The [child]
/// is given tight constraints equal to the thumbnail bounds, so an [Image] with
/// [BoxFit.cover] fills automatically.
///
/// {@tool snippet}
///
/// An image media attachment:
///
/// ```dart
/// StreamMessageComposerMediaAttachment(
///   onRemovePressed: () => removeAttachment(),
///   child: Image(image: NetworkImage(url), fit: BoxFit.cover),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// A video thumbnail with a duration badge:
///
/// ```dart
/// StreamMessageComposerMediaAttachment(
///   mediaBadge: StreamMediaBadge(
///     type: MediaBadgeType.video,
///     duration: Duration(minutes: 1, seconds: 42),
///   ),
///   onRemovePressed: () => removeAttachment(),
///   child: Image(image: NetworkImage(thumbnailUrl), fit: BoxFit.cover),
/// )
/// ```
/// {@end-tool}
///
/// ## Theming
///
/// [StreamMessageComposerMediaAttachment] uses [StreamMessageComposerMediaAttachmentThemeData]
/// for default styling, including the border color and the thumbnail dimensions.
/// Per-instance [style] takes precedence over the inherited theme.
///
/// See also:
///
///  * [StreamMessageComposerMediaAttachmentTheme], for customizing media attachments globally.
///  * [StreamMessageComposerAttachment], the surrounding container.
///  * [StreamMediaBadge], the badge typically passed as [mediaBadge].
///  * [DefaultStreamMessageComposerMediaAttachment], the default visual implementation.
class StreamMessageComposerMediaAttachment extends StatelessWidget {
  /// Creates a media attachment with a custom [child].
  StreamMessageComposerMediaAttachment({
    super.key,
    required Widget child,
    VoidCallback? onRemovePressed,
    Widget? mediaBadge,
    StreamMessageComposerMediaAttachmentThemeData? style,
  }) : props = .new(
         child: child,
         onRemovePressed: onRemovePressed,
         mediaBadge: mediaBadge,
         style: style,
       );

  /// The properties that configure this media attachment.
  final StreamMessageComposerMediaAttachmentProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).messageComposerMediaAttachment;
    if (builder != null) return builder(context, props);
    return DefaultStreamMessageComposerMediaAttachment(props: props);
  }
}

/// Properties for configuring a [StreamMessageComposerMediaAttachment].
///
/// This class holds all the configuration options for a media attachment, allowing them to
/// be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamMessageComposerMediaAttachment], which uses these properties.
///  * [DefaultStreamMessageComposerMediaAttachment], the default implementation.
class StreamMessageComposerMediaAttachmentProps {
  /// Creates properties for a media attachment.
  const StreamMessageComposerMediaAttachmentProps({
    required this.child,
    this.onRemovePressed,
    this.mediaBadge,
    this.style,
  });

  /// The thumbnail content, clipped to the surrounding container's rounded shape.
  ///
  /// Given tight constraints equal to the thumbnail bounds (default 72×72), so an [Image]
  /// with [BoxFit.cover] fills automatically without any extra wrapper.
  final Widget child;

  /// An optional badge overlaid at the bottom-start corner of the thumbnail.
  ///
  /// Typically a [StreamMediaBadge] used to indicate video duration or media type.
  final Widget? mediaBadge;

  /// Called when the remove button is tapped.
  ///
  /// When null, no remove control is shown on the surrounding container.
  final VoidCallback? onRemovePressed;

  /// Per-instance style overrides.
  ///
  /// Fields left null fall back to the inherited [StreamMessageComposerMediaAttachmentTheme],
  /// then to built-in defaults.
  final StreamMessageComposerMediaAttachmentThemeData? style;
}

/// The default implementation of [StreamMessageComposerMediaAttachment].
///
/// Renders the media attachment with theming support from
/// [StreamMessageComposerMediaAttachmentTheme]. It is used as the default factory
/// implementation in [StreamComponentFactory].
///
/// See also:
///
///  * [StreamMessageComposerMediaAttachment], the public API widget.
///  * [StreamMessageComposerMediaAttachmentProps], which configures this widget.
class DefaultStreamMessageComposerMediaAttachment extends StatelessWidget {
  /// Creates a default media attachment with the given [props].
  const DefaultStreamMessageComposerMediaAttachment({super.key, required this.props});

  /// The properties that configure this media attachment.
  final StreamMessageComposerMediaAttachmentProps props;

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    final theme = context.streamMessageComposerMediaAttachmentTheme.merge(props.style);
    final defaults = _StreamMessageComposerMediaAttachmentDefaults(context);

    final effectiveBorderColor = theme.borderColor ?? defaults.borderColor;
    final effectiveSize = theme.size ?? defaults.size;

    return StreamMessageComposerAttachment(
      onRemovePressed: props.onRemovePressed,
      style: StreamMessageComposerAttachmentThemeData(
        side: BorderSide(color: effectiveBorderColor),
      ),
      child: SizedBox.fromSize(
        size: effectiveSize,
        child: Stack(
          fit: .expand,
          children: [
            props.child,
            if (props.mediaBadge case final badge?)
              PositionedDirectional(
                start: spacing.xxs,
                bottom: spacing.xxs,
                child: badge,
              ),
          ],
        ),
      ),
    );
  }
}

// Default theme values for [StreamMessageComposerMediaAttachment].
//
// Used when no explicit value is provided via
// [StreamMessageComposerMediaAttachmentThemeData].
class _StreamMessageComposerMediaAttachmentDefaults extends StreamMessageComposerMediaAttachmentThemeData {
  _StreamMessageComposerMediaAttachmentDefaults(this._context);

  final BuildContext _context;

  late final _colorScheme = _context.streamColorScheme;

  @override
  Color get borderColor => _colorScheme.borderOpacitySubtle;

  @override
  Size get size => const Size.square(72);
}
