import 'package:json_annotation/json_annotation.dart';

part 'stream_api_error.g.dart';

@JsonSerializable()
class StreamApiError {
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

  /// API error code
  final int code;

  /// Additional error-specific information
  final List<int> details;

  /// Request duration
  final String duration;

  /// Additional error info
  final Map<String, String>? exceptionFields;

  /// Message describing an error
  final String message;

  /// URL with additional information
  final String moreInfo;

  /// Response HTTP status code
  @JsonKey(name: 'StatusCode')
  final int statusCode;

  /// Flag that indicates if the error is unrecoverable, requests that return unrecoverable errors should not be retried, this error only applies to the request that caused it
  final bool? unrecoverable;

  Map<String, dynamic> toJson() => _$StreamApiErrorToJson(this);

  static StreamApiError fromJson(Map<String, dynamic> json) =>
      _$StreamApiErrorFromJson(json);

  @override
  String toString() {
    return 'APIError('
        'code: $code, '
        'details: $details, '
        'duration: $duration, '
        'exceptionFields: $exceptionFields, '
        'message: $message, '
        'moreInfo: $moreInfo, '
        'statusCode: $statusCode, '
        'unrecoverable: $unrecoverable, '
        ')';
  }
}

final _tokenInvalidErrorCodes = _range(40, 42);
final _clientErrorCodes = _range(400, 499);

extension StreamApiErrorExtension on StreamApiError {
  bool get isTokenExpiredError => _tokenInvalidErrorCodes.contains(code);
  bool get isClientError => _clientErrorCodes.contains(code);
  bool get isRateLimitError => statusCode == 429;
}

List<int> _range(int from, int to) =>
    List.generate(to - from + 1, (i) => i + from);
