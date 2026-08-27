// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stream_api_error.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StreamApiError _$StreamApiErrorFromJson(Map<String, dynamic> json) => StreamApiError(
  code: StreamErrorCode.fromJson(json['code'] as num),
  details: _detailsFromJson(json['details']),
  duration: json['duration'] as String,
  exceptionFields: (json['exception_fields'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  message: json['message'] as String,
  moreInfo: json['more_info'] as String,
  statusCode: (json['StatusCode'] as num).toInt(),
  unrecoverable: json['unrecoverable'] as bool?,
);

Map<String, dynamic> _$StreamApiErrorToJson(StreamApiError instance) => <String, dynamic>{
  'code': instance.code.toJson(),
  'details': instance.details,
  'duration': instance.duration,
  'exception_fields': instance.exceptionFields,
  'message': instance.message,
  'more_info': instance.moreInfo,
  'StatusCode': instance.statusCode,
  'unrecoverable': instance.unrecoverable,
};
