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
    this.connectTimeout,
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
  /// When specified, the connection attempt will timeout if not completed
  /// within this duration. If `null`, uses the platform default timeout.
  final Duration? connectTimeout;

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
