// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connect_user_details_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConnectUserDetailsRequest _$ConnectUserDetailsRequestFromJson(
        Map<String, dynamic> json) =>
    ConnectUserDetailsRequest(
      id: json['id'] as String,
      image: json['image'] as String?,
      invisible: json['invisible'] as bool?,
      language: json['language'] as String?,
      name: json['name'] as String?,
    );

Map<String, dynamic> _$ConnectUserDetailsRequestToJson(
        ConnectUserDetailsRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'image': instance.image,
      'invisible': instance.invisible,
      'language': instance.language,
      'name': instance.name,
    };
