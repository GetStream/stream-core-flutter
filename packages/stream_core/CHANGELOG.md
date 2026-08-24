## Upcoming

### 💥 BREAKING CHANGES

- Removed the `userId` parameter from `UserToken.anonymous`, anonymous tokens always use `User.anonymousUserId`
- Removed the `TokenManager.tokenProvider` setter, use `setTokenProvider` instead
- `StreamWebSocketClient` now takes an `optionsBuilder` instead of `options`, called once per connection attempt
- Renamed `StreamWebSocketClient.onConnectionEstablished` to `onAuthenticate`, now a `WebSocketAuthenticator`. It is handed a `WsRequestSender` and the error the server closed the previous attempt with, and throws to say the credentials did not go out
- Removed `WebSocketEngineException.stopErrorCode`, use `CloseCode.normalClosure`
- `AuthInterceptor` extends `Interceptor` rather than `QueuedInterceptor`, so requests are no longer serialised against one another
- `TokenManager.userId` is now nullable, and is `null` until an identity is configured
- `User` now requires a user of type `UserType.anonymous` to carry `User.anonymousUserId` as its id. A mismatch fails to compile in a const context, and throws in debug mode otherwise
- `WebSocketConnectionState.isAutomaticReconnectionEnabled` is now `true` for an expired token, and remains `false` for token errors a fresh token cannot fix
- `StreamApiError.isTokenExpiredError` now means code 40 only; the other token codes and a wrong API key are `isInvalidTokenError`
- `StreamApiError.isClientError` compares the HTTP `statusCode` against 400..499 rather than the Stream error `code`, which never falls in that range
- `Result.getOrElse`, `getOrDefault`, `recover` and `recoverCatching` return the result's own type and no longer take a type parameter. To widen, widen the result (`Result<num> widened = intResult`) or use `fold`

### ✨ Features

- Added `DioException.apiError`, the Stream API error a response carried, or `null` for anything else
- Added `TokenManager.setTokenProvider`, which points an existing manager at another user and expires the cached token
- Added optional `onTokenUpdated` callback to `TokenManager`, invoked after every successful token load
- Added optional `rawValue` to `UserToken.anonymous`, so an anonymous token can carry a JWT granting restricted access; its `user_id` claim must be `!anon`
- Added `UserToken.expiresAt`, from the token's `exp` claim, and `UserToken.isExpired`, which takes an optional `leeway`
- Added `User.anonymousUserId`, the id every anonymous user has
- Added `TokenManager.unconfigured`, for a client that exists before its user does
- Added `TokenManager.reset`, which drops the configured identity and its cached token
- Added `DisconnectionSource.connectTimeout`, reported when an attempt is abandoned before it is established
- Added `DisconnectionSource.authenticationFailed`, reported with its cause when a connection opens but cannot be authenticated
- Added `DisconnectionSource.isReconnectable`, whether a connection closed for that reason is worth opening again
- Added `WsRequestSender`, the send capability handed to a `WebSocketAuthenticator`, which fails once the attempt it belongs to is no longer the one in flight
- Added `ConnectUserDetailsRequest.fromUser`, which builds the details a client may send from a `User`
- Added `StreamWebSocketClient.dispose`, which closes the connection along with `events` and `connectionState`; the client is now `Disposable`
- `StreamWebSocketClient.connect` now throws a `StateError` once the client has been disposed
- `StreamWebSocketClient.disconnect` now takes effect on a connection already closing or closed, which is what calls off a scheduled reconnection
- Added `teams` field to `User` class
- `StreamWebSocketClient` now honours `WebSocketOptions.connectTimeout`, no longer nullable and 30 seconds by default, so an attempt that never becomes usable is abandoned

### 🐛 Bug Fixes

- Fixed a token-expired response never being retried when the server sent it without a JSON content type
- `StreamWebSocketClient` no longer prints to the console
- Fixed `StreamWebSocketClient.connect` leaking the socket of a connection whose handshake failed, and the closure now names the error that failed it
- Fixed a WebSocket engine that reported no closure when there was no socket to close, leaving a client waiting to hear the connection is down
- Fixed a request that met a second token-expired response never completing at all; a request is now retried at most once
- Fixed a retried request re-sending a multipart body whose streams the refused attempt had already consumed
- Fixed the failure to load a token reporting the stack trace of where it was caught rather than where the load failed
- Fixed a rejected request expiring a token that another request had already replaced; only the token a request actually carried is expired now
- Fixed `TokenManager.getToken()` contacting the `TokenProvider` on every call instead of returning the cached token
- `TokenManager.getToken` now replaces a cached token that has expired, rather than handing it out and learning the same thing from a refused request. Judged on the expiry alone, so a token with life left in it is still cached. A static provider is left alone: it has nothing fresher to give, and the server refusing its token is what tells a guest to exchange for a new identity
- Fixed `DynamicTokenProvider` accepting a token issued for a different user than the one requested
- Fixed `TokenManager` caching a token that finished loading after `expireToken` or `setTokenProvider` had invalidated it
- Fixed `StreamWebSocketClient.disconnect` completing before the socket was closed, so a `connect` straight afterwards raced the closure
- Fixed a failure to close the socket leaving `StreamWebSocketClient` reporting itself as disconnecting for good
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
- `AuthInterceptor` no longer retries a request signed for a user the `TokenManager` has since been pointed away from, which would have performed one user's request as another
- `StreamWebSocketEngine.open` fails when a connection is already open, rather than closing it to make room

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
