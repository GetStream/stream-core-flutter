import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamTapTargetPadding,
  path: '[Components]/Common',
)
Widget buildStreamTapTargetPaddingPlayground(BuildContext context) {
  final alignment = context.knobs.object.dropdown(
    label: 'Alignment',
    options: const [
      AlignmentDirectional.topStart,
      AlignmentDirectional.topCenter,
      AlignmentDirectional.topEnd,
      AlignmentDirectional.centerStart,
      AlignmentDirectional.center,
      AlignmentDirectional.centerEnd,
      AlignmentDirectional.bottomStart,
      AlignmentDirectional.bottomCenter,
      AlignmentDirectional.bottomEnd,
    ],
    labelBuilder: _alignmentLabel,
    initialOption: AlignmentDirectional.center,
    description: 'Where the child paints within the padded box.',
  );

  final minSize = context.knobs.double.slider(
    label: 'Min size (dp)',
    initialValue: kMinInteractiveDimension,
    min: 20,
    max: 96,
    description:
        'The minimum size of the tap target on both axes. The child '
        'keeps its own 20x20 size regardless.',
  );

  final showHitRegion = context.knobs.boolean(
    label: 'Show hit region',
    initialValue: true,
    description:
        'When on, the padded region is shaded so you can see where '
        'taps are redirected to the child.',
  );

  return Center(
    child: _InteractiveDemo(
      alignment: alignment,
      minSize: Size.square(minSize),
      showHitRegion: showHitRegion,
    ),
  );
}

class _InteractiveDemo extends StatefulWidget {
  const _InteractiveDemo({
    required this.alignment,
    required this.minSize,
    required this.showHitRegion,
  });

  final AlignmentGeometry alignment;
  final Size minSize;
  final bool showHitRegion;

  @override
  State<_InteractiveDemo> createState() => _InteractiveDemoState();
}

class _InteractiveDemoState extends State<_InteractiveDemo> {
  var _taps = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    final hitRegionColor = colorScheme.accentPrimary.withValues(alpha: 0.15);

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: spacing.md,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: widget.showHitRegion ? hitRegionColor : null,
            border: Border.all(
              color: colorScheme.borderSubtle,
              style: widget.showHitRegion ? BorderStyle.solid : BorderStyle.none,
            ),
          ),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: StreamTapTargetPadding(
              minSize: widget.minSize,
              alignment: widget.alignment,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _taps++),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: colorScheme.accentPrimary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ),
        Text(
          'Taps: $_taps',
          style: textTheme.captionDefault.copyWith(
            color: colorScheme.textSecondary,
          ),
        ),
        Text(
          'Tap anywhere in the shaded area.',
          style: textTheme.metadataDefault.copyWith(
            color: colorScheme.textTertiary,
          ),
        ),
      ],
    );
  }
}

String _alignmentLabel(AlignmentGeometry value) {
  if (value is AlignmentDirectional) {
    final y = switch (value.y) {
      -1.0 => 'top',
      1.0 => 'bottom',
      _ => 'center',
    };
    final x = switch (value.start) {
      -1.0 => 'start',
      1.0 => 'end',
      _ => 'center',
    };
    return '$y-$x';
  }
  return value.toString();
}
