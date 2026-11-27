import '../utils/object.dart';
import '../ws.dart';
import 'connect_user_details_request.dart';

class WsAuthMessageRequest extends WsRequest {
  const WsAuthMessageRequest({
    this.products,
    required this.token,
    this.userDetails,
    this.memberCustomInclude,
    this.eventProtocol,
  });

  final List<String>? products;
  final String token;
  final ConnectUserDetailsRequest? userDetails;

  /// The channel member custom data keys to include with each chat message this connection receives, at most 8.
  final List<String>? memberCustomInclude;

  /// The realtime event protocol this connection asks for, or `null` for the server's default.
  final EventProtocol? eventProtocol;

  @override
  List<Object?> get props => [products, token, userDetails, memberCustomInclude, eventProtocol];

  @override
  Map<String, dynamic> toJson() {
    return {
      'products': ?products,
      'token': token,
      'user_details': ?userDetails?.toJson(),
      'member_custom_include': ?memberCustomInclude,
      'event_protocol': ?eventProtocol,
    };
  }

  @override
  String toString() {
    return '${objectRuntimeType(this, 'WsAuthMessageRequest')}(products: $products, userId: ${userDetails?.id}, '
        'memberCustomInclude: $memberCustomInclude, eventProtocol: $eventProtocol)';
  }
}

/// The realtime event protocol version a connection asks for.
///
/// A version the server does not support yet falls back to the newest one it does.
extension type const EventProtocol(int _) implements int {
  /// The legacy event format.
  static const legacy = EventProtocol(0);

  /// The V3 event format, which leaves the members out of some chat events in large channels.
  static const v3 = EventProtocol(3);
}
