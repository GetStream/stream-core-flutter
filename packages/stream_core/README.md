# StreamCore (Flutter)

**⚠️ Internal SDK — Not for public use**

This is the internal Dart SDK that powers several of Stream’s products (`stream_feed`, `stream_chat` and `stream_video`). 

It provides shared low-level utilities, such as:

- A robust WebSocket client
- Retry/backoff logic
- Logging and monitoring tools
- Dependency injection and lightweight service containers
- Support for uploading attachments
- User models
- Other utils that are used in the products

## 🔒 Intended Usage

This package is **not designed for direct use by customers**. It acts as the foundation layer for other Stream SDKs and contains internal logic that is subject to change.

> If you're building an app with Stream, use [stream-chat-flutter](https://github.com/GetStream/stream-chat-flutter), [stream-video-flutter](https://github.com/GetStream/stream-video-flutter) or [stream-feeds-flutter](https://github.com/GetStream/stream-feeds-flutter) instead.

## ⚠️ Versioning Notice

This library does follow semantic versioning. Breaking changes may be introduced at any time without warning. We reserve the right to refactor or remove functionality without deprecation periods. However, as all our products need to depend on the same version of the core packages we want to limit breaking changes as much as possible.

## Detailed docs
* [Websocket](./doc/web_socket.md)