import 'dart:math' as math;
import 'dart:ui';

import 'package:core/data/providers.dart';
import 'package:core/domain/common/result.dart';
import 'package:core/domain/failures/core_failure.dart';
import 'package:core/presentation/widgets/glass_app_bar_widget.dart';
import 'package:core/presentation/widgets/glass_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../crystal/presentation/pages/crystal_display_page.dart';
import '../../../repository_test/presentation/pages/repository_test_page.dart';
import '../../domain/entities/crystal_entity.dart';
import '../../domain/entities/crystallization_area_entity.dart';
import '../providers/map_providers.dart';
import '../state/map_view_state.dart';
import '../widgets/error_banner.dart';
import '../widgets/gps_warning_banner.dart';
import '../widgets/magical_loading_overlay.dart';

// User polygon layer IDs
const String _userPolygonSourceId = 'user-polygon-source';
const String _userPolygonLayerId = 'user-polygon-layer';

// Crystal marker layer IDs
const String _crystalSourceId = 'crystal-source';

// 3D Model IDs
const String _crystal3DModelId = 'crystal-3d-model';
// Remote GLB model for testing (Mapbox sample)
// TODO: Replace with local asset once iOS asset loading is resolved
const String _crystal3DModelUri =
    'https://raw.githubusercontent.com/nacky235/rock/main/rock.glb';

// Map configuration constants
const double _defaultPitch = 45.0; // Tilt angle for 3D view
const double _defaultBearing = 0.0;
const double _userPolygonRadius = 50.0; // Radius in meters

// 3D Model offset to align model bottom with ground
// Based on GLB bounding box: Y min = -0.174, Y center = 0.8775
// Offset to place model bottom at ground level (Y=0)
const double _modelYOffset = -0.174;

/// Primary color for crystal dialog
const Color _crystalPrimaryColor = Color(0xFFFF3C00);

