import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

void main() {
  group('HealthCheckInfo', () {
    test('compares by what it carries', () {
      expect(
        const HealthCheckInfo(connectionId: 'a', participantCount: 2),
        const HealthCheckInfo(connectionId: 'a', participantCount: 2),
      );
      expect(
        const HealthCheckInfo(connectionId: 'a'),
        isNot(const HealthCheckInfo(connectionId: 'b')),
      );
    });
  });

  group('HealthCheckPingEvent', () {
    test('is sent as a health check naming the connection it is for', () {
      // The server matches a ping to a connection by this id, so the wire shape is the contract.
      expect(
        const HealthCheckPingEvent(connectionId: 'connection-id').toJson(),
        {'type': 'health.check', 'client_id': 'connection-id'},
      );
    });

    test('leaves the connection out when there is not one yet', () {
      // A null id is omitted rather than sent as null, which the server would read as a client
      // claiming no connection.
      expect(const HealthCheckPingEvent(connectionId: null).toJson(), {'type': 'health.check'});
    });
  });
}
