import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_core_flutter/core.dart';

import '../../config/theme_export_configuration.dart';
import 'export_column_row.dart';
import 'message_bubble_preview.dart';

/// A full-width message preview shown below the scrollable settings columns
/// (not inside them), split light/dark like every other row so it sits
/// directly on each column's own background rather than in a separate card.
class ThemeExportPreviewBar extends StatelessWidget {
  const ThemeExportPreviewBar({super.key});

  @override
  Widget build(BuildContext context) {
    final export = context.watch<ThemeExportConfiguration>();
    final spacing = context.streamSpacing;

    return ExportColumnRow(
      lightMaterialTheme: export.lightMaterialTheme,
      darkMaterialTheme: export.darkMaterialTheme,
      lightBuilder: (context) => Padding(
        padding: EdgeInsets.all(spacing.md),
        child: const MessageBubblePreview(),
      ),
      darkBuilder: (context) => Padding(
        padding: EdgeInsets.all(spacing.md),
        child: const MessageBubblePreview(),
      ),
    );
  }
}
