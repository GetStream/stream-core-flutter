import '../../errors.dart' show StreamApiException, StreamNetworkException;
import '../../logger.dart';
import '../../utils.dart';
import '../events/ws_request.dart';
import 'web_socket_connection_state.dart';

/// A function that sends a request over a connection that is not usable yet.
///
/// Fails once the connection attempt it was handed to is no longer the one in flight, so
/// credentials loaded for an abandoned attempt are not sent over the connection that replaced it.
typedef WsRequestSender = Result<void> Function(WsRequest request);

/// A function that authenticates a newly opened connection.
///
/// Called while the state is [Authenticating], to send the credentials the connection requires.
///
/// `previousError` is the error the server closed the previous attempt with, and null when there was
/// none, once a connection has been established, or once the caller has disconnected. Only the next
/// attempt after a refusal sees it. Use it to replace credentials that were refused.
///
/// Throw when the credentials did not go out, whether because sending failed or because this
/// function chose not to send them. The connection is then closed with [AuthenticationFailed]
/// carrying what was thrown, and reconnected only when that says the network was at fault rather
/// than the credentials — so pass a failed [WsRequestSender]'s error on rather than replacing it.
typedef WebSocketAuthenticator = Future<void> Function(WsRequestSender send, StreamApiException? previousError);

/// A handler that authenticates newly opened connections and remembers why the server refused the
/// last one.
///
/// Driven by a WebSocket client, which feeds it connection state changes.
class WebSocketAuthenticationHandler {
  /// Creates a [WebSocketAuthenticationHandler].
  ///
  /// `authenticator` may be null, for a connection that needs nothing sent.
  WebSocketAuthenticationHandler({
    required this._authenticator,
    required this._send,
    required this._onFailure,
    String tag = 'SC:WsAuth',
  }) : _logger = StreamLogger(tag);

  final StreamLogger _logger;

  final WebSocketAuthenticator? _authenticator;
  final WsRequestSender _send;
  final void Function(Object error, StackTrace? stackTrace) _onFailure;

  // Identifies the attempt in flight: an authenticator can outlive the one that started it.
  var _attempt = 0;

  /// The error the server closed the previous attempt with, if it sent one.
  ///
  /// Becomes null once the attempt that read it finishes, or once a connection is established. An
  /// attempt abandoned before it finishes leaves it behind, for the attempt that replaces it.
  StreamApiException? get previousError => _previousError;
  StreamApiException? _previousError;

  /// Takes in a connection state change.
  ///
  /// A [Connecting] state begins an attempt and a closure ends one, after which an authenticator
  /// still running for it can neither send nor report a failure: whatever it comes back with
  /// describes a connection that is already gone. Every other state only updates [previousError],
  /// which is left alone unless the server refused or the caller took over.
  void onConnectionStateChanged(WebSocketConnectionState state) {
    if (state case Connecting() || Disconnecting() || Disconnected()) _attempt++;

    _previousError = switch (state) {
      Connected() => null,
      // The caller took control; what they connect with next may have nothing to do with the refusal.
      Disconnected(source: UserInitiated()) => null,
      // The server closed without sending an error, so the last one still applies. Only a verdict
      // counts: a transport failure says nothing about the credentials.
      Disconnected(source: ServerInitiated(:final StreamApiException error)) => error,
      _ => _previousError,
    };
  }

  /// Authenticates a socket that has just opened.
  ///
  /// Does nothing when there is no authenticator. Passes [previousError] to the authenticator, and
  /// spends it once this attempt finishes, so a later attempt does not see a refusal that was not
  /// about it.
  ///
  /// An error the authenticator throws is passed to `onFailure` instead of escaping, unless the
  /// attempt has since been abandoned, which leaves nothing to report it against.
  Future<void> authenticate() async {
    final authenticate = _authenticator;
    if (authenticate == null) return;

    final attempt = _attempt;
    final previousError = _previousError;
    _logger.d(() => 'authenticate attempt #$attempt, previousError: $previousError');

    // Guarded because nothing awaits this: an error thrown here would go unhandled.
    final result = await runSafely(() => authenticate(_senderFor(attempt), previousError));

    // Stale: its failure would close the connection that replaced it, and never be reconnected.
    if (attempt != _attempt) {
      return _logger.d(() => 'attempt #$attempt is stale, dropping its outcome: $result');
    }

    // Spent, unless the server refused something newer while the authenticator ran. By identity,
    // not equality: a newer refusal of the same kind compares equal to this one.
    if (identical(_previousError, previousError)) _previousError = null;

    if (result case Failure(:final error, :final stackTrace)) {
      _logger.w(() => 'attempt #$attempt could not be authenticated', error: error, stackTrace: stackTrace);
      return _onFailure(error, stackTrace);
    }
  }

  // The sender is held across the authenticator's own awaits, so the attempt is checked on each send.
  WsRequestSender _senderFor(int attempt) => (request) {
    if (attempt == _attempt) return _send(request);

    const error = StreamNetworkException(
      message: 'The connection attempt was abandoned before its credentials were sent',
    );
    return const Result.failure(error);
  };
}
