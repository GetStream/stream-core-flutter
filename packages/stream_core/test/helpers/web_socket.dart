import 'dart:async';

// ignore: depend_on_referenced_packages
import 'package:stream_channel/stream_channel.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// A socket a test drives, recording what was sent to the peer.
///
/// Closing it ends [FakeWebSocketChannel.stream], as a real socket does. Pass `holdClose` for a
/// close that only finishes once [completeClose] is called, and `closeError` for one that refuses to
/// close at all.
class FakeWebSocketSink implements WebSocketSink {
  FakeWebSocketSink({this.holdClose = false, this.closeError, this.onSent, this._onClosed});

  /// Whether [close] waits for [completeClose] before finishing.
  final bool holdClose;

  /// Thrown by [close], for a socket that refuses to close.
  final Object? closeError;

  /// Called with each frame sent, for a peer that answers.
  void Function(Object? frame)? onSent;

  final void Function()? _onClosed;

  /// Everything sent to the peer, in order.
  final sent = <Object?>[];

  /// The code and reason [close] was called with, or `null` while still open.
  ({int? code, String? reason})? closedWith;

  final _held = Completer<void>();
  final _done = Completer<void>();

  /// Lets a close held by `holdClose` finish.
  void completeClose() {
    if (!_held.isCompleted) _held.complete();
  }

  @override
  void add(Object? data) {
    sent.add(data);
    onSent?.call(data);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {}

  @override
  Future<void> addStream(Stream<Object?> stream) => stream.forEach(add);

  @override
  Future<void> close([int? closeCode, String? closeReason]) async {
    closedWith = (code: closeCode, reason: closeReason);
    if (holdClose) await _held.future;
    if (closeError case final error?) throw error; // ignore: only_throw_errors

    _onClosed?.call();
    if (!_done.isCompleted) _done.complete();
  }

  @override
  Future<void> get done => _done.future;
}

/// A WebSocket a test drives, in place of a real connection.
///
/// Incoming frames arrive through [emit], and [endStream] is the peer hanging up. Closing [sink]
/// ends [stream], which is the guarantee `StreamChannel` requires of a real channel.
class FakeWebSocketChannel extends StreamChannelMixin<Object?> implements WebSocketChannel {
  FakeWebSocketChannel({
    bool holdClose = false,
    Object? closeError,
    this.readyError,
    this.holdReady = false,
  }) {
    sink = FakeWebSocketSink(
      holdClose: holdClose,
      closeError: closeError,
      onClosed: endStream,
    );
  }

  /// Thrown by [ready], for a socket that never opens.
  final Object? readyError;

  /// Whether [ready] never completes, for a handshake that hangs.
  final bool holdReady;

  @override
  // ignore: close_sinks
  late final FakeWebSocketSink sink;

  // A controller with no `onCancel` has nothing to wait for, so `cancel` hands back a future that
  // belongs to the root zone. A `fakeAsync` test never drives that zone, so awaiting the cancel there
  // stalls for good, while against a real socket it completes. Naming an `onCancel` is what makes the
  // controller hand back a future of its own instead.
  final _incoming = StreamController<Object?>(onCancel: Future<void>.value);

  /// Delivers an incoming frame.
  void emit(Object? frame) {
    if (!_incoming.isClosed) _incoming.add(frame);
  }

  /// Delivers a socket error, as a connection failing mid-stream does.
  ///
  /// A real socket closes itself after reporting one, so [endStream] follows.
  void emitError(Object error) {
    if (_incoming.isClosed) return;

    _incoming.addError(error);
    endStream();
  }

  /// Ends the incoming stream, as a peer hanging up does.
  void endStream() {
    if (!_incoming.isClosed) _incoming.close().ignore();
  }

  @override
  Stream<Object?> get stream => _incoming.stream;

  @override
  Future<void> get ready {
    if (readyError case final error?) return Future.error(error);
    if (holdReady) return Completer<void>().future;
    return Future.value();
  }

  @override
  String? get protocol => null;

  @override
  int? get closeCode => sink.closedWith?.code;

  @override
  String? get closeReason => sink.closedWith?.reason;
}
