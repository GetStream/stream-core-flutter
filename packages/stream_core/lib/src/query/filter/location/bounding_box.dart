import 'package:json_annotation/json_annotation.dart';

import 'location_coordinate.dart';

part 'bounding_box.g.dart';

/// A rectangular geographic region for area-based location filtering.
///
/// Defined by northeast and southwest corners. Used for rectangular
/// area queries such as map viewports or city boundaries.
///
/// ```dart
/// final bbox = BoundingBox(
///   northEast: LocationCoordinate(latitude: 37.8324, longitude: -122.3482),
///   southWest: LocationCoordinate(latitude: 37.7079, longitude: -122.5161),
/// );
///
/// final isInside = bbox.contains(point);
/// ```
@JsonSerializable(createFactory: false)
class BoundingBox {
  const BoundingBox({
    required this.northEast,
    required this.southWest,
  });

  /// The northeast corner of this bounding box.
  @JsonKey(includeToJson: false)
  final LocationCoordinate northEast;

  /// The southwest corner of this bounding box.
  @JsonKey(includeToJson: false)
  final LocationCoordinate southWest;

  /// The latitude of the northeast corner.
  @JsonKey(name: 'ne_lat')
  double get neLat => northEast.latitude;

  /// The longitude of the northeast corner.
  @JsonKey(name: 'ne_lng')
  double get neLng => northEast.longitude;

  /// The latitude of the southwest corner.
  @JsonKey(name: 'sw_lat')
  double get swLat => southWest.latitude;

  /// The longitude of the southwest corner.
  @JsonKey(name: 'sw_lng')
  double get swLng => southWest.longitude;

  /// Whether [point] is within this bounding box.
  bool contains(LocationCoordinate point) {
    var withinLatitude = point.latitude <= northEast.latitude;
    withinLatitude &= point.latitude >= southWest.latitude;

    var withinLongitude = point.longitude <= northEast.longitude;
    withinLongitude &= point.longitude >= southWest.longitude;

    return withinLatitude && withinLongitude;
  }

  /// Converts this bounding box to JSON.
  Map<String, dynamic> toJson() => _$BoundingBoxToJson(this);
}
