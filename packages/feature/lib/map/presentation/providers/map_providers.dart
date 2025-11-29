import 'package:core/data/data_sources/location_data_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/data_sources/crystal_mock_data_source.dart';
import '../../data/repositories/map_repository_impl.dart';
import '../../domain/entities/crystallization_area_entity.dart';
import '../../domain/repositories/map_repository.dart';
import '../state/map_view_state.dart';
import '../view_model/map_view_model.dart';

// Re-export the generated provider from map_view_model.dart
export '../view_model/map_view_model.dart';

// ============================================================================
// Data Source Providers
// ============================================================================

/// Flag to control whether to use real GPS or mock location
/// Set to true for real device testing, false for simulator/development
const bool kUseRealGps = true;

/// Provider for LocationDataSource
/// Uses LocationDataSourceImpl for real GPS, MockLocationDataSource for development
final locationDataSourceProvider = Provider<LocationDataSource>((ref) {
  if (kUseRealGps) {
    return LocationDataSourceImpl();
  }
  return MockLocationDataSource();
});

/// Provider for CrystalMockDataSource
final crystalDataSourceProvider = Provider<CrystalMockDataSource>((ref) {
  return CrystalMockDataSource.instance;
});

// ============================================================================
// Repository Providers
// ============================================================================

/// Provider for MapRepository
final mapRepositoryProvider = Provider<MapRepository>((ref) {
  final locationDataSource = ref.watch(locationDataSourceProvider);
  final crystalDataSource = ref.watch(crystalDataSourceProvider);
  return MapRepositoryImpl(
    locationDataSource: locationDataSource,
    crystalDataSource: crystalDataSource,
  );
});

// ============================================================================
// Derived State Providers
// ============================================================================

/// Provider for checking if user is in proximity to any crystal
final isInProximityProvider = Provider<bool>((ref) {
  final mapState = ref.watch(mapViewModelProvider);
  return mapState.hasCrystalInRange;
});

/// Provider for the closest approaching crystal (if any)
final approachingCrystalProvider = Provider<CrystallizationAreaEntity?>((ref) {
  final mapState = ref.watch(mapViewModelProvider);
  return mapState.approachingCrystal;
});

/// Provider for proximity phase
final proximityPhaseProvider = Provider<ProximityPhase>((ref) {
  final mapState = ref.watch(mapViewModelProvider);
  return mapState.proximityPhase;
});

/// Provider for pulse intensity (for animations)
final pulseIntensityProvider = Provider<double>((ref) {
  final mapState = ref.watch(mapViewModelProvider);
  return mapState.pulseIntensity;
});

/// Provider for crystal color (for heartbeat effect)
final heartbeatColorProvider = Provider<int?>((ref) {
  final mapState = ref.watch(mapViewModelProvider);
  return mapState.approachingCrystalColor;
});

/// Provider for checking if mining transition should occur
final shouldTransitionToMiningProvider = Provider<bool>((ref) {
  final mapState = ref.watch(mapViewModelProvider);
  return mapState.canMine && mapState.approachingCrystal != null;
});

/// Provider for GPS warning visibility
final shouldShowGpsWarningProvider = Provider<bool>((ref) {
  final mapState = ref.watch(mapViewModelProvider);
  return mapState.shouldShowGpsWarning;
});

/// Provider for location permission status
final locationPermissionStatusProvider =
    Provider<LocationPermissionStatus>((ref) {
  final mapState = ref.watch(mapViewModelProvider);
  return mapState.permissionStatus;
});
