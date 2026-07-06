import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/preview_configuration.dart';
import 'toolbar_button.dart';

/// Toggles a [SemanticsDebugger] overlay over the widget preview, drawing
/// boxes and labels around every semantic node.
class SemanticsDebuggerToggle extends StatelessWidget {
  const SemanticsDebuggerToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final previewConfig = context.watch<PreviewConfiguration>();

    return ToolbarButton(
      icon: previewConfig.showSemanticsDebugger ? Icons.accessibility_new : Icons.accessibility,
      tooltip: 'Semantics Debugger',
      isActive: previewConfig.showSemanticsDebugger,
      onTap: previewConfig.toggleSemanticsDebugger,
    );
  }
}
