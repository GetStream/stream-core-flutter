import 'package:flutter/material.dart';

import '../../../../stream_core_flutter.dart';

const _kDefaultConstraints = BoxConstraints(minWidth: 290);

/// A composer attachment that previews a link with optional thumbnail, title, subtitle, and
/// caption.
///
/// [StreamMessageComposerLinkPreviewAttachment] displays an optional leading [thumbnail]
/// (typically a favicon or hero image), a [title] (the page title), a [subtitle] (the page
/// description), and a [caption] (typically the URL with a leading link icon). Each text
/// field renders on a single line and ellipsizes on overflow; null fields are omitted.
///
/// The preview has a minimum width of 290 and grows to fit longer content. It shrinks to fit
/// when a parent bounds the width below 290. Height adapts to the content.
///
/// {@tool snippet}
///
/// A link preview with title, subtitle, and a caption with a leading link icon:
///
/// ```dart
/// StreamMessageComposerLinkPreviewAttachment(
///   title: Text('Stream Chat'),
///   subtitle: Text('Build in-app chat in days, not months.'),
///   caption: Row(
///     spacing: 4,
///     children: [Icon(Icons.link, size: 12), Text('getstream.io')],
///   ),
///   thumbnail: Image(image: NetworkImage(faviconUrl), fit: BoxFit.cover),
///   onRemovePressed: () => removePreview(),
/// )
/// ```
/// {@end-tool}
///
/// ## Theming
///
/// [StreamMessageComposerLinkPreviewAttachment] uses
/// [StreamMessageComposerLinkPreviewAttachmentThemeData] for default styling, including the
/// thumbnail's size, shape, and border. Per-instance [style] takes precedence over the
/// inherited theme.
///
/// See also:
///
///  * [StreamMessageComposerLinkPreviewAttachmentTheme], for customizing link previews
///    globally.
///  * [StreamMessageComposerAttachment], the surrounding container.
///  * [DefaultStreamMessageComposerLinkPreviewAttachment], the default visual implementation.
class StreamMessageComposerLinkPreviewAttachment extends StatelessWidget {
  /// Creates a link preview attachment.
  StreamMessageComposerLinkPreviewAttachment({
    super.key,
    Widget? title,
    Widget? subtitle,
    Widget? caption,
    Widget? thumbnail,
    VoidCallback? onRemovePressed,
    StreamMessageComposerLinkPreviewAttachmentThemeData? style,
  }) : props = .new(
         title: title,
         subtitle: subtitle,
         caption: caption,
         thumbnail: thumbnail,
         onRemovePressed: onRemovePressed,
         style: style,
       );

  /// The properties that configure this link preview.
  final StreamMessageComposerLinkPreviewAttachmentProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).messageComposerLinkPreviewAttachment;
    if (builder != null) return builder(context, props);
    return DefaultStreamMessageComposerLinkPreviewAttachment(props: props);
  }
}

/// Properties for configuring a [StreamMessageComposerLinkPreviewAttachment].
///
/// This class holds all the configuration options for a link preview, allowing them to be
/// passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamMessageComposerLinkPreviewAttachment], which uses these properties.
///  * [DefaultStreamMessageComposerLinkPreviewAttachment], the default implementation.
class StreamMessageComposerLinkPreviewAttachmentProps {
  /// Creates properties for a link preview attachment.
  const StreamMessageComposerLinkPreviewAttachmentProps({
    this.title,
    this.subtitle,
    this.caption,
    this.thumbnail,
    this.onRemovePressed,
    this.style,
  });

  /// The title displayed on the first line.
  ///
  /// Typically a [Text] showing the page title. Renders on a single line and ellipsizes on
  /// overflow. Omitted when null.
  final Widget? title;

  /// The subtitle displayed below [title].
  ///
  /// Typically a [Text] showing the page description. Renders on a single line and
  /// ellipsizes on overflow. Omitted when null.
  final Widget? subtitle;

  /// The caption displayed at the bottom of the preview.
  ///
  /// Typically the URL with a leading link icon (callers compose the icon + text themselves,
  /// e.g. via a [Row]). Renders on a single line and ellipsizes on overflow. Omitted when
  /// null.
  final Widget? caption;

  /// An optional leading thumbnail.
  ///
  /// Typically an [Image] showing a favicon or hero image. When non-null, a square thumbnail
  /// is placed at the start of the row and clipped to the thumbnail border radius; when null,
  /// the text column is flush with the start padding. The widget is responsible for filling
  /// the thumbnail bounds (typically [Image] with [BoxFit.cover]).
  final Widget? thumbnail;

  /// Called when the remove button is tapped.
  ///
  /// When null, no remove control is shown on the surrounding container.
  final VoidCallback? onRemovePressed;

