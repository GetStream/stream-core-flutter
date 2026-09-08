import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

void main() {
  group('StreamSnackbarHost', () {
    testWidgets('renders a snackbar at its location', (tester) async {
      final messenger = StreamSnackbarMessenger();
      addTearDown(messenger.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [StreamTheme.light()]),
          home: Stack(
            children: [
              const ColoredBox(color: Color(0xFFEEEEEE)),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: StreamSnackbarHost(messenger: messenger),
              ),
            ],
          ),
        ),
      );

      messenger.show(StreamSnackbar(message: const Text('Hello')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('controller.closed resolves with .dismiss on programmatic close', (tester) async {
      final messenger = StreamSnackbarMessenger();
      addTearDown(messenger.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [StreamTheme.light()]),
          home: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: StreamSnackbarHost(messenger: messenger),
              ),
            ],
          ),
        ),
      );

      final controller = messenger.show(StreamSnackbar(message: const Text('Bye')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      controller.close();
      await tester.pumpAndSettle();

      expect(await controller.closed, StreamSnackbarClosedReason.dismiss);
      expect(find.text('Bye'), findsNothing);
    });

    testWidgets('action press resolves with .action and invokes callback', (tester) async {
      final messenger = StreamSnackbarMessenger();
      addTearDown(messenger.dispose);
      var pressed = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [StreamTheme.light()]),
          home: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: StreamSnackbarHost(messenger: messenger),
              ),
            ],
          ),
        ),
      );

      final controller = messenger.show(
        StreamSnackbar(
          message: const Text('Deleted'),
          variant: StreamSnackbarVariant.success,
          action: StreamSnackbarAction(label: const Text('Undo'), onPressed: () => pressed++),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      expect(pressed, 1);
      expect(await controller.closed, StreamSnackbarClosedReason.action);
    });

    testWidgets('controller.closed resolves with .timeout when duration elapses', (tester) async {
      final messenger = StreamSnackbarMessenger();
      addTearDown(messenger.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [StreamTheme.light()]),
          home: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: StreamSnackbarHost(messenger: messenger),
              ),
            ],
          ),
        ),
      );

      final controller = messenger.show(
        StreamSnackbar(
          message: const Text('Brief'),
          duration: const Duration(milliseconds: 50),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(await controller.closed, StreamSnackbarClosedReason.timeout);
    });

    testWidgets('controller.closed resolves with .swipe when user dismisses by swipe', (tester) async {
      final messenger = StreamSnackbarMessenger();
      addTearDown(messenger.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [StreamTheme.light()]),
          home: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: StreamSnackbarHost(messenger: messenger),
              ),
            ],
          ),
        ),
      );

      final controller = messenger.show(StreamSnackbar(message: const Text('Bye')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.fling(find.text('Bye'), const Offset(0, 300), 1000);
      await tester.pumpAndSettle();

      expect(await controller.closed, StreamSnackbarClosedReason.swipe);
    });

    testWidgets('queued snackbars show one after another', (tester) async {
      final messenger = StreamSnackbarMessenger();
      addTearDown(messenger.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [StreamTheme.light()]),
          home: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: StreamSnackbarHost(messenger: messenger),
              ),
            ],
          ),
        ),
      );

      final first = messenger.show(StreamSnackbar(message: const Text('First')));
      final second = messenger.show(StreamSnackbar(message: const Text('Second')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsNothing);

      first.close();
      await tester.pumpAndSettle();

      expect(find.text('First'), findsNothing);
      expect(find.text('Second'), findsOneWidget);
      expect(await first.closed, StreamSnackbarClosedReason.dismiss);

      second.close();
      await tester.pumpAndSettle();
      expect(await second.closed, StreamSnackbarClosedReason.dismiss);
    });

    testWidgets('queued snackbar shows after the current one is swipe-dismissed', (tester) async {
      final messenger = StreamSnackbarMessenger();
      addTearDown(messenger.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [StreamTheme.light()]),
          home: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: StreamSnackbarHost(messenger: messenger),
              ),
            ],
          ),
        ),
      );

      final first = messenger.show(StreamSnackbar(message: const Text('First')));
      messenger.show(StreamSnackbar(message: const Text('Second')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('First'), findsOneWidget);

      await tester.fling(find.text('First'), const Offset(0, 300), 1000);
      await tester.pumpAndSettle();

      expect(await first.closed, StreamSnackbarClosedReason.swipe);
      expect(find.text('Second'), findsOneWidget);
    });

    testWidgets('queued (not yet shown) snackbar can be closed before its turn', (tester) async {
      final messenger = StreamSnackbarMessenger();
      addTearDown(messenger.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [StreamTheme.light()]),
          home: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: StreamSnackbarHost(messenger: messenger),
              ),
            ],
          ),
        ),
      );

      final first = messenger.show(StreamSnackbar(message: const Text('First')));
      final queued = messenger.show(StreamSnackbar(message: const Text('Queued')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Cancel the queued one before it ever shows.
      queued.close();
      expect(await queued.closed, StreamSnackbarClosedReason.dismiss);
      expect(find.text('First'), findsOneWidget);
      expect(find.text('Queued'), findsNothing);

      // First should still be on screen and behave normally.
      first.close();
      await tester.pumpAndSettle();
      expect(await first.closed, StreamSnackbarClosedReason.dismiss);
    });

    testWidgets('throwing action callback still closes the snackbar', (tester) async {
      final messenger = StreamSnackbarMessenger();
      addTearDown(messenger.dispose);
      final errors = <Object>[];
      final originalHandler = FlutterError.onError;
      FlutterError.onError = (details) => errors.add(details.exception);
      addTearDown(() => FlutterError.onError = originalHandler);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [StreamTheme.light()]),
          home: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: StreamSnackbarHost(messenger: messenger),
              ),
            ],
          ),
        ),
      );

      final controller = messenger.show(
        StreamSnackbar(
          message: const Text('Boom'),
          action: StreamSnackbarAction(
            label: const Text('Throw'),
            onPressed: () => throw StateError('user callback failed'),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Throw'));
      await tester.pumpAndSettle();

      expect(await controller.closed, StreamSnackbarClosedReason.action);
      expect(errors.whereType<StateError>(), isNotEmpty);
    });

    testWidgets('StreamComponentFactory.snackbar override is honoured', (tester) async {
      final messenger = StreamSnackbarMessenger();
      addTearDown(messenger.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [StreamTheme.light()]),
          home: StreamComponentFactory(
            builders: StreamComponentBuilders(
              snackbar: (context, props) => Directionality(
                textDirection: TextDirection.ltr,
                child: DefaultTextStyle(
                  style: const TextStyle(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [const Text('custom: '), props.message],
                  ),
                ),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: StreamSnackbarHost(messenger: messenger),
                ),
              ],
            ),
          ),
        ),
      );

      messenger.show(StreamSnackbar(message: const Text('hello')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('custom: '), findsOneWidget);
      expect(find.text('hello'), findsOneWidget);
    });

    testWidgets('action button cannot be tapped twice', (tester) async {
      final messenger = StreamSnackbarMessenger();
      addTearDown(messenger.dispose);
      var pressCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [StreamTheme.light()]),
          home: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: StreamSnackbarHost(messenger: messenger),
              ),
            ],
          ),
        ),
      );

      messenger.show(
        StreamSnackbar(
          message: const Text('Saved'),
          action: StreamSnackbarAction(
            label: const Text('Undo'),
            onPressed: () => pressCount++,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Undo'));
      expect(pressCount, 1);

      // Second tap during the exit animation must be a no-op.
      await tester.tap(find.text('Undo'), warnIfMissed: false);
      expect(pressCount, 1);

      await tester.pumpAndSettle();
    });

    testWidgets('snackbar contributes dismiss semantics', (tester) async {
      final semantics = tester.ensureSemantics();
      final messenger = StreamSnackbarMessenger();
      addTearDown(messenger.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [StreamTheme.light()]),
          home: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: StreamSnackbarHost(messenger: messenger),
              ),
            ],
          ),
        ),
      );

      messenger.show(StreamSnackbar(message: const Text('Saved')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // The message merges into the snackbar's own node rather than staying a
      // child of it, which is what makes the live region announce it.
      expect(
        tester.getSemantics(find.byType(StreamSnackbar)),
        isSemantics(
          label: 'Saved',
          isLiveRegion: true,
          hasDismissAction: true,
        ),
      );

      semantics.dispose();
    });

    group('default display duration', () {
      testWidgets('neutral without action auto-dismisses after 5s', (tester) async {
        final messenger = StreamSnackbarMessenger();
        addTearDown(messenger.dispose);

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(extensions: [StreamTheme.light()]),
            home: Stack(
              children: [
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: StreamSnackbarHost(messenger: messenger),
                ),
              ],
            ),
          ),
        );

        final controller = messenger.show(StreamSnackbar(message: const Text('msg')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Still visible just before the 5 s threshold.
        await tester.pump(const Duration(seconds: 4, milliseconds: 500));
        expect(find.text('msg'), findsOneWidget);

        // Past the threshold + exit animation: gone.
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
        expect(find.text('msg'), findsNothing);
        expect(await controller.closed, StreamSnackbarClosedReason.timeout);
      });

      testWidgets('neutral with action lingers 10s', (tester) async {
        final messenger = StreamSnackbarMessenger();
        addTearDown(messenger.dispose);

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(extensions: [StreamTheme.light()]),
            home: Stack(
              children: [
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: StreamSnackbarHost(messenger: messenger),
                ),
              ],
            ),
          ),
        );

        messenger.show(
          StreamSnackbar(
            message: const Text('msg'),
            action: StreamSnackbarAction(label: const Text('Undo'), onPressed: () {}),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Still visible at 7 s (would have dismissed at 5 s without the action).
        await tester.pump(const Duration(seconds: 7));
        expect(find.text('msg'), findsOneWidget);

        // Past 10 s + exit anim: gone.
        await tester.pump(const Duration(seconds: 4));
        await tester.pumpAndSettle();
        expect(find.text('msg'), findsNothing);
      });

      testWidgets('loading variant is persistent', (tester) async {
        final messenger = StreamSnackbarMessenger();
        addTearDown(messenger.dispose);

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(extensions: [StreamTheme.light()]),
            home: Stack(
              children: [
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: StreamSnackbarHost(messenger: messenger),
                ),
              ],
            ),
          ),
        );

        messenger.show(
          StreamSnackbar(
            message: const Text('loading'),
            variant: StreamSnackbarVariant.loading,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Stays through any sane interval.
        await tester.pump(const Duration(seconds: 30));
        expect(find.text('loading'), findsOneWidget);
      });

      testWidgets('error with action is persistent', (tester) async {
        final messenger = StreamSnackbarMessenger();
        addTearDown(messenger.dispose);

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(extensions: [StreamTheme.light()]),
            home: Stack(
              children: [
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: StreamSnackbarHost(messenger: messenger),
                ),
              ],
            ),
          ),
        );

        messenger.show(
          StreamSnackbar(
            message: const Text('boom'),
            variant: StreamSnackbarVariant.error,
            action: StreamSnackbarAction(label: const Text('Retry'), onPressed: () {}),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        await tester.pump(const Duration(seconds: 30));
        expect(find.text('boom'), findsOneWidget);
      });
    });

    testWidgets('per-instance dismissDirection overrides default', (tester) async {
      final messenger = StreamSnackbarMessenger();
      addTearDown(messenger.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [StreamTheme.light()]),
          home: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: StreamSnackbarHost(messenger: messenger),
              ),
            ],
          ),
        ),
      );

      final controller = messenger.show(
        StreamSnackbar(
          message: const Text('Swipe up'),
          dismissDirection: DismissDirection.up,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Swipe DOWN — should not dismiss (configured direction is up).
      await tester.fling(find.text('Swipe up'), const Offset(0, 300), 1000);
      await tester.pumpAndSettle();
      expect(find.text('Swipe up'), findsOneWidget);

      // Swipe UP — dismisses.
      await tester.fling(find.text('Swipe up'), const Offset(0, -300), 1000);
      await tester.pumpAndSettle();
      expect(find.text('Swipe up'), findsNothing);
      expect(await controller.closed, StreamSnackbarClosedReason.swipe);
    });
  });

  group('StreamSnackbarScope', () {
    testWidgets('scope.of(context).show renders via the scope', (tester) async {
      final key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [StreamTheme.light()]),
          home: StreamSnackbarScope(
            child: Center(child: SizedBox(key: key, width: 1, height: 1)),
          ),
        ),
      );

      StreamSnackbarMessenger.of(key.currentContext!).show(
        StreamSnackbar(message: const Text('Convenient')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Convenient'), findsOneWidget);
    });

    testWidgets('scope.of(context) throws when no scope ancestor exists', (tester) async {
      final key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [StreamTheme.light()]),
          home: Center(child: SizedBox(key: key, width: 1, height: 1)),
        ),
      );

      expect(
        () => StreamSnackbarMessenger.of(key.currentContext!),
        throwsFlutterError,
      );
    });

    testWidgets('hideCurrent dismisses the current snackbar', (tester) async {
      final key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [StreamTheme.light()]),
          home: StreamSnackbarScope(
            child: Center(child: SizedBox(key: key, width: 1, height: 1)),
          ),
        ),
      );

      final host = StreamSnackbarMessenger.of(key.currentContext!);
      host.show(StreamSnackbar(message: const Text('Goodbye')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Goodbye'), findsOneWidget);

      host.hideCurrent();
      await tester.pumpAndSettle();
      expect(find.text('Goodbye'), findsNothing);
    });

    testWidgets('show returns controller with closed future', (tester) async {
      final key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [StreamTheme.light()]),
          home: StreamSnackbarScope(
            child: Center(child: SizedBox(key: key, width: 1, height: 1)),
          ),
        ),
      );

      final controller = StreamSnackbarMessenger.of(key.currentContext!).show(
        StreamSnackbar(
          message: const Text('Deleted'),
          action: StreamSnackbarAction(label: const Text('Undo'), onPressed: () {}),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      expect(await controller.closed, StreamSnackbarClosedReason.action);
    });

    testWidgets('nested scopes — show targets the innermost', (tester) async {
      final outerState = StreamSnackbarMessenger();
      addTearDown(outerState.dispose);
      final innerKey = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [StreamTheme.light()]),
          home: StreamSnackbarScope.withState(
            messenger: outerState,
            child: StreamSnackbarScope(
              child: Center(child: SizedBox(key: innerKey, width: 1, height: 1)),
            ),
          ),
        ),
      );

      StreamSnackbarMessenger.of(innerKey.currentContext!).show(
        StreamSnackbar(message: const Text('Inner only')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Inner only'), findsOneWidget);
      expect(outerState.currentSnackbar, isNull);
    });

    testWidgets('StreamSnackbarScope.withState delegates to external state', (tester) async {
      final externalState = StreamSnackbarMessenger();
      addTearDown(externalState.dispose);
      final key = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [StreamTheme.light()]),
          home: StreamSnackbarScope.withState(
            messenger: externalState,
            child: Center(child: SizedBox(key: key, width: 1, height: 1)),
          ),
        ),
      );

      StreamSnackbarMessenger.of(key.currentContext!).show(
        StreamSnackbar(message: const Text('External')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('External'), findsOneWidget);
      expect(externalState.currentSnackbar, isNotNull);
    });
  });

  group('StreamSnackbarPopup', () {
    testWidgets('renders snackbar above its anchor', (tester) async {
      final messenger = StreamSnackbarMessenger();
      addTearDown(messenger.dispose);
      final anchorKey = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [StreamTheme.light()]),
          home: Center(
            child: StreamSnackbarPopup.withState(
              messenger: messenger,
              child: SizedBox(key: anchorKey, width: 200, height: 60),
            ),
          ),
        ),
      );

      messenger.show(StreamSnackbar(message: const Text('Above')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Above'), findsOneWidget);

      final anchorTopY = tester.getTopLeft(find.byKey(anchorKey)).dy;
      final snackbarBottomY = tester.getBottomLeft(find.text('Above')).dy;
      expect(snackbarBottomY, lessThanOrEqualTo(anchorTopY));
    });

    testWidgets('placement: under renders snackbar below its anchor', (tester) async {
      final messenger = StreamSnackbarMessenger();
      addTearDown(messenger.dispose);
      final anchorKey = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [StreamTheme.light()]),
          home: Center(
            child: StreamSnackbarPopup.withState(
              messenger: messenger,
              placement: StreamSnackbarPopupPlacement.under,
              child: SizedBox(key: anchorKey, width: 200, height: 60),
            ),
          ),
        ),
      );

      messenger.show(StreamSnackbar(message: const Text('Under')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Under'), findsOneWidget);

      final anchorBottomY = tester.getBottomLeft(find.byKey(anchorKey)).dy;
      final snackbarTopY = tester.getTopLeft(find.text('Under')).dy;
      expect(snackbarTopY, greaterThanOrEqualTo(anchorBottomY));
    });

    testWidgets('default ctor auto-manages messenger — descendants fire via context', (tester) async {
      final anchorKey = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [StreamTheme.light()]),
          home: Center(
            child: StreamSnackbarPopup(
              child: SizedBox(key: anchorKey, width: 200, height: 60),
            ),
          ),
        ),
      );

      // Descendant of the anchor fires via the inherited messenger.
      StreamSnackbarMessenger.maybeOf(anchorKey.currentContext!)?.show(
        StreamSnackbar(message: const Text('Auto-managed')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Auto-managed'), findsOneWidget);
    });
  });

  group('accessibleNavigation', () {
    Widget hostScaffold(StreamSnackbarMessenger messenger) {
      return MaterialApp(
        theme: ThemeData(extensions: [StreamTheme.light()]),
        home: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: StreamSnackbarHost(messenger: messenger),
            ),
          ],
        ),
      );
    }

    FadeTransition fadeOf(WidgetTester tester) {
      return tester.widget<FadeTransition>(
        find.descendant(
          of: find.byType(StreamSnackbarHost),
          matching: find.byType(FadeTransition),
        ),
      );
    }

    testWidgets('on — entry skips animation (opacity 1.0 after one frame)', (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(
        accessibleNavigation: true,
      );
      addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

      final messenger = StreamSnackbarMessenger();
      addTearDown(messenger.dispose);

      await tester.pumpWidget(hostScaffold(messenger));

      messenger.show(StreamSnackbar(message: const Text('Hello')));
      await tester.pump();

      expect(fadeOf(tester).opacity.value, equals(1.0));
    });

    testWidgets('on — exit skips animation and resolves controller after one frame', (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(
        accessibleNavigation: true,
      );
      addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

      final messenger = StreamSnackbarMessenger();
      addTearDown(messenger.dispose);

      await tester.pumpWidget(hostScaffold(messenger));

      final controller = messenger.show(StreamSnackbar(message: const Text('Bye')));
      await tester.pump();
      expect(find.text('Bye'), findsOneWidget);

      controller.close();
      await tester.pump();

      expect(find.text('Bye'), findsNothing);
      expect(await controller.closed, StreamSnackbarClosedReason.dismiss);
    });
  });
}
