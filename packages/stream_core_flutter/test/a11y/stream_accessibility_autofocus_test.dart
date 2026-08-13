
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemChannels;
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

void main() {
  // Semantic events sent by [RenderObject.sendSemanticsEvent] are delivered
  // to the platform via [SystemChannels.accessibility]. Intercepting the
  // channel lets us observe what — if anything — the widget dispatched.
  late List<Map<dynamic, dynamic>> sentEvents;

  Iterable<Map<dynamic, dynamic>> focusEvents() {
    return sentEvents.where((e) => e['type'] == 'focus');
  }

  late SemanticsHandle semanticsHandle;

  setUp(() {
    sentEvents = <Map<dynamic, dynamic>>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(
      SystemChannels.accessibility,
      (mockMessage) async => sentEvents.add(mockMessage as Map<dynamic, dynamic>),
    );
    // sendSemanticsEvent requires a live semantics owner. Enable it for all
    // tests so dispatches don't null-check the missing owner.
    semanticsHandle = TestWidgetsFlutterBinding.instance.ensureSemantics();
  });

  tearDown(() {
    semanticsHandle.dispose();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(
      SystemChannels.accessibility,
      null,
    );
  });

  Widget host({
    required bool accessibleNavigation,
    required Widget child,
  }) {
    return MediaQuery(
      data: MediaQueryData(accessibleNavigation: accessibleNavigation),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: child,
      ),
    );
  }

  group('StreamAccessibilityAutofocus', () {
    testWidgets('renders its child unchanged', (tester) async {
      await tester.pumpWidget(
        host(
          accessibleNavigation: false,
          child: const StreamAccessibilityAutofocus(child: Text('child')),
        ),
      );

      expect(find.text('child'), findsOneWidget);
    });

    testWidgets('does not dispatch focus events when accessibleNavigation is off', (tester) async {
      await tester.pumpWidget(
        host(
          accessibleNavigation: false,
          child: const StreamAccessibilityAutofocus(child: SizedBox()),
        ),
      );

      // Let the entire window elapse — nothing should have fired.
      await tester.pump();
      await tester.pump(const Duration(seconds: 4));

      expect(focusEvents(), isEmpty);
    });

    testWidgets('does not dispatch focus events when enabled is false', (tester) async {
      await tester.pumpWidget(
        host(
          accessibleNavigation: true,
          child: const StreamAccessibilityAutofocus(
            enabled: false,
            child: SizedBox(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 4));

      expect(focusEvents(), isEmpty);
    });

    testWidgets('dispatches focus events after mount when SR is on', (tester) async {
      await tester.pumpWidget(
        host(
          accessibleNavigation: true,
          child: const StreamAccessibilityAutofocus(child: SizedBox()),
        ),
      );

      // Wait past the initial postFrame + a couple of retry ticks.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(focusEvents(), isNotEmpty);
    });

    testWidgets('retries at the configured cadence during the window', (tester) async {
      // Use a short window with a short interval so we can count retries
      // deterministically without slowing the test down.
      await tester.pumpWidget(
        host(
          accessibleNavigation: true,
          child: const StreamAccessibilityAutofocus(
            retryInterval: Duration(milliseconds: 100),
            window: Duration(milliseconds: 500),
            child: SizedBox(),
          ),
        ),
      );

      // Drain the window. Expect at least 3 fires — one postFrame plus
      // several 100ms retry ticks within the 500ms window.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(focusEvents().length, greaterThanOrEqualTo(3));
    });

    testWidgets('stops dispatching after the window closes', (tester) async {
      await tester.pumpWidget(
        host(
          accessibleNavigation: true,
          child: const StreamAccessibilityAutofocus(child: SizedBox()),
        ),
      );

      // Drain past the default 3s window.
      await tester.pump();
      await tester.pump(const Duration(seconds: 4));

      final countAfterWindow = focusEvents().length;

      // Wait an extra second beyond the window — no new events should fire.
      await tester.pump(const Duration(seconds: 1));
      expect(focusEvents().length, countAfterWindow);
    });

    testWidgets('starts an attempt window when SR is turned on after mount', (tester) async {
      await tester.pumpWidget(
        host(
          accessibleNavigation: false,
          child: const StreamAccessibilityAutofocus(child: SizedBox()),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(focusEvents(), isEmpty);

      // Flip SR on — didChangeDependencies should trigger and start the window.
      await tester.pumpWidget(
        host(
          accessibleNavigation: true,
          child: const StreamAccessibilityAutofocus(child: SizedBox()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(focusEvents(), isNotEmpty);
    });

    testWidgets('stops dispatching when SR is turned off mid-window', (tester) async {
      await tester.pumpWidget(
        host(
          accessibleNavigation: true,
          child: const StreamAccessibilityAutofocus(child: SizedBox()),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(focusEvents(), isNotEmpty);
      final countBeforeToggle = focusEvents().length;

      // Turn SR off before the window naturally elapses.
      await tester.pumpWidget(
        host(
          accessibleNavigation: false,
          child: const StreamAccessibilityAutofocus(child: SizedBox()),
        ),
      );

      // Wait the rest of what would have been the window — nothing new.
      await tester.pump(const Duration(seconds: 4));
      expect(focusEvents().length, countBeforeToggle);
    });

    testWidgets('trips the debug assertion when two instances share a route', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(accessibleNavigation: true),
            child: Scaffold(
              body: Column(
                children: [
                  StreamAccessibilityAutofocus(child: SizedBox()),
                  StreamAccessibilityAutofocus(child: SizedBox()),
                ],
              ),
            ),
          ),
        ),
      );

      // The second instance's didChangeDependencies should have thrown.
      expect(tester.takeException(), isA<FlutterError>());

      // Unmount to cancel the surviving first instance's timers so the
      // per-test invariant check does not see them still pending.
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('allows two instances on different routes', (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: const MediaQuery(
            data: MediaQueryData(accessibleNavigation: true),
            child: Scaffold(
              body: StreamAccessibilityAutofocus(child: SizedBox()),
            ),
          ),
        ),
      );

      // Push a second route with its own autofocus instance — simulates
      // opening a bottom sheet that contains a text field.
      navigatorKey.currentState!.push(
        MaterialPageRoute<void>(
          builder: (_) => const MediaQuery(
            data: MediaQueryData(accessibleNavigation: true),
            child: Scaffold(
              body: StreamAccessibilityAutofocus(child: SizedBox()),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('allows two instances outside any route', (tester) async {
      await tester.pumpWidget(
        host(
          accessibleNavigation: true,
          child: const Column(
            children: [
              StreamAccessibilityAutofocus(child: SizedBox()),
              StreamAccessibilityAutofocus(child: SizedBox()),
            ],
          ),
        ),
      );

      // No enclosing ModalRoute — the per-route check is a no-op.
      expect(tester.takeException(), isNull);
    });

    testWidgets('allows a new instance after the previous disposes on the same route', (tester) async {
      Widget hostWithRoute(Widget? autofocus) {
        return MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(accessibleNavigation: true),
            child: Scaffold(body: autofocus ?? const SizedBox()),
          ),
        );
      }

      await tester.pumpWidget(hostWithRoute(const StreamAccessibilityAutofocus(child: SizedBox())));

      // Unmount the first instance.
      await tester.pumpWidget(hostWithRoute(null));

      // Mount a second instance on the same route — should register cleanly.
      await tester.pumpWidget(hostWithRoute(const StreamAccessibilityAutofocus(child: SizedBox())));

      expect(tester.takeException(), isNull);
    });

    testWidgets('cancels timers on dispose', (tester) async {
      await tester.pumpWidget(
        host(
          accessibleNavigation: true,
          child: const StreamAccessibilityAutofocus(child: SizedBox()),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final countBeforeDispose = focusEvents().length;

      // Unmount the widget.
      await tester.pumpWidget(host(accessibleNavigation: true, child: const SizedBox()));

      // Wait what remains of the window. If timers weren't cancelled we'd
      // see more events; if they were, the count is stable.
      await tester.pump(const Duration(seconds: 4));
      expect(focusEvents().length, countBeforeDispose);
    });
  });
}
