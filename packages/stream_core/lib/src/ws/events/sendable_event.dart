import 'dart:convert';

abstract interface class SendableEvent {
  /// Serialize the object to `String` or `Uint8List`.
  Object toSerializedData();
}

final class HealthCheckPingEvent implements SendableEvent {
  const HealthCheckPingEvent({
    required this.connectionId,
  });

  final String? connectionId;

  @override
  Object toSerializedData() => json.encode(
        [
          {
            'type': 'health.check',
            'client_id': connectionId,
          }
        ],
      );
}
