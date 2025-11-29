// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ViewModel for the Map View screen.
///
/// Manages the state and business logic for:
/// - User location tracking
/// - Crystal proximity detection
/// - Sensory feedback coordination (visual, haptic, audio)
/// - Map interactions

@ProviderFor(MapViewModel)
const mapViewModelProvider = MapViewModelProvider._();

/// ViewModel for the Map View screen.
///
/// Manages the state and business logic for:
/// - User location tracking
/// - Crystal proximity detection
/// - Sensory feedback coordination (visual, haptic, audio)
/// - Map interactions
final class MapViewModelProvider
    extends $NotifierProvider<MapViewModel, MapViewState> {
  /// ViewModel for the Map View screen.
  ///
  /// Manages the state and business logic for:
  /// - User location tracking
  /// - Crystal proximity detection
  /// - Sensory feedback coordination (visual, haptic, audio)
  /// - Map interactions
  const MapViewModelProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'mapViewModelProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$mapViewModelHash();

  @$internal
  @override
  MapViewModel create() => MapViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MapViewState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MapViewState>(value),
    );
  }
}

String _$mapViewModelHash() => r'46c9a65b7f52ebd49669d7f2551c79e9bb1d9e2f';

/// ViewModel for the Map View screen.
///
/// Manages the state and business logic for:
/// - User location tracking
/// - Crystal proximity detection
/// - Sensory feedback coordination (visual, haptic, audio)
/// - Map interactions

abstract class _$MapViewModel extends $Notifier<MapViewState> {
  MapViewState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<MapViewState, MapViewState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<MapViewState, MapViewState>,
        MapViewState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
