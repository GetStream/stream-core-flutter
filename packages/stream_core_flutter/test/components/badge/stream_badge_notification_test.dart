import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

void main() {
  testWidgets('StreamBadgeNotification lets a tap on the badge reach its child', (tester) async {
    var taps = 0;

    await tester.pumpWidget(
      _wrap(
        StreamBadgeNotification(
          label: '5',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => taps += 1,
            child: const SizedBox.square(dimension: 48),
          ),
        ),
      ),
    );

    await tester.tapAt(tester.getCenter(find.text('5')));

    expect(taps, 1);
  });
}

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [StreamTheme()]),
    home: Scaffold(body: Center(child: child)),
  );
}
