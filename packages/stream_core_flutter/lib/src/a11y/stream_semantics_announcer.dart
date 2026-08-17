// ignore_for_file: avoid_classes_with_only_static_members

import 'dart:async';

import 'package:flutter/semantics.dart';
import 'package:material_ui/material_ui.dart';

/// Dispatches screen-reader announcements with platform-aware delivery.
///
/// [StreamSemanticsAnnouncer] wraps [SemanticsService.sendAnnouncement] with
/// behaviour the platform itself doesn't provide: a short delay on VoiceOver
/// (iOS and macOS) for polite announcements that would otherwise be dropped,
/// and cancellation of pending announcements when a new one arrives.
///
/// Polite announcements queue behind the screen reader's current speech and
/// on VoiceOver may be dropped while another element is being read, so this
/// helper schedules them after a short delay on those platforms as a
/// workaround. Assertive announcements interrupt the current speech and are
/// dispatched immediately on every platform.
///
/// A single timer is shared across the app — calling [announce] again
/// cancels any pending delivery so rapid state changes only announce the
/// latest message, regardless of which feature dispatched them.
///
/// {@tool snippet}
///
/// Polite announcement when a region changes state:
///
/// ```dart
/// StreamSemanticsAnnouncer.announce(context, 'Picker expanded');
/// ```
/// {@end-tool}
///
/// {@tool snippet}
///
/// Assertive announcement that interrupts other screen-reader output:
///
/// ```dart
/// StreamSemanticsAnnouncer.announce(
///   context,
///   'Recording started',
///   assertiveness: Assertiveness.assertive,
/// );
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [SemanticsService.sendAnnouncement], which this class wraps.
///  * [Assertiveness], which controls whether the announcement queues
///    behind or interrupts current speech.
abstract final class StreamSemanticsAnnouncer {
  static const _voiceOverDelay = Duration(seconds: 1);

  static Timer? _timer;

  /// Schedules [message] to be announced by the screen reader.
  ///
  /// Cancels any previously scheduled announcement that hasn't yet been
  /// delivered, so the latest call wins when multiple announcements are
  /// requested in quick succession.
  ///
  /// On VoiceOver (iOS and macOS) polite announcements are dispatched after
  /// a short delay to work around a platform limitation where they can be
  /// silently dropped. On other platforms — and for assertive announcements
  /// regardless of platform — the dispatch is synchronous.
  ///
  /// Set [assertiveness] to [Assertiveness.assertive] for time-sensitive
  /// state changes that should preempt other screen-reader output.
  static void announce(
    BuildContext context,
    String message, {
    Assertiveness assertiveness = .polite,
  }) {
    _timer?.cancel();

    final view = View.of(context);
    final textDirection = Directionality.of(context);

    final platform = Theme.of(context).platform;
    final usesVoiceOver = platform == .iOS || platform == .macOS;

    void send() {
      SemanticsService.sendAnnouncement(
        view,
        message,
        textDirection,
        assertiveness: assertiveness,
      ).catchError((Object error, StackTrace stack) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stack,
            library: 'stream_core_flutter',
            context: ErrorDescription('while sending a screen-reader announcement'),
          ),
        );
      });
    }

    // Assertive announcements interrupt the screen reader directly, so the
    // VoiceOver workaround isn't needed for them.
    if (!usesVoiceOver || assertiveness == .assertive) {
      return send();
    }

    _timer = Timer(_voiceOverDelay, send);
  }

  /// Sends a tooltip announcement for the screen reader to read.
  ///
  /// Currently only honored on Android, where TalkBack reads [message] as
  /// a tooltip announcement. Does not interact with the pending [announce]
  /// timer — tooltips are independent of regular announcements.
  static Future<void> tooltip(String message) {
    return SemanticsService.tooltip(message);
  }

  /// Cancels any pending announcement.
  @visibleForTesting
  static void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}
