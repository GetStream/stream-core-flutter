import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(
  name: 'All Elevations',
  type: StreamBoxShadow,
  path: '[App Foundation]/Elevations',
)
Widget buildStreamBoxShadowShowcase(BuildContext context) {
  final streamTheme = StreamTheme.of(context);
  final boxShadow = streamTheme.boxShadow;
  final colorScheme = streamTheme.colorScheme;
  final textTheme = streamTheme.textTheme;

  return DefaultTextStyle(
    style: TextStyle(color: colorScheme.textPrimary),
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Elevation System',
            style: textTheme.headingMd.copyWith(color: colorScheme.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Shadows create depth hierarchy and visual separation between surfaces',
            style: textTheme.bodyDefault.copyWith(
              color: colorScheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // 3D Stacked visualization
          _StackedElevationDemo(
            boxShadow: boxShadow,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          const SizedBox(height: 32),

          // Elevation cards grid
          _ElevationGrid(
            boxShadow: boxShadow,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          const SizedBox(height: 32),

          // Technical details
          _TechnicalDetails(
            boxShadow: boxShadow,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
        ],
      ),
    ),
  );
}

class _StackedElevationDemo extends StatelessWidget {
  const _StackedElevationDemo({
    required this.boxShadow,
    required this.colorScheme,
    required this.textTheme,
  });

  final StreamBoxShadow boxShadow;
  final StreamColorScheme colorScheme;
  final StreamTextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.backgroundSurfaceSubtle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.borderSurfaceSubtle),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.layers_outlined,
                size: 16,
                color: colorScheme.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Depth Hierarchy',
                style: textTheme.captionEmphasis.copyWith(
                  color: colorScheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Base layer
                Positioned(
                  bottom: 0,
                  child: _buildLayer(
                    'Base',
                    boxShadow.elevation1,
                    160,
                    colorScheme.backgroundSurface.withValues(alpha: 0.6),
                  ),
                ),
                // elevation2
                Positioned(
                  bottom: 30,
                  child: _buildLayer(
                    'elevation2',
                    boxShadow.elevation2,
                    140,
                    colorScheme.backgroundSurface.withValues(alpha: 0.8),
                  ),
                ),
                // elevation3
                Positioned(
                  bottom: 60,
                  child: _buildLayer(
                    'elevation3',
                    boxShadow.elevation3,
                    120,
                    colorScheme.backgroundSurface.withValues(alpha: 0.9),
                  ),
                ),
                // elevation4
                Positioned(
                  bottom: 90,
                  child: _buildLayer(
                    'elevation4',
                    boxShadow.elevation4,
                    100,
                    colorScheme.backgroundSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Higher elevations appear closer to the viewer',
            style: textTheme.metadataDefault.copyWith(
              color: colorScheme.textTertiary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayer(
    String label,
    List<BoxShadow> shadow,
    double width,
    Color color,
  ) {
    return Container(
      width: width,
      height: 50,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: shadow,
        border: Border.all(
          color: colorScheme.borderSurfaceSubtle.withValues(alpha: 0.5),
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: textTheme.metadataEmphasis.copyWith(
            color: colorScheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ElevationGrid extends StatelessWidget {
  const _ElevationGrid({
    required this.boxShadow,
    required this.colorScheme,
    required this.textTheme,
  });

  final StreamBoxShadow boxShadow;
  final StreamColorScheme colorScheme;
  final StreamTextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final elevations = [
      _ElevationData(
        name: 'elevation1',
        shadow: boxShadow.elevation1,
        icon: Icons.layers_outlined,
        description: 'Subtle lift for resting state',
        useCases: ['Cards', 'List items', 'Input fields'],
      ),
      _ElevationData(
        name: 'elevation2',
        shadow: boxShadow.elevation2,
        icon: Icons.flip_to_front,
        description: 'Moderate lift for hover/focus',
        useCases: ['Dropdowns', 'Menus', 'Popovers'],
      ),
      _ElevationData(
        name: 'elevation3',
        shadow: boxShadow.elevation3,
        icon: Icons.picture_in_picture,
        description: 'High lift for prominent UI',
        useCases: ['Modals', 'Dialogs', 'Drawers'],
      ),
      _ElevationData(
        name: 'elevation4',
        shadow: boxShadow.elevation4,
        icon: Icons.web_asset,
        description: 'Highest lift for alerts',
        useCases: ['Toasts', 'Notifications', 'Snackbars'],
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: colorScheme.accentPrimary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'LEVELS',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: colorScheme.textOnAccent,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Tap to copy usage code',
              style: textTheme.captionDefault.copyWith(
                color: colorScheme.textTertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...elevations.map(
          (e) => _ElevationCard(
            data: e,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
        ),
      ],
    );
  }
}

class _ElevationCard extends StatelessWidget {
  const _ElevationCard({
    required this.data,
    required this.colorScheme,
    required this.textTheme,
  });

  final _ElevationData data;
  final StreamColorScheme colorScheme;
  final StreamTextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          Clipboard.setData(
            ClipboardData(text: 'boxShadow: streamTheme.boxShadow.${data.name}'),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Copied: boxShadow.${data.name}'),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colorScheme.backgroundSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.borderSurfaceSubtle),
          ),
          child: Row(
            children: [
              // Preview box with shadow
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colorScheme.backgroundSurface,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: data.shadow,
                ),
                child: Icon(
                  data.icon,
                  color: colorScheme.textTertiary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          data.name,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.copy,
                          size: 11,
                          color: colorScheme.textTertiary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.description,
                      style: textTheme.captionDefault.copyWith(
                        color: colorScheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: data.useCases.map((use) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.backgroundSurfaceSubtle,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            use,
                            style: textTheme.metadataDefault.copyWith(
                              color: colorScheme.textTertiary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TechnicalDetails extends StatelessWidget {
  const _TechnicalDetails({
    required this.boxShadow,
    required this.colorScheme,
    required this.textTheme,
  });

  final StreamBoxShadow boxShadow;
  final StreamColorScheme colorScheme;
  final StreamTextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: colorScheme.accentNeutral,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'TECHNICAL',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: colorScheme.textOnAccent,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Shadow values for each elevation',
              style: textTheme.captionDefault.copyWith(
                color: colorScheme.textTertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colorScheme.backgroundSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.borderSurfaceSubtle),
          ),
          child: Column(
            children: [
              _ShadowRow(
                name: 'elevation1',
                shadows: boxShadow.elevation1,
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
              Divider(color: colorScheme.borderSurfaceSubtle, height: 20),
              _ShadowRow(
                name: 'elevation2',
                shadows: boxShadow.elevation2,
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
              Divider(color: colorScheme.borderSurfaceSubtle, height: 20),
              _ShadowRow(
                name: 'elevation3',
                shadows: boxShadow.elevation3,
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
              Divider(color: colorScheme.borderSurfaceSubtle, height: 20),
              _ShadowRow(
                name: 'elevation4',
                shadows: boxShadow.elevation4,
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ShadowRow extends StatelessWidget {
  const _ShadowRow({
    required this.name,
    required this.shadows,
    required this.colorScheme,
    required this.textTheme,
  });

  final String name;
  final List<BoxShadow> shadows;
  final StreamColorScheme colorScheme;
  final StreamTextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: colorScheme.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        ...shadows.asMap().entries.map((entry) {
          final shadow = entry.value;
          final hex = shadow.color.toARGB32().toRadixString(16).toUpperCase();
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: shadow.color,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(
                      color: colorScheme.borderSurface.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'offset(${shadow.offset.dx.toInt()}, ${shadow.offset.dy.toInt()}) '
                    'blur(${shadow.blurRadius.toInt()}) '
                    'spread(${shadow.spreadRadius.toInt()}) '
                    '#$hex',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      color: colorScheme.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _ElevationData {
  const _ElevationData({
    required this.name,
    required this.shadow,
    required this.icon,
    required this.description,
    required this.useCases,
  });

  final String name;
  final List<BoxShadow> shadow;
  final IconData icon;
  final String description;
  final List<String> useCases;
}
