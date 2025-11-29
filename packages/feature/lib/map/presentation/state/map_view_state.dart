import 'package:core/domain/entities/location_permission_status.dart';
import 'package:core/domain/entities/user_location_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/crystal_entity.dart';
import '../../domain/entities/crystallization_area_entity.dart';

// Re-export for convenience
export 'package:core/domain/entities/location_permission_status.dart';
export 'package:core/domain/entities/user_location_entity.dart';

part 'map_view_state.freezed.dart';

/// Proximity phase determining the current sensory feedback level
enum ProximityPhase {
  /// No crystal within detection range
  none,

  /// User is within 100m-25m of a crystal - heartbeat phase active
  heartbeat,

  /// User is within 25m of a crystal - ready for mining
  imminent,
}

/// GPS accuracy warning level
enum GpsAccuracyLevel {
  /// Accuracy is good (<20m)
  good,

  /// Accuracy is acceptable (20-50m)
  acceptable,

  /// Accuracy is poor (>50m) - should warn user
  poor,
}

/// Immutable state for the Map View.
///
/// This state represents all the data needed to render the map screen
/// including user location, nearby crystals, and proximity feedback state.
@freezed
sealed class MapViewState with _$MapViewState {
  const factory MapViewState({
    /// Current user location, null if not yet acquired
    UserLocationEntity? userLocation,

    /// Location permission status
    @Default(LocationPermissionStatus.notDetermined)
    LocationPermissionStatus permissionStatus,

    /// GPS accuracy level for warning display
    @Default(GpsAccuracyLevel.good) GpsAccuracyLevel gpsAccuracyLevel,

    /// List of crystallization areas visible on the map
    @Default([]) List<CrystallizationAreaEntity> visibleCrystallizationAreas,

    /// Current proximity detection phase
    @Default(ProximityPhase.none) ProximityPhase proximityPhase,

    /// The closest crystal being approached, null if none in range
    CrystallizationAreaEntity? approachingCrystal,

    /// Distance to the closest crystal in meters, null if none in range
    double? distanceToClosestCrystal,

    /// Pulse intensity for heartbeat effect (0.0 to 1.0)
    @Default(0.0) double pulseIntensity,

    /// Whether haptic feedback is currently active
    @Default(false) bool isHapticActive,

    /// Whether map is currently loading
    @Default(true) bool isLoading,

    /// Error message if any operation failed
    String? errorMessage,

    /// Whether the app is in background mode
    @Default(false) bool isBackgroundMode,

    /// Map camera center latitude
    double? mapCenterLatitude,

    /// Map camera center longitude
    double? mapCenterLongitude,

    /// Map camera zoom level (17+ for 3D buildings to be visible)
    @Default(17.5) double mapZoomLevel,

    /// Whether map is following user location
    @Default(true) bool isFollowingUser,
  }) = _MapViewState;

  const MapViewState._();

  /// Check if user has granted location permission
  bool get hasLocationPermission => permissionStatus.canUseLocation;

  /// Check if there's a crystal in proximity range
  bool get hasCrystalInRange => proximityPhase != ProximityPhase.none;

  /// Check if user is close enough to mine
  bool get canMine => proximityPhase == ProximityPhase.imminent;

  /// Get the emotion color for the approaching crystal
  int? get approachingCrystalColor =>
      approachingCrystal?.emotionType.colorValue;

  /// Check if GPS warning should be shown
  bool get shouldShowGpsWarning => gpsAccuracyLevel == GpsAccuracyLevel.poor;
}
