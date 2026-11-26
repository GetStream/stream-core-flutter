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
  type: StreamModalDialog,
  path: '[Components]/Dialog',
)
Widget buildStreamModalDialogPlayground(BuildContext context) {
  final title = context.knobs.string(
    label: 'Title',
    initialValue: 'Choose what to share',
    description: 'The title at the leading edge of the header. Empty draws no title.',
  );

  final headerActions = context.knobs.int.slider(
    label: 'Header Actions',
    initialValue: 1,
    max: 3,
    description: 'Icon buttons drawn in the header, before the close button.',
  );

  final showCloseButton = context.knobs.boolean(
    label: 'Show Close Button',
    initialValue: true,
    description: 'Whether the header draws a close button.',
  );

  final footerActions = context.knobs.int.slider(
    label: 'Footer Actions',
    initialValue: 2,
    max: 3,
    description: 'Buttons drawn in the footer. None draws no footer.',
  );

  final longContent = context.knobs.boolean(
    label: 'Long Content',
    description: 'Fill the body with a scrolling list, to show the dialog stopping at its constraints.',
  );

  final blur = context.knobs.boolean(
    label: 'Blur',
    initialValue: true,
    description: 'Whether the barrier blurs what is behind it. The blur is stronger on Android and iOS.',
  );

  final barrierDismissible = context.knobs.boolean(
    label: 'Barrier Dismissible',
    initialValue: true,
    description: 'Whether a tap outside the dialog dismisses it.',
  );

  Widget buildDialog(BuildContext context) {
    final icons = context.streamIcons;
    final headerIcons = [icons.refresh, icons.settings, icons.search];

    return StreamModalDialog(
      title: title.isEmpty ? null : Text(title),
      headerActions: [
        for (var i = 0; i < headerActions; i += 1)
          StreamButton.icon(
            icon: Icon(headerIcons[i]),
            style: StreamButtonStyle.secondary,
            type: StreamButtonType.ghost,
            onPressed: () {},
          ),
      ],
      showCloseButton: showCloseButton,
      actions: [
        if (footerActions >= 3)
          StreamButton(
            style: StreamButtonStyle.destructive,
            type: StreamButtonType.ghost,
            onPressed: () => Navigator.pop(context, 'Delete'),
            child: const Text('Delete'),
          ),
        if (footerActions >= 2)
          StreamButton(
            style: StreamButtonStyle.secondary,
            type: StreamButtonType.ghost,
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('Cancel'),
          ),
        if (footerActions >= 1)
          StreamButton(
            onPressed: () => Navigator.pop(context, 'Share'),
            child: const Text('Share'),
          ),
      ],
      child: longContent ? const _LongBody() : const _ShortBody(),
    );
  }

  return Center(
    child: StreamModalDialogTheme(
      data: StreamModalDialogThemeData(barrierBlurSigma: blur ? null : 0),
      child: Builder(
        builder: (context) => StreamButton(
          onPressed: () async {
            final messenger = ScaffoldMessenger.maybeOf(context);
            final result = await showStreamModalDialog<String>(
              context: context,
              // Opens in the preview, so the toolbar's device, text scale and
              // direction reach the dialog.
              useRootNavigator: false,
              barrierDismissible: barrierDismissible,
              builder: buildDialog,
            );
            messenger?.showSnackBar(SnackBar(content: Text('Closed with ${result ?? 'no value'}')));
          },
          child: const Text('Open dialog'),
        ),
      ),
    ),
  );
}

// =============================================================================
// Showcase
// =============================================================================

