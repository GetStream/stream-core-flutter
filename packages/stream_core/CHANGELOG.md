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
