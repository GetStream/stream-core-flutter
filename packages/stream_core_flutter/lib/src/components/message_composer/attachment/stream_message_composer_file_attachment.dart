import 'package:flutter/widgets.dart';

import '../../../../stream_core_flutter.dart';

const _kDefaultConstraints = BoxConstraints(maxWidth: 260, maxHeight: 260, minHeight: 72);

/// A composer attachment row that previews a file by name and metadata.
///
/// [StreamMessageComposerFileAttachment] displays an optional leading [fileTypeIcon], a
/// [title] (the file name), and an optional [subtitle] (typically size or extension). It's
/// used for non-media files — documents, archives, etc. — that aren't shown as a thumbnail.
/// Both labels render on a single line and ellipsize on overflow.
///
/// The row is at most 260 wide with a minimum height of 72. It shrinks to fit when a parent
/// bounds the width below 260, and the height grows to accommodate taller content (up to 260).
///
/// {@tool snippet}
///
/// A file attachment with name and size:
///
/// ```dart
/// StreamMessageComposerFileAttachment(
///   title: Text('report.pdf'),
///   subtitle: Text('1.2 MB'),
///   fileTypeIcon: StreamFileTypeIcon.pdf(),
///   onRemovePressed: () => removeAttachment(),
/// )
/// ```
/// {@end-tool}
///
/// ## Theming
///
/// [StreamMessageComposerFileAttachment] uses [StreamMessageComposerFileAttachmentThemeData]
/// for default styling. Per-instance [style] takes precedence over the inherited theme.
///
/// See also:
///
///  * [StreamMessageComposerFileAttachmentTheme], for customizing file attachments globally.
///  * [StreamMessageComposerAttachment], the surrounding container.
///  * [StreamFileTypeIcon], the icon shown in the [fileTypeIcon] slot.
///  * [DefaultStreamMessageComposerFileAttachment], the default visual implementation.
class StreamMessageComposerFileAttachment extends StatelessWidget {
  /// Creates a file attachment row.
  StreamMessageComposerFileAttachment({
    super.key,
    required Widget title,
    Widget? subtitle,
    StreamFileTypeIcon? fileTypeIcon,
    VoidCallback? onRemovePressed,
    StreamMessageComposerFileAttachmentThemeData? style,
  }) : props = .new(
         title: title,
         subtitle: subtitle,
         fileTypeIcon: fileTypeIcon,
         onRemovePressed: onRemovePressed,
         style: style,
       );

  /// The properties that configure this file attachment.
  final StreamMessageComposerFileAttachmentProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).messageComposerFileAttachment;
    if (builder != null) return builder(context, props);
    return DefaultStreamMessageComposerFileAttachment(props: props);
  }
}

/// Properties for configuring a [StreamMessageComposerFileAttachment].
///
/// This class holds all the configuration options for a file attachment, allowing them to be
/// passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamMessageComposerFileAttachment], which uses these properties.
///  * [DefaultStreamMessageComposerFileAttachment], the default implementation.
class StreamMessageComposerFileAttachmentProps {
  /// Creates properties for a file attachment.
  const StreamMessageComposerFileAttachmentProps({
    required this.title,
    this.subtitle,
    this.fileTypeIcon,
    this.onRemovePressed,
    this.style,
  });

  /// The primary label shown on the first line.
  ///
  /// Typically a [Text] showing the file name. Renders on a single line and ellipsizes on
  /// overflow.
  final Widget title;

  /// An optional secondary label shown below [title].
  ///
  /// Typically a [Text] showing the file size or extension. Renders on a single line and
  /// ellipsizes on overflow. The row collapses to a single line when null.
  final Widget? subtitle;

  /// An optional leading icon representing the file type.
  ///
  /// When null, the row begins with the title/subtitle column flush to the start padding.
  final StreamFileTypeIcon? fileTypeIcon;

  /// Called when the remove button is tapped.
  ///
  /// When null, no remove control is shown on the surrounding container.
  final VoidCallback? onRemovePressed;

  /// Per-instance style overrides.
  ///
  /// Fields left null fall back to the inherited [StreamMessageComposerFileAttachmentTheme],
  /// then to built-in defaults.
  final StreamMessageComposerFileAttachmentThemeData? style;
}

/// The default implementation of [StreamMessageComposerFileAttachment].
///
/// Renders the file attachment with theming support from
/// [StreamMessageComposerFileAttachmentTheme]. It is used as the default factory
/// implementation in [StreamComponentFactory].
///
/// See also:
///
///  * [StreamMessageComposerFileAttachment], the public API widget.
///  * [StreamMessageComposerFileAttachmentProps], which configures this widget.
class DefaultStreamMessageComposerFileAttachment extends StatelessWidget {
  /// Creates a default file attachment with the given [props].
  const DefaultStreamMessageComposerFileAttachment({super.key, required this.props});

  /// The properties that configure this file attachment.
  final StreamMessageComposerFileAttachmentProps props;

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    final theme = context.streamMessageComposerFileAttachmentTheme.merge(props.style);
    final defaults = _StreamMessageComposerFileAttachmentDefaults(context);

    final effectiveTitleStyle = theme.titleTextStyle ?? defaults.titleTextStyle;
    final effectiveSubtitleStyle = theme.subtitleTextStyle ?? defaults.subtitleTextStyle;
    final effectivePadding = theme.padding ?? defaults.padding;
    final effectiveSpacing = theme.spacing ?? defaults.spacing;

    final effectiveTitle = DefaultTextStyle.merge(
      style: effectiveTitleStyle,
      maxLines: 1,
      overflow: .ellipsis,
      child: props.title,
    );

    Widget? effectiveSubtitle;
    if (props.subtitle case final subtitle?) {
      effectiveSubtitle = DefaultTextStyle.merge(
        style: effectiveSubtitleStyle,
        maxLines: 1,
        overflow: .ellipsis,
        child: subtitle,
      );
    }

    return StreamMessageComposerAttachment(
      onRemovePressed: props.onRemovePressed,
      child: ConstrainedBox(
        constraints: _kDefaultConstraints,
        child: Padding(
          padding: effectivePadding,
          child: Row(
            mainAxisSize: .min,
            spacing: effectiveSpacing,
            children: [
              ?props.fileTypeIcon,
              Expanded(
                child: Column(
                  spacing: spacing.xxs,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [effectiveTitle, ?effectiveSubtitle],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Default theme values for [StreamMessageComposerFileAttachment].
//
// Used when no explicit value is provided via
// [StreamMessageComposerFileAttachmentThemeData].
class _StreamMessageComposerFileAttachmentDefaults extends StreamMessageComposerFileAttachmentThemeData {
  _StreamMessageComposerFileAttachmentDefaults(this._context);

  final BuildContext _context;

  late final _spacing = _context.streamSpacing;
  late final _textTheme = _context.streamTextTheme;
  late final _colorScheme = _context.streamColorScheme;

  @override
  TextStyle get titleTextStyle => _textTheme.metadataEmphasis.copyWith(color: _colorScheme.textPrimary);

  @override
  TextStyle get subtitleTextStyle => _textTheme.metadataDefault.copyWith(color: _colorScheme.textSecondary);

  @override
  EdgeInsetsGeometry get padding => EdgeInsetsDirectional.only(
    start: _spacing.md,
    end: _spacing.sm,
    top: _spacing.md,
    bottom: _spacing.md,
  );

  @override
  double get spacing => _spacing.sm;
}
