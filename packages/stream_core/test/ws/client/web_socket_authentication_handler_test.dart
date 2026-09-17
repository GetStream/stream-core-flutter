import 'dart:async';

import 'package:stream_core/src/ws/client/web_socket_authentication_handler.dart';
import 'package:stream_core/src/ws/client/web_socket_connection_attempt.dart';
import 'package:stream_core/stream_core.dart';
import 'package:test/test.dart';

final class _PingRequest extends WsRequest {
  const _PingRequest();

  @override
  Map<String, Object?> toJson() => const {};

  @override
  List<Object?> get props => const [];
}

StreamApiError _apiError({
  required int code,
  int statusCode = 401,
}) => StreamApiError(
  code: StreamErrorCode(code),
  details: const [],
  duration: '0ms',
  message: 'error $code',
  moreInfo: '',
  statusCode: statusCode,
);

final _expiredToken = StreamApiException.fromApiError(_apiError(code: 40));

Disconnected _serverClosure(StreamApiException? error) => Disconnected(
  source: ServerInitiated(error: error),
);

/// An attempt for a test that only needs one to exist.
WebSocketConnectionAttempt _anAttempt() => WebSocketConnectionAttempt(onTimeout: () {});

/// Builds a handler, along with the errors it handed the authenticator and the failures it reported.
({
  WebSocketAuthenticationHandler authentication,
  List<StreamApiException?> asked,
  List<Object> failures,
})
_subject({WebSocketAuthenticator? authenticator}) {
  final asked = <StreamApiException?>[];
  final failures = <Object>[];

  final authentication = WebSocketAuthenticationHandler(
    authenticator:
        authenticator ??
        (send, previousError) async {
          asked.add(previousError);
          send(const _PingRequest()).getOrThrow();
        },
    send: (_) => const Result.success(null),
    onFailure: (error, _) => failures.add(error),
  );

  return (authentication: authentication, asked: asked, failures: failures);
}

