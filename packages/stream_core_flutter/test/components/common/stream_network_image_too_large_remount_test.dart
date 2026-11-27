import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

import '../../helpers/blank_png.dart';
import 'recovering_image_server.dart';

void main() {
  testWidgets('downloads an image with more pixels than 8192 by 8192 once when shown again', (tester) async {
    final server = await RecoveringImageServer.start(tester)
      ..serve(blankPng(8193, 8193));
    final url = server.url('large.png');

    for (var mount = 1; mount <= 3; mount++) {
      await tester.pumpWidget(withStreamTheme(StreamNetworkImage(url, key: ValueKey(mount), width: 40, height: 40)));
      await pumpUntil(tester, () => find.byType(StreamImageErrorPlaceholder).evaluate().isNotEmpty);
      await tester.pumpWidget(const SizedBox());
    }

    expect(server.requestsFor('large.png'), 1);
    await disposeAndFlushTimers(tester);
  });
}
