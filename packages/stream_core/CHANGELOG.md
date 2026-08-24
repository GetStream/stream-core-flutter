## Upcoming

### 💥 BREAKING CHANGES

- Raised the minimum Dart SDK to `^3.12.0`
- Removed the `userId` parameter from `UserToken.anonymous`, anonymous tokens always use `User.anonymousUserId`
- Removed the `TokenManager.tokenProvider` setter, use `setTokenProvider` instead
- `TokenManager.userId` is now nullable, and is `null` until an identity is configured
- `User` now requires a user of type `UserType.anonymous` to carry `User.anonymousUserId` as its id. A mismatch fails to compile in a const context, and throws in debug mode otherwise
- `StreamWebSocketClient` now takes an `optionsBuilder` instead of `options`, called once per connection attempt
- `WebSocketOptions.connectTimeout` is now a non-nullable `Duration`, 30 seconds by default, and is honoured: a connection that does not come up is given up on instead of waited on indefinitely. A connection that drops later is retried for you; a `connect` that times out is not, so call it again
- Renamed `StreamWebSocketClient.onConnectionEstablished` to `onAuthenticate`, now a `WebSocketAuthenticator`. It is handed a `WsRequestSender` and the error the server closed the previous attempt with, and throws to say the credentials did not go out
- Removed `WebSocketEngineException.stopErrorCode`, use `CloseCode.normalClosure`
- `AuthInterceptor` extends `Interceptor` rather than `QueuedInterceptor`, so requests are no longer serialised against one another
- `WebSocketConnectionState.isAutomaticReconnectionEnabled` is now `true` for an expired token, and remains `false` for token errors a fresh token cannot fix
- `StreamApiError.isTokenExpiredError` now means code 40 only; the other token codes and a wrong API key are `isInvalidTokenError`. `isClientError` compares the HTTP `statusCode` against 400..499, rather than the Stream error `code`, which never falls in that range
- `Result.getOrElse`, `getOrDefault`, `recover` and `recoverCatching` return the result's own type and no longer take a type parameter. To widen, widen the result (`Result<num> widened = intResult`) or use `fold`
- Replaced the logger: `StreamLogger` is the handle you write with and a `StreamLogHandler` is where records go, so `Priority`, `MessageBuilder`, `Tag`, `IsLoggableValidator` and `Finder` are renamed or gone
- `LoggingInterceptor` writes through the logger rather than printing, so it is silent until an app installs a handler. Its `logPrint` is now optional, and it takes a `tag`

### ✨ Features

- Added a logger the SDK now reports itself through, silent until an app installs a handler on `StreamLogger.root` or a product client passes `StreamLogger.configure` the `StreamLogConfig` it was given
- Added `TokenManager.setTokenProvider`, which points an existing manager at another user and expires the cached token; handed the identity it already has, it does nothing
- Added optional `onTokenUpdated` callback to `TokenManager`, invoked after every successful token load
- Added optional `rawValue` to `UserToken.anonymous`, so an anonymous token can carry a JWT granting restricted access; its `user_id` claim must be `!anon`
- Added `UserToken.expiresAt`, from the token's `exp` claim, and `UserToken.isExpired`, which takes an optional `leeway`
- Added `User.anonymousUserId`, the id every anonymous user has
- Added `TokenManager.unconfigured`, for a client that exists before its user does, and `TokenManager.reset`, which drops the configured identity and its cached token
- Added `teams` field to `User` class
- Added `DioException.apiError`, the Stream API error a response carried, or `null` for anything else
- Added `DisconnectionSource.connectTimeout` and `authenticationFailed`, and `isReconnectable`, whether a connection closed for that reason is worth opening again
- Added `DisconnectionSource.cause`, the error that closed the connection, or `null` when the source carries none
- Added `ConnectUserDetailsRequest.fromUser`, which builds the details a client may send from a `User`
- Added `StreamWebSocketClient.dispose`, which closes the connection along with `events` and `connectionState`; the client is now `Disposable`, and `connect` throws a `StateError` afterwards

### 🐛 Bug Fixes

- Fixed three faults in `TokenManager`'s token cache: `getToken` contacted the provider on every call instead of returning the cached token, handed out a token that had already expired rather than replacing it, and cached one that finished loading after `expireToken` or `setTokenProvider` had invalidated it. A static provider is left alone, having nothing fresher to give
- Fixed `DynamicTokenProvider` accepting a token issued for a different user than the one requested
- Fixed several faults in the token-expired retry: it was skipped when the response carried no JSON content type, never completed at all when the replacement was refused too, re-sent a multipart body whose streams the refused attempt had consumed, and expired a token another request had already replaced
- `StreamWebSocketClient` no longer prints to the console
- Fixed a connection that could be left open, or left disconnecting for good: `connect` leaked the socket of a failed handshake, `disconnect` completed before the socket had closed, and a close that failed or found no socket reported no closure at all
- Fixed reconnection eligibility: the deliberate-close and client-error checks never matched, and a rate limit was treated as permanent when it clears on its own
- Fixed `ConnectionRecoveryHandler` retrying a first connection attempt, which reconnected behind the caller of `connect`; only established connections are recovered now
- Fixed a health check arriving while disconnecting reporting the connection as established again, turning a deliberate disconnect into a reconnect

### 🔄 Changed

- `ConnectUserDetailsRequest` leaves its unset fields out of the JSON it serialises, rather than sending them as nulls
- Anonymous requests now always send `user_id=!anon`, rather than whatever id the `TokenManager` was configured with
- `DynamicTokenProvider` checks the token type before its user id, so a token of the wrong type is reported as such instead of as a mismatched user
- `TokenManager.getToken` fails when `reset` runs while the token is loading, and rejects a token whose `user_id` is not the user it was loading for; a `setTokenProvider` during a load still serves the caller that started it
- `AuthInterceptor` no longer refreshes a token when the manager has no identity, so the original error is surfaced, and no longer retries a request signed for a user it has since been pointed away from, which would have performed one user's request as another
- `StreamWebSocketEngine.open` fails when a connection is already open, rather than closing it to make room
- `SystemEnvironmentManager.updateEnvironment` now sanitizes the passed `SystemEnvironment`, so an integrator can enrich the Stream client header without changing the SDK identity it reports

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
