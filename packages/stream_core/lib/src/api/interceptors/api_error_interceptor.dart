import 'package:dio/dio.dart';

import '../stream_core_dio_error.dart';

class ApiErrorInterceptor extends Interceptor {
  /// Initializes a new instance of [ApiErrorInterceptor].
  const ApiErrorInterceptor();

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    if (err is StreamDioException) {
      // If the error is already a StreamDioException,
      // we can directly pass it to the handler.
      return super.onError(err, handler);
    }

    // Otherwise, we convert the DioException to a StreamDioException
    final streamDioException = StreamDioException(
      exception: err.toClientException(),
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      stackTrace: err.stackTrace,
      message: err.message,
    );

    return super.onError(streamDioException, handler);
  }
}
