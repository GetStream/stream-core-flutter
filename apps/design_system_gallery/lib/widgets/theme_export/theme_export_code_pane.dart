import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:stream_core_flutter/core.dart';

import '../../config/theme_export_configuration.dart';

/// The right-hand pane of the export page: the generated Dart snippet with a
/// copy button.
///
/// Themed dark throughout via [ThemeExportConfiguration.darkMaterialTheme]
/// and Stream tokens (not hardcoded colors).
class ThemeExportCodePane extends StatefulWidget {
  const ThemeExportCodePane({super.key});

  @override
  State<ThemeExportCodePane> createState() => _ThemeExportCodePaneState();
}

class _ThemeExportCodePaneState extends State<ThemeExportCodePane> {
  // Scrollbar needs an explicit controller shared with the scroll view it
  // decorates - without one it falls back to PrimaryScrollController, which
  // this nested scroll view isn't registered as, and throws on scroll.
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final export = context.watch<ThemeExportConfiguration>();

    return Theme(
      data: export.darkMaterialTheme,
      child: Builder(
        builder: (context) {
          final colorScheme = context.streamColorScheme;
          final textTheme = context.streamTextTheme;
          final spacing = context.streamSpacing;

          return Material(
            color: colorScheme.backgroundElevation1,
            child: Padding(
              padding: EdgeInsets.all(spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Dart code',
                          style: textTheme.headingXs.copyWith(color: colorScheme.textPrimary),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Copy to clipboard',
                        icon: const Icon(Icons.copy, size: 18),
                        onPressed: () => _copyCode(context, export.generateCode()),
                      ),
                    ],
                  ),
                  SizedBox(height: spacing.sm),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(spacing.sm),
                      decoration: BoxDecoration(
                        color: colorScheme.backgroundElevation0,
                        borderRadius: BorderRadius.all(context.streamRadius.sm),
                      ),
                      foregroundDecoration: BoxDecoration(
                        borderRadius: BorderRadius.all(context.streamRadius.sm),
                        border: Border.all(color: colorScheme.borderSubtle),
                      ),
                      child: Scrollbar(
                        controller: _scrollController,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: SelectableText(
                            export.generateCode(),
                            style: textTheme.captionDefault.copyWith(
                              color: colorScheme.textPrimary,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _copyCode(BuildContext context, String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied theme code to clipboard')));
    }
  }
}
