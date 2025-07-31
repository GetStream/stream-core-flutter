import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

import '../user.dart';
import '../ws/events/sendable_event.dart';

part 'ws_auth_message_request.g.dart';

@JsonSerializable()
class WsAuthMessageRequest implements SendableEvent {
  const WsAuthMessageRequest({
    this.products,
    required this.token,
    this.userDetails,
  });

  final List<String>? products;
  final String token;

  @JsonKey(name: 'user_details')
  final ConnectUserDetailsRequest? userDetails;

  Map<String, dynamic> toJson() => _$WsAuthMessageRequestToJson(this);

  static WsAuthMessageRequest fromJson(Map<String, dynamic> json) =>
      _$WsAuthMessageRequestFromJson(json);

  @override
  Object toSerializedData() => json.encode(toJson());
}
