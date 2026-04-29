import 'package:flutter/material.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamSheetRoute,
  path: '[Components]/Sheet',
)
Widget buildStreamSheetPlayground(BuildContext context) {
  final showDragHandle = context.knobs.boolean(
    label: 'Show drag handle',
    initialValue: true,
    description: 'Whether to display the drag handle at the top of the sheet.',
  );

  final enableDrag = context.knobs.boolean(
    label: 'Enable drag',
    initialValue: true,
    description: 'Whether the sheet can be dismissed by dragging it down.',
  );

  final isDismissible = context.knobs.boolean(
    label: 'Is dismissible',
    description:
        'Whether tapping the modal barrier dismisses the sheet. Pair with '
        'a non-transparent barrier color to give users a visible target.',
  );

  final useNestedNavigation = context.knobs.boolean(
    label: 'Use nested navigation',
    description:
        'When true, the sheet hosts its own Navigator so consumers can push '
        'routes inside the sheet. The header auto-shows a back chevron on '
        'deeper nested routes.',
  );

  final useScrollableBody = context.knobs.boolean(
    label: 'Scrollable body',
    initialValue: true,
    description:
        'When on, the sheet hosts a ListView attached to the provided '
        'ScrollController so dragging at the top of the list dismisses '
        'the sheet (scroll-aware drag-to-dismiss).',
  );

  return _SheetLauncher(
    label: 'Open Stream sheet',
    onPressed: (launchContext) => showStreamSheet<void>(
      context: launchContext,
      showDragHandle: showDragHandle,
      enableDrag: enableDrag,
      isDismissible: isDismissible,
      useNestedNavigation: useNestedNavigation,
      builder: (sheetContext, scrollController) {
        return _PlaygroundSheetContent(
          scrollController: scrollController,
          useScrollableBody: useScrollableBody,
          useNestedNavigation: useNestedNavigation,
        );
      },
    ),
  );
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamSheetRoute,
  path: '[Components]/Sheet',
)
Widget buildStreamSheetShowcase(BuildContext context) {
  final colorScheme = context.streamColorScheme;
  final textTheme = context.streamTextTheme;
  final spacing = context.streamSpacing;

  return DefaultTextStyle(
    style: textTheme.bodyDefault.copyWith(color: colorScheme.textPrimary),
    child: SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Section(
            label: 'Basic — full-height sheet with a drag handle',
            description:
                'The default Stream sheet covers the full screen, honours '
                'the system top inset, and shows a drag handle at the top.',
            launcher: _SheetLauncher(
              label: 'Open basic sheet',
              onPressed: (launchContext) => showStreamSheet<void>(
                context: launchContext,
                builder: (_, _) => const _SimpleBody(message: 'Basic sheet'),
              ),
            ),
          ),
          SizedBox(height: spacing.md),
          _Section(
            label: 'Scrollable — scroll-aware drag-to-dismiss',
            description:
                'When the list is at its top edge, dragging it further down '
                'dismisses the sheet. Otherwise dragging just scrolls the list.',
            launcher: _SheetLauncher(
              label: 'Open scrollable sheet',
              onPressed: (launchContext) => showStreamSheet<void>(
                context: launchContext,
                builder: (_, controller) {
                  return ListView.builder(
                    controller: controller,
                    itemCount: 60,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text('Item ${index + 1}'),
                        subtitle: Text('Subtitle for item ${index + 1}'),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          SizedBox(height: spacing.md),
          _Section(
            label: 'Stacked — open a sheet from inside a sheet',
            description:
                'Opening a Stream sheet from within another auto-applies a '
                'stacked top gap so the parent peeks above. The header on '
                'the stacked sheet shows a back chevron — popping returns '
                'you to the previous sheet. Keep tapping the action to push '
                'sheets indefinitely and watch the stack build up.',
            launcher: _SheetLauncher(
              label: 'Open infinitely stackable sheets',
              onPressed: (launchContext) => showStreamSheet<void>(
                context: launchContext,
                builder: (_, _) => const _StackedSheetBody(depth: 1),
              ),
            ),
          ),
          SizedBox(height: spacing.md),
          _Section(
            label: 'Nested navigation — back button inside the sheet',
            description:
                'With useNestedNavigation: true the sheet hosts its own '
                'Navigator. Pushing routes inside renders a back chevron on '
                'the header, while the first route shows a close cross.',
            launcher: _SheetLauncher(
              label: 'Open sheet with nested navigation',
              onPressed: (launchContext) => showStreamSheet<void>(
                context: launchContext,
                useNestedNavigation: true,
                builder: (sheetContext, _) {
                  return _NestedNavSheetBody(parentContext: sheetContext);
                },
              ),
            ),
          ),
          SizedBox(height: spacing.md),
          _Section(
            label: 'Constrained — capped width on wide screens',
            description:
                'Pass BoxConstraints to limit width on tablet/desktop. The '
                'sheet is bottom-aligned within the constraints.',
            launcher: _SheetLauncher(
              label: 'Open constrained sheet',
              onPressed: (launchContext) => showStreamSheet<void>(
                context: launchContext,
                constraints: const BoxConstraints(maxWidth: 480),
                builder: (_, _) => const _SimpleBody(message: 'Max width: 480'),
              ),
            ),
          ),
          SizedBox(height: spacing.md),
          _Section(
            label: 'Dismissible barrier — dim and tap-to-close',
            description:
                'Pair barrierColor with isDismissible: true to dim the '
                'background and let users tap above the sheet to dismiss.',
            launcher: _SheetLauncher(
              label: 'Open dismissible sheet',
              onPressed: (launchContext) => showStreamSheet<void>(
                context: launchContext,
                isDismissible: true,
                barrierColor: const Color(0x99000000),
                builder: (_, _) => const _SimpleBody(
                  message: 'Tap above the sheet to dismiss',
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// =============================================================================
// Helpers
// =============================================================================

class _SheetLauncher extends StatelessWidget {
  const _SheetLauncher({required this.label, required this.onPressed});

  final String label;
  final void Function(BuildContext context) onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: StreamButton(
        onPressed: () => onPressed(context),
        child: Text(label),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.label,
    required this.description,
    required this.launcher,
  });

  final String label;
  final String description;
  final Widget launcher;

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
          decoration: BoxDecoration(
            color: colorScheme.backgroundSurface,
            borderRadius: BorderRadius.all(radius.lg),
            border: Border.all(color: colorScheme.borderSubtle),
          ),
          padding: EdgeInsets.all(spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                description,
                style: textTheme.bodyDefault.copyWith(color: colorScheme.textSecondary),
              ),
              SizedBox(height: spacing.md),
              launcher,
            ],
          ),
        ),
      ],
    );
  }
}

class _SimpleBody extends StatelessWidget {
  const _SimpleBody({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreamSheetHeader(title: const Text('Stream sheet')),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: textTheme.bodyDefault.copyWith(
                  color: colorScheme.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PlaygroundSheetContent extends StatelessWidget {
  const _PlaygroundSheetContent({
    required this.scrollController,
    required this.useScrollableBody,
    required this.useNestedNavigation,
  });

  final ScrollController scrollController;
  final bool useScrollableBody;
  final bool useNestedNavigation;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    Widget body;
    if (useScrollableBody) {
      body = ListView.builder(
        controller: scrollController,
        itemCount: 60,
        itemBuilder: (_, index) => ListTile(
          title: Text('Item ${index + 1}'),
        ),
      );
    } else {
      body = Center(
        child: Padding(
          padding: EdgeInsets.all(spacing.lg),
          child: Text(
            'Sheet body',
            style: textTheme.bodyDefault.copyWith(
              color: colorScheme.textSecondary,
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreamSheetHeader(
          title: const Text('Stream sheet'),
          subtitle: const Text('Playground'),
          trailing: useNestedNavigation
              ? StreamButton.icon(
                  icon: Icon(context.streamIcons.chevronRight),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (innerContext) => _NestedDetail(parentContext: innerContext),
                      ),
                    );
                  },
                )
              : null,
        ),
        Expanded(child: body),
      ],
    );
  }
}

class _StackedSheetBody extends StatelessWidget {
  const _StackedSheetBody({required this.depth});

  /// 1-based stacking depth shown in the header so it's easy to verify how
  /// far down the stack you've gone.
  final int depth;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreamSheetHeader(
          title: Text('Sheet #$depth'),
          subtitle: Text('Stacked depth: $depth'),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Each new sheet shifts the previous stack up and scales '
                    'it down. Pop a single sheet with the back chevron, or '
                    'tap the action to push another one.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyDefault.copyWith(
                      color: colorScheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: spacing.lg),
                  StreamButton(
                    onPressed: () => showStreamSheet<void>(
                      context: context,
                      builder: (_, _) => _StackedSheetBody(depth: depth + 1),
                    ),
                    child: const Text('Push another sheet'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NestedNavSheetBody extends StatelessWidget {
  const _NestedNavSheetBody({required this.parentContext});

  final BuildContext parentContext;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreamSheetHeader(title: const Text('Sheet root')),
        Expanded(
          child: Center(
            child: StreamButton(
              onPressed: () {
                Navigator.of(parentContext).push(
                  MaterialPageRoute<void>(
                    builder: (innerContext) => _NestedDetail(parentContext: innerContext),
                  ),
                );
              },
              child: const Text('Push detail page'),
            ),
          ),
        ),
      ],
    );
  }
}

class _NestedDetail extends StatelessWidget {
  const _NestedDetail({required this.parentContext});

  final BuildContext parentContext;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          StreamSheetHeader(title: const Text('Detail')),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Pop the detail to return to the sheet root, or close '
                      'the entire sheet via the action below.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyDefault.copyWith(color: colorScheme.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    StreamButton(
                      style: StreamButtonStyle.secondary,
                      type: StreamButtonType.outline,
                      onPressed: () => StreamSheetRoute.popSheet(parentContext),
                      child: const Text('Close entire sheet'),
                    ),
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
