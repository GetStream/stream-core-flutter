import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stream_core_flutter/core.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

// =============================================================================
// Playground
// =============================================================================

@widgetbook.UseCase(
  name: 'Playground',
  type: StreamSnackbar,
  path: '[Components]/Snackbar',
)
Widget buildStreamSnackbarPlayground(BuildContext context) {
  // ---- Content ------------------------------------------------------------
  final message = context.knobs.string(
    label: 'Message',
    initialValue: 'Message sent',
    description: 'The text rendered inside the snackbar.',
  );
  final variant = context.knobs.object.dropdown<StreamSnackbarVariant>(
    label: 'Variant',
    options: StreamSnackbarVariant.values,
    initialOption: StreamSnackbarVariant.neutral,
    labelBuilder: (option) => option.name,
    description: 'Visual variant + leading icon. `loading` is persistent.',
  );
  final withAction = context.knobs.boolean(
    label: 'With action',
    description: 'Show a trailing action button.',
    initialValue: true,
  );

  // ---- Behavior -----------------------------------------------------------
  final replace = context.knobs.boolean(
    label: 'Replace current',
    description:
        'Dismiss current then show next — useful for status transitions. '
        'Pattern: show(snackbar, replace: true).',
  );
  final durationSeconds = context.knobs.double.slider(
    label: 'Duration (sec)',
    initialValue: 5,
    min: 1,
    divisions: 19,
    description: 'Auto-dismiss timeout (ignored by the loading variant).',
  );

  // ---- Host placement -----------------------------------------------------
  final hostMode = context.knobs.object.dropdown<_HostMode>(
    label: 'Host mode',
    options: _HostMode.values,
    initialOption: _HostMode.scopeFullScreen,
    labelBuilder: (option) => option.label,
    description:
        'scopeFullScreen → StreamSnackbarScope (wraps the surface, snackbar '
        'at the bottom). aboveComposer → StreamSnackbarPopup over a '
        'composer-like row at the bottom. belowHeader → StreamSnackbarPopup '
        'under a header-like row at the top.',
  );
  final dismissDirection = context.knobs.object.dropdown<DismissDirection>(
    label: 'Dismiss direction',
    options: const [
      DismissDirection.down,
      DismissDirection.up,
      DismissDirection.horizontal,
      DismissDirection.none,
    ],
    initialOption: DismissDirection.down,
    labelBuilder: (option) => option.name,
    description:
        'Per-snackbar swipe-to-dismiss direction. Overrides '
        'StreamSnackbarStyle.dismissDirection. Use .none to disable swipe.',
  );

  return _SnackbarPlayground(
    message: message,
    variant: variant,
    withAction: withAction,
    replace: replace,
    durationSeconds: durationSeconds.toInt(),
    hostMode: hostMode,
    dismissDirection: dismissDirection,
  );
}

enum _HostMode {
  scopeFullScreen('Scope — full-screen surface'),
  aboveComposer('Popup — placement: above (over a bottom composer)'),
  belowHeader('Popup — placement: below (under a top header)');

  const _HostMode(this.label);
  final String label;
}

class _SnackbarPlayground extends StatefulWidget {
  const _SnackbarPlayground({
    required this.message,
    required this.variant,
    required this.withAction,
    required this.replace,
    required this.durationSeconds,
    required this.hostMode,
    required this.dismissDirection,
  });

  final String message;
  final StreamSnackbarVariant variant;
  final bool withAction;
  final bool replace;
  final int durationSeconds;
  final _HostMode hostMode;
  final DismissDirection dismissDirection;

  @override
  State<_SnackbarPlayground> createState() => _SnackbarPlaygroundState();
}

class _SnackbarPlaygroundState extends State<_SnackbarPlayground> {
  // Used in popup mode where we don't have a Scope.
  final _popupState = StreamSnackbarMessenger();

  @override
  void dispose() {
    _popupState.dispose();
    super.dispose();
  }

  bool get _isPopup => widget.hostMode == _HostMode.aboveComposer || widget.hostMode == _HostMode.belowHeader;

