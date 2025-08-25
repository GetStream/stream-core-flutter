import 'package:equatable/equatable.dart';

abstract class WsEvent extends Equatable {
  const WsEvent();

  Object? get error => null;
  HealthCheckInfo? get healthCheckInfo => null;

  @override
  List<Object?> get props => [];
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
