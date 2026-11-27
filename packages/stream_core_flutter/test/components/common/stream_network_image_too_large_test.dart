import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

import '../../helpers/blank_png.dart';
import 'recovering_image_server.dart';

void main() {
  testWidgets('shows an image with more pixels than 8192 by 8192 as an error it can retry', (tester) async {
    final server = await RecoveringImageServer.start(tester)
      ..serve(blankPng(8193, 8193));

    await tester.pumpWidget(withStreamTheme(StreamNetworkImage(server.url('large.png'), width: 40, height: 40)));
    await pumpUntil(tester, () => find.byType(StreamImageErrorPlaceholder).evaluate().isNotEmpty);

    expect(tester.widget<StreamImageErrorPlaceholder>(find.byType(StreamImageErrorPlaceholder)).onRetry, isNotNull);
    await disposeAndFlushTimers(tester);
  });
}