  void _show(BuildContext context) {
    final isLoading = widget.variant == StreamSnackbarVariant.loading;
    final snackbar = StreamSnackbar(
      message: Text(widget.message),
      variant: widget.variant,
      action: widget.withAction ? StreamSnackbarAction(label: const Text('Undo'), onPressed: () {}) : null,
      duration: isLoading ? null : Duration(seconds: widget.durationSeconds),
      dismissDirection: widget.dismissDirection,
    );

    if (_isPopup) {
      _popupState.show(snackbar, replace: widget.replace);
    } else {
      StreamSnackbarMessenger.of(context).show(snackbar, replace: widget.replace);
    }
  }

  void _closeActive(BuildContext context) {
    if (_isPopup) {
      _popupState.hideCurrent();
    } else {
      StreamSnackbarMessenger.maybeOf(context)?.hideCurrent();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final body = _PlaygroundBody(
      variant: widget.variant,
      onShow: _show,
      onClose: _closeActive,
    );

    return ColoredBox(
      color: colorScheme.backgroundApp,
      child: SafeArea(
        child: switch (widget.hostMode) {
          _HostMode.scopeFullScreen => StreamSnackbarScope(child: body),
          _HostMode.aboveComposer => _AboveComposerLayout(
            popupState: _popupState,
            body: body,
          ),
          _HostMode.belowHeader => _BelowHeaderLayout(
            popupState: _popupState,
            body: body,
          ),
        },
      ),
    );
  }
}

class _PlaygroundBody extends StatelessWidget {
  const _PlaygroundBody({
    required this.variant,
    required this.onShow,
    required this.onClose,
  });

  final StreamSnackbarVariant variant;
  final void Function(BuildContext) onShow;
  final void Function(BuildContext) onClose;

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;
    final showLoadingControls = variant == StreamSnackbarVariant.loading;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: EdgeInsets.all(spacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: spacing.md,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: spacing.sm,
                children: [
                  StreamButton(
                    onPressed: () => onShow(context),
                    child: const Text('Show snackbar'),
                  ),
                  if (showLoadingControls)
                    StreamButton(
                      onPressed: () => onClose(context),
                      style: StreamButtonStyle.secondary,
                      type: StreamButtonType.outline,
                      child: const Text('Close'),
                    ),
                ],
              ),
              StreamTextInput(
                hintText: 'Tap to open the keyboard',
                helperText: 'Snackbar auto-lifts above the soft keyboard.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Layout for the Popup demo: body fills the area, fake composer wrapped in
/// [StreamSnackbarPopup] sits at the bottom.
class _AboveComposerLayout extends StatelessWidget {
  const _AboveComposerLayout({required this.popupState, required this.body});

  final StreamSnackbarMessenger popupState;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: body),
        StreamSnackbarPopup.withState(
          messenger: popupState,
          child: const _FakeComposer(),
        ),
      ],
    );
  }
}

/// Layout for the below-header demo: fake header at the top with a
/// [StreamSnackbarPopup] anchored to it via `placement: below`, body fills
/// the rest.
class _BelowHeaderLayout extends StatelessWidget {
  const _BelowHeaderLayout({required this.popupState, required this.body});

  final StreamSnackbarMessenger popupState;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StreamSnackbarPopup.withState(
          messenger: popupState,
          placement: StreamSnackbarPopupPlacement.under,
          child: const _FakeHeader(),
        ),
        Expanded(child: body),
      ],
    );
  }
}

/// A header-like row at the top that the popup anchors to with
/// `placement: below`.
class _FakeHeader extends StatelessWidget {
  const _FakeHeader();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final spacing = context.streamSpacing;
    final textTheme = context.streamTextTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.backgroundSurfaceCard,
        border: Border(bottom: BorderSide(color: colorScheme.borderSubtle)),
      ),
      padding: EdgeInsets.symmetric(horizontal: spacing.md, vertical: spacing.sm),
      child: Center(
        child: Text(
          'Fake header — snackbar floats below this',
          style: textTheme.bodyDefault.copyWith(color: colorScheme.textSecondary),
        ),
      ),
    );
  }
}

