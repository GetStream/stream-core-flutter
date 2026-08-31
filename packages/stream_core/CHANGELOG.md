## Upcoming

### 💥 BREAKING CHANGES

- Raised the minimum Dart SDK to `^3.12.0`
- Removed the `userId` parameter from `UserToken.anonymous`, anonymous tokens always use `User.anonymousUserId`
- Removed the `TokenManager.tokenProvider` setter, use `setTokenProvider` instead
- `TokenManager.userId` is now nullable, and is `null` until an identity is configured
- `User` now requires a user of type `UserType.anonymous` to carry `User.anonymousUserId` as its id. A mismatch fails to compile in a const context, and throws in debug mode otherwise
- `StreamWebSocketClient` now takes an `optionsBuilder` instead of `options`, called once per connection attempt
- `WebSocketOptions.connectTimeout` is now a non-nullable `Duration`, 30 seconds by default, and is honoured: a connection that does not come up is given up on instead of waited on indefinitely. A connection that drops later is retried for you; a `connect` that times out is not, so call it again
- Renamed `StreamWebSocketClient.onConnectionEstablished` to `onAuthenticate`, now a `WebSocketAuthenticator`. It is handed a `WsRequestSender` and the `StreamApiException` the server closed the previous attempt with, and throws to say the credentials did not go out
- Reworked the error layer around one sealed root: every failure the SDK reports is a `StreamException` of four kinds — `StreamApiException`, `StreamNetworkException`, `StreamAuthenticationException` or `StreamClientException`. See `ERROR_LAYER.md` for the contract
- Removed `ClientException`, `HttpClientException` and `WebSocketEngineException`, replaced by the kinds above. `StreamDioException.exception` is a `StreamException`, and `DioException.toClientException()` is now `toStreamException()`
- `ServerInitiated.error` is typed `StreamException?` rather than `WebSocketEngineException?`
- `TokenManager.getToken` fails with a `StreamAuthenticationException` rather than raw errors; a failed provider's own error is preserved as `cause`
- Replaced `StreamApiError.isTokenExpiredError`, `isClientError` and `isRateLimitError`: the conditions live on `StreamErrorCode` and `StreamApiException` as `isTokenExpired`, `isTokenNotYetValid`, `isTokenSignatureInvalid`, `isApiKeyInvalid` and `isRateLimited`; `StreamApiError` keeps only `isRateLimited`
- `StreamApiError.code` is typed `StreamErrorCode` rather than `int`; construction takes `StreamErrorCode(40)` in place of `40`, reads are unchanged
- `AuthInterceptor` extends `Interceptor` rather than `QueuedInterceptor`, so requests are no longer serialised against one another
- `WebSocketConnectionState.isAutomaticReconnectionEnabled` reads the error's facts: token conditions that heal and transient network failures reconnect; refused signatures or API keys, other 4xx and `unrecoverable` verdicts do not
- `Result.getOrElse`, `getOrDefault`, `recover` and `recoverCatching` return the result's own type and no longer take a type parameter. To widen, widen the result (`Result<num> widened = intResult`) or use `fold`
- Replaced the logger: `StreamLogger` is the handle you write with and a `StreamLogHandler` is where records go, so `Priority`, `MessageBuilder`, `Tag`, `IsLoggableValidator` and `Finder` are renamed or gone
- `LoggingInterceptor` writes through the logger rather than printing, so it is silent until an app asks for records. Its `logPrint` is now optional, and it takes a `tag`
- Reworked attachment uploads around `AttachmentUploadTask`: `StreamAttachmentUploader.upload` returns the running task rather than a `Future`, and `uploadBatch` returns an `AttachmentUploadBatch`. `CancelToken` and progress callbacks are gone from the public API
- Removed `StreamAttachment.uploadState`. Where an upload has got to lives on the task running it, not on the attachment
- Replaced the `UploadState*` classes with `UploadQueued`, `UploadPreparing`, `UploadInProgress`, `UploadSuccess`, `UploadFailed` and `UploadCancelled`. `UploadInProgress.progress` is an `UploadProgress` in bytes rather than a `double`, `UploadSuccess` carries the `UploadedAttachment`, and `UploadFailed.error` is a `StreamException` rather than an `Object` with no separate `stackTrace`. The `AttachmentUploadState.preparing()`, `.inProgress()`, `.success()` and `.failed()` named constructors are gone; construct the states directly
- Removed `AttachmentUploadException`. A failed upload carries the `StreamException` that stopped it, and a cancelled one a `StreamNetworkException` with `isCancelled` set
- Removed the `OnUploadProgress` and `OnBatchUploadProgress` callbacks along with the `StreamAttachmentUploaderBatch` extension. Progress arrives on `AttachmentUploadTask.state` and `AttachmentUploadBatch.state`, so it can never disagree with the lifecycle
- `uploadBatch`'s `maxConcurrent` now defaults to `3` rather than `5`

