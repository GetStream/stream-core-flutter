import 'dart:async';

import 'web_socket_connection_state.dart';

/// One attempt to open a connection, from [Connecting] until that connection starts closing.
///
/// Work that suspends mid-attempt holds one, so that when it resumes it can tell whether it is
/// still the attempt being made. The connection state cannot answer that on its own: an attempt
/// that replaced this one reports [Connecting] too.
///
/// Created by a client, one per attempt, and handed to whatever works on that attempt's behalf.
final class WebSocketConnectionAttempt {
  /// Creates an attempt, calling `onTimeout` if it outlives a bound given to [boundBy].
  WebSocketConnectionAttempt({required this._onTimeout});

  final void Function() _onTimeout;
  final _ended = Completer<void>();
  Timer? _bound;

  /// Whether this attempt has stopped being the one in flight.
  bool get hasEnded => _ended.isCompleted;

  /// What [operation] completes with, or null if this attempt ends before it does.
  ///
  /// Raced rather than checked afterwards, so an operation that never completes cannot hold up its
  /// caller once the attempt it belongs to is over.
  Future<T?> valueUnlessEnded<T>(Future<T> operation) {
    return Future.any([operation, _ended.future.then((_) => null)]);
  }

  /// Gives this attempt [timeout] to become usable, replacing any bound it already had.
  void boundBy(Duration timeout) {
    _bound?.cancel();
    _bound = Timer(timeout, _onTimeout);
  }

  /// Stops bounding this attempt, for a connection that has shown it works.
  ///
  /// Separate from ending it: the attempt is still the one in flight, it just no longer needs a
  /// deadline.
  void stopBounding() {
    _bound?.cancel();
    _bound = null;
  }

  /// Ends this attempt once the connection it was making starts closing.
  void onConnectionStateChanged(WebSocketConnectionState state) {
    if (state case Disconnecting() || Disconnected()) end();
  }

  /// Ends this attempt, so anything still waiting on it stops.
  void end() {
    _bound?.cancel();
    _bound = null;
    if (!_ended.isCompleted) _ended.complete();
  }
}
