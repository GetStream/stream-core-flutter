// ignore_for_file: experimental_member_use

import 'package:flutter/material.dart';
import 'package:stream_core_flutter/video.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamContextMenuHeading,
  path: '[Components]/Context Menu',
)
Widget buildStreamContextMenuHeadingPlayground(BuildContext context) {
  return const _PlaygroundDemo();
}

class _PlaygroundDemo extends StatefulWidget {
  const _PlaygroundDemo();

  @override
  State<_PlaygroundDemo> createState() => _PlaygroundDemoState();
}

class _PlaygroundDemoState extends State<_PlaygroundDemo> {
  var _collapsed = false;

  @override
  Widget build(BuildContext context) {
    final icons = context.streamIcons;

    final label = context.knobs.string(
      label: 'Label',
      initialValue: 'Microphone',
      description: 'The heading text.',
    );

    final collapsible = context.knobs.boolean(
      label: 'Collapsible',
      initialValue: true,
      description: 'Give the heading an onTap and a chevron that folds its section away.',
    );

    final showTrailing = context.knobs.boolean(
      label: 'Trailing',
      initialValue: true,
      description: 'Show a trailing chevron. Without Collapsible it is decoration only.',
    );

    final showSecondSection = context.knobs.boolean(
      label: 'Second Section',
      initialValue: true,
      description: 'Add a plain heading and its actions below a separator.',
    );

    final isCollapsed = collapsible && _collapsed;

    return Center(
      child: StreamContextMenu(
        children: [
          StreamContextMenuHeading(
            label: Text(label),
            trailing: showTrailing ? Icon(isCollapsed ? icons.chevronDown : icons.chevronUp) : null,
            expanded: collapsible ? !isCollapsed : null,
            onTap: collapsible ? () => setState(() => _collapsed = !_collapsed) : null,
          ),
          if (!isCollapsed) ...[
            StreamContextMenuAction<void>(
              label: const Text('Built-in microphone'),
              closeOnActivate: false,
              onTap: () {},
            ),
            StreamContextMenuAction<void>(
              label: const Text('External microphone'),
              closeOnActivate: false,
              onTap: () {},
            ),
          ],
          if (showSecondSection) ...[
            const StreamContextMenuSeparator(),
            StreamContextMenuHeading(label: const Text('Speaker')),
            StreamContextMenuAction<void>(
              label: const Text('Built-in speaker'),
              closeOnActivate: false,
              onTap: () {},
            ),
          ],
        ],
      ),
    );
  }
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamContextMenuHeading,
  path: '[Components]/Context Menu',
)
Widget buildStreamContextMenuHeadingShowcase(BuildContext context) {
  return const _ShowcaseDemo();
}

class _ShowcaseDemo extends StatefulWidget {
  const _ShowcaseDemo();

  @override
  State<_ShowcaseDemo> createState() => _ShowcaseDemoState();
}

class _ShowcaseDemoState extends State<_ShowcaseDemo> {
  final _collapsed = <String>{'Camera'};

  @override
  Widget build(BuildContext context) {
    final icons = context.streamIcons;
    final spacing = context.streamSpacing;
    final textTheme = context.streamTextTheme;
    final colorScheme = context.streamColorScheme;

    Iterable<Widget> section(String heading, List<String> options) sync* {
      final collapsed = _collapsed.contains(heading);
      yield StreamContextMenuHeading(
        label: Text(heading),
        trailing: Icon(collapsed ? icons.chevronDown : icons.chevronUp),
        expanded: !collapsed,
        onTap: () => setState(() => collapsed ? _collapsed.remove(heading) : _collapsed.add(heading)),
      );
      if (collapsed) return;
      for (final option in options) {
        yield StreamContextMenuAction<void>(label: Text(option), closeOnActivate: false, onTap: () {});
      }
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: Wrap(
        spacing: spacing.xl,
        runSpacing: spacing.xl,
        children: [
          _Labeled(
            title: 'Plain headings',
            textStyle: textTheme.captionEmphasis.copyWith(color: colorScheme.textSecondary),
            child: StreamContextMenu(
              children: StreamContextMenuAction.sectioned(
                sections: [
                  [
                    StreamContextMenuHeading(label: const Text('Microphone')),
                    StreamContextMenuAction<void>(label: const Text('Built-in microphone'), onTap: () {}),
                    StreamContextMenuAction<void>(label: const Text('External microphone'), onTap: () {}),
                  ],
                  [
                    StreamContextMenuHeading(label: const Text('Speaker')),
                    StreamContextMenuAction<void>(label: const Text('Built-in speaker'), onTap: () {}),
                  ],
                ],
              ),
            ),
          ),
          _Labeled(
            title: 'Collapsible sections',
            textStyle: textTheme.captionEmphasis.copyWith(color: colorScheme.textSecondary),
            child: StreamContextMenu(
              children: StreamContextMenuAction.sectioned(
                sections: [
                  section('Microphone', ['Built-in microphone', 'External microphone']),
                  section('Camera', ['FaceTime HD camera', 'External camera']),
                ],
              ),
            ),
          ),
          _Labeled(
            title: 'Dense metrics via theme',
            textStyle: textTheme.captionEmphasis.copyWith(color: colorScheme.textSecondary),
            child: StreamContextMenuActionTheme(
              data: StreamContextMenuActionThemeData(
                style: StreamContextMenuActionStyle(
                  minimumSize: const WidgetStatePropertyAll(Size(200, 32)),
                  padding: WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: spacing.xs, vertical: spacing.xxs),
                  ),
                ),
              ),
              child: StreamContextMenuHeadingTheme(
                data: StreamContextMenuHeadingThemeData(
                  minimumSize: const Size(200, 32),
                  padding: EdgeInsets.symmetric(horizontal: spacing.xs, vertical: spacing.xxs),
                ),
                child: StreamContextMenu(
                  children: [
                    StreamContextMenuHeading(label: const Text('Microphone')),
                    StreamContextMenuAction<void>(label: const Text('Built-in microphone'), onTap: () {}),
                    StreamContextMenuAction<void>(label: const Text('External microphone'), onTap: () {}),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Labeled extends StatelessWidget {
  const _Labeled({required this.title, required this.textStyle, required this.child});

  final String title;
  final TextStyle textStyle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: context.streamSpacing.sm,
      children: [
        Text(title, style: textStyle),
        child,
      ],
    );
  }
}
