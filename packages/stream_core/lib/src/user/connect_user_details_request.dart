import 'package:json_annotation/json_annotation.dart';

import '../utils/standard.dart';
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

  /// Creates the details to send when connecting as [user].
  ///
  /// Pass [includeDetails] as `false` to send the id alone.
  ///
  /// The name comes from [User.originalName] rather than [User.name], so a user who was never given
  /// one does not have their id sent as their name. [User.role] and [User.teams] are left out
  /// deliberately: the server assigns both and ignores whatever a client claims for them.
  factory ConnectUserDetailsRequest.fromUser(
    User user, {
    bool includeDetails = true,
  }) {
    final details = user.takeIf((_) => includeDetails);

    return ConnectUserDetailsRequest(
      id: user.id,
      name: details?.originalName,
      image: details?.image,
      custom: details?.custom,
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
