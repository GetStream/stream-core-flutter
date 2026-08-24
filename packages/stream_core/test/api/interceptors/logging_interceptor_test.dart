import 'dart:convert';

import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

import '../../helpers/logger.dart';
import '../../helpers/user_token.dart';

class _FakeApi implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<Uint8List>? s, Future<void>? c) async {
    return ResponseBody.fromString(
      jsonEncode(const {'ok': true}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Builds the interceptor stack a Stream SDK puts on its client, in the same order.
Dio _subject({LogPrint? logPrint}) {
  final tokens = TokenManager(
    userId: 'user-1',
    tokenProvider: TokenProvider.static(generateTestUserToken('user-1')),
  );

  final dio = Dio(BaseOptions(baseUrl: 'https://example.com'))..httpClientAdapter = _FakeApi();
  return dio
    ..interceptors.addAll([
      AuthInterceptor(dio, tokens),
      LoggingInterceptor(requestHeader: true, logPrint: logPrint),
    ]);
}

void main() {
  group('LoggingInterceptor', () {
    test('writes nothing until an app installs a handler', () async {
      final dio = _subject();

      final printed = capturePrints(() => dio.get<void>('/test'));
      await pumpEventQueue();

      // It used to print every request, headers and all, in every build.
      expect(printed, isEmpty);
    });

    test('leaves the credentials out of a log nobody asked for', () async {
      final dio = _subject();
      final token = generateTestUserToken('user-1').rawValue;

      final printed = capturePrints(() => dio.get<void>('/test'));
      await pumpEventQueue();

      // `requestHeader` puts `Authorization` in the record, and the request is signed before this
      // interceptor sees it, so a log written unasked carries the user's token.
      expect(printed.join(), isNot(contains(token)));
    });

    test('reports the request once a handler wants it', () async {
      final handler = RecordingLogHandler();
      final dio = _subject();

      await withStreamLogger(
        handler: handler,
        filter: const StreamLogFilter.minPriority(StreamLogPriority.debug),
        () async {
          await dio.get<void>('/test');
          await pumpEventQueue();
        },
      );

      expect(handler.tags, everyElement('SC:Http'));
      expect(handler.messages.join(), contains('https://example.com/test'));
    });

    test('writes through the logger rather than printing, when given no printer', () async {
      final handler = RecordingLogHandler();
      final dio = _subject();

      final printed = await withStreamLogger(
        handler: handler,
        filter: const StreamLogFilter.always(),
        () async {
          final lines = capturePrints(() => dio.get<void>('/test').ignore());
          await pumpEventQueue();
          return lines;
        },
      );

      expect(handler.records, isNotEmpty, reason: 'the records reached the handler');
      expect(printed, isEmpty, reason: 'and none of them went to the console');
    });

    test('hands the lines to a printer a caller supplied, leaving the logger out of it', () async {
      final handler = RecordingLogHandler();
      var lines = 0;
      final dio = _subject(logPrint: (_, _) => lines++);

      await withStreamLogger(
        handler: handler,
        filter: const StreamLogFilter.always(),
        () async {
          await dio.get<void>('/test');
          await pumpEventQueue();
        },
      );

      expect(lines, greaterThan(0));
      expect(handler.records, isEmpty, reason: 'a supplied printer replaces the logger');
    });
  });
}
