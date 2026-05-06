import 'package:flutter/material.dart';

import '../../../../stream_core_flutter.dart';

const _kDefaultConstraints = BoxConstraints(minHeight: 56);

const _kIndicatorWidth = 2.0;
const _kIndicatorVerticalMargin = 2.0;

/// The direction of the message being quoted by a reply preview.
///
/// Drives the direction-aware default colors of [StreamMessageComposerReplyAttachment] when the
/// corresponding theme fields are not provided.
enum StreamReplyDirection {
  /// The quoted message was received from another user.
  incoming,

  /// The quoted message was sent by the current user.
  outgoing,
}

/// A composer attachment that previews the message being replied to.
///
/// [StreamMessageComposerReplyAttachment] displays a leading indicator bar, a [title]
/// (typically the quoted user's name), a [subtitle] (a preview of the quoted message body),
/// and an optional trailing [thumbnail] of the quoted attachment. Both labels render on a
/// single line and ellipsize on overflow.
///
/// [direction] selects direction-aware default colors: incoming previews use a neutral
/// surface tint with a chrome indicator, outgoing previews use a brand-tinted background with
/// a brand indicator.
///
/// The preview fills the parent's width and is at least 56 tall, growing vertically to fit
/// longer content.
///
/// {@tool snippet}
///
/// A reply preview for an outgoing message:
///
/// ```dart
/// StreamMessageComposerReplyAttachment(
///   title: Text('Reply to John Doe'),
///   subtitle: Text('We had a great time during our holiday.'),
///   direction: StreamReplyDirection.outgoing,
///   onRemovePressed: () => cancelReply(),
/// )
/// ```
/// {@end-tool}
///
/// ## Theming
///
/// [StreamMessageComposerReplyAttachment] uses
/// [StreamMessageComposerReplyAttachmentThemeData] for default styling, falling back to
/// direction-aware defaults selected by [direction]. Per-instance [style] takes precedence
/// over the inherited theme.
///
/// See also:
///
///  * [StreamMessageComposerReplyAttachmentTheme], for customizing reply previews globally.
///  * [StreamMessageComposerAttachment], the surrounding container.
///  * [StreamReplyDirection], which selects direction-aware defaults.
///  * [DefaultStreamMessageComposerReplyAttachment], the default visual implementation.
class StreamMessageComposerReplyAttachment extends StatelessWidget {
  /// Creates a reply preview attachment.
  StreamMessageComposerReplyAttachment({
    super.key,
    required Widget title,
    required Widget subtitle,
    Widget? thumbnail,
    VoidCallback? onRemovePressed,
    StreamReplyDirection direction = .incoming,
    StreamMessageComposerReplyAttachmentThemeData? style,
  }) : props = .new(
         title: title,
         subtitle: subtitle,
         thumbnail: thumbnail,
         onRemovePressed: onRemovePressed,
         direction: direction,
         style: style,
       );

  /// The properties that configure this reply preview.
  final StreamMessageComposerReplyAttachmentProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).messageComposerReplyAttachment;
    if (builder != null) return builder(context, props);
    return DefaultStreamMessageComposerReplyAttachment(props: props);
  }
}

/// Properties for configuring a [StreamMessageComposerReplyAttachment].
///
/// This class holds all the configuration options for a reply preview, allowing them to be
/// passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamMessageComposerReplyAttachment], which uses these properties.
///  * [DefaultStreamMessageComposerReplyAttachment], the default implementation.
class StreamMessageComposerReplyAttachmentProps {
  /// Creates properties for a reply preview attachment.
  const StreamMessageComposerReplyAttachmentProps({
    required this.title,
    required this.subtitle,
    this.thumbnail,
    this.onRemovePressed,
    this.direction = .incoming,
    this.style,
  });

  /// The primary label shown on the first line.
  ///
  /// Typically a [Text] showing the quoted user's name. Renders on a single line and
  /// ellipsizes on overflow.
  final Widget title;

  /// The secondary label shown below [title].
  ///
  /// Typically a [Text] previewing the quoted message body. Renders on a single line and
  /// ellipsizes on overflow.
  final Widget subtitle;

  /// An optional thumbnail of the quoted attachment, rendered at the end of the preview row.
  ///
  /// Sized and shaped via the inherited theme (default 40×40 with rounded corners). The
  /// caller-provided widget is responsible for filling the thumbnail bounds — typically an
  /// [Image] with [BoxFit.cover]. When null, the title/subtitle column expands to the full
  /// width of the row.
  final Widget? thumbnail;

  /// Called when the remove button is tapped.
  ///
  /// When null, no remove control is shown on the surrounding container.
  final VoidCallback? onRemovePressed;

  /// Selects direction-aware default colors for the background, indicator bar, and text.
  ///
  /// Has no effect on fields explicitly provided through [style] or the inherited theme.
  /// Defaults to [StreamReplyDirection.incoming].
  final StreamReplyDirection direction;

  /// Per-instance style overrides.
  ///
  /// Fields left null fall back to the inherited [StreamMessageComposerReplyAttachmentTheme],
  /// then to direction-aware defaults selected by [direction].
  final StreamMessageComposerReplyAttachmentThemeData? style;
}