/// A composer-like row that stands in for the real `StreamMessageComposer`
/// — kept simple so the focus stays on the snackbar's positioning. Uses
/// `StreamButton.icon` with stream icons so it looks like our other surfaces.
class _FakeComposer extends StatelessWidget {
  const _FakeComposer();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final spacing = context.streamSpacing;
    final icons = context.streamIcons;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.backgroundSurfaceCard,
        border: Border(top: BorderSide(color: colorScheme.borderSubtle)),
      ),
      padding: EdgeInsets.fromLTRB(spacing.sm, spacing.sm, spacing.sm, spacing.sm),
      child: Row(
        spacing: spacing.xs,
        children: [
          StreamButton.icon(
            onPressed: () {},
            style: StreamButtonStyle.secondary,
            type: StreamButtonType.ghost,
            icon: Icon(icons.attachment),
          ),
          Expanded(
            child: StreamTextInput(
              hintText: 'Fake composer — snackbar floats above this',
            ),
          ),
          StreamButton.icon(
            onPressed: () {},
            icon: Icon(icons.send),
          ),
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
  type: StreamSnackbar,
  path: '[Components]/Snackbar',
)
Widget buildStreamSnackbarShowcase(BuildContext context) {
  return const _Showcase();
}

class _Showcase extends StatelessWidget {
  const _Showcase();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final spacing = context.streamSpacing;

    return DefaultTextStyle(
      style: textTheme.bodyDefault.copyWith(color: colorScheme.textPrimary),
      child: ColoredBox(
        color: colorScheme.backgroundApp,
        child: StreamSnackbarScope(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              spacing.lg,
              spacing.lg,
              spacing.lg,
              spacing.lg + 64,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: spacing.xl,
              children: const [
                _VariantsSection(),
                _WithActionSection(),
                _MessageLengthSection(),
                _BehaviorSection(),
                _CustomizationSection(),
                _AnchoredPopupSection(),
                _NestedScopesSection(),
                _UsagePatternsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Variants Section
// =============================================================================

class _VariantsSection extends StatelessWidget {
  const _VariantsSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: [
        const _SectionLabel(label: 'VARIANTS'),
        _ExampleCard(
          title: 'Four variants for different feedback',
          description:
              'Each variant maps to a leading visual. Neutral has no icon, '
              'success and error use icons, loading shows a spinner.',
          child: _SnackbarList(
            entries: [
              for (final variant in StreamSnackbarVariant.values)
                (
                  variant.name,
                  StreamSnackbar(
                    message: Text(_messageFor(variant)),
                    variant: variant,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  static String _messageFor(StreamSnackbarVariant variant) => switch (variant) {
    StreamSnackbarVariant.neutral => 'Settings updated',
    StreamSnackbarVariant.success => 'Message sent',
    StreamSnackbarVariant.error => 'Failed to send message',
    StreamSnackbarVariant.loading => 'Uploading file',
  };
}

// =============================================================================
// With Action Section
// =============================================================================

class _WithActionSection extends StatelessWidget {
  const _WithActionSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: [
        const _SectionLabel(label: 'WITH ACTION'),
        _ExampleCard(
          title: 'Optional trailing action',
          description:
              'Pair any variant with an action. Snackbars with an action '
              'linger longer (10 s by default) and close on press.',
          child: _SnackbarList(
            entries: [
              for (final entry in const [
                (StreamSnackbarVariant.neutral, 'Conversation archived', 'Undo'),
                (StreamSnackbarVariant.success, 'Reaction added', 'Undo'),
                (StreamSnackbarVariant.error, 'Could not connect', 'Retry'),
                (StreamSnackbarVariant.loading, 'Uploading 1 of 3', 'Cancel'),
              ])
                (
                  entry.$1.name,
                  StreamSnackbar(
                    message: Text(entry.$2),
                    variant: entry.$1,
                    action: StreamSnackbarAction(
                      label: Text(entry.$3),
                      onPressed: () {},
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Message Length Section
// =============================================================================

class _MessageLengthSection extends StatelessWidget {
  const _MessageLengthSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: [
        const _SectionLabel(label: 'MESSAGE LENGTHS'),
        _ExampleCard(
          title: 'Truncation behaviour',
          description:
              'Snackbars sit at a max width of 370 px and clip the message to '
              'a single line. Anything longer is truncated with an ellipsis.',
          child: _SnackbarList(
            entries: [
              ('short', StreamSnackbar(message: const Text('Saved'))),
              ('medium', StreamSnackbar(message: const Text('Your draft was saved automatically'))),
              (
                'long (truncates)',
                StreamSnackbar(
                  message: const Text(
                    'Your draft has been saved and is now available across '
                    'every device signed in to your account.',
                  ),
                  action: StreamSnackbarAction(label: const Text('OK'), onPressed: () {}),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Behavior Section
// =============================================================================

class _BehaviorSection extends StatelessWidget {
  const _BehaviorSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: const [
        _SectionLabel(label: 'BEHAVIOR'),
        _ReplaceVsQueueDemo(),
        _AwaitResultDemo(),
        _PersistentLoadingDemo(),
      ],
    );
  }
}

class _ReplaceVsQueueDemo extends StatelessWidget {
  const _ReplaceVsQueueDemo();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;
    return _ExampleCard(
      title: 'Queue vs. replace',
      description:
          'show() always queues. To preempt the current snackbar, '
          'pass replace: true (or call hideCurrent() / removeCurrent() '
          'first). "Queue 3" fires three back-to-back; "Replace 3" '
          'snap-replaces between each so only the latest is visible.',
      child: Row(
        children: [
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: [
              StreamButton(
                onPressed: () => _fireStatusSequence(context, replace: false),
                style: StreamButtonStyle.secondary,
                type: StreamButtonType.outline,
                child: const Text('Queue 3'),
              ),
              StreamButton(
                onPressed: () => _fireStatusSequence(context, replace: true),
                child: const Text('Replace 3'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _fireStatusSequence(BuildContext context, {required bool replace}) async {
    const messages = ['Connecting…', 'Authenticating…', 'Connected'];
    for (final message in messages) {
      if (!context.mounted) return;
      StreamSnackbarMessenger.of(context).show(
        StreamSnackbar(
          message: Text(message),
          variant: message == 'Connected' ? StreamSnackbarVariant.success : StreamSnackbarVariant.loading,
        ),
        replace: replace,
      );
      await Future<void>.delayed(const Duration(milliseconds: 600));
    }
  }
}

class _AwaitResultDemo extends StatefulWidget {
  const _AwaitResultDemo();

  @override
  State<_AwaitResultDemo> createState() => _AwaitResultDemoState();
}

class _AwaitResultDemoState extends State<_AwaitResultDemo> {
  StreamSnackbarClosedReason? _lastResult;

  Future<void> _show(BuildContext context) async {
    final controller = StreamSnackbarMessenger.of(context).show(
      StreamSnackbar(
        message: const Text('Message deleted'),
        variant: StreamSnackbarVariant.success,
        action: StreamSnackbarAction(label: const Text('Undo'), onPressed: () {}),
      ),
    );
    final result = await controller.closed;
    if (mounted) setState(() => _lastResult = result);
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    return _ExampleCard(
      title: 'Awaiting the result',
      description:
          'show() returns a StreamSnackbarController; await '
          'controller.closed for the StreamSnackbarClosedReason. '
          'Tap the action vs let it time out and watch the result update.',
      child: Row(
        spacing: spacing.md,
        children: [
          StreamButton(
            onPressed: () => _show(context),
            child: const Text('Show with action'),
          ),
          if (_lastResult case final result?)
            Text(
              'last result: ${result.name}',
              style: textTheme.metadataDefault.copyWith(color: colorScheme.textSecondary),
            ),
        ],
      ),
    );
  }
}

class _PersistentLoadingDemo extends StatelessWidget {
  const _PersistentLoadingDemo();

  @override
  Widget build(BuildContext context) {
    return _ExampleCard(
      title: 'Persistent loading + manual dismiss',
      description:
          'The loading variant is persistent. Dismiss when work completes '
          'via StreamSnackbarMessenger.of(context).hideCurrent(). Tap '
          'below for a 3 s simulated upload.',
      child: StreamButton(
        onPressed: () {
          StreamSnackbarMessenger.of(context).show(
            StreamSnackbar(
              message: const Text('Uploading…'),
              variant: StreamSnackbarVariant.loading,
            ),
          );
          Future<void>.delayed(const Duration(seconds: 3), () {
            if (context.mounted) StreamSnackbarMessenger.of(context).hideCurrent();
          });
        },
        child: const Text('Start fake upload'),
      ),
    );
  }
}

// =============================================================================
// Customization Section
// =============================================================================

class _CustomizationSection extends StatelessWidget {
  const _CustomizationSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: [
        const _SectionLabel(label: 'CUSTOMIZATION'),
        _ExampleCard(
          title: 'StreamComponentFactory override',
          description:
              'Embedders restyle SDK-fired snackbars via the factory. The '
              'override receives the same StreamSnackbar widget the default '
              'renderer would.',
          child: _SnackbarList(
            entries: [
              (
                'default',
                StreamSnackbar(
                  message: const Text('Message sent'),
                  variant: StreamSnackbarVariant.success,
                ),
              ),
              (
                'custom',
                StreamComponentFactory(
                  builders: StreamComponentBuilders(
                    snackbar: (context, props) => _BannerStyleSnackbar(props: props),
                  ),
                  child: StreamSnackbar(
                    message: const Text('Message sent'),
                    variant: StreamSnackbarVariant.success,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A demo override that renders the snackbar as a left-bordered banner
/// instead of the default pill.
class _BannerStyleSnackbar extends StatelessWidget {
  const _BannerStyleSnackbar({required this.props});

  final StreamSnackbarProps props;

  void _handleActionPressed(BuildContext context) {
    props.action?.onPressed.call();
    StreamSnackbarMessenger.maybeOf(context)?.hideCurrent(StreamSnackbarClosedReason.action);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;
    final icons = context.streamIcons;

    final accent = switch (props.variant) {
      StreamSnackbarVariant.success => colorScheme.accentSuccess,
      StreamSnackbarVariant.error => colorScheme.accentError,
      StreamSnackbarVariant.loading => colorScheme.accentPrimary,
      StreamSnackbarVariant.neutral => colorScheme.accentNeutral,
    };
    final icon = switch (props.variant) {
      StreamSnackbarVariant.success => icons.checkmark,
      StreamSnackbarVariant.error => icons.exclamationCircleFill,
      StreamSnackbarVariant.loading => icons.refresh,
      StreamSnackbarVariant.neutral => icons.info,
    };

    return Material(
      type: MaterialType.transparency,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 370),
        decoration: BoxDecoration(
          color: colorScheme.backgroundSurfaceCard,
          borderRadius: BorderRadius.all(radius.md),
          border: BorderDirectional(start: BorderSide(color: accent, width: 4)),
          boxShadow: context.streamBoxShadow.elevation1,
        ),
        padding: EdgeInsets.symmetric(horizontal: spacing.md, vertical: spacing.sm),
        child: Row(
          spacing: spacing.sm,
          children: [
            Icon(icon, color: accent, size: 20),
            Expanded(
              child: DefaultTextStyle(
                style: textTheme.bodyDefault.copyWith(color: colorScheme.textPrimary),
                child: props.message,
              ),
            ),
            if (props.action case final action?)
              StreamButton(
                onPressed: () => _handleActionPressed(context),
                style: StreamButtonStyle.secondary,
                type: StreamButtonType.ghost,
                size: StreamButtonSize.small,
                child: action.label,
              ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Anchored Popup Section
// =============================================================================

class _AnchoredPopupSection extends StatefulWidget {
  const _AnchoredPopupSection();

  @override
  State<_AnchoredPopupSection> createState() => _AnchoredPopupSectionState();
}

class _AnchoredPopupSectionState extends State<_AnchoredPopupSection> {
  final _popupState = StreamSnackbarMessenger();

  @override
  void dispose() {
    _popupState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: [
        const _SectionLabel(label: 'ANCHORED POPUP'),
        _ExampleCard(
          title: 'StreamSnackbarPopup — composer pattern',
          description:
              'Wrap a small surface with StreamSnackbarPopup. The snackbar '
              'renders into the surrounding Overlay, positioned just above '
              "the wrapped child's top edge, so it escapes the surface's "
              'bounds instead of being clipped or hidden.',
          child: Column(
            spacing: spacing.sm,
            children: [
              StreamButton(
                onPressed: () => _popupState.show(
                  StreamSnackbar(
                    message: const Text('Message too long'),
                    variant: StreamSnackbarVariant.error,
                  ),
                ),
                child: const Text('Show above composer'),
              ),
              StreamSnackbarPopup.withState(
                messenger: _popupState,
                child: const _FakeComposer(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Nested Scopes Section
// =============================================================================

class _NestedScopesSection extends StatelessWidget {
  const _NestedScopesSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: [
        const _SectionLabel(label: 'NESTED SCOPES'),
        _ExampleCard(
          title: 'Per-surface isolation',
          description:
              'Nested StreamSnackbarScopes get independent queues. '
              'StreamSnackbarMessenger.of(context) targets the nearest one, so '
              'a snackbar fired from inside a chat component stays in that '
              "component — the outer screen's queue is untouched.",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: spacing.sm,
            children: [
              Text(
                'OUTER scope',
                style: textTheme.metadataEmphasis.copyWith(color: colorScheme.textTertiary),
              ),
              _ScopeDemoCard(
                accent: colorScheme.accentPrimary,
                label: 'Outer',
                child: Column(
                  spacing: spacing.sm,
                  children: [
                    const _ScopeFireButton(label: 'Fire in outer'),
                    Text(
                      'INNER scope',
                      style: textTheme.metadataEmphasis.copyWith(color: colorScheme.textTertiary),
                    ),
                    StreamSnackbarScope(
                      child: _ScopeDemoCard(
                        accent: colorScheme.accentSuccess,
                        label: 'Inner',
                        child: const _ScopeFireButton(label: 'Fire in inner'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScopeDemoCard extends StatelessWidget {
  const _ScopeDemoCard({
    required this.accent,
    required this.label,
    required this.child,
  });

  final Color accent;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;
    final textTheme = context.streamTextTheme;

    return Container(
      padding: EdgeInsets.all(spacing.sm),
      decoration: BoxDecoration(
        color: colorScheme.backgroundSurfaceSubtle,
        borderRadius: BorderRadius.all(radius.md),
        border: BorderDirectional(start: BorderSide(color: accent, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.sm,
        children: [
          Text(
            label,
            style: textTheme.metadataEmphasis.copyWith(
              color: accent,
              fontFamily: 'monospace',
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _ScopeFireButton extends StatelessWidget {
  const _ScopeFireButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: StreamButton(
        onPressed: () => StreamSnackbarMessenger.of(context).show(
          StreamSnackbar(message: Text(label)),
        ),
        style: StreamButtonStyle.secondary,
        type: StreamButtonType.outline,
        size: StreamButtonSize.small,
        child: Text(label),
      ),
    );
  }
}

// =============================================================================
// Usage Patterns Section
// =============================================================================

class _UsagePatternsSection extends StatelessWidget {
  const _UsagePatternsSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing.md,
      children: const [
        _SectionLabel(label: 'USAGE PATTERNS'),
        _LiveDemoCard(
          title: 'Save confirmation',
          description:
              'Short success message after a destructive-feeling action '
              'completes. Auto-dismisses after 5 seconds.',
          buttonLabel: 'Trigger save',
          message: 'Message sent',
          variant: StreamSnackbarVariant.success,
        ),
        _LiveDemoCard(
          title: 'Undoable delete',
          description:
              'A reversible action stays on screen long enough for the user '
              'to reverse course. The action closes the snackbar early.',
          buttonLabel: 'Delete conversation',
          message: 'Conversation deleted',
          variant: StreamSnackbarVariant.neutral,
          actionLabel: 'Undo',
        ),
        _LiveDemoCard(
          title: 'Retryable error',
          description:
              'A failure with a retry affordance. Lingers for 10 s to give '
              'the user time to react.',
          buttonLabel: 'Simulate failure',
          message: 'Could not reach Stream',
          variant: StreamSnackbarVariant.error,
          actionLabel: 'Retry',
        ),
        _LiveDemoCard(
          title: 'Background work',
          description:
              'The loading variant is persistent — dismiss when work '
              'completes. Tap below for a 3 s simulated upload.',
          buttonLabel: 'Start upload',
          message: 'Uploading file…',
          variant: StreamSnackbarVariant.loading,
          autoDismissAfter: Duration(seconds: 3),
        ),
      ],
    );
  }
}

// =============================================================================
// Shared Widgets
// =============================================================================

class _LiveDemoCard extends StatelessWidget {
  const _LiveDemoCard({
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.message,
    required this.variant,
    this.actionLabel,
    this.autoDismissAfter,
  });

  final String title;
  final String description;
  final String buttonLabel;
  final String message;
  final StreamSnackbarVariant variant;
  final String? actionLabel;
  final Duration? autoDismissAfter;

  @override
  Widget build(BuildContext context) {
    return _ExampleCard(
      title: title,
      description: description,
      child: Align(
        alignment: Alignment.centerLeft,
        child: StreamButton(
          onPressed: () {
            StreamSnackbarMessenger.of(context).show(
              StreamSnackbar(
                message: Text(message),
                variant: variant,
                action: actionLabel == null ? null : StreamSnackbarAction(label: Text(actionLabel!), onPressed: () {}),
              ),
            );
            if (autoDismissAfter case final delay?) {
              Future<void>.delayed(delay, () {
                if (context.mounted) StreamSnackbarMessenger.of(context).hideCurrent();
              });
            }
          },
          child: Text(buttonLabel),
        ),
      ),
    );
  }
}

/// Renders a vertical list of snackbars each prefixed with a monospace label.
class _SnackbarList extends StatelessWidget {
  const _SnackbarList({required this.entries});

  final List<(String label, Widget snackbar)> entries;

  @override
  Widget build(BuildContext context) {
    final spacing = context.streamSpacing;
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: spacing.sm,
      children: [
        for (final entry in entries) _LabeledSnackbar(label: entry.$1, snackbar: entry.$2),
      ],
    );
  }
}

class _LabeledSnackbar extends StatelessWidget {
  const _LabeledSnackbar({required this.label, required this.snackbar});

  final String label;
  final Widget snackbar;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.streamTextTheme;
    final colorScheme = context.streamColorScheme;
    final spacing = context.streamSpacing;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Padding(
            padding: EdgeInsets.only(top: spacing.sm),
            child: Text(
              label,
              style: textTheme.metadataEmphasis.copyWith(
                color: colorScheme.textTertiary,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
        Expanded(
          child: Align(alignment: Alignment.centerLeft, child: snackbar),
        ),
      ],
    );
  }
}

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
      clipBehavior: Clip.antiAlias,
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
                Text(
                  title,
                  style: textTheme.captionEmphasis.copyWith(color: colorScheme.textPrimary),
                ),
                Text(
                  description,
                  style: textTheme.metadataDefault.copyWith(color: colorScheme.textTertiary),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colorScheme.borderSubtle),
          Container(
            padding: EdgeInsets.all(spacing.md),
            color: colorScheme.backgroundSurface,
            child: child,
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.streamColorScheme;
    final textTheme = context.streamTextTheme;
    final radius = context.streamRadius;
    final spacing = context.streamSpacing;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: spacing.sm, vertical: spacing.xs),
      decoration: BoxDecoration(
        color: colorScheme.accentPrimary,
        borderRadius: BorderRadius.all(radius.xs),
      ),
      child: Text(
        label,
        style: textTheme.metadataEmphasis.copyWith(
          color: colorScheme.textOnAccent,
          letterSpacing: 1,
          fontSize: 9,
        ),
      ),
    );
  }
}
