import 'web_socket_engine.dart';

/// Configuration options for establishing WebSocket connections.
///
/// Defines the connection parameters including URL, timeout settings, protocols,
/// and query parameters for WebSocket connections. Used by [WebSocketEngine]
/// implementations to establish connections with the specified configuration.
///
/// ## Example
/// ```dart
/// final options = WebSocketOptions(
///   url: 'wss://api.example.com/ws',
///   connectTimeout: Duration(seconds: 10),
///   protocols: ['chat', 'superchat'],
///   queryParameters: {
///     'token': 'abc123',
///     'version': '1.0',
///   },
/// );
/// ```
class WebSocketOptions {
  /// Creates a new instance of [WebSocketOptions].
  const WebSocketOptions({
    required this.url,
    this.connectTimeout = defaultConnectTimeout,
    this.protocols,
    this.queryParameters,
  });

  /// The WebSocket server URL to connect to.
  ///
  /// Must be a valid WebSocket URL using either `ws://` or `wss://` scheme.
  /// The URL should include the host, port (if non-standard), and path.
  final String url;

  /// Maximum time allowed for establishing the WebSocket connection.
  ///
  /// Covers the whole attempt, not just opening the socket: a connection that opens but is never
  /// established is abandoned once this elapses.
  ///
  /// Defaults to [defaultConnectTimeout].
  final Duration connectTimeout;

  /// The [connectTimeout] used when none is given, thirty seconds.
  static const defaultConnectTimeout = Duration(seconds: 30);

  /// WebSocket sub-protocols to negotiate during the handshake.
  ///
  /// Specifies the list of sub-protocols that the client supports.
  /// The server will select one of these protocols during the handshake
  /// if it supports any of them.
  final Iterable<String>? protocols;

  /// Query parameters to append to the connection URL.
  ///
  /// These parameters are added to the WebSocket URL during connection
  /// establishment. Commonly used for authentication tokens, API versions,
  /// or other connection-specific configuration.
  final Map<String, Object>? queryParameters;
}
