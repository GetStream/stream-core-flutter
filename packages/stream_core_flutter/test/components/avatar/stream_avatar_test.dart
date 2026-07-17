import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

void main() {
  testWidgets('StreamAvatar renders a StreamNetworkImage when imageUrl is set', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: [StreamTheme()]),
        home: Scaffold(
          body: StreamAvatar(
            imageUrl: 'https://example.com/avatar.png',
            placeholder: (context) => const Text('A'),
          ),
        ),
      ),
    );

    final networkImage = tester.widget<StreamNetworkImage>(find.byType(StreamNetworkImage));
    expect(networkImage.props.url, equals('https://example.com/avatar.png'));
  });
}
