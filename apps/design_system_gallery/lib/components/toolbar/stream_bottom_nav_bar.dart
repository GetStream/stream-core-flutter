import 'package:flutter/material.dart';
import 'package:stream_core_flutter/core.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// The tabs used across the playground and showcase. Icons switch to their
// filled variant when the item is selected.
List<StreamBottomNavBarItem> _navItems(BuildContext context) {
  final icons = context.streamIcons;
  return [
    StreamBottomNavBarItem(
      icon: Icon(icons.messageBubble),
      selectedIcon: Icon(icons.messageBubbleFill),
      label: 'Chats',
    ),
    StreamBottomNavBarItem(
      icon: Icon(icons.thread),
      selectedIcon: Icon(icons.threadFill),
      label: 'Threads',
    ),
    StreamBottomNavBarItem(
      icon: Icon(icons.mention),
      selectedIcon: Icon(icons.mention),
      label: 'Mentions',
    ),
    StreamBottomNavBarItem(
      icon: Icon(icons.user),
      selectedIcon: Icon(icons.account),
      label: 'Profile',
    ),
  ];
}

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamBottomNavBar,
  path: '[Components]/Toolbar',
)
Widget buildStreamBottomNavBarPlayground(BuildContext context) {
  return const _PlaygroundDemo();
}

class _PlaygroundDemo extends StatefulWidget {
  const _PlaygroundDemo();

  @override
  State<_PlaygroundDemo> createState() => _PlaygroundDemoState();
}

class _PlaygroundDemoState extends State<_PlaygroundDemo> {
  var _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final floating = context.knobs.boolean(
      label: 'Floating',
      description:
          'When true, the bar renders as a rounded pill with a gradient fade '
          'instead of a docked bar with a top border.',
    );

    final itemCount = context.knobs.int.slider(
      label: 'Item count',
      initialValue: 4,
      min: 2,
      max: 4,
      description: 'Number of navigation tabs to display (2–4).',
    );

    final items = _navItems(context).take(itemCount).toList();
    // Keep the selected index in range as the item count changes.
    final currentIndex = _currentIndex.clamp(0, items.length - 1);

    return Align(
      alignment: Alignment.bottomCenter,
      child: StreamBottomNavBar(
        items: items,
        currentIndex: currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        behavior: floating ? StreamBottomNavBarBehavior.floating : StreamBottomNavBarBehavior.regular,
      ),
    );
  }
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamBottomNavBar,
  path: '[Components]/Toolbar',
)
Widget buildStreamBottomNavBarShowcase(BuildContext context) {
  return const _ShowcaseDemo();
}

class _ShowcaseDemo extends StatefulWidget {
  const _ShowcaseDemo();

  @override
  State<_ShowcaseDemo> createState() => _ShowcaseDemoState();
}

class _ShowcaseDemoState extends State<_ShowcaseDemo> {
  var _regularIndex = 0;
  var _floatingIndex = 1;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;
    final items = _navItems(context);

    return DefaultTextStyle(
      style: textTheme.bodyDefault.copyWith(color: colorScheme.textPrimary),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BarExample(
              label: 'Regular — docked with a top border',
              bar: StreamBottomNavBar(
                items: items,
                currentIndex: _regularIndex,
                onTap: (index) => setState(() => _regularIndex = index),
                behavior: StreamBottomNavBarBehavior.regular,
              ),
            ),
            SizedBox(height: spacing.md),
            _BarExample(
              label: 'Floating — pill with a gradient fade over content',
              bar: _FloatingNavBarPreview(
                bar: StreamBottomNavBar(
                  items: items,
                  currentIndex: _floatingIndex,
                  onTap: (index) => setState(() => _floatingIndex = index),
                  behavior: StreamBottomNavBarBehavior.floating,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Renders a floating [StreamBottomNavBar] over a simulated content gradient so
/// the fade effect is clearly visible in the Showcase.
class _FloatingNavBarPreview extends StatelessWidget {
  const _FloatingNavBarPreview({required this.bar});

  final Widget bar;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    return SizedBox(
      height: kStreamToolbarHeight * 3,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colorScheme.backgroundApp,
                    colorScheme.accentPrimary.withAlpha(0x40),
                  ],
                ),
              ),
            ),
          ),
          Positioned(bottom: 0, left: 0, right: 0, child: bar),
        ],
      ),
    );
  }
}

class _BarExample extends StatelessWidget {
  const _BarExample({required this.label, required this.bar});

  final String label;
  final Widget bar;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.captionEmphasis.copyWith(
            color: colorScheme.textSecondary,
          ),
        ),
        SizedBox(height: spacing.xs),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: colorScheme.backgroundSurface,
            borderRadius: BorderRadius.all(radius.lg),
          ),
          // The clip follows the outer rounded rect, so at the corners the bar
          // paints over an inside-aligned border. Draw it in the foreground.
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.all(radius.lg),
            border: Border.all(color: colorScheme.borderSubtle),
          ),
          child: bar,
        ),
      ],
    );
  }
}
