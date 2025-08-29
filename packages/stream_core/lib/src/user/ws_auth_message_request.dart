import 'package:json_annotation/json_annotation.dart';

import '../ws.dart';
import 'connect_user_details_request.dart';

part 'ws_auth_message_request.g.dart';

@JsonSerializable(createFactory: false)
class WsAuthMessageRequest extends WsRequest {
  const WsAuthMessageRequest({
    this.products,
    required this.token,
    this.userDetails,
  });

  final List<String>? products;
  final String token;
  final ConnectUserDetailsRequest? userDetails;

  @override
  List<Object?> get props => [products, token, userDetails];

  @override
  Map<String, dynamic> toJson() => _$WsAuthMessageRequestToJson(this);
}
