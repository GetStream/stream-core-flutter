import 'package:json_annotation/json_annotation.dart';

import 'user.dart';

part 'connect_user_details_request.g.dart';

@JsonSerializable(createFactory: false)
class ConnectUserDetailsRequest {
  const ConnectUserDetailsRequest({
    required this.id,
    this.image,
    this.invisible,
    this.language,
    this.name,
    this.custom,
  });

  /// Creates the details a client may send when connecting as [user].
  ///
  /// A user's role and teams are left out: the server assigns both and does not
  /// accept them from a client.
  ///
  /// Pass [includeDetails] as `false` to send the id alone.
  factory ConnectUserDetailsRequest.fromUser(
    User user, {
    bool includeDetails = true,
  }) {
    return ConnectUserDetailsRequest(
      id: user.id,
      name: includeDetails ? user.originalName : null,
      image: includeDetails ? user.image : null,
      custom: includeDetails ? user.custom : null,
    );
  }

  final String id;
  final String? image;
  final bool? invisible;
  final String? language;
  final String? name;
  final Map<String, Object?>? custom;

  Map<String, dynamic> toJson() => _$ConnectUserDetailsRequestToJson(this);
}
