import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

import 'recovering_image_server.dart';

void main() {
  testWidgets('ignores the retry listenable once a failed image loads at a new size', (tester) async {
    final server = await RecoveringImageServer.start(tester);
    final retry = ChangeNotifier();
    addTearDown(retry.dispose);
    final url = server.url('resized.png');

    await tester.pumpWidget(withStreamTheme(StreamNetworkImage(url, width: 40, height: 40, retryListenable: retry)));
    await pumpUntil(tester, () => find.byType(StreamImageErrorPlaceholder).evaluate().isNotEmpty);
    expect(find.byType(StreamImageErrorPlaceholder), findsOneWidget);

    server.recover();
    await tester.pumpWidget(withStreamTheme(StreamNetworkImage(url, width: 48, height: 48, retryListenable: retry)));
    await pumpUntil(tester, () => shownImages(tester) == 1);
    expect(shownImages(tester), 1);

    retry.notifyListeners();
    await tester.pump();

    expect(shownImages(tester), 1);
    await disposeAndFlushTimers(tester);
  });
}
