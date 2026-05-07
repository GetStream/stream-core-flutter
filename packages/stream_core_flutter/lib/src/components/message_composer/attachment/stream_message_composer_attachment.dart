import 'package:flutter/material.dart';

import '../../../theme.dart';
import '../../controls/stream_remove_control.dart';

/// A styled container that wraps composer attachment content with a themed background, shape,
/// and border.
///
/// [StreamMessageComposerAttachment] sizes itself to its [child], paints a rounded surface
/// behind it, and clips the [child] to that shape. An outlined border is composed onto the
/// shape. The container also adds an outer margin so adjacent attachments in a row don't
/// touch.
///
/// When [onRemovePressed] is non-null, a circular [StreamRemoveControl] is overlaid at the
/// top-end corner, slightly outside the shape so it visually attaches to the edge.
///
/// {@tool snippet}
///
/// Basic usage — a rounded card with a subtle 1px border:
///
/// ```dart
/// StreamMessageComposerAttachment(
///   onRemovePressed: () => removeAttachment(),
///   child: MyAttachmentContent(),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// With explicit style overrides:
///
/// ```dart
/// StreamMessageComposerAttachment(
///   style: StreamMessageComposerAttachmentThemeData(
///     backgroundColor: Colors.blue.shade50,
///     side: BorderSide(color: Colors.blue.shade200),
///   ),
///   child: MyAttachmentContent(),
/// )
/// ```
/// {@end-tool}
///
/// ## Theming
///
/// [StreamMessageComposerAttachment] uses [StreamMessageComposerAttachmentThemeData] for
/// default styling — background color, shape, border side, and outer padding. Per-instance
/// [style] takes precedence over the inherited theme.
///
/// See also:
///
///  * [StreamMessageComposerAttachmentTheme], for customizing attachment containers globally.
///  * [StreamRemoveControl], the remove button shown when [onRemovePressed] is provided.
///  * [StreamMessageAttachment], the analogous container for message-list attachments.
///  * [DefaultStreamMessageComposerAttachment], the default visual implementation.
class StreamMessageComposerAttachment extends StatelessWidget {
  /// Creates a composer attachment container.
  StreamMessageComposerAttachment({
    super.key,
    required Widget child,
    VoidCallback? onRemovePressed,
    StreamMessageComposerAttachmentThemeData? style,
  }) : props = .new(
         child: child,
         onRemovePressed: onRemovePressed,
         style: style,
       );

  /// The properties that configure this attachment container.
  final StreamMessageComposerAttachmentProps props;

  @override
  Widget build(BuildContext context) {
    final builder = StreamComponentFactory.of(context).messageComposerAttachment;
    if (builder != null) return builder(context, props);
    return DefaultStreamMessageComposerAttachment(props: props);
  }
}

/// Properties for configuring a [StreamMessageComposerAttachment].
///
/// This class holds all the configuration options for an attachment container, allowing them
/// to be passed through the [StreamComponentFactory].
///
/// See also:
///
///  * [StreamMessageComposerAttachment], which uses these properties.
///  * [DefaultStreamMessageComposerAttachment], the default implementation.
class StreamMessageComposerAttachmentProps {
  /// Creates properties for an attachment container.
  const StreamMessageComposerAttachmentProps({
    required this.child,
    this.onRemovePressed,
    this.style,
  });

  /// The content displayed inside the container.
  ///
  /// Clipped to the container's rounded shape.
  final Widget child;

  /// Called when the remove button is tapped.
  ///
  /// When non-null, a [StreamRemoveControl] is overlaid at the top-end corner of the
  /// container. When null, no remove control is shown.
  final VoidCallback? onRemovePressed;

  /// Per-instance style overrides.
  ///
  /// Fields left null fall back to the inherited [StreamMessageComposerAttachmentTheme],
  /// then to built-in defaults.
  final StreamMessageComposerAttachmentThemeData? style;
}

/// The default implementation of [StreamMessageComposerAttachment].
///
/// Renders the container with theming support from [StreamMessageComposerAttachmentTheme].
/// It is used as the default factory implementation in [StreamComponentFactory].
///
/// See also:
///
///  * [StreamMessageComposerAttachment], the public API widget.
///  * [StreamMessageComposerAttachmentProps], which configures this widget.
class DefaultStreamMessageComposerAttachment extends StatelessWidget {
  /// Creates a default attachment container with the given [props].
  const DefaultStreamMessageComposerAttachment({super.key, required this.props});

  /// The properties that configure this attachment container.
  final StreamMessageComposerAttachmentProps props;

  @override
  Widget build(BuildContext context) {
    final theme = context.streamMessageComposerAttachmentTheme.merge(props.style);
    final defaults = _StreamMessageComposerAttachmentDefaults(context);

    final effectiveSide = theme.side ?? defaults.side;
    final effectiveShape = (theme.shape ?? defaults.shape).copyWith(side: effectiveSide);
    final effectiveBackgroundColor = theme.backgroundColor ?? defaults.backgroundColor;
    final effectivePadding = theme.padding ?? defaults.padding;

    final container = Padding(
      padding: effectivePadding,
      child: Material(
        clipBehavior: .hardEdge,
        shape: effectiveShape,
        color: effectiveBackgroundColor,
        child: props.child,
      ),
    );

    if (props.onRemovePressed case final onPressed?) {
      return Stack(
        clipBehavior: .none,
        children: [
          container,
          PositionedDirectional(
            top: 0,
            end: 0,
            child: StreamRemoveControl(onPressed: onPressed),
          ),
        ],
      );
    }

    return container;
  }
}

// Default theme values for [StreamMessageComposerAttachment].
//
// Used when no explicit value is provided via [style] or
// [StreamMessageComposerAttachmentThemeData].
class _StreamMessageComposerAttachmentDefaults extends StreamMessageComposerAttachmentThemeData {
  _StreamMessageComposerAttachmentDefaults(this._context);

  final BuildContext _context;

  late final _radius = _context.streamRadius;
  late final _spacing = _context.streamSpacing;
  late final _colorScheme = _context.streamColorScheme;

  @override
  Color get backgroundColor => _colorScheme.backgroundElevation1;

  @override
  OutlinedBorder get shape => RoundedSuperellipseBorder(borderRadius: .all(_radius.lg));

  @override
  BorderSide get side => BorderSide(color: _colorScheme.borderDefault);

  @override
  EdgeInsetsGeometry get padding => EdgeInsets.all(_spacing.xxs);
}
