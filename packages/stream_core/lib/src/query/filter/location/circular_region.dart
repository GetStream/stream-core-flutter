import 'package:json_annotation/json_annotation.dart';

import 'distance.dart';
import 'location_coordinate.dart';

part 'circular_region.g.dart';

/// A circular geographic region for proximity-based location filtering.
///
/// Defined by a center point and radius. Used for geofencing and
/// "near" location queries.
///
/// ```dart
/// final region = CircularRegion(
///   radius: 5.kilometers,
///   center: LocationCoordinate(latitude: 37.7749, longitude: -122.4194),
/// );
///
/// final isInside = region.contains(point);
/// ```
@JsonSerializable(createFactory: false)
class CircularRegion {
  const CircularRegion({
    required this.radius,
    required this.center,
  });

  /// The radius of this circular region.
  @JsonKey(includeToJson: false)
  final Distance radius;

  /// The center coordinate of this circular region.
  @JsonKey(includeToJson: false)
  final LocationCoordinate center;

  /// The latitude of the center point.
  @JsonKey(name: 'lat')
  double get lat => center.latitude;

  /// The longitude of the center point.
  @JsonKey(name: 'lng')
  double get lng => center.longitude;

  /// The radius in kilometers.
  @JsonKey(name: 'distance')
  double get distance => radius.inKilometers;

  /// Whether [point] is within this circular region.
  bool contains(LocationCoordinate point) {
    final distance = center.distanceTo(point);
    return distance <= radius;
  }

  /// Converts this circular region to JSON.
  Map<String, dynamic> toJson() => _$CircularRegionToJson(this);
}
