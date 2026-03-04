import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'toolbar_button.dart';

/// Debug baselines toggle button for visualizing text baselines.
class BaselinesToggle extends StatefulWidget {
  const BaselinesToggle({super.key});

  @override
  State<BaselinesToggle> createState() => _BaselinesToggleState();
}

class _BaselinesToggleState extends State<BaselinesToggle> {
  void _toggle() {
    setState(() => debugPaintBaselinesEnabled = !debugPaintBaselinesEnabled);
    WidgetsBinding.instance.performReassemble();
  }

  @override
  Widget build(BuildContext context) {
    return ToolbarButton(
      icon: Icons.format_line_spacing,
      tooltip: 'Text Baselines',
      isActive: debugPaintBaselinesEnabled,
      onTap: _toggle,
    );
  }
}
