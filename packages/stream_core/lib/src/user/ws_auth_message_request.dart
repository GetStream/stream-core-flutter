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

  /// The channel member custom data keys to add to the member of each message this connection receives.
  final List<String>? memberCustomInclude;

  /// The realtime event protocol version this connection asks for.
  final int? eventProtocol;

  @override
  List<Object?> get props => [products, token, userDetails, memberCustomInclude, eventProtocol];

  // Hand-written: a generated toJson would also send the getters Equatable adds (`props`, `hashCode`,
  // `stringify`), and `props` repeats the token.
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