  /// Per-instance style overrides.
  ///
  /// Fields left null fall back to the inherited
  /// [StreamMessageComposerLinkPreviewAttachmentTheme], then to built-in defaults.
  final StreamMessageComposerLinkPreviewAttachmentThemeData? style;
}

/// The default implementation of [StreamMessageComposerLinkPreviewAttachment].
///
/// Renders the link preview with theming support from
/// [StreamMessageComposerLinkPreviewAttachmentTheme]. It is used as the default factory
/// implementation in [StreamComponentFactory].
///
/// See also:
///
///  * [StreamMessageComposerLinkPreviewAttachment], the public API widget.
///  * [StreamMessageComposerLinkPreviewAttachmentProps], which configures this widget.
class DefaultStreamMessageComposerLinkPreviewAttachment extends StatelessWidget {
  /// Creates a default link preview with the given [props].
  const DefaultStreamMessageComposerLinkPreviewAttachment({super.key, required this.props});

  /// The properties that configure this link preview.
  final StreamMessageComposerLinkPreviewAttachmentProps props;

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    final theme = context.streamMessageComposerLinkPreviewAttachmentTheme.merge(props.style);
    final defaults = _StreamMessageComposerLinkPreviewAttachmentDefaults(context);

    final effectiveBackgroundColor = theme.backgroundColor ?? defaults.backgroundColor;
    final effectiveTitleStyle = theme.titleTextStyle ?? defaults.titleTextStyle;
    final effectiveSubtitleStyle = theme.subtitleTextStyle ?? defaults.subtitleTextStyle;
    final effectivePadding = theme.padding ?? defaults.padding;
    final effectiveThumbnailSide = theme.thumbnailSide ?? defaults.thumbnailSide;
    final effectiveThumbnailShape = (theme.thumbnailShape ?? defaults.thumbnailShape).copyWith(
      side: effectiveThumbnailSide,
    );
    final effectiveThumbnailSize = theme.thumbnailSize ?? defaults.thumbnailSize;

    Widget? effectiveThumbnail;
    if (props.thumbnail case final thumbnail?) {
      effectiveThumbnail = SizedBox.fromSize(
        size: effectiveThumbnailSize,
        child: Material(
          clipBehavior: Clip.hardEdge,
          shape: effectiveThumbnailShape,
          child: thumbnail,
        ),
      );
    }

    Widget? effectiveTitle;
    if (props.title case final title?) {
      effectiveTitle = DefaultTextStyle.merge(
        style: effectiveTitleStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        child: title,
      );
    }

    Widget? effectiveSubtitle;
    if (props.subtitle case final subtitle?) {
      effectiveSubtitle = DefaultTextStyle.merge(
        style: effectiveSubtitleStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        child: subtitle,
      );
    }

    Widget? effectiveCaption;
    if (props.caption case final caption?) {
      effectiveCaption = DefaultTextStyle.merge(
        style: effectiveSubtitleStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        child: caption,
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
          child: Row(
            mainAxisSize: .min,
            crossAxisAlignment: .start,
            spacing: spacing.xs,
            children: [
              ?effectiveThumbnail,
              Expanded(
                child: Column(
                  mainAxisSize: .min,
                  spacing: spacing.xxxs,
                  crossAxisAlignment: .start,
                  children: [?effectiveTitle, ?effectiveSubtitle, ?effectiveCaption],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Default theme values for [StreamMessageComposerLinkPreviewAttachment].
//
// Used when no explicit value is provided via
// [StreamMessageComposerLinkPreviewAttachmentThemeData].
class _StreamMessageComposerLinkPreviewAttachmentDefaults extends StreamMessageComposerLinkPreviewAttachmentThemeData {
  _StreamMessageComposerLinkPreviewAttachmentDefaults(this._context);

  final BuildContext _context;

  late final _radius = _context.streamRadius;
  late final _spacing = _context.streamSpacing;
  late final _textTheme = _context.streamTextTheme;
  late final _colorScheme = _context.streamColorScheme;
  late final Color _textColor = _colorScheme.brand.shade900;

  @override
  Color get backgroundColor => _colorScheme.brand.shade100;

  @override
  TextStyle get titleTextStyle => _textTheme.metadataEmphasis.copyWith(color: _textColor);

  @override
  TextStyle get subtitleTextStyle => _textTheme.metadataDefault.copyWith(color: _textColor);

  @override
  EdgeInsetsGeometry get padding => EdgeInsetsDirectional.only(
    start: _spacing.xs,
    end: _spacing.sm,
    top: _spacing.xs,
    bottom: _spacing.xs,
  );

  @override
  OutlinedBorder get thumbnailShape => RoundedSuperellipseBorder(borderRadius: BorderRadius.all(_radius.md));

  @override
  Size get thumbnailSize => const Size.square(40);
}