/// Main map page for crystal discovery and proximity detection.
///
/// Displays a dark fantasy-themed map with crystallization areas,
/// and provides sensory feedback as users approach crystals.
class MapPage extends HookConsumerWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapState = ref.watch(mapViewModelProvider);
    final viewModel = ref.read(mapViewModelProvider.notifier);

    // Local state using hooks
    final mapboxMapRef = useRef<MapboxMap?>(null);
    final isProgrammaticCameraUpdate = useState(false);
    final existing3DModelLayers = useRef<Set<String>>({});

    // Handle app lifecycle changes
    useOnAppLifecycleStateChange((previous, current) {
      switch (current) {
        case AppLifecycleState.paused:
        case AppLifecycleState.inactive:
          viewModel.onAppLifecycleChanged(isBackground: true);
        case AppLifecycleState.resumed:
          viewModel.onAppLifecycleChanged(isBackground: false);
        case AppLifecycleState.detached:
        case AppLifecycleState.hidden:
          viewModel.stopLocationTracking();
      }
    });

    // Effect to load crystals after map style is loaded AND initial location is set
    useEffect(
      () {
        if (mapState.isMapStyleLoaded && mapState.hasSetInitialLocation) {
          Future.microtask(() async {
            debugPrint(
              '[MapPage] Loading crystals after map ready and initial location set',
            );
            viewModel.loadVisibleCrystallizationAreas();

            // Automatically load remote crystals on initial load
            await viewModel.loadRemoteCrystals(limit: 5);
            await _updateCrystalMarkers(
              mapboxMapRef.value,
              ref,
              existing3DModelLayers.value,
              context,
            );
          });
        }
        return null;
      },
      [mapState.isMapStyleLoaded, mapState.hasSetInitialLocation],
    );

    // Handle camera follow when user location changes
    ref.listen<MapViewState>(mapViewModelProvider, (previous, next) {
      // Update camera to follow user and rotate with heading
      if (next.isFollowingUser && next.userLocation != null) {
        final nextLocation = next.userLocation!;

        // Jump to initial location without animation on first location update
        if (!next.hasSetInitialLocation) {
          _jumpToInitialLocation(
            mapboxMapRef.value,
            nextLocation,
            isProgrammaticCameraUpdate,
            viewModel,
          );
        } else {
          // Smooth camera update for subsequent location changes
          _updateCameraToFollowUser(
            mapboxMapRef.value,
            nextLocation,
            isProgrammaticCameraUpdate,
          );
        }

        // Update user polygon when location changes
        _updateUserPolygon(mapboxMapRef.value, nextLocation);
      }
    });

    return VisibilityDetector(
      key: const Key('map_page_visibility_detector'),
      onVisibilityChanged: (info) {
        // Reload karma when page becomes visible (visibility > 50%)
        if (info.visibleFraction > 0.5) {
          viewModel.loadKarma();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Mapbox Map
            _buildMap(
              context,
              mapState,
              viewModel,
              mapboxMapRef,
              isProgrammaticCameraUpdate,
              existing3DModelLayers,
              ref,
            ),

            // Glass App Bar
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
              child: GlassAppBarWidget(
                title: 'HIMITSU no SECRET',
                icon: Icons.grid_view,
                onIconPressed: () {
                  context.push('/crystals');
                },
              ),
            ),

            // Top Right Actions (Scan & Recenter)
            _TopRightActions(
              topPadding: MediaQuery.of(context).padding.top + 70,
              isFollowingUser: mapState.isFollowingUser,
              onRecenterPressed: () => _recenterOnUser(
                mapboxMapRef.value,
                viewModel,
                mapState,
                isProgrammaticCameraUpdate,
              ),
              onScanPressed: () => _scanForCrystals(
                mapboxMapRef.value,
                viewModel,
                ref,
                existing3DModelLayers.value,
                context,
              ),
            ),

            // GPS Warning Banner
            if (mapState.shouldShowGpsWarning)
              Positioned(
                top: MediaQuery.of(context).padding.top + 130,
                left: 16,
                right: 16,
                child: const GpsWarningBanner(),
              ),

            // Loading Indicator
            if (mapState.isLoading)
              _buildLoadingOverlay(mapState.loadingMessage),

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

            // Bottom Left Actions
            _BottomLeftActions(
              karma: mapState.currentKarma,
              onDebugPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const _DebugRepositoryTestPage(),
                  ),
                );
              },
            ),

            // Bottom Right Actions
            _BottomRightActions(
              onCrystalSublimationPressed: () => context.push('/memory-burial'),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildMap(
  BuildContext context,
  MapViewState mapState,
  MapViewModel viewModel,
  ObjectRef<MapboxMap?> mapboxMapRef,
  ValueNotifier<bool> isProgrammaticCameraUpdate,
  ObjectRef<Set<String>> existing3DModelLayers,
  WidgetRef ref,
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
      pitch: _defaultPitch,
      bearing: _defaultBearing,
    ),
    styleUri: MapboxStyles.LIGHT,
    onMapCreated: (mapboxMap) =>
        _onMapCreated(mapboxMap, viewModel, mapboxMapRef),
    onStyleLoadedListener: (styleLoadedEventData) => _onStyleLoaded(
      mapboxMapRef.value!,
      viewModel,
      context,
      ref,
      existing3DModelLayers.value,
    ),
    onCameraChangeListener: (cameraChangedEventData) {
      if (isProgrammaticCameraUpdate.value) return;

      final center = cameraChangedEventData.cameraState.center;
      final zoom = cameraChangedEventData.cameraState.zoom;
      viewModel.onMapCameraMoved(
        latitude: center.coordinates.lat.toDouble(),
        longitude: center.coordinates.lng.toDouble(),
        zoomLevel: zoom,
      );

      _update3DModelScales(
        mapboxMapRef.value,
        zoom,
        existing3DModelLayers.value,
      );
    },
  );
}

Future<void> _onMapCreated(
  MapboxMap mapboxMap,
  MapViewModel viewModel,
  ObjectRef<MapboxMap?> mapboxMapRef,
) async {
  mapboxMapRef.value = mapboxMap;

  await _hideMapControls(mapboxMap);
  await _setupLocationPuck(mapboxMap);

  // Request location permission after map is ready
  // Crystals will be loaded via useEffect when both map style loaded AND initial location set
  viewModel.requestLocationPermission();
}

Future<void> _hideMapControls(MapboxMap mapboxMap) async {
  try {
    await mapboxMap.compass.updateSettings(CompassSettings(enabled: false));
    await mapboxMap.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
    await mapboxMap.attribution.updateSettings(
      AttributionSettings(enabled: false),
    );
    await mapboxMap.logo.updateSettings(LogoSettings(enabled: false));
    debugPrint('Map UI controls hidden');
  } catch (e) {
    debugPrint('Error hiding map controls: $e');
  }
}

