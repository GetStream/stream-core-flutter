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
  factory ConnectUserDetailsRequest.fromUser(
    User user, {
    bool includeDetails = true,
  }) {
    // Only the id is sent when the details are not wanted.
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
