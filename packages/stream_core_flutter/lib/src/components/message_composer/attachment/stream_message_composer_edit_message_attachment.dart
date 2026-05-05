import 'package:flutter/material.dart';

import '../../../../stream_core_flutter.dart';

const _kDefaultConstraints = BoxConstraints(minHeight: 56);

const _kIndicatorWidth = 2.0;
const _kIndicatorVerticalMargin = 2.0;

/// A composer attachment that previews the message currently being edited.
///
/// [StreamMessageComposerEditMessageAttachment] displays a leading indicator bar, a [title]
/// (typically a localized "Edit message" label), a [subtitle] (the body of the message being
/// edited), and an optional trailing [thumbnail] of the attached media. Both labels render on
/// a single line and ellipsize on overflow.
///
/// The preview fills the parent's width and is at least 56 tall, growing vertically to fit
/// longer content.
///
/// {@tool snippet}
///
/// An edit-message preview:
///
/// ```dart
/// StreamMessageComposerEditMessageAttachment(
///   title: Text('Edit message'),
///   subtitle: Text('See you at 9!'),
///   onRemovePressed: () => cancelEdit(),
/// )
/// ```
/// {@end-tool}
///
/// ## Theming
///
/// [StreamMessageComposerEditMessageAttachment] uses
/// [StreamMessageComposerEditMessageAttachmentThemeData] for default styling. Per-instance
/// [style] takes precedence over the inherited theme.
///
/// See also:
///
///  * [StreamMessageComposerEditMessageAttachmentTheme], for customizing edit previews
///    globally.
///  * [StreamMessageComposerAttachment], the surrounding container.
///  * [DefaultStreamMessageComposerEditMessageAttachment], the default visual implementation.
class StreamMessageComposerEditMessageAttachment extends StatelessWidget {
  /// Creates an edit-message preview attachment.
  StreamMessageComposerEditMessageAttachment({
    super.key,
    required Widget title,
    required Widget subtitle,
    Widget? thumbnail,
    VoidCallback? onRemovePressed,
    StreamMessageComposerEditMessageAttachmentThemeData? style,
  }) : props = .new(
         title: title,
         subtitle: subtitle,
         thumbnail: thumbnail,
         onRemovePressed: onRemovePressed,
         style: style,
       );

  /// The properties that configure this edit-message preview.
  final StreamMessageComposerEditMessageAttachmentProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).messageComposerEditMessageAttachment;
    if (builder != null) return builder(context, props);
    return DefaultStreamMessageComposerEditMessageAttachment(props: props);
  }
}

/// Properties for configuring a [StreamMessageComposerEditMessageAttachment].
///
/// This class holds all the configuration options for an edit-message preview, allowing them
/// to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamMessageComposerEditMessageAttachment], which uses these properties.
///  * [DefaultStreamMessageComposerEditMessageAttachment], the default implementation.
class StreamMessageComposerEditMessageAttachmentProps {
  /// Creates properties for an edit-message preview attachment.
  const StreamMessageComposerEditMessageAttachmentProps({
    required this.title,
    required this.subtitle,
    this.thumbnail,
    this.onRemovePressed,
    this.style,
  });

  /// The primary label shown on the first line.
  ///
  /// Typically a [Text] showing a localized "Edit message" string. Renders on a single line
  /// and ellipsizes on overflow.
  final Widget title;

  /// The secondary label shown below [title].
  ///
  /// Typically a [Text] previewing the body of the message being edited. Renders on a single
  /// line and ellipsizes on overflow.
  final Widget subtitle;

  /// An optional thumbnail of the attached media, rendered at the end of the preview row.
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

  /// Per-instance style overrides.
  ///
  /// Fields left null fall back to the inherited
  /// [StreamMessageComposerEditMessageAttachmentTheme], then to built-in defaults.
  final StreamMessageComposerEditMessageAttachmentThemeData? style;
}

/// The default implementation of [StreamMessageComposerEditMessageAttachment].
///
/// Renders the edit-message preview with theming support from
/// [StreamMessageComposerEditMessageAttachmentTheme]. It is used as the default factory
/// implementation in [StreamComponentFactory].
///
/// See also:
///
///  * [StreamMessageComposerEditMessageAttachment], the public API widget.
///  * [StreamMessageComposerEditMessageAttachmentProps], which configures this widget.
class DefaultStreamMessageComposerEditMessageAttachment extends StatelessWidget {
  /// Creates a default edit-message preview with the given [props].
  const DefaultStreamMessageComposerEditMessageAttachment({super.key, required this.props});

  /// The properties that configure this edit-message preview.
  final StreamMessageComposerEditMessageAttachmentProps props;

  @override
  Widget build(BuildContext context) {
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    final theme = context.streamMessageComposerEditMessageAttachmentTheme.merge(props.style);
    final defaults = _StreamMessageComposerEditMessageAttachmentDefaults(context);

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

// Default theme values for [StreamMessageComposerEditMessageAttachment].
//
// Used when no explicit value is provided via
// [StreamMessageComposerEditMessageAttachmentThemeData].
class _StreamMessageComposerEditMessageAttachmentDefaults extends StreamMessageComposerEditMessageAttachmentThemeData {
  _StreamMessageComposerEditMessageAttachmentDefaults(this._context);

  final BuildContext _context;

  late final _spacing = _context.streamSpacing;
  late final _textTheme = _context.streamTextTheme;
  late final _colorScheme = _context.streamColorScheme;

  @override
  Color get backgroundColor => _colorScheme.brand.shade100;

  @override
  Color get indicatorColor => _colorScheme.brand.shade400;

  @override
  TextStyle get titleTextStyle => _textTheme.metadataEmphasis.copyWith(color: _colorScheme.textPrimary);

  @override
  TextStyle get subtitleTextStyle => _textTheme.metadataDefault.copyWith(color: _colorScheme.textPrimary);

  @override
  EdgeInsetsGeometry get padding => EdgeInsets.all(_spacing.xs);

  @override
  OutlinedBorder get thumbnailShape => RoundedSuperellipseBorder(borderRadius: .all(_context.streamRadius.md));

  @override
  Size get thumbnailSize => const Size.square(40);
}
