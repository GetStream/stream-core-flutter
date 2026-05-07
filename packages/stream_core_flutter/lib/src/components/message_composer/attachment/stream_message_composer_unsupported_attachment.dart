import 'package:flutter/widgets.dart';

import '../../../../stream_core_flutter.dart';

const _kDefaultConstraints = BoxConstraints(maxWidth: 260, maxHeight: 260, minHeight: 72);

/// A composer attachment placeholder shown for attachments the client cannot render.
///
/// [StreamMessageComposerUnsupportedAttachment] displays a leading "unsupported" glyph and a
/// single [label] line — e.g. for custom or third-party attachment types the SDK doesn't
/// have a renderer for. The label renders on a single line and ellipsizes on overflow.
///
/// The row is at most 260 wide with a minimum height of 72. It shrinks to fit when a parent
/// bounds the width below 260, and the height grows to accommodate taller content (up to 260).
///
/// {@tool snippet}
///
/// An unsupported-attachment placeholder:
///
/// ```dart
/// StreamMessageComposerUnsupportedAttachment(
///   label: Text('Unsupported attachment'),
///   onRemovePressed: () => removeAttachment(),
/// )
/// ```
/// {@end-tool}
///
/// ## Theming
///
/// [StreamMessageComposerUnsupportedAttachment] uses
/// [StreamMessageComposerUnsupportedAttachmentThemeData] for default styling. Per-instance
/// [style] takes precedence over the inherited theme.
///
/// See also:
///
///  * [StreamMessageComposerUnsupportedAttachmentTheme], for customizing unsupported
///    placeholders globally.
///  * [StreamMessageComposerAttachment], the surrounding container.
///  * [DefaultStreamMessageComposerUnsupportedAttachment], the default visual implementation.
class StreamMessageComposerUnsupportedAttachment extends StatelessWidget {
  /// Creates an unsupported-attachment placeholder.
  StreamMessageComposerUnsupportedAttachment({
    super.key,
    required Widget label,
    VoidCallback? onRemovePressed,
    StreamMessageComposerUnsupportedAttachmentThemeData? style,
  }) : props = .new(
         label: label,
         onRemovePressed: onRemovePressed,
         style: style,
       );

  /// The properties that configure this placeholder.
  final StreamMessageComposerUnsupportedAttachmentProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).messageComposerUnsupportedAttachment;
    if (builder != null) return builder(context, props);
    return DefaultStreamMessageComposerUnsupportedAttachment(props: props);
  }
}

/// Properties for configuring a [StreamMessageComposerUnsupportedAttachment].
///
/// This class holds all the configuration options for an unsupported-attachment placeholder,
/// allowing them to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamMessageComposerUnsupportedAttachment], which uses these properties.
///  * [DefaultStreamMessageComposerUnsupportedAttachment], the default implementation.
class StreamMessageComposerUnsupportedAttachmentProps {
  /// Creates properties for an unsupported-attachment placeholder.
  const StreamMessageComposerUnsupportedAttachmentProps({
    required this.label,
    this.onRemovePressed,
    this.style,
  });

  /// The placeholder label.
  ///
  /// Typically a [Text] showing a localized "Unsupported attachment" string. Renders on a
  /// single line and ellipsizes on overflow.
  final Widget label;

  /// Called when the remove button is tapped.
  ///
  /// When null, no remove control is shown on the surrounding container.
  final VoidCallback? onRemovePressed;

  /// Per-instance style overrides.
  ///
  /// Fields left null fall back to the inherited
  /// [StreamMessageComposerUnsupportedAttachmentTheme], then to built-in defaults.
  final StreamMessageComposerUnsupportedAttachmentThemeData? style;
}

/// The default implementation of [StreamMessageComposerUnsupportedAttachment].
///
/// Renders the placeholder with theming support from
/// [StreamMessageComposerUnsupportedAttachmentTheme]. It is used as the default factory
/// implementation in [StreamComponentFactory].
///
/// See also:
///
///  * [StreamMessageComposerUnsupportedAttachment], the public API widget.
///  * [StreamMessageComposerUnsupportedAttachmentProps], which configures this widget.
class DefaultStreamMessageComposerUnsupportedAttachment extends StatelessWidget {
  /// Creates a default unsupported-attachment placeholder with the given [props].
  const DefaultStreamMessageComposerUnsupportedAttachment({super.key, required this.props});

  /// The properties that configure this placeholder.
  final StreamMessageComposerUnsupportedAttachmentProps props;

  @override
  Widget build(BuildContext context) {
    final icons = context.streamIcons;

    final theme = context.streamMessageComposerUnsupportedAttachmentTheme.merge(props.style);
    final defaults = _StreamMessageComposerUnsupportedAttachmentDefaults(context);

    final effectiveLabelStyle = theme.labelTextStyle ?? defaults.labelTextStyle;
    final effectivePadding = theme.padding ?? defaults.padding;
    final effectiveSpacing = theme.spacing ?? defaults.spacing;

    final effectiveLabel = DefaultTextStyle.merge(
      style: effectiveLabelStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      child: props.label,
    );

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
              Icon(icons.unsupportedAttachment, size: 20, color: effectiveLabelStyle.color),
              Expanded(child: effectiveLabel),
            ],
          ),
        ),
      ),
    );
  }
}

// Default theme values for [StreamMessageComposerUnsupportedAttachment].
//
// Used when no explicit value is provided via
// [StreamMessageComposerUnsupportedAttachmentThemeData].
class _StreamMessageComposerUnsupportedAttachmentDefaults extends StreamMessageComposerUnsupportedAttachmentThemeData {
  _StreamMessageComposerUnsupportedAttachmentDefaults(this._context);

  final BuildContext _context;

  late final _spacing = _context.streamSpacing;
  late final _textTheme = _context.streamTextTheme;
  late final _colorScheme = _context.streamColorScheme;

  @override
  TextStyle get labelTextStyle => _textTheme.metadataEmphasis.copyWith(color: _colorScheme.textPrimary);

  @override
  EdgeInsetsGeometry get padding =>
      EdgeInsetsDirectional.only(start: _spacing.md, end: _spacing.sm, top: _spacing.md, bottom: _spacing.md);

  @override
  double get spacing => _spacing.xs;
}
