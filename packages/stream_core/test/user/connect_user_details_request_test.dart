import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

void main() {
  group('ConnectUserDetailsRequest.fromUser', () {
    test('carries the fields the server accepts from a client', () {
      const user = User(
        id: 'user-1',
        name: 'Bob',
        image: 'https://example.com/bob.png',
        custom: {'plan': 'pro'},
      );

      final details = ConnectUserDetailsRequest.fromUser(user);

      expect(details.id, 'user-1');
      expect(details.name, 'Bob');
      expect(details.image, 'https://example.com/bob.png');
      expect(details.custom, {'plan': 'pro'});
    });

    test('leaves out the fields the server decides itself', () {
      const user = User(id: 'user-1', role: 'admin', teams: ['red']);

      final json = ConnectUserDetailsRequest.fromUser(user).toJson();

      // Sending either is pointless: the server ignores both from a client.
      expect(json, isNot(contains('role')));
      expect(json, isNot(contains('teams')));
    });

    test('sends the id alone when details are excluded', () {
      const user = User(
        id: 'user-1',
        name: 'Bob',
        image: 'https://example.com/bob.png',
        custom: {'plan': 'pro'},
      );

      final details = ConnectUserDetailsRequest.fromUser(user, includeDetails: false);

      expect(details.id, 'user-1');
      expect(details.name, isNull);
      expect(details.image, isNull);
      expect(details.custom, isNull);
    });

    test('reports the name the user was created with, not the id fallback', () {
      // `User.name` falls back to the id; the wire form must not, or a user
      // with no name would be given the id as one.
      const user = User(id: 'user-1');

      final details = ConnectUserDetailsRequest.fromUser(user);

      expect(user.name, 'user-1');
      expect(details.name, isNull);
    });
  });
}
