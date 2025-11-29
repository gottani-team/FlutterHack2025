import 'dart:async';
import 'dart:math' as math;

import 'package:core/data/data_sources/location_data_source.dart';
import 'package:core/domain/services/haptic_service.dart';
import 'package:core/presentation/utils/audio_player_service.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/data_sources/crystal_mock_data_source.dart';
import '../../domain/entities/crystallization_area_entity.dart';
import '../../domain/usecases/scan_crystals_usecase.dart';
import '../providers/map_providers.dart';
import '../state/map_view_state.dart';

part 'map_view_model.g.dart';

/// ViewModel for the Map View screen.
///
/// Manages the state and business logic for:
/// - User location tracking
/// - Crystal proximity detection
/// - Sensory feedback coordination (visual, haptic, audio)
/// - Map interactions
@riverpod
class MapViewModel extends _$MapViewModel {
  Timer? _pulseAnimationTimer;
  StreamSubscription<UserLocationEntity>? _locationSubscription;

  // Sensory feedback services
  final HapticService _hapticService = HapticService.instance;
  final AudioPlayerService _audioService = AudioPlayerService.instance;

  // Use cases
  final ScanCrystalsUseCase _scanCrystalsUseCase = ScanCrystalsUseCase();

  // Location data source (injected via provider)
  LocationDataSource get _locationDataSource =>
      ref.read(locationDataSourceProvider);

  @override
  MapViewState build() {
    // Initialize audio service
    _audioService.initialize();

    // Cleanup resources when provider is disposed
    ref.onDispose(() {
      _locationSubscription?.cancel();
      _pulseAnimationTimer?.cancel();
    });

    return const MapViewState();
  }

  /// Request location permission from the user
  Future<void> requestLocationPermission() async {
    debugPrint('[MapViewModel] requestLocationPermission called');

    // Set requesting state
    state = state.copyWith(
      permissionStatus: LocationPermissionStatus.requesting,
    );

    try {
      // Check current permission status first
      final currentStatus = await _locationDataSource.checkLocationPermission();
      debugPrint('[MapViewModel] Current permission status: $currentStatus');

      // Use initializeLocation for comprehensive permission handling
      debugPrint('[MapViewModel] Calling initializeLocation...');
      final permissionStatus = await _locationDataSource.initializeLocation();
      debugPrint(
        '[MapViewModel] initializeLocation returned: $permissionStatus',
      );

      state = state.copyWith(permissionStatus: permissionStatus);

      // Handle various permission states
      switch (permissionStatus) {
        case LocationPermissionStatus.granted:
          debugPrint(
            '[MapViewModel] Permission granted, starting location tracking',
          );
          // Start location tracking after permission granted
          await startLocationTracking();
        case LocationPermissionStatus.serviceDisabled:
          debugPrint('[MapViewModel] Location service disabled');
          state = state.copyWith(
            errorMessage: permissionStatus.userMessage,
          );
        case LocationPermissionStatus.permanentlyDenied:
          debugPrint('[MapViewModel] Permission permanently denied');
          state = state.copyWith(
            errorMessage: permissionStatus.userMessage,
          );
        case LocationPermissionStatus.denied:
          debugPrint('[MapViewModel] Permission denied');
          state = state.copyWith(
            errorMessage: permissionStatus.userMessage,
          );
        case LocationPermissionStatus.notDetermined:
        case LocationPermissionStatus.requesting:
          debugPrint('[MapViewModel] Unexpected status: $permissionStatus');
          // Should not reach here normally
          break;
      }
    } catch (e, stackTrace) {
      debugPrint('[MapViewModel] Error requesting permission: $e');
      debugPrint('[MapViewModel] StackTrace: $stackTrace');
      state = state.copyWith(
        permissionStatus: LocationPermissionStatus.denied,
        errorMessage: '位置情報の許可取得中にエラーが発生しました: $e',
      );
    }
  }

  /// Start continuous location tracking
  Future<void> startLocationTracking() async {
    // Check if permission is granted using extension method
    if (!state.permissionStatus.canUseLocation) {
      state = state.copyWith(
        errorMessage: state.permissionStatus.userMessage,
      );
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      // Cancel any existing subscription
      await _locationSubscription?.cancel();

      // Get initial location
      final initialLocation = await _locationDataSource.getCurrentLocation();
      _updateUserLocation(initialLocation);

      // Subscribe to location updates stream
      _locationSubscription = _locationDataSource.watchUserLocation().listen(
        (location) {
          _updateUserLocation(location);
        },
        onError: (error) {
          // Handle LocationException specifically
          if (error is LocationException) {
            state = state.copyWith(
              errorMessage: error.message,
              isLoading: false,
            );
            if (error.permissionStatus != null) {
              state = state.copyWith(
                permissionStatus: error.permissionStatus!,
              );
            }
          } else {
            state = state.copyWith(
              errorMessage: '位置情報の取得中にエラーが発生しました: $error',
              isLoading: false,
            );
          }
        },
      );

      state = state.copyWith(isLoading: false);
    } on LocationException catch (e) {
      state = state.copyWith(
        errorMessage: e.message,
        isLoading: false,
      );
      if (e.permissionStatus != null) {
        state = state.copyWith(permissionStatus: e.permissionStatus!);
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: '位置情報追跡の開始に失敗しました: $e',
        isLoading: false,
      );
    }
  }

