import 'package:equatable/equatable.dart';

import '../../utils.dart' show StreamEvent;

abstract class WsEvent implements StreamEvent {
  const WsEvent();

  Object? get error => null;
  HealthCheckInfo? get healthCheckInfo => null;
}

final class HealthCheckInfo extends Equatable {
  const HealthCheckInfo({
    this.connectionId,
    this.participantCount,
  });

  final String? connectionId;
  final int? participantCount;

  @override
  List<Object?> get props => [connectionId, participantCount];
}
