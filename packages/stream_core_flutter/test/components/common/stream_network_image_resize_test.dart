import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

import 'recovering_image_server.dart';

void main() {
  testWidgets('keeps showing a loaded image while it decodes at a new size', (tester) async {
    final server = await RecoveringImageServer.start(tester)
      ..recover();
    final url = server.url('resize.png');

    await tester.pumpWidget(withStreamTheme(StreamNetworkImage(url, width: 40, height: 40)));
    await pumpUntil(tester, () => shownImages(tester) == 1);
    expect(shownImages(tester), 1);

    await tester.pumpWidget(withStreamTheme(StreamNetworkImage(url, width: 48, height: 48)));

    expect(shownImages(tester), 1);
    await disposeAndFlushTimers(tester);
  });
}
