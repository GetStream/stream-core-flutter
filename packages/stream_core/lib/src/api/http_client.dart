import 'dart:async';

import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

import '../../stream_core.dart';
import '../logger/stream_logger.dart';
import 'interceptors/additional_headers_interceptor.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/connection_id_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

part 'http_client_options.dart';

const _tag = 'SC:CoreHttpClient';

/// This is where we configure the base url, headers,
///  query parameters and convenient methods for http verbs with error parsing.
class CoreHttpClient {
  /// [CoreHttpClient] constructor
  CoreHttpClient(
    this.apiKey, {
    Dio? dio,
    HttpClientOptions? options,
    TokenManager? tokenManager,
    ConnectionIdProvider? connectionIdProvider,
    required SystemEnvironmentManager systemEnvironmentManager,
    StreamLogger? logger,
    Iterable<Interceptor>? interceptors,
    HttpClientAdapter? httpClientAdapter,
  })  : _options = options ?? const HttpClientOptions(),
        httpClient = dio ?? Dio() {
    httpClient
      ..options.baseUrl = _options.baseUrl
      ..options.receiveTimeout = _options.receiveTimeout
      ..options.connectTimeout = _options.connectTimeout
      ..options.queryParameters = {
        'api_key': apiKey,
        ..._options.queryParameters,
      }
      ..options.headers = {
        'Content-Type': 'application/json',
        'Content-Encoding': 'application/gzip',
        ..._options.headers,
      }
      ..interceptors.addAll([
        AdditionalHeadersInterceptor(systemEnvironmentManager),
        if (tokenManager != null) AuthInterceptor(this, tokenManager),
        if (connectionIdProvider != null)
          ConnectionIdInterceptor(connectionIdProvider),
        ...interceptors ??
            [
              // Add a default logging interceptor if no interceptors are
              // provided.
              if (logger != null)
                LoggingInterceptor(
                  requestHeader: true,
                  logPrint: (step, message) {
                    switch (step) {
                      case InterceptStep.request:
                        return logger.log(
                          Priority.info,
                          _tag,
                          message.toString,
                        );
                      case InterceptStep.response:
                        return logger.log(
                          Priority.info,
                          _tag,
                          message.toString,
                        );
                      case InterceptStep.error:
                        return logger.log(
                          Priority.error,
                          _tag,
                          message.toString,
                        );
                    }
                  },
                ),
            ],
      ]);
    if (httpClientAdapter != null) {
      httpClient.httpClientAdapter = httpClientAdapter;
    }
  }

  /// Your project Stream Chat api key.
  /// Find your API keys here https://getstream.io/dashboard/
  final String apiKey;

  /// Your project Stream Chat ClientOptions
  final HttpClientOptions _options;

  /// [Dio] httpClient
  /// It's been chosen because it's easy to use
  /// and supports interesting features out of the box
  /// (Interceptors, Global configuration, FormData, File downloading etc.)
  @visibleForTesting
  final Dio httpClient;

  /// Shuts down the [CoreHttpClient].
  ///
  /// If [force] is `false` the [CoreHttpClient] will be kept alive
  /// until all active connections are done. If [force] is `true` any active
  /// connections will be closed to immediately release all resources. These
  /// closed connections will receive an error event to indicate that the client
  /// was shut down. In both cases trying to establish a new connection after
  /// calling [close] will throw an exception.
  void close({bool force = false}) => httpClient.close(force: force);

  ClientException _parseError(DioException exception) {
    // locally thrown dio error
    if (exception is StreamDioException) return exception.exception;
    // real network request dio error
    return exception.toClientException();
  }

  /// Handy method to make http GET request with error parsing.
  Future<Response<dynamic>> get(
    String path, {
    Map<String, Object?>? queryParameters,
    Map<String, Object?>? headers,
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await httpClient.get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (error) {
      throw _parseError(error);
    }
  }

  /// Handy method to make http POST request with error parsing.
  Future<Response<dynamic>> post(
    String path, {
    Object? data,
    Map<String, Object?>? queryParameters,
    Map<String, Object?>? headers,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await httpClient.post<dynamic>(
        path,
        queryParameters: queryParameters,
        data: data,
        options: Options(headers: headers),
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (error) {
      throw _parseError(error);
    }
  }

  /// Handy method to make http DELETE request with error parsing.
  Future<Response<dynamic>> delete(
    String path, {
    Map<String, Object?>? queryParameters,
    Map<String, Object?>? headers,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await httpClient.delete<dynamic>(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (error) {
      throw _parseError(error);
    }
  }

  /// Handy method to make http PATCH request with error parsing.
  Future<Response<dynamic>> patch(
    String path, {
    Object? data,
    Map<String, Object?>? queryParameters,
    Map<String, Object?>? headers,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await httpClient.patch<dynamic>(
        path,
        queryParameters: queryParameters,
        data: data,
        options: Options(headers: headers),
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (error) {
      throw _parseError(error);
    }
  }

  /// Handy method to make http PUT request with error parsing.
  Future<Response<dynamic>> put(
    String path, {
    Object? data,
    Map<String, Object?>? queryParameters,
    Map<String, Object?>? headers,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await httpClient.put<dynamic>(
        path,
        queryParameters: queryParameters,
        data: data,
        options: Options(headers: headers),
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (error) {
      throw _parseError(error);
    }
  }

  /// Handy method to post files with error parsing.
  Future<Response<dynamic>> postFile(
    String path,
    MultipartFile file, {
    Map<String, Object?>? queryParameters,
    Map<String, Object?>? headers,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    final formData = FormData.fromMap({'file': file});
    final response = await post(
      path,
      data: formData,
      queryParameters: queryParameters,
      headers: headers,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
      cancelToken: cancelToken,
    );
    return response;
  }

  /// Handy method to make generic http request with error parsing.
  Future<Response<dynamic>> request(
    String path, {
    Object? data,
    Map<String, Object?>? queryParameters,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await httpClient.request<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (error) {
      throw _parseError(error);
    }
  }

  /// Handy method to make http requests from [RequestOptions]
  /// with error parsing.
  Future<Response<dynamic>> fetch(
    RequestOptions requestOptions,
  ) async {
    try {
      final response = await httpClient.fetch<dynamic>(requestOptions);
      return response;
    } on DioException catch (error) {
      throw _parseError(error);
    }
  }
}
