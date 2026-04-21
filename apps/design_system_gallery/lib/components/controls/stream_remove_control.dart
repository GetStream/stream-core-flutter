import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamRemoveControl,
  path: '[Components]/Controls',
)
Widget buildStreamRemoveControlPlayground(BuildContext context) {
  final tapTargetSize = context.knobs.object.dropdown(
    label: 'Tap target size',
    options: MaterialTapTargetSize.values,
    labelBuilder: (value) => value.name,
    initialOption: MaterialTapTargetSize.padded,
    description:
        'padded: pads the hit area to kMinInteractiveDimension (48 dp). '
        'shrinkWrap: matches the visible 20x20 badge exactly.',
  );

  final showHitRegion = context.knobs.boolean(
    label: 'Show hit region',
    initialValue: true,
    description: 'Shades the padded tap area so it is visible.',
  );

  return Center(
    child: _RemoveControlDemo(
      tapTargetSize: tapTargetSize,
      showHitRegion: showHitRegion,
    ),
  );
}

class _RemoveControlDemo extends StatefulWidget {
  const _RemoveControlDemo({
    required this.tapTargetSize,
    required this.showHitRegion,
  });

  final MaterialTapTargetSize tapTargetSize;
  final bool showHitRegion;

  @override
  State<_RemoveControlDemo> createState() => _RemoveControlDemoState();
}

class _RemoveControlDemoState extends State<_RemoveControlDemo> {
  var _taps = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;
    final radius = context.streamRadius;

    final hitRegionColor =
        colorScheme.accentPrimary.withValues(alpha: 0.15);

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: spacing.md,
      children: [
        SizedBox(
          width: 160,
          height: 160,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.backgroundElevation1,
                    borderRadius: BorderRadius.all(radius.lg),
                    border: Border.all(color: colorScheme.borderDefault),
                  ),
                ),
              ),
              PositionedDirectional(
                top: 0,
                end: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: widget.showHitRegion ? hitRegionColor : null,
                  ),
                  child: StreamRemoveControl(
                    onPressed: () => setState(() => _taps++),
                    tapTargetSize: widget.tapTargetSize,
                  ),
                ),
              ),
            ],
          ),
        ),
        Text(
          'Taps: $_taps',
          style: textTheme.captionDefault.copyWith(
            color: colorScheme.textSecondary,
          ),
        ),
        Text(
          widget.tapTargetSize == MaterialTapTargetSize.padded
              ? 'Tap anywhere in the shaded 48 dp region.'
              : 'Only the 20 dp badge is tappable.',
          style: textTheme.metadataDefault.copyWith(
            color: colorScheme.textTertiary,
          ),
        ),
      ],
    );
  }
}
