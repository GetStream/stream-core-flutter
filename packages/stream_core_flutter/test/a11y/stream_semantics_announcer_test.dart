import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart' show SystemChannels;
import 'package:flutter_test/flutter_test.dart';
import 'package:stream_core_flutter/core.dart';

void main() {
  late List<Map<dynamic, dynamic>> sentMessages;

  Map<dynamic, dynamic> dataOf(int index) {
    return sentMessages[index]['data']! as Map<dynamic, dynamic>;
  }

  Future<BuildContext> pumpHost(WidgetTester tester, TargetPlatform platform) async {
    late BuildContext capturedContext;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: platform),
        home: Builder(
          builder: (context) {
            capturedContext = context;
            return const SizedBox();
          },
        ),
      ),
    );
    return capturedContext;
  }

  setUp(() {
    sentMessages = <Map<dynamic, dynamic>>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(
      SystemChannels.accessibility,
      (mockMessage) async {
        sentMessages.add(mockMessage as Map<dynamic, dynamic>);
      },
    );
  });

  tearDown(() {
    StreamSemanticsAnnouncer.cancel();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(
      SystemChannels.accessibility,
      null,
    );
  });

  group('StreamSemanticsAnnouncer.announce', () {
    testWidgets('dispatches immediately on non-iOS platforms', (tester) async {
      final context = await pumpHost(tester, TargetPlatform.android);

      StreamSemanticsAnnouncer.announce(context, 'hello');
      await tester.pump();

      expect(sentMessages, hasLength(1));
      expect(sentMessages.single['type'], 'announce');
      expect(dataOf(0)['message'], 'hello');
    });

    testWidgets('delays by 1 second on iOS with polite assertiveness', (tester) async {
      final context = await pumpHost(tester, TargetPlatform.iOS);

      StreamSemanticsAnnouncer.announce(context, 'polite');
      await tester.pump();
      // Nothing dispatched yet — Timer hasn't fired.
      expect(sentMessages, isEmpty);

      await tester.pump(const Duration(seconds: 1));
      expect(sentMessages, hasLength(1));
      expect(dataOf(0)['message'], 'polite');
    });

    testWidgets('dispatches immediately on iOS with assertive assertiveness', (tester) async {
      final context = await pumpHost(tester, TargetPlatform.iOS);

      StreamSemanticsAnnouncer.announce(
        context,
        'urgent',
        assertiveness: Assertiveness.assertive,
      );
      await tester.pump();

      expect(sentMessages, hasLength(1));
      expect(dataOf(0)['message'], 'urgent');
      expect(dataOf(0)['assertiveness'], 1);
    });

    testWidgets('rapid polite calls on iOS only emit the latest message', (tester) async {
      final context = await pumpHost(tester, TargetPlatform.iOS);

      StreamSemanticsAnnouncer.announce(context, 'first');
      await tester.pump(const Duration(milliseconds: 200));
      StreamSemanticsAnnouncer.announce(context, 'second');
      await tester.pump(const Duration(seconds: 1));

      expect(sentMessages, hasLength(1));
      expect(dataOf(0)['message'], 'second');
    });

    testWidgets('cancel() clears the pending iOS timer', (tester) async {
      final context = await pumpHost(tester, TargetPlatform.iOS);

      StreamSemanticsAnnouncer.announce(context, 'discarded');
      StreamSemanticsAnnouncer.cancel();
      await tester.pump(const Duration(seconds: 2));

      expect(sentMessages, isEmpty);
    });

    testWidgets('reports platform-channel errors via FlutterError', (tester) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(
        SystemChannels.accessibility,
        (_) async => throw StateError('channel down'),
      );

      final errors = <FlutterErrorDetails>[];
      final originalOnError = FlutterError.onError;
      FlutterError.onError = errors.add;
      addTearDown(() => FlutterError.onError = originalOnError);

      final context = await pumpHost(tester, TargetPlatform.android);
      StreamSemanticsAnnouncer.announce(context, 'doomed');
      await tester.pumpAndSettle();

      expect(errors, hasLength(1));
      expect(errors.single.exception, isA<StateError>());
      expect(errors.single.context.toString(), contains('screen-reader announcement'));
    });
  });

  group('StreamSemanticsAnnouncer.tooltip', () {
    testWidgets('dispatches a tooltip event', (tester) async {
      await StreamSemanticsAnnouncer.tooltip('tooltip text');

      expect(sentMessages, hasLength(1));
      expect(sentMessages.single['type'], 'tooltip');
      expect(dataOf(0)['message'], 'tooltip text');
    });
  });
}
