import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/src/utils/display_fold.dart';

void main() {
  Future<Offset> anchorIn(WidgetTester tester, TextDirection textDirection) async {
    late Offset anchor;
    await tester.pumpWidget(
      Directionality(
        textDirection: textDirection,
        child: Builder(
          builder: (context) {
            anchor = trailingTopAnchorOf(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    return anchor;
  }

  testWidgets('trailingTopAnchorOf is the top-right corner left to right', (tester) async {
    expect(await anchorIn(tester, TextDirection.ltr), const Offset(double.maxFinite, 0));
  });

  testWidgets('trailingTopAnchorOf is the top-left corner right to left', (tester) async {
    expect(await anchorIn(tester, TextDirection.rtl), Offset.zero);
  });
}
