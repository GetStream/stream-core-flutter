import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stream_core/src/logger.dart';

class MockLogger extends Mock implements StreamLogger {}

class MockDio extends Mock implements Dio {
  BaseOptions? _options;

  @override
  BaseOptions get options => _options ??= BaseOptions();

  Interceptors? _interceptors;

  @override
  Interceptors get interceptors => _interceptors ??= Interceptors();
}
