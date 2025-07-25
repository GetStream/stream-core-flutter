import 'package:equatable/equatable.dart';

abstract class WsEvent extends Equatable {
  const WsEvent();

  Object? get error => null;
  HealthCheckInfo? get healthCheckInfo => null;

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [];
}

class HealthCheckPongEvent extends WsEvent {
  const HealthCheckPongEvent({
    required this.healthCheckInfo,
  });

  @override
  final HealthCheckInfo healthCheckInfo;

  @override
  List<Object?> get props => [healthCheckInfo];
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
