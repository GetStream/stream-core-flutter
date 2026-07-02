import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

// Each slot of [StreamAppBar] must produce its own focus stop. A raw
// [GestureDetector] in a slot must not leak its tap action up to the
// bar's outer [Semantics] container — that would collapse the bar into
// a single tappable region. The fix is [explicitChildNodes: true] on
// the outer Semantics, matching Flutter's inner Semantics inside
// Material (app_bar.dart line 1246).

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [StreamTheme()]),
    home: child,
  );
}

void main() {
  testWidgets('slots stay isolated; trailing tap does not leak up', (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(
      _wrap(
        Scaffold(
          appBar: StreamAppBar(
            leading: Builder(
              builder: (context) => IconButton(
                tooltip: 'Back',
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
            automaticallyImplyLeading: false,
            title: const Text('John Doe'),
            subtitle: const Text('Online'),
            trailing: SizedBox.square(
              dimension: 48,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {},
                child: const Center(child: CircleAvatar(radius: 16)),
              ),
            ),
          ),
        ),
      ),
    );

    // Walk the semantics tree and find the outer bar node (the one whose
    // bounds match the toolbar height).
    SemanticsNode? barNode;
    void visit(SemanticsNode node) {
      if (node.rect.height == kStreamToolbarHeight && node.rect.width >= 500) {
        barNode = node;
      }
      node.visitChildren((child) {
        visit(child);
        return true;
      });
    }

    // rootPipelineOwner.semanticsOwner is null in test env; the deprecated
    // pipelineOwner path still points at the semantic root in tests.
    // ignore: deprecated_member_use
    visit(tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!);
    expect(barNode, isNotNull);

    // The outer bar node must have NO actions. A leak from a slot would
    // surface here and collapse the bar to one focus stop.
    final barActions = barNode!.getSemanticsData().actions;
    expect(barActions, equals(0), reason: 'Outer bar must not carry leaked actions');

    // Three children: leading, merged title+subtitle, trailing.
    final children = <SemanticsNode>[];
    barNode!.visitChildren((child) {
      children.add(child);
      return true;
    });
    expect(children.length, equals(3));

    // Trailing slot has its own tap-action node.
    expect(
      children.last.getSemanticsData().hasAction(SemanticsAction.tap),
      isTrue,
    );

    handle.dispose();
  });
}
