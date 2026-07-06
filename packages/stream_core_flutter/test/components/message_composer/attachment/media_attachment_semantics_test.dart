import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/chat.dart';

Widget _withStreamTheme(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [StreamTheme()]),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  testWidgets('media attachments — one merged SR node per tile, correct traversal order', (tester) async {
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

    final photo1 = tester.getSemantics(find.bySemanticsLabel('Photo 1'));
    final photo2 = tester.getSemantics(find.bySemanticsLabel('Photo 2'));

    for (final tile in [photo1, photo2]) {
      expect(tile, containsSemantics(hasTapAction: true, onTapHint: 'Delete'));
    }

    // The remove control is ExcludeSemantics'd — no separate button node.
    expect(find.bySemanticsLabel('Delete'), findsNothing);

    // SR walks Photo 1 before Photo 2.
    final labels = tester.semantics
        .simulatedAccessibilityTraversal()
        .map((n) => n.getSemanticsData().label)
        .where((l) => l == 'Photo 1' || l == 'Photo 2')
        .toList();
    expect(labels, ['Photo 1', 'Photo 2']);

    handle.dispose();
  });
}
