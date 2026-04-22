import 'package:flutter/material.dart';

import '../../../stream_core_flutter.dart';

/// A small circular "remove" badge typically overlaid on top of an
/// attachment preview.
///
/// The visible badge is a 20x20 dp circle containing an "x" icon. By
/// default the tap target is expanded to `kMinInteractiveDimension`
/// (48 dp) via [StreamTapTargetPadding] so the control is still easy to
/// hit on touch devices even though its visible footprint is small.
///
/// The badge inside the padded box is aligned to
/// [AlignmentDirectional.topEnd], so when the control is positioned at
/// the top-end corner of an attachment, the visible badge stays flush
/// with the corner and the extra hit area extends inward, overlapping
/// the attachment.
///
/// Set [tapTargetSize] to [MaterialTapTargetSize.shrinkWrap] to make the
/// hit area match the visible badge exactly (useful in dense layouts
/// where the padded region would overlap other interactive elements).
///
/// See also:
///
///  * [StreamTapTargetPadding], the primitive that provides the padded
///    tap target.
class StreamRemoveControl extends StatelessWidget {
  /// Creates a remove control.
  const StreamRemoveControl({
    super.key,
    required this.onPressed,
    this.tapTargetSize,
    this.visualDensity,
    this.semanticLabel = 'Remove',
  });

  /// Called when the control is tapped.
  final VoidCallback onPressed;

  /// Configures the minimum size of the tap target.
  ///
  /// Defaults to [MaterialTapTargetSize.padded], which enforces a
  /// [kMinInteractiveDimension] square (48x48 dp) tap area regardless of
  /// the visible badge size. Use [MaterialTapTargetSize.shrinkWrap] to
  /// shrink the tap target to match the 20x20 visible badge.
  final MaterialTapTargetSize? tapTargetSize;

  /// Defines how compact the control's layout will be.
  ///
  /// Its [VisualDensity.baseSizeAdjustment] is added to the effective
  /// min size derived from [tapTargetSize]. Defaults to
  /// [VisualDensity.standard].
  final VisualDensity? visualDensity;

  /// The semantic label announced by screen readers for this control.
  ///
  /// Defaults to `'Remove'`.
  final String? semanticLabel;

  static const _badgeSize = Size.square(20);

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;

    final effectiveTapTargetSize = tapTargetSize ?? .padded;
    final effectiveVisualDensity = visualDensity ?? .standard;
    final minSize = _effectiveMinSize(effectiveTapTargetSize, effectiveVisualDensity);

    return Semantics(
      button: true,
      label: semanticLabel,
      onTap: onPressed,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onPressed,
        behavior: .opaque,
        child: StreamTapTargetPadding(
          minSize: minSize,
          alignment: AlignmentDirectional.topEnd,
          child: Container(
            width: _badgeSize.width,
            height: _badgeSize.height,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.backgroundInverse,
              border: Border.all(color: colorScheme.borderOnInverse, width: 2),
            ),
            child: Icon(
              size: 16,
              context.streamIcons.xmarkSmall,
              color: colorScheme.textOnInverse,
            ),
          ),
        ),
      ),
    );
  }

  static Size _effectiveMinSize(
    MaterialTapTargetSize tapTargetSize,
    VisualDensity visualDensity,
  ) {
    final base = switch (tapTargetSize) {
      .padded => const Size.square(kMinInteractiveDimension),
      .shrinkWrap => _badgeSize,
    };

    final adjusted = base + visualDensity.baseSizeAdjustment;

    return Size(
      adjusted.width.clamp(_badgeSize.width, double.infinity),
      adjusted.height.clamp(_badgeSize.height, double.infinity),
    );
  }
}
