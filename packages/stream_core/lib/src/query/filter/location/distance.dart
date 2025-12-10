/// A distance value with convenient unit conversions.
///
/// ```dart
/// final distance1 = 1000.meters;  // 1000 meters
/// final distance2 = 5.kilometers; // 5000 meters
/// print(distance1.inKilometers);  // 1.0
/// ```
extension type const Distance._(double meters) implements double {
  /// Creates a [Distance] from [meters].
  const Distance.fromMeters(double meters) : this._(meters);

  /// The distance in kilometers.
  double get inKilometers => meters / 1000;
}

/// Extension methods on [num] for creating [Distance] values.
extension DistanceExtension on num {
  /// This value as a [Distance] in meters.
  Distance get meters => Distance.fromMeters(toDouble());

  /// This value as a [Distance] in kilometers.
  Distance get kilometers => Distance.fromMeters(toDouble() * 1000);
}
