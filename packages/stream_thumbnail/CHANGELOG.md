## Upcoming

### 🐛 Bug Fixes

- A failed thumbnail generation now completes with a `PlatformException` instead of a cast error. iOS reports failure by
  returning no data, which previously surfaced as a `TypeError` about an internal cast.

### 🔄 Changed

- Raised the minimum Flutter version to `>=3.44.0` and the Dart SDK to `^3.12.0`.

## 0.1.0

* Initial release.
