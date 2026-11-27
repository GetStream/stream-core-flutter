import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

void main() {
  test('sends only the fields that were set', () {
    const request = WsAuthMessageRequest(
      products: ['feeds'],
      token: 'secret-token',
      userDetails: ConnectUserDetailsRequest(id: 'user-1'),
    );

    final json = request.toJson();

    expect(json, {
      'products': ['feeds'],
      'token': 'secret-token',
      'user_details': {'id': 'user-1'},
    });
  });

  test('keeps the token out of its string form', () {
    const request = WsAuthMessageRequest(
      products: ['feeds'],
      token: 'secret-token',
      userDetails: ConnectUserDetailsRequest(id: 'user-1'),
    );

    expect(request.toString(), isNot(contains('secret-token')));
  });
}
