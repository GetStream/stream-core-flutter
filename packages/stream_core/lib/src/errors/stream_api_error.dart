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
  ///
  /// The wire field is not always a list of codes: a moderation rejection
  /// (code 73) carries a list of objects here, and the backend can serialize
  /// the field as an object outright. Decoding tolerates every shape — what
  /// is not a number reads as absent rather than failing the whole error.
  @JsonKey(fromJson: _detailsFromJson)
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

List<int> _detailsFromJson(Object? json) {
  if (json is! List) return const [];
  return [for (final entry in json.whereType<num>()) entry.toInt()];
}

/// The token this payload carries has expired (code 40).
///
/// Same semantics as `StreamApiException.isTokenExpired`, for code that holds
/// the raw payload — an interceptor reading a response body, or a WebSocket
/// error event.
extension StreamApiErrorPredicates on StreamApiError {
  /// Whether the token has expired (code 40). A fresh token fixes it.
  bool get isTokenExpired => code == 40;

  /// Whether the token is not valid yet (codes 41 and 42) — clock skew that
  /// waiting fixes and a fresh token does not.
  bool get isTokenNotYetValid => code == 41 || code == 42;

  /// Whether the token's signature cannot be accepted (code 43) — a
  /// configuration problem no token or wait fixes.
  bool get isTokenSignatureInvalid => code == 43;

  /// Whether the API key cannot be accepted (code 2).
  bool get isApiKeyInvalid => code == 2;

  /// Whether the request was rate limited (HTTP 429).
  bool get isRateLimited => statusCode == 429;
}
