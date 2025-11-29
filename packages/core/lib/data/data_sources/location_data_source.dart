import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../../domain/entities/location_permission_status.dart';
import '../../domain/entities/user_location_entity.dart';

/// Data source for location services using Geolocator.
///
/// Provides real-time location tracking with proper permission management.
/// This is a shared data source used across all features that need location data.
abstract class LocationDataSource {
  /// Watch user's current location as a continuous stream.
  /// Make sure to check permissions before calling this.
  Stream<UserLocationEntity> watchUserLocation();

  /// Get a single location fix.
  /// Make sure to check permissions before calling this.
  Future<UserLocationEntity> getCurrentLocation();

  /// Initialize location services and request permission if needed.
  /// Call this when the app starts or when location feature is accessed.
  /// Returns the resulting permission status.
  Future<LocationPermissionStatus> initializeLocation();

  /// Request location permission from the user.
  /// This will show the system permission dialog.
  Future<LocationPermissionStatus> requestLocationPermission();

  /// Check current location permission status without requesting.
  Future<LocationPermissionStatus> checkLocationPermission();

  /// Check if location services are enabled on the device.
  Future<bool> isLocationServiceEnabled();

  /// Open app settings for the user to change permissions.
  /// Use this when permission is permanently denied.
  Future<bool> openAppSettings();

  /// Open location settings for the user to enable location services.
  /// Use this when location services are disabled on device.
  Future<bool> openLocationSettings();

  /// Dispose of resources (streams, subscriptions, etc.)
  void dispose();
}

/// Implementation of LocationDataSource using Geolocator package.
/// Provides comprehensive permission handling and error management.
class LocationDataSourceImpl implements LocationDataSource {
  LocationDataSourceImpl({
    this.enableHighAccuracy = true,
    this.distanceFilterMeters = 5,
  });

  /// Whether to use high accuracy mode (GPS + network)
  final bool enableHighAccuracy;

  /// Minimum distance (in meters) before location updates are triggered
  final int distanceFilterMeters;

  StreamController<UserLocationEntity>? _locationController;
  StreamSubscription<Position>? _positionSubscription;
  bool _isDisposed = false;

  /// Location settings for high accuracy tracking
  LocationSettings get _highAccuracySettings => LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilterMeters,
      );

  /// Location settings for battery-saving mode
  LocationSettings get _lowPowerSettings => const LocationSettings(
        accuracy: LocationAccuracy.low,
        distanceFilter: 50,
      );

  /// Get the appropriate location settings based on configuration
  LocationSettings get _locationSettings =>
      enableHighAccuracy ? _highAccuracySettings : _lowPowerSettings;

  @override
  Future<LocationPermissionStatus> initializeLocation() async {
    debugPrint('[LocationDataSource] initializeLocation called');

    // Step 1: Check if location services are enabled on device
    final serviceEnabled = await isLocationServiceEnabled();
    debugPrint(
        '[LocationDataSource] Location service enabled: $serviceEnabled');
    if (!serviceEnabled) {
      debugPrint('[LocationDataSource] Returning serviceDisabled');
      return LocationPermissionStatus.serviceDisabled;
    }

    // Step 2: Check current permission status
    var permission = await Geolocator.checkPermission();
    debugPrint('[LocationDataSource] Current permission: $permission');

    // Step 3: If not granted yet, request permission
    // Request for: denied, unableToDetermine
    // Don't request for: deniedForever (need to go to settings)
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.unableToDetermine) {
      debugPrint('[LocationDataSource] Requesting permission...');
      try {
        permission = await Geolocator.requestPermission();
        debugPrint(
            '[LocationDataSource] Permission after request: $permission');
      } catch (e) {
        debugPrint('[LocationDataSource] Error requesting permission: $e');
        // If request fails, return current status
        return _convertPermission(permission);
      }
    }

    final result = _convertPermission(permission);
    debugPrint('[LocationDataSource] Returning: $result');
    return result;
  }

  @override
  Stream<UserLocationEntity> watchUserLocation() {
    if (_isDisposed) {
      throw StateError('LocationDataSource has been disposed');
    }

    // Create a broadcast controller if not exists
    _locationController ??= StreamController<UserLocationEntity>.broadcast(
      onCancel: () {
        _positionSubscription?.cancel();
        _positionSubscription = null;
      },
    );

    // Start listening to position updates
    _startPositionStream();

    return _locationController!.stream;
  }

  void _startPositionStream() {
    // Cancel existing subscription if any
    _positionSubscription?.cancel();

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: _locationSettings,
    ).listen(
      (position) {
        if (!_isDisposed && _locationController != null) {
          _locationController!.add(_positionToEntity(position));
        }
      },
      onError: (error) {
        if (!_isDisposed && _locationController != null) {
          _locationController!.addError(
            LocationException(
              message: 'Failed to get location: $error',
              cause: error,
            ),
          );
        }
      },
    );
  }

  @override
  Future<UserLocationEntity> getCurrentLocation() async {
    if (_isDisposed) {
      throw StateError('LocationDataSource has been disposed');
    }

    try {
      // First check service and permission
      final status = await checkLocationPermission();
      if (!status.canUseLocation) {
        throw LocationException(
          message: 'Location permission not granted: $status',
          permissionStatus: status,
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: _locationSettings,
      );
      return _positionToEntity(position);
    } on LocationServiceDisabledException {
      throw const LocationException(
        message: 'Location services are disabled',
        permissionStatus: LocationPermissionStatus.serviceDisabled,
      );
    } on PermissionDeniedException catch (e) {
      throw LocationException(
        message: 'Location permission denied: ${e.message}',
        permissionStatus: LocationPermissionStatus.denied,
      );
    } catch (e) {
      if (e is LocationException) rethrow;
      throw LocationException(
        message: 'Failed to get current location: $e',
        cause: e,
      );
    }
  }

  @override
  Future<LocationPermissionStatus> requestLocationPermission() async {
    // First check if location services are enabled
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermissionStatus.serviceDisabled;
    }

    // Check current status
    var permission = await Geolocator.checkPermission();

    // Only request if not already granted or permanently denied
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return _convertPermission(permission);
  }

  @override
  Future<LocationPermissionStatus> checkLocationPermission() async {
    // First check if location services are enabled
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermissionStatus.serviceDisabled;
    }

    final permission = await Geolocator.checkPermission();
    return _convertPermission(permission);
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  @override
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  @override
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Convert Geolocator Position to UserLocationEntity
  UserLocationEntity _positionToEntity(Position position) {
    return UserLocationEntity(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      timestamp: position.timestamp,
      heading: position.heading,
      speed: position.speed,
      altitude: position.altitude,
    );
  }

  /// Convert Geolocator LocationPermission to our LocationPermissionStatus
  LocationPermissionStatus _convertPermission(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.denied:
        return LocationPermissionStatus.denied;
      case LocationPermission.deniedForever:
        return LocationPermissionStatus.permanentlyDenied;
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        return LocationPermissionStatus.granted;
      case LocationPermission.unableToDetermine:
        return LocationPermissionStatus.notDetermined;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _locationController?.close();
    _locationController = null;
  }
}

