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
  testWidgets('file attachment — semantic tree', (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(
      _withStreamTheme(
        StreamMessageComposerFileAttachment(
          title: const Text('report.pdf'),
          subtitle: const Text('2 MB'),
          fileTypeIcon: StreamFileTypeIcon(type: StreamFileType.pdf, extension: 'PDF'),
          onRemovePressed: () {},
        ),
      ),
    );

    debugPrint('=== ACCESSIBILITY TRAVERSAL ORDER (what SR walks) ===');
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

    debugPrint('\n=== FULL SEMANTIC TREE ===');
    final owner = RendererBinding.instance.rootPipelineOwner.semanticsOwner;
    final root = owner?.rootSemanticsNode;
    debugPrint(root?.toStringDeep() ?? '(no root semantic node)');

    handle.dispose();
  });
}
