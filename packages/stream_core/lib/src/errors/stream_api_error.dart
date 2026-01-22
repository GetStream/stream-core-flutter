import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'stream_api_error.g.dart';

/// An API error response from the Stream API.
///
/// Encapsulates all error information returned by the API when a request fails,
/// providing detailed context about what went wrong. This includes error codes,
/// status information, and additional metadata for debugging and error handling.
///
/// Note: While this class can be generated from the OpenAPI specification, it is
/// defined here to allow usage across different Stream products without depending
/// on OpenAPI codegen.
@JsonSerializable()
class StreamApiError extends Equatable {
  /// Creates a new [StreamApiError] instance.
  const StreamApiError({
    required this.code,
    required this.details,
    required this.duration,
    this.exceptionFields,
    required this.message,
    required this.moreInfo,
    required this.statusCode,
    this.unrecoverable,
  });

  /// The specific error code identifying the type of error.
  final int code;

  /// Additional error detail codes providing more context.
  final List<int> details;

  /// The processing duration before the error occurred.
  final String duration;

  /// Additional context about the exception as key-value pairs.
  final Map<String, String>? exceptionFields;

  /// The human-readable error description.
  final String message;

  /// Additional information or documentation URL for this error.
  final String moreInfo;

  /// The HTTP status code associated with this error.
  @JsonKey(name: 'StatusCode')
  final int statusCode;

  /// Whether this error is unrecoverable and should not be retried.
  final bool? unrecoverable;

  Map<String, dynamic> toJson() => _$StreamApiErrorToJson(this);

  /// Creates a [StreamApiError] from a JSON map.
  static StreamApiError fromJson(Map<String, dynamic> json) => _$StreamApiErrorFromJson(json);

  @override
  List<Object?> get props => [
    code,
    details,
    duration,
    exceptionFields,
    message,
    moreInfo,
    statusCode,
    unrecoverable,
  ];
}

final _tokenInvalidErrorCodes = _range(40, 42);
final _clientErrorCodes = _range(400, 499);

/// Extension methods for [StreamApiError] to provide convenient error type checks.
extension StreamApiErrorExtension on StreamApiError {
  /// Whether this error indicates an expired or invalid token.
  bool get isTokenExpiredError => _tokenInvalidErrorCodes.contains(code);

  /// Whether this error is a client-side error (4xx status codes).
  bool get isClientError => _clientErrorCodes.contains(code);

  /// Whether this error indicates rate limiting (429 status code).
  bool get isRateLimitError => statusCode == 429;
}

// Helper function to generate a range of integers from [from] to [to] inclusive.
List<int> _range(int from, int to) {
  return List.generate(to - from + 1, (i) => i + from);
}
