import 'package:json_annotation/json_annotation.dart';

part 'connect_user_details_request.g.dart';

@JsonSerializable()
class ConnectUserDetailsRequest {
  const ConnectUserDetailsRequest({
    required this.id,
    this.image,
    this.invisible,
    this.language,
    this.name,
    this.customData,
  });

  final String id;
  final String? image;
  final bool? invisible;
  final String? language;
  final String? name;
  final Map<String, dynamic>? customData;

  Map<String, dynamic> toJson() => _$ConnectUserDetailsRequestToJson(this);
  static ConnectUserDetailsRequest fromJson(Map<String, dynamic> json) =>
      _$ConnectUserDetailsRequestFromJson(json);
}
