import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../domain/entities/crystal_entity.dart';
import '../../domain/entities/crystallization_area_entity.dart';
import '../providers/map_providers.dart';
import '../state/map_view_state.dart';
import '../widgets/error_banner.dart';
import '../widgets/gps_warning_banner.dart';
import '../widgets/magical_loading_overlay.dart';

/// Main map page for crystal discovery and proximity detection.
///
/// Displays a dark fantasy-themed map with crystallization areas,
/// and provides sensory feedback as users approach crystals.
class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> with WidgetsBindingObserver {
  MapboxMap? _mapboxMap;

  // Flag to prevent onCameraChangeListener from firing during programmatic updates
  bool _isProgrammaticCameraUpdate = false;

  // Flag to track if initial location has been set
  bool _hasSetInitialLocation = false;

  // User polygon layer IDs
  static const String _userPolygonSourceId = 'user-polygon-source';
  static const String _userPolygonLayerId = 'user-polygon-layer';

  // Crystal marker layer IDs
  static const String _crystalSourceId = 'crystal-source';
  static const String _crystalLayerId = 'crystal-layer';

  // 3D Model IDs
  static const String _crystal3DModelId = 'crystal-3d-model';
  // Local asset for crystal 3D model (from feature package)
  static const String _crystal3DModelUri =
      'asset://packages/feature/assets/models/rock.glb';

  // Map configuration constants
  static const double _defaultPitch = 45.0; // Tilt angle for 3D view
  static const double _defaultBearing = 0.0;
  static const double _userPolygonRadius = 50.0; // Radius in meters

  @override
  void initState() {
    super.initState();
    // Register lifecycle observer
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Unregister lifecycle observer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final viewModel = ref.read(mapViewModelProvider.notifier);

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // App is going to background - reduce battery usage
        viewModel.onAppLifecycleChanged(isBackground: true);
        break;
      case AppLifecycleState.resumed:
        // App is back to foreground - resume full tracking
        viewModel.onAppLifecycleChanged(isBackground: false);
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // App is being destroyed or hidden
        viewModel.stopLocationTracking();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapViewModelProvider);
    final viewModel = ref.read(mapViewModelProvider.notifier);

