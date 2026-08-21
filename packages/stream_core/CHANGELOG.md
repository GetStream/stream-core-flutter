## Upcoming

### 💥 BREAKING CHANGES

- Removed the `userId` parameter from `UserToken.anonymous`, anonymous tokens always use `User.anonymousUserId`
- Removed the `TokenManager.tokenProvider` setter, use `setTokenProvider` instead
- `StreamWebSocketClient` now takes an `optionsBuilder` instead of `options`, and calls it for every connection attempt
- Renamed `StreamWebSocketClient.onConnectionEstablished` to `onAuthenticate`
- `StreamWebSocketClient.onAuthenticate` is now a `WebSocketAuthenticator`: it is handed a `WsRequestSender` and returns a `Result`, so a failure to authenticate can be observed
- `WsRequestSender` and `WebSocketAuthenticator` now live in `web_socket_authentication_handler.dart` and are exported as before. The handler that runs them, and remembers what the server refused, is internal
- `WebSocketAuthenticator` returns `Future<void>` rather than `Future<Result<void>>`: it throws to say the credentials did not go out, whether that is a failure or a deliberate refusal to send them. Returning a result described the same thing a second way, and both were funnelled into the same closure regardless
- `WebSocketAuthenticator` is handed the error the server closed the previous attempt with, as `previousError`, and null once a connection has been established. It says whether the credentials it last sent are the reason the attempt failed, so it can replace them — or return a failure when there is nothing to replace them with, which closes the connection as `AuthenticationFailed` and is not retried, rather than offering refused credentials for the life of the client
- `TokenManager.userId` is now nullable, and is `null` until an identity is configured
- `User` now requires a user of type `UserType.anonymous` to carry `User.anonymousUserId` as its id. A mismatch fails to compile in a const context, and throws in debug mode otherwise
- `WebSocketConnectionState.isAutomaticReconnectionEnabled` is now `true` for an expired token, and remains `false` for token errors a fresh token cannot fix
- `StreamApiError.isTokenExpiredError` now means code 40 only; the other token codes and a wrong API key are `isInvalidTokenError`
- `StreamApiError.isClientError` compares the HTTP `statusCode` against 400..499 rather than the Stream error `code`, which never falls in that range
- `Result.getOrElse`, `getOrDefault`, `recover` and `recoverCatching` return the result's own type and no longer take a type parameter. To widen, widen the result (`Result<num> widened = intResult`) or use `fold`

### ✨ Features

- Added `TokenManager.setTokenProvider`, which points an existing manager at another user and expires the cached token
- Added optional `onTokenUpdated` callback to `TokenManager`, invoked after every successful token load
- Added optional `rawValue` to `UserToken.anonymous`, so an anonymous token can carry a JWT granting restricted access; its `user_id` claim must be `!anon`
- Added `UserToken.expiresAt`, from the token's `exp` claim, and `UserToken.isExpired`, which takes an optional `leeway`
- Added `User.anonymousUserId`, the id every anonymous user has
- Added `TokenManager.unconfigured`, for a client that exists before its user does
- Added `TokenManager.reset`, which drops the configured identity and its cached token
- Added `DisconnectionSource.connectTimeout`, reported when a connection attempt is abandoned before it is established, and eligible for automatic reconnection
- Added `DisconnectionSource.authenticationFailed`, reported with its cause when a connection opens but cannot be authenticated
- Added `WsRequestSender`, the send capability handed to a `WebSocketAuthenticator`
- Added `ConnectUserDetailsRequest.fromUser`, which builds the details a client may send from a `User`
- Added `StreamWebSocketClient.dispose`, which closes the connection along with `events` and `connectionState`; the client is now `Disposable`
- `StreamWebSocketClient.connect` now throws a `StateError` once the client has been disposed, in release builds as well as debug. It previously asserted and then returned, so a release build opened a socket nothing could observe or close: the emitters are shut, so no state change is reported, and the health monitor that would tear an idle connection down is stopped
- `StreamWebSocketClient.disconnect` records the request without going through `disconnecting` when there is no connection to close, so a `connect` made straight afterwards is not refused for racing a close that is not happening. An explicit disconnect also now takes effect on a connection that is already down, which is what calls off a scheduled reconnection
- Added `teams` field to `User` class
- `StreamWebSocketClient` now honours `WebSocketOptions.connectTimeout`, no longer nullable and 30 seconds by default, so an attempt that never becomes usable is abandoned and reconnected rather than waited on indefinitely

### 🐛 Bug Fixes

