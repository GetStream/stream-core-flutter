import 'package:flutter/material.dart';

import '../../../theme.dart';
import '../../controls/stream_remove_control.dart';

/// A styled container that wraps message composer attachment content with a
/// themed background, shape, and border.
///
/// Built-in defaults provide a rounded shape, background color, and border
/// matching the design system tokens.
///
/// An optional [onRemovePressed] callback adds a [StreamRemoveControl] overlay.
///
/// {@tool snippet}
///
/// Basic usage relying on defaults:
///
/// ```dart
/// StreamMessageComposerAttachmentContainer(
///   onRemovePressed: () => removeAttachment(),
///   child: MyAttachmentContent(),
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// With custom colors:
///
/// ```dart
/// StreamMessageComposerAttachmentContainer(
///   backgroundColor: Colors.blue.shade50,
///   borderColor: Colors.blue.shade200,
///   child: MyAttachmentContent(),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamRemoveControl], the remove button shown when [onRemovePressed]
///    is provided.
///  * [StreamMessageAttachment], the analogous container for message-list
///    attachments.
class StreamMessageComposerAttachmentContainer extends StatelessWidget {
  /// Creates a composer attachment container.
  const StreamMessageComposerAttachmentContainer({
    super.key,
    required this.child,
    this.onRemovePressed,
    this.backgroundColor,
    this.borderColor,
  });

  /// The content widget displayed inside the container.
  final Widget child;

  /// Called when the remove button is tapped.
  ///
  /// When non-null, a [StreamRemoveControl] overlay appears at the
  /// top-right corner of the container.
  final VoidCallback? onRemovePressed;

  /// The background fill color of the container.
  ///
  /// Falls back to [StreamColorScheme.backgroundElevation1].
  final Color? backgroundColor;

  /// The border color of the container.
  ///
  /// When non-null, a 1px border is drawn with this color. When null, the
  /// default border from [StreamColorScheme.borderDefault] is used.
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;
    final colorScheme = context.streamColorScheme;

    final effectiveBorderColor = borderColor ?? colorScheme.borderDefault;
    final effectiveBackgroundColor = backgroundColor ?? colorScheme.backgroundElevation1;

    final container = Container(
      clipBehavior: .hardEdge,
      margin: .all(spacing.xxs),
      decoration: BoxDecoration(
        borderRadius: .all(radius.lg),
        color: effectiveBackgroundColor,
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: .all(radius.lg),
        border: .all(
          color: effectiveBorderColor,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: child,
    );

    if (onRemovePressed case final onPressed?) {
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