Future<void> _onStyleLoaded(
  MapboxMap mapboxMap,
  MapViewModel viewModel,
  BuildContext context,
  WidgetRef ref,
  Set<String> existing3DModelLayers,
) async {
  final style = mapboxMap.style;

  await _hideLabels(style);
  await _enable3DBuildings(style);
  await _setupUserPolygonLayer(style);
  await _setupCrystalMarkerLayer(style);

  // Mark map style as loaded - this triggers useEffect to load crystals
  viewModel.setMapStyleLoaded(true);
}

Future<void> _hideLabels(StyleManager style) async {
  try {
    final layers = await style.getStyleLayers();

    for (final layer in layers) {
      final layerId = layer?.id;
      if (layerId == null) continue;

      final lowerLayerId = layerId.toLowerCase();

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
        await style.setStyleLayerProperty(layerId, 'visibility', 'none');
      }
    }
    debugPrint('All labels hidden');
  } catch (e) {
    debugPrint('Error hiding labels: $e');
  }
}

Future<void> _enable3DBuildings(StyleManager style) async {
  try {
    final layers = await style.getStyleLayers();

    for (final layer in layers) {
      final layerId = layer?.id;
      if (layerId == null) continue;

      if (layerId.contains('building')) {
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

Future<void> _setupCrystalMarkerLayer(StyleManager style) async {
  try {
    await style.addSource(
      GeoJsonSource(
        id: _crystalSourceId,
        data: '{"type":"FeatureCollection","features":[]}',
      ),
    );

    debugPrint('Crystal marker layer setup complete');

    await style.addStyleModel(_crystal3DModelId, _crystal3DModelUri);
    debugPrint('3D model added: $_crystal3DModelId');
  } catch (e) {
    debugPrint('Error setting up crystal marker layer: $e');
  }
}

Future<void> _scanForCrystals(
  MapboxMap? mapboxMap,
  MapViewModel viewModel,
  WidgetRef ref,
  Set<String> existing3DModelLayers,
  BuildContext context,
) async {
  debugPrint('Scanning for crystals...');

  await viewModel.loadRemoteCrystals(limit: 5);

  debugPrint('Remote crystals loaded');

  await _updateCrystalMarkers(
    mapboxMap,
    ref,
    existing3DModelLayers,
    context,
  );
}

Future<void> _updateCrystalMarkers(
  MapboxMap? mapboxMap,
  WidgetRef ref,
  Set<String> existing3DModelLayers,
  BuildContext context,
) async {
  if (mapboxMap == null) return;

  final mapState = ref.read(mapViewModelProvider);
  final crystals = mapState.visibleCrystallizationAreas;

  try {
    final geoJson = _createCrystalGeoJson(crystals);
    await mapboxMap.style.setStyleSourceProperty(
      _crystalSourceId,
      'data',
      geoJson,
    );

    await _update3DModels(
      mapboxMap,
      crystals,
      existing3DModelLayers,
      ref,
      context,
    );

    debugPrint('Updated ${crystals.length} crystal markers on map');
  } catch (e) {
    debugPrint('Error updating crystal markers: $e');
  }
}

Future<void> _remove3DModel(
  MapboxMap? mapboxMap,
  String crystalId,
  Set<String> existing3DModelLayers,
) async {
  if (mapboxMap == null) return;

  if (!existing3DModelLayers.contains(crystalId)) {
    debugPrint('3D model not found for crystal: $crystalId');
    return;
  }

  final style = mapboxMap.style;

  try {
    mapboxMap.removeInteraction('model-interaction-$crystalId');
    await style.removeStyleLayer('model-layer-$crystalId');
    await style.removeStyleLayer('tap-circle-layer-$crystalId');
    await style.removeStyleSource('model-source-$crystalId');
    existing3DModelLayers.remove(crystalId);
    debugPrint('Removed 3D model for crystal: $crystalId');
  } catch (e) {
    debugPrint('Error removing 3D model for $crystalId: $e');
  }
}

Future<void> _update3DModels(
  MapboxMap mapboxMap,
  List<CrystallizationAreaEntity> crystals,
  Set<String> existing3DModelLayers,
  WidgetRef ref,
  BuildContext context,
) async {
  final style = mapboxMap.style;

  // Remove old model layers that are no longer needed
  final currentCrystalIds = crystals.map((c) => c.crystalId).toSet();
  final layersToRemove = existing3DModelLayers
      .where((id) => !currentCrystalIds.contains(id))
      .toList();

  for (final crystalId in layersToRemove) {
    try {
      mapboxMap.removeInteraction('model-interaction-$crystalId');
      await style.removeStyleLayer('model-layer-$crystalId');
      await style.removeStyleLayer('tap-circle-layer-$crystalId');
      await style.removeStyleSource('model-source-$crystalId');
      existing3DModelLayers.remove(crystalId);
    } catch (e) {
      debugPrint('Error removing old model layer: $e');
    }
  }

  // Add/update model layers for each crystal
  for (final crystal in crystals) {
    final sourceId = 'model-source-${crystal.crystalId}';
    final layerId = 'model-layer-${crystal.crystalId}';
    final tapCircleLayerId = 'tap-circle-layer-${crystal.crystalId}';

    try {
      if (!existing3DModelLayers.contains(crystal.crystalId)) {
        final pointGeoJson = '''
{
  "type": "Point",
  "coordinates": [${crystal.approximateLongitude}, ${crystal.approximateLatitude}]
}''';

        await style.addSource(
          GeoJsonSource(id: sourceId, data: pointGeoJson),
        );

        final circleLayer = CircleLayer(
          id: tapCircleLayerId,
          sourceId: sourceId,
        );
        circleLayer.circleRadius = 30.0;
        circleLayer.circleColor = Colors.transparent.value;
        circleLayer.circleOpacity = 0.0;

        await style.addLayer(circleLayer);

        final interactionId = 'model-interaction-${crystal.crystalId}';
        final crystalId = crystal.crystalId;
        mapboxMap.addInteraction(
          TapInteraction(
            FeaturesetDescriptor(layerId: tapCircleLayerId),
            (feature, ctx) {
              _showCrystalDialog(
                context,
                ref,
                mapboxMap,
                crystalId,
                existing3DModelLayers,
              );
            },
          ),
          interactionID: interactionId,
        );

        final modelLayer = ModelLayer(id: layerId, sourceId: sourceId);
        modelLayer.modelId = _crystal3DModelUri;
        final zoomLevel = ref.read(mapViewModelProvider).mapZoomLevel;
        const baseScale = 10.0;
        final scale = baseScale * math.pow(17.5 / zoomLevel, 3);
        modelLayer.modelScale = [scale, scale, scale];
        modelLayer.modelRotation = [0.0, 0.0, 0.0];
        modelLayer.modelTranslation = [0.0, 0.0, 0.0];
        modelLayer.modelType = ModelType.COMMON_3D;

        await style.addLayer(modelLayer);
        existing3DModelLayers.add(crystal.crystalId);

        debugPrint('Added 3D model for crystal: ${crystal.crystalId}');
      }
    } catch (e) {
      debugPrint(
        'Error adding 3D model for crystal ${crystal.crystalId}: $e',
      );
    }
  }
}

Future<void> _update3DModelScales(
  MapboxMap? mapboxMap,
  double zoomLevel,
  Set<String> existing3DModelLayers,
) async {
  if (mapboxMap == null) return;

  final style = mapboxMap.style;
  const baseScale = 10.0;
  final scale = baseScale * math.pow(17.5 / zoomLevel, 3);

  for (final crystalId in existing3DModelLayers) {
    final layerId = 'model-layer-$crystalId';
    try {
      await style.setStyleLayerProperty(
        layerId,
        'model-scale',
        [scale, scale, scale],
      );
    } catch (e) {
      debugPrint('Error updating model scale for $layerId: $e');
    }
  }
}

void _showCrystalDialog(
  BuildContext context,
  WidgetRef ref,
  MapboxMap mapboxMap,
  String crystalId,
  Set<String> existing3DModelLayers,
) {
  final viewModel = ref.read(mapViewModelProvider.notifier);
  final crystal = viewModel.getRemoteCrystal(crystalId);

  final karmaPoint = crystal?.karmaValue ?? 0;
  final nickname = crystal?.creatorNickname ?? '不明';

  showDialog<void>(
    context: context,
    barrierColor: Colors.transparent,
    builder: (dialogContext) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            clipBehavior: Clip.antiAlias,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'ヒミツを買う',
                      style: GoogleFonts.notoSansJp(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Image.asset(
                      crystal?.tier.imageUrl ?? 'assets/images/stone.png',
                      width: 80,
                      height: 80,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '$nicknameのヒミツ',
                      style: GoogleFonts.notoSansJp(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black.withOpacity(0.85),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '$karmaPointポイントでヒミツを購入します',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(dialogContext).pop();
                          await _purchaseCrystal(
                            context,
                            ref,
                            mapboxMap,
                            crystalId,
                            existing3DModelLayers,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _crystalPrimaryColor.withOpacity(0.64),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          '購入する',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black.withOpacity(0.8),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          '後にする',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

void _showInsufficientKarmaDialog(
  BuildContext context,
  WidgetRef ref,
  String crystalId, {
  required int requiredKarma,
  required int availableKarma,
}) {
  final viewModel = ref.read(mapViewModelProvider.notifier);
  final crystal = viewModel.getRemoteCrystal(crystalId);
  final nickname = crystal?.creatorNickname ?? '不明';

  showDialog<void>(
    context: context,
    barrierColor: Colors.transparent,
    builder: (dialogContext) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            clipBehavior: Clip.antiAlias,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'ポイントが足りません',
                      style: GoogleFonts.notoSansJp(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Image.asset(
                      crystal?.tier.imageUrl ?? 'assets/images/stone.png',
                      width: 80,
                      height: 80,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '$nicknameのヒミツ',
                      style: GoogleFonts.notoSansJp(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black.withOpacity(0.85),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'このヒミツを買うには\n$requiredKarmaポイント必要です',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '現在の所持ポイント: $availableKarma',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          context.push('/memory-burial');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _crystalPrimaryColor.withOpacity(0.64),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'あなたのヒミツをポイントに変える',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black.withOpacity(0.8),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          '閉じる',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

Future<void> _purchaseCrystal(
  BuildContext context,
  WidgetRef ref,
  MapboxMap mapboxMap,
  String crystalId,
  Set<String> existing3DModelLayers,
) async {
  final viewModel = ref.read(mapViewModelProvider.notifier);

  // Start loading with mining message
  viewModel.setLoading(true, message: '採掘中...');

  try {
    final authRepository = ref.read(authRepositoryProvider);
    final sessionResult = await authRepository.getCurrentSession();

    switch (sessionResult) {
      case Success():
        final deciphermentRepository = ref.read(deciphermentRepositoryProvider);
        final result =
            await deciphermentRepository.decipher(crystalId: crystalId);

        switch (result) {
          case Success():
            viewModel.removeCrystal(crystalId);

            await _remove3DModel(mapboxMap, crystalId, existing3DModelLayers);

            if (context.mounted) {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) =>
                      CrystalDisplayPage(crystalId: crystalId),
                ),
              );
            }
          case Failure(error: final failure):
            if (context.mounted) {
              // カルマ不足の場合は専用ダイアログを表示
              if (failure is CoreFailure) {
                final insufficientKarma = failure.mapOrNull(
                  insufficientKarma: (e) => e,
                );
                if (insufficientKarma != null) {
                  _showInsufficientKarmaDialog(
                    context,
                    ref,
                    crystalId,
                    requiredKarma: insufficientKarma.required,
                    availableKarma: insufficientKarma.available,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '購入に失敗しました: ${failure.message}',
                        style: const TextStyle(color: Colors.black),
                      ),
                      backgroundColor: Colors.white,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '購入に失敗しました: $failure',
                      style: const TextStyle(color: Colors.black),
                    ),
                    backgroundColor: Colors.white,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            }
        }
      case Failure(error: final failure):
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'ログインが必要です: ${failure.message}',
                style: const TextStyle(color: Colors.black),
              ),
              backgroundColor: Colors.white,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
    }
  } finally {
    // Stop loading
    viewModel.setLoading(false);
  }
}

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

String _getEmotionColor(EmotionType emotionType) {
  switch (emotionType) {
    case EmotionType.joy:
      return '#FFD700';
    case EmotionType.healing:
      return '#4CAF50';
    case EmotionType.silence:
      return '#1E88E5';
    case EmotionType.passion:
      return '#F44336';
  }
}

Future<void> _setupUserPolygonLayer(StyleManager style) async {
  try {
    await style.addSource(
      GeoJsonSource(
        id: _userPolygonSourceId,
        data: '{"type":"FeatureCollection","features":[]}',
      ),
    );

    await style.addLayer(
      FillLayer(
        id: _userPolygonLayerId,
        sourceId: _userPolygonSourceId,
        fillColor: 0x334285F4,
        fillOutlineColor: 0xFF4285F4,
        fillOpacity: 0.3,
      ),
    );

    debugPrint('User polygon layer setup complete');
  } catch (e) {
    debugPrint('Error setting up user polygon layer: $e');
  }
}

String _createCirclePolygonGeoJson(
  double lat,
  double lng,
  double radiusMeters,
) {
  const int segments = 64;
  final List<List<double>> coordinates = [];

  const double earthRadius = 6371000;

  final double latDelta = (radiusMeters / earthRadius) * (180 / math.pi);
  final double lngDelta = latDelta / math.cos(lat * math.pi / 180);

  for (int i = 0; i <= segments; i++) {
    final double angle = (i * 2 * math.pi) / segments;
    final double x = lng + lngDelta * math.cos(angle);
    final double y = lat + latDelta * math.sin(angle);
    coordinates.add([x, y]);
  }

  final parts = coordinates.map((c) => '[${c[0]},${c[1]}]').join(',');

  return '''
{
  "type": "FeatureCollection",
  "features": [{
    "type": "Feature",
    "geometry": {
      "type": "Polygon",
      "coordinates": [[$parts]]
    },
    "properties": {}
  }]
}
''';
}

Future<void> _updateUserPolygon(
  MapboxMap? mapboxMap,
  UserLocationEntity userLocation,
) async {
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

Future<void> _setupLocationPuck(MapboxMap mapboxMap) async {
  try {
    await mapboxMap.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        showAccuracyRing: true,
        pulsingEnabled: true,
        pulsingColor: 0xFF4285F4,
        pulsingMaxRadius: 30.0,
        accuracyRingColor: 0x334285F4,
        accuracyRingBorderColor: 0x664285F4,
        puckBearingEnabled: true,
        puckBearing: PuckBearing.HEADING,
        locationPuck: LocationPuck(
          locationPuck2D: DefaultLocationPuck2D(
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

Future<void> _jumpToInitialLocation(
  MapboxMap? mapboxMap,
  UserLocationEntity userLocation,
  ValueNotifier<bool> isProgrammaticCameraUpdate,
  MapViewModel viewModel,
) async {
  if (mapboxMap == null) return;

  isProgrammaticCameraUpdate.value = true;

  try {
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

    // Mark initial location as set - this triggers useEffect to load crystals
    viewModel.setInitialLocationSet(true);
  } catch (e) {
    debugPrint('Error jumping to initial location: $e');
  } finally {
    Future.delayed(const Duration(milliseconds: 600), () {
      isProgrammaticCameraUpdate.value = false;
    });
  }
}

Future<void> _updateCameraToFollowUser(
  MapboxMap? mapboxMap,
  UserLocationEntity userLocation,
  ValueNotifier<bool> isProgrammaticCameraUpdate,
) async {
  if (mapboxMap == null) return;

  isProgrammaticCameraUpdate.value = true;

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
    Future.delayed(const Duration(milliseconds: 600), () {
      isProgrammaticCameraUpdate.value = false;
    });
  }
}

Widget _buildLoadingOverlay(String message) {
  return MagicalLoadingOverlay(message: message);
}

Widget _buildPermissionOverlay(BuildContext context, MapViewModel viewModel) {
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

Future<void> _recenterOnUser(
  MapboxMap? mapboxMap,
  MapViewModel viewModel,
  MapViewState mapState,
  ValueNotifier<bool> isProgrammaticCameraUpdate,
) async {
  if (mapboxMap == null) return;

  viewModel.recenterOnUser();

  final userLocation = mapState.userLocation;

  if (userLocation != null) {
    isProgrammaticCameraUpdate.value = true;

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

    Future.delayed(const Duration(milliseconds: 1100), () {
      isProgrammaticCameraUpdate.value = false;
    });
  }
}

/// Debug page wrapper that imports and displays the repository test page
class _DebugRepositoryTestPage extends ConsumerWidget {
  const _DebugRepositoryTestPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const RepositoryTestPage();
  }
}

/// Widget to display the user's current karma balance with slot animation
class _KarmaBalanceWidget extends StatefulWidget {
  const _KarmaBalanceWidget({required this.karma});

  final int? karma;

  @override
  State<_KarmaBalanceWidget> createState() => _KarmaBalanceWidgetState();
}

class _KarmaBalanceWidgetState extends State<_KarmaBalanceWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int _displayedValue = 0;
  int _previousValue = 0;
  int _targetValue = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Initialize with current karma value
    if (widget.karma != null) {
      _displayedValue = widget.karma!;
      _previousValue = widget.karma!;
      _targetValue = widget.karma!;
    }

    _animationController.addListener(_onAnimationTick);
  }

  @override
  void didUpdateWidget(_KarmaBalanceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Animate when karma value changes
    if (widget.karma != null && widget.karma != _targetValue) {
      _previousValue = _displayedValue;
      _targetValue = widget.karma!;
      _animationController.forward(from: 0);
    }
  }

  void _onAnimationTick() {
    if (mounted) {
      setState(() {
        // Use easeOutCubic curve for smooth deceleration
        final curvedValue = Curves.easeOutCubic.transform(
          _animationController.value,
        );
        _displayedValue =
            (_previousValue + ((_targetValue - _previousValue) * curvedValue))
                .round();
      });
    }
  }

  @override
  void dispose() {
    _animationController.removeListener(_onAnimationTick);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayText = widget.karma != null ? '$_displayedValue' : '--';

    return GlassCardWidget(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      borderRadius: 24,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            displayText,
            style: GoogleFonts.notoSansJp(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'P',
            style: GoogleFonts.notoSansJp(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget to display bottom left action buttons
class _BottomLeftActions extends StatelessWidget {
  const _BottomLeftActions({
    required this.karma,
    required this.onDebugPressed,
  });

  final int? karma;
  final VoidCallback onDebugPressed;

  // Spacing between buttons
  static const double _buttonSpacing = 12.0;
  static const double _bottomPadding = 48.0;
  static const double _horizontalPadding = 16.0;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: _bottomPadding,
      left: _horizontalPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Debug Menu Button
          FloatingActionButton.small(
            heroTag: 'debug',
            onPressed: onDebugPressed,
            backgroundColor: Colors.grey.shade800,
            child: const Icon(
              Icons.bug_report,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: _buttonSpacing),
          // Karma Balance Display
          _KarmaBalanceWidget(karma: karma),
        ],
      ),
    );
  }
}

/// Widget to display top right action buttons (below app bar)
class _TopRightActions extends StatelessWidget {
  const _TopRightActions({
    required this.topPadding,
    required this.isFollowingUser,
    required this.onRecenterPressed,
    required this.onScanPressed,
  });

  final double topPadding;
  final bool isFollowingUser;
  final VoidCallback onRecenterPressed;
  final VoidCallback onScanPressed;

  static const double _buttonSpacing = 12.0;
  static const double _horizontalPadding = 16.0;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: topPadding,
      right: _horizontalPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Recenter Button
          _GlassActionButton(
            onPressed: onRecenterPressed,
            icon: isFollowingUser ? Icons.gps_fixed : Icons.gps_not_fixed,
          ),
          const SizedBox(height: _buttonSpacing),
          // Scan Button
          _GlassActionButton(
            onPressed: onScanPressed,
            icon: Icons.radar,
          ),
        ],
      ),
    );
  }
}

/// Widget to display bottom right action buttons
class _BottomRightActions extends StatelessWidget {
  const _BottomRightActions({
    required this.onCrystalSublimationPressed,
  });

  final VoidCallback onCrystalSublimationPressed;

  static const double _bottomPadding = 48.0;
  static const double _horizontalPadding = 16.0;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: _bottomPadding,
      right: _horizontalPadding,
      child: _OrangeGlassActionButton(
        onPressed: onCrystalSublimationPressed,
        icon: Icons.add,
      ),
    );
  }
}

/// Glass action button with transparent/white glassmorphism style
class _GlassActionButton extends StatelessWidget {
  const _GlassActionButton({
    required this.onPressed,
    required this.icon,
  });

  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: SizedBox(
        width: 44.0,
        height: 44.0,
        child: GlassCardWidget(
          borderRadius: 22,
          child: Center(
            child: Icon(
              icon,
              color: Colors.black,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

/// Orange glass action button with glassmorphism style
class _OrangeGlassActionButton extends StatelessWidget {
  const _OrangeGlassActionButton({
    required this.onPressed,
    required this.icon,
  });

  final VoidCallback onPressed;
  final IconData icon;

  static const Color _orangeColor = Color(0xFFFF6B35);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: SizedBox(
        width: 56.0,
        height: 56.0,
        child: GlassCardWidget(
          borderRadius: 28,
          backgroundColor: _orangeColor.withOpacity(0.85),
          borderColor: _orangeColor,
          child: Center(
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
