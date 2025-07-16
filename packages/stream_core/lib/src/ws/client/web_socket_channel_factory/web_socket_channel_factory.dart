import 'dart:async';

import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketChannelFactory {
  const WebSocketChannelFactory();
  Future<WebSocketChannel> connect(Uri uri,
      {Iterable<String>? protocols}) async {
    throw UnsupportedError('No implementation of the connect api provided');
  }
}
