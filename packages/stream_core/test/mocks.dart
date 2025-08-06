import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stream_core/src/logger.dart';
import 'package:stream_core/stream_core.dart';

class MockLogger extends Mock implements StreamLogger {}

class MockDio extends Mock implements Dio {
  BaseOptions? _options;

  @override
  BaseOptions get options => _options ??= BaseOptions();

  Interceptors? _interceptors;

  @override
  Interceptors get interceptors => _interceptors ??= Interceptors();
}

class MockHttpClient extends Mock implements CoreHttpClient {}

class MockTokenManager extends Mock implements TokenManager {}

class MockWebSocketClient extends Mock implements WebSocketClient {}

final systemEnvironmentManager = SystemEnvironmentManager(
  environment: const SystemEnvironment(
    sdkName: 'core',
    sdkIdentifier: 'dart',
    sdkVersion: '0.1',
  ),
);

StreamApiError createStreamApiError({
  int code = 0,
  List<int> details = const [],
  String message = '',
  String duration = '',
  String moreInfo = '',
  int statusCode = 0,
}) {
  return StreamApiError(
    code: code,
    details: details,
    duration: duration,
    message: message,
    moreInfo: moreInfo,
    statusCode: statusCode,
  );
}
