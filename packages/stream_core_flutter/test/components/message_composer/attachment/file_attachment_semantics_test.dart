import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stream_core_flutter/chat.dart';

Widget _withStreamTheme(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [StreamTheme()]),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  testWidgets('file attachment — single merged SR node with delete affordance', (tester) async {
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

    // MergeSemantics rolls up the title + subtitle Text nodes into one SR
    // focus stop that reads the joined label.
    final semantics = tester.getSemantics(find.bySemanticsLabel(RegExp(r'report\.pdf')));

    expect(semantics.label, contains('report.pdf'));
    expect(semantics.label, contains('2 MB'));

    // Tap on the merged node invokes the remove callback (VoiceOver says
    // "double-tap to Delete" via onTapHint).
    expect(semantics, isSemantics(hasTapAction: true, onTapHint: 'Delete'));

    handle.dispose();
  });
}
