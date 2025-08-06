// ignore_for_file: avoid_redundant_argument_values

import 'dart:async';

import 'package:mocktail/mocktail.dart';
import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

import '../mocks.dart';

void main() {
  late MockWebSocketClient client;
  late ConnectionRecoveryHandler connectionRecoveryHandler;

  late FakeNetworkMonitor networkMonitor;

  setUpAll(() {
    registerFallbackValue(CloseCode.normalClosure);
    registerFallbackValue(DisconnectionSource.systemInitiated());
  });

  setUp(() {
    client = MockWebSocketClient();
    networkMonitor = FakeNetworkMonitor();
  });

  tearDown(() {
    connectionRecoveryHandler.dispose();
  });

  test('Should disconnect on losing internet', () async {
    when(() => client.connectionState)
        .thenReturn(WebSocketConnectionState.connected());
    when(() => client.connectionStateStream)
        .thenReturn(MutableSharedEmitterImpl<WebSocketConnectionState>());
    when(() => client.disconnect()).thenReturn(null);

    connectionRecoveryHandler = DefaultConnectionRecoveryHandler(
      client: client,
      networkMonitor: networkMonitor,
    );

    networkMonitor.updateStatus(NetworkStatus.disconnected);
    await Future<void>.delayed(Duration.zero);

    verify(
      () => client.disconnect(
        code: CloseCode.normalClosure,
        source: DisconnectionSource.systemInitiated(),
      ),
    ).called(1);
  });

  test('Should not disconnect on losing internet when already disconnected',
      () async {
    when(() => client.connectionState).thenReturn(
      WebSocketConnectionState.disconnected(
        source: DisconnectionSource.noPongReceived(),
      ),
    );
    when(() => client.connectionStateStream)
        .thenReturn(MutableSharedEmitterImpl<WebSocketConnectionState>());
    when(() => client.disconnect()).thenReturn(null);

    connectionRecoveryHandler = DefaultConnectionRecoveryHandler(
      client: client,
      networkMonitor: networkMonitor,
    );

    networkMonitor.updateStatus(NetworkStatus.disconnected);
    await Future<void>.delayed(Duration.zero);

    verifyNever(
      () => client.disconnect(
        code: any(named: 'code'),
        source: any(named: 'source'),
      ),
    );
  });

  test('Should reconnect on gaining internet', () async {
    when(() => client.connectionState).thenReturn(
      WebSocketConnectionState.disconnected(
        source: DisconnectionSource.systemInitiated(),
      ),
    );
    when(() => client.connectionStateStream)
        .thenReturn(MutableSharedEmitterImpl<WebSocketConnectionState>());

    connectionRecoveryHandler = DefaultConnectionRecoveryHandler(
      client: client,
      networkMonitor: networkMonitor,
    );

    networkMonitor.updateStatus(NetworkStatus.connected);
    await Future<void>.delayed(Duration.zero);

    verify(() => client.connect()).called(1);
  });
}

class FakeNetworkMonitor implements NetworkMonitor {
  FakeNetworkMonitor({NetworkStatus initialStatus = NetworkStatus.connected})
      : currentStatus = initialStatus;

  void updateStatus(NetworkStatus status) {
    currentStatus = status;
    _statusController.add(status);
  }

  @override
  NetworkStatus currentStatus;

  final StreamController<NetworkStatus> _statusController = StreamController();
  @override
  // TODO: implement onStatusChange
  Stream<NetworkStatus> get onStatusChange => _statusController.stream;
}
