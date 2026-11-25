import 'dart:convert';

import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

import '../../helpers/logger.dart';
import '../../helpers/user_token.dart';

class _FakeApi implements HttpClientAdapter {
  _FakeApi({this.body = const {'ok': true}});

  final Map<String, Object?> body;

  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<Uint8List>? s, Future<void>? c) async {
    return ResponseBody.fromString(
      jsonEncode(body),
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
Dio _subject({
  LogPrint? logPrint,
  bool requestHeader = true,
  bool compact = true,
  Map<String, Object?> body = const {'ok': true},
}) {
  final tokens = TokenManager(
    userId: 'user-1',
    tokenProvider: TokenProvider.static(generateTestUserToken('user-1')),
  );

  final dio = Dio(BaseOptions(baseUrl: 'https://example.com'))..httpClientAdapter = _FakeApi(body: body);
  return dio
    ..interceptors.addAll([
      AuthInterceptor(dio, tokens),
      LoggingInterceptor(requestHeader: requestHeader, compact: compact, logPrint: logPrint),
    ]);
}

/// A response the size the API really answers a list request with.
Map<String, Object?> _bulkyBody() => {
  'threads': List.generate(
    20,
    (i) => {'channel_cid': 'messaging:channel-$i', 'title': 'a' * 200},
  ),
  'next': 'W3sibmFtZSI6Imhhc191bnJlYWQiLCJ2YWx1ZSI6ZmFsc2UsImRpcmVjdGlvbiI6LTF9' * 4,
};

// Sends one GET through [create]'s interceptor and returns every line it reported.
Future<String> _linesOf(
  LoggingInterceptor Function(LogPrint logPrint) create, {
  String path = '/test',
  Map<String, Object?> headers = const {},
}) async {
  final lines = <String>[];
  final dio = Dio(BaseOptions(baseUrl: 'https://example.com', headers: headers))
    ..httpClientAdapter = _FakeApi()
    ..interceptors.add(create((_, line) => lines.add('$line')));

  await dio.get<void>(path);
  return lines.join('\n');
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

      expect(printed.join(), isNot(contains(token)));
    });

    test('keeps the credentials out of a log that was asked for, left at its defaults', () async {
      final handler = RecordingLogHandler();
      final dio = _subject(requestHeader: false);
      final token = generateTestUserToken('user-1').rawValue;

      await withStreamLogger(
        handler: handler,
        filter: const StreamLogFilter.always(),
        () async {
          await dio.get<void>('/test');
          await pumpEventQueue();
        },
      );

      expect(handler.records, isNotEmpty, reason: 'the request was reported');
      expect(handler.messages.join(), isNot(contains(token)));
    });

    test('reports the headers with the Authorization value redacted', () async {
      final handler = RecordingLogHandler();
      final dio = _subject();
      final token = generateTestUserToken('user-1').rawValue;

      await withStreamLogger(
        handler: handler,
        filter: const StreamLogFilter.always(),
        () async {
          await dio.get<void>('/test');
          await pumpEventQueue();
        },
      );

      expect(handler.messages.join(), contains('Authorization'));
      expect(handler.messages.join(), contains('██'));
      expect(handler.messages.join(), isNot(contains(token)));
    });

    test('redacts the Authorization header by default whatever its case', () async {
      final log = await _linesOf(
        (logPrint) => LoggingInterceptor(requestHeader: true, logPrint: logPrint),
        headers: const {'authorization': 'authorization-value'},
      );

      expect(log, contains('authorization: ██'));
      expect(log, isNot(contains('authorization-value')));
    });

    test('redacts the headers it is given along with the default ones', () async {
      final log = await _linesOf(
        (logPrint) => LoggingInterceptor(
          requestHeader: true,
          redactedHeaders: {...LoggingInterceptor.defaultRedactedHeaders, 'x-session'},
          logPrint: logPrint,
        ),
        headers: const {'X-Session': 'session-value', 'Authorization': 'authorization-value'},
      );

      expect(log, isNot(contains('session-value')));
      expect(log, isNot(contains('authorization-value')));
    });

    test('reports every header as is when no header is to be redacted', () async {
      final log = await _linesOf(
        (logPrint) => LoggingInterceptor(requestHeader: true, redactedHeaders: const {}, logPrint: logPrint),
        headers: const {'Authorization': 'authorization-value'},
      );

      expect(log, contains('authorization-value'));
    });

    test('redacts the query parameters it is given, whatever their case', () async {
      final log = await _linesOf(
        (logPrint) => LoggingInterceptor(requestHeader: true, redactedQueryParameters: {'API_KEY'}, logPrint: logPrint),
        path: '/test?api_key=key-value&page=2',
      );

      expect(log, contains('api_key=██&page=2'));
      expect(log, isNot(contains('key-value')));
    });

    test('redacts a query parameter whose name is encoded in the URL', () async {
      final log = await _linesOf(
        (logPrint) =>
            LoggingInterceptor(requestHeader: true, redactedQueryParameters: {'filter[id]'}, logPrint: logPrint),
        path: '/test?filter%5Bid%5D=filter-value',
      );

      expect(log, contains('filter%5Bid%5D=██'));
      expect(log, isNot(contains('filter-value')));
    });

    test('keeps the order of repeated query parameters it redacts around', () async {
      final log = await _linesOf(
        (logPrint) => LoggingInterceptor(redactedQueryParameters: {'b'}, logPrint: logPrint),
        path: '/test?a=1&b=2&a=3',
      );

      expect(log, contains('/test?a=1&b=██&a=3'));
    });

    test('keeps the encoding of the query parameters it does not redact', () async {
      final log = await _linesOf(
        (logPrint) => LoggingInterceptor(redactedQueryParameters: {'api_key'}, logPrint: logPrint),
        path: '/test?q=a%20b&api_key=key-value',
      );

      expect(log, contains('/test?q=a%20b&api_key=██'));
    });

    test('redacts a response header it is given', () async {
      final log = await _linesOf(
        (logPrint) => LoggingInterceptor(responseHeader: true, redactedHeaders: {'Content-Type'}, logPrint: logPrint),
      );

      expect(log, contains('content-type'));
      expect(log, isNot(contains(Headers.jsonContentType)));
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

    // A line longer than the platform's own limit is cut by it instead, which says nothing about
    // having done so and takes the rest of the record with it: the box drawing, the prefix that
    // marks the line as ours, and any line that followed.
    test('never writes a line past the width it was given', () async {
      final lines = <String>[];
      final dio = _subject(
        body: _bulkyBody(),
        logPrint: (_, line) => lines.add(line.toString()),
      );

      await dio.get<void>('/test');

      // The rules that draw the box are the width plus the corners that close them.
      final content = lines.where((it) => !it.contains('═'));

      expect(content, isNotEmpty);
      expect(content.map((it) => it.length), everyElement(lessThanOrEqualTo(120)));
    });

    test('names how much of a value too long for the line it left out', () async {
      final lines = <String>[];
      final dio = _subject(
        body: _bulkyBody(),
        logPrint: (_, line) => lines.add(line.toString()),
      );

      await dio.get<void>('/test');

      // The value is reported as far as it fits, and the rest is accounted for rather than dropped.
      final threads = lines.singleWhere((it) => it.contains('threads:'));
      expect(threads, startsWith('║'));
      expect(threads, matches(RegExp(r' … \+\d+ chars$')));
    });

    test('keeps the key on a value it wraps over several lines', () async {
      final lines = <String>[];
      final dio = _subject(
        compact: false,
        body: _bulkyBody(),
        logPrint: (_, line) => lines.add(line.toString()),
      );

      await dio.get<void>('/test');

      // Wrapped without it, the value reads as an unlabelled block of text.
      expect(lines.where((it) => it.contains('next:')), hasLength(1));
    });
  });
}