- Fixed `StreamWebSocketClient.connect` leaking the socket of a connection whose handshake failed. The socket is opened before the handshake it fails, and the client reported the connection closed without closing it, so the socket stayed open and unreachable — `dispose` did not close it either, and the next attempt closed it instead, reporting a closure while that attempt was still connecting
- Fixed a WebSocket engine that reported a closure to its listener only when the close succeeded. It now reports one however the close went, and even when there was no socket to close, so a client waiting to hear the connection is down is no longer left waiting on a socket it can never use. It also lets go of a socket that failed to close, rather than holding one it cannot use, and reports a closure once rather than again when the socket's stream ends
- Fixed a request that met a second token-expired response never completing at all. A request is now retried at most once
- Fixed a retried request re-sending a multipart body whose streams the refused attempt had already consumed
- Fixed a rejected request expiring a token that another request had already replaced; only the token a request actually carried is expired now
- Fixed `TokenManager.getToken()` contacting the `TokenProvider` on every call instead of returning the cached token
- Fixed `DynamicTokenProvider` accepting a token issued for a different user than the one requested
- Fixed `TokenManager` caching a token that finished loading after `expireToken` or `setTokenProvider` had invalidated it
- Fixed `StreamWebSocketClient.disconnect` completing before the socket was closed, so a `connect` straight afterwards raced the closure
- Fixed a failure to close the socket leaving `StreamWebSocketClient` reporting itself as disconnecting for good
- Fixed a `WebSocketAuthenticator` that throws rather than returning a failure escaping as an unhandled error and leaving the connection authenticating
- Fixed `StreamWebSocketClient.disconnect` replacing the source of a closure already under way, turning a reconnectable error into a permanent `ConnectTimeout`
- Fixed `isAutomaticReconnectionEnabled` refusing neither a deliberate close (code 1000) nor client errors, neither of which ever matched
- Fixed a connection closed for a rate limit not being eligible for automatic reconnection, since a rate limit clears on its own
- Fixed `ConnectionRecoveryHandler` retrying a first connection attempt, which reconnected behind the caller of `connect`; only established connections are recovered now
- Fixed a health check arriving while disconnecting reporting the connection as established again, turning a deliberate disconnect into a reconnect

### 🔄 Changed

- Raised the minimum Dart SDK to `^3.12.0`
- Anonymous requests now always send `user_id=!anon`, rather than whatever id the `TokenManager` was configured with
- `DynamicTokenProvider` checks the token type before its user id, so a token of the wrong type is reported as such instead of as a mismatched user
- `TokenManager.setTokenProvider` does nothing when handed the identity it already has; providers are compared with `==`
- `TokenManager.getToken` fails when `reset` runs while the token is loading; a `setTokenProvider` during a load still serves the caller that started it
- `TokenManager.getToken` rejects a token whose `user_id` is not the user it was loading for
- `AuthInterceptor` no longer attempts a token refresh when the manager has no identity, so the original token-expired error is surfaced

## 0.4.0

### 💥 BREAKING CHANGES

- `SharedEmitter` and `StateEmitter` now implement `Stream<T>` directly instead of exposing a `stream` getter
- Removed `stream` getter from `SharedEmitter` and `StateEmitter`

### ✨ Features

- Added `hasListener` and `isClosed` properties to `SharedEmitter`
- Added `asSharedEmitter()` and `asStateEmitter()` extension methods for read-only views
- Added `update`, `getAndUpdate`, `updateAndGet` extension methods on `MutableStateEmitter`
- Added `StreamEvent` base interface and `EventResolver` for event transformation

## 0.3.3

### ✨ Features

- Added `partition` method for splitting lists into two based on a filter condition
- Added `compare` parameter to `updateWhere` for optional sorting after updates

## 0.3.2

### ✨ Features

- Added location-based filtering support with `LocationCoordinate`, `Distance`, `CircularRegion`,
  and `BoundingBox`
- Added `insertAt` parameter to `upsert` for controlling insertion position of new elements

## 0.3.1

### ✨ Features

- Added `updateWhere` method for updating elements matching a filter condition
- Added `batchReplace` method for replacing multiple elements based on matching keys
- Added `insertUnique` method for inserting elements ensuring uniqueness by key with optional sorting
- Added `update` parameter to `upsert` for custom merge logic when replacing existing elements
- Added `update` parameter to `batchReplace` for custom merge logic
- Added `update` parameter to `sortedUpsert` for custom merge logic when replacing existing elements

### 🐛 Bug Fixes

- Fixed `StreamDioException.toClientException()` not handling invalid JSON strings gracefully

## 0.3.0

### 💥 BREAKING CHANGES

- `FilterField` now requires a value getter function `Object? Function(T)`
- Filter classes renamed (e.g., `EqualOperator` → `Equal`, `AndOperator` → `And`)
- `Filter` signature changed to `Filter<T extends Object>`

### ✨ Features

- Added `matches(T other)` method for client-side filtering with PostgreSQL-like semantics
- Added utility functions for deep equality, subset containment, and type-safe comparisons
- Enhanced `Sort` comparator to handle incompatible types safely

## 0.2.0

### 💥 BREAKING CHANGES

- Renamed `AppLifecycleStateProvider` to `LifecycleStateProvider` and `AppLifecycleState` to `LifecycleState`

### ✨ Features

- Added `keepConnectionAliveInBackground` option to `ConnectionRecoveryHandler`
- Added `unknown` state to `NetworkState` and `LifecycleState` enums

### 🐛 Bug Fixes

- Fixed `onClose()` not being called when disconnecting during connecting state
- Fixed unnecessary reconnection attempts when network is offline
- Fixed existing connections not being closed before opening new ones

## 0.1.0

- Initial release
