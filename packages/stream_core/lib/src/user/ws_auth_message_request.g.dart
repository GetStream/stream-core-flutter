// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ws_auth_message_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WsAuthMessageRequest _$WsAuthMessageRequestFromJson(
        Map<String, dynamic> json) =>
    WsAuthMessageRequest(
      products: (json['products'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      token: json['token'] as String,
      userDetails: json['user_details'] == null
          ? null
          : ConnectUserDetailsRequest.fromJson(
              json['user_details'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WsAuthMessageRequestToJson(
        WsAuthMessageRequest instance) =>
    <String, dynamic>{
      'products': instance.products,
      'token': instance.token,
      'user_details': instance.userDetails,
    };
