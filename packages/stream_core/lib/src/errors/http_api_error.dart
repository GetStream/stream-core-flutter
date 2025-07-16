abstract interface class HttpApiError {
  /// Response HTTP status code
  int get statusCode;

  /// API error code
  int get code;

  /// Additional error-specific information
  List<int> get details;

  /// Request duration
  String get duration;

  /// Additional error info
  Map<String, String> get exceptionFields;

  /// Message describing an error
  String get message;

  /// URL with additional information
  String get moreInfo;

  /// Flag that indicates if the error is unrecoverable, requests that return unrecoverable errors should not be retried, this error only applies to the request that caused it
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? get unrecoverable;
}
