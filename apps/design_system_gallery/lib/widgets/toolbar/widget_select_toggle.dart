import 'package:flutter/material.dart';

import 'toolbar_button.dart';

/// Widget select mode toggle for inspecting widgets in the preview.
class WidgetSelectToggle extends StatelessWidget {
  const WidgetSelectToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = WidgetsBinding.instance.debugShowWidgetInspectorOverrideNotifier;

    return ValueListenableBuilder<bool>(
      valueListenable: notifier,
      builder: (context, isActive, _) {
        return ToolbarButton(
          icon: Icons.ads_click,
          tooltip: 'Select Widget',
          isActive: isActive,
          onTap: () => notifier.value = !isActive,
        );
      },
    );
  }
}
