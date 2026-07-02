import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/chat.dart';

Widget _withStreamTheme(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [StreamTheme()]),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  testWidgets('media attachment — semantic tree', (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(
      _withStreamTheme(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            StreamMessageComposerMediaAttachment(
              semanticLabel: 'Photo 1',
              onRemovePressed: () {},
              child: Container(color: Colors.grey),
            ),
            StreamMessageComposerMediaAttachment(
              semanticLabel: 'Photo 2',
              onRemovePressed: () {},
              child: Container(color: Colors.blue),
            ),
          ],
        ),
      ),
    );

    debugPrint('=== TRAVERSAL ===');
    final order = tester.semantics.simulatedAccessibilityTraversal();
    var i = 0;
    for (final node in order) {
      final data = node.getSemanticsData();
      final actions = SemanticsAction.values.where((a) => (data.actions & a.index) != 0).map((a) => a.name).toList();
      final flags = data.flagsCollection.toStrings();
      if (data.label.isEmpty && actions.isEmpty && flags.isEmpty) continue;
      debugPrint('[$i] rect=${node.rect}  label="${data.label}"  flags=$flags  actions=$actions');
      i++;
    }

    debugPrint('\n=== FULL TREE ===');
    final root = RendererBinding.instance.rootPipelineOwner.semanticsOwner?.rootSemanticsNode;
    debugPrint(root?.toStringDeep() ?? '(none)');

    handle.dispose();
  });
}
