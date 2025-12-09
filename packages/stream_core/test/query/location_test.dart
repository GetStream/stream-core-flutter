import 'package:stream_core/stream_core.dart';
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

    test('should support equality comparison', () {
      const location1 = LocationCoordinate(
        latitude: 37.7749,
        longitude: -122.4194,
      );
      const location2 = LocationCoordinate(
        latitude: 37.7749,
        longitude: -122.4194,
      );
      const location3 = LocationCoordinate(
        latitude: 40.7128,
        longitude: -74.0060,
      );

      expect(location1, equals(location2));
      expect(location1, isNot(equals(location3)));
      expect(location1.hashCode, equals(location2.hashCode));
    });

    test('should consider near-equal coordinates as equal', () {
      const location1 = LocationCoordinate(
        latitude: 37.7749,
        longitude: -122.4194,
      );

      // Coordinates differ by less than epsilon (~1cm)
      const location2 = LocationCoordinate(
        latitude: 37.77490000001,
        longitude: -122.41940000001,
      );

      // Coordinates differ by more than epsilon
      const location3 = LocationCoordinate(
        latitude: 37.7749001,
        longitude: -122.4194001,
      );

      expect(location1, equals(location2));
      expect(location1, isNot(equals(location3)));
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