    // Handle camera follow when user location changes
    ref.listen<MapViewState>(mapViewModelProvider, (previous, next) {
      // Update camera to follow user and rotate with heading
      if (next.isFollowingUser && next.userLocation != null) {
        final nextLocation = next.userLocation!;

        // Jump to initial location without animation on first location update
        if (!_hasSetInitialLocation) {
          _hasSetInitialLocation = true;
          _jumpToInitialLocation(nextLocation);
        } else {
          // Smooth camera update for subsequent location changes
          _updateCameraToFollowUser(nextLocation);
        }

        // Update user polygon when location changes
        _updateUserPolygon(nextLocation);
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // Mapbox Map
          _buildMap(context, mapState, viewModel),

          // GPS Warning Banner
          if (mapState.shouldShowGpsWarning)
            const Positioned(
              top: 60,
              left: 16,
              right: 16,
              child: GpsWarningBanner(),
            ),

          // Loading Indicator
          if (mapState.isLoading) _buildLoadingOverlay(),

          // Error Banner
          if (mapState.errorMessage != null)
            Positioned(
              bottom: 100,
              left: 16,
              right: 16,
              child: ErrorBanner(
                message: mapState.errorMessage!,
                onDismiss: () => viewModel.clearError(),
              ),
            ),

          // Permission Request Overlay
          if (mapState.permissionStatus == LocationPermissionStatus.denied ||
              mapState.permissionStatus ==
                  LocationPermissionStatus.notDetermined)
            _buildPermissionOverlay(context, viewModel),

          // Recenter Button
          Positioned(
            bottom: 100,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'recenter',
              onPressed: () => _recenterOnUser(viewModel),
              backgroundColor: Colors.white,
              child: Icon(
                mapState.isFollowingUser
                    ? Icons.gps_fixed
                    : Icons.gps_not_fixed,
                color: const Color(0xFF4285F4),
              ),
            ),
          ),

          // Scan Button
          Positioned(
            bottom: 170,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'scan',
              onPressed: () => _scanForCrystals(viewModel),
              backgroundColor: const Color(0xFF9C27B0),
              child: const Icon(
                Icons.radar,
                color: Colors.white,
              ),
            ),
          ),

          // Crystal count debug info
          Positioned(
            top: 60,
            left: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${mapState.visibleCrystallizationAreas.length}P',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Debug Menu Button
          Positioned(
            top: 60,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: 'debug_menu',
              onPressed: () => context.pushNamed('repository-test'),
              backgroundColor: Colors.black54,
              child: const Icon(
                Icons.bug_report,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap(
    BuildContext context,
    MapViewState mapState,
    MapViewModel viewModel,
  ) {
    // Default location: Shibaura area
    const defaultLatitude = 35.62871770681847;
    const defaultLongitude = 139.77776556855437;

    // Use user location if available, otherwise use state center or default
    final initialLongitude = mapState.userLocation?.longitude ??
        mapState.mapCenterLongitude ??
        defaultLongitude;
    final initialLatitude = mapState.userLocation?.latitude ??
        mapState.mapCenterLatitude ??
        defaultLatitude;

    return MapWidget(
      key: const ValueKey('mapbox_map'),
      cameraOptions: CameraOptions(
        center: Point(
          coordinates: Position(
            initialLongitude,
            initialLatitude,
          ),
        ),
        zoom: mapState.mapZoomLevel,
        pitch: _defaultPitch, // Tilted view for 3D buildings
        bearing: _defaultBearing,
      ),
      styleUri: MapboxStyles.STANDARD, // Standard map style
      onMapCreated: (mapboxMap) => _onMapCreated(mapboxMap, viewModel),
      onStyleLoadedListener: (styleLoadedEventData) =>
          _onStyleLoaded(_mapboxMap!),
      onCameraChangeListener: (cameraChangedEventData) {
        // Skip if this is a programmatic camera update (not user interaction)
        if (_isProgrammaticCameraUpdate) return;

        // Update state when user manually moves map
        final center = cameraChangedEventData.cameraState.center;
        final zoom = cameraChangedEventData.cameraState.zoom;
        viewModel.onMapCameraMoved(
          latitude: center.coordinates.lat.toDouble(),
          longitude: center.coordinates.lng.toDouble(),
          zoomLevel: zoom,
        );

        // Log visible bounds (for debugging)
        _logVisibleBounds();
      },
    );
  }

  Future<void> _onMapCreated(
    MapboxMap mapboxMap,
    MapViewModel viewModel,
  ) async {
    _mapboxMap = mapboxMap;

    // Hide map UI controls for cleaner look
    await _hideMapControls(mapboxMap);

    // Setup user location puck (blue dot like native maps)
    await _setupLocationPuck(mapboxMap);

    // Request location permission after map is ready
    viewModel.requestLocationPermission();

    // Load visible crystals
    viewModel.loadVisibleCrystallizationAreas();
  }

  /// Hide map UI controls (compass, scale bar, attribution, logo)
  Future<void> _hideMapControls(MapboxMap mapboxMap) async {
    try {
      // Hide compass
      await mapboxMap.compass.updateSettings(
        CompassSettings(enabled: false),
      );

      // Hide scale bar
      await mapboxMap.scaleBar.updateSettings(
        ScaleBarSettings(enabled: false),
      );

      // Hide attribution button (info button)
      await mapboxMap.attribution.updateSettings(
        AttributionSettings(enabled: false),
      );

      // Hide Mapbox logo
      await mapboxMap.logo.updateSettings(
        LogoSettings(enabled: false),
      );

      debugPrint('Map UI controls hidden');
    } catch (e) {
      debugPrint('Error hiding map controls: $e');
    }
  }

  /// Called when map style is fully loaded
  Future<void> _onStyleLoaded(MapboxMap mapboxMap) async {
    final style = mapboxMap.style;

    // Hide text labels for cleaner look
    await _hideLabels(style);

    // Enable 3D buildings
    await _enable3DBuildings(style);

    // Setup user polygon layer
    await _setupUserPolygonLayer(style);

    // Setup crystal marker layer
    await _setupCrystalMarkerLayer(style);
  }

  /// Hide all text labels and symbols on the map
  Future<void> _hideLabels(StyleManager style) async {
    try {
      // Get all layer IDs
      final layers = await style.getStyleLayers();

      for (final layer in layers) {
        final layerId = layer?.id;
        if (layerId == null) continue;

        // Convert to lowercase for case-insensitive matching
        final lowerLayerId = layerId.toLowerCase();

        // Hide all symbol layers (text labels, icons, markers)
        // This covers: place names, road names, POIs, transit, etc.
        if (lowerLayerId.contains('label') ||
            lowerLayerId.contains('place') ||
            lowerLayerId.contains('poi') ||
            lowerLayerId.contains('road-number') ||
            lowerLayerId.contains('transit') ||
            lowerLayerId.contains('symbol') ||
            lowerLayerId.contains('text') ||
            lowerLayerId.contains('name') ||
            lowerLayerId.contains('icon') ||
            lowerLayerId.contains('shield') ||
            lowerLayerId.contains('marker') ||
            lowerLayerId.contains('airport') ||
            lowerLayerId.contains('station') ||
            lowerLayerId.contains('country') ||
            lowerLayerId.contains('state') ||
            lowerLayerId.contains('settlement') ||
            lowerLayerId.contains('water-name') ||
            lowerLayerId.contains('natural')) {
          await style.setStyleLayerProperty(
            layerId,
            'visibility',
            'none',
          );
          debugPrint('Hidden layer: $layerId');
        }
      }
      debugPrint('All labels hidden');
    } catch (e) {
      debugPrint('Error hiding labels: $e');
    }
  }

  /// Enable 3D building extrusions
  Future<void> _enable3DBuildings(StyleManager style) async {
    try {
      // Check if building layer exists and configure it for 3D
      final layers = await style.getStyleLayers();

      for (final layer in layers) {
        final layerId = layer?.id;
        if (layerId == null) continue;

        // Find building layer and make it 3D
        if (layerId.contains('building')) {
          // Set building extrusion height
          await style.setStyleLayerProperty(
            layerId,
            'fill-extrusion-height',
            ['get', 'height'],
          );
          await style.setStyleLayerProperty(
            layerId,
            'fill-extrusion-base',
            ['get', 'min_height'],
          );
          await style.setStyleLayerProperty(
            layerId,
            'fill-extrusion-opacity',
            0.8,
          );
        }
      }
    } catch (e) {
      debugPrint('Error enabling 3D buildings: $e');
    }
  }

  /// Setup crystal marker layer (circle markers as fallback)
  Future<void> _setupCrystalMarkerLayer(StyleManager style) async {
    try {
      // Create an empty GeoJSON source for crystal markers
      await style.addSource(
        GeoJsonSource(
          id: _crystalSourceId,
          data: '{"type":"FeatureCollection","features":[]}',
        ),
      );

      // Add a circle layer for crystal markers (as fallback/base)
      await style.addLayer(
        CircleLayer(
          id: _crystalLayerId,
          sourceId: _crystalSourceId,
          circleRadius: 15.0,
          circleColor: 0xFF9C27B0, // Purple default
          circleOpacity: 0.8,
          circleStrokeWidth: 3.0,
          circleStrokeColor: 0xFFFFFFFF,
        ),
      );

      debugPrint('Crystal marker layer setup complete');

      // Also setup 3D model
      await _setup3DModel(style);
    } catch (e) {
      debugPrint('Error setting up crystal marker layer: $e');
    }
  }

  /// Setup 3D model for crystals
  Future<void> _setup3DModel(StyleManager style) async {
    try {
      // Add the 3D model to the style
      await style.addStyleModel(_crystal3DModelId, _crystal3DModelUri);
      debugPrint('3D model added: $_crystal3DModelId');
    } catch (e) {
      debugPrint('Error setting up 3D model: $e');
    }
  }

  /// Scan for crystals in the visible area
  Future<void> _scanForCrystals(MapViewModel viewModel) async {
    final bounds = await getVisibleBoundsAsMap();
    if (bounds == null) {
      debugPrint('Could not get visible bounds');
      return;
    }

    // Scan the visible area for crystals
    final newCrystals = viewModel.scanVisibleArea(
      minLat: bounds['minLat']!,
      maxLat: bounds['maxLat']!,
      minLng: bounds['minLng']!,
      maxLng: bounds['maxLng']!,
    );

    debugPrint('Scanned and found ${newCrystals.length} new crystals');

    // Update crystal markers on the map
    await _updateCrystalMarkers();
  }

  /// Update crystal markers on the map
  Future<void> _updateCrystalMarkers() async {
    final mapboxMap = _mapboxMap;
    if (mapboxMap == null) return;

    final mapState = ref.read(mapViewModelProvider);
    final crystals = mapState.visibleCrystallizationAreas;

    try {
      // Update circle markers (fallback)
      final geoJson = _createCrystalGeoJson(crystals);
      await mapboxMap.style.setStyleSourceProperty(
        _crystalSourceId,
        'data',
        geoJson,
      );

      // Update 3D models for each crystal
      await _update3DModels(crystals);

      debugPrint('Updated ${crystals.length} crystal markers on map');
    } catch (e) {
      debugPrint('Error updating crystal markers: $e');
    }
  }

  // Track existing 3D model layers
  final Set<String> _existing3DModelLayers = {};

  /// Update 3D models for crystals
  Future<void> _update3DModels(List<CrystallizationAreaEntity> crystals) async {
    final mapboxMap = _mapboxMap;
    if (mapboxMap == null) return;

    final style = mapboxMap.style;

    // Remove old model layers that are no longer needed
    final currentCrystalIds = crystals.map((c) => c.crystalId).toSet();
    final layersToRemove = _existing3DModelLayers
        .where((id) => !currentCrystalIds.contains(id))
        .toList();

    for (final layerId in layersToRemove) {
      try {
        await style.removeStyleLayer('model-layer-$layerId');
        await style.removeStyleSource('model-source-$layerId');
        _existing3DModelLayers.remove(layerId);
      } catch (e) {
        debugPrint('Error removing old model layer: $e');
      }
    }

    // Add/update model layers for each crystal
    for (final crystal in crystals) {
      final sourceId = 'model-source-${crystal.crystalId}';
      final layerId = 'model-layer-${crystal.crystalId}';

      try {
        if (!_existing3DModelLayers.contains(crystal.crystalId)) {
          // Create GeoJSON for this crystal's position
          final pointGeoJson = '''
{
  "type": "Point",
  "coordinates": [${crystal.approximateLongitude}, ${crystal.approximateLatitude}]
}''';

          // Add source for this crystal
          await style.addSource(
            GeoJsonSource(
              id: sourceId,
              data: pointGeoJson,
            ),
          );

          // Add model layer for this crystal
          final modelLayer = ModelLayer(
            id: layerId,
            sourceId: sourceId,
          );
          modelLayer.modelId = _crystal3DModelId;
          modelLayer.modelScale = [0.5, 0.5, 0.5]; // Adjust scale as needed
          modelLayer.modelRotation = [0, 0, 0];
          modelLayer.modelType = ModelType.COMMON_3D;

          await style.addLayer(modelLayer);
          _existing3DModelLayers.add(crystal.crystalId);

          debugPrint('Added 3D model for crystal: ${crystal.crystalId}');
        }
      } catch (e) {
        debugPrint(
          'Error adding 3D model for crystal ${crystal.crystalId}: $e',
        );
      }
    }
  }

  /// Create GeoJSON for crystal markers
  String _createCrystalGeoJson(List<CrystallizationAreaEntity> crystals) {
    if (crystals.isEmpty) {
      return '{"type":"FeatureCollection","features":[]}';
    }

    final features = crystals.map((crystal) {
      final color = _getEmotionColor(crystal.emotionType);
      return '''
{
  "type": "Feature",
  "geometry": {
    "type": "Point",
    "coordinates": [${crystal.approximateLongitude}, ${crystal.approximateLatitude}]
  },
  "properties": {
    "id": "${crystal.crystalId}",
    "emotionType": "${crystal.emotionType.name}",
    "color": "$color"
  }
}''';
    }).join(',');

    return '{"type":"FeatureCollection","features":[$features]}';
  }

  /// Get color hex string for emotion type
  String _getEmotionColor(EmotionType emotionType) {
    switch (emotionType) {
      case EmotionType.joy:
        return '#FFD700'; // Gold
      case EmotionType.healing:
        return '#4CAF50'; // Green
      case EmotionType.silence:
        return '#1E88E5'; // Blue
      case EmotionType.passion:
        return '#F44336'; // Red
    }
  }

  /// Setup user polygon layer (circle around user)
  Future<void> _setupUserPolygonLayer(StyleManager style) async {
    try {
      // Create an empty GeoJSON source for the user polygon
      await style.addSource(
        GeoJsonSource(
          id: _userPolygonSourceId,
          data: _createEmptyPolygonGeoJson(),
        ),
      );

      // Add a fill layer for the polygon
      await style.addLayer(
        FillLayer(
          id: _userPolygonLayerId,
          sourceId: _userPolygonSourceId,
          fillColor: 0x334285F4, // Semi-transparent blue
          fillOutlineColor: 0xFF4285F4, // Blue outline
          fillOpacity: 0.3,
        ),
      );

      debugPrint('User polygon layer setup complete');
    } catch (e) {
      debugPrint('Error setting up user polygon layer: $e');
    }
  }

  /// Create empty polygon GeoJSON
  String _createEmptyPolygonGeoJson() {
    return '{"type":"FeatureCollection","features":[]}';
  }

  /// Create circle polygon GeoJSON around a point
  String _createCirclePolygonGeoJson(
    double lat,
    double lng,
    double radiusMeters,
  ) {
    const int segments = 64;
    final List<List<double>> coordinates = [];

    // Earth radius in meters
    const double earthRadius = 6371000;

    // Convert radius from meters to degrees (approximate)
    final double latDelta = (radiusMeters / earthRadius) * (180 / math.pi);
    final double lngDelta = latDelta / math.cos(lat * math.pi / 180);

    for (int i = 0; i <= segments; i++) {
      final double angle = (i * 2 * math.pi) / segments;
      final double x = lng + lngDelta * math.cos(angle);
      final double y = lat + latDelta * math.sin(angle);
      coordinates.add([x, y]);
    }

    return '''
{
  "type": "FeatureCollection",
  "features": [{
    "type": "Feature",
    "geometry": {
      "type": "Polygon",
      "coordinates": [${_coordinatesToJson(coordinates)}]
    },
    "properties": {}
  }]
}
''';
  }

  String _coordinatesToJson(List<List<double>> coords) {
    final parts = coords.map((c) => '[${c[0]},${c[1]}]').join(',');
    return '[$parts]';
  }

  /// Update user polygon position
  Future<void> _updateUserPolygon(UserLocationEntity userLocation) async {
    final mapboxMap = _mapboxMap;
    if (mapboxMap == null) return;

    try {
      final geoJson = _createCirclePolygonGeoJson(
        userLocation.latitude,
        userLocation.longitude,
        _userPolygonRadius,
      );

      await mapboxMap.style.setStyleSourceProperty(
        _userPolygonSourceId,
        'data',
        geoJson,
      );
    } catch (e) {
      debugPrint('Error updating user polygon: $e');
    }
  }

  /// Get the visible bounds of the current map viewport
  /// Returns a CoordinateBounds with southwest and northeast corners
  Future<CoordinateBounds?> getVisibleBounds() async {
    final mapboxMap = _mapboxMap;
    if (mapboxMap == null) return null;

    try {
      // Get current camera state
      final cameraState = await mapboxMap.getCameraState();

      // Get the coordinate bounds for the current camera
      final bounds = await mapboxMap.coordinateBoundsForCamera(
        CameraOptions(
          center: cameraState.center,
          zoom: cameraState.zoom,
          bearing: cameraState.bearing,
          pitch: cameraState.pitch,
          padding: cameraState.padding,
        ),
      );

      debugPrint('Visible bounds:');
      debugPrint(
        '  Southwest: ${bounds.southwest.coordinates.lat}, ${bounds.southwest.coordinates.lng}',
      );
      debugPrint(
        '  Northeast: ${bounds.northeast.coordinates.lat}, ${bounds.northeast.coordinates.lng}',
      );

      return bounds;
    } catch (e) {
      debugPrint('Error getting visible bounds: $e');
      return null;
    }
  }

  /// Get visible bounds as a simple map with lat/lng values
  Future<Map<String, double>?> getVisibleBoundsAsMap() async {
    final bounds = await getVisibleBounds();
    if (bounds == null) return null;

    return {
      'minLat': bounds.southwest.coordinates.lat.toDouble(),
      'maxLat': bounds.northeast.coordinates.lat.toDouble(),
      'minLng': bounds.southwest.coordinates.lng.toDouble(),
      'maxLng': bounds.northeast.coordinates.lng.toDouble(),
    };
  }

  /// Log visible bounds for debugging
  Future<void> _logVisibleBounds() async {
    final bounds = await getVisibleBoundsAsMap();
    if (bounds != null) {
      debugPrint('Visible area: '
          'lat(${bounds['minLat']?.toStringAsFixed(6)} - ${bounds['maxLat']?.toStringAsFixed(6)}), '
          'lng(${bounds['minLng']?.toStringAsFixed(6)} - ${bounds['maxLng']?.toStringAsFixed(6)})');
    }
  }

  /// Setup location puck (blue dot indicator like native maps)
  Future<void> _setupLocationPuck(MapboxMap mapboxMap) async {
    try {
      // Enable location component with puck styling
      await mapboxMap.location.updateSettings(
        LocationComponentSettings(
          enabled: true,
          showAccuracyRing: true,
          pulsingEnabled: true,
          pulsingColor: 0xFF4285F4, // Google Maps blue
          pulsingMaxRadius: 30.0,
          accuracyRingColor: 0x334285F4, // Semi-transparent blue
          accuracyRingBorderColor: 0x664285F4,
          puckBearingEnabled: true,
          puckBearing: PuckBearing.HEADING,
          locationPuck: LocationPuck(
            locationPuck2D: DefaultLocationPuck2D(
              // Use default blue dot appearance
              topImage: null,
              bearingImage: null,
              shadowImage: null,
            ),
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error setting up location puck: $e');
    }
  }

  /// Jump to initial user location without animation
  Future<void> _jumpToInitialLocation(UserLocationEntity userLocation) async {
    final mapboxMap = _mapboxMap;
    if (mapboxMap == null) return;

    _isProgrammaticCameraUpdate = true;

    try {
      // Use flyTo with short duration for smooth initial positioning
      await mapboxMap.flyTo(
        CameraOptions(
          center: Point(
            coordinates: Position(
              userLocation.longitude,
              userLocation.latitude,
            ),
          ),
          bearing: userLocation.heading ?? 0.0,
          pitch: _defaultPitch,
          zoom: 17.5,
        ),
        MapAnimationOptions(duration: 500),
      );
      debugPrint('Camera moved to initial user location: '
          '${userLocation.latitude}, ${userLocation.longitude}');
    } catch (e) {
      debugPrint('Error jumping to initial location: $e');
    } finally {
      Future.delayed(const Duration(milliseconds: 600), () {
        _isProgrammaticCameraUpdate = false;
      });
    }
  }

  /// Update camera to follow user location and rotate with heading
  Future<void> _updateCameraToFollowUser(
    UserLocationEntity userLocation,
  ) async {
    final mapboxMap = _mapboxMap;
    if (mapboxMap == null) return;

    // Set flag to prevent onCameraChangeListener from triggering
    _isProgrammaticCameraUpdate = true;

    try {
      await mapboxMap.easeTo(
        CameraOptions(
          center: Point(
            coordinates: Position(
              userLocation.longitude,
              userLocation.latitude,
            ),
          ),
          bearing: userLocation.heading ?? 0.0,
          pitch: _defaultPitch,
        ),
        MapAnimationOptions(duration: 500),
      );
    } catch (e) {
      debugPrint('Error updating camera: $e');
    } finally {
      // Reset flag after animation completes
      Future.delayed(const Duration(milliseconds: 600), () {
        _isProgrammaticCameraUpdate = false;
      });
    }
  }

  Widget _buildLoadingOverlay() {
    return const MagicalLoadingOverlay(
      message: '地脈を探索中...',
    );
  }

  Widget _buildPermissionOverlay(
    BuildContext context,
    MapViewModel viewModel,
  ) {
    return Container(
      color: const Color(0xF0000000),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.location_on,
                size: 64,
                color: Color(0xFF4A90D9),
              ),
              const SizedBox(height: 24),
              const Text(
                '位置情報の許可が必要です',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                '地脈の結晶を探索するために、\n位置情報へのアクセスを許可してください。',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => viewModel.requestLocationPermission(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90D9),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('位置情報を許可する'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Recenter map camera on user's current location and resume following
  Future<void> _recenterOnUser(MapViewModel viewModel) async {
    final mapboxMap = _mapboxMap;
    if (mapboxMap == null) return;

    // Update ViewModel state
    viewModel.recenterOnUser();

    // Get user location from state
    final mapState = ref.read(mapViewModelProvider);
    final userLocation = mapState.userLocation;

    if (userLocation != null) {
      // Set flag to prevent onCameraChangeListener from triggering
      _isProgrammaticCameraUpdate = true;

      // Fly to user location with current heading
      await mapboxMap.flyTo(
        CameraOptions(
          center: Point(
            coordinates: Position(
              userLocation.longitude,
              userLocation.latitude,
            ),
          ),
          zoom: mapState.mapZoomLevel,
          pitch: _defaultPitch,
          bearing: userLocation.heading ?? 0.0,
        ),
        MapAnimationOptions(duration: 1000),
      );

      // Reset flag after animation completes
      Future.delayed(const Duration(milliseconds: 1100), () {
        _isProgrammaticCameraUpdate = false;
      });
    }
  }
}