  /// Stop location tracking (for battery conservation)
  void stopLocationTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  /// Handle new location update from GPS
  void _updateUserLocation(UserLocationEntity location) {
    final updatedLocation = UserLocationEntity(
      latitude: location.latitude,
      longitude: location.longitude,
      accuracy: location.accuracy,
      timestamp: DateTime.now(),
      heading: location.heading,
      speed: location.speed,
    );

    // Determine GPS accuracy level
    final accuracyLevel = _calculateAccuracyLevel(location.accuracy);

    state = state.copyWith(
      userLocation: updatedLocation,
      gpsAccuracyLevel: accuracyLevel,
    );

    // Update map center if following user
    if (state.isFollowingUser) {
      state = state.copyWith(
        mapCenterLatitude: location.latitude,
        mapCenterLongitude: location.longitude,
      );
    }

    // Check proximity to crystals
    _checkCrystalProximity();
  }

  /// Calculate GPS accuracy level for warning display
  GpsAccuracyLevel _calculateAccuracyLevel(double accuracy) {
    if (accuracy <= 20.0) {
      return GpsAccuracyLevel.good;
    } else if (accuracy <= 50.0) {
      return GpsAccuracyLevel.acceptable;
    } else {
      return GpsAccuracyLevel.poor;
    }
  }

