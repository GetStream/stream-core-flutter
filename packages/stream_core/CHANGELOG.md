## Upcoming

### 💥 BREAKING CHANGES

- Removed the `userId` parameter from `UserToken.anonymous`, anonymous tokens always use `User.anonymousUserId`
- Removed the `TokenManager.tokenProvider` setter, use `setTokenProvider` instead
- `TokenManager.userId` is now nullable, and is `null` until an identity is configured

### ✨ Features

- Added `TokenManager.setTokenProvider`, which points an existing manager at another user and expires the cached token
- Added optional `onTokenUpdated` callback to `TokenManager`, invoked after every successful token load
- Added optional `rawValue` to `UserToken.anonymous`, so an anonymous token can carry a JWT granting restricted access, provided its `user_id` claim is `User.anonymousUserId` (`!anon`), which the server also requires
- Added `User.anonymousUserId`, the id every anonymous user has
- Added `TokenManager.unconfigured`, for a client that exists before its user does
- Added `TokenManager.reset`, which drops the configured identity and its cached token
- Added `teams` field to `User` class

### 🐛 Bug Fixes

- Fixed `TokenManager.getToken()` contacting the `TokenProvider` on every call instead of returning the cached token
- Fixed `DynamicTokenProvider` accepting a token issued for a different user than the one requested
- Fixed `TokenManager` caching a token that finished loading after `expireToken` or `setTokenProvider` had invalidated it

### 🔄 Changed

- Raised the minimum Dart SDK to `^3.12.0`
- `User` now asserts that a user of type `UserType.anonymous` carries `User.anonymousUserId` as its id
- Anonymous requests now always send `user_id=!anon`. The value previously came from the `TokenManager`, so it was whatever the caller configured; the server requires the claim to be `!anon` and derives the anonymous session itself, so the parameter now matches
- `DynamicTokenProvider` checks the token type before its user id, so a token of the wrong type is reported as such instead of as a mismatched user
- `TokenManager.setTokenProvider` does nothing when handed the identity it already has, instead of expiring the cached token
- `TokenManager.getToken` fails when `reset` runs while the token is loading, instead of returning a token for a user the manager no longer has. A `setTokenProvider` during a load still serves the caller that started it
- `TokenManager.getToken` rejects a token whose `user_id` is not the user it was loading for, which a custom `TokenProvider` is not obliged to check itself
- `AuthInterceptor` no longer attempts a token refresh when the manager has no identity, so the original token-expired error is surfaced rather than a failure to load a token

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
