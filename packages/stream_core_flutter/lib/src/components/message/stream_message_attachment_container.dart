import 'package:flutter/widgets.dart';

import '../../theme.dart';
import '../message_placement/stream_message_placement.dart';

/// A styled container that wraps message attachment content with a themed
/// background, shape, and border.
///
/// Style properties are resolved from the current [StreamMessagePlacement]
/// and the [StreamMessageAttachmentStyle] provided via [style] or the
/// inherited [StreamMessageItemTheme].
///
/// {@tool snippet}
///
/// Basic usage with theme defaults:
///
/// ```dart
/// StreamMessageAttachmentContainer(child: Image.network(url))
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// With explicit style overrides:
///
/// ```dart
/// StreamMessageAttachmentContainer(
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
///  * [StreamMessageAttachmentStyle], for placement-aware styling.
///  * [StreamMessageItemTheme], for theming via the widget tree.
class StreamMessageAttachmentContainer extends StatelessWidget {
  /// Creates a message attachment container.
  const StreamMessageAttachmentContainer({
    super.key,
    required this.child,
    this.style,
  });

  /// The content widget displayed inside the container.
  final Widget child;

  /// Optional style overrides for placement-aware styling.
  final StreamMessageAttachmentStyle? style;

  @override
  Widget build(BuildContext context) {
    final placement = StreamMessagePlacement.of(context);
    final themeStyle = style ?? StreamMessageItemTheme.of(context).attachment;
    final defaults = _StreamMessageAttachmentContainerDefaults(context);

    final resolve = StreamMessageStyleResolver(placement, [themeStyle, defaults]);

    final effectiveSide = resolve.maybeResolve((s) => s?.side);
    final effectiveShape = resolve((s) => s?.shape).copyWith(side: effectiveSide);
    final effectiveBackgroundColor = resolve((s) => s?.backgroundColor);

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: ShapeDecoration(
        shape: effectiveShape,
        color: effectiveBackgroundColor,
      ),
      child: child,
    );
  }
}

class _StreamMessageAttachmentContainerDefaults extends StreamMessageAttachmentStyle {
  _StreamMessageAttachmentContainerDefaults(this._context);

  final BuildContext _context;

  late final StreamColorScheme _colorScheme = _context.streamColorScheme;
  late final StreamRadius _radius = _context.streamRadius;

  @override
  StreamMessageStyleProperty<Color> get backgroundColor => .resolveWith(
    (placement) => switch (placement.alignment) {
      .start => _colorScheme.backgroundSurfaceStrong,
      .end => _colorScheme.brand.shade150,
    },
  );

  @override
  StreamMessageStyleProperty<OutlinedBorder> get shape => .resolveWith(
    (placement) => RoundedSuperellipseBorder(borderRadius: .all(_radius.lg)),
  );
}