  /// Load crystallization areas visible in the current map viewport
  Future<void> loadVisibleCrystallizationAreas() async {
    state = state.copyWith(isLoading: true);

    try {
      // Use mock data source (Firestore integration is out of scope)
      final mockDataSource = CrystalMockDataSource.instance;

      // Calculate bounding box from current map center (approximately 1km radius)
      final centerLat = state.mapCenterLatitude ?? 35.6812;
      final centerLon = state.mapCenterLongitude ?? 139.7671;
      const kmPerDegree = 111.32;
      const radiusKm = 1.0;
      final latDelta = radiusKm / kmPerDegree;
      final lonDelta =
          radiusKm / (kmPerDegree * math.cos(centerLat * math.pi / 180));

      final areas = mockDataSource.getCrystallizationAreas(
        minLatitude: centerLat - latDelta,
        maxLatitude: centerLat + latDelta,
        minLongitude: centerLon - lonDelta,
        maxLongitude: centerLon + lonDelta,
      );

      state = state.copyWith(
        visibleCrystallizationAreas: areas,
        isLoading: false,
      );

      // Check proximity after loading
      _checkCrystalProximity();
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to load crystals: $e',
        isLoading: false,
      );
    }
  }

  /// Scan visible bounds and generate random crystals
  ///
  /// [minLat], [maxLat], [minLng], [maxLng] define the visible bounding box.
  /// Returns the generated crystals and updates state.
  List<CrystallizationAreaEntity> scanVisibleArea({
    required double minLat,
    required double maxLat,
    required double minLng,
    required double maxLng,
  }) {
    debugPrint('[MapViewModel] Scanning area: '
        'lat($minLat - $maxLat), lng($minLng - $maxLng)');

    // Generate random crystals in the visible area
    final crystals = _scanCrystalsUseCase.execute(
      minLat: minLat,
      maxLat: maxLat,
      minLng: minLng,
      maxLng: maxLng,
    );

    debugPrint('[MapViewModel] Generated ${crystals.length} crystals');

    // Merge with existing crystals (avoid duplicates based on ID)
    final existingIds =
        state.visibleCrystallizationAreas.map((c) => c.crystalId).toSet();
    final newCrystals =
        crystals.where((c) => !existingIds.contains(c.crystalId)).toList();

    final allCrystals = [
      ...state.visibleCrystallizationAreas,
      ...newCrystals,
    ];

    state = state.copyWith(
      visibleCrystallizationAreas: allCrystals,
    );

    // Check proximity after adding new crystals
    _checkCrystalProximity();

    return newCrystals;
  }

  /// Clear all crystals and rescan the visible area
  List<CrystallizationAreaEntity> rescanVisibleArea({
    required double minLat,
    required double maxLat,
    required double minLng,
    required double maxLng,
  }) {
    // Clear existing crystals
    state = state.copyWith(
      visibleCrystallizationAreas: [],
    );

    // Scan and generate new crystals
    return scanVisibleArea(
      minLat: minLat,
      maxLat: maxLat,
      minLng: minLng,
      maxLng: maxLng,
    );
  }

  /// Check proximity to all visible crystals and update feedback state
  void _checkCrystalProximity() {
    final userLocation = state.userLocation;
    if (userLocation == null) return;

    CrystallizationAreaEntity? closestCrystal;
    double? closestDistance;

    for (final area in state.visibleCrystallizationAreas) {
      final distance = _calculateDistance(
        userLocation.latitude,
        userLocation.longitude,
        area.approximateLatitude,
        area.approximateLongitude,
      );

      if (closestDistance == null || distance < closestDistance) {
        closestDistance = distance;
        closestCrystal = area;
      }
    }

    // Determine proximity phase based on distance
    ProximityPhase phase = ProximityPhase.none;
    double pulseIntensity = 0.0;

    if (closestDistance != null && closestCrystal != null) {
      if (closestDistance <= CrystallizationAreaEntity.innerDetectionRadius) {
        // Within 25m - ready to mine
        phase = ProximityPhase.imminent;
        pulseIntensity = 1.0;
        _triggerMiningTransition(closestCrystal);
      } else if (closestDistance <=
          CrystallizationAreaEntity.outerDetectionRadius) {
        // Within 100m - heartbeat phase
        phase = ProximityPhase.heartbeat;
        // Calculate intensity: closer = more intense (linear interpolation)
        pulseIntensity = 1.0 -
            ((closestDistance -
                    CrystallizationAreaEntity.innerDetectionRadius) /
                (CrystallizationAreaEntity.outerDetectionRadius -
                    CrystallizationAreaEntity.innerDetectionRadius));
        _startHeartbeatFeedback(pulseIntensity);
      } else {
        _stopHeartbeatFeedback();
      }
    } else {
      _stopHeartbeatFeedback();
    }

    state = state.copyWith(
      proximityPhase: phase,
      approachingCrystal: closestCrystal,
      distanceToClosestCrystal: closestDistance,
      pulseIntensity: pulseIntensity,
    );
  }

  /// Calculate distance between two coordinates using Haversine formula
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371000.0; // meters

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * math.pi / 180;

  /// Start heartbeat visual and haptic feedback
  void _startHeartbeatFeedback(double intensity) {
    // Calculate pulse interval: faster as you get closer
    // 100m = ~1500ms interval, 25m = ~500ms interval
    final intervalMs = (1500 - (intensity * 1000)).round();

    _pulseAnimationTimer?.cancel();
    _pulseAnimationTimer = Timer.periodic(
      Duration(milliseconds: intervalMs),
      (_) {
        _triggerPulse();
      },
    );
  }

  /// Stop heartbeat feedback
  void _stopHeartbeatFeedback() {
    _pulseAnimationTimer?.cancel();
    _pulseAnimationTimer = null;
    state = state.copyWith(
      isHapticActive: false,
      pulseIntensity: 0.0,
    );
  }

  /// Trigger a single pulse (visual + haptic + audio synchronized)
  void _triggerPulse() {
    final intensity = state.pulseIntensity;

    // Trigger haptic feedback with intensity-based strength
    _hapticService.pulseWithIntensity(intensity);

    // Trigger resonance sound effect with intensity-based volume
    _audioService.playResonance(intensity: intensity);

    // Update visual state
    state = state.copyWith(isHapticActive: true);

    // Reset haptic state after brief delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (state.isHapticActive) {
        state = state.copyWith(isHapticActive: false);
      }
    });
  }

  /// Trigger transition to mining screen when user is close enough
  void _triggerMiningTransition(CrystallizationAreaEntity crystal) {
    _stopHeartbeatFeedback();

    // TODO: Navigate to mining screen with crystal data
    // This will be handled by the View layer observing state changes
  }

  /// Handle map camera movement (user panning/zooming)
  void onMapCameraMoved({
    required double latitude,
    required double longitude,
    required double zoomLevel,
  }) {
    state = state.copyWith(
      mapCenterLatitude: latitude,
      mapCenterLongitude: longitude,
      mapZoomLevel: zoomLevel,
      isFollowingUser: false, // User manually moved map
    );

    // Reload crystals for new viewport
    loadVisibleCrystallizationAreas();
  }

  /// Re-center map on user location
  void recenterOnUser() {
    final userLocation = state.userLocation;
    if (userLocation != null) {
      state = state.copyWith(
        mapCenterLatitude: userLocation.latitude,
        mapCenterLongitude: userLocation.longitude,
        isFollowingUser: true,
      );
    }
  }

  /// Handle app lifecycle changes (background/foreground)
  void onAppLifecycleChanged({required bool isBackground}) {
    state = state.copyWith(isBackgroundMode: isBackground);

    if (isBackground) {
      // Reduce update frequency in background
      // TODO: Implement background location updates with reduced frequency
    } else {
      // Resume normal tracking
      startLocationTracking();
    }
  }

  /// Clear any error messages
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Open app settings for user to change permissions
  Future<void> openAppSettings() async {
    await _locationDataSource.openAppSettings();
  }

  /// Open location settings for user to enable GPS
  Future<void> openLocationSettings() async {
    await _locationDataSource.openLocationSettings();
  }
}