/// Mock implementation for testing without actual GPS.
class MockLocationDataSource implements LocationDataSource {
  MockLocationDataSource({
    this.mockLatitude = 35.6812,
    this.mockLongitude = 139.7671,
    this.mockPermissionStatus = LocationPermissionStatus.granted,
    this.mockServiceEnabled = true,
  });

  final double mockLatitude;
  final double mockLongitude;
  final LocationPermissionStatus mockPermissionStatus;
  final bool mockServiceEnabled;

  final StreamController<UserLocationEntity> _locationController =
      StreamController<UserLocationEntity>.broadcast();
  bool _isDisposed = false;

  @override
  Future<LocationPermissionStatus> initializeLocation() async {
    if (!mockServiceEnabled) {
      return LocationPermissionStatus.serviceDisabled;
    }
    return mockPermissionStatus;
  }

  @override
  Stream<UserLocationEntity> watchUserLocation() {
    if (_isDisposed) {
      throw StateError('MockLocationDataSource has been disposed');
    }

    // Emit initial mock location after a short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!_isDisposed) {
        _locationController.add(
          UserLocationEntity(
            latitude: mockLatitude,
            longitude: mockLongitude,
            accuracy: 10.0,
            timestamp: DateTime.now(),
          ),
        );
      }
    });
    return _locationController.stream;
  }

  @override
  Future<UserLocationEntity> getCurrentLocation() async {
    if (_isDisposed) {
      throw StateError('MockLocationDataSource has been disposed');
    }

    if (!mockServiceEnabled) {
      throw const LocationException(
        message: 'Location services are disabled',
        permissionStatus: LocationPermissionStatus.serviceDisabled,
      );
    }

    if (!mockPermissionStatus.canUseLocation) {
      throw LocationException(
        message: 'Location permission not granted',
        permissionStatus: mockPermissionStatus,
      );
    }

    return UserLocationEntity(
      latitude: mockLatitude,
      longitude: mockLongitude,
      accuracy: 10.0,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<LocationPermissionStatus> requestLocationPermission() async {
    return mockPermissionStatus;
  }

  @override
  Future<LocationPermissionStatus> checkLocationPermission() async {
    if (!mockServiceEnabled) {
      return LocationPermissionStatus.serviceDisabled;
    }
    return mockPermissionStatus;
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    return mockServiceEnabled;
  }

  @override
  Future<bool> openAppSettings() async {
    return true;
  }

  @override
  Future<bool> openLocationSettings() async {
    return true;
  }

  /// Simulate location update (for testing proximity detection)
  void simulateLocationUpdate(
    double latitude,
    double longitude, {
    double accuracy = 10.0,
    double? heading,
    double? speed,
  }) {
    if (!_isDisposed) {
      _locationController.add(
        UserLocationEntity(
          latitude: latitude,
          longitude: longitude,
          accuracy: accuracy,
          timestamp: DateTime.now(),
          heading: heading,
          speed: speed,
        ),
      );
    }
  }

  /// Simulate location error (for testing error handling)
  void simulateError(Object error) {
    if (!_isDisposed) {
      _locationController.addError(error);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _locationController.close();
  }
}

/// Exception thrown when location operations fail.
class LocationException implements Exception {
  const LocationException({
    required this.message,
    this.permissionStatus,
    this.cause,
  });

  final String message;
  final LocationPermissionStatus? permissionStatus;
  final Object? cause;

  @override
  String toString() {
    var result = 'LocationException: $message';
    if (permissionStatus != null) {
      result += ' (status: $permissionStatus)';
    }
    if (cause != null) {
      result += '\nCaused by: $cause';
    }
    return result;
  }
}
