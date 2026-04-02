import 'package:flutter/material.dart';

import '../../theme.dart';
import '../message_layout/stream_message_layout.dart';

/// A styled container that wraps message attachment content with a themed
/// background, shape, and border.
///
/// Style properties are resolved from the current [StreamMessageLayout]
/// and the [StreamMessageAttachmentStyle] provided via [style] or the
/// inherited [StreamMessageItemTheme].
///
/// Built-in defaults provide a rounded shape, horizontal padding, and a
/// placement-aware background color. Fields left null in [style] and
/// [StreamMessageItemTheme.attachment] fall back to these defaults.
///
/// {@tool snippet}
///
/// Relies on the inherited theme and built-in defaults for styling:
///
/// ```dart
/// StreamMessageAttachment(child: Image.network(url))
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// With explicit style overrides:
///
/// ```dart
/// StreamMessageAttachment(
///   style: StreamMessageAttachmentStyle.from(
///     backgroundColor: Colors.grey.shade100,
///     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
///   ),
///   child: Image.network(url),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamMessageAttachmentStyle], for layout-aware styling.
///  * [StreamMessageItemTheme], for theming via the widget tree.
class StreamMessageAttachment extends StatelessWidget {
  /// Creates a message attachment.
  const StreamMessageAttachment({
    super.key,
    required this.child,
    this.style,
  });

  /// The content widget displayed inside the attachment.
  final Widget child;

  /// Optional style overrides for layout-aware styling.
  ///
  /// Fields left null fall back to the inherited [StreamMessageItemTheme],
  /// then to built-in defaults.
  final StreamMessageAttachmentStyle? style;

  @override
  Widget build(BuildContext context) {
    final layout = StreamMessageLayout.of(context);
    final themeStyle = StreamMessageItemTheme.of(context).attachment;
    final defaults = _StreamMessageAttachmentDefaults(context);

    final resolve = StreamMessageLayoutResolver(layout, [style, themeStyle, defaults]);

    final effectiveSide = resolve.maybeResolve((s) => s?.side);
    final effectiveShape = resolve((s) => s?.shape).copyWith(side: effectiveSide);
    final effectiveBackgroundColor = resolve((s) => s?.backgroundColor);
    final effectivePadding = resolve((s) => s?.padding);

    return Padding(
      padding: effectivePadding,
      child: Material(
        clipBehavior: Clip.hardEdge,
        shape: effectiveShape,
        color: effectiveBackgroundColor,
        child: child,
      ),
    );
  }
}

class _StreamMessageAttachmentDefaults extends StreamMessageAttachmentStyle {
  _StreamMessageAttachmentDefaults(this._context);

  final BuildContext _context;

  late final StreamColorScheme _colorScheme = _context.streamColorScheme;
  late final StreamSpacing _spacing = _context.streamSpacing;
  late final StreamRadius _radius = _context.streamRadius;

  @override
  StreamMessageLayoutProperty<Color> get backgroundColor => .resolveWith(
    (layout) => switch ((layout.alignment, layout.contentKind)) {
      (_, .singleAttachment) => StreamColors.transparent,
      (.start, _) => _colorScheme.backgroundSurfaceStrong,
      (.end, _) => _colorScheme.brand.shade150,
    },
  );

  @override
  StreamMessageLayoutProperty<EdgeInsetsGeometry> get padding => .resolveWith(
    (layout) => switch (layout.contentKind) {
      .standard || .jumbomoji => .symmetric(horizontal: _spacing.xs),
      .singleAttachment => .zero,
    },
  );

  @override
  StreamMessageLayoutProperty<OutlinedBorder> get shape => .resolveWith(
    (layout) => switch (layout.contentKind) {
      .standard || .jumbomoji => RoundedSuperellipseBorder(borderRadius: .all(_radius.lg)),
      .singleAttachment => LinearBorder.none,
    },
  );
}
