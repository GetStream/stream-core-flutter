import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'toolbar_button.dart';

/// Debug paint toggle button for visualizing layout bounds.
class DebugPaintToggle extends StatefulWidget {
  const DebugPaintToggle({super.key});

  @override
  State<DebugPaintToggle> createState() => _DebugPaintToggleState();
}

class _DebugPaintToggleState extends State<DebugPaintToggle> {
  void _toggle() {
    setState(() => debugPaintSizeEnabled = !debugPaintSizeEnabled);
    WidgetsBinding.instance.performReassemble();
  }

  @override
  Widget build(BuildContext context) {
    return ToolbarButton(
      icon: debugPaintSizeEnabled ? Icons.grid_on : Icons.grid_off,
      tooltip: 'Layout Bounds',
      isActive: debugPaintSizeEnabled,
      onTap: _toggle,
    );
  }
}
