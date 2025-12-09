import 'package:stream_core/src/query/filter/location/bounding_box.dart';
import 'package:stream_core/src/query/filter/location/circular_region.dart';
import 'package:stream_core/src/query/filter/location/distance.dart';
import 'package:stream_core/src/query/filter/location/location_coordinate.dart';
import 'package:test/test.dart';

void main() {
  group('LocationCoordinate', () {
    test('should calculate distance accurately', () {
      const sanFrancisco = LocationCoordinate(
        latitude: 37.7749,
        longitude: -122.4194,
      );

      const newYork = LocationCoordinate(
        latitude: 40.7128,
        longitude: -74.0060,
      );

      final distance = sanFrancisco.distanceTo(newYork);

      // Allow 1% error margin for Haversine approximation
      const expectedDistance = 4130000; // ~4130 km
      expect(distance, closeTo(expectedDistance, expectedDistance * 0.01));
    });

    test('should return zero distance for identical coordinates', () {
      const location = LocationCoordinate(
        latitude: 37.7749,
        longitude: -122.4194,
      );

      final distance = location.distanceTo(location);
      expect(distance, equals(0.meters));
    });
  });

  group('Distance', () {
    test('should convert between meters and kilometers', () {
      final distance = 5.kilometers;
      expect(distance, equals(5000.0));
      expect(distance.inKilometers, equals(5.0));
    });
  });

  group('CircularRegion', () {
    test('should contain point within radius', () {
      const center = LocationCoordinate(
        latitude: 37.7749,
        longitude: -122.4194,
      );

      final region = CircularRegion(
        radius: 10.kilometers,
        center: center,
      );

      const nearbyPoint = LocationCoordinate(
        latitude: 37.8149,
        longitude: -122.4594,
      );
      expect(region.contains(nearbyPoint), isTrue);

      const farPoint = LocationCoordinate(
        latitude: 40.7128,
        longitude: -74.0060,
      );
      expect(region.contains(farPoint), isFalse);
    });

    test('should serialize to JSON correctly', () {
      const center = LocationCoordinate(
        latitude: 37.7749,
        longitude: -122.4194,
      );

      final region = CircularRegion(radius: 5.kilometers, center: center);

      expect(region.toJson(), {
        'lat': 37.7749,
        'lng': -122.4194,
        'distance': 5.0,
      });
    });
  });

  group('BoundingBox', () {
    test('should contain point within bounds', () {
      const bbox = BoundingBox(
        northEast: LocationCoordinate(latitude: 38, longitude: -122),
        southWest: LocationCoordinate(latitude: 37, longitude: -123),
      );

      const insidePoint = LocationCoordinate(
        latitude: 37.5,
        longitude: -122.5,
      );
      expect(bbox.contains(insidePoint), isTrue);

      const outsidePoint = LocationCoordinate(
        latitude: 38.1,
        longitude: -122.5,
      );
      expect(bbox.contains(outsidePoint), isFalse);
    });

    test('should serialize to JSON correctly', () {
      const bbox = BoundingBox(
        northEast: LocationCoordinate(latitude: 37.8324, longitude: -122.3482),
        southWest: LocationCoordinate(latitude: 37.7079, longitude: -122.5161),
      );

      expect(bbox.toJson(), {
        'ne_lat': 37.8324,
        'ne_lng': -122.3482,
        'sw_lat': 37.7079,
        'sw_lng': -122.5161,
      });
    });
  });
}
