import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

import 'recovering_image_server.dart';

void main() {
  testWidgets('shows the image in every widget of a failed URL when the retry listenable notifies', (tester) async {
    final server = await RecoveringImageServer.start(tester);
    final retry = ChangeNotifier();
    addTearDown(retry.dispose);
    final url = server.url('shared.png');

    await tester.pumpWidget(
      withStreamTheme(
        Column(
          children: [
            StreamNetworkImage(url, width: 40, height: 40, retryListenable: retry),
            StreamNetworkImage(url, width: 40, height: 40, retryListenable: retry),
          ],
        ),
      ),
    );
    await pumpUntil(tester, () => find.byType(StreamImageErrorPlaceholder).evaluate().length == 2);
    expect(find.byType(StreamImageErrorPlaceholder), findsNWidgets(2));

    server.recover();
    retry.notifyListeners();
    await pumpUntil(tester, () => shownImages(tester) == 2);

    expect(shownImages(tester), 2);
    expect(find.byType(StreamImageErrorPlaceholder), findsNothing);
    await disposeAndFlushTimers(tester);
  });
}