void main() {
  test('previousError holds what the server closed the connection with', () {
    final (:authentication, asked: _, failures: _) = _subject();

    authentication.onConnectionStateChanged(_serverClosure(_expiredToken));

    expect(authentication.previousError, _expiredToken);
  });

  test('previousError survives a closure the server did not explain', () {
    final (:authentication, asked: _, failures: _) = _subject();
    authentication.onConnectionStateChanged(_serverClosure(_expiredToken));

    // A socket that fails to open closes without an error. The earlier refusal still applies,
    // because no new credentials were sent.
    authentication.onConnectionStateChanged(_serverClosure(null));

    expect(authentication.previousError, _expiredToken);
  });

  test('previousError is cleared once a connection has been established', () {
    final (:authentication, asked: _, failures: _) = _subject();
    authentication.onConnectionStateChanged(_serverClosure(_expiredToken));

    authentication.onConnectionStateChanged(
      const Connected(healthCheck: HealthCheckInfo(connectionId: 'connection-id')),
    );

    // The connection succeeded, so there is no refusal to report.
    expect(authentication.previousError, isNull);
  });

  test('previousError survives a newer refusal equal to the one being answered', () async {
    // `StreamApiError` compares by value, so a second refusal of the same kind cannot be told from
    // the first by comparing them. Spent on the strength of that, it would leave the attempt after
    // this one with nothing to answer, and it would present the same refused credentials again.
    final held = Completer<void>();
    final (:authentication, asked: _, failures: _) = _subject(
      authenticator: (send, previousError) => held.future,
    );

    authentication.onConnectionStateChanged(_serverClosure(_expiredToken));
    final running = authentication.authenticate(_anAttempt());

    // The server refuses again while this attempt is still awaiting its credentials.
    authentication.onConnectionStateChanged(_serverClosure(StreamApiException.fromApiError(_apiError(code: 40))));
    held.complete();
    await running;

    expect(authentication.previousError, _expiredToken);
  });

  test('previousError is forgotten once the caller has disconnected', () {
    final (:authentication, asked: _, failures: _) = _subject();
    authentication.onConnectionStateChanged(_serverClosure(_expiredToken));

    // A caller that disconnects takes connecting back, and what they connect with next is theirs to
    // decide: another user, for one, whose credentials this refusal says nothing about.
    //
    // The cost is a connect made straight afterwards with credentials that are still spent: it is
    // refused, and since a caller's disconnect hands connecting back to them, nothing retries it
    // either. That attempt records the refusal afresh, so the connect after it is told and succeeds.
    authentication.onConnectionStateChanged(
      const Disconnected(source: DisconnectionSource.userInitiated()),
    );

    expect(authentication.previousError, isNull);
  });

  test('previousError is taken by the attempt that reads it, not left for the next', () async {
    final (:authentication, :asked, failures: _) = _subject();
    authentication.onConnectionStateChanged(_serverClosure(_expiredToken));

    await authentication.authenticate(_anAttempt());
    await authentication.authenticate(_anAttempt());

    // Left behind, the refusal would reach a later attempt that it says nothing about.
    expect(asked, [_expiredToken, null]);
    expect(authentication.previousError, isNull);
  });

  test('previousError survives the states an attempt passes through', () {
    final (:authentication, asked: _, failures: _) = _subject();
    authentication.onConnectionStateChanged(_serverClosure(_expiredToken));

    // The error must survive until the retry actually authenticates.
    authentication.onConnectionStateChanged(const Connecting());
    authentication.onConnectionStateChanged(const Authenticating());

    expect(authentication.previousError, _expiredToken);
  });

  test('authenticate hands the previous error to the authenticator', () async {
    final (:authentication, :asked, failures: _) = _subject();

    await authentication.authenticate(_anAttempt());
    authentication.onConnectionStateChanged(_serverClosure(_expiredToken));
    await authentication.authenticate(_anAttempt());

    expect(asked, [null, _expiredToken]);
  });

  test('authenticate does nothing without an authenticator', () async {
    final authentication = WebSocketAuthenticationHandler(
      authenticator: null,
      send: (_) => const Result.success(null),
      onFailure: (_, _) => fail('nothing to authenticate, so nothing can fail'),
    );

    await expectLater(authentication.authenticate(_anAttempt()), completes);
  });

  test('authenticate reports an error the authenticator threw, rather than letting it escape', () async {
    final (:authentication, asked: _, :failures) = _subject(
      // Loading a token throws, and nothing awaits `authenticate`, so the error would otherwise
      // escape unhandled.
      authenticator: (_, _) async => throw StateError('token load failed'),
    );

    await authentication.authenticate(_anAttempt());

    expect(failures, [isStateError]);
  });

  test('previousError keeps a refusal the server sent while an attempt was authenticating', () async {
    final loaded = Completer<void>();
    final authentication = WebSocketAuthenticationHandler(
      authenticator: (_, _) => loaded.future,
      send: (_) => const Result.success(null),
      onFailure: (_, _) => fail('the credentials went out'),
    );

    final authenticating = authentication.authenticate(_anAttempt());

    // Refused while this attempt was still running, so it is not the refusal this attempt read and
    // it has yet to be answered.
    authentication.onConnectionStateChanged(_serverClosure(_expiredToken));

    loaded.complete();
    await authenticating;

    expect(authentication.previousError, _expiredToken);
  });

  group('when the attempt it belongs to has ended', () {
    test('sends nothing once the connection it belongs to has closed', () async {
      final loaded = Completer<void>();
      final sent = <WsRequest>[];
      Result<void>? outcome;

      final authentication = WebSocketAuthenticationHandler(
        authenticator: (send, _) async {
          await loaded.future;
          outcome = send(const _PingRequest());
        },
        send: (request) {
          sent.add(request);
          return const Result.success(null);
        },
        onFailure: (_, _) => fail('the credentials were never offered, so nothing failed to go out'),
      );

      final attempt = _anAttempt();
      final authenticating = authentication.authenticate(attempt);

      // Closed, and nothing has begun in its place. The credentials still belong to the attempt
      // that closure ended, so the socket they would reach is not the one that asked for them.
      attempt.end();

      loaded.complete();
      await authenticating;

      expect(sent, isEmpty);
      expect(outcome, isA<Failure>());
    });

    test('reports no failure once the connection it belongs to has closed', () async {
      final loaded = Completer<void>();

      final authentication = WebSocketAuthenticationHandler(
        authenticator: (_, _) async {
          await loaded.future;
          throw StateError('token load failed');
        },
        send: (_) => const Result.success(null),
        onFailure: (_, _) => fail('the attempt this failure belongs to had already been closed'),
      );

      final attempt = _anAttempt();
      final authenticating = authentication.authenticate(attempt);

      // Reported, this would replace the reason the connection closed with one that is never
      // reconnected, on an attempt nothing has taken over from.
      attempt.end();

      loaded.complete();
      await authenticating;
    });

    test('sends nothing over the connection that replaced the one it belongs to', () async {
      final loaded = Completer<void>();
      final sent = <WsRequest>[];
      Result<void>? outcome;

      final authentication = WebSocketAuthenticationHandler(
        authenticator: (send, _) async {
          await loaded.future;
          outcome = send(const _PingRequest());
        },
        send: (request) {
          sent.add(request);
          return const Result.success(null);
        },
        onFailure: (_, _) => fail('the credentials were never offered, so nothing failed to go out'),
      );

      final attempt = _anAttempt();
      final authenticating = authentication.authenticate(attempt);

      // Abandoned while its credentials were still loading, and replaced.
      attempt.end();
      unawaited(authentication.authenticate(_anAttempt()));

      loaded.complete();
      await authenticating;

      expect(sent, isEmpty);
      expect(outcome, isA<Failure>());
    });

    test('reports no failure against the connection that replaced the one it belongs to', () async {
      final loaded = Completer<void>();
      final failures = <Object>[];

      final authentication = WebSocketAuthenticationHandler(
        authenticator: (_, _) async {
          await loaded.future;
          throw StateError('token load failed');
        },
        send: (_) => const Result.success(null),
        onFailure: (error, _) => failures.add(error),
      );

      final attempt = _anAttempt();
      final authenticating = authentication.authenticate(attempt);

      attempt.end();
      unawaited(authentication.authenticate(_anAttempt()));

      loaded.complete();
      await authenticating;

      // Reported against the attempt that replaced it, this would close a connection that
      // authenticated fine as `AuthenticationFailed`, which is never reconnected.
      expect(failures, isEmpty);
    });

    test('leaves the refusal for the attempt that replaces it', () async {
      final loaded = Completer<void>();
      final asked = <StreamApiException?>[];
      var calls = 0;

      final authentication = WebSocketAuthenticationHandler(
        authenticator: (send, previousError) async {
          asked.add(previousError);
          if (++calls > 1) return;
          await loaded.future;
        },
        send: (_) => const Result.success(null),
        onFailure: (_, _) {},
      );

      authentication.onConnectionStateChanged(_serverClosure(_expiredToken));
      final abandoned = _anAttempt();
      final running = authentication.authenticate(abandoned);

      abandoned.end();
      await authentication.authenticate(_anAttempt());

      loaded.complete();
      await running;

      // The abandoned attempt never sent anything, so the refusal still applies to the credentials
      // in place, and belongs to the attempt that can actually answer it.
      expect(asked, [_expiredToken, _expiredToken]);
    });

    test('still reports a failure for the attempt in flight', () async {
      final failures = <Object>[];

      final authentication = WebSocketAuthenticationHandler(
        authenticator: (_, _) async => throw StateError('token load failed'),
        send: (_) => const Result.success(null),
        onFailure: (error, _) => failures.add(error),
      );

      await authentication.authenticate(_anAttempt());

      expect(failures, [isStateError]);
    });
  });
}
