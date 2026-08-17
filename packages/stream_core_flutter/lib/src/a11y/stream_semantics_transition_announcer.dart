import 'package:flutter/semantics.dart';
import 'package:material_ui/material_ui.dart';

import 'stream_semantics_announcer.dart';

/// A behavior-only wrapper that announces transitions on [listenable] to the
/// screen reader.
///
/// [StreamSemanticsTransitionAnnouncer] observes [listenable] for changes,
/// reads the current value via [snapshot] on each notification, derives a
/// transition message via [resolveMessage], and dispatches it through
/// [StreamSemanticsAnnouncer]. The visual tree is untouched — [build]
/// returns [child] unchanged.
///
/// [snapshot] is called once during initialisation to capture the baseline
/// and again on every notification, so the first transition compares
/// against a real value rather than a synthetic default.
///
/// {@tool snippet}
///
/// Announce add/remove transitions on a value-listening source:
///
/// ```dart
/// StreamSemanticsTransitionAnnouncer<List<Attachment>>(
///   listenable: controller,
///   snapshot: () => controller.attachments,
///   resolveMessage: (previous, current) => _diffLabel(previous, current),
///   child: AttachmentList(...),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [StreamSemanticsAnnouncer], which dispatches the resolved message.
///  * [Assertiveness], which controls whether the announcement queues
///    behind or interrupts current speech.
class StreamSemanticsTransitionAnnouncer<T> extends StatefulWidget {
  /// Creates an announcer that observes [listenable] and dispatches a
  /// resolved message on each transition.
  const StreamSemanticsTransitionAnnouncer({
    super.key,
    required this.listenable,
    required this.snapshot,
    required this.resolveMessage,
    required this.child,
    this.assertiveness = Assertiveness.polite,
  });

  /// The source whose notifications drive [snapshot] and [resolveMessage].
  final Listenable listenable;

  /// Reads the current value to compare against the previous one.
  ///
  /// Called once during initialisation and again on every notification
  /// from [listenable].
  final T Function() snapshot;

  /// Resolves a screen-reader message for a transition, or returns `null`
  /// to skip the announcement.
  final String? Function(T previous, T current) resolveMessage;

  /// The widget returned unchanged from [build].
  final Widget child;

  /// Priority used to dispatch the resolved announcement.
  ///
  /// Defaults to [Assertiveness.polite] so announcements queue behind any
  /// current screen-reader speech. Use [Assertiveness.assertive] for
  /// time-sensitive transitions that should preempt other output.
  final Assertiveness assertiveness;

  @override
  State<StreamSemanticsTransitionAnnouncer<T>> createState() => _StreamSemanticsTransitionAnnouncerState<T>();
}

class _StreamSemanticsTransitionAnnouncerState<T> extends State<StreamSemanticsTransitionAnnouncer<T>> {
  late T _current;

  @override
  void initState() {
    super.initState();
    _current = widget.snapshot();
    widget.listenable.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(StreamSemanticsTransitionAnnouncer<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listenable != widget.listenable) {
      oldWidget.listenable.removeListener(_onChanged);
      _current = widget.snapshot();
      widget.listenable.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    widget.listenable.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (!mounted) return;
    final previous = _current;
    final current = widget.snapshot();
    _current = current;
    final message = widget.resolveMessage(previous, current);
    if (message == null) return;
    StreamSemanticsAnnouncer.announce(
      context,
      message,
      assertiveness: widget.assertiveness,
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
