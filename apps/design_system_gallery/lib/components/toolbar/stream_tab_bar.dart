// ignore_for_file: experimental_member_use

import 'package:flutter/material.dart';
import 'package:stream_core_flutter/video.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const _labels = ['Entire Screen', 'Window', 'Application', 'Tab'];

List<StreamTabBarItem> _tabs(BuildContext context, {required int count, required bool showIcons}) {
  final icons = context.streamIcons;
  final tabIcons = [icons.presentDesktopFill, icons.gridFill, icons.sidebar, icons.link];
  return [
    for (var index = 0; index < count; index += 1)
      StreamTabBarItem(
        label: _labels[index],
        icon: showIcons ? Icon(tabIcons[index]) : null,
      ),
  ];
}

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamTabBar,
  path: '[Components]/Toolbar',
)
Widget buildStreamTabBarPlayground(BuildContext context) {
  return const _PlaygroundDemo();
}

class _PlaygroundDemo extends StatefulWidget {
  const _PlaygroundDemo();

  @override
  State<_PlaygroundDemo> createState() => _PlaygroundDemoState();
}

class _PlaygroundDemoState extends State<_PlaygroundDemo> {
  var _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tabCount = context.knobs.int.slider(
      label: 'Tab count',
      initialValue: 2,
      min: 1,
      max: _labels.length,
      description: 'Number of tabs. Each takes an equal share of the width.',
    );

    final showIcons = context.knobs.boolean(
      label: 'Icons',
      description: 'Draw an icon before each label.',
    );

    final width = context.knobs.double.slider(
      label: 'Width',
      initialValue: 480,
      min: 160,
      max: 800,
      description: 'Width of the bar. Labels that do not fit their share are truncated.',
    );

    final selectedIndex = _selectedIndex.clamp(0, tabCount - 1);

    return Center(
      child: SizedBox(
        width: width,
        child: StreamTabBar(
          selectedIndex: selectedIndex,
          onSelected: (index) => setState(() => _selectedIndex = index),
          tabs: _tabs(context, count: tabCount, showIcons: showIcons),
        ),
      ),
    );
  }
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamTabBar,
  path: '[Components]/Toolbar',
)
Widget buildStreamTabBarShowcase(BuildContext context) {
  final colorScheme = context.streamColorScheme;
  final textTheme = context.streamTextTheme;
  final spacing = context.streamSpacing;

  return DefaultTextStyle(
    style: textTheme.bodyDefault.copyWith(color: colorScheme.textPrimary),
    child: SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.xl,
        children: const [
          _ExampleSection(
            title: 'Labels',
            description: 'The selected tab takes the accent color for its label and underline.',
            showIcons: false,
          ),
          _ExampleSection(
            title: 'With icons',
            description: 'An icon before the label takes the same color as the label.',
            showIcons: true,
          ),
          _TruncationSection(),
          _ThemedSection(),
        ],
      ),
    ),
  );
}

class _ExampleSection extends StatefulWidget {
  const _ExampleSection({required this.title, required this.description, required this.showIcons});

  final String title;
  final String description;
  final bool showIcons;

  @override
  State<_ExampleSection> createState() => _ExampleSectionState();
}

class _ExampleSectionState extends State<_ExampleSection> {
  var _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return _ExampleCard(
      title: widget.title,
      description: widget.description,
      child: StreamTabBar(
        selectedIndex: _selectedIndex,
        onSelected: (index) => setState(() => _selectedIndex = index),
        tabs: _tabs(context, count: 3, showIcons: widget.showIcons),
      ),
    );
  }
}

class _TruncationSection extends StatefulWidget {
  const _TruncationSection();

  @override
  State<_TruncationSection> createState() => _TruncationSectionState();
}

class _TruncationSectionState extends State<_TruncationSection> {
  var _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return _ExampleCard(
      title: 'Long labels',
      description: 'A label that does not fit its share of the width is cut off with an ellipsis.',
      child: SizedBox(
        width: 280,
        child: StreamTabBar(
          selectedIndex: _selectedIndex,
          onSelected: (index) => setState(() => _selectedIndex = index),
          tabs: const [
            StreamTabBarItem(label: 'Recently shared with you'),
            StreamTabBarItem(label: 'Mine'),
          ],
        ),
      ),
    );
  }
}

class _ThemedSection extends StatefulWidget {
  const _ThemedSection();

  @override
  State<_ThemedSection> createState() => _ThemedSectionState();
}

class _ThemedSectionState extends State<_ThemedSection> {
  var _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;

    return _ExampleCard(
      title: 'Themed',
      description: 'A StreamTabBarTheme with a taller bar, a thicker underline and no border under unselected tabs.',
      child: StreamTabBarTheme(
        data: StreamTabBarThemeData(
          height: 56,
          indicatorWeight: 3,
          indicatorColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected) ? colorScheme.accentPrimary : Colors.transparent,
          ),
        ),
        child: StreamTabBar(
          selectedIndex: _selectedIndex,
          onSelected: (index) => setState(() => _selectedIndex = index),
          tabs: _tabs(context, count: 3, showIcons: false),
        ),
      ),
    );
  }
}

// =============================================================================
// Shared Widgets
// =============================================================================

class _ExampleCard extends StatelessWidget {
  const _ExampleCard({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final boxShadow = context.streamBoxShadow;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.backgroundSurfaceSubtle,
        borderRadius: BorderRadius.all(radius.lg),
        boxShadow: boxShadow.elevation1,
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.all(radius.lg),
        border: Border.all(color: colorScheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(spacing.md, spacing.sm, spacing.md, spacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.captionEmphasis.copyWith(color: colorScheme.textPrimary)),
                Text(description, style: textTheme.metadataDefault.copyWith(color: colorScheme.textTertiary)),
              ],
            ),
          ),
          Divider(height: 1, color: colorScheme.borderSubtle),
          Padding(padding: EdgeInsets.all(spacing.md), child: child),
        ],
      ),
    );
  }
}
