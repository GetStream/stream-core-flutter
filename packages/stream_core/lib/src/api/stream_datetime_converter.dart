import 'package:json_annotation/json_annotation.dart';

/// A [JsonConverter] for the API's [DateTime] fields.
///
/// Responses carry an RFC3339 string (v1) or epoch nanoseconds (v2), so
/// [fromJson] accepts either; requests are always RFC3339. Precision is
/// microseconds, the finest unit [DateTime] supports.
class StreamDateTimeConverter implements JsonConverter<DateTime, Object> {
  const StreamDateTimeConverter();

  @override
  DateTime fromJson(Object json) {
    if (json is String) {
      return DateTime.parse(json).toUtc();
    }

    if (json is num) {
      // Epoch nanoseconds -> microseconds.
      return DateTime.fromMicrosecondsSinceEpoch(json ~/ 1000, isUtc: true);
    }

    throw FormatException('Unsupported DateTime JSON type: ${json.runtimeType}', json);
  }

  @override
  String toJson(DateTime object) => object.toUtc().toIso8601String();
}
