import 'dart:math' as math;

import 'package:meta/meta.dart';

import 'distance.dart';

/// A geographic coordinate with latitude and longitude.
///
/// Uses the WGS84 coordinate system (same as GPS).
///
/// ```dart
/// const sanFrancisco = LocationCoordinate(
///   latitude: 37.7749,
///   longitude: -122.4194,
/// );
///
/// final distance = sanFrancisco.distanceTo(newYork);
/// print('Distance: ${distance.inKilometers} km');
/// ```
@immutable
class LocationCoordinate {
  const LocationCoordinate({
    required this.latitude,
    required this.longitude,
  });

  /// The latitude in decimal degrees.
  ///
  /// Valid range is -90° (South Pole) to +90° (North Pole).
  final double latitude;

  /// The longitude in decimal degrees.
  ///
  /// Valid range is -180° (West) to +180° (East).
  final double longitude;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LocationCoordinate) return false;

    const epsilon = 1e-7; // ~1cm precision
    final absLatDiff = (latitude - other.latitude).abs();
    final absLngDiff = (longitude - other.longitude).abs();

    return absLatDiff < epsilon && absLngDiff < epsilon;
  }

  @override
  int get hashCode => Object.hash(latitude, longitude);

  /// The distance to [other].
  ///
  /// Uses the Haversine formula, which assumes a spherical Earth
  /// with typical error < 0.5%.
  ///
  /// ```dart
  /// const london = LocationCoordinate(latitude: 51.5074, longitude: -0.1278);
  /// const paris = LocationCoordinate(latitude: 48.8566, longitude: 2.3522);
  ///
  /// final distance = london.distanceTo(paris);
  /// print('Distance: ${distance.inKilometers} km'); // ~343.56 km
  /// ```
  Distance distanceTo(LocationCoordinate other) {
    // If the coordinates are equal, the distance is zero.
    if (this == other) return 0.meters;

    const earthRadius = 6378137.0;

    // Calculate differences in coordinates
    final dLat = _degToRad(other.latitude - latitude);
    final dLon = _degToRad(other.longitude - longitude);

    // Haversine formula components
    final sinDLat = math.sin(dLat / 2);
    final sinDLon = math.sin(dLon / 2);

    // Calculate latitude component: sin²(Δlat/2)
    final latComponent = _square(sinDLat);

    // Calculate longitude component: sin²(Δlon/2) * cos(lat1) * cos(lat2)
    final lonComponent = _square(sinDLon) * math.cos(_degToRad(latitude)) * math.cos(_degToRad(other.latitude));

    // Combine components
    final a = latComponent + lonComponent;

    // Calculate angular distance
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return Distance.fromMeters(earthRadius * c);
  }
}

@pragma('vm:prefer-inline')
double _degToRad(double degree) => degree * math.pi / 180;

@pragma('vm:prefer-inline')
double _square(double value) => value * value;
