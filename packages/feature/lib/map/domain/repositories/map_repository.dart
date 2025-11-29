import 'package:core/domain/entities/location_permission_status.dart';
import 'package:core/domain/entities/user_location_entity.dart';

import '../entities/crystallization_area_entity.dart';

/// Repository interface for map-related operations.
///
/// Defines the contract for location services, crystal data access,
/// and permission management.
abstract class MapRepository {
  /// Watch user's current location as a continuous stream.
  ///
  /// Returns a stream of [UserLocationEntity] that emits whenever
  /// the user's location changes significantly.
  Stream<UserLocationEntity> watchUserLocation();

  /// Get all crystallization areas within the specified bounds.
  ///
  /// [minLatitude], [maxLatitude], [minLongitude], [maxLongitude] define
  /// the rectangular bounds to search within.
  Future<List<CrystallizationAreaEntity>> getCrystalsInBounds({
    required double minLatitude,
    required double maxLatitude,
    required double minLongitude,
    required double maxLongitude,
  });

  /// Request location permission from the user.
  ///
  /// Returns the resulting [LocationPermissionStatus] after the request.
  Future<LocationPermissionStatus> requestLocationPermission();

  /// Check current location permission status.
  ///
  /// Returns the current [LocationPermissionStatus] without prompting.
  Future<LocationPermissionStatus> checkLocationPermission();

  /// Check if location services are enabled on the device.
  Future<bool> isLocationServiceEnabled();

  /// Open app settings for the user to change permissions.
  Future<void> openAppSettings();

  /// Get a single location fix (for initial positioning).
  Future<UserLocationEntity> getCurrentLocation();
}
