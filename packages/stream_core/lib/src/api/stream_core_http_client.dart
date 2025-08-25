import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

import '../utils.dart';

extension type const StreamCoreHttpClient._(Dio _client) implements Dio {
  factory StreamCoreHttpClient({
    BaseOptions? options,
    Iterable<Interceptor>? interceptors,
    HttpClientAdapter? httpClientAdapter,
  }) {
    final dio = Dio(options);

    // Add interceptors, error handlers, etc.
    interceptors?.let(dio.interceptors.addAll);

    if (httpClientAdapter != null) {
      dio.httpClientAdapter = httpClientAdapter;
    }

    return StreamCoreHttpClient._(dio);
  }

  @visibleForTesting
  const StreamCoreHttpClient.fromDio(Dio client) : this._(client);
}
