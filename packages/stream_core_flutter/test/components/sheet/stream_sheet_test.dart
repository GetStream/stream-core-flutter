import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/stream_core_flutter.dart';

Widget _withStreamTheme(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [StreamTheme()]),
    home: child,
  );
}

class _SheetLauncher extends StatelessWidget {
  const _SheetLauncher({required this.onPushed});

  final Future<Object?> Function(BuildContext context) onPushed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) => TextButton(
          onPressed: () => onPushed(context),
          child: const Text('Open'),
        ),
      ),
    );
  }
}

void main() {
  group('showStreamSheet', () {
    testWidgets('completes future with the popped value', (tester) async {
      Object? result;
      await tester.pumpWidget(
        _withStreamTheme(
          _SheetLauncher(
            onPushed: (context) async {
              return result = await showStreamSheet<String>(
                context: context,
                builder: (sheetContext, scrollController) {
                  return Center(
                    child: TextButton(
                      onPressed: () => Navigator.of(sheetContext).pop('done'),
                      child: const Text('Close'),
                    ),
                  );
                },
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Close'), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.text('Close'), findsNothing);
      expect(result, equals('done'));
    });

    testWidgets('drags the body down to dismiss the sheet', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          _SheetLauncher(
            onPushed: (context) {
              return showStreamSheet<void>(
                context: context,
                builder: (_, _) => const SizedBox.expand(
                  child: ColoredBox(
                    color: Color(0xFFFFC107),
                    child: Center(child: Text('Body')),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Body'), findsOneWidget);

      // Drag the body downwards far enough to trigger dismissal.
      final start = tester.getCenter(find.text('Body'));
      await tester.dragFrom(start, const Offset(0, 600));
      await tester.pumpAndSettle();

      expect(find.text('Body'), findsNothing);
    });

    testWidgets(
      'scrolling within scrollable does not dismiss until at top',
      (tester) async {
        await tester.pumpWidget(
          _withStreamTheme(
            _SheetLauncher(
              onPushed: (context) {
                return showStreamSheet<void>(
                  context: context,
                  builder: (_, scrollController) {
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: 100,
                      itemBuilder: (_, index) => SizedBox(
                        height: 64,
                        child: Center(child: Text('Item $index')),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.text('Item 0'), findsOneWidget);

        // Scroll the list upward (drag finger up): the sheet should NOT
        // dismiss; the list should scroll instead.
        await tester.fling(
          find.text('Item 5'),
          const Offset(0, -300),
          1000,
        );
        await tester.pumpAndSettle();

        // Sheet still on screen — find a now-visible item further down.
        expect(find.text('Item 0'), findsNothing);
        expect(find.byType(ListView), findsOneWidget);

        // Scroll back to the top.
        await tester.fling(
          find.byType(ListView),
          const Offset(0, 1500),
          2000,
        );
        await tester.pumpAndSettle();
        expect(find.text('Item 0'), findsOneWidget);

        // Now drag down at the top — should dismiss the sheet.
        await tester.dragFrom(
          tester.getCenter(find.text('Item 0')),
          const Offset(0, 600),
        );
        await tester.pumpAndSettle();

        expect(find.byType(ListView), findsNothing);
      },
    );

    testWidgets(
      'applies custom backgroundColor, borderRadius and elevation',
      (tester) async {
        const customColor = Color(0xFF112233);
        final customRadius = BorderRadius.circular(40);
        const customElevation = 4.0;

        await tester.pumpWidget(
          _withStreamTheme(
            _SheetLauncher(
              onPushed: (context) {
                return showStreamSheet<void>(
                  context: context,
                  backgroundColor: customColor,
                  borderRadius: customRadius,
                  elevation: customElevation,
                  builder: (_, _) => const SizedBox.expand(
                    child: Center(child: Text('Body')),
                  ),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        final materialFinder = find
            .descendant(
              of: find.byType(StreamSheetTransition),
              matching: find.byType(Material),
            )
            .first;
        final material = tester.widget<Material>(materialFinder);
        expect(material.color, equals(customColor));
        expect(material.borderRadius, equals(customRadius));
        expect(material.elevation, equals(customElevation));
      },
    );

    testWidgets(
      'isDismissible + barrierColor allow tap-to-dismiss',
      (tester) async {
        await tester.pumpWidget(
          _withStreamTheme(
            _SheetLauncher(
              onPushed: (context) {
                return showStreamSheet<void>(
                  context: context,
                  isDismissible: true,
                  barrierColor: const Color(0x80000000),
                  builder: (_, _) => const SizedBox.expand(
                    child: Center(child: Text('Body')),
                  ),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(find.text('Body'), findsOneWidget);

        // Tap above the sheet (in the barrier area). The sheet's top
        // sits at `spacing.sm = 12`, so a tap at y=4 is above it.
        await tester.tapAt(const Offset(20, 4));
        await tester.pumpAndSettle();

        expect(find.text('Body'), findsNothing);
      },
    );

    testWidgets('applies BoxConstraints to the sheet', (tester) async {
      await tester.pumpWidget(
        _withStreamTheme(
          _SheetLauncher(
            onPushed: (context) {
              return showStreamSheet<void>(
                context: context,
                constraints: const BoxConstraints(maxWidth: 320),
                builder: (_, _) => const SizedBox.expand(
                  child: Center(child: Text('Body')),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final sheetSize = tester.getSize(
        find
            .descendant(
              of: find.byType(StreamSheetTransition),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(sheetSize.width, lessThanOrEqualTo(320));
    });

    testWidgets(
      'stacked sheets share the root sheet topPadding',
      (tester) async {
        await tester.pumpWidget(
          _withStreamTheme(
            _SheetLauncher(
              onPushed: (context) {
                return showStreamSheet<void>(
                  context: context,
                  builder: (sheetContext, _) {
                    return Center(
                      child: TextButton(
                        onPressed: () {
                          showStreamSheet<void>(
                            context: sheetContext,
                            builder: (_, _) => const SizedBox.expand(
                              child: Center(child: Text('Inner')),
                            ),
                          );
                        },
                        child: const Text('Push inner'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Push inner'));
        await tester.pumpAndSettle();
        expect(find.text('Inner'), findsOneWidget);

        // Stream's stacked sheets resolve their topPadding the same way
        // as the root (`screenHeight * topGap`) — there's no per-depth
        // bump. The inner (stacked) sheet's Material should therefore
        // have the same layout height as the root sheet's Material.
        final materials = tester
            .widgetList<Material>(
              find.descendant(
                of: find.byType(StreamSheetTransition),
                matching: find.byType(Material),
              ),
            )
            .toList();
        final outerHeight = tester.renderObject<RenderBox>(find.byWidget(materials.first)).size.height;
        final innerHeight = tester.renderObject<RenderBox>(find.byWidget(materials.last)).size.height;
        expect(innerHeight, closeTo(outerHeight, 0.5));
      },
    );

    testWidgets(
      'foreground stacked sheet sits at spacing.sm and reaches the '
      'screen bottom',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          _withStreamTheme(
            _SheetLauncher(
              onPushed: (context) {
                return showStreamSheet<void>(
                  context: context,
                  builder: (sheetContext, _) {
                    return Center(
                      child: TextButton(
                        onPressed: () {
                          showStreamSheet<void>(
                            context: sheetContext,
                            builder: (_, _) => const SizedBox.expand(child: Text('Inner')),
                          );
                        },
                        child: const Text('Push inner'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Push inner'));
        await tester.pumpAndSettle();

        final innerMaterial = tester
            .widgetList<Material>(
              find.descendant(
                of: find.byType(StreamSheetTransition).last,
                matching: find.byType(Material),
              ),
            )
            .first;
        final box = tester.renderObject<RenderBox>(
          find.byWidget(innerMaterial),
        );
        final topLeft = box.localToGlobal(Offset.zero);
        final size = box.size;
        final screenHeight = tester.view.physicalSize.height;

        // The sheet sits at a fixed `spacing.sm` (= 12) from the screen
        // top — a fixed peek rather than a screen-relative gap, since
        // we don't shrink the underlying route. The foreground extends
        // all the way to the screen bottom (no primary lift, no bottom
        // gap).
        const spacingSm = 12.0;
        expect(topLeft.dy, closeTo(spacingSm, 0.5));
        expect(topLeft.dy + size.height, closeTo(screenHeight, 0.5));
      },
    );

    testWidgets(
      'covered sheets apply the secondary scale + slide-up while the '
      'topmost stays flush at its topPadding',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        Future<void> pushOnce(BuildContext context) {
          return showStreamSheet<void>(
            context: context,
            builder: (innerContext, _) {
              return Builder(
                builder: (buttonContext) => Center(
                  child: TextButton(
                    onPressed: () => pushOnce(buttonContext),
                    child: const Text('Push more'),
                  ),
                ),
              );
            },
          );
        }

        await tester.pumpWidget(
          _withStreamTheme(
            _SheetLauncher(
              onPushed: (context) => pushOnce(context),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        // Stack: depth 1 (just the original push from `Open`).
        // Push two more so we end up at depth 3. Use `.last` so we always
        // tap the topmost sheet's button.
        await tester.tap(find.text('Push more').last);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Push more').last);
        await tester.pumpAndSettle();

        const midUpShift = 0.005;
        const spacingSm = 12.0;
        const totalDepth = 3;
        final screenHeight = tester.view.physicalSize.height;

        // Per the design — every sheet shares the same `topPadding`
        // (= `spacing.sm = 12`), and the primary slide-up tween always
        // ends at `(0, 0)`. The foreground stays flush with the screen
        // edges; covered sheets apply only the secondary transform
        // (scale by 0.9165 around topCenter + slide-up by `midUpShift *
        // childHeight`, where `childHeight = screenHeight - topPadding
        // = screenHeight - 12`).
        //
        // For 3 stacked sheets the rendered tops are:
        //   depth 0 (root, covered):   12 - midUpShift * (h - 12)
        //   depth 1 (middle, covered): same as depth 0
        //   depth 2 (foreground, top): 12
        double renderedTopAt(int depth) {
          if (depth == totalDepth - 1) return spacingSm;
          final childHeight = screenHeight - spacingSm;
          return spacingSm - midUpShift * childHeight;
        }

        final transitions = tester.widgetList<StreamSheetTransition>(
          find.byType(StreamSheetTransition),
        );
        expect(transitions, hasLength(totalDepth));

        for (var depth = 0; depth < totalDepth; depth++) {
          final material = tester
              .widgetList<Material>(
                find.descendant(
                  of: find.byType(StreamSheetTransition).at(depth),
                  matching: find.byType(Material),
                ),
              )
              .first;
          final box = tester.renderObject<RenderBox>(find.byWidget(material));
          final actualTop = box.localToGlobal(Offset.zero).dy;
          expect(
            actualTop,
            closeTo(renderedTopAt(depth), 0.5),
            reason: 'depth $depth rendered top mismatch',
          );
        }

        // The foreground sits at exactly its `topPadding` and every
        // covered sheet sits slightly above (by `midUpShift *
        // childHeight`), giving the rounded top corners of the
        // underlying stack a small peek above the foreground.
        final foregroundTop = renderedTopAt(totalDepth - 1);
        for (var depth = 0; depth < totalDepth - 1; depth++) {
          expect(
            renderedTopAt(depth),
            lessThan(foregroundTop),
            reason: 'covered depth $depth should peek above the foreground',
          );
        }
      },
    );

    testWidgets(
      'useNestedNavigation pushes routes inside the sheet and popSheet '
      'dismisses the whole sheet',
      (tester) async {
        await tester.pumpWidget(
          _withStreamTheme(
            _SheetLauncher(
              onPushed: (context) {
                return showStreamSheet<void>(
                  context: context,
                  useNestedNavigation: true,
                  builder: (sheetContext, _) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('First'),
                          TextButton(
                            onPressed: () {
                              Navigator.of(sheetContext).push(
                                MaterialPageRoute<void>(
                                  builder: (innerContext) => Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text('Second'),
                                        TextButton(
                                          onPressed: () => StreamSheetRoute.popSheet(
                                            innerContext,
                                          ),
                                          child: const Text('Close All'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: const Text('Push'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(find.text('First'), findsOneWidget);

        await tester.tap(find.text('Push'));
        await tester.pumpAndSettle();
        expect(find.text('Second'), findsOneWidget);

        await tester.tap(find.text('Close All'));
        await tester.pumpAndSettle();

        expect(find.text('First'), findsNothing);
        expect(find.text('Second'), findsNothing);
        expect(find.text('Open'), findsOneWidget);
      },
    );
  });
}
