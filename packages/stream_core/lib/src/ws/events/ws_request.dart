import 'package:equatable/equatable.dart';

abstract class WsRequest extends Equatable {
  const WsRequest();

  Map<String, Object?> toJson();
}

final class HealthCheckPingEvent extends WsRequest {
  const HealthCheckPingEvent({required this.connectionId});

  final String? connectionId;

  @override
  List<Object?> get props => [connectionId];

  @override
  Map<String, Object?> toJson() {
    return {
      'type': 'health.check',
      'client_id': ?connectionId,
    };
  }
}
