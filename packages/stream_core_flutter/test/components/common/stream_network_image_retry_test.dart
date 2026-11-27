import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

import 'recovering_image_server.dart';

void main() {
  testWidgets('shows the image after the retry badge is tapped once the server recovers', (tester) async {
    final server = await RecoveringImageServer.start(tester);

    await tester.pumpWidget(withStreamTheme(StreamNetworkImage(server.url('tapped.png'), width: 40, height: 40)));
    await pumpUntil(tester, () => find.byType(StreamImageErrorPlaceholder).evaluate().isNotEmpty);
    expect(find.byType(StreamImageErrorPlaceholder), findsOneWidget);

    server.recover();
    await tester.tap(find.byType(StreamImageErrorPlaceholder));
    await pumpUntil(tester, () => shownImages(tester) == 1);

    expect(shownImages(tester), 1);
    expect(find.byType(StreamImageErrorPlaceholder), findsNothing);
    await disposeAndFlushTimers(tester);
  });
}
