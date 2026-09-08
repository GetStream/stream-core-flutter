import 'package:dio/dio.dart';

import '../stream_core_dio_exception.dart';

/// Interceptor that maps every failed request onto a [StreamDioException]
/// carrying the `StreamException` it represents.
///
/// Installed last, so every rejection leaving the HTTP client — whatever
/// interceptor or transport produced it — delivers a Stream exception.
class ApiErrorInterceptor extends Interceptor {
  /// Creates a new [ApiErrorInterceptor].
  const ApiErrorInterceptor();

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    if (err is StreamDioException) {
      // Already carries a StreamException; pass it along unchanged.
      return super.onError(err, handler);
    }

    final streamDioException = StreamDioException(
      exception: err.toStreamException(),
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      stackTrace: err.stackTrace,
      message: err.message,
    );

    return super.onError(streamDioException, handler);
  }
}
