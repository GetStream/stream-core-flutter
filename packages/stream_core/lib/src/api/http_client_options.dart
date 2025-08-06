part of 'http_client.dart';

const _defaultBaseURL = 'https://chat.stream-io-api.com';

/// Client options to modify [CoreHttpClient]
class HttpClientOptions {
  /// Instantiates a new [HttpClientOptions]
  const HttpClientOptions({
    String? baseUrl,
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.queryParameters = const {},
    this.headers = const {},
  }) : baseUrl = baseUrl ?? _defaultBaseURL;

  /// base url to use with client.
  final String baseUrl;

  /// connect timeout, default to 30s
  final Duration connectTimeout;

  /// received timeout, default to 30s
  final Duration receiveTimeout;

  /// Common query parameters.
  ///
  /// List values use the default [ListFormat.multiCompatible].
  final Map<String, Object?> queryParameters;

  /// Http request headers.
  /// The keys of initial headers will be converted to lowercase,
  /// for example 'Content-Type' will be converted to 'content-type'.
  ///
  /// The key of Header Map is case-insensitive
  /// eg: content-type and Content-Type are
  /// regard as the same key.
  final Map<String, Object?> headers;
}
