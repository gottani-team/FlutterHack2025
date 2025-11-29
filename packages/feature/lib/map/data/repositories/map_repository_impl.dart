import 'package:core/data/data_sources/location_data_source.dart';
import 'package:core/domain/entities/location_permission_status.dart';
import 'package:core/domain/entities/user_location_entity.dart';

import '../../domain/entities/crystallization_area_entity.dart';
import '../../domain/repositories/map_repository.dart';
import '../data_sources/crystal_mock_data_source.dart';

/// Implementation of MapRepository using mock crystal data and geolocator.
///
/// Note: Firestore integration is out of scope for MVP.
/// Crystal data comes from CrystalMockDataSource.
class MapRepositoryImpl implements MapRepository {
  MapRepositoryImpl({
    required this.locationDataSource,
    CrystalMockDataSource? crystalDataSource,
  }) : _crystalDataSource = crystalDataSource ?? CrystalMockDataSource.instance;

  final LocationDataSource locationDataSource;
  final CrystalMockDataSource _crystalDataSource;

  @override
  Stream<UserLocationEntity> watchUserLocation() {
    return locationDataSource.watchUserLocation();
  }

  @override
  Future<List<CrystallizationAreaEntity>> getCrystalsInBounds({
    required double minLatitude,
    required double maxLatitude,
    required double minLongitude,
    required double maxLongitude,
  }) async {
    // Use mock data source (Firestore integration is out of scope)
    return _crystalDataSource.getCrystallizationAreas(
      minLatitude: minLatitude,
      maxLatitude: maxLatitude,
      minLongitude: minLongitude,
      maxLongitude: maxLongitude,
    );
  }

  @override
  Future<LocationPermissionStatus> requestLocationPermission() {
    return locationDataSource.requestLocationPermission();
  }

  @override
  Future<LocationPermissionStatus> checkLocationPermission() {
    return locationDataSource.checkLocationPermission();
  }

  @override
  Future<bool> isLocationServiceEnabled() {
    return locationDataSource.isLocationServiceEnabled();
  }

  @override
  Future<void> openAppSettings() {
    return locationDataSource.openAppSettings();
  }

  @override
  Future<UserLocationEntity> getCurrentLocation() {
    return locationDataSource.getCurrentLocation();
  }
}