### ✨ Features

- Added a logger the SDK now reports itself through, silent until an app names both a destination and a priority on `StreamLogger`, or hands a product client a `StreamLogConfig` carrying both
- Added `TokenManager.setTokenProvider`, which points an existing manager at another user and expires the cached token; handed the identity it already has, it does nothing
- Added optional `onTokenUpdated` callback to `TokenManager`, invoked after every successful token load
- Added optional `rawValue` to `UserToken.anonymous`, so an anonymous token can carry a JWT granting restricted access; its `user_id` claim must be `!anon`
- Added `UserToken.expiresAt`, from the token's `exp` claim, and `UserToken.isExpired`, which takes an optional `leeway`
- Added `User.anonymousUserId`, the id every anonymous user has
- `User.guest` takes an `image`, which it previously dropped
- Added `TokenManager.unconfigured`, for a client that exists before its user does, and `TokenManager.reset`, which drops the configured identity and its cached token
- Added `teams` field to `User` class
- Added `objectRuntimeType`, naming an object's type in `toString` in a way that survives minification
- Added `StreamDateTimeConverter`, a `JsonConverter` for the API's `DateTime` fields. Accepts either an RFC3339 string (v1) or epoch nanoseconds (v2) when deserializing, and always serializes to RFC3339. Values are normalized to UTC with microsecond precision
- Added `DioException.toStreamException()`, mapping a Dio failure to the `StreamException` it represents
- Added `StreamApiException.retryAfter`, the wait the server asked for, read from the `Retry-After` header on rate-limited responses
- Added `StreamErrorCode`, the API's error-code registry as named constants over `int`, tolerant of codes the SDK does not know yet
- Added `runApiSafely`, which runs an API call and reports every failure as a `StreamException`
- Added `DisconnectionSource.connectTimeout` and `authenticationFailed`, and `isReconnectable`, whether a connection closed for that reason is worth opening again
- Added `DisconnectionSource.cause`, the error that closed the connection, or `null` when the source carries none
- Added `ConnectUserDetailsRequest.fromUser`, which builds the details a client may send from a `User`
- Added `StreamWebSocketClient.dispose`, which closes the connection along with `events` and `connectionState`; the client is now `Disposable`, and `connect` throws a `StateError` afterwards
- Added `InFlightCache`, which hands concurrent callers asking for the same key the one call already in flight, and its outcome, success or failure alike
- Added `AttachmentUploadTask`, one upload as an object: `state` carries the whole lifecycle including byte progress, `result` settles once and never throws, and `cancel` calls it off at once, settling without waiting to hear what became of the upload — so a `CdnClient` that never answers cannot leave it unsettled
- Added `AttachmentUploadBatch`, which uploads several attachments under a concurrency limit, aggregates byte-weighted progress, and finishes as a sealed `BatchUploadResult` — `BatchUploadCompleted`, `BatchUploadStoppedOnError` or `BatchUploadCancelled` — carrying one outcome per attachment in input order

### 🐛 Bug Fixes

- Fixed `StreamApiError` failing to decode when `details` is not a list of numbers, as a moderation rejection's is; such values read as empty
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
