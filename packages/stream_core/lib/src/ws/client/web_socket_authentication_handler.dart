import '../../errors.dart' show StreamApiError;
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
/// `previousError` is the error the server closed the previous attempt with, or null if there was
/// none. Only the next attempt after a refusal sees it; later ones see null. Use it to replace
/// credentials that were refused.
///
/// Throw when the credentials did not go out, whether because sending failed or because this
/// function chose not to send them. The connection is then closed with [AuthenticationFailed], and
/// is not reconnected.
typedef WebSocketAuthenticator = Future<void> Function(WsRequestSender send, StreamApiError? previousError);

/// A handler that authenticates newly opened connections and remembers why the server refused the
/// last one.
///
/// Driven by a WebSocket client, which feeds it connection state changes.
class WebSocketAuthenticationHandler {
  /// Creates a [WebSocketAuthenticationHandler].
  ///
  /// `authenticator` may be null, for a connection that needs nothing sent. `onFailure` receives
  /// the cause when authentication fails.
  WebSocketAuthenticationHandler({
    required this._authenticator,
    required this._send,
    required this._onFailure,
  });

  final WebSocketAuthenticator? _authenticator;
  final WsRequestSender _send;
  final void Function(Object error) _onFailure;

  // Identifies the attempt in flight. An authenticator awaiting credentials can outlive the attempt
  // that started it, and holds a sender and a failure path that would otherwise reach whichever
  // connection is current by then.
  var _attempt = 0;

  /// The error the server closed the previous attempt with, if it sent one.
  ///
  /// Becomes null once the attempt that read it finishes, or once a connection is established. An
  /// attempt abandoned before it finishes leaves it behind, for the attempt that replaces it.
  StreamApiError? get previousError => _previousError;
  StreamApiError? _previousError;

  /// Takes in a connection state change.
  ///
  /// A [Connecting] state begins an attempt, after which an authenticator still running for an
  /// earlier one can neither send nor report a failure.
  ///
  /// [previousError] is set when the server closes the connection with an error, and cleared when a
  /// connection is established or the caller disconnects. It is otherwise left alone, so a refusal
  /// outlives the states an attempt passes through.
  void onConnectionStateChanged(WebSocketConnectionState state) {
    if (state case Connecting()) _attempt++;

    _previousError = switch (state) {
      Connected() => null,
      // The caller took control, so whatever they connect with next is a decision of their own and
      // may have nothing to do with the credentials that were refused.
      Disconnected(source: UserInitiated()) => null,
      // The server closed without sending an error, so the last one still applies.
      Disconnected(source: ServerInitiated(:final error)) => error?.apiError ?? _previousError,
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

    // Guarded because nothing awaits this: an error thrown here would go unhandled.
    final result = await runSafely(() => authenticate(_senderFor(attempt), previousError));

    // The connection this failure belongs to is already closed, and the one that replaced it did
    // not fail: reported against that one it would close a usable connection as
    // `AuthenticationFailed`, which is never reconnected. The refusal is left behind with it, for
    // the attempt that replaced it and has yet to answer it.
    if (attempt != _attempt) return;

    // Spent, unless the server has refused something newer since: either the credentials went out,
    // or the authenticator saw the refusal and had nothing else to offer, and one left armed would
    // be declined again without anything being sent.
    if (_previousError == previousError) _previousError = null;

    if (result case Failure(:final error)) return _onFailure(error);
  }

  // An authenticator holds its sender across its own awaits, so the attempt is checked when a
  // request is sent rather than once before the authenticator is called.
  WsRequestSender _senderFor(int attempt) => (request) {
    if (attempt == _attempt) return _send(request);

    final error = StateError('Connection attempt was abandoned before its credentials were sent');
    return Result.failure(error);
  };
}