@widgetbook.UseCase(
  name: 'Showcase',
  type: StreamModalDialog,
  path: '[Components]/Dialog',
)
Widget buildStreamModalDialogShowcase(BuildContext context) {
  final spacing = context.streamSpacing;

  return SingleChildScrollView(
    padding: EdgeInsets.all(spacing.lg),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.xl,
      children: [
        _Example(
          label: 'TITLE AND BODY',
          caption: 'A title, a close button and a short body',
          child: StreamModalDialog(
            title: const Text('Settings'),
            child: const _ShortBody(),
          ),
        ),
        const _Example(
          label: 'HEADER AND FOOTER ACTIONS',
          caption: 'Icon buttons before the close button, and a row of actions at the trailing edge',
          child: _ShareDialog(),
        ),
        const _MobileVariant(
          child: _Example(
            label: 'MOBILE',
            caption: 'On Android and iOS: tighter padding, and footer actions that share the width',
            child: _ShareDialog(),
          ),
        ),
        _Example(
          label: 'NO CLOSE BUTTON',
          caption: 'A dialog that has to be answered through its actions',
          child: StreamModalDialog(
            title: const Text('Choose a layout'),
            showCloseButton: false,
            actions: [
              StreamButton(
                style: StreamButtonStyle.secondary,
                type: StreamButtonType.ghost,
                onPressed: () {},
                child: const Text('Grid'),
              ),
              StreamButton(onPressed: () {}, child: const Text('Spotlight')),
            ],
            child: const _LayoutBody(),
          ),
        ),
      ],
    ),
  );
}

// =============================================================================
// Shared Widgets
// =============================================================================

class _ShortBody extends StatelessWidget {
  const _ShortBody();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Changes apply to everyone in the conversation.',
      style: context.streamTextTheme.bodyDefault.copyWith(color: context.streamColorScheme.textPrimary),
    );
  }
}

// Shows [child] as it looks on Android and iOS. The variant follows the
// platform, and the web always gets the web one, so the theme also spells out
// the mobile metrics for the web build of the gallery.
class _MobileVariant extends StatelessWidget {
  const _MobileVariant({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;
    final padding = EdgeInsets.fromLTRB(spacing.md, 0, spacing.md, spacing.md);

    return Theme(
      data: Theme.of(context).copyWith(platform: TargetPlatform.android),
      child: StreamModalDialogTheme(
        data: StreamModalDialogThemeData(
          contentPadding: padding,
          barrierBlurSigma: 25,
          headerStyle: StreamModalDialogHeaderStyle(
            padding: EdgeInsets.all(spacing.md),
            spacing: spacing.sm,
          ),
          footerStyle: StreamModalDialogFooterStyle(
            padding: padding,
            expandActions: true,
          ),
        ),
        child: child,
      ),
    );
  }
}

class _LayoutBody extends StatelessWidget {
  const _LayoutBody();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Show everyone in a grid, or the active speaker large with the others in a row.',
      style: context.streamTextTheme.bodyDefault.copyWith(color: context.streamColorScheme.textPrimary),
    );
  }
}

class _ShareDialog extends StatelessWidget {
  const _ShareDialog();

  @override
  Widget build(BuildContext context) {
    return StreamModalDialog(
      title: const Text('Choose what to share'),
      headerActions: [
        StreamButton.icon(
          icon: Icon(context.streamIcons.refresh),
          style: StreamButtonStyle.secondary,
          type: StreamButtonType.ghost,
          onPressed: () {},
        ),
      ],
      actions: [
        StreamButton(
          style: StreamButtonStyle.secondary,
          type: StreamButtonType.ghost,
          onPressed: () {},
          child: const Text('Cancel'),
        ),
        StreamButton(onPressed: () {}, child: const Text('Share')),
      ],
      child: const _ShortBody(),
    );
  }
}

class _LongBody extends StatelessWidget {
  const _LongBody();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return ListView.builder(
      shrinkWrap: true,
      itemCount: 40,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.symmetric(vertical: spacing.xs),
        child: Text(
          'Row ${index + 1}',
          style: context.streamTextTheme.bodyDefault.copyWith(color: context.streamColorScheme.textPrimary),
        ),
      ),
    );
  }
}

// A dialog drawn in place rather than opened, on a scrim so its surface
// stands out from the page. The panel grows with the dialog, so a larger text
// scale does not clip it, and its outline keeps it visible in dark mode, where
// the scrim is close to the page color.
class _Example extends StatelessWidget {
  const _Example({
    required this.label,
    required this.caption,
    required this.child,
  });

  final String label;
  final String caption;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;
    final radius = BorderRadius.all(context.streamRadius.lg);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.xs,
      children: [
        Text(label, style: textTheme.captionEmphasis.copyWith(color: colorScheme.textTertiary)),
        Text(caption, style: textTheme.captionDefault.copyWith(color: colorScheme.textSecondary)),
        DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: colorScheme.borderDefault),
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 280),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Positioned.fill(child: StreamBlurScrim()),
                  child,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