/// The default implementation of [StreamMessageComposerReplyAttachment].
///
/// Renders the reply preview with theming support from
/// [StreamMessageComposerReplyAttachmentTheme]. It is used as the default factory
/// implementation in [StreamComponentFactory].
///
/// See also:
///
///  * [StreamMessageComposerReplyAttachment], the public API widget.
///  * [StreamMessageComposerReplyAttachmentProps], which configures this widget.
class DefaultStreamMessageComposerReplyAttachment extends StatelessWidget {
  /// Creates a default reply preview with the given [props].
  const DefaultStreamMessageComposerReplyAttachment({super.key, required this.props});

  /// The properties that configure this reply preview.
  final StreamMessageComposerReplyAttachmentProps props;

  @override
  Widget build(BuildContext context) {
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    final theme = context.streamMessageComposerReplyAttachmentTheme.merge(props.style);
    final defaults = _StreamMessageComposerReplyAttachmentDefaults(context, props.direction);

    final effectiveBackgroundColor = theme.backgroundColor ?? defaults.backgroundColor;
    final effectiveIndicatorColor = theme.indicatorColor ?? defaults.indicatorColor;
    final effectiveTitleStyle = theme.titleTextStyle ?? defaults.titleTextStyle;
    final effectiveSubtitleStyle = theme.subtitleTextStyle ?? defaults.subtitleTextStyle;
    final effectivePadding = theme.padding ?? defaults.padding;
    final effectiveThumbnailSide = theme.thumbnailSide ?? defaults.thumbnailSide;
    final effectiveThumbnailShape = (theme.thumbnailShape ?? defaults.thumbnailShape).copyWith(
      side: effectiveThumbnailSide,
    );
    final effectiveThumbnailSize = theme.thumbnailSize ?? defaults.thumbnailSize;

    final effectiveTitle = DefaultTextStyle.merge(
      style: effectiveTitleStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      child: props.title,
    );

    final effectiveSubtitle = DefaultTextStyle.merge(
      style: effectiveSubtitleStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      child: props.subtitle,
    );

    Widget? effectiveThumbnail;
    if (props.thumbnail case final thumbnail?) {
      effectiveThumbnail = SizedBox.fromSize(
        size: effectiveThumbnailSize,
        child: Material(
          type: MaterialType.transparency,
          clipBehavior: Clip.hardEdge,
          shape: effectiveThumbnailShape,
          child: thumbnail,
        ),
      );
    }

    return StreamMessageComposerAttachment(
      onRemovePressed: props.onRemovePressed,
      style: StreamMessageComposerAttachmentThemeData(
        backgroundColor: effectiveBackgroundColor,
        side: BorderSide.none,
      ),
      child: ConstrainedBox(
        constraints: _kDefaultConstraints,
        child: Padding(
          padding: effectivePadding,
          child: IntrinsicHeight(
            child: Row(
              mainAxisSize: .min,
              spacing: spacing.xs,
              children: [
                VerticalDivider(
                  width: _kIndicatorWidth,
                  thickness: _kIndicatorWidth,
                  indent: _kIndicatorVerticalMargin,
                  endIndent: _kIndicatorVerticalMargin,
                  radius: BorderRadius.all(radius.max),
                  color: effectiveIndicatorColor,
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: .min,
                    spacing: spacing.xxxs,
                    mainAxisAlignment: .center,
                    crossAxisAlignment: .start,
                    children: [effectiveTitle, effectiveSubtitle],
                  ),
                ),
                ?effectiveThumbnail,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Default theme values for [StreamMessageComposerReplyAttachment].
//
// Used when no explicit value is provided via
// [StreamMessageComposerReplyAttachmentThemeData]. Direction-aware defaults
// are selected by [_direction].
class _StreamMessageComposerReplyAttachmentDefaults extends StreamMessageComposerReplyAttachmentThemeData {
  _StreamMessageComposerReplyAttachmentDefaults(this._context, this._direction);

  final BuildContext _context;
  final StreamReplyDirection _direction;

  late final _spacing = _context.streamSpacing;
  late final _textTheme = _context.streamTextTheme;
  late final _colorScheme = _context.streamColorScheme;

  late final Color _textColor = switch (_direction) {
    StreamReplyDirection.incoming => _colorScheme.textPrimary,
    StreamReplyDirection.outgoing => _colorScheme.brand.shade900,
  };

  @override
  Color get backgroundColor => switch (_direction) {
    StreamReplyDirection.incoming => _colorScheme.backgroundSurface,
    StreamReplyDirection.outgoing => _colorScheme.brand.shade100,
  };

  @override
  Color get indicatorColor => switch (_direction) {
    StreamReplyDirection.incoming => _colorScheme.chrome.shade400,
    StreamReplyDirection.outgoing => _colorScheme.brand.shade400,
  };

  @override
  TextStyle get titleTextStyle => _textTheme.metadataEmphasis.copyWith(color: _textColor);

  @override
  TextStyle get subtitleTextStyle => _textTheme.metadataDefault.copyWith(color: _textColor);

  @override
  EdgeInsetsGeometry get padding => EdgeInsets.all(_spacing.xs);

  @override
  OutlinedBorder get thumbnailShape => RoundedSuperellipseBorder(borderRadius: .all(_context.streamRadius.md));

  @override
  Size get thumbnailSize => const Size.square(40);
}
